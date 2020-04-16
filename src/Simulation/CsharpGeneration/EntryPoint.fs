module internal Microsoft.Quantum.QsCompiler.CsharpGeneration.EntryPoint

open Microsoft.CodeAnalysis.CSharp.Syntax
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

/// The name of the entry point adapter class.
let private adapterClassName = "__QsEntryPointAdapter__"

/// The name of the entry point driver class.
let private driverClassName = "__QsEntryPointDriver__"

/// The name of the result struct.
let private resultStructName = "__QsResult__"

/// The name of the class containing extension methods for the result struct.
let private resultExtensionsClassName = "__QsResultExtensions__"

/// Returns a sequence of all of the named parameters in the argument tuple and their respective C# and Q# types.
let rec private getParameters context doc = function
    | QsTupleItem variable ->
        match variable.VariableName, variable.Type.Resolution with
        | ValidName name, ArrayType itemType ->
            // Command-line parsing libraries can't convert to IQArray. Use IEnumerable instead.
            let typeName = sprintf "System.Collections.Generic.IEnumerable<%s>"
                                   (SimulationCode.roslynTypeName context itemType)
            Seq.singleton { Name = name.Value
                            QsharpType = variable.Type
                            CsharpTypeName = typeName
                            Description = ParameterDescription doc name.Value }
        | ValidName name, _ ->
            Seq.singleton { Name = name.Value
                            QsharpType = variable.Type
                            CsharpTypeName = SimulationCode.roslynTypeName context variable.Type
                            Description = ParameterDescription doc name.Value }
        | InvalidName, _ -> Seq.empty
    | QsTuple items -> items |> Seq.map (getParameters context doc) |> Seq.concat

/// Returns the custom argument handler for the given Q# type.
let private getArgumentHandler =
    function
    | UnitType -> Some "UnitArgumentHandler"
    | Result -> Some "ResultArgumentHandler"
    | BigInt -> Some "BigIntArgumentHandler"
    | Range -> Some "RangeArgumentHandler"
    | _ -> None
    >> Option.map (fun handler -> ``ident`` driverClassName <|.|> ``ident`` handler)

/// Returns a property containing a sequence of command-line options corresponding to each parameter given.
let private getParameterOptionsProperty parameters =
    let optionTypeName = "System.CommandLine.Option"
    let optionsEnumerableTypeName = sprintf "System.Collections.Generic.IEnumerable<%s>" optionTypeName
    let toKebabCaseIdent = ``ident`` "System.CommandLine.Parsing.StringExtensions.ToKebabCase"
    let getOption { Name = name; QsharpType = qsType; CsharpTypeName = typeName; Description = desc } =
        let nameExpr =
            if name.Length = 1
            then ``literal`` ("-" + name)
            else ``literal`` "--" <+> ``invoke`` toKebabCaseIdent ``(`` [``literal`` name] ``)``
        let members =
            getArgumentHandler qsType.Resolution
            |> Option.map (fun handler -> ``ident`` "Argument" <-- handler :> ExpressionSyntax)
            |> Option.toList
            |> List.append [``ident`` "Required" <-- ``true``]

        ``new init`` (``type`` [sprintf "%s<%s>" optionTypeName typeName]) ``(`` [nameExpr; ``literal`` desc] ``)``
            ``{``
                members
            ``}``

    let options = parameters |> Seq.map getOption |> Seq.toList
    ``property-arrow_get`` optionsEnumerableTypeName "Options" [``public``; ``static``]
        ``get`` (``=>`` (``new array`` (Some optionTypeName) options))

/// Returns the name of the parameter property for the given parameter name.
let private getParameterPropertyName (s : string) =
    s.Substring(0, 1).ToUpper() + s.Substring 1

/// Returns a sequence of properties corresponding to each parameter given.
let private getParameterProperties =
    Seq.map (fun { Name = name; CsharpTypeName = typeName } ->
        ``prop`` typeName (getParameterPropertyName name) [``public``])

/// Returns the method for running the entry point using the parameter properties declared in the adapter.
let private getRunMethod context (entryPoint : QsCallable) =
    let entryPointName = sprintf "%s.%s" entryPoint.FullName.Namespace.Value entryPoint.FullName.Name.Value
    let returnTypeName = SimulationCode.roslynTypeName context entryPoint.Signature.ReturnType
    let taskTypeName = sprintf "System.Threading.Tasks.Task<%s>" returnTypeName
    let factoryParamName = "__factory__"

    let getArgExpr { Name = name; QsharpType = qsType } =
        let property = ``ident`` "this" <|.|> ``ident`` (getParameterPropertyName name)
        match qsType.Resolution with
        | ArrayType itemType ->
            // Convert the IEnumerable property into a QArray.
            let arrayTypeName = sprintf "QArray<%s>" (SimulationCode.roslynTypeName context itemType)
            ``new`` (``type`` arrayTypeName) ``(`` [property] ``)``
        | _ -> property

    let callArgs : seq<ExpressionSyntax> =
        Seq.concat [
            Seq.singleton (upcast ``ident`` factoryParamName)
            Seq.map getArgExpr (getParameters context entryPoint.Documentation entryPoint.ArgumentTuple)
        ]

    ``arrow_method`` taskTypeName "Run" ``<<`` [] ``>>``
        ``(`` [``param`` factoryParamName ``of`` (``type`` "IOperationFactory")] ``)``
        [``public``; ``async``]
        (Some (``=>`` (``await`` (``ident`` entryPointName <.> (``ident`` "Run", callArgs)))))

/// Returns the class that adapts the entry point for use with the command-line parsing library and the driver.
let private getAdapterClass context (entryPoint : QsCallable) =
    let constant name typeName value =
        ``property-arrow_get`` typeName name [``public``; ``static``]
            ``get`` (``=>`` (``literal`` value))
    let summary = constant "Summary" "string" ((PrintSummary entryPoint.Documentation false).Trim ())
    let defaultSimulator =
        context.assemblyConstants.TryGetValue "DefaultSimulator"
        |> snd
        |> (fun value -> if String.IsNullOrWhiteSpace value then "QuantumSimulator" else value)
        |> constant "DefaultSimulator" "string"
    let parameters = getParameters context entryPoint.Documentation entryPoint.ArgumentTuple
    let members : seq<MemberDeclarationSyntax> =
        Seq.concat [
            Seq.ofList [
                summary
                defaultSimulator
                getParameterOptionsProperty parameters
            ]
            getParameterProperties parameters |> Seq.map (fun property -> upcast property)
            Seq.singleton (upcast getRunMethod context entryPoint)
        ]

    ``class`` adapterClassName ``<<`` [] ``>>``
        ``:`` None ``,`` []
        [``internal``]
        ``{``
            members
        ``}``

/// Returns the source code for the entry point adapter.
let private getAdapter context (entryPoint : QsCallable) =
    let ns =
        ``namespace`` entryPoint.FullName.Namespace.Value
            ``{``
                (Seq.map ``using`` SimulationCode.autoNamespaces)
                [getAdapterClass context entryPoint]
            ``}``

    ``compilation unit`` [] [] [ns]
    |> ``with leading comments`` SimulationCode.autogenComment
    |> SimulationCode.formatSyntaxTree

/// Returns the source code for the entry point driver.
let private getDriver (entryPoint : QsCallable) =
    let name = "Microsoft.Quantum.CsharpGeneration.Resources.EntryPointDriver.cs"
    use stream = Assembly.GetExecutingAssembly().GetManifestResourceStream name
    use reader = new StreamReader(stream)
    reader.ReadToEnd()
        .Replace("@Namespace", entryPoint.FullName.Namespace.Value)
        .Replace("@EntryPointDriver", "__QsEntryPointDriver__")
        .Replace("@EntryPointAdapter", adapterClassName)
        .Replace("@ResultExtensions", resultExtensionsClassName)
        .Replace("@Result", resultStructName)

/// Generates C# source code for a standalone executable that runs the Q# entry point.
let internal generate context entryPoint =
    getAdapter context entryPoint + Environment.NewLine + getDriver entryPoint
