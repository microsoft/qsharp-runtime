module internal Microsoft.Quantum.QsCompiler.CsharpGeneration.EntryPoint

open Microsoft.CodeAnalysis.CSharp.Syntax
open Microsoft.Quantum.QsCompiler.SyntaxTokens
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.RoslynWrapper


/// Returns a sequence of all of the named items in the argument tuple and their respective C# types.
let rec private getArguments context = function
    | QsTupleItem variable ->
        match variable.VariableName with
        | ValidName name -> Seq.singleton (name.Value, SimulationCode.roslynTypeName context variable.Type)
        | InvalidName -> Seq.empty
    | QsTuple items -> items |> Seq.map (getArguments context) |> Seq.concat

/// Returns a property containing a sequence of command-line options corresponding to each argument given.
let private getArgumentOptionsProperty args =
    let optionTypeName = "System.CommandLine.Option"
    let optionsEnumerableTypeName = sprintf "System.Collections.Generic.IEnumerable<%s>" optionTypeName
    let getOption (name, typeName) =
        // TODO: Generate diagnostic if argument option name conflicts with a standard option name.
        // TODO: Use kebab-case.
        // TODO: We might need to convert IQArray<T> to a standard array type.
        let optionName = "--" + name
        ``new init`` (``type`` [sprintf "%s<%s>" optionTypeName typeName]) ``(`` [``literal`` optionName] ``)``
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
    Seq.map (fun (name, typeName) -> ``prop`` typeName (getArgumentPropertyName name) [``public``])

/// Returns the method for running the entry point using the argument properties declared in the runner.
let private getRunMethod context (entryPoint : QsCallable) =
    let entryPointName = sprintf "%s.%s" entryPoint.FullName.Namespace.Value entryPoint.FullName.Name.Value
    let argNames = getArguments context entryPoint.ArgumentTuple |> Seq.map fst
    let returnTypeName = SimulationCode.roslynTypeName context entryPoint.Signature.ReturnType
    let taskTypeName = sprintf "System.Threading.Tasks.Task<%s>" returnTypeName
    let factoryArgName = "__factory__"
    let callArgs : seq<ExpressionSyntax> =
        Seq.concat [
            Seq.singleton (upcast ``ident`` factoryArgName)
            argNames |> Seq.map (fun name -> ``ident`` "this" <|.|> ``ident`` (getArgumentPropertyName name))
        ]

    ``arrow_method`` taskTypeName "Run" ``<<`` [] ``>>``
        ``(`` [``param`` factoryArgName ``of`` (``type`` "IOperationFactory")] ``)``
        [``public``; ``async``]
        (Some (``=>`` (``await`` (``ident`` entryPointName <.> (``ident`` "Run", callArgs)))))

/// Returns a C# class that can run the entry point using command-line options to provide the entry point's arguments.
let private getEntryPointRunner context entryPoint =
    let args = getArguments context entryPoint.ArgumentTuple
    let members : seq<MemberDeclarationSyntax> =
        Seq.concat [
            Seq.singleton (upcast getArgumentOptionsProperty args)
            getArgumentProperties args |> Seq.map (fun property -> upcast property)
            Seq.singleton (upcast getRunMethod context entryPoint)
        ]

    ``class`` "__QsEntryPointRunner__" ``<<`` [] ``>>``
        ``:`` None ``,`` []
        [``internal``]
        ``{``
            members
        ``}``

/// Generates the C# source code for a standalone executable that runs the Q# entry point.
let internal generate context (entryPoint : QsCallable) =
    let ns =
        ``namespace`` entryPoint.FullName.Namespace.Value
            ``{``
                []
                [getEntryPointRunner context entryPoint]
            ``}``

    ``compilation unit``
        []
        (Seq.map ``using`` SimulationCode.autoNamespaces)
        [ns]
    |> ``with leading comments`` SimulationCode.autogenComment
    |> SimulationCode.formatSyntaxTree
