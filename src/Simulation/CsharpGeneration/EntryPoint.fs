module internal Microsoft.Quantum.QsCompiler.CsharpGeneration.EntryPoint

open Microsoft.CodeAnalysis.CSharp.Syntax
open Microsoft.Quantum.QsCompiler.SyntaxProcessing.SyntaxExtensions
open Microsoft.Quantum.QsCompiler.SyntaxTokens
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.RoslynWrapper
open System
open System.IO
open System.Reflection


/// Returns a sequence of all of the named items in the argument tuple and their respective C# and Q# types.
let rec private getArguments context = function
    | QsTupleItem variable ->
        match variable.VariableName, variable.Type.Resolution with
        | ValidName name, ArrayType itemType ->
            // Command-line parsing libraries can't convert to IQArray. Use IEnumerable instead.
            let typeName = sprintf "System.Collections.Generic.IEnumerable<%s>"
                                   (SimulationCode.roslynTypeName context itemType)
            Seq.singleton (name.Value, typeName, variable.Type)
        | ValidName name, _ ->
            Seq.singleton (name.Value, SimulationCode.roslynTypeName context variable.Type, variable.Type)
        | InvalidName, _ -> Seq.empty
    | QsTuple items -> items |> Seq.map (getArguments context) |> Seq.concat

/// Returns a property containing a sequence of command-line options corresponding to each argument given.
let private getArgumentOptionsProperty args =
    let optionTypeName = "System.CommandLine.Option"
    let optionsEnumerableTypeName = sprintf "System.Collections.Generic.IEnumerable<%s>" optionTypeName
    let getOption (name, typeName, _) =
        // TODO: Generate diagnostic if argument option name conflicts with a standard option name.
        let toKebabCaseIdent = ``ident`` "System.CommandLine.Parsing.StringExtensions.ToKebabCase"
        let nameExpr = ``literal`` "--" <+> ``invoke`` toKebabCaseIdent ``(`` [``literal`` name] ``)``
        ``new init`` (``type`` [sprintf "%s<%s>" optionTypeName typeName]) ``(`` [nameExpr] ``)``
            ``{``
                [``ident`` "Required" <-- ``true``]
            ``}``
    let options = args |> Seq.map getOption |> Seq.toList

    ``property-arrow_get`` optionsEnumerableTypeName "Options" [``public``; ``static``]
        ``get`` (``=>`` (``new array`` (Some optionTypeName) options))

/// Returns the name of the argument property for the given argument name.
let private getArgumentPropertyName (s : string) =
    s.Substring(0, 1).ToUpper() + s.Substring 1

/// Returns a sequence of properties corresponding to each argument given.
let private getArgumentProperties =
    Seq.map (fun (name, typeName, _) -> ``prop`` typeName (getArgumentPropertyName name) [``public``])

/// Returns the method for running the entry point using the argument properties declared in the adapter.
let private getRunMethod context (entryPoint : QsCallable) =
    let entryPointName = sprintf "%s.%s" entryPoint.FullName.Namespace.Value entryPoint.FullName.Name.Value
    let returnTypeName = SimulationCode.roslynTypeName context entryPoint.Signature.ReturnType
    let taskTypeName = sprintf "System.Threading.Tasks.Task<%s>" returnTypeName
    let factoryArgName = "__factory__"

    let getArgExpr (name, _, qsType : ResolvedType) =
        let property = ``ident`` "this" <|.|> ``ident`` (getArgumentPropertyName name)
        match qsType.Resolution with
        | ArrayType itemType ->
            // Convert the IEnumerable property into a QArray.
            let arrayTypeName = sprintf "QArray<%s>" (SimulationCode.roslynTypeName context itemType)
            ``new`` (``type`` arrayTypeName) ``(`` [property] ``)``
        | _ -> property

    let callArgs : seq<ExpressionSyntax> =
        Seq.concat [
            Seq.singleton (upcast ``ident`` factoryArgName)
            Seq.map getArgExpr (getArguments context entryPoint.ArgumentTuple)
        ]

    ``arrow_method`` taskTypeName "Run" ``<<`` [] ``>>``
        ``(`` [``param`` factoryArgName ``of`` (``type`` "IOperationFactory")] ``)``
        [``public``; ``async``]
        (Some (``=>`` (``await`` (``ident`` entryPointName <.> (``ident`` "Run", callArgs)))))

/// The name of the entry point adapter class.
let private adapterClassName = "__QsEntryPointAdapter__"

/// Returns the class that adapts the entry point for use with the command-line parsing library and the driver.
let private getAdapterClass context (entryPoint : QsCallable) =
    let summary =
        ``property-arrow_get`` "string" "Summary" [``public``; ``static``]
            ``get`` (``=>`` (``literal`` ((PrintSummary entryPoint.Documentation false).Trim ())))
    let args = getArguments context entryPoint.ArgumentTuple
    let members : seq<MemberDeclarationSyntax> =
        Seq.concat [
            Seq.singleton (upcast summary)
            Seq.singleton (upcast getArgumentOptionsProperty args)
            getArgumentProperties args |> Seq.map (fun property -> upcast property)
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
        .Replace("@SimulatorKind", "__QsSimulatorKind__")
        .Replace("@EntryPointDriver", "__QsEntryPointDriver__")
        .Replace("@EntryPointAdapter", adapterClassName)

/// Generates C# source code for a standalone executable that runs the Q# entry point.
let internal generate context entryPoint =
    getAdapter context entryPoint + Environment.NewLine + getDriver entryPoint
