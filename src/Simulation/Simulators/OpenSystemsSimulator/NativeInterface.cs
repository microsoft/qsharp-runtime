using System;
using System.IO;
using System.Reflection;
using System.Text.Json;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

#nullable enable

namespace Microsoft.Quantum.Experimental
{
    /// <summary>
    ///     Abstracts away calls to and from libopensim.
    /// </summary>
    internal static class NativeInterface
    {
        public static event Action<string>? OnVerbose = null;
        private static void LogCall(string callName) =>
            OnVerbose?.Invoke($"[VERBOSE] NativeInterface: calling {callName}.");

        private static void CheckCall(Int64 errorCode)
        {
            if (errorCode != 0)
            {
                var error = _LastError();
                throw new Exception($"Exception in native open systems simulator runtime: {error}");
            }
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="lasterr")]
        private static extern string _LastError();

        public const string DLL_NAME = "Microsoft.Quantum.Experimental.OpenSystemsSimulator.Native.dll";

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="get_name")]
        private static extern string _GetName();

        public static string Name
        {
            get
            {
                // TODO: Add get_name to c_api and uncomment this.
                // LogCall("get_name");
                // return _GetName();
                return "OpenSystemsSimulator";
            }
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="init")]
        private static extern ulong _Init(uint initialCapacity);

        public static ulong Init(uint initialCapacity)
        {
            LogCall("init");
            return _Init(initialCapacity);
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="destroy")]
        private static extern Int64 _Destroy(uint simId);

        public static void Destroy(uint simId)
        {
            LogCall("init");
            CheckCall(_Destroy(simId));
        }

        

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="dump_to_console")]
        private static extern void _DumpToConsole(uint simId);

        public static void DumpToConsole(uint simId)
        {
            LogCall("dump_to_console");
            _DumpToConsole(simId);
        }

        // TODO: Copy datamodel and uncomment.
        // [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="get_current_state")]
        // private static extern string _GetCurrentState();

        // public static State CurrentState
        // {
        //     get
        //     {
        //         LogCall("get_current_state");
        //         return JsonSerializer.Deserialize<State>(_GetCurrentState());
        //     }
        // }

        // [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="get_noise_model")]
        // private static extern string _GetNoiseModel();

        // [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="set_noise_model")]
        // private static extern void _SetNoiseModel(string noiseModel);

        // public static NoiseModel NoiseModel
        // {
        //     get
        //     {
        //         LogCall("get_noise_model");
        //         return JsonSerializer.Deserialize<NoiseModel>(_GetNoiseModel());
        //     }
        //     set
        //     {
        //         LogCall("set_noise_model");
        //         _SetNoiseModel(JsonSerializer.Serialize(value));
        //     }
        // }

        // FIXME: all of the following actually return an error code that needs to be checked, not void!
        //        To fix, write a new method that checks the error code that results, calls last_err if
        //        needed, and turns that error message into an exception.

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="h")]
        private static extern Int64 _H(ulong simId, uint idx);

        public static void H(ulong simId, Qubit q)
        {
            LogCall("h");
            CheckCall(_H(simId, (uint)q.Id));
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="x")]
        private static extern Int64 _X(ulong simId, uint idx);

        public static void X(ulong simId, Qubit q)
        {
            LogCall("x");
            CheckCall(_X(simId, (uint)q.Id));
        }

        // [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="y")]
        // private static extern void _Y(uint idx);

        // public static void Y(Qubit q)
        // {
        //     LogCall("y");
        //     _Y((uint)q.Id);
        // }

        // [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="z")]
        // private static extern void _Z(uint idx);

        // public static void Z(Qubit q)
        // {
        //     LogCall("z");
        //     _Z((uint)q.Id);
        // }

        // [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="s")]
        // private static extern void _S(uint idx);

        // public static void S(Qubit q)
        // {
        //     LogCall("s");
        //     _S((uint)q.Id);
        // }

        // [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="s_adj")]
        // private static extern void _SAdj(uint idx);

        // public static void SAdj(Qubit q)
        // {
        //     LogCall("s_adj");
        //     _SAdj((uint)q.Id);
        // }

        // [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="t")]
        // private static extern void _T(uint idx);

        // public static void T(Qubit q)
        // {
        //     LogCall("t");
        //     _T((uint)q.Id);
        // }

        // [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="t_adj")]
        // private static extern void _TAdj(uint idx);

        // public static void TAdj(Qubit q)
        // {
        //     LogCall("t_adj");
        //     _TAdj((uint)q.Id);
        // }

        // [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="cnot")]
        // private static extern void _CNOT(uint idxControl, uint idxTarget);

        // public static void CNOT(Qubit control, Qubit target)
        // {
        //     LogCall("cnot");
        //     _CNOT((uint)control.Id, (uint)target.Id);
        // }


        // [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="m")]
        // private static extern void _M(uint idx, out uint result);

        // public static Result M(Qubit q)
        // {
        //     LogCall("m");
        //     _M((uint)q.Id, out var result);
        //     return result == 1 ? Result.One : Result.Zero;
        // }

    }
}
