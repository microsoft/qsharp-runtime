// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

module Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint

open System
open System.Collections.Immutable
open System.IO
open System.Reflection
open System.Threading.Tasks
open Microsoft.CodeAnalysis
open Microsoft.CodeAnalysis.CSharp
open Microsoft.Quantum.QsCompiler.CompilationBuilder
open Microsoft.Quantum.QsCompiler.CsharpGeneration
open Microsoft.Quantum.QsCompiler.DataTypes
open Xunit


/// The path to the Q# file that provides the Microsoft.Quantum.Core namespace.
let private coreFile = Path.Combine ("Circuits", "Core.qs") |> Path.GetFullPath

/// The path to the Q# file that contains the test cases.
let private testFile = Path.Combine ("Circuits", "EntryPointTests.qs") |> Path.GetFullPath

/// The namespace used for the test cases.
let private testNamespace = "Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint"

/// The test cases.
let private tests = File.ReadAllText testFile |> fun text -> text.Split "// ---"

/// Compiles Q# source code into a syntax tree with the list of entry points names.
let private compileQsharp source =
    let uri name = Uri ("file://" + name)
    let fileManager name content =
        CompilationUnitManager.InitializeFileManager (uri name, content)

    use compilationManager = new CompilationUnitManager (isExecutable = true)
    let fileManagers = ImmutableHashSet.Create (fileManager coreFile (File.ReadAllText coreFile),
                                                fileManager testFile source)
    compilationManager.AddOrUpdateSourceFilesAsync fileManagers |> ignore
    let compilation = compilationManager.Build ()
    Assert.Empty (compilation.Diagnostics ())
    compilation.BuiltCompilation.Namespaces, compilation.BuiltCompilation.EntryPoints

/// Generates C# source code for the given test case number.
let private generateCsharp testNum =
    let syntaxTree, entryPoints = compileQsharp tests.[testNum - 1]
    let context = CodegenContext.Create syntaxTree
    let entryPoint = context.allCallables.[Seq.exactlyOne entryPoints]
    [
        SimulationCode.generate (NonNullable<_>.New testFile) context
        EntryPoint.generate context entryPoint
    ]

/// The full path to a referenced assembly given its short name.
let private referencedAssembly name =
    (AppContext.GetData "TRUSTED_PLATFORM_ASSEMBLIES" :?> string).Split ';'
    |> Seq.find (fun path -> String.Equals (Path.GetFileNameWithoutExtension path, name,
                                            StringComparison.InvariantCultureIgnoreCase))

/// Compiles the C# sources into an assembly.
let private compileCsharp (sources : string seq) =
    let references : MetadataReference list =
        [
            "netstandard"
            "System.Collections.Immutable"
            "System.CommandLine"
            "System.Console"
            "System.Linq"
            "System.Private.CoreLib"
            "System.Runtime"
            "System.Runtime.Extensions"
            "System.Runtime.Numerics"
            "Microsoft.Quantum.QSharp.Core"
            "Microsoft.Quantum.Runtime.Core"
            "Microsoft.Quantum.Simulation.Common"
            "Microsoft.Quantum.Simulation.Simulators"
        ]
        |> List.map (fun name -> upcast MetadataReference.CreateFromFile (referencedAssembly name))

    let syntaxTrees = sources |> Seq.map CSharpSyntaxTree.ParseText
    let compilation = CSharpCompilation.Create ("GeneratedEntryPoint", syntaxTrees, references)
    use stream = new MemoryStream ()
    let result = compilation.Emit stream
    Assert.True (result.Success, String.Join ("\n", result.Diagnostics))
    Assert.Equal (0L, stream.Seek (0L, SeekOrigin.Begin))
    Assembly.Load (stream.ToArray ())

/// The assembly for the given test case.
let private testAssembly = generateCsharp >> compileCsharp

/// Runs the entry point driver in the assembly with the given command-line arguments, and returns the output.
let private run (assembly : Assembly) (args : string[]) =
    let driver = assembly.GetType (EntryPoint.generatedNamespace testNamespace + ".Driver")
    let main = driver.GetMethod("Main", BindingFlags.NonPublic ||| BindingFlags.Static)

    let previousOut = Console.Out
    use stream = new StringWriter ()
    Console.SetOut stream
    let exitCode = main.Invoke (null, [| args |]) :?> Task<int> |> Async.AwaitTask |> Async.RunSynchronously
    Console.SetOut previousOut
    stream.ToString (), exitCode

/// Asserts that running the entry point in the assembly with the given arguments succeeds and yields the expected
/// output.
let private yields expected (assembly, args) =
    let output, exitCode = run assembly args
    Assert.Equal (0, exitCode)
    Assert.Equal (expected, output.TrimEnd ())

/// Asserts that running the entry point in the assembly with the given argument fails.
let private fails (assembly, args) =
    let _, exitCode = run assembly args
    Assert.NotEqual (0, exitCode)

[<Fact>]
let ``Entry point returns Unit`` () =
    (testAssembly 1, Array.empty) |> yields ""
    
[<Fact>]
let ``Entry point returns Int`` () =
    (testAssembly 2, Array.empty) |> yields "42"

[<Fact>]
let ``Entry point returns String`` () =
    (testAssembly 3, Array.empty) |> yields "Hello, World!"
