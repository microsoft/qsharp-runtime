// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Xunit;

namespace interop_tests
{
    public class BasicInterop
    {
        public const string QDK_DLL_NAME = "qdk.dll";


        [DllImport(QDK_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl,
            EntryPoint = "QAPI_CreateContext_Toffoli")]
        private static extern unsafe UInt64 CreateContext_Toffoli();

        [DllImport(QDK_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl,
            EntryPoint = "QAPI_CreateContext_Fullstate")]
        private static extern unsafe UInt64 CreateContext_Fullstate();

        [DllImport(QDK_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl,
            EntryPoint = "QAPI_DestroyContext")]
        private static extern UInt64 DestroyContext(UInt64 context);

        [DllImport(QDK_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl,
            EntryPoint = "QAPI_AllocateQubit")]
        private static extern UInt64 AllocateQubit(UInt64 context);

        [DllImport(QDK_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl,
            EntryPoint = "QAPI_X")]
        private static extern void X(UInt64 context, UInt64 qubit);

        [DllImport(QDK_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl,
            EntryPoint = "QAPI_M")]
        private static extern UInt64 M(UInt64 context, UInt64 qubit);

        [DllImport(QDK_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl,
            EntryPoint = "QAPI_GetResultValue")]
        private static extern int GetResultValue(UInt64 context, UInt64 result);

        // no asserts in this test, it passes if doesn't crash
        [Fact]
        public void ContextManagement()
        {
            unsafe
            {
                UInt64 context1 = CreateContext_Toffoli();
                UInt64 context2 = CreateContext_Toffoli();
                DestroyContext(context1);
                UInt64 context3 = CreateContext_Fullstate();
                DestroyContext(context3);
                DestroyContext(context2);

                UInt64 context4 = CreateContext_Toffoli();
                DestroyContext(context4);
            }
        }

        [Fact]
        public void ToffoliContext()
        {
            unsafe
            {
                UInt64 context = CreateContext_Toffoli();

                UInt64 q = AllocateQubit(context);
                X(context, q);
                UInt64 r = M(context, q);
                Assert.Equal(1, GetResultValue(context, r));

                DestroyContext(context);
            }
        }

        [Fact]
        public void FullstateContext()
        {
            unsafe
            {
                UInt64 context = CreateContext_Fullstate();

                UInt64 q = AllocateQubit(context);
                X(context, q);
                UInt64 r = M(context, q);
                Assert.Equal(1, GetResultValue(context, r));

                DestroyContext(context);
            }
        }
    }
}
