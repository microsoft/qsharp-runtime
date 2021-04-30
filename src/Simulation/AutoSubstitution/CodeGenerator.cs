using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.Editing;
using Microsoft.Quantum.QsCompiler.CsharpGeneration;
using Microsoft.Quantum.QsCompiler.SyntaxTree;

namespace Microsoft.Quantum.QsCompiler.AutoSubstitution
{
    public class CodeGenerator
    {
        public CodeGenerator(CodegenContext context)
        {
            ctx = context;
            gen = Microsoft.CodeAnalysis.Editing.SyntaxGenerator.GetGenerator(new AdhocWorkspace(), LanguageNames.CSharp);
        }

        /// <summary>
        /// Generates an substitution class for a given callable with a given name
        /// </summary>
        ///
        /// <para>
        /// In the following we illustrate the syntax that is generated using
        /// as an example the `Microsoft.Quantum.Canon.ApplyAnd` operation with
        /// `Microsoft.Quantum.Intrinsic.CCNOT` as an alternative when using
        /// `ToffoliSimulator`.
        ///
        /// The generated code looks as follows:
        ///
        /// <code>
        /// namespace Microsoft.Quantum.Canon {
        ///   public partial class ApplyAnd {
        ///     public class Native : ApplyAnd {
        ///       public Native(Microsoft.Quantum.Simulation.Core.IOperationFactory m) : base(m) {
        ///         sim0 = m as ToffoliSimulator;
        ///       }
        ///
        ///       public override void __Init__() {
        ///         base.Init();
        ///         if (sim0 != null) alternative0 = __Factory__.Get&lt;Microsoft.Quantum.Intrinsic.CCNOT&gt;(typeof(Microsoft.Quantum.Intrinsic.CCNOT));
        ///       }
        ///
        ///       public override Func<(Qubit, Qubit, Qubit), QVoid> __Body__ => args => {
        ///         if (sim0 != null) return alternative0.__Body__(args);
        ///         else return base.__Body__(args);
        ///       }
        ///
        ///       // methods for other specializations ...
        ///
        ///       private ToffoliSimulator sim0 = null;
        ///       private Microsoft.Quantum.Intrinsic.CCNOT alternative0 = null;
        ///     }
        ///   }
        /// }
        /// </code>
        /// </para>
        /// 
        /// <param name="name">Namespace and name of the callable</param>
        /// <param name="callable">Q# Callable</param>
        /// <param name="substitutionAttributes">All attribute values from @HasSubstitutionAttribute attributes of that callable</param>
        public void AddCallable(QsQualifiedName name, QsCallable callable, IEnumerable<(string AlternativeOperation, string InSimulator)> substitutionAttributes)
        {
            var attributes = substitutionAttributes.Select((attr, idx) => new SubstitutionAttribute(
                SyntaxFactory.ParseTypeName(attr.AlternativeOperation),
                gen.IdentifierName($"alternative{idx}"),
                SyntaxFactory.ParseTypeName(attr.InSimulator),
                gen.IdentifierName($"sim{idx}")
            ));

            var operationFields = attributes.Select(CreateOperationField);
            var simulatorFields = attributes.Select(CreateSimulatorField);

            var specializationProperties = callable.Specializations.Select(specialization =>
                CreateSpecializationProperty(
                    specializationName: specialization.Kind switch
                    {
                        var kind when kind.IsQsBody => "__Body__",
                        var kind when kind.IsQsAdjoint => "__AdjointBody__",
                        var kind when kind.IsQsControlled => "__ControlledBody__",
                        var kind when kind.IsQsControlledAdjoint => "__ControlledAdjointBody__",
                        _ => throw new Exception("unexpected specialization kind")
                    },
                    attributes: attributes,
                    argumentType: SimulationCode.roslynTypeName(ctx, specialization.Signature.ArgumentType),
                    returnType: SimulationCode.roslynTypeName(ctx, specialization.Signature.ReturnType))
            );

            var innerClass = gen.ClassDeclaration(
                "Native",
                accessibility: Accessibility.Public,
                baseType: gen.IdentifierName(name.Name),
                members: new[] {
                    CreateConstructor(attributes.Select(CreateSimulatorCast)),
                    CreateInitMethod(attributes.Select(CreateOperationAssignment))
                }.Concat(specializationProperties).Concat(operationFields).Concat(simulatorFields));

            var cls = gen.ClassDeclaration(
                name.Name,
                accessibility: callable.Access.IsInternal ? Accessibility.Internal : Accessibility.Public,
                modifiers: DeclarationModifiers.Partial,
                members: new[] { innerClass });

            InsertClassNode(name.Namespace, cls);
        }

        /// <summary>
        /// Creates a syntax node for the constructor of the inner Native class
        /// </summary>
        private SyntaxNode CreateConstructor(IEnumerable<SyntaxNode> bodyStatements) =>
            gen.ConstructorDeclaration(
                        "Native",
                        parameters: new[] { gen.ParameterDeclaration("m", SyntaxFactory.ParseTypeName("Microsoft.Quantum.Simulation.Core.IOperationFactory")) },
                        accessibility: Accessibility.Public,
                        baseConstructorArguments: new[] { gen.IdentifierName("m") },
                        statements: bodyStatements);

        /// <summary>
        /// Creates a syntax node for the Init() method of the inner Native class
        /// </summary>
        private SyntaxNode CreateInitMethod(IEnumerable<SyntaxNode> bodyStatements) =>
            gen.MethodDeclaration(
                "__Init__",
                accessibility: Accessibility.Public,
                modifiers: DeclarationModifiers.Override,
                statements: new[] {
                    gen.ExpressionStatement(
                        gen.InvocationExpression(gen.MemberAccessExpression(gen.BaseExpression(), "__Init__"))
                    )
                }.Concat(bodyStatements));

        /// <summary>
        /// Creates a syntax node for field declarations for the alternative operations
        /// </summary>
        private SyntaxNode CreateOperationField(SubstitutionAttribute attr) =>
            gen.FieldDeclaration(
                attr.OperationName.ToFullString(),
                type: attr.OperationType,
                accessibility: Accessibility.Private,
                initializer: gen.NullLiteralExpression());

        /// <summary>
        /// Creates a syntax node for operation field assignments in the Init() method
        /// </summary>
        private SyntaxNode CreateOperationAssignment(SubstitutionAttribute attr) =>
            gen.IfStatement(
                condition: gen.ValueNotEqualsExpression(attr.SimulatorName, gen.NullLiteralExpression()),
                trueStatements: new[]
                {
                    gen.AssignmentStatement(
                        left: attr.OperationName,
                        right: CreateFactoryGetStatement(attr.OperationType))
                }
            );

        /// <summary>
        /// Creates a syntax node for the __Factory__.Get statement in operation field assignments
        /// </summary>
        private SyntaxNode CreateFactoryGetStatement(SyntaxNode type) =>
            gen.InvocationExpression(
                gen.MemberAccessExpression(
                    gen.IdentifierName("__Factory__"),
                    gen.GenericName("Get", type)),
                gen.TypeOfExpression(type));

        /// <summary>
        /// Creates a syntax node for field declarations for the simulators
        /// </summary>
        /// <param name="attr"></param>
        /// <returns></returns>
        private SyntaxNode CreateSimulatorField(SubstitutionAttribute attr) =>
            gen.FieldDeclaration(
                attr.SimulatorName.ToFullString(),
                type: attr.SimulatorType,
                accessibility: Accessibility.Private,
                initializer: gen.NullLiteralExpression());

        /// <summary>
        /// Creates a syntax node for the simulator field cast assignments in the constructor
        /// </summary>
        /// <param name="attr"></param>
        /// <returns></returns>
        private SyntaxNode CreateSimulatorCast(SubstitutionAttribute attr) =>
            gen.AssignmentStatement(
                left: attr.SimulatorName,
                right: gen.TryCastExpression(gen.IdentifierName("m"), attr.SimulatorType)
            );

        /// <summary>
        /// Creates a syntax node for one specialization property
        /// </summary>
        private SyntaxNode CreateSpecializationProperty(string specializationName, IEnumerable<SubstitutionAttribute> attributes, string argumentType, string returnType) =>
            gen.PropertyDeclaration(
                specializationName,
                type: SyntaxFactory.ParseTypeName($"Func<{argumentType}, {returnType}>"),
                accessibility: Accessibility.Public,
                modifiers: DeclarationModifiers.Override | DeclarationModifiers.ReadOnly,
                getAccessorStatements: new[] { gen.ReturnStatement(CreateSpecializationLambda(specializationName, attributes)) });

        /// <summary>
        /// Creates a syntax node for the lambda expression, returned in the
        /// `get` accessor of a specialization property
        /// </summary>
        private SyntaxNode CreateSpecializationLambda(string specializationName, IEnumerable<SubstitutionAttribute> attrs) =>
            gen.ValueReturningLambdaExpression(
                "args",
                new[]
                {
                    CreateSpecializationBody(specializationName, attrs)
                });

        /// <summary>
        /// Creates a syntax node for a nested if-statement for all possible
        /// operation alternatives
        /// </summary>
        private SyntaxNode CreateSpecializationBody(string specializationName, IEnumerable<SubstitutionAttribute> attrs) =>
            attrs.Count() switch
            {
                0 => gen.ReturnStatement(
                         gen.InvocationExpression(
                             gen.MemberAccessExpression(gen.BaseExpression(), specializationName),
                             gen.IdentifierName("args"))),
                _ => gen.IfStatement(
                         condition: gen.ValueNotEqualsExpression(attrs.First().SimulatorName, gen.NullLiteralExpression()),
                         trueStatements: new[] {
                             gen.ReturnStatement(
                                 gen.InvocationExpression(
                                     gen.MemberAccessExpression(attrs.First().OperationName, specializationName),
                                     gen.IdentifierName("args"))) },
                         falseStatement: CreateSpecializationBody(specializationName, attrs.Skip(1)))
            };

        /// <summary>
        /// Inserts a syntax node for a class declaration into a list for its
        /// corresponding namespace
        /// </summary>
        /// <param name="namespace">Namespace name</param>
        /// <param name="classNode">Syntax node for class declaration</param>
        private void InsertClassNode(string @namespace, SyntaxNode classNode)
        {
            if (!classNodes.ContainsKey(@namespace))
            {
                classNodes.Add(@namespace, new List<SyntaxNode>());
            }

            classNodes[@namespace].Add(classNode);
        }

        /// <summary>
        /// Group class declarations of the same namespace into a namespace node
        /// </summary>
        private IEnumerable<SyntaxNode> GetNamespaceNodes() =>
            classNodes.Select(pair => gen.NamespaceDeclaration(pair.Key, pair.Value));

        /// <summary>
        /// Write namespaces into a text writer
        /// </summary>
        /// <param name="writer">Text writer, e.g., `Console.Out`</param>
        public void WriteTo(TextWriter writer) =>
            gen.CompilationUnit(
                new[] { "System", "Microsoft.Quantum.Simulation.Core", "Microsoft.Quantum.Simulation.Simulators" }.Select(gen.NamespaceImportDeclaration)
                .Concat(GetNamespaceNodes())
            ).NormalizeWhitespace().WriteTo(writer);

        /// <summary>
        /// Helper struct to prepare syntax nodes for @SubstitutableOnTarget attribute values
        /// </summary>
        private class SubstitutionAttribute
        {
            public SubstitutionAttribute(SyntaxNode operationType, SyntaxNode operationName, SyntaxNode simulatorType, SyntaxNode simulatorName)
            {
                OperationType = operationType;
                OperationName = operationName;
                SimulatorType = simulatorType;
                SimulatorName = simulatorName;
            }

            public SyntaxNode OperationType { get; private set; }
            public SyntaxNode OperationName { get; private set; }
            public SyntaxNode SimulatorType { get; private set; }
            public SyntaxNode SimulatorName { get; private set; }
        }

        private readonly CodegenContext ctx;
        private readonly Microsoft.CodeAnalysis.Editing.SyntaxGenerator gen;

        /// <summary>
        /// Contains class nodes by namespace names
        /// </summary>
        private readonly Dictionary<string, List<SyntaxNode>> classNodes = new Dictionary<string, List<SyntaxNode>>();
    }
}
