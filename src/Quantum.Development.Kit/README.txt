The content of this folder is deprecated and only preserved to support both the old and the new setup for some extended period of time. 
There are currently some issues tracked related to using custom Sdks that cause some inconvenience with our build setup. We may hence choose to keep the older setup for certain test projects until these issues are resolved. 
See also: 
https://github.com/dotnet/runtime/issues/949
https://github.com/NuGet/Home/issues/8692
https://github.com/NuGet/NuGet.Client/pull/3170

Important: This deprecated version of the Microsoft.Quantum.Development.Kit package clashes with the Microsoft.Quantum.Sdk, meaning that projects which use the new Sdk should *not* include this package. 
Eventually, we will likely adapt the Microsoft.Quantum.Development.Kit package to no longer provide the build functionality it currently does, but instead merely aggregate a collection of packages. 
At that point the package will be again compatible with the Sdk, and the Sdk will become required to compile Q# projects. 


