﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

module Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint

open System
open System.Collections.Immutable
open System.Globalization
open System.IO
open System.Reflection
open System.Text.RegularExpressions
open System.Threading.Tasks
open Microsoft.CodeAnalysis
open Microsoft.CodeAnalysis.CSharp
open Microsoft.VisualStudio.LanguageServer.Protocol
open Xunit

open Microsoft.Quantum.QsCompiler.CompilationBuilder
open Microsoft.Quantum.QsCompiler.CsharpGeneration
open Microsoft.Quantum.QsCompiler.DataTypes
open Microsoft.Quantum.QsCompiler.ReservedKeywords
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.Simulation.Simulators


/// The path to the Q# file that provides the Microsoft.Quantum.Core namespace.
let private coreFile = Path.Combine ("Circuits", "Core.qs") |> Path.GetFullPath

/// The path to the Q# file that provides the Microsoft.Quantum.Intrinsic namespace.
let private intrinsicFile = Path.Combine ("Circuits", "Intrinsic.qs") |> Path.GetFullPath

/// The path to the Q# file that contains the test cases.
let private testFile = Path.Combine ("Circuits", "EntryPointTests.qs") |> Path.GetFullPath

/// The namespace used for the test cases.
let private testNamespace = "Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint"

/// The test case for the given test number.
let private testCase =
    File.ReadAllText testFile
    |> fun text -> text.Split "// ---"
    |> fun cases num -> cases.[num - 1]

/// Compiles Q# source code into a syntax tree with the list of entry points names.
let private compileQsharp source =
    let uri name = Uri ("file://" + name)
    let fileManager name content =
        CompilationUnitManager.InitializeFileManager (uri name, content)

    use compilationManager = new CompilationUnitManager (isExecutable = true)
    let fileManagers = ImmutableHashSet.Create (fileManager coreFile (File.ReadAllText coreFile),
                                                fileManager intrinsicFile (File.ReadAllText intrinsicFile),
                                                fileManager testFile source)
    compilationManager.AddOrUpdateSourceFilesAsync fileManagers |> ignore
    let compilation = compilationManager.Build ()
    let errors =
        compilation.Diagnostics ()
        |> Seq.filter (fun diagnostic -> diagnostic.Severity = DiagnosticSeverity.Error)
    Assert.Empty errors
    compilation.BuiltCompilation.Namespaces, compilation.BuiltCompilation.EntryPoints

/// Generates C# source code for the given test case number and default simulator.
let private generateCsharp defaultSimulator (syntaxTree : QsNamespace seq, entryPoints) =
    let assemblyConstants =
        match defaultSimulator with
        | Some simulator -> ImmutableDictionary.Empty.Add (AssemblyConstants.DefaultSimulator, simulator)
        | None -> ImmutableDictionary.Empty
    let context = CodegenContext.Create (syntaxTree, assemblyConstants)
    let entryPoint = context.allCallables.[Seq.exactlyOne entryPoints]
    [
        SimulationCode.generate (NonNullable<_>.New testFile) context
        EntryPoint.generate context entryPoint
    ]

/// The full path to a referenced assembly given its short name.
let private referencedAssembly name =
    let delimiter = if Environment.OSVersion.Platform = PlatformID.Win32NT then ';' else ':'
    let path =
        (AppContext.GetData "TRUSTED_PLATFORM_ASSEMBLIES" :?> string).Split delimiter
        |> Seq.tryFind (fun path -> String.Equals (Path.GetFileNameWithoutExtension path, name,
                                                   StringComparison.InvariantCultureIgnoreCase))
    path |> Option.defaultWith (fun () -> failwith (sprintf "Missing reference to assembly '%s'." name))

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

/// The assembly for the given test case and default simulator.
let private testAssembly testNum defaultSimulator =
    testNum
    |> testCase
    |> compileQsharp
    |> generateCsharp defaultSimulator
    |> compileCsharp

/// Runs the entry point driver in the assembly with the given command-line arguments, and returns the output, errors,
/// and exit code.
let private run (assembly : Assembly) (args : string[]) =
    let driver = assembly.GetType (EntryPoint.generatedNamespace testNamespace + ".Driver")
    let main = driver.GetMethod("Main", BindingFlags.NonPublic ||| BindingFlags.Static)
    let previousCulture = CultureInfo.DefaultThreadCurrentCulture
    let previousOut = Console.Out
    let previousError = Console.Error

    CultureInfo.DefaultThreadCurrentCulture <- CultureInfo ("en-US", false)
    use outStream = new StringWriter ()
    use errorStream = new StringWriter ()
    try
        Console.SetOut outStream
        Console.SetError errorStream
        let exitCode = main.Invoke (null, [| args |]) :?> Task<int> |> Async.AwaitTask |> Async.RunSynchronously
        outStream.ToString (), errorStream.ToString (), exitCode
    finally
        Console.SetError previousError
        Console.SetOut previousOut
        CultureInfo.DefaultThreadCurrentCulture <- previousCulture

/// Asserts that running the entry point in the assembly with the given arguments succeeds and yields the expected
/// output.
let private yields expected (assembly, args) =
    let normalize text = Regex.Replace(text, @"\s+", " ").Trim()
    let out, error, exitCode = run assembly args
    Assert.True (0 = exitCode, sprintf "Expected exit code 0, but got %d with:\n\n%s\n\n%s" exitCode out error)
    Assert.Equal (normalize expected, normalize out)

/// Asserts that running the entry point in the assembly with the given arguments fails.
let private fails (assembly, args) =
    let out, error, exitCode = run assembly args
    Assert.True (0 <> exitCode, sprintf "Expected non-zero exit code, but got 0 with:\n\n%s\n\n%s" out error)

/// A tuple of the test assembly and arguments using the standard default simulator. The tuple can be passed to yields
/// or fails.
let private test testNum =
    let assembly = testAssembly testNum None
    fun args -> assembly, Array.ofList args

/// A tuple of the test assembly and arguments using the given default simulator. The tuple can be passed to yields or
/// fails.
let private testWith testNum defaultSimulator =
    let assembly = testAssembly testNum (Some defaultSimulator)
    fun args -> assembly, Array.ofList args


// No Option

[<Fact>]
let ``Returns Unit`` () =
    let given = test 1
    given [] |> yields ""
    
[<Fact>]
let ``Returns Int`` () =
    let given = test 2
    given [] |> yields "42"

[<Fact>]
let ``Returns String`` () =
    let given = test 3
    given [] |> yields "Hello, World!"


// Single Option

[<Fact>]
let ``Accepts Int`` () =
    let given = test 4
    given ["-n"; "42"] |> yields "42"
    given ["-n"; "4.2"] |> fails
    given ["-n"; "9223372036854775807"] |> yields "9223372036854775807"
    given ["-n"; "9223372036854775808"] |> fails
    given ["-n"; "foo"] |> fails

[<Fact>]
let ``Accepts BigInt`` () =
    let given = test 5
    given ["-n"; "42"] |> yields "42"
    given ["-n"; "4.2"] |> fails
    given ["-n"; "9223372036854775807"] |> yields "9223372036854775807"
    given ["-n"; "9223372036854775808"] |> yields "9223372036854775808"
    given ["-n"; "foo"] |> fails

[<Fact>]
let ``Accepts Double`` () =
    let given = test 6
    given ["-n"; "4.2"] |> yields "4.2"
    given ["-n"; "foo"] |> fails

[<Fact>]
let ``Accepts Bool`` () =
    let given = test 7
    given ["-b"] |> yields "True"
    given ["-b"; "false"] |> yields "False"
    given ["-b"; "true"] |> yields "True"
    given ["-b"; "one"] |> fails

[<Fact>]
let ``Accepts Pauli`` () =
    let given = test 8
    given ["-p"; "PauliI"] |> yields "PauliI"
    given ["-p"; "PauliX"] |> yields "PauliX"
    given ["-p"; "PauliY"] |> yields "PauliY"
    given ["-p"; "PauliZ"] |> yields "PauliZ"
    given ["-p"; "paulii"] |> yields "PauliI"
    given ["-p"; "paulix"] |> yields "PauliX"
    given ["-p"; "pauliy"] |> yields "PauliY"
    given ["-p"; "pauliz"] |> yields "PauliZ"
    given ["-p"; "PauliW"] |> fails

[<Fact>]
let ``Accepts Result`` () =
    let given = test 9
    given ["-r"; "Zero"] |> yields "Zero"
    given ["-r"; "zero"] |> yields "Zero"
    given ["-r"; "One"] |> yields "One"
    given ["-r"; "one"] |> yields "One"
    given ["-r"; "0"] |> yields "Zero"
    given ["-r"; "1"] |> yields "One"
    given ["-r"; "Two"] |> fails

[<Fact>]
let ``Accepts Range`` () =
    let given = test 10
    given ["-r"; "0..0"] |> yields "0..1..0"
    given ["-r"; "0..1"] |> yields "0..1..1"
    given ["-r"; "0..2..10"] |> yields "0..2..10"
    given ["-r"; "0 ..1"] |> yields "0..1..1"
    given ["-r"; "0.. 1"] |> yields "0..1..1"
    given ["-r"; "0 .. 1"] |> yields "0..1..1"
    given ["-r"; "0 ..2 ..10"] |> yields "0..2..10"
    given ["-r"; "0.. 2 ..10"] |> yields "0..2..10"
    given ["-r"; "0 .. 2 .. 10"] |> yields "0..2..10"
    given ["-r"; "0 1"] |> fails
    given ["-r"; "0 2 10"] |> fails
    given ["-r"; "0"; "1"] |> fails
    given ["-r"; "0"] |> fails
    given ["-r"; "0.."] |> fails
    given ["-r"; "0..2.."] |> fails
    given ["-r"; "0..2..3.."] |> fails
    given ["-r"; "0..2..3..4"] |> fails
    given ["-r"; "0"; ".."; "1"] |> fails
    given ["-r"; "0..1"; "..2"] |> fails

[<Fact>]
let ``Accepts String`` () =
    let given = test 11
    given ["-s"; "Hello, World!"] |> yields "Hello, World!"

[<Fact>]
let ``Accepts Unit`` () =
    let given = test 12
    given ["-u"; "()"] |> yields ""
    given ["-u"; "42"] |> fails

[<Fact>]
let ``Accepts String array`` () =
    let given = test 13
    given ["--xs"; "foo"] |> yields "[foo]"
    given ["--xs"; "foo"; "bar"] |> yields "[foo,bar]"
    given ["--xs"; "foo bar"; "baz"] |> yields "[foo bar,baz]"
    given ["--xs"; "foo"; "bar"; "baz"] |> yields "[foo,bar,baz]"
    given ["--xs"] |> fails

[<Fact>]
let ``Accepts BigInt array`` () =
    let given = test 14
    given ["--bs"; "9223372036854775808"] |> yields "[9223372036854775808]"
    given ["--bs"; "1"; "2"; "9223372036854775808"] |> yields "[1,2,9223372036854775808]"
    given ["--bs"; "1"; "2"; "4.2"] |> fails

[<Fact>]
let ``Accepts Pauli array`` () =
    let given = test 15
    given ["--ps"; "PauliI"] |> yields "[PauliI]"
    given ["--ps"; "PauliZ"; "PauliX"] |> yields "[PauliZ,PauliX]"
    given ["--ps"; "PauliY"; "PauliY"; "PauliY"] |> yields "[PauliY,PauliY,PauliY]"
    given ["--ps"; "PauliY"; "PauliZ"; "PauliW"] |> fails

[<Fact>]
let ``Accepts Range array`` () =
    let given = test 16
    given ["--rs"; "1..10"] |> yields "[1..1..10]"
    given ["--rs"; "1..10"; "2..4..20"] |> yields "[1..1..10,2..4..20]"
    given ["--rs"; "1 ..10"; "2 ..4 ..20"] |> yields "[1..1..10,2..4..20]"
    given ["--rs"; "1 .. 10"; "2 .. 4 .. 20"] |> yields "[1..1..10,2..4..20]"
    given ["--rs"; "1 .. 1o"; "2 .. 4 .. 20"] |> fails

[<Fact>]
let ``Accepts Result array`` () =
    let given = test 17
    given ["--rs"; "One"] |> yields "[One]"
    given ["--rs"; "One"; "Zero"] |> yields "[One,Zero]"
    given ["--rs"; "Zero"; "One"; "Two"] |> fails

[<Fact>]
let ``Accepts Unit array`` () =
    let given = test 18
    given ["--us"; "()"] |> yields "[()]"
    given ["--us"; "()"; "()"] |> yields "[(),()]"
    given ["--us"; "()"; "()"; "()"] |> yields "[(),(),()]"
    given ["--us"; "()"; "unit"; "()"] |> fails

[<Fact>]
let ``Supports repeat-name array syntax`` () =
    let given = test 13
    given ["--xs"; "Hello"; "--xs"; "World"] |> yields "[Hello,World]"
    given ["--xs"; "foo"; "bar"; "--xs"; "baz"] |> yields "[foo,bar,baz]"
    given ["--xs"; "foo"; "--xs"; "bar"; "--xs"; "baz"] |> yields "[foo,bar,baz]"
    given ["--xs"; "foo bar"; "--xs"; "baz"] |> yields "[foo bar,baz]"


// Multiple Options

[<Fact>]
let ``Accepts two options`` () =
    let given = test 19
    given ["-n"; "7"; "-b"; "true"] |> yields "7 True"
    given ["-b"; "true"; "-n"; "7"] |> yields "7 True"

[<Fact>]
let ``Accepts three options`` () =
    let given = test 20
    given ["-n"; "7"; "-b"; "true"; "--xs"; "foo"] |> yields "7 True [foo]"
    given ["--xs"; "foo"; "-n"; "7"; "-b"; "true"] |> yields "7 True [foo]"
    given ["-n"; "7"; "--xs"; "foo"; "-b"; "true"] |> yields "7 True [foo]"
    given ["-b"; "true"; "-n"; "7"; "--xs"; "foo"] |> yields "7 True [foo]"

[<Fact>]
let ``Requires all options`` () =
    let given = test 20
    given ["-b"; "true"; "--xs"; "foo"] |> fails
    given ["-n"; "7"; "--xs"; "foo"] |> fails
    given ["-n"; "7"; "-b"; "true"] |> fails
    given ["-n"; "7"] |> fails
    given ["-b"; "true"] |> fails
    given ["--xs"; "foo"] |> fails
    given [] |> fails


// Name Conversion

[<Fact>]
let ``Uses kebab-case`` () =
    let given = test 21
    given ["--camel-case-name"; "foo"] |> yields "foo"
    given ["--camelCaseName"; "foo"] |> fails

[<Fact>]
let ``Uses single-dash short names`` () =
    let given = test 22
    given ["-x"; "foo"] |> yields "foo"
    given ["--x"; "foo"] |> fails


// Shadowing

[<Fact>]
let ``Shadows --simulator`` () =
    let given = test 23
    given ["--simulator"; "foo"] |> yields "foo"
    given ["--simulator"; AssemblyConstants.ResourcesEstimator] |> yields AssemblyConstants.ResourcesEstimator
    given ["-s"; AssemblyConstants.ResourcesEstimator; "--simulator"; "foo"] |> fails 
    given ["-s"; "foo"] |> fails

[<Fact>]
let ``Shadows -s`` () =
    let given = test 24
    given ["-s"; "foo"] |> yields "foo"
    given ["--simulator"; AssemblyConstants.ToffoliSimulator; "-s"; "foo"] |> yields "foo"
    given ["--simulator"; "bar"; "-s"; "foo"] |> fails

[<Fact>]
let ``Shadows --version`` () =
    let given = test 25
    given ["--version"; "foo"] |> yields "foo"


// Simulators

// The expected output from the resources estimator.
let private resourceSummary = "Metric          Sum
CNOT            0
QubitClifford   1
R               0
Measure         1
T               0
Depth           0
Width           1
BorrowedWidth   0"

[<Fact>]
let ``Supports QuantumSimulator`` () =
    let given = test 26
    given ["--simulator"; AssemblyConstants.QuantumSimulator; "--use-h"; "false"] |> yields "Hello, World!"
    given ["--simulator"; AssemblyConstants.QuantumSimulator; "--use-h"; "true"] |> yields "Hello, World!"

[<Fact>]
let ``Supports ToffoliSimulator`` () =
    let given = test 26
    given ["--simulator"; AssemblyConstants.ToffoliSimulator; "--use-h"; "false"] |> yields "Hello, World!"
    given ["--simulator"; AssemblyConstants.ToffoliSimulator; "--use-h"; "true"] |> fails

[<Fact>]
let ``Supports ResourcesEstimator`` () =
    let given = test 26
    given ["--simulator"; AssemblyConstants.ResourcesEstimator; "--use-h"; "false"] |> yields resourceSummary
    given ["--simulator"; AssemblyConstants.ResourcesEstimator; "--use-h"; "true"] |> yields resourceSummary

[<Fact>]
let ``Rejects unknown simulator`` () =
    let given = test 26
    given ["--simulator"; "FooSimulator"; "--use-h"; "false"] |> fails

[<Fact>]
let ``Supports default standard simulator`` () =
    let given = testWith 26 AssemblyConstants.ResourcesEstimator
    given ["--use-h"; "false"] |> yields resourceSummary
    given ["--simulator"; AssemblyConstants.QuantumSimulator; "--use-h"; "false"] |> yields "Hello, World!"

[<Fact>]
let ``Supports default custom simulator`` () =
    // This is not really a "custom" simulator, but the driver does not recognize the fully-qualified name of the
    // standard simulators, so it is treated as one.
    let given = testWith 26 typeof<ToffoliSimulator>.FullName
    given ["--use-h"; "false"] |> yields "Hello, World!"
    given ["--use-h"; "true"] |> fails
    given ["--simulator"; typeof<ToffoliSimulator>.FullName; "--use-h"; "false"] |> yields "Hello, World!"
    given ["--simulator"; typeof<ToffoliSimulator>.FullName; "--use-h"; "true"] |> fails
    given ["--simulator"; AssemblyConstants.QuantumSimulator; "--use-h"; "false"] |> yields "Hello, World!"
    given ["--simulator"; AssemblyConstants.QuantumSimulator; "--use-h"; "true"] |> yields "Hello, World!"
    given ["--simulator"; AssemblyConstants.ResourcesEstimator; "--use-h"; "false"] |> yields resourceSummary
    given ["--simulator"; typeof<QuantumSimulator>.FullName; "--use-h"; "false"] |> fails


// Help

[<Fact>]
let ``Uses documentation`` () =
    let name = Path.GetFileNameWithoutExtension (Assembly.GetEntryAssembly().Location)
    let message = (name, name) ||> sprintf "%s:
  This test checks that the entry point documentation appears correctly in the command line help message.

Usage:
  %s [options] [command]

Options:
  -n <n> (REQUIRED)                                   A number.
  --pauli <PauliI|PauliX|PauliY|PauliZ> (REQUIRED)    The name of a Pauli matrix.
  --my-cool-bool (REQUIRED)                           A neat bit.
  -s, --simulator <simulator>                         The name of the simulator to use.
  --version                                           Show version information
  -?, -h, --help                                      Show help and usage information

Commands:
  simulate    (default) Run the program using a local simulator."

    let given = test 27
    given ["--help"] |> yields message
    given ["-h"] |> yields message
    given ["-?"] |> yields message
