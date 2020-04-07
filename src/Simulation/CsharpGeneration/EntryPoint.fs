module Microsoft.Quantum.QsCompiler.CsharpGeneration.EntryPoint

open Microsoft.CodeAnalysis.CSharp.Syntax
open Microsoft.Quantum.QsCompiler.SyntaxTokens
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.RoslynWrapper


type private ArgumentTuple = QsTuple<LocalVariableDeclaration<QsLocalSymbol>>

/// Returns a sequence of all of the named items in the argument tuple and their respective C# types.
let rec private getArguments context = function
    | QsTupleItem variable ->
        match variable.VariableName with
        | ValidName name -> Seq.singleton (name.Value, SimulationCode.roslynTypeName context variable.Type)
        | InvalidName -> Seq.empty
    | QsTuple items -> items |> Seq.map (getArguments context) |> Seq.concat

/// Returns a property containing a sequence of command-line options corresponding to each named argument in the entry
/// point.
let private getArgumentOptionsProperty context (arguments : ArgumentTuple) =
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
    let options = arguments |> getArguments context |> Seq.map getOption |> Seq.toList
    ``property-arrow_get`` optionsEnumerableTypeName "Options" [``public``; ``static``]
        ``get`` (``=>`` (``new array`` (Some optionTypeName) options))

/// Returns a C# class that can run the entry point using command-line options to provide the entry point's arguments.
let private getEntryPointRunner context entryPoint =
    ``class`` "__QsEntryPointRunner__" ``<<`` [] ``>>``
        ``:`` None ``,`` []
        [``internal``]
        ``{``
            [getArgumentOptionsProperty context entryPoint.ArgumentTuple]
        ``}``

/// Generates the C# source code for a standalone executable that runs the Q# entry point.
let internal generate context (entryPoint : QsCallable) =
    let ns =
        ``namespace`` entryPoint.FullName.Namespace.Value
            ``{``
                []
                [getEntryPointRunner context entryPoint]
            ``}``
        :> MemberDeclarationSyntax

    ``compilation unit``
        []
        (Seq.map ``using`` SimulationCode.autoNamespaces)
        [ns]
    |> SimulationCode.formatSyntaxTree
