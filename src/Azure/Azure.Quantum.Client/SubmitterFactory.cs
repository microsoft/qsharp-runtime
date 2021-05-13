// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Azure.Quantum
{
    using System;
    using System.Collections.Generic;
    using System.Collections.Immutable;
    using System.IO;
    using System.Linq;
    using System.Reflection;
    using Microsoft.Quantum.Runtime.Submitters;

    /// <summary>
    /// Creates Azure Quantum submitters for specific targets.
    /// </summary>
    public static class SubmitterFactory
    {
        /// <summary>
        /// Information about each supported QIR submitter.
        /// </summary>
        private static readonly ImmutableList<SubmitterInfo> QirSubmitters = ImmutableList<SubmitterInfo>.Empty;

        /// <summary>
        /// Information about each supported Q# submitter.
        /// </summary>
        private static readonly ImmutableList<SubmitterInfo> QSharpSubmitters = ImmutableList<SubmitterInfo>.Empty;

        /// <summary>
        /// Returns a QIR submitter.
        /// </summary>
        /// <param name="target">The name of the execution target.</param>
        /// <param name="workspace">The workspace used to manage jobs.</param>
        /// <param name="storageConnection">The connection string for the storage account.</param>
        /// <returns>A QIR submitter.</returns>
        public static IQirSubmitter? QirSubmitter(string target, IWorkspace workspace, string? storageConnection) =>
            Submitter<IQirSubmitter>(QirSubmitters, target, workspace, storageConnection);

        /// <summary>
        /// Returns a Q# submitter.
        /// </summary>
        /// <param name="target">The name of the execution target.</param>
        /// <param name="workspace">The workspace used to manage jobs.</param>
        /// <param name="storageConnection">The connection string for the storage account.</param>
        /// <returns>A Q# submitter.</returns>
        public static IQSharpSubmitter? QSharpSubmitter(
            string target, IWorkspace workspace, string? storageConnection) =>
            Submitter<IQSharpSubmitter>(QSharpSubmitters, target, workspace, storageConnection);

        /// <summary>
        /// Returns an instance of a submitter from the given list that matches the target.
        /// </summary>
        /// <param name="submitters">Information about each submitter.</param>
        /// <param name="target">The name of the execution target.</param>
        /// <param name="workspace">The workspace used to manage jobs.</param>
        /// <param name="storageConnection">The connection string for the storage account.</param>
        /// <typeparam name="T">The type of the submitter interface.</typeparam>
        /// <returns>The submitter instance.</returns>
        private static T? Submitter<T>(
            IEnumerable<SubmitterInfo> submitters, string target, IWorkspace workspace, string? storageConnection)
            where T : class
        {
            var submitter = submitters.FirstOrDefault(s => target.StartsWith(s.TargetPrefix + "."));
            if (submitter is null)
            {
                return null;
            }

            var type = QdkType(submitter.TypeName);
            return (T)Activator.CreateInstance(type, target, workspace, storageConnection);
        }

        /// <summary>
        /// Returns a type from a QDK assembly given its type name.
        /// </summary>
        /// <param name="name">The fully-qualified or assembly-qualified type name.</param>
        /// <returns>The type.</returns>
        private static Type QdkType(string name)
        {
            try
            {
                var version = Assembly.GetExecutingAssembly().GetName().Version;
                var signedName = $"{name}, Version={version}, Culture=neutral, PublicKeyToken=40866b40fd95c7f5";
                return Type.GetType(signedName, true);
            }
            catch (FileLoadException)
            {
                return Type.GetType(name, true);
            }
        }

        /// <summary>
        /// Information about a submitter.
        /// </summary>
        private class SubmitterInfo
        {
            /// <summary>
            /// Initializes a new instance of the <see cref="SubmitterInfo"/> class.
            /// </summary>
            /// <param name="targetPrefix">The prefix for targets supported by the submitter.</param>
            /// <param name="typeName">The fully-qualified or assembly-qualified name of the submitter type.</param>
            public SubmitterInfo(string targetPrefix, string typeName) =>
                (TargetPrefix, TypeName) = (targetPrefix, typeName);

            /// <summary>
            /// The prefix for targets supported by the submitter.
            /// </summary>
            public string TargetPrefix { get; }

            /// <summary>
            /// The fully-qualified or assembly-qualified name of the submitter type.
            /// </summary>
            public string TypeName { get; }
        }
    }
}
