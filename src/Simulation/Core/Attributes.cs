// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;


namespace Microsoft.Quantum.Simulation.Core
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public class SourceLocationAttribute : Attribute
    { 
        public string SourceFile { get; }
        public OperationFunctor SpecializationKind { get; }
        public int StartLine { get; }
        public int EndLine { get; }

        public SourceLocationAttribute(string sourceFile, OperationFunctor kind, int startLine, int endLine)
        {
            this.SourceFile = sourceFile;
            this.SpecializationKind = kind;
            this.StartLine = startLine;
            this.EndLine = endLine;
        }
    }

    [AttributeUsage(AttributeTargets.Assembly, AllowMultiple = true)]
    public class CallableDeclarationAttribute : Attribute
    {
        public string Value { get; }

        public CallableDeclarationAttribute(string serializedHeader)
        {
            this.Value = serializedHeader != null 
                ? serializedHeader
                : throw new ArgumentNullException(nameof(serializedHeader));
        }
    }

    [AttributeUsage(AttributeTargets.Assembly, AllowMultiple = true)]
    public class SpecializationDeclarationAttribute : Attribute
    {
        public string Value { get; }

        public SpecializationDeclarationAttribute(string serializedHeader)
        {
            this.Value = serializedHeader != null
                ? serializedHeader
                : throw new ArgumentNullException(nameof(serializedHeader));
        }
    }

    [AttributeUsage(AttributeTargets.Assembly, AllowMultiple = true)]
    public class TypeDeclarationAttribute : Attribute
    {
        public string Value { get; }

        public TypeDeclarationAttribute(string serializedHeader)
        {
            this.Value = serializedHeader != null
                ? serializedHeader
                : throw new ArgumentNullException(nameof(serializedHeader));
        }
    }
}