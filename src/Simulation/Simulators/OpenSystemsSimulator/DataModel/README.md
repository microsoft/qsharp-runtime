# Open systems simulation data model

The C# classes in this folder define a data model and JSON serialization logic that can be used to exchange data with the native runtime for the open systems simulator.

## Newtonsoft.Json versus System.Text.Json

The JSON converters in this folder target System.Text.Json as this is the recommended path for .NET Core 3.1 and forward, both in terms of where new functionality will be developed, and in terms of performance improvements due to `Span` and other recent additions to the .NET platform.

Since IQ# and many other Quantum Development Kit components use Newtonsoft.Json, however, the `DelegatedConverter<T>` class allows for exposing a System.Text.Json converter as a Newtonsoft.Json converter; this has a significant performance implication, but provides a path forward for using System.Text.Json in the future.
