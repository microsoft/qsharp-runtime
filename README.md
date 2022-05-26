# Microsoft Quantum Development Kit: Q# runtime #

Welcome to the Microsoft Quantum Development Kit!

This repository contains the runtime components for the [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/).
It consists of the libraries and packages needed to create and simulate quantum applications using Q#.

- **[Azure/](./src/Azure/)**: Source for client package to create and manage jobs in Azure Quantum.
- **[Simulation/](./src/Simulation/)**: Source for Q# simulation. Includes code generation, full-state and other simulators.
- **[xUnit/](./src/Xunit/)**: Source for the xUnit's Q# test-case discoverer.

## New to Quantum? ##

See the [introduction to quantum computing](https://docs.microsoft.com/azure/quantum/concepts-overview) provided with the Quantum Development Kit.


## Installing the Quantum Development Kit

**If you're looking to use Q# to write quantum applications, please see the instructions on how to get started with using the [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk) including the Q# compiler, language server, and development environment extensions.**

Please see the [installation guide](https://docs.microsoft.com/azure/quantum/install-overview-qdk) for further information on how to get started using the Quantum Development Kit to develop quantum applications.
You may also visit our [Quantum](https://github.com/microsoft/quantum) repository, which offers a wide variety of samples on how to write quantum based programs.


## Building from Source ##

[![Build Status](https://dev.azure.com/ms-quantum-public/Microsoft%20Quantum%20(public)/_apis/build/status/microsoft.qsharp-runtime?branchName=main)](https://dev.azure.com/ms-quantum-public/Microsoft%20Quantum%20(public)/_build/latest?definitionId=15&branchName=main)

Note that when building from source, this repository is configured so that .NET will automatically look at the [Quantum Development Kit prerelease feed](https://dev.azure.com/ms-quantum-public/Microsoft%20Quantum%20(public)/_packaging?_a=feed&feed=alpha) in addition to any other feeds you may have configured.

Building **QIR Runtime** isn't enabled by default yet. Please see [its readme](./src/Qir/Runtime/README.md) for details.

### Windows ###

To build on Windows:

1. Install the pre-reqs:
    * Install [CMake](https://cmake.org/install/) 3.20 or newer.
    * Install [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/). Make sure you install the following workloads:
        * **Desktop development with C++**
        * **Spectre-mitigated libraries. For that in the Visual Studio Installer, for the VS version of interest,
          press "Modify" button, "Individual Components" tab, search for "spectre", select the latest version of "MSVC v143 - VS 2022 C++ x64/x86 Spectre-mitigated libs", press "Modify" button**
        * **.NET 6.0 Runtime**
2. Run [bootstrap.ps1](bootstrap.ps1) from PowerShell
    * pre-req (in PowerShell): `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
    * The script might install additional tools (a specific compiler, build tools, etc)
    * Then it builds release flavor of the native (C++) full-state simulator and debug flavor of the Simulation solution.
    * You only need to run it once.
3. Open and build the [`Simulation.sln`](./Simulation.sln) solution in Visual Studio.

The `Simulation.sln` solution does not include the full-state quantum simulator. To change it, you can open the `quantum-simulator.sln` solution created during bootstrap in the `src\Simulation\Native\build`. To integrate your changes with the rest of the simulation components, you must manually build it.


### macOS/Linux ###

To build on other platforms:

1. Install the pre-reqs:
    * Install [CMake](https://cmake.org/install/) 3.20 or newer
    * Install [.NET 6.0](https://dotnet.microsoft.com/download) (version lower than 6.0.300 is recommended)
    * On [WSL](https://docs.microsoft.com/en-us/windows/wsl/)/Linux:
      * Install [`libomp`](https://openmp.llvm.org) needed for the native (C++) full-state simulator.
        `sudo apt install libomp-13-dev`. The possible result can be as in listing A below.
      * .NET 6.0: `sudo apt install dotnet-sdk-6.0 dotnet-runtime-6.0`. The possible result can be as in listing B below.

Listing A.

```bash
# In an empty directory:
dpkg -l *libomp*

# Desired=Unknown/Install/Remove/Purge/Hold
# | Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
# |/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
# ||/ Name             Version                                                         Architecture Description
# +++-================-===============================================================-============-=================================
# un  libomp-11-dev    <none>                                                          <none>       (no description available)
# ii  libomp-13-dev    1:13.0.1~++20220120110924+75e33f71c2da-1~exp1~20220120231001.58 amd64        LLVM OpenMP runtime - dev package
# un  libomp-13-doc    <none>                                                          <none>       (no description available)
# un  libomp-dev       <none>                                                          <none>       (no description available)
# un  libomp-x.y       <none>                                                          <none>       (no description available)
# un  libomp-x.y-dev   <none>                                                          <none>       (no description available)
# un  libomp5          <none>                                                          <none>       (no description available)
# ii  libomp5-13:amd64 1:13.0.1~++20220120110924+75e33f71c2da-1~exp1~20220120231001.58 amd64        LLVM OpenMP runtime
```

Listing B.

```bash
# In an empty directory:
dpkg -l *dotnet*

# Desired=Unknown/Install/Remove/Purge/Hold
# | Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
# |/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
# ||/ Name                      Version      Architecture Description
# +++-=========================-============-============-=======================================
# un  dotnet                    <none>       <none>       (no description available)
# ii  dotnet-apphost-pack-6.0   6.0.5-1      amd64        Microsoft.NETCore.App.Host 6.0.5
# ii  dotnet-host               6.0.5-1      amd64        Microsoft .NET Host - 6.0.5
# ii  dotnet-hostfxr-6.0        6.0.5-1      amd64        Microsoft .NET Host FX Resolver - 6.0.5
# un  dotnet-nightly            <none>       <none>       (no description available)
# ii  dotnet-runtime-6.0        6.0.5-1      amd64        Microsoft.NETCore.App.Runtime 6.0.5
# ii  dotnet-runtime-deps-6.0   6.0.5-1      amd64        dotnet-runtime-deps-debian 6.0.5
# ii  dotnet-sdk-6.0            6.0.300-1    amd64        Microsoft .NET SDK 6.0.300
# ii  dotnet-targeting-pack-6.0 6.0.5-1      amd64        Microsoft.NETCore.App.Ref 6.0.5
```

2. Run [bootstrap.ps1](./bootstrap.ps1)
    * The script might install additional tools (a specific compiler, build tools, etc)
    * Then it builds release flavor of the native (C++) full-state simulator and debug flavor of the Simulation solution.
    * You only need to run it once.
3. From the command line, run:
    * `dotnet build Simulation.sln`

The `Simulation.sln` solution does not include the full-state simulator. To integrate any changes with the rest of the simulation components, you need to manually build it using `make` in the `src\Simulation\Native\build` folder.


## Testing ##

All unit tests are part of the `Simulation.sln` solution. To run the tests:

* From [Visual Studio](https://docs.microsoft.com/en-us/visualstudio/test/getting-started-with-unit-testing?view=vs-2019#run-unit-tests):
    * Open Test Explorer by choosing Test > Windows > Test Explorer from the top menu bar.
    * Run your unit tests by clicking Run All.
* From the command line, run:
    * `dotnet test Simulation.sln`


## Feedback ##

If you have feedback about the Q# simulators or any other runtime component, please let us know by filing a [new issue](https://github.com/microsoft/qsharp-runtime/issues/new)!
If you have feedback about some other part of the Microsoft Quantum Development Kit, please see the [contribution guide](https://docs.microsoft.com/azure/quantum/contributing-overview) for more information.


## Reporting Security Issues

Security issues and bugs should be reported privately, via email, to the Microsoft Security
Response Center (MSRC) at [secure@microsoft.com](mailto:secure@microsoft.com). You should
receive a response within 24 hours. If for some reason you do not, please follow up via
email to ensure we received your original message. Further information, including the
[MSRC PGP](https://technet.microsoft.com/en-us/security/dn606155) key, can be found in
the [Security TechCenter](https://technet.microsoft.com/en-us/security/default).


## Legal and Licensing ##


## Contributing ##

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

For more details, please see [CONTRIBUTING.md](./CONTRIBUTING.md), or the [contribution guide](https://docs.microsoft.com/azure/quantum/contributing-overview).
