// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

module Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint

open System
open System.Collections.Immutable
open System.Globalization
open System.IO
open System.Reflection
open System.Threading.Tasks
open Microsoft.CodeAnalysis
open Microsoft.CodeAnalysis.CSharp
open Microsoft.Quantum.QsCompiler.CompilationBuilder
open Microsoft.Quantum.QsCompiler.CsharpGeneration
open Microsoft.Quantum.QsCompiler.DataTypes
open Microsoft.VisualStudio.LanguageServer.Protocol
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
    let errors =
        compilation.Diagnostics ()
        |> Seq.filter (fun diagnostic -> diagnostic.Severity = DiagnosticSeverity.Error)
    Assert.Empty errors
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
    let previousCulture = CultureInfo.DefaultThreadCurrentCulture
    let previousOut = Console.Out

    CultureInfo.DefaultThreadCurrentCulture <- CultureInfo ("en-US", false)
    use stream = new StringWriter ()
    Console.SetOut stream
    let exitCode = main.Invoke (null, [| args |]) :?> Task<int> |> Async.AwaitTask |> Async.RunSynchronously
    Console.SetOut previousOut
    CultureInfo.DefaultThreadCurrentCulture <- previousCulture

    stream.ToString (), exitCode

/// Asserts that running the entry point in the assembly with the given arguments succeeds and yields the expected
/// output.
let private yields expected (assembly, args) =
    let output, exitCode = run assembly args
    Assert.Equal (0, exitCode)
    Assert.Equal (expected, output.TrimEnd ())

/// Asserts that running the entry point in the assembly with the given argument fails.
let private fails (assembly, args) =
    let output, exitCode = run assembly args
    Assert.True (0 <> exitCode, "Succeeded unexpectedly:\n" + output)


// No Option

[<Fact>]
let ``Returns Unit`` () =
    (testAssembly 1, Array.empty) |> yields ""
    
[<Fact>]
let ``Returns Int`` () =
    (testAssembly 2, Array.empty) |> yields "42"

[<Fact>]
let ``Returns String`` () =
    (testAssembly 3, Array.empty) |> yields "Hello, World!"


// Single Option

[<Fact>]
let ``Accepts Int`` () =
    let assembly = testAssembly 4
    (assembly, [| "-n"; "42" |]) |> yields "42"
    (assembly, [| "-n"; "4.2" |]) |> fails
    (assembly, [| "-n"; "9223372036854775808" |]) |> fails

[<Fact>]
let ``Accepts BigInt`` () =
    let assembly = testAssembly 5
    (assembly, [| "-n"; "9223372036854775808" |]) |> yields "9223372036854775808"
    (assembly, [| "-n"; "foo" |]) |> fails

[<Fact>]
let ``Accepts Double`` () =
    (testAssembly 6, [| "-n"; "4.2" |]) |> yields "4.2"
    (testAssembly 6, [| "-n"; "foo" |]) |> fails

[<Fact>]
let ``Accepts Bool`` () =
    let assembly = testAssembly 7
    (assembly, [| "-b" |]) |> yields "True"
    (assembly, [| "-b"; "false" |]) |> yields "False"
    (assembly, [| "-b"; "true" |]) |> yields "True"
    (assembly, [| "-b"; "one" |]) |> fails

[<Fact>]
let ``Accepts Pauli`` () =
    let assembly = testAssembly 8
    (assembly, [| "-p"; "PauliI" |]) |> yields "PauliI"
    (assembly, [| "-p"; "PauliX" |]) |> yields "PauliX"
    (assembly, [| "-p"; "PauliY" |]) |> yields "PauliY"
    (assembly, [| "-p"; "PauliZ" |]) |> yields "PauliZ"
    (assembly, [| "-p"; "PauliW" |]) |> fails

[<Fact>]
let ``Accepts Result`` () =
    let assembly = testAssembly 9
    (assembly, [| "-r"; "Zero" |]) |> yields "Zero"
    (assembly, [| "-r"; "zero" |]) |> yields "Zero"
    (assembly, [| "-r"; "One" |]) |> yields "One"
    (assembly, [| "-r"; "one" |]) |> yields "One"
    (assembly, [| "-r"; "0" |]) |> yields "Zero"
    (assembly, [| "-r"; "1" |]) |> yields "One"
    (assembly, [| "-r"; "Two" |]) |> fails

[<Fact>]
let ``Accepts Range`` () =
    let assembly = testAssembly 10
    (assembly, [| "-r"; "0..0" |]) |> yields "0..1..0"
    (assembly, [| "-r"; "0..1" |]) |> yields "0..1..1"
    (assembly, [| "-r"; "0..2..10" |]) |> yields "0..2..10"
    (assembly, [| "-r"; "0"; "..1" |]) |> yields "0..1..1"
    (assembly, [| "-r"; "0.."; "1" |]) |> yields "0..1..1"
    (assembly, [| "-r"; "0"; ".."; "1" |]) |> yields "0..1..1"
    (assembly, [| "-r"; "0"; "..2"; "..10" |]) |> yields "0..2..10"
    (assembly, [| "-r"; "0.."; "2"; "..10" |]) |> yields "0..2..10"
    (assembly, [| "-r"; "0"; ".."; "2"; ".."; "10" |]) |> yields "0..2..10"
    (assembly, [| "-r"; "0"; "1" |]) |> yields "0..1..1"
    (assembly, [| "-r"; "0"; "2"; "10" |]) |> yields "0..2..10"
    (assembly, [| "-r"; "0" |]) |> fails
    (assembly, [| "-r"; "0.." |]) |> fails
    (assembly, [| "-r"; "0..2.." |]) |> fails
    (assembly, [| "-r"; "0..2..3.." |]) |> fails
    (assembly, [| "-r"; "0..2..3..4" |]) |> fails
    (assembly, [| "-r"; "0"; "1"; "2"; "3" |]) |> fails

[<Fact>]
let ``Accepts String`` () =
    (testAssembly 11, [| "-s"; "Hello, World!" |]) |> yields "Hello, World!"

[<Fact>]
let ``Accepts String array`` () =
    let assembly = testAssembly 12
    (assembly, [| "--xs"; "foo" |]) |> yields "[foo]"
    (assembly, [| "--xs"; "foo"; "bar" |]) |> yields "[foo,bar]"
    (assembly, [| "--xs"; "foo bar"; "baz" |]) |> yields "[foo bar,baz]"
    (assembly, [| "--xs"; "foo"; "bar"; "baz" |]) |> yields "[foo,bar,baz]"

[<Fact>]
let ``Accepts Unit`` () =
    let assembly = testAssembly 13
    (assembly, [| "-u"; "()" |]) |> yields ""
    (assembly, [| "-u"; "42" |]) |> fails
