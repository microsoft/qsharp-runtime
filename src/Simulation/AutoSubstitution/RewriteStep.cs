// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Linq;
using Microsoft.CodeAnalysis;
using Microsoft.Quantum.QsCompiler;
using Microsoft.Quantum.QsCompiler.CsharpGeneration;
using Microsoft.Quantum.QsCompiler.SyntaxTokens;
using Microsoft.Quantum.QsCompiler.SyntaxTree;

namespace Microsoft.Quantum.QsCompiler.AutoSubstitution
{
    /// <summary>
    /// A Q# rewrite step for auto substitution
    /// </summary>
    ///
    /// <para>
    /// This rewrite step creates custom emulators for operations that have the
    /// <c>SubstitutableOnTarget</c> attribute.  This attribute holds an alternative operation,
    /// with the same signature, as its first argument, and a simulator, for which
    /// the alternative operation should be used, as its second argument.
    /// </para>
    public class RewriteStep : IRewriteStep
    {
        public string Name => "AutoSubstitution";

        // This rewrite step needs to be run before syntax tree trimming
        public int Priority => RewriteStepPriorities.SyntaxTreeTrimming + 1;

        public IDictionary<string, string?> AssemblyConstants { get; } = new Dictionary<string, string?>();

        public IEnumerable<IRewriteStep.Diagnostic> GeneratedDiagnostics => diagnostics;

        public bool ImplementsPreconditionVerification => false;

        public bool ImplementsTransformation => true;

        public bool ImplementsPostconditionVerification => false;

        public bool PostconditionVerification(QsCompilation compilation) => throw new System.NotImplementedException();

        public bool PreconditionVerification(QsCompilation compilation) => throw new System.NotImplementedException();

        public bool Transformation(QsCompilation compilation, [NotNullWhen(true)] out QsCompilation? transformed)
        {
            // we do not change the Q# syntax tree
            transformed = compilation;

            // global callables
            var globalCallables = compilation.Namespaces.GlobalCallableResolutions();

            // collect all callables that have an substitution attribute
            var globals = globalCallables.Where(p => p.Value.Source.CodeFile.EndsWith(".qs"))
                                         .Where(p => p.Value.Attributes.Any(HasSubstitutionAttribute));

            if (!globals.Any())
            {
                diagnostics.Add(new IRewriteStep.Diagnostic
                {
                    Severity = DiagnosticSeverity.Info,
                    Message = "AutoSubstitution: no operations have @SubstitutableOnTarget attribute",
                    Stage = IRewriteStep.Stage.Transformation
                });
                return true;
            }

            // no need to generate any C# file, if there is no substitution attribute, or if we cannot retrieve the output path
            if (!AssemblyConstants.TryGetValue(Microsoft.Quantum.QsCompiler.ReservedKeywords.AssemblyConstants.OutputPath, out var outputPath))
            {
                diagnostics.Add(new IRewriteStep.Diagnostic
                {
                    Severity = DiagnosticSeverity.Error,
                    Message = "AutoSubstitution: cannot determine output path for generated C# code",
                    Stage = IRewriteStep.Stage.Transformation
                });
                return false;
            }

            diagnostics.Add(new IRewriteStep.Diagnostic
            {
                Severity = DiagnosticSeverity.Info,
                Message = $"AutoSubstitution: Generating file __AutoSubstitution__.g.cs in {outputPath}",
                Stage = IRewriteStep.Stage.Transformation
            });

            using var writer = new StreamWriter(Path.Combine(outputPath, "__AutoSubstitution__.g.cs"));
            var context = CodegenContext.Create(compilation, AssemblyConstants);

            var generator = new CodeGenerator(context);
            foreach (var (key, callable) in globals)
            {
                var attributeArguments = callable.Attributes.Where(HasSubstitutionAttribute).Select(GetSubstitutionAttributeArguments);
                foreach (var (alternativeOperation, _) in attributeArguments)
                {
                    var period = alternativeOperation.LastIndexOf('.');
                    if (period == -1)
                    {
                        diagnostics.Add(new IRewriteStep.Diagnostic
                        {
                            Severity = DiagnosticSeverity.Error,
                            Message = $"AutoSubstitution: name of alternative operation in {key.Namespace}.{key.Name} must be completely specified (including namespace)",
                            Stage = IRewriteStep.Stage.Transformation
                        });
                        return false;
                    }

                    var qualifiedName = new QsQualifiedName(alternativeOperation.Substring(0, period), alternativeOperation.Substring(period + 1));
                    if (!globalCallables.TryGetValue(qualifiedName, out var alternativeCallable))
                    {
                        diagnostics.Add(new IRewriteStep.Diagnostic
                        {
                            Severity = DiagnosticSeverity.Error,
                            Message = $"AutoSubstitution: cannot find alternative operation `{alternativeOperation}`",
                            Stage = IRewriteStep.Stage.Transformation
                        });
                        return false;
                    }

                    var callableSignature = callable.Signature;
                    var alternativeSignature = alternativeCallable.Signature;

                    if (!callableSignature.ArgumentType.Equals(alternativeSignature.ArgumentType) || !callableSignature.ReturnType.Equals(alternativeSignature.ReturnType))
                    {
                        diagnostics.Add(new IRewriteStep.Diagnostic
                        {
                            Severity = DiagnosticSeverity.Error,
                            Message = $"AutoSubstitution: signature of `{alternativeOperation}` does not match the one of {key.Namespace}.{key.Name}",
                            Stage = IRewriteStep.Stage.Transformation
                        });
                        return false;
                    }

                    if (!GetSpecializationKinds(callable).IsSubsetOf(GetSpecializationKinds(alternativeCallable)))
                    {
                        diagnostics.Add(new IRewriteStep.Diagnostic
                        {
                            Severity = DiagnosticSeverity.Error,
                            Message = $"AutoSubstitution: specializations of `{alternativeOperation}` must be a superset of specializations of {key.Namespace}.{key.Name}",
                            Stage = IRewriteStep.Stage.Transformation
                        });
                        return false;
                    }
                }
                generator.AddCallable(key, callable, attributeArguments);
            }
            generator.WriteTo(writer);


            return true;
        }

        private static bool HasSubstitutionAttribute(QsDeclarationAttribute attribute) =>
            attribute.TypeId.IsValue && attribute.TypeId.Item.Namespace == "Microsoft.Quantum.Targeting" && attribute.TypeId.Item.Name == "SubstitutableOnTarget";

        private static (string AlternativeOperation, string InSimulator) GetSubstitutionAttributeArguments(QsDeclarationAttribute attribute) =>
            attribute.Argument.Expression switch
            {
                QsExpressionKind<TypedExpression, Identifier, ResolvedType>.ValueTuple tuple =>
                    tuple.Item switch
                    {
                        var arr when arr.Count() == 2 =>
                            (arr.ElementAt(0).Expression, arr.ElementAt(1).Expression) switch
                            {
                                (QsExpressionKind<TypedExpression, Identifier, ResolvedType>.StringLiteral alternativeOperation, QsExpressionKind<TypedExpression, Identifier, ResolvedType>.StringLiteral inSimulator) => (alternativeOperation.Item1, inSimulator.Item1),
                                _ => throw new Exception("Unexpected argument")
                            },
                        _ => throw new Exception("Unexpected argument")
                    },
                _ => throw new Exception("Unexpected argument")
            };

        private static ISet<QsSpecializationKind> GetSpecializationKinds(QsCallable callable) =>
            callable.Specializations.Select(spec => spec.Kind).OrderBy(kind => kind).ToHashSet();

        private List<IRewriteStep.Diagnostic> diagnostics = new List<IRewriteStep.Diagnostic>();
    }
}
