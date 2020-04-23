module internal Microsoft.Quantum.QsCompiler.CsharpGeneration.EntryPoint

open Microsoft.CodeAnalysis.CSharp
open Microsoft.CodeAnalysis.CSharp.Syntax
open Microsoft.Quantum.QsCompiler.ReservedKeywords
open Microsoft.Quantum.QsCompiler.SyntaxProcessing.SyntaxExtensions
open Microsoft.Quantum.QsCompiler.SyntaxTokens
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.RoslynWrapper
open System
open System.IO
open System.Reflection


/// An entry point parameter.
type private Parameter =
    { Name : string
      QsharpType : ResolvedType
      CsharpTypeName : string
      Description : string }

/// The namespace in which to put generated code for the entry point.
let internal generatedNamespace entryPointNamespace = entryPointNamespace + ".__QsEntryPoint__"

/// A public constant field.
let private constant name typeName value =
    ``field`` typeName name [``public``; ``const``] (``:=`` value |> Some)

/// A public static property with a getter.
let private readonlyProperty name typeName value =
    ``property-arrow_get`` typeName name [``public``; ``static``]
        ``get`` (``=>`` value)

/// A static class containing constants used by the entry point driver.
let private constantsClass =
    ``class`` "Constants" ``<<`` [] ``>>``
        ``:`` None ``,`` []
        [``internal``; ``static``]
        ``{``
            [readonlyProperty "SimulatorOptions" "System.Collections.Generic.IEnumerable<string>"
                (``new array`` (Some "") [``literal`` ("--" + fst CommandLineArguments.SimulatorOption)
                                          ``literal`` ("-" + snd CommandLineArguments.SimulatorOption)])
             constant "QuantumSimulator" "string" (``literal`` AssemblyConstants.QuantumSimulator)
             constant "ToffoliSimulator" "string" (``literal`` AssemblyConstants.ToffoliSimulator)
             constant "ResourcesEstimator" "string" (``literal`` AssemblyConstants.ResourcesEstimator)]
        ``}``

/// The name of the C# type used by the parameter in its command-line option, given its Q# type.
let rec private csharpParameterTypeName context (qsType : ResolvedType) =
    match qsType.Resolution with
    | ArrayType itemType -> sprintf "System.Collections.Generic.IEnumerable<%s>"
                                    (csharpParameterTypeName context itemType)
    | _ -> SimulationCode.roslynTypeName context qsType

/// A sequence of all of the named parameters in the argument tuple and their respective C# and Q# types.
let rec private parameters context doc = function
    | QsTupleItem variable ->
        match variable.VariableName with
        | ValidName name ->
            Seq.singleton { Name = name.Value
                            QsharpType = variable.Type
                            CsharpTypeName = csharpParameterTypeName context variable.Type
                            Description = ParameterDescription doc name.Value }
        | InvalidName -> Seq.empty
    | QsTuple items -> items |> Seq.map (parameters context doc) |> Seq.concat

/// The argument parser for the Q# type.
let private argumentParser qsType =
    let rec valueParser = function
        | ArrayType (itemType : ResolvedType) -> valueParser itemType.Resolution
        | BigInt -> Some "TryParseBigInteger"
        | Range -> Some "TryParseQRange"
        | Result -> Some "TryParseResult"
        | UnitType -> Some "TryParseQVoid"
        | _ -> None
    let argParser =
        match qsType with
        | ArrayType _ -> "ParseArgumentsWith"
        | _ -> "ParseArgumentWith"
    valueParser qsType |> Option.map (fun valueParser ->
        ``ident`` "Parsers" <.> (``ident`` argParser, [``ident`` "Parsers" <|.|> ``ident`` valueParser]))

/// Adds suggestions, if any, to the option based on the Q# type.
let private withSuggestions qsType option =
    let rec suggestions = function
        | ArrayType (itemType : ResolvedType) -> suggestions itemType.Resolution
        | Result -> ["Zero"; "One"]
        | _ -> []
    match suggestions qsType with
    | [] -> option
    | suggestions ->
        let args = option :: List.map ``literal`` suggestions
        ``invoke`` (``ident`` "System.CommandLine.OptionExtensions.WithSuggestions") ``(`` args ``)``

/// A property containing a sequence of command-line options corresponding to each parameter given.
let private parameterOptionsProperty parameters =
    let optionTypeName = "System.CommandLine.Option"
    let optionsEnumerableTypeName = sprintf "System.Collections.Generic.IEnumerable<%s>" optionTypeName
    let toKebabCaseIdent = ``ident`` "System.CommandLine.Parsing.StringExtensions.ToKebabCase"
    let getOption { Name = name; QsharpType = qsType; CsharpTypeName = typeName; Description = desc } =
        let nameExpr =
            if name.Length = 1
            then ``literal`` ("-" + name)
            else ``literal`` "--" <+> ``invoke`` toKebabCaseIdent ``(`` [``literal`` name] ``)``
        let args =
            match argumentParser qsType.Resolution with
            | Some parser -> [nameExpr; parser; upcast ``false``; ``literal`` desc]
            | None -> [nameExpr; ``literal`` desc]

        ``new init`` (``type`` [sprintf "%s<%s>" optionTypeName typeName]) ``(`` args ``)``
            ``{``
                [``ident`` "Required" <-- ``true``]
            ``}``
        |> withSuggestions qsType.Resolution

    let options = parameters |> Seq.map getOption |> Seq.toList
    ``property-arrow_get`` optionsEnumerableTypeName "Options" [``public``; ``static``]
        ``get`` (``=>`` (``new array`` (Some optionTypeName) options))

/// The name of the parameter property for the given parameter name.
let private parameterPropertyName (s : string) = s.Substring(0, 1).ToUpper() + s.Substring 1

/// A sequence of properties corresponding to each parameter given.
let private parameterProperties =
    Seq.map (fun { Name = name; CsharpTypeName = typeName } ->
        ``prop`` typeName (parameterPropertyName name) [``public``])

/// The method for running the entry point using the parameter properties declared in the adapter.
let private runMethod context (entryPoint : QsCallable) =
    let entryPointName = sprintf "%s.%s" entryPoint.FullName.Namespace.Value entryPoint.FullName.Name.Value
    let returnTypeName = SimulationCode.roslynTypeName context entryPoint.Signature.ReturnType
    let taskTypeName = sprintf "System.Threading.Tasks.Task<%s>" returnTypeName
    let factoryParamName = "__factory__"

    let argExpr { Name = name; QsharpType = qsType } =
        let property = ``ident`` "this" <|.|> ``ident`` (parameterPropertyName name)
        match qsType.Resolution with
        | ArrayType itemType ->
            let arrayTypeName = sprintf "QArray<%s>" (SimulationCode.roslynTypeName context itemType)
            ``new`` (``type`` arrayTypeName) ``(`` [property] ``)``
        | _ -> property

    let callArgs : seq<ExpressionSyntax> =
        Seq.concat [
            Seq.singleton (upcast ``ident`` factoryParamName)
            Seq.map argExpr (parameters context entryPoint.Documentation entryPoint.ArgumentTuple)
        ]

    ``arrow_method`` taskTypeName "Run" ``<<`` [] ``>>``
        ``(`` [``param`` factoryParamName ``of`` (``type`` "IOperationFactory")] ``)``
        [``public``; ``async``]
        (Some (``=>`` (``await`` (``ident`` entryPointName <.> (``ident`` "Run", callArgs)))))

/// A method that creates an instance of the default simulator if it is a custom simulator.
let private customSimulatorFactory name =
    let expr : ExpressionSyntax =
        match name with
        | "QuantumSimulator" | "ToffoliSimulator" | "ResourcesEstimator" ->
            upcast SyntaxFactory.ThrowExpression (``new`` (``type`` "InvalidOperationException") ``(`` [] ``)``)
        | _ -> ``new`` (``type`` name) ``(`` [] ``)``
    ``arrow_method`` "IOperationFactory" "CreateDefaultCustomSimulator" ``<<`` [] ``>>``
        ``(`` [] ``)``
        [``public``; ``static``]
        (Some (``=>`` expr))

/// The class that adapts the entry point for use with the command-line parsing library and the driver.
let private adapterClass context (entryPoint : QsCallable) =
    let summaryProperty =
        readonlyProperty "Summary" "string" (``literal`` ((PrintSummary entryPoint.Documentation false).Trim ()))
    let defaultSimulator =
        context.assemblyConstants.TryGetValue "DefaultSimulator"
        |> snd
        |> (fun value -> if String.IsNullOrWhiteSpace value then "QuantumSimulator" else value)
    let defaultSimulatorProperty = readonlyProperty "DefaultSimulator" "string" (``literal`` defaultSimulator)
    let parameters = parameters context entryPoint.Documentation entryPoint.ArgumentTuple

    let members : seq<MemberDeclarationSyntax> =
        Seq.concat [
            Seq.ofList [
                summaryProperty
                defaultSimulatorProperty
                parameterOptionsProperty parameters
                customSimulatorFactory defaultSimulator
                runMethod context entryPoint
            ]
            parameterProperties parameters |> Seq.map (fun property -> upcast property)
        ]

    ``class`` "EntryPoint" ``<<`` [] ``>>``
        ``:`` None ``,`` []
        [``internal``]
        ``{``
            members
        ``}``

/// The source code for the entry point constants and adapter classes.
let private generatedClasses context (entryPoint : QsCallable) =
    let ns =
        ``namespace`` (generatedNamespace entryPoint.FullName.Namespace.Value)
            ``{``
                (Seq.map ``using`` SimulationCode.autoNamespaces)
                [
                    constantsClass
                    adapterClass context entryPoint
                ]
            ``}``
    ``compilation unit`` [] [] [ns]
    |> ``with leading comments`` SimulationCode.autogenComment
    |> SimulationCode.formatSyntaxTree
    |> fun code -> code + Environment.NewLine

/// The source code for the entry point driver.
let private driver (entryPoint : QsCallable) =
    let source fileName =
        let resourceName = "Microsoft.Quantum.CsharpGeneration.Resources.EntryPoint." + fileName
        use stream = Assembly.GetExecutingAssembly().GetManifestResourceStream resourceName
        use reader = new StreamReader(stream)
        reader.ReadToEnd().Replace("@Namespace", generatedNamespace entryPoint.FullName.Namespace.Value)
    String.Join (Environment.NewLine, source "Driver.cs", source "Parsers.cs", source "Validation.cs")

/// Generates C# source code for a standalone executable that runs the Q# entry point.
let internal generate context entryPoint =
    generatedClasses context entryPoint + driver entryPoint
