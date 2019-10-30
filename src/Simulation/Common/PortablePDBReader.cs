// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

namespace Microsoft.Quantum.Simulation.Common
{
    using System.Collections.Generic;
    using System.Reflection.Metadata;
    using System;
    using System.IO;
    using System.IO.Compression;
    using System.Text;
    using Newtonsoft.Json.Linq;
    using System.Text.RegularExpressions;
    using Microsoft.Quantum.Simulation.Core;

    // Based on https://github.com/microsoft/BPerf/blob/master/WebViewer/Microsoft.BPerf.SymbolicInformation.ProgramDatabase/PortablePdbSymbolReader.cs
    class PortablePdbSymbolReader
    {
        private static readonly Guid SourceLink = new Guid("CC110556-A091-4D38-9FEC-25AB9A351A6A");

        private static readonly Guid EmbeddedSource = new Guid("0E8A571B-6926-466E-B4AD-8AB04611F5FE");

        public static Dictionary<string, string> GetEmbeddedFiles(string pdbFilePath)
        {
            Dictionary<string, string> embeddedFiles = new Dictionary<string, string>();

            using (FileStream stream = File.OpenRead(pdbFilePath))
            using (MetadataReaderProvider metadataReaderProvider = MetadataReaderProvider.FromPortablePdbStream(stream))
            {
                MetadataReader metadataReader = metadataReaderProvider.GetMetadataReader();
                CustomDebugInformationHandleCollection customDebugInformationHandles = metadataReader.CustomDebugInformation;
                foreach (var customDebugInformationHandle in customDebugInformationHandles)
                {
                    CustomDebugInformation customDebugInformation = metadataReader.GetCustomDebugInformation(customDebugInformationHandle);
                    if (metadataReader.GetGuid(customDebugInformation.Kind) == EmbeddedSource)
                    {
                        byte[] embeddedSource = metadataReader.GetBlobBytes(customDebugInformation.Value);
                        Int32 uncompressedSourceFileSize = BitConverter.ToInt32(embeddedSource, 0);
                        if (uncompressedSourceFileSize != 0)
                        {
                            Document document = metadataReader.GetDocument((DocumentHandle)customDebugInformation.Parent);
                            string sourceFileName = System.IO.Path.GetFullPath(metadataReader.GetString(document.Name));

                            // See https://github.com/dotnet/corefx/blob/master/src/System.Reflection.Metadata/specs/PortablePdb-Metadata.md#embedded-source-c-and-vb-compilers   
                            // Decompress embedded source      
                            MemoryStream memoryStream =
                                new MemoryStream(embeddedSource, sizeof(Int32), embeddedSource.Length - sizeof(Int32));

                            using (DeflateStream decompressionStream = new DeflateStream(memoryStream, CompressionMode.Decompress))
                            {
                                MemoryStream decompressed = new MemoryStream(new byte[uncompressedSourceFileSize], true);
                                decompressionStream.CopyTo(decompressed);
                                embeddedFiles.Add(sourceFileName, Encoding.UTF8.GetString(decompressed.ToArray()));
                            }
                        }
                    }
                }
            }
            return embeddedFiles;
        }

        public static string GetSourceLinkString(string pdbFilePath)
        {
            using (FileStream stream = File.OpenRead(pdbFilePath))
            {
                using (MetadataReaderProvider metadataReaderProvider = MetadataReaderProvider.FromPortablePdbStream(stream))
                {
                    MetadataReader metadataReader = metadataReaderProvider.GetMetadataReader();
                    CustomDebugInformationHandleCollection customDebugInformationHandles = metadataReader.CustomDebugInformation;
                    foreach (var customDebugInformationHandle in customDebugInformationHandles)
                    {
                        CustomDebugInformation customDebugInformation = metadataReader.GetCustomDebugInformation(customDebugInformationHandle);

                        if (metadataReader.GetGuid(customDebugInformation.Kind) == SourceLink)
                        {
                            return Encoding.UTF8.GetString(metadataReader.GetBlobBytes(customDebugInformation.Value));
                        }
                    }
                }
            }
            return null;
        }

        public static Tuple<string, string>[] ParseSourceLinkString(string SourceLinkString)
        {
            if (SourceLinkString == null) return null;
            List<Tuple<string, string>> pairs = new List<Tuple<string, string>>();
            JObject jsonResponse = JObject.Parse(SourceLinkString);
            JObject document = JObject.Parse(jsonResponse["documents"].ToString());
            foreach (JProperty property in document.Properties())
            {
                string fullPath = System.IO.Path.GetFullPath(property.Name.Replace("*", ""));
                pairs.Add(new Tuple<string, string>(fullPath, property.Value.ToObject<string>().Replace("*", "")));
            }
            return pairs.ToArray();
        }

        public static string TryFormatGitHubUrl(Tuple<string,string> rawUrl, int lineNumber)
        {
            if (rawUrl == null)
                return null;

            string result = null;
            if (rawUrl.Item1.StartsWith(@"https://raw.githubusercontent.com"))
            {
                result = Regex.Replace(rawUrl.Item1, "[a-f0-9]+" + Regex.Escape("/") + "$", (Match m) => { return @"blob/" + m.Value; });
                result = result.Replace(@"https://raw.githubusercontent.com", @"https://github.com");
                result += rawUrl.Item2;
                result += $"#L{lineNumber}";
            }
            else
            {
                result = rawUrl.Item1 + rawUrl.Item2;
            }
            return result;
        }

        public static string GetPDBLocation(ICallable callable)
        {
            try
            {
                string filename = System.IO.Path.ChangeExtension(callable.UnwrapCallable().GetType().Assembly.Location, ".pdb");
                if( File.Exists(filename) )
                {
                    return filename;
                }
                else
                {
                    return null;
                }
            }
            catch(NotSupportedException)
            {
                return null;
            }
        }
    }

    public static class PortablePDBPathRemappingCache
    {
        [ThreadStatic]
        private static Dictionary<string, Tuple<string, string>[]> pdbLocationToPathRemapping = null;

        public static Tuple<string, string>[] GetRemappingInfromation(string pdbLocation)
        {
            if (pdbLocationToPathRemapping == null)
            {
                pdbLocationToPathRemapping = new Dictionary<string, Tuple<string, string>[]>();
            }

            Tuple<string, string>[] remappings;
            if (pdbLocationToPathRemapping.TryGetValue(pdbLocation, out remappings))
            {
                return remappings;
            }
            else
            {
                try
                {
                    string sourceLinkString = PortablePdbSymbolReader.GetSourceLinkString(pdbLocation);
                    remappings = PortablePdbSymbolReader.ParseSourceLinkString(sourceLinkString);
                }
                finally
                {
                    pdbLocationToPathRemapping.Add(pdbLocation, remappings);
                }
                return remappings;
            }
        }

        /// <summary>
        /// Tuple of strings such that full URL consists of their concatenation.
        /// First part of URL is URL root for all files in PDB and second part is relative path to given file.
        /// </summary>
        public static Tuple<string,string> TryGetFileUrl(string pdbLocation, string fileName )
        {
            if (fileName == null) return null;

            string prefix = null;
            string rest = null;

            Tuple<string, string>[] fileCorrespondence = GetRemappingInfromation(pdbLocation);
            if (fileCorrespondence != null)
            {
                foreach (Tuple<string, string> replacement in fileCorrespondence)
                {
                    if (fileName.StartsWith(replacement.Item1))
                    {
                        rest = fileName.Replace(replacement.Item1, "");
                        prefix = replacement.Item2;
                        if (prefix.Contains(@"/") && rest.Contains(@"\"))
                        {
                            rest = rest.Replace(@"\", @"/");
                        }
                        break;
                    }
                }
            }
            return new Tuple<string, string>(prefix,rest);
        }
    }

    public static class PortablePDBEmbeddedFilesCache
    {
        public const string lineMarkPrefix = ">>>";
        public const int lineNumberPaddingWidth = 6;

        [ThreadStatic]
        private static Dictionary<string, Dictionary<string, string>> pdbLocationToEmbeddedFiles = null;

        public static Dictionary<string, string> GetEmbeddedFiles(string pdbLocation)
        {
            if (pdbLocationToEmbeddedFiles == null)
            {
                pdbLocationToEmbeddedFiles = new Dictionary<string, Dictionary<string, string>>();
            }

            Dictionary<string, string> embeddedFilesFromPath = null;
            if (pdbLocationToEmbeddedFiles.TryGetValue(pdbLocation, out embeddedFilesFromPath))
            {
                return embeddedFilesFromPath;
            }
            else
            {
                try
                {
                    embeddedFilesFromPath = PortablePdbSymbolReader.GetEmbeddedFiles(pdbLocation);
                }
                finally
                {
                    pdbLocationToEmbeddedFiles.Add(pdbLocation, embeddedFilesFromPath);
                }
                return embeddedFilesFromPath;
            }
        }

        public static string GetEmbeddedFileRange( string pdbLocation, string fullName, int lineStart, int lineEnd, bool showLineNumbers = false, int markedLine = -1, string markPrefix = lineMarkPrefix)
        {
            Dictionary<string, string> fileNameToFileSourceText = GetEmbeddedFiles(pdbLocation);
            if (fileNameToFileSourceText == null) return null;
            string source = fileNameToFileSourceText.GetValueOrDefault(fullName);
            if (source == null) return null;

            StringBuilder builder = new StringBuilder();
            using (StringReader reader = new StringReader(source))
            {
                int lineNumber = 0;

                // first go through text source till we reach lineStart
                while ( reader.Peek() != -1 )
                {
                    lineNumber++;
                    if (lineNumber == lineStart)
                        break;
                    reader.ReadLine();
                }

                while (reader.Peek() != -1)
                {
                    string currentLine = reader.ReadLine();
                    if (showLineNumbers)
                    {
                        builder.Append($"{lineNumber} ".PadLeft(lineNumberPaddingWidth));
                    }
                    if (lineNumber == markedLine)
                    {
                        builder.Append(markPrefix);
                    }
                    builder.AppendLine(currentLine);

                    lineNumber++;
                    if (lineNumber == lineEnd)
                        break;
                }
            }
            return builder.ToString();
        }
    }
}