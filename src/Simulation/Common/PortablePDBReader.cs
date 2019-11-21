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
    using System.Linq;

    public class CompressedSourceFile
    {
        private readonly byte[] compressedSource = null;
        private string decompressedSource = null;

        public CompressedSourceFile(byte[] compressedSource)
        {
            this.compressedSource = compressedSource;
        }

        public override string ToString()
        {
            if (decompressedSource == null)
            {
                using MemoryStream memoryStream = new MemoryStream(compressedSource, sizeof(Int32), compressedSource.Length - sizeof(Int32));
                using DeflateStream decompressionStream = new DeflateStream(memoryStream, CompressionMode.Decompress);
                Int32 uncompressedSourceFileSize = BitConverter.ToInt32(compressedSource, 0);
                MemoryStream decompressed = new MemoryStream(new byte[uncompressedSourceFileSize], true);
                decompressionStream.CopyTo(decompressed);
                decompressedSource = Encoding.UTF8.GetString(decompressed.ToArray());
            }

            return decompressedSource;
        }
    }

    /// <summary>
    /// Class for source link information corresponding to SourceLink schema 
    /// https://github.com/dotnet/designs/blob/master/accepted/diagnostics/source-link.md#source-link-json-schema
    /// </summary>
    [Serializable]
    public class SourceLinkPathRemapping
    {
        public Dictionary<string, string> documents;

        /// <summary>
        /// Collection of patterns present within documents 
        /// </summary>
        /// <remarks>
        /// For example, documents can contain patterns with *, like shown below
        /// <code>
        /// { "documents": { "C:\\src\\CodeFormatter\\*": "https://raw.githubusercontent.com/dotnet/codeformatter/bcc51178e1a82fb2edaf47285f6e577989a7333f/*" },}
        /// </code>
        /// </remarks>
        [Newtonsoft.Json.JsonIgnore]
        private ValueTuple<string, string>[] patterns;

        // Collection of patterns present within documents 
        [Newtonsoft.Json.JsonIgnore]
        public ValueTuple<string, string>[] Patterns
        {
            get
            {
                if (this.patterns == null)
                {
                    List<ValueTuple<string, string>> patterns = new List<ValueTuple<string, string>>();
                    foreach (KeyValuePair<string, string> keyValuePair in documents)
                    {
                        if (keyValuePair.Key.EndsWith("*"))
                        {
                            patterns.Add(new ValueTuple<string, string>(keyValuePair.Key.Replace("*", ""), keyValuePair.Value.Replace("*", "")));
                        }
                    }
                    this.patterns = patterns.ToArray();
                }
                return this.patterns;
            }
        }
    }

    /// <summary>
    /// Utility class for extracting source file text and source location from PortablePDB meta-data.
    /// </summary>
    /// <remarks>
    /// Based on https://github.com/microsoft/BPerf/blob/master/WebViewer/Microsoft.BPerf.SymbolicInformation.ProgramDatabase/PortablePdbSymbolReader.cs
    /// </remarks>
    public class PortablePdbSymbolReader
    {
        /// <summary> SourceLink GUID is a part of PortablePDB meta-data specification https://github.com/dotnet/corefx/blob/master/src/System.Reflection.Metadata/specs/PortablePdb-Metadata.md#SourceLink </summary>
        private static readonly Guid SourceLink = new Guid("CC110556-A091-4D38-9FEC-25AB9A351A6A");

        /// <summary> EmbeddedSource GUID is a part of PortablePDB meta-data specification https://github.com/dotnet/corefx/blob/master/src/System.Reflection.Metadata/specs/PortablePdb-Metadata.md#embedded-source-c-and-vb-compilers </summary>
        private static readonly Guid EmbeddedSource = new Guid("0E8A571B-6926-466E-B4AD-8AB04611F5FE");

        /// <summary>
        /// Unpacks all files stored in a PortablePDB meta-data. The key in the dictionary is the location of a source file 
        /// on the build machine. The value is the content of the source file itself.
        /// The function will throw an exception if PortablePDB file is not found or anything else went wrong.
        /// </summary>
        /// <param name="pdbFilePath">Path to PortablePDB file to load source files from.</param>
        public static Dictionary<string, CompressedSourceFile> GetEmbeddedFiles(string pdbFilePath)
        {
            Dictionary<string, CompressedSourceFile> embeddedFiles = new Dictionary<string, CompressedSourceFile>();

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
                            embeddedFiles.Add(sourceFileName, new CompressedSourceFile(embeddedSource));
                        }
                    }
                }
            }
            return embeddedFiles;
        }

        /// <summary>
        /// Returns SourceLink information, that is JSON string with schema described at https://github.com/dotnet/designs/blob/master/accepted/diagnostics/source-link.md#source-link-json-schema
        /// stored in PortablePDB.
        /// The function will throw an exception if PortablePDB file is not found or anything else went wrong.
        /// </summary>
        /// <param name="pdbFilePath">Path to PortablePDB file </param>
        public static SourceLinkPathRemapping GetSourceLinkString(string pdbFilePath)
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
                            string jsonString = Encoding.UTF8.GetString(metadataReader.GetBlobBytes(customDebugInformation.Value));
                            return Newtonsoft.Json.JsonConvert.DeserializeObject<SourceLinkPathRemapping>(jsonString);
                        }
                    }
                }
            }
            return null;
        }

        /// <summary>
        /// Includes line number into GitHub URL with source location
        /// </summary>
        /// <param name="rawUrl">Tuple of baseURL describing the repository and commit and relative path to the file</param>
        /// <param name="lineNumber">Line number to include into URL</param>
        /// <returns>GitHub URL for the file with the line number</returns>
        public static string TryFormatGitHubUrl(string rawUrl, int lineNumber)
        {
            if (rawUrl == null)
                return null;

            string result = rawUrl;
            if (rawUrl.StartsWith(@"https://raw.githubusercontent.com"))
            {
                // Our goal is to replace raw GitHub URL, for example something like:
                // https://raw.githubusercontent.com/microsoft/qsharp-runtime/af6262c05522d645d0a0952272443e84eeab677a/src/Xunit/TestCaseDiscoverer.cs
                // By a permanent link GitHub URL that includes line number
                // https://github.com/microsoft/qsharp-runtime/blob/af6262c05522d645d0a0952272443e84eeab677a/src/Xunit/TestCaseDiscoverer.cs#L13
                // To make sure that when a user clicks the link to GitHub the line number is highlighted 

                MatchCollection sha1StringMatches = Regex.Matches(rawUrl, Regex.Escape("/") + "[a-f0-9]{40}" + Regex.Escape("/")); // SHA1 part of the URL is 40 symbols long
                Match sha1StringMatch = null;

                if (sha1StringMatches.Count == 1)
                {
                    sha1StringMatch = sha1StringMatches[0];
                }
                else // there are several sub-strings of URL that can potentially be a sha1 hash, we fall-back to original URL in this case
                {
                    return rawUrl;
                }

                if (sha1StringMatch.Success)
                {
                    int startPosition = sha1StringMatch.Index;
                    string sha1String = sha1StringMatch.Value; //should be "/af6262c05522d645d0a0952272443e84eeab677a/"
                    string urlAndRepositoryPath = rawUrl.Substring(0, startPosition); // should be "https://raw.githubusercontent.com/microsoft/qsharp-runtime"
                    string relativePath = rawUrl.Substring(startPosition + sha1String.Length); // should be "src/Xunit/TestCaseDiscoverer.cs"
                    return $"{urlAndRepositoryPath.Replace(@"https://raw.githubusercontent.com", @"https://github.com")}{"/blob"}{sha1String}{relativePath}#L{lineNumber}";
                }
            }
            return result;
        }

        /// <summary>
        /// Returns location of PortablePDB file with the source information for a given callable.
        /// Returns null if PortablePDB cannot be found.
        /// </summary>
        public static string GetPDBLocation(ICallable callable)
        {
            try
            {
                string filename = System.IO.Path.ChangeExtension(callable.UnwrapCallable().GetType().Assembly.Location, ".pdb");
                if (File.Exists(filename))
                {
                    return filename;
                }
                else
                {
                    return null;
                }
            }
            catch (NotSupportedException)
            {
                return null;
            }
        }
    }

    /// <summary>
    /// Caches path remapping from build machine to URL per location of PDB file.
    /// </summary>
    public static class PortablePDBPathRemappingCache
    {
        /// <summary>
        /// Key is the location of a PortablePDB file on a current machine
        /// </summary>
        // ThreadStaticAttribute makes sure that the cache is thread safe
        [ThreadStatic]
        private static Dictionary<string, SourceLinkPathRemapping> pdbLocationToPathRemapping = null;

        public static SourceLinkPathRemapping GetRemappingInfromation(string pdbLocation)
        {
            if (pdbLocationToPathRemapping == null)
            {
                pdbLocationToPathRemapping = new Dictionary<string, SourceLinkPathRemapping>();
            }

            SourceLinkPathRemapping remappings;
            if (pdbLocationToPathRemapping.TryGetValue(pdbLocation, out remappings))
            {
                return remappings;
            }
            else
            {
                try
                {
                    remappings = PortablePdbSymbolReader.GetSourceLinkString(pdbLocation);
                }
                finally
                {
                    pdbLocationToPathRemapping.Add(pdbLocation, remappings);
                }
                return remappings;
            }
        }

        /// <summary>
        /// Finds URL for given path on a build machine.
        /// </summary>
        public static string TryGetFileUrl(string pdbLocation, string fileName)
        {
            if (fileName == null) return null;

            SourceLinkPathRemapping remapping = GetRemappingInfromation(pdbLocation);
            if (remapping != null)
            {
                if (remapping.documents.ContainsKey(fileName))
                {
                    return remapping.documents[fileName];
                }

                if (remapping.Patterns != null)
                {
                    foreach (ValueTuple<string, string> replacement in remapping.Patterns)
                    {
                        if (fileName.StartsWith(replacement.Item1))
                        {
                            string rest = fileName.Replace(replacement.Item1, "");
                            string prefix = replacement.Item2;
                            // Replace Windows-style separators by Web/Linux style 
                            if (prefix.Contains(@"/") && rest.Contains(@"\"))
                            {
                                rest = rest.Replace(@"\", @"/");
                            }
                            return prefix + rest;
                        }
                    }
                }
            }
            return null;
        }
    }

    /// <summary>
    /// Caches sources of source files per location of PDB file indexed by source file path
    /// </summary>
    public static class PortablePDBEmbeddedFilesCache
    {
        public const string lineMarkPrefix = ">>>";
        public const int lineNumberPaddingWidth = 6;

        /// <summary>
        /// Key is the location of a PortablePDB file on a current machine.
        /// Value is the dictionary returned by <see cref="PortablePdbSymbolReader.GetEmbeddedFiles(string)"/>
        /// called with a given Key.
        /// </summary>
        // ThreadStaticAttribute makes sure that the cache is thread safe
        [ThreadStatic]
        private static Dictionary<string, Dictionary<string, CompressedSourceFile>> pdbLocationToEmbeddedFiles = null;

        /// <summary>
        /// Returns cached result of calling <see cref="PortablePdbSymbolReader.GetEmbeddedFiles(string)"/>
        /// </summary>
        public static Dictionary<string, CompressedSourceFile> GetEmbeddedFiles(string pdbLocation)
        {
            if (pdbLocationToEmbeddedFiles == null)
            {
                pdbLocationToEmbeddedFiles = new Dictionary<string, Dictionary<string, CompressedSourceFile>>();
            }

            Dictionary<string, CompressedSourceFile> embeddedFilesFromPath = null;
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

        public static string GetEmbeddedFileRange(string pdbLocation, string fullName, int lineStart, int lineEnd, bool showLineNumbers = false, int markedLine = -1, string markPrefix = lineMarkPrefix)
        {
            Dictionary<string, CompressedSourceFile> fileNameToFileSourceText = GetEmbeddedFiles(pdbLocation);
            if (fileNameToFileSourceText == null) return null;
            CompressedSourceFile source = fileNameToFileSourceText.GetValueOrDefault(fullName);
            if (source == null) return null;

            StringBuilder builder = new StringBuilder();
            using (StringReader reader = new StringReader(source.ToString()))
            {
                int lineNumber = 0;

                // first go through text source till we reach lineStart
                while (reader.Peek() != -1)
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