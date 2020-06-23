# Microsoft Quantum Development Kit: Q# runtime #

Welcome to the Microsoft Quantum Development Kit!

This repository contains the runtime components for the [Quantum Development Kit](https://docs.microsoft.com/quantum/).
It consists of the libraries and packages needed to create and simulate quantum applications using Q#.

- **[Azure/](./src/Azure/)**: Source for client package to create and manage jobs in Azure Quantum.
- **[Simulation/](./src/Simulation/)**: Source for Q# simulation. Includes code generation, full-state and other simulators.
- **[xUnit/](./src/Xunit/)**: Source for the xUnit's Q# test-case discoverer.

## New to Quantum? ##

See the [introduction to quantum computing](https://docs.microsoft.com/quantum/concepts/) provided with the Quantum Development Kit.


## Installing the Quantum Development Kit

**If you're looking to use Q# to write quantum applications, please see the instructions on how to get started with using the [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/) including the Q# compiler, language server, and development environment extensions.**

Please see the [installation guide](https://docs.microsoft.com/quantum/install-guide) for further information on how to get started using the Quantum Development Kit to develop quantum applications.
You may also visit our [Quantum](https://github.com/microsoft/quantum) repository, which offers a wide variety of samples on how to write quantum based programs.


## Building from Source ##

[![Build Status](https://dev.azure.com/ms-quantum-public/Microsoft%20Quantum%20(public)/_apis/build/status/microsoft.qsharp-runtime?branchName=master)](https://dev.azure.com/ms-quantum-public/Microsoft%20Quantum%20(public)/_build/latest?definitionId=15&branchName=master)


Note that when building from source, this repository is configured so that .NET Core will automatically look at the [Quantum Development Kit prerelease feed](https://dev.azure.com/ms-quantum-public/Microsoft%20Quantum%20(public)/_packaging?_a=feed&feed=alpha) in addition to any other feeds you may have configured.


### Windows ###

To build on Windows:

1. Install the pre-reqs:
    * Install [CMake](https://cmake.org/install/)
    * Install [Visual Studio 2019 (version 16.3 or later)](https://visualstudio.microsoft.com/downloads/). Make sure you install the following workloads:
        * **Desktop development with C++**
        * **From the Individual Components tab in VS Installer add Spectre-mitigated libs that match your C++ build tools version**
        * **.NET Core 3 cross-platform development**
2. Run [bootstrap.cmd](bootstrap.cmd) from the `Developer Command Prompt for VS 2019`.
    * pre-req (in PowerShell): `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
    * This script prepares and builds the native (C++) full-state simulator.
    * You only need to run it once.
3. Open and build the [`Simulation.sln`](./Simulation.sln) solution in Visual Studio.

The `Simulation.sln` solution does not include the full-state quantum simulator. To change it, you can open the `quantum-simulator.sln` solution created during bootstrap in the `src\Simulation\Native\build`. To integrate your changes with the rest of the simulation components, you must first manually build it using the `Release` configuration.


### macOS/Linux ###

To build on other platforms:

1. Install the pre-reqs:
    * Install [CMake](https://cmake.org/install/)
    * Install [.NET Core 3 SDK](https://dotnet.microsoft.com/download)
2. Run [bootstrap.sh](./bootstrap.sh)
    * This script prepares and builds the native (C++) full-state simulator.
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
If you have feedback about some other part of the Microsoft Quantum Development Kit, please see the [contribution guide](https://docs.microsoft.com/quantum/contributing/) for more information.


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

For more details, please see [CONTRIBUTING.md](./CONTRIBUTING.md), or the [contribution guide](https://docs.microsoft.com/quantum/contributing/).
