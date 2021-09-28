#addin nuget:?package=Cake.CMake&version=1.2.0

var release_configuration = Argument("configuration", "Release");
var debug_configuration = Argument("configuration", "Debug");
var target = Argument("target", "Build");

//////////////////////////////////////////////////////////////////////
// TASKS
//////////////////////////////////////////////////////////////////////

Task("Clean")
    .WithCriteria(c => HasArgument("rebuild"))
    .Does(() =>
{
    CleanDirectory($"./{release_configuration}");
    CleanDirectory($"./{debug_configuration}");
});

Task("CMake"
)    .IsDependentOn("Clean")
    .Does(() =>
{
    CMake(new CMakeSettings {
        OutputPath = Directory("Native/build"),
        SourcePath = Directory("Native/"),
    });

    CMakeBuild(new CMakeBuildSettings {
        BinaryPath = Directory("Native/build"),
        Configuration = release_configuration
    });
});

Task("Build")
    .IsDependentOn("CMake")
    .Does(() =>
{
    DotNetCoreBuild(".", new DotNetCoreBuildSettings
    {
        Configuration = release_configuration,
    });
});

Task("CMake_debug"
)    .IsDependentOn("Clean")
    .Does(() =>
{
    CMake(new CMakeSettings {
        OutputPath = Directory("Native/build"),
        SourcePath = Directory("Native/"),
    });

    CMakeBuild(new CMakeBuildSettings {
        BinaryPath = Directory("Native/build"),
        Configuration = debug_configuration
    });
});

Task("Build_debug")
    .IsDependentOn("CMake_debug")
    .Does(() =>
{
    DotNetCoreBuild(".", new DotNetCoreBuildSettings
    {
        Configuration = debug_configuration,
    });
});


RunTarget(target);
RunTarget(Argument("target", "Build_debug"));

