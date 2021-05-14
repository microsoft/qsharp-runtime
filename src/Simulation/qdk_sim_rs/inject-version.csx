#r "nuget: System.CommandLine, 2.0.0-beta1.21216.1"
#r "nuget: Tommy, 2.0.0"

using System.CommandLine;
using System.Linq;
using System.CommandLine.Invocation;
using Tommy;

// Create a root command with some options
var rootCommand = new RootCommand
{
    new Option<FileInfo>(
        "--template",
        description: "A file to use as the template for cargo manifest."),
    new Option<string>(
        "--out-path",
        description: "Path to write the generated manifest to."),
    new Option<string>(
        "--version",
        description: "The version number to inject.")
};

// Note that the parameters of the handler method are matched according to the names of the options
rootCommand.Handler = CommandHandler.Create<FileInfo, string, string>((template, outPath, version) =>
{
    using var reader = new StreamReader(File.OpenRead(template.FullName));
    var table = TOML.Parse(reader);

    // Set the version number in the table.
    table["package"]["version"] = version;

    using var writer = new StreamWriter(File.OpenWrite(outPath));
    table.WriteTo(writer);
    // Remember to flush the data if needed!
    writer.Flush();
});

await rootCommand.InvokeAsync(Args.ToArray());
