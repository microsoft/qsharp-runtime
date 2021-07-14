using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

// In SDK-style projects such as this one, several assembly attributes that were historically
// defined in this file are now automatically added during build and populated with
// values defined in project properties. For details of which attributes are included
// and how to customise this process see: https://aka.ms/assembly-info-properties


// Setting ComVisible to false makes the types in this assembly not visible to COM
// components.  If you need to access a type in this assembly from COM, set the ComVisible
// attribute to true on that type.

[assembly: ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM.

[assembly: Guid("1594aae8-0e24-442b-9201-430ce9ee4d2e")]

[assembly: InternalsVisibleTo("Tests.Microsoft.Quantum.Qir.Tools")]

// This is required to mock internals in tests.
[assembly: InternalsVisibleTo("DynamicProxyGenAssembly2")]
