module Microsoft.Quantum.QsCompiler.CsharpGeneration.EntryPoint

open Microsoft.CodeAnalysis.CSharp.Syntax
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.RoslynWrapper


/// The name of the entry point runner class.
let private entryPointRunnerClassName = "__QsEntryPointRunner__"

/// Returns a C# class that can run the entry point using command-line options to provide the entry point's arguments.
let private getEntryPointRunner =
    ``class`` entryPointRunnerClassName ``<<`` [] ``>>``
        ``:`` None ``,`` []
        [``internal``]
        ``{``
            // TODO
            []
        ``}``

/// Generates the C# source code for a standalone executable that runs the Q# entry point.
let internal generate (entryPoint : QsQualifiedName) =
    let ns =
        ``#line hidden`` <|
        ``namespace`` entryPoint.Namespace.Value
            ``{``
                []
                [getEntryPointRunner]
            ``}``
        :> MemberDeclarationSyntax

    ``compilation unit`` [] [] [ns]
    |> SimulationCode.formatSyntaxTree
