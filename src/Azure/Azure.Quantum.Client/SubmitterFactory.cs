﻿// Copyright (c) Microsoft Corporation.
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
    using System.Text.RegularExpressions;
    using Microsoft.Quantum.Runtime.Submitters;

    /// <summary>
    /// Creates Azure Quantum submitters for specific targets.
    /// </summary>
    public static class SubmitterFactory
    {
        /// <summary>
        /// Information about each supported QIR submitter.
        /// </summary>
        private static readonly ImmutableList<SubmitterInfo> QirSubmitters = ImmutableList.Create(
            new SubmitterInfo(
                new Regex(@"\Amicrosoft\.simulator\.([\w-_]+\.)*[\w-_]+\z"),
                "Microsoft.Quantum.Providers.Targets.MicrosoftSimulatorSubmitter, Microsoft.Quantum.Providers.Core",
                "QirSubmitter",
                ImmutableArray.Create("FullComputation")),
            new SubmitterInfo(
                new Regex(@"\Amicrosoft\.((?!simulator\.)[\w-_]+\.)*[\w-_]+\z"), // does not match microsoft.simulator.*, but matches any other microsoft.*
                "Microsoft.Quantum.Providers.Targets.MicrosoftQuantumSubmitter, Microsoft.Quantum.Providers.Core",
                "QirSubmitter",
                ImmutableArray.Create("FullComputation")),
            new SubmitterInfo(
                new Regex(@"\Aquantinuum\.([\w-_]+\.)*[\w-_]+\z"),
                "Microsoft.Quantum.Providers.Quantinuum.Targets.QuantinuumQirSubmitter, Microsoft.Quantum.Providers.Honeywell",
                "QirSubmitter",
                ImmutableArray.Create("AdaptiveExecution", "BasicExecution")), // support for BasicMeasurementFeedback goes via the QSharpSubmitter
            new SubmitterInfo(
                new Regex(@"\Aqci\.([\w-_]+\.)*[\w-_]+\z"),
                "Microsoft.Quantum.Providers.QCI.Targets.QCIQirSubmitter, Microsoft.Quantum.Providers.QCI",
                "QirSubmitter",
                ImmutableArray.Create("AdaptiveExecution", "BasicExecution")),
            new SubmitterInfo(
                new Regex(@"\Arigetti\.([\w-_]+\.)*[\w-_]+\z"),
                "Microsoft.Quantum.Providers.Rigetti.Targets.RigettiQirSubmitter, Microsoft.Quantum.Providers.Rigetti",
                "QirSubmitter",
                ImmutableArray.Create("BasicExecution")));

        private static readonly ImmutableList<SubmitterInfo> QirPayloadGenerators = ImmutableList.Create(
            new SubmitterInfo(
                new Regex(@"\Amicrosoft\.simulator\.([\w]+\.)*[\w]+\z"),
                "Microsoft.Quantum.Providers.Targets.MicrosoftSimulatorSubmitter, Microsoft.Quantum.Providers.Core",
                "QirPayloadGenerator",
                ImmutableArray.Create("FullComputation")),
            new SubmitterInfo(
                new Regex(@"\Amicrosoft\.((?!simulator\.)[\w-_]+\.)*[\w-_]+\z"), // does not match microsoft.simulator.*, but matches any other microsoft.*
                "Microsoft.Quantum.Providers.Targets.MicrosoftQuantumSubmitter, Microsoft.Quantum.Providers.Core",
                "QirPayloadGenerator",
                ImmutableArray.Create("FullComputation"))
            );

        /// <summary>
        /// Information about each supported Q# submitter.
        /// </summary>
        private static readonly ImmutableList<SubmitterInfo> QSharpSubmitters = ImmutableList<SubmitterInfo>.Empty;

        /// <summary>
        /// Returns a QIR submitter that can generate the payload to Azure offline.
        /// </summary>
        /// <param name="target">The name of the execution target.</param>
        /// <returns>A QIR submitter.</returns>
        public static IQirSubmitter? QirPayloadGenerator(string target) =>
            AzurePayloadGenerator(QirPayloadGenerators, target);

        /// <summary>
        /// Returns a QIR submitter.
        /// </summary>
        /// <param name="target">The name of the execution target.</param>
        /// <param name="workspace">The workspace used to manage jobs.</param>
        /// <param name="storageConnection">The connection string for the storage account.</param>
        /// <param name="targetCapability">The target capability.</param>
        /// <returns>A QIR submitter.</returns>
        public static IQirSubmitter? QirSubmitter(string target, IWorkspace workspace, string? storageConnection, string targetCapability) =>
            Submitter<IQirSubmitter>(QirSubmitters, target, workspace, storageConnection, targetCapability);

        public static IQirSubmitter? QirSubmitterFromConfigFile(
            string target, FileInfo configFile, IWorkspace workspace, string? storageConnection)
        {
            var constructorType = QdkType(
                "Microsoft.Quantum.Providers.Targets.GenericQirSubmitter, Microsoft.Quantum.Providers.Core");
            var constructorName = "QirSubmitter";
            var args = new object?[] { target, configFile, workspace, storageConnection };
            return (IQirSubmitter)constructorType.InvokeMember(
                constructorName, BindingFlags.InvokeMethod, Type.DefaultBinder, null, args);
        }

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
        /// Returns an instance of a QIR submitter that can generate payload for Azure offline from the given list that matches the target.
        /// </summary>
        /// <param name="submitters">Information about each submitter.</param>
        /// <param name="target">The name of the execution target.</param>
        /// <returns>The QIR submitter instance.</returns>
        private static IQirSubmitter? AzurePayloadGenerator(IEnumerable<SubmitterInfo> submitters, string target)
        {
            var submitter = submitters.FirstOrDefault(s => s.TargetPattern.IsMatch(target));
            if (submitter is null)
            {
                return null;
            }

            var constructorInfo = ConstructorInfo(submitter);
            (var constructorName, var constructorType) = constructorInfo;
            var args = new object?[] { target };
            return (IQirSubmitter)constructorType.InvokeMember(
                constructorName, BindingFlags.InvokeMethod, Type.DefaultBinder, null, args);
        }

        /// <summary>
        /// Returns an instance of a submitter from the given list that matches the target.
        /// </summary>
        /// <param name="submitters">Information about each submitter.</param>
        /// <param name="target">The name of the execution target.</param>
        /// <param name="workspace">The workspace used to manage jobs.</param>
        /// <param name="storageConnection">The connection string for the storage account.</param>
        /// <param name="targetCapability">The target capability.</param>
        /// <typeparam name="T">The type of the submitter interface.</typeparam>
        /// <returns>The submitter instance.</returns>
        private static T? Submitter<T>(
            IEnumerable<SubmitterInfo> submitters, string target, IWorkspace workspace, string? storageConnection, string targetCapability = "")
            where T : class
        {
            var submitter = submitters.FirstOrDefault(s => s.TargetPattern.IsMatch(target));
            if (submitter is null)
            {
                return null;
            }

            var supportedTargetCapabilities = submitter.SupportedTargetCapabilities.Select(c => c.ToLower()).ToImmutableHashSet();
            if (!supportedTargetCapabilities.Contains(targetCapability.ToLower()))
            {
                return null;
            }

            var constructorInfo = ConstructorInfo(submitter);
            (var constructorName, var constructorType) = constructorInfo;
            var args = new object?[] { target, workspace, storageConnection };
            return (T)constructorType.InvokeMember(
                constructorName, BindingFlags.InvokeMethod, Type.DefaultBinder, null, args);
        }

        /// <summary>
        /// Returns the name and the type of a constructor that matches the target.
        /// </summary>
        /// <param name="submitter">Information about the submitter.</param>
        /// <returns>A name and type tuple.</returns>
        private static (string Name, Type Type) ConstructorInfo(SubmitterInfo submitter)
        {
            var name = submitter.MethodName;
            var type = QdkType(submitter.TypeName);
            return (name, type);
        }

        /// <summary>
        /// Returns a type from a QDK assembly given its type name.
        /// </summary>
        /// <param name="name">The fully-qualified or assembly-qualified type name.</param>
        /// <returns>The type.</returns>
        private static Type QdkType(string name)
        {
            var version = Assembly.GetExecutingAssembly().GetName().Version;
            var strongName = $"{name}, Version={version}, Culture=neutral, PublicKeyToken=40866b40fd95c7f5";
            return Type.GetType(strongName, true);
        }

        /// <summary>
        /// Information about a submitter.
        /// </summary>
        private class SubmitterInfo
        {
            /// <summary>
            /// Initializes a new instance of the <see cref="SubmitterInfo"/> class.
            /// </summary>
            /// <param name="targetPattern">The pattern for targets supported by the submitter.</param>
            /// <param name="typeName">The fully-qualified or assembly-qualified name of the submitter type.</param>
            /// <param name="methodName">The name of the static factory method.</param>
            /// <param name="requiresTargetCapability">The flag telling if the target capability is required by the target.</param>
            public SubmitterInfo(
                Regex targetPattern, string typeName, string methodName, IEnumerable<string>? supportedTargetCapabilities = null) =>
                (TargetPattern, TypeName, MethodName, SupportedTargetCapabilities) =
                    (targetPattern, typeName, methodName, supportedTargetCapabilities?.ToImmutableArray() ?? ImmutableArray<string>.Empty);

            /// <summary>
            /// The pattern for targets supported by the submitter.
            /// </summary>
            public Regex TargetPattern { get; }

            /// <summary>
            /// The fully-qualified or assembly-qualified name of the submitter type.
            /// </summary>
            public string TypeName { get; }

            /// <summary>
            /// The name of the static factory method.
            /// </summary>
            public string MethodName { get; }

            /// <summary>
            /// Flag telling if the target requires the target capability.
            /// </summary>
            public IReadOnlyList<string> SupportedTargetCapabilities { get; }
        }
    }
}
