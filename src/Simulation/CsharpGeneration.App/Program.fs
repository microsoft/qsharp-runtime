// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

module Microsoft.Quantum.QsCompiler.CsharpGeneration.Program

open System
open System.Collections.Generic
open CommandLine
open Microsoft.Quantum.QsCompiler
open Microsoft.Quantum.QsCompiler.Diagnostics
open Microsoft.Quantum.QsCompiler.Transformations.BasicTransformations


type Options = {

    [<Option('v', "verbose", Required = false, Default = false, 
      HelpText = "Specifies whether to compile in verbose mode.")>]
    Verbose : bool;
    
    [<Option('i', "input", Required = true, 
      HelpText = "Q# code or name of the Q# file to compile.")>]
    Input : IEnumerable<string>
            
    [<Option('r', "references", Required = false, Default = [||],
      HelpText = "Referenced binaries to include in the compilation.")>]
    References : IEnumerable<string>
 
    [<Option('o', "output", Required = true, 
      HelpText = "Destination folder where the output of the compilation will be generated.")>]
    OutputFolder : string

    [<Option("doc", Required = false,
      HelpText = "Destination folder where documentation will be generated.")>]
    DocFolder : string

}

type Logger() = 
    inherit LogTracker()
    override this.Print msg =
        Formatting.MsBuildFormat msg |> Console.WriteLine
    override this.OnException ex = 
        Console.Error.WriteLine ex


let generateFiles (options : Options) = 
    let logger = new Logger()
    let loadOptions = 
        new CompilationLoader.Configuration(
            GenerateFunctorSupport = true,
            DocumentationOutputFolder = options.DocFolder
        ) 

    let loaded = new CompilationLoader(options.Input, options.References, Nullable(loadOptions), logger)
    let syntaxTree = loaded.GeneratedSyntaxTree |> Seq.toArray
    let allSources = GetSourceFiles.Apply syntaxTree |> Seq.filter (fun fileName -> fileName.Value.EndsWith ".qs")
    for source in allSources do
        try let content = syntaxTree |> SimulationCode.generate source
            CompilationLoader.GeneratedFile(source, options.OutputFolder, ".g.cs", content) |> ignore
        with | ex -> logger.Log(ex)


let [<EntryPoint>] main args = 
    match Parser.Default.ParseArguments<Options> args with 
    | :? Parsed<Options> as options -> generateFiles options.Value; 0
    | _ -> 1



