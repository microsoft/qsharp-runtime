// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.QsCompiler.TargetGeneration

open Microsoft.CodeAnalysis.CSharp.Syntax

open Microsoft.Quantum.RoslynWrapper

open System.Collections.Generic
open System.IO
open Microsoft.Quantum.QsCompiler.CsharpGeneration
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.QsCompiler.SyntaxTokens
open Microsoft.Quantum.QsCompiler
open Microsoft.Quantum.QsCompiler.SyntaxExtensions
open Microsoft.Quantum.QsCompiler.DataTypes
open System.Collections.Immutable
open Microsoft.CodeAnalysis
open Microsoft.CodeAnalysis.CSharp

module GenerateTarget =
    // Used to handle the edge case where two intrinsics in different namespaces have the same
    // short name
    type Naminginfo =
        {
            intrinsicNames  : Dictionary<string, string>
            methodNames     : HashSet<string>
        }

    let typeToName t = t |> ResolvedType.New |> SimulationCode.roslynSimpleTypeName 
                        |> Option.defaultValue "" 
    let intTypeName = QsTypeKind.Int |> typeToName
    let intType = intTypeName |> ``ident``
    let qubitTypeName = QsTypeKind.Qubit |> typeToName
    let qubitType = qubitTypeName |> ``ident``
    let unitTypeName = QsTypeKind.UnitType |> typeToName
    let unitValue = (``ident`` unitTypeName) <|.|> (``ident`` "Instance")
    // This one can't be built from the type name string because that won't generate the generic properly
    let qubitArrayTypeName = "IQArray<" + qubitTypeName + ">"
    let qubitArrayType = ``generic`` "IQArray" ``<<`` [qubitTypeName] ``>>``
    // A bunch of "magic strings":
    let applyMethodName = "Apply"
    let dumpMachineName = "DumpMachine"
    let dumpMachineMethodName = "DoDumpMachine"
    let dumpRegisterName = "DumpRegister"
    let dumpRegisterMethodName = "DoDumpRegister"
    let namePropertyName = "Name"
    let bodyPropertyName = "Body"
    let allocationNames = seq { "Allocate"; "Borrow" }
    let releaseNames = seq { "Release"; "Return" }

    // Builds the top-level compilation unit structure
    let buildHeader (baseClassOpt : string option) ns =
        let namespaces = match baseClassOpt  with
                         | Some s -> 
                            let n = s.LastIndexOf('.')
                            if n >= 0
                            then s.Substring(0, n) :: SimulationCode.autoNamespaces
                            else SimulationCode.autoNamespaces
                         | None -> SimulationCode.autoNamespaces
        let usings = namespaces |> List.map (fun ns -> ``using`` ns)

        ``compilation unit``
            []
            usings
            [ns]
        |> SimulationCode.buildPragmas
        |> ``with leading comments`` SimulationCode.autogenComment

    let buildPrologue targetClass generateQubitMgmt generateDump =
        let buildAllocMethods name =
            let implOne = ``method`` qubitTypeName ("Do" + name) ``<<`` [] ``>>`` 
                                ``(`` [] ``)`` [``public``;``abstract``]
                                ``{`` [] ``}`` :> MemberDeclarationSyntax
            let implMany = ``method`` qubitArrayTypeName ("Do" + name) ``<<`` [] ``>>`` 
                                ``(`` [``param`` "n" ``of`` intType] ``)`` [``public``;``abstract``]
                                ``{`` [] ``}`` :> MemberDeclarationSyntax
            seq { implOne; implMany }
        let buildReleaseMethods name =
            let implOne = ``method`` "void" ("Do" + name) ``<<`` [] ``>>`` 
                                ``(`` [``param`` "qb" ``of`` qubitType] ``)`` [``public``;``abstract``]
                                ``{`` [] ``}`` :> MemberDeclarationSyntax
            let implMany = ``method`` "void" ("Do" + name) ``<<`` [] ``>>`` 
                                ``(`` [``param`` "qbs" ``of`` qubitArrayType] ``)`` [``public``;``abstract``]
                                ``{`` [] ``}`` :> MemberDeclarationSyntax
            seq { implOne; implMany }
        let dumpMachineMethod = ``method`` "void" dumpMachineMethodName ``<<`` ["T"] ``>>``
                                    ``(`` [``param`` "location" ``of`` (``ident`` "T")] ``)``
                                    [``public``;``abstract``]
                                    ``{`` [] ``}`` :> MemberDeclarationSyntax
        let dumpRegisterMethod = ``method`` "void" dumpRegisterMethodName ``<<`` ["T"] ``>>``
                                    ``(`` [``param`` "location" ``of`` (``ident`` "T");
                                           ``param`` "qbs" ``of`` qubitArrayType] ``)``
                                    [``public``;``abstract``]
                                    ``{`` [] ``}`` :> MemberDeclarationSyntax
        let nameProperty = ``property-arrow_get`` "string" namePropertyName [``public``;``override``] 
                                ``get`` (``=>`` (literal targetClass))
        let start = if generateDump
                    then seq { nameProperty :> MemberDeclarationSyntax; 
                               dumpMachineMethod; dumpRegisterMethod }
                    else seq { nameProperty :> MemberDeclarationSyntax }
        if generateQubitMgmt then
            seq {
                    start
                    allocationNames |> Seq.collect buildAllocMethods
                    releaseNames |> Seq.collect buildReleaseMethods
                } 
                |> Seq.concat
        else
            start

    let buildEpilogue targetClass generateQubitMgmt generateDump =
        let simFieldName = "simulator"
        let buildSimField () =
            ``field`` targetClass simFieldName [``private``] None
        let buildConstructor name =
            let argName = "m"
            ``constructor`` name ``(`` [ (argName, ``type`` targetClass) ] ``)`` ``:`` ["m"]
                    [``public``] 
                    ``(`` [ (``ident`` simFieldName <-- ``ident`` argName) |> statement ] ``)``
        let buildAllocClass name =
            let applySingle = ``arrow_method`` qubitTypeName applyMethodName ``<<`` [] ``>>`` 
                                    ``(`` [] ``)``
                                    [``public``; ``override``]
                                    (Some (``=>`` (``ident`` simFieldName <.> (``ident`` ("Do" + name), []))))
            let applyMultiple = ``arrow_method`` qubitArrayTypeName applyMethodName ``<<`` [] ``>>`` 
                                    ``(`` [``param`` "n" ``of`` intType ] ``)``
                                    [``public``; ``override``]
                                    (Some (``=>`` (``ident`` simFieldName <.> (``ident`` ("Do" + name), 
                                                                                [``ident`` "n"]))))
            ``class`` name ``<<`` [] ``>>`` ``:`` (Some (simpleBase ("Intrinsic." + name))) ``,`` 
                [] [``public``] 
                ``(`` [
                    buildSimField ()
                    buildConstructor name
                    applySingle
                    applyMultiple
                ] ``)``
        let buildReturnClass name =
            let qbParam = "qb"
            let applySingle = ``arrow_method`` "void" applyMethodName ``<<`` [] ``>>`` 
                                    ``(`` [``param`` qbParam ``of`` qubitType] ``)``
                                    [``public``; ``override``]
                                    (Some (``=>`` (``ident`` simFieldName <.> (``ident`` ("Do" + name), 
                                                                                [``ident`` qbParam]))))
            let qbsParam = "qbs"
            let applyMultiple = ``arrow_method`` "void" applyMethodName ``<<`` [] ``>>`` 
                                    ``(`` [``param`` qbsParam ``of`` qubitArrayType ] ``)``
                                    [``public``; ``override``]
                                    (Some (``=>`` (``ident`` simFieldName <.> (``ident`` ("Do" + name), 
                                                                                [``ident`` qbsParam]))))
            ``class`` name ``<<`` [] ``>>`` ``:`` (Some (simpleBase ("Intrinsic." + name))) ``,`` 
                [] [``public``] 
                ``(`` [
                    buildSimField ()
                    buildConstructor name
                    applySingle
                    applyMultiple
                ] ``)``
        let dumpMachineClass =
            let locParamName = "location"
            let call = (``ident`` simFieldName) <.> 
                        (``ident`` dumpMachineMethodName, [``ident`` locParamName]) |> statement
            let body = ``() => {}`` [ locParamName ] [call] :> ExpressionSyntax
            let dumpMachineBody = ``property-arrow_get`` "Func<T, QVoid>" bodyPropertyName 
                                    [``public``; ``override``]
                                    ``get`` (``=>`` body)
            ``class`` dumpMachineName ``<<`` ["T"] ``>>`` ``:`` 
                (Some (simpleBase ("Quantum.Diagnostics.DumpMachine<T>"))) ``,`` [] [``public``] 
                ``(`` [
                    buildSimField ()
                    buildConstructor dumpMachineName
                    dumpMachineBody
                ] ``)``
        let dumpRegisterClass =
            let locParamName = "location"
            let qubitsParamName = "qubits"
            let argPrep = ``var`` ("(" + locParamName + ", " + qubitsParamName + ")") 
                                (``:=`` (``ident`` "__in"))
            let call = (``ident`` simFieldName) <.> 
                        (``ident`` dumpRegisterMethodName, 
                                    [``ident`` locParamName; ``ident`` qubitsParamName]) |> statement
            let body = ``() => {}`` [ locParamName ] [argPrep; call] :> ExpressionSyntax
            let dumpRegisterBody = ``property-arrow_get`` "Func<(T, IQArray<Qubit>), QVoid>" 
                                            bodyPropertyName 
                                    [``public``; ``override``]
                                    ``get`` (``=>`` body)
            ``class`` dumpRegisterName ``<<`` ["T"] ``>>`` ``:`` 
                (Some (simpleBase ("Quantum.Diagnostics.DumpRegister<T>"))) ``,`` [] [``public``] 
                ``(`` [
                    buildSimField ()
                    buildConstructor dumpRegisterName
                    dumpRegisterBody
                ] ``)``
        let qubitClasses = if generateQubitMgmt
                           then
                                Seq.append
                                    (allocationNames |> Seq.map buildAllocClass)
                                    (releaseNames |> Seq.map buildReturnClass)
                           else
                                Seq.empty
        let dumpClasses = if generateDump 
                          then seq { dumpMachineClass; dumpRegisterClass }
                          else Seq.empty
        Seq.append qubitClasses dumpClasses

    let implClassName (ns : string) name =
        ns.Replace(".", "_") + "__" + name

    let implMethodName namingInfo (sp : QsSpecialization) =
        let shortName = sp.Parent.Name.Value
        let longName = implClassName sp.Parent.Namespace.Value shortName
        let baseName = 
            match namingInfo.intrinsicNames.TryGetValue longName with
            | true, s -> s
            | false, _ ->
                if namingInfo.methodNames.Contains shortName
                then
                    namingInfo.methodNames.Add longName |> ignore
                    namingInfo.intrinsicNames.[longName] <- longName
                    longName
                else
                    namingInfo.methodNames.Add shortName |> ignore
                    namingInfo.intrinsicNames.[longName] <- shortName
                    shortName
        "Do" + baseName + match sp.Kind with
                                      | QsBody              -> ""
                                      | QsAdjoint           -> "Adj"
                                      | QsControlled        -> "Ctl"
                                      | QsControlledAdjoint -> "CtlAdj"

    let fullArgsForSpecialization args (sp : QsSpecialization) =
        match sp.Kind with
        | QsControlled | QsControlledAdjoint -> ("__ctrls__", qubitArrayTypeName) :: args
        | _ -> args

    let buildImplMethod context namingInfo args (sp : QsSpecialization) =
        let outType = match sp.Signature.ReturnType.Resolution with
                      | UnitType -> "void"
                      | _ -> SimulationCode.roslynTypeName context sp.Signature.ReturnType
        match sp.Implementation with
        | Generated SelfInverse -> Seq.empty
        | _ ->
            let implName = implMethodName namingInfo sp
            let fullArgs = fullArgsForSpecialization args sp
            let parms = fullArgs |> List.map (fun (n, t) -> ``param`` n ``of`` (``type`` t))
            let impl = ``method`` outType implName ``<<`` [] ``>>`` 
                            ``(`` parms ``)`` [``public``;``abstract``]
                            ``{`` [] ``}`` :> MemberDeclarationSyntax
            seq { impl }

    let buildImplProperty targetClass context namingInfo args (sp : QsSpecialization) =
        let inType  = SimulationCode.roslynTypeName context sp.Signature.ArgumentType
        let outType = SimulationCode.roslynTypeName context sp.Signature.ReturnType
        let propertyType = "Func<" + inType + ", " + outType + ">"
        let propertyName = SimulationCode.getSpecPropertyName sp
        let propertyFromBody body =
            (``property-arrow_get`` propertyType propertyName [``public``; ``override``]
                    ``get`` (``=>`` body)) :> MemberDeclarationSyntax
        match sp.Implementation with
        | SpecializationImplementation.Intrinsic -> 
            let returnType  = sp.Signature.ReturnType
            let inDataName = "__in__"
            let inData = ``ident`` inDataName
            let spArgs = match sp.Kind with 
                         | QsControlled | QsControlledAdjoint -> 
                            let controls = 
                                { 
                                    VariableName = NonNullable<string>.New "__ctrls__" |> ValidName
                                    Type = ResolvedType.New (ArrayType (ResolvedType.New Qubit))
                                    InferredInformation = InferredExpressionInformation.New (false, false)
                                    Position = Null
                                    Range = (QsPositionInfo.Zero, QsPositionInfo.Zero)
                                }
                                |> QsTupleItem
                            match args with
                            | QsTupleItem one -> 
                                [| controls ; QsTupleItem one |] |> ImmutableArray.ToImmutableArray |> QsTuple
                            | QsTuple many ->
                                if many.Length = 0 
                                then 
                                    let empty = [| |] |> ImmutableArray.ToImmutableArray |> QsTuple
                                    [| controls; empty |] |> ImmutableArray.ToImmutableArray |> QsTuple
                                else many.Insert(0, controls) |> QsTuple
                         | _ -> args
            let (argName, argsInit, argNames) =
            //TODO: diagnostics.
                let name = function | ValidName n -> n.Value | InvalidName -> ""
                let rec buildVariableName = function
                    | QsTupleItem  one -> one.VariableName |> name
                    | QsTuple     many -> 
                        if many.Length = 0
                        then "(_)"
                        else "(" + (many |> Seq.map buildVariableName |> String.concat ",") + ")"
                let rec buildVariableNameList accum a =
                    match a with
                    | QsTupleItem  one -> ((one.VariableName |> name |> ``ident``) :: accum) |> List.rev
                    | QsTuple     many -> many |> Seq.fold (fun s i -> buildVariableNameList s i) accum
                match spArgs with
                | QsTupleItem one -> (one.VariableName |> name, [], [one.VariableName |> name |> ``ident``])
                | QsTuple many    ->
                    if many.Length = 0 then
                        (inDataName, [], [])
                    elif many.Length = 1 then
                        ((buildVariableName many.[0]), 
                         [], 
                         [``ident`` (buildVariableName many.[0])])
                    else
                        (inDataName,
                         [ ``var`` (buildVariableName spArgs) (``:=`` <| inData) ], 
                         buildVariableNameList [] spArgs)
            let sim = ``((`` (``as`` targetClass ((``ident`` "this" ) <|.|> (``ident`` "Factory"))) ``))``
            let methodName = implMethodName namingInfo sp |> ``ident``
            let call = sim <.> (methodName, argNames)
            let ret =
                match returnType.Resolution with
                | QsTypeKind.UnitType ->
                    [
                        call |> statement
                        ``return`` ( Some unitValue)
                    ]
                | _ ->
                    [
                        ``return`` ( Some call )
                    ]
            let body = ``() => {}`` [ argName ] (argsInit @ ret) :> ExpressionSyntax
            Some (body |> propertyFromBody)
        | Generated SelfInverse ->
            let adjointedBodyName = SimulationCode.getAdjointBodyName sp
            Some (adjointedBodyName |> ``ident`` |> propertyFromBody)
        | _ ->
            None

    let buildIntrinsicClass context namingInfo targetClass op =
        let (opName, nonGenericName) = SimulationCode.findClassName context op
        let className = implClassName op.FullName.Namespace.Value opName
        let constructors = [ (SimulationCode.buildConstructor context className) ]
        let nameProperties = [ SimulationCode.buildName className; 
                               SimulationCode.buildFullName op.FullName ]
        //let baseClass, _, _ = SimulationCode.getBaseClass context op
        let baseClass = op.FullName.Namespace.Value + "." + opName |> ``simpleBase``
        let specProperties = op.Specializations 
                             |> Seq.choose (buildImplProperty targetClass context namingInfo op.ArgumentTuple)
                             |> Seq.toList
        let inData, outData = SimulationCode.buildInOutData context op
        let methods = [ 
                        [] |> SimulationCode.buildInit context
                        inData |> fst
                        outData |> fst
                        SimulationCode.buildRun context nonGenericName op.ArgumentTuple op.Signature.ArgumentType op.Signature.ReturnType
                      ]
        let specClass = ``class`` className ``<<`` [] ``>>``
                            ``:`` (Some baseClass) ``,`` [ ``simpleBase`` "ICallable" ] 
                            [``public``]
                            ``{``
                                (constructors @ nameProperties @ specProperties @ methods)
                            ``}``
        specClass

    let buildIntrinsicMethods context namingInfo (op : QsCallable) : MemberDeclarationSyntax seq =
        let args = SimulationCode.flatArgumentsList context op.ArgumentTuple
        let implMethods = op.Specializations |> Seq.collect (buildImplMethod context namingInfo args)
        implMethods

    let buildClass targetClass targetBaseClass members = 
        let baseClass = (match targetBaseClass with | Some s -> s | None -> "SimulatorBase")
                        |> simpleBase |> Some
        ``class`` targetClass ``<<`` [] ``>>`` ``:`` baseClass ``,`` [] [``abstract``; ``public``] ``(`` members ``)``

    let buildNamespace name target =
        ``namespace`` name
            ``{``
                []
                [target]
            ``}``

    let namespaceElementIsIntrinsic elem =
        match elem with
        | QsCallable callable -> 
            match callable.Kind with
            | TypeConstructor -> None
            | _ -> 
                if callable.Specializations 
                   |> Seq.exists (fun spec -> match spec.Implementation with
                                                    | SpecializationImplementation.Intrinsic -> true
                                                    | _ -> false)
                then Some callable
                else None
        | _ -> None

    let findIntrinsics syntaxTree =
        syntaxTree 
        |> Seq.collect (fun ns -> ns.Elements |> Seq.choose namespaceElementIsIntrinsic)

    /// <summary>
    /// Generates the abstract base class for a target defined by a Q# compilation.
    /// </summary>
    /// <param name="syntaxTree">The Q# compilation unit</param>
    /// <param name="targetClass">The simple name of the class to generate</param>
    /// <param name="targetNamespace">The namespace in which the class should be generated</param>
    /// <param name="targetBaseClass">The (optional) fully-qualified name of the base class for
    /// the generated class; if None, then the SimulatorBase class is used</param>
    /// <param name="genQubitMgmt">true if the qubit management subclasses and methods should be generated,
    /// false if not</param>
    /// <param name="genDump">true if the dump machine and register subclasses and methods should be
    /// generated, false if not</param>
    let GenerateTarget (syntaxTree : QsNamespace seq) targetClass targetNamespace 
                        targetBaseClass genQubitMgmt genDump =
        let context = CodegenContext.Create(syntaxTree, new Dictionary<string, string>())
        let namingInfo = {intrinsicNames = Dictionary<string, string>(); methodNames = HashSet<string>()}
        // We alphabetize the list of namespaces in order to guarantee a repeatable sequence and outcome
        let intrinsics = syntaxTree |> Seq.sortBy (fun ns -> ns.Name.Value) 
                                    |> findIntrinsics 
        let members = intrinsics |> Seq.collect (buildIntrinsicMethods context namingInfo)
        let subClasses = intrinsics |> Seq.map (buildIntrinsicClass context namingInfo targetClass) 
                                    |> Seq.cast<MemberDeclarationSyntax>
        let stdPrologue = buildPrologue targetClass genQubitMgmt genDump |> Seq.cast<MemberDeclarationSyntax>
        let stdEpilogue = buildEpilogue targetClass genQubitMgmt genDump |> Seq.cast<MemberDeclarationSyntax>
        let allMembers = seq { stdPrologue; members; subClasses; stdEpilogue } |> Seq.concat
        let target = buildClass targetClass targetBaseClass allMembers
        let ns = buildNamespace targetNamespace target
        let syntax = buildHeader targetBaseClass ns
        let text = syntax |> SimulationCode.formatSyntaxTree
        text
