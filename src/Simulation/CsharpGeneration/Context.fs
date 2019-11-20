// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.QsCompiler.CsharpGeneration

open System
open System.Collections.Generic
open System.Collections.Immutable
open System.Linq

open Microsoft.Quantum.QsCompiler
open Microsoft.Quantum.QsCompiler.DataTypes
open Microsoft.Quantum.QsCompiler.ReservedKeywords
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.QsCompiler.Transformations


type internal DeclarationPositions() = 
    inherit SyntaxTreeTransformation<NoScopeTransformations>(new NoScopeTransformations())

    let mutable currentSource = null
    let declarationLocations = new List<NonNullable<string> * (int * int)>()

    member this.DeclarationLocations = 
        declarationLocations.ToLookup (fst, snd)

    static member Apply (syntaxTree : IEnumerable<QsNamespace>) = 
        let walker = new DeclarationPositions()
        for ns in syntaxTree do 
            walker.Transform ns |> ignore
        walker.DeclarationLocations

    override this.onSourceFile file = 
        currentSource <- file.Value
        file

    override this.onLocation (loc : QsLocation) = 
        if currentSource <> null then
            declarationLocations.Add (NonNullable<string>.New currentSource, loc.Offset)
        loc


type CodegenContext = { 
    assemblyConstants       : IDictionary<string, string>
    allQsElements           : IEnumerable<QsNamespace>
    allUdts                 : ImmutableDictionary<QsQualifiedName,QsCustomType>
    allCallables            : ImmutableDictionary<QsQualifiedName,QsCallable>
    declarationPositions    : ImmutableDictionary<NonNullable<string>, ImmutableSortedSet<int * int>>
    byName                  : ImmutableDictionary<NonNullable<string>,(NonNullable<string>*QsCallable) list>
    current                 : QsQualifiedName option
    signature               : ResolvedSignature option
    fileName                : string option
    unitTests               : ILookup<NonNullable<string>, string> // for each namespace contains the targets on which unit tests need to be executed
} 
    with
    static member public Create (syntaxTree, assemblyConstants) =        
        let udts = GlobalTypeResolutions syntaxTree
        let callables = GlobalCallableResolutions syntaxTree
        let positionInfos = DeclarationPositions.Apply syntaxTree
        let callablesByName = 
            let result = new Dictionary<NonNullable<string>,(NonNullable<string>*QsCallable) list>()
            syntaxTree |> Seq.collect (fun ns -> ns.Elements |> Seq.choose (function
            | QsCallable c -> Some (ns, c)
            | _ -> None))
            |> Seq.iter (fun (ns:QsNamespace,c:QsCallable) -> 
                if result.ContainsKey c.FullName.Name then result.[c.FullName.Name] <- (ns.Name, c) :: (result.[c.FullName.Name]) 
                else result.[c.FullName.Name] <- [ns.Name, c])
            result.ToImmutableDictionary()

        let testTargets =  
            let allTargets (c : QsCallable) = c.Attributes |> SymbolResolution.TryFindTestTargets |> Seq.map (fun target -> c.FullName.Namespace, target)
            callables.Values 
            |> Seq.collect allTargets
            |> Seq.distinct 
            |> Seq.filter (snd >> String.IsNullOrWhiteSpace >> not) 
            |> Seq.toArray
    
        { 
            assemblyConstants = assemblyConstants;
            allQsElements = syntaxTree; 
            byName = callablesByName; 
            allUdts = udts; 
            allCallables = callables; 
            declarationPositions = positionInfos.ToImmutableDictionary((fun g -> g.Key), (fun g -> g.ToImmutableSortedSet()))
            current = None; 
            fileName = None;
            signature = None;
            unitTests = testTargets.ToLookup(fst, snd)
        }

    static member public Create syntaxTree = 
        CodegenContext.Create(syntaxTree, ImmutableDictionary.Empty)

    member public this.AssemblyName = 
        match this.assemblyConstants.TryGetValue AssemblyConstants.AssemblyName with
        | true, name -> name
        | false, _ -> null
