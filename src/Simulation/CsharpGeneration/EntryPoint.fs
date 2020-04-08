module Microsoft.Quantum.QsCompiler.CsharpGeneration.EntryPoint

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
let private getArgumentOptionsProperty arguments =
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
    let options = arguments |> Seq.map getOption |> Seq.toList
    ``property-arrow_get`` optionsEnumerableTypeName "Options" [``public``; ``static``]
        ``get`` (``=>`` (``new array`` (Some optionTypeName) options))

/// Returns a sequence of properties corresponding to each argument given.
let private getArgumentProperties =
    let capitalize (s : string) = s.Substring(0, 1).ToUpper() + s.Substring 1
    Seq.map (fun (name, typeName) -> ``prop`` typeName (capitalize name) [``public``])

/// Returns a C# class that can run the entry point using command-line options to provide the entry point's arguments.
let private getEntryPointRunner context entryPoint =
    let arguments = getArguments context entryPoint.ArgumentTuple
    let members : seq<MemberDeclarationSyntax> =
        Seq.concat [
            Seq.singleton (upcast getArgumentOptionsProperty arguments)
            getArgumentProperties arguments |> Seq.map (fun property -> upcast property)
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
