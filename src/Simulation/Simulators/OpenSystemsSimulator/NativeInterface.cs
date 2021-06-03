// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Reflection;
using System.Text.Json;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;
using Newtonsoft.Json.Linq;

#nullable enable

namespace Microsoft.Quantum.Experimental
{
    /// <summary>
    ///     Abstracts away calls to and from the experimental simulators DLL.
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


        public const string DLL_NAME = "Microsoft.Quantum.Experimental.Simulators.Runtime.dll";

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="lasterr")]
        private static extern string _LastError();


        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="get_simulator_info")]
        private static extern string _GetSimulatorInfo();

        private static readonly JToken SimulatorInfo;

        static NativeInterface()
        {
            SimulatorInfo = JToken.Parse(_GetSimulatorInfo());
        }

        public static string Name
        {
            get
            {
                return SimulatorInfo.Value<string>("name");
            }
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="init")]
        private static extern Int64 _Init(uint initialCapacity, string representation, out uint simulatorId);

        public static ulong Init(uint initialCapacity, string representation = "mixed")
        {
            LogCall("init");
            CheckCall(_Init(initialCapacity, representation, out var simulatorId));
            return simulatorId;
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="destroy")]
        private static extern Int64 _Destroy(ulong simId);

        public static void Destroy(ulong simId)
        {
            LogCall("init");
            CheckCall(_Destroy(simId));
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="dump_to_console")]
        private static extern void _DumpToConsole(ulong simId);

        public static void DumpToConsole(ulong simId)
        {
            LogCall("dump_to_console");
            _DumpToConsole(simId);
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="get_current_state")]
        private static extern string _GetCurrentState(ulong simId);

        public static State GetCurrentState(ulong simId)
        {
            LogCall("get_current_state");
            return JsonSerializer.Deserialize<State>(_GetCurrentState(simId));
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="get_noise_model")]
        private static extern string _GetNoiseModel(ulong simId);


        public static NoiseModel GetNoiseModel(ulong simId)
        {
            LogCall("get_noise_model");
            return JsonSerializer.Deserialize<NoiseModel>(_GetNoiseModel(simId));
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="set_noise_model")]
        private static extern Int64 _SetNoiseModel(ulong simId, string noiseModel);

        public static void SetNoiseModel(ulong simId, NoiseModel noiseModel)
        {
            LogCall("set_noise_model");
            string? jsonData = null;
            try
            {
                jsonData = JsonSerializer.Serialize(noiseModel);
                CheckCall(_SetNoiseModel(simId, jsonData));
            }
            catch (NotSupportedException ex)
            {
                throw new ArgumentException("Could not serialize noise model to JSON, as no suitable serializer was found.", ex);
            }
            catch (JsonException ex)
            {
                throw new Exception($"Could not serialize noise model: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                throw new Exception($"Could not set noise model from JSON: {ex.Message}\nJSON data:\n{jsonData}", ex);
            }
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="ideal_noise_model")]
        private static extern string _IdealNoiseModel();


        public static NoiseModel IdealNoiseModel()
        {
            LogCall("ideal_noise_model");
            return JsonSerializer.Deserialize<NoiseModel>(_IdealNoiseModel());
        }


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

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="y")]
        private static extern Int64 _Y(ulong simId, uint idx);

        public static void Y(ulong simId, Qubit q)
        {
            LogCall("y");
            CheckCall(_Y(simId, (uint)q.Id));
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="z")]
        private static extern Int64 _Z(ulong simId, uint idx);

        public static void Z(ulong simId, Qubit q)
        {
            LogCall("z");
            CheckCall(_Z(simId, (uint)q.Id));
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="s")]
        private static extern Int64 _S(ulong simId, uint idx);

        public static void S(ulong simId, Qubit q)
        {
            LogCall("s");
            CheckCall(_S(simId, (uint)q.Id));
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="s_adj")]
        private static extern Int64 _SAdj(ulong simId, uint idx);

        public static void SAdj(ulong simId, Qubit q)
        {
            LogCall("s");
            CheckCall(_SAdj(simId, (uint)q.Id));
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="t")]
        private static extern Int64 _T(ulong simId, uint idx);

        public static void T(ulong simId, Qubit q)
        {
            LogCall("t");
            CheckCall(_T(simId, (uint)q.Id));
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="t_adj")]
        private static extern Int64 _TAdj(ulong simId, uint idx);

        public static void TAdj(ulong simId, Qubit q)
        {
            LogCall("t_adj");
            CheckCall(_TAdj(simId, (uint)q.Id));
        }

        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="cnot")]
        private static extern Int64 _CNOT(ulong simId, uint idxControl, uint idxTarget);

        public static void CNOT(ulong simId, Qubit control, Qubit target)
        {
            LogCall("cnot");
            CheckCall(_CNOT(simId, (uint)control.Id, (uint)target.Id));
        }


        [DllImport(DLL_NAME, ExactSpelling=true, CallingConvention=CallingConvention.Cdecl, EntryPoint="m")]
        private static extern Int64 _M(ulong simId, uint idx, out uint result);

        public static Result M(ulong simId, Qubit q)
        {
            LogCall("m");
            CheckCall(_M(simId, (uint)q.Id, out var result));
            return result == 1 ? Result.One : Result.Zero;
        }

    }
}
