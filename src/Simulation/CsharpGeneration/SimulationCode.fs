// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.QsCompiler.CsharpGeneration

open System
open System.Collections.Generic
open System.Collections.Immutable
open System.Linq

open Microsoft.CodeAnalysis
open Microsoft.CodeAnalysis.CSharp.Syntax
open Microsoft.CodeAnalysis.Formatting

open Microsoft.Quantum.RoslynWrapper
open Microsoft.Quantum.QsCompiler
open Microsoft.Quantum.QsCompiler.DataTypes
open Microsoft.Quantum.QsCompiler.ReservedKeywords
open Microsoft.Quantum.QsCompiler.SyntaxTokens 
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.QsCompiler.SyntaxExtensions
open Microsoft.Quantum.QsCompiler.Transformations.BasicTransformations


/// ---------------------------------------------------------------------------
/// The code generation for the simulation runtime. C# code
/// for Quantum simulation is generated using the Roslyn compiler.
/// It uses BrightSword's (John Azariah's) F# wrapper for easier readability.
/// ---------------------------------------------------------------------------
module SimulationCode =
    open Microsoft.Quantum.QsCompiler.Transformations
    open System.Globalization

    type DeclarationPositions() = 
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
        allQsElements           : IEnumerable<QsNamespace>
        allUdts                 : ImmutableDictionary<QsQualifiedName,QsCustomType>
        allCallables            : ImmutableDictionary<QsQualifiedName,QsCallable>
        declarationPositions    : ImmutableDictionary<NonNullable<string>, ImmutableSortedSet<int * int>>
        byName                  : ImmutableDictionary<NonNullable<string>,(NonNullable<string>*QsCallable) list>
        current                 : QsQualifiedName option
        signature               : ResolvedSignature option
        fileName                : string option
    } 
    
    type CodegenContext with
        member this.setCallable (op: QsCallable) = { this with current = (Some op.FullName); signature = (Some op.Signature) }
        member this.setUdt (udt: QsCustomType) = { this with current = (Some udt.FullName) } 

    let createContext fileName syntaxTree =        
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
        { 
            allQsElements = syntaxTree; 
            byName = callablesByName; 
            allUdts = udts; 
            allCallables = callables; 
            declarationPositions = positionInfos.ToImmutableDictionary((fun g -> g.Key), (fun g -> g.ToImmutableSortedSet()))
            current = None; 
            fileName = fileName; 
            signature = None 
        }
              
    let autoNamespaces = 
        [
            "System"
            "Microsoft.Quantum.Core"
            "Microsoft.Quantum.Intrinsic"
            "Microsoft.Quantum.Simulation.Core" 
        ]

    let funcsAsProps = [
        ("Length", { Namespace = "Microsoft.Quantum.Core" |> NonNullable<String>.New; Name = "Length" |> NonNullable<String>.New } )
        ("Start",  { Namespace = "Microsoft.Quantum.Core" |> NonNullable<String>.New; Name = "RangeStart" |> NonNullable<String>.New } )
        ("End",    { Namespace = "Microsoft.Quantum.Core" |> NonNullable<String>.New; Name = "RangeEnd" |> NonNullable<String>.New } )
        ("Step",   { Namespace = "Microsoft.Quantum.Core" |> NonNullable<String>.New; Name = "RangeStep" |> NonNullable<String>.New } )
    ]
    
    let isCurrentOp context n = match context.current with | None -> false | Some name ->  name = n

    let prependNamespaceString (name : QsQualifiedName) = 
        let pieces = name.Namespace.Value.Split([|'.'|]) |> String.Concat
        pieces + name.Name.Value

    let needsFullPath context (op:QsQualifiedName) = 
        let hasMultipleDefinitions() = if context.byName.ContainsKey op.Name then context.byName.[op.Name].Length > 1 else false
        let sameNamespace = match context.current with | None -> false | Some n -> n.Namespace = op.Namespace

        if sameNamespace then 
            false
        elif hasMultipleDefinitions() then
            true
        else
            not (autoNamespaces |> List.contains op.Namespace.Value)
            
    let getTypeParameters types = 
        let findAll (t: ResolvedType) = t.ExtractAll (fun item -> item.Resolution |> function 
            | QsTypeKind.TypeParameter tp -> seq{ yield tp }
            | _ -> Enumerable.Empty())
        types 
        |> Seq.collect findAll 
        |> Seq.distinctBy (fun tp -> tp.Origin, tp.TypeName)
        |> Seq.toList

    let getAllItems itemBase t = 
        let rec getItems (acc : Queue<ExpressionSyntax>) current = function 
            | Tuple ts -> ts |> Seq.iteri (fun i x -> getItems acc (current <|.|> ident ("Item" + (i+1).ToString())) x)
            | _ -> acc.Enqueue current
        let items = Queue() 
        getItems items itemBase t
        items

    let hasTypeParameters types = not (getTypeParameters types).IsEmpty
   
    let justTheName context (n: QsQualifiedName) =
        if needsFullPath context n then n.Namespace.Value + "." + n.Name.Value else n.Name.Value

    let isGeneric context (n: QsQualifiedName) =
        if context.allCallables.ContainsKey n then
            let signature = context.allCallables.[n].Signature
            let tIn = signature.ArgumentType
            let tOut = signature.ReturnType
            hasTypeParameters [tIn;tOut]
        else
            false

    let findUdt context (name:QsQualifiedName) = context.allUdts.[name]

    let isUdt context (name:QsQualifiedName) = context.allUdts.TryGetValue name

    let inAndOutputType (qsharpType: ResolvedType) =
        match qsharpType.Resolution with
        | QsTypeKind.Operation ((tIn, tOut), _) -> (tIn, tOut)
        | QsTypeKind.Function (tIn, tOut)       -> (tIn, tOut)
// TODO: Diagnostics
        | _ -> failwith "Invalid ResolvedType for callable definition"  

    let hasAdjointControlled functors =    
        let oneFunctor (adj,ctrl) f = 
            match f with 
            | QsFunctor.Adjoint    -> (true, ctrl) 
            | QsFunctor.Controlled -> (adj, true)
        match functors with 
        | Value fs -> fs |> Seq.fold oneFunctor (false,false)
// TODO: Diagnostics
        | Null -> (true, true)

   // Maps Q# types to their corresponding Roslyn type
    let rec roslynTypeName context (qsharpType:ResolvedType) : string =
        match qsharpType.Resolution with
        | QsTypeKind.UnitType      -> "QVoid"
        | QsTypeKind.Int           -> "Int64"
        | QsTypeKind.BigInt        -> "System.Numerics.BigInteger"
        | QsTypeKind.Double        -> "Double"
        | QsTypeKind.Bool          -> "Boolean"
        | QsTypeKind.String        -> "String"
        | QsTypeKind.Qubit         -> "Qubit"
        | QsTypeKind.Result        -> "Result"
        | QsTypeKind.Pauli         -> "Pauli"
        | QsTypeKind.Range         -> "QRange"
        | QsTypeKind.ArrayType arrayType    -> sprintf "IQArray<%s>" (arrayType |> roslynTypeName context)
        | QsTypeKind.TupleType tupleType    -> tupleType |> roslynTupleTypeName context
        | QsTypeKind.UserDefinedType name   -> justTheName context (QsQualifiedName.New (name.Namespace, name.Name))
        | QsTypeKind.Operation (_,functors) -> roslynCallableInterfaceName functors.Characteristics
        | QsTypeKind.Function _             -> roslynCallableInterfaceName ResolvedCharacteristics.Empty
        | QsTypeKind.TypeParameter t        -> t |> roslynTypeParameterName
        | QsTypeKind.MissingType            -> "object" 
// TODO: diagnostics
        | QsTypeKind.InvalidType            -> ""
       
    and roslynTupleTypeName context tupleTypes = 
        tupleTypes
        |> Seq.map (roslynTypeName context)
        |> String.concat ","
        |> sprintf "(%s)"

    and roslynTypeParameterName (t:QsTypeParameter) =
        sprintf "__%s__" t.TypeName.Value

    and roslynCallableInterfaceName characteristics =    
        let (adj, ctrl) = characteristics.SupportedFunctors |> hasAdjointControlled 
        match (adj,ctrl) with 
        | (true, true)  -> "IUnitary"      
        | (true, false) -> "IAdjointable"  
        | (false, true) -> "IControllable"
        | _             -> "ICallable"     

    and roslynCallableTypeName context (name:QsQualifiedName) =
        if not (context.allCallables.ContainsKey name) then
            name.Name.Value
        else
            let signature = context.allCallables.[name].Signature
            let tIn = signature.ArgumentType
            let tOut = signature.ReturnType
            let baseInterface = roslynCallableInterfaceName signature.Information.Characteristics
            if isGeneric context name then
                baseInterface
            else
                match baseInterface with 
                | "ICallable" ->
                    sprintf "%s<%s, %s>" baseInterface (roslynTypeName context tIn) (roslynTypeName context tOut)
                | _ ->
                    sprintf "%s<%s>" baseInterface (roslynTypeName context tIn)

    let isTuple = function
    | QsTypeKind.TupleType _  -> true
    | _                 -> false

    let isCallable (qsharpType:ResolvedType) =
        match qsharpType.Resolution with
        | QsTypeKind.Operation _
        | QsTypeKind.Function  _ -> true
        | _             -> false
   
    let tupleBaseClassName context qsharpType =
        let baseType = (roslynTypeName context qsharpType)
        sprintf "QTuple<%s>" baseType
        
    let udtBaseClassName context qsharpType =
        let baseType = (roslynTypeName context qsharpType)
        sprintf "UDTBase<%s>" baseType

    // Top-level and public for testing
    let floatToString (f : double) =
        sprintf "%sD" (f.ToString("R", System.Globalization.CultureInfo.InvariantCulture))

    let mutable private count = 0
    let private nextArgName() =
        count <- count + 1
        sprintf "__arg%d__" count

    type ExpressionSeeker(context) = 
        inherit DefaultExpressionTransformation()

        member val Operations : Set<QsQualifiedName> = Set.empty with get, set

        override this.Transform ex =
            match ex.Expression with
            | Identifier (id, _) -> 
                match id with
                | GlobalCallable n -> this.Operations <- this.Operations.Add n
                | _ -> ()
            | _ -> ()
            base.Transform ex    

    /// Used to discover which operations are used by a certain code block.
    type OperationsSeeker(context : CodegenContext) =
        inherit ScopeTransformation<StatementKindSeeker, ExpressionSeeker>
                (new Func<_,_>(fun s -> new StatementKindSeeker(s :?> OperationsSeeker)), new ExpressionSeeker(context))   

        member this.Operations 
            with get () = this._Expression.Operations
            and set v = this._Expression.Operations <- v
           
    /// Used to discover which operations are used by a certain code block.
    and StatementKindSeeker(opSeeker : OperationsSeeker) = 
        inherit StatementKindTransformation<OperationsSeeker>(opSeeker)

        let ALLOCATE = { Name = "Allocate" |> NonNullable<string>.New; Namespace = "Microsoft.Quantum.Intrinsic" |> NonNullable<string>.New }
        let RELEASE  = { Name = "Release"  |> NonNullable<string>.New; Namespace = "Microsoft.Quantum.Intrinsic" |> NonNullable<string>.New }
        let BORROW   = { Name = "Borrow"   |> NonNullable<string>.New; Namespace = "Microsoft.Quantum.Intrinsic" |> NonNullable<string>.New }
        let RETURN   = { Name = "Return"   |> NonNullable<string>.New; Namespace = "Microsoft.Quantum.Intrinsic" |> NonNullable<string>.New }

        override this.onAllocateQubits node = 
            this._Scope.Operations <- this._Scope.Operations.Add ALLOCATE
            this._Scope.Operations <- this._Scope.Operations.Add RELEASE
            base.onAllocateQubits node 

        override this.onBorrowQubits node = 
            let t = UnitType |> ResolvedType.New        // Dummy, not used.
            this._Scope.Operations <- this._Scope.Operations.Add BORROW
            this._Scope.Operations <- this._Scope.Operations.Add RETURN
            base.onBorrowQubits node 

    /// Used to generate the list of statements that implement a Q# operation specialization.
    type StatementBlockBuilder(context) = 
        inherit ScopeTransformation<StatementBuilder, NoExpressionTransformations>
                (new Func<_,_>(fun s -> new StatementBuilder(s :?> StatementBlockBuilder, context)), new NoExpressionTransformations())
        
        member val DeclarationsInStatement = LocalDeclarations.Empty with get, set
        member val DeclarationsInScope = LocalDeclarations.Empty with get, set

        member this.Statements = this._StatementKind.Statements
        member this.SetStartLine nr = this._StatementKind.StartLine <- nr

        override this.Transform (scope : QsScope) = 
            this.DeclarationsInScope <- scope.KnownSymbols
            base.Transform scope

        override this.onStatement (node:QsStatement) =
            match node.Location with 
            | Value loc -> 
                let (current, _) = loc.Offset
                this._StatementKind.LineNumber <- this._StatementKind.StartLine |> Option.map (fun start -> start + current + 1) // The Q# compiler reports 0-based line numbers.
            | Null -> 
                this._StatementKind.LineNumber <- None // auto-generated statement; the line number will be set to the specialization declaration
            this.DeclarationsInStatement <- node.SymbolDeclarations
            this.DeclarationsInScope <- LocalDeclarations.Concat this.DeclarationsInScope this.DeclarationsInStatement // only fine because/if a new StatementBlockBuilder is created for every block!
            base.onStatement node

    /// Used to generate the statements that implement a Q# operation specialization.
    and StatementBuilder(bodyBuilder, context) =
        inherit StatementKindTransformation<StatementBlockBuilder>(bodyBuilder)
       
        let mutable lineNumber = None
        let mutable startLine  = None

        let withLineNumber s =
            // add a line directive if the operation specifies the source file and a line number
            match context.fileName, lineNumber with
            | Some _, Some ln when ln = 0 ->
                ``#line hidden`` <| s
            | Some n, Some ln -> 
                ``#line`` ln n s
            | Some n, None -> startLine |> function 
                | Some ln -> 
                    ``#line`` (ln + 1) n s // we need 1-based line numbers here, and startLine is zero-based
                | None -> s
            | _ -> s
            
        let QArrayType = function
            | ArrayType b -> generic "QArray" ``<<`` [ roslynTypeName context b ] ``>>`` |> Some
            | _ -> None

        let (|Property|_|) = function
            | CallLikeExpression (op : TypedExpression, args) ->
                match op.Expression with
                | Identifier (id, _) -> 
                    match id with
                    | GlobalCallable n -> funcsAsProps |> List.tryPick (fun (prop, f) -> if (n = f) then Some (args, prop) else None)
                    | _ -> None
                | _ -> None
            | _ -> None
            
        let (|NewUdt|_|) = function
            | CallLikeExpression (op : TypedExpression, args) ->
                match op.Expression with
                | Identifier (id, _) -> 
                    match id with
                    | GlobalCallable n when isUdt context n |> fst -> Some (n,args)
                    | _ -> None
                | _ -> None
            | _ -> None

        let (|PartialApplication|_|) expression =
            match expression with
            | CallLikeExpression (op,args) when TypedExpression.IsPartialApplication expression -> Some (op,args) 
            | _ -> None

        // Builds Roslyn code for a Q# expression
        let rec buildExpression (ex : TypedExpression) =
            match ex.Expression with
// TODO: Diagnostics
            | InvalidExpr                   -> failwith "Can't generate code for error expression"
            | UnitValue                     -> (``ident`` "QVoid") <|.|> (``ident`` "Instance")
            | IntLiteral           i        -> literal i
            | BigIntLiteral        b        -> ``invoke`` (ident "System.Numerics.BigInteger.Parse") ``(`` [literal (b.ToString("R", CultureInfo.InvariantCulture))] ``)``
            // otherwise converts x.0 to int, see https://stackoverflow.com/questions/24299692/why-is-a-round-trip-conversion-via-a-string-not-safe-for-a-double
            | DoubleLiteral        f        -> ident (floatToString f) :> ExpressionSyntax
            | BoolLiteral b                 -> upcast (if b then ``true`` else ``false``)
            | ResultLiteral r               -> (ident "Result") <|.|> (ident (match r with | Zero -> "Zero" | One -> "One"))
            | PauliLiteral p                -> (ident "Pauli")  <|.|> (ident (match p with | PauliI -> "PauliI" | PauliX -> "PauliX" | PauliY -> "PauliY" | PauliZ -> "PauliZ"))
            | Identifier (id,_)             -> buildId id
            | StringLiteral (s,e)           -> buildInterpolatedString s.Value e
            | RangeLiteral (r,e)            -> buildRange r e
            | NEG n                         -> ``-`` (buildExpression n)
            | NOT r                         -> ! (buildExpression r)
            | BNOT i                        -> ``~~~`` (buildExpression i)          
            | ADD (l, r)                    -> buildAddExpr ex.ResolvedType l r
            // We use the Pow extension method from Microsoft.Quantum.Simulation.Core for all valid combinations of types.
            | POW (l, r)                    -> ``invoke`` ((buildExpression l) <|.|> (ident "Pow")) ``(`` [ (buildExpression r) ] ``)``
            | SUB (l, r)                    -> ``((`` ((buildExpression l) <->  (buildExpression r)) ``))``
            | MUL (l, r)                    -> ``((`` ((buildExpression l) <*>  (buildExpression r)) ``))``
            | DIV (l, r)                    -> ``((`` ((buildExpression l) </>  (buildExpression r)) ``))``
            | MOD (l, r)                    -> ``((`` ((buildExpression l) <%>  (buildExpression r)) ``))``
            | EQ  (l, r)                    -> ``((`` ((buildExpression l) .==. (buildExpression r)) ``))``
            | NEQ (l, r)                    -> ``((`` ((buildExpression l) .!=. (buildExpression r)) ``))``
            | AND (l, r)                    -> ``((`` ((buildExpression l) .&&. (buildExpression r)) ``))``
            | OR  (l, r)                    -> ``((`` ((buildExpression l) .||. (buildExpression r)) ``))``
            | BOR (l, r)                    -> ``((`` ((buildExpression l) .|||. (buildExpression r)) ``))``
            | BAND (l, r)                   -> ``((`` ((buildExpression l) .&&&. (buildExpression r)) ``))``
            | BXOR (l, r)                   -> ``((`` ((buildExpression l) .^^^. (buildExpression r)) ``))``
            | LSHIFT (l, r)                 -> ``((`` ((buildExpression l) .<<<. (``cast`` "int" (buildExpression r))) ``))``
            | RSHIFT (l, r)                 -> ``((`` ((buildExpression l) .>>>. (``cast`` "int" (buildExpression r))) ``))``
            | LT  (l, r)                    -> ``((`` ((buildExpression l) .<.  (buildExpression r)) ``))``
            | LTE (l, r)                    -> ``((`` ((buildExpression l) .<=. (buildExpression r)) ``))``
            | GT  (l, r)                    -> ``((`` ((buildExpression l) .>.  (buildExpression r)) ``))``
            | GTE (l, r)                    -> ``((`` ((buildExpression l) .>=. (buildExpression r)) ``))``
            | CONDITIONAL (c, t, f)         -> ``((`` (buildConditional c t f) ``))`` 
            | CopyAndUpdate (l, i, r)       -> buildCopyAndUpdateExpression (l, i, r)
            | UnwrapApplication e           -> (buildExpression e) <|.|> (ident "Data")
            | ValueTuple vs                 -> buildTuple vs
            | NamedItem (ex, acc)           -> buildNamedItem ex acc
            | ArrayItem (a, i)              -> buildArrayItem a i
            | ValueArray elems              -> buildValueArray ex.ResolvedType elems
            | NewArray (t, expr)            -> buildNewArray t expr
            | AdjointApplication op         -> (buildExpression op)   <|.|> (ident "Adjoint")
            | ControlledApplication op      -> (buildExpression op)   <|.|> (ident "Controlled")
            | Property (elem, prop)         -> (buildExpression elem) <|.|> (ident prop)
            | PartialApplication (op,args)  -> buildPartial ex.ResolvedType ex.TypeParameterResolutions op args // needs to be before NewUdt!
            | NewUdt (udt,args)             -> buildNewUdt udt args // needs to be before CallLikeExpression!
            | CallLikeExpression (op,args)  -> buildApply ex.ResolvedType op args
            | MissingExpr                   -> ident "_" :> ExpressionSyntax 

        and captureExpression (ex : TypedExpression) =
            match ex.Expression with
            | Identifier (s, _) when ex.InferredInformation.IsMutable ->
                match ex.ResolvedType.Resolution with
                | QsTypeKind.ArrayType _ -> ``invoke`` (buildId s <|?.|> (ident "Copy")) ``(`` [] ``)``
                | _ -> buildExpression ex
            | _ -> buildExpression ex

        and buildNamedItem ex acc = 
            match acc with 
            | LocalVariable name -> (buildExpression ex) <|.|> (ident name.Value)
// TODO: Diagnostics
            | _ -> failwith "Invalid identifier for named item"

        and buildAddExpr (exType : ResolvedType) lhs rhs = 
            match exType.Resolution |> QArrayType with 
            | Some arrType -> arrType <.> (``ident`` "Add", [buildExpression lhs; buildExpression rhs]) 
            | _ -> ``((`` ((buildExpression lhs) <+> (buildExpression rhs)) ``))``

        and buildInterpolatedString (s : string) (exs: ImmutableArray<TypedExpression>) =
            if exs.Length <> 0 then                 
                let exprs = exs |> Seq.map buildExpression |> Seq.toList
                ``invoke`` (ident "String.Format" ) ``(`` (literal s :: exprs) ``)``
            else literal s
            
        and buildId id : ExpressionSyntax = 
            match id with
            | LocalVariable n-> n.Value |> ident :> ExpressionSyntax
            | GlobalCallable n ->
                if isCurrentOp context n then 
                    Directives.Self |> ident :> ExpressionSyntax
                elif needsFullPath context n then 
                    prependNamespaceString n |> ident :> ExpressionSyntax
                else 
                    n.Name.Value |> ident :> ExpressionSyntax
// TODO: Diagnostics
            | InvalidIdentifier -> 
                failwith "Received InvalidIdentifier"

        and buildCopyAndUpdateExpression (lhsEx : TypedExpression, accEx : TypedExpression, rhsEx) = 
            match lhsEx.ResolvedType.Resolution |> QArrayType with
            | Some arrayType -> 
                let lhsAsQArray = ``new`` arrayType ``(`` [buildExpression lhsEx] ``)`` 
                lhsAsQArray <.> (``ident`` "Modify", [ buildExpression accEx; captureExpression rhsEx ]) // in-place modification
            | _ -> lhsEx.ResolvedType.Resolution |> function
                | UserDefinedType udt -> 
                    let itemName = accEx.Expression |> function
                        | Identifier (LocalVariable id, Null) -> id
// TODO: Diagnostics
                        | _ -> failwith "item access expression in copy-and-update expression for user defined type is not a suitable identifier"
                    let name = QsQualifiedName.New (udt.Namespace, udt.Name)
                    let decl = findUdt context name
                    let root = (buildExpression lhsEx) <|.|> (ident "Data")
                    let items = getAllItems root decl.Type
                    let rec buildArg  = function 
                        | QsTuple args -> args |> Seq.map buildArg |> Seq.toList |> ``tuple``
                        | QsTupleItem (Named item) when item.VariableName.Value = itemName.Value -> 
                            items.Dequeue() |> ignore
                            captureExpression rhsEx
                        | QsTupleItem _ -> items.Dequeue()
                    ``new`` (``type`` [ justTheName context name ]) ``(`` [buildArg decl.TypeItems] ``)``                       
                | _ -> failwith "copy-and-update expressions are currently only supported for arrays and user defined types"

        and buildTuple many : ExpressionSyntax = 
            many |> Seq.map captureExpression |> Seq.toList |> ``tuple`` // captured since we rely on the native C# tuples 

        and buildPartial (partialType : ResolvedType) typeParamResolutions opEx args =
            let (pIn, pOut) = inAndOutputType partialType     // The type of the operation constructed by partial application
            let (oIn, _) = inAndOutputType opEx.ResolvedType  // The type of the operation accepting the partial tuples.

            let buildPartialMapper () = // may only be executed if there are no more type parameters to be resolved                
                let argName = nextArgName()
                let items = getAllItems (``ident`` argName) pIn

                let rec argMapping (expr : TypedExpression) =
                    let rec buildMissing = function
                        | Tuple ts -> ts |> Seq.toList |> List.map buildMissing |> ``tuple``
                        | _ -> items.Dequeue()                  
                  
                    match expr with 
                    | Missing -> buildMissing expr.ResolvedType
                    | Tuple vt -> 
                        match expr.ResolvedType with
                        | Tuple ts when ts.Length = vt.Length ->
                            vt  |> Seq.zip ts  |> Seq.toList
                                |> List.map (fun (t,v) -> argMapping {v with ResolvedType = t})
                                |> ``tuple``
// TODO: Diagnostics.
                        | _ -> failwith "invalid input to code gen in partial application"
                    | Item ex -> captureExpression ex
// TODO: Diagnostics.
                    | _ -> failwith "partial application contains an error expression"
                
                let resolvedOrigInputT = ResolvedType.ResolveTypeParameters typeParamResolutions oIn
                let mapper =  [ ``() =>`` [argName] (argMapping {args with ResolvedType = resolvedOrigInputT}) ]
                ``new`` (generic "Func"  ``<<`` [ (roslynTypeName context pIn); (roslynTypeName context resolvedOrigInputT) ] ``>>``) ``(`` mapper ``)``           

            // Checks if the expression still has type parameters.
            // If it does, we can't create the PartialMapper at compile time
            // so we just build a partial-tuple and let it be resolved at runtime.
            let op = buildExpression opEx
            let values =
                if hasTypeParameters [ pIn; pOut ] then args |> captureExpression
                else buildPartialMapper()
            op <.> (``ident`` "Partial", [ values ])

        and buildNewUdt n args =
            ``new`` (``type`` [ justTheName context n ]) ``(`` [args |> captureExpression] ``)``   

        and buildApply returnType op args =            
            // Checks if the expression points to a non-generic user-defined callable.
            // Because these have fully-resolved types in the runtime,
            // they don't need to have the return type explicitly in the apply.
            let isNonGenericCallable() =     
                match op.Expression with
                | Identifier (_, Value tArgs) when tArgs.Length > 0 -> false
                | Identifier (id, _) -> 
                    match id with
                    | GlobalCallable n ->
                        let sameName = match context.current with | None -> false | Some name -> n = name
                        if sameName then        // when called recursively, we always need to specify the return type.
                            false
                        else
                            not (hasTypeParameters [op.ResolvedType]) 
                    | _ -> 
                        false
                | _ ->
                    false
            let useReturnType = 
                match returnType.Resolution with
                | QsTypeKind.UnitType ->
                    false
                | _ -> 
                    not (isNonGenericCallable())
            let apply = if useReturnType then (ident (sprintf "Apply<%s>" (roslynTypeName context returnType))) else (ident "Apply")
            buildExpression op <.> (apply, [args |> captureExpression]) // we need to capture to guarantee that the result accurately reflects any indirect binding of arguments

        and buildConditional c t f =
            let cond  = c |> buildExpression
            let whenTrue  = t |> captureExpression
            let whenFalse = f |> captureExpression
            ``?`` cond (whenTrue, whenFalse)

        and buildRange lhs rEnd =
            let args = lhs.Expression |> function
                | RangeLiteral (start,step) ->
                    [ (buildExpression start); (buildExpression step); (buildExpression rEnd) ]
                | _ ->
                    [ (buildExpression lhs); (buildExpression rEnd) ]
            ``new`` (``type`` ["QRange"]) ``(`` args ``)``

        and buildValueArray at elems =
            match at.Resolution |> QArrayType with
            | Some arrayType -> ``new`` arrayType ``(`` (elems |> Seq.map captureExpression |> Seq.toList) ``)``
// TODO: diagnostics.
            | _ -> failwith ""
            
        and buildNewArray b count = 
            let arrayType = (ArrayType b |> QArrayType).Value 
            arrayType <.> (ident "Create", [count |> buildExpression])

        and buildArrayItem a i = 
            match i.ResolvedType.Resolution with
            | Range -> ``invoke`` ((buildExpression a) <|?.|> (ident "Slice")) ``(`` [ (buildExpression i) ] ``)`` 
            | _ -> ``item`` (buildExpression a) [ (buildExpression i) ] 
           
        let buildBlock (block : QsScope) = 
            let builder = new StatementBlockBuilder(context)
            builder.SetStartLine startLine
            builder.Transform block |> ignore
            builder.Statements

        let buildSymbolTuple buildTuple buildSymbol symbol = 
            let rec buildOne = function
// TODO: Diagnostics
                | InvalidItem            -> failwith ("InvalidItem received")
                | VariableName one       -> one.Value |> buildSymbol
                | VariableNameTuple many -> many |> Seq.map buildOne |> Seq.toList |> buildTuple
                | DiscardedItem          -> "_" |> buildSymbol
            // While _ inside C# tuple destructs will properly discard the assignment, 
            // _ can also be used as variable name in C# where a repeated usage will lead to a compilation error.
            // We hence auto-generate a name for discarded Q# bindings.
            match symbol with
            | DiscardedItem -> nextArgName() |> buildSymbol
            | _ -> buildOne symbol

        let buildSymbolNames buildName = 
            buildSymbolTuple (String.concat "," >> sprintf "(%s)") buildName 

        /// returns true if a value of this type contains any arrays
        /// -> in particular, this does not include the in- and output type of callables
        let rec containsArrays (t : ResolvedType) = 
            match t.Resolution with 
            | TupleType ts -> ts |> Seq.exists containsArrays
            | ArrayType _ -> true
            | _ -> false // no need to check types within callables
           
        /// returns true if the given expression initializes a new QArray instance
        let rec isArrayInit ex = 
            match ex.Expression with 
            | CopyAndUpdate _ | NewArray _ | ADD _ | ValueArray _ -> true
            | CONDITIONAL (_, l, r) -> isArrayInit l && isArrayInit r
            | _ -> false

        member val Statements = [] with get, set

        member this.StartLine 
          with get() = startLine
          and set(value) = startLine <- value

        member this.LineNumber
          with get() = lineNumber
          and set(value) = lineNumber <- value

        member this.AddStatement (s:StatementSyntax) =
            this.Statements <- this.Statements @ [s |> withLineNumber]

        override this.onExpressionStatement (node:TypedExpression) =
            buildExpression node
            |> (statement >> this.AddStatement)
            QsExpressionStatement node

        override this.onReturnStatement (node:TypedExpression) =
            buildExpression node
            |> Some
            |> ``return``
            |> this.AddStatement
            QsReturnStatement node

        override this.onVariableDeclaration (node:QsBinding<TypedExpression>) = 
            let bindsArrays = node.Rhs.ResolvedType |> containsArrays
            let rhs = node.Rhs |> captureExpression 
            let buildBinding buildName = 
                let lhs = node.Lhs |> buildSymbolNames buildName
                if bindsArrays then // we need to cast to the correct type here (in particular to IQArray for arrays)
                    let t = roslynTypeName context node.Rhs.ResolvedType
                    ``var`` lhs (``:=`` <| ``cast`` t rhs ) |> this.AddStatement 
                else ``var`` lhs (``:=`` <| rhs ) |> this.AddStatement

            match node.Kind with 
            | MutableBinding ->
                match node.Lhs with 

                // no need to insert a destructing statement first
                | VariableName varName -> 
                    match node.Rhs.ResolvedType.Resolution |> QArrayType with 
                    | Some _ when isArrayInit node.Rhs -> // avoid unnecessary copies on construction
                        ``var`` varName.Value (``:=`` <| rhs ) |> this.AddStatement
                    | Some arrType -> // we need to make sure to bind to a new QArray instance here
                        let qArray = ``new`` arrType ``(`` [rhs] ``)``
                        ``var`` varName.Value (``:=`` <| qArray ) |> this.AddStatement
                    | _ -> buildBinding id

                // we first need to destruct here, and then make sure all QArrays are built
                | VariableNameTuple _ when bindsArrays -> 
                    // insert a destructing statement
                    let prefix = nextArgName()
                    let imName = sprintf "%s%s__" prefix
                    buildBinding imName 

                    // build the actual binding, making sure all necessary QArrays instances are created
                    for localVar in this._Scope.DeclarationsInStatement.Variables do  
                        let varName = localVar.VariableName.Value
                        match localVar.Type.Resolution |> QArrayType with 
                        | Some arrType -> 
                            let qArray = ``new`` arrType ``(`` [ident (imName varName)] ``)``
                            ``var`` varName (``:=`` <| qArray) |> this.AddStatement
                        | _ -> ``var`` varName (``:=`` <| ident (imName varName)) |> this.AddStatement 
                | _ -> buildBinding id 
            | _ -> buildBinding id
            QsVariableDeclaration node

        override this.onValueUpdate (node:QsValueUpdate) =
            let rec varNames onTuple onItem (ex : TypedExpression) = 
                match ex.Expression with 
                | MissingExpr -> onItem "_"
                | Identifier (LocalVariable id, Null) -> onItem id.Value
                | ValueTuple vs -> vs |> Seq.map (varNames onTuple onItem) |> onTuple
// TODO: diagnostics.
                | _ -> failwith "unexpected expression in lhs of value update"

            let lhs, rhs = buildExpression node.Lhs, captureExpression node.Rhs
            match node.Lhs.Expression with 
            | MissingExpr -> ``var`` (nextArgName()) (``:=`` <| buildExpression node.Rhs) |> this.AddStatement 

            // no need to insert a destructing statement first
            | Identifier (LocalVariable id, Null) -> 
                let matchesIdentifier (ex : TypedExpression) = 
                    match ex.Expression with 
                    | Identifier (LocalVariable rhsId, Null) when rhsId.Value = id.Value -> true
                    | _ -> false
                let isArray = function | ArrayType _ -> true | _ -> false
                match node.Rhs.Expression with 
                | CopyAndUpdate (l, a, r) when l |> matchesIdentifier && l.ResolvedType.Resolution |> isArray -> // we do an in-place modification in this case
                    let access, rhs = buildExpression a, captureExpression r
                    (buildExpression l) <.> (``ident`` "Modify", [ access; rhs ]) |> statement |> this.AddStatement
                | _ when node.Rhs |> matchesIdentifier -> () // unnecessary statement 
                | _ -> node.Rhs.ResolvedType.Resolution |> QArrayType |> function
                    | Some _ when isArrayInit node.Rhs -> // avoid unnecessary copies here 
                        lhs <-- rhs |> statement |> this.AddStatement 
                    | Some arrType -> // we need to make sure to bind to a new QArray instance here
                        let qArray = ``new`` arrType ``(`` [rhs] ``)``
                        lhs <-- qArray |> statement |> this.AddStatement
                    | _ -> lhs <-- rhs |> statement |> this.AddStatement

            // we first need to destruct here, and then make sure all QArrays are built
            | _ when containsArrays node.Rhs.ResolvedType -> 
                // insert a destructing statement
                let prefix = nextArgName()
                let imName name = if name = "_" then name else sprintf "%s%s__" prefix name
                let tempBinding = varNames (fun ids -> String.Join (",", ids) |> sprintf "(%s)") imName node.Lhs
                ``var`` tempBinding (``:=`` <| rhs ) |> this.AddStatement 

                // build the actual binding, making sure all necessary QArrays instances are created
                let ids = varNames (Seq.collect id) (fun id -> seq{ if id <> "_" then yield id}) node.Lhs
                for id in ids do 
                    let decl = this._Scope.DeclarationsInScope.Variables |> Seq.tryFind (fun d -> d.VariableName.Value = id)
                    match decl |> Option.map (fun d -> d.Type.Resolution |> QArrayType) |> Option.flatten with 
                    | Some arrType -> // we need to make sure to create a new QArray instance here
                        let qArray = ``new`` arrType ``(`` [imName id |> ident] ``)``
                        (ident id) <-- qArray |> statement |> this.AddStatement
                    | _ -> (ident id) <-- (imName id |> ident) |> statement |> this.AddStatement 

            | _ -> lhs <-- rhs |> statement |> this.AddStatement
            QsValueUpdate node

        override this.onConditionalStatement (node:QsConditionalStatement) =    
            let all   = node.ConditionalBlocks
            let (cond, thenBlock) = all.[0]
            let cond  = cond |> buildExpression
            let thenBlock  = thenBlock.Body |> buildBlock
            let others = [ 
                for i in 1 .. all.Length - 1 -> 
                let (cond, block) = all.[i]
                cond |> buildExpression, block.Body |> buildBlock ]
            let elseBlock = 
                match node.Default with 
                | Null -> None
                | Value block -> ``else`` (buildBlock block.Body) |> Some
            ``if`` ``(`` cond ``)`` thenBlock (``elif`` others elseBlock)
            |> this.AddStatement
            QsConditionalStatement node
               
        override this.onForStatement (node:QsForStatement) =
            let sym   = node.LoopItem |> fst |> buildSymbolNames id
            let range = node.IterationValues |> captureExpression
            let body  = node.Body |> buildBlock
            ``foreach`` ``(`` sym ``in`` range  ``)`` body
            |> this.AddStatement
            QsForStatement node

        override this.onWhileStatement (node:QsWhileStatement) =
            let cond   = node.Condition |> buildExpression
            let body  = node.Body |> buildBlock
            ``while`` ``(`` cond  ``)`` body
            |> this.AddStatement
            QsWhileStatement node
                                
        override this.onRepeatStatement rs =        
            let buildTest test fixup =
                let condition = buildExpression test
                let thens = [``break``]
                let elses = buildBlock fixup
                ``if`` ``(`` condition ``)`` thens (Some (``else`` elses))

            ``while`` ``(`` ``true`` ``)`` 
                ((buildBlock rs.RepeatBlock.Body) @ [buildTest rs.SuccessCondition rs.FixupBlock.Body])
            |> this.AddStatement
            QsRepeatStatement rs

        override this.onQubitScope (using:QsQubitScope) = 
            let (alloc, release) = 
                match using.Kind with 
                | Allocate -> ("Allocate", "Release")
                | Borrow   -> ("Borrow", "Return")
            let rec removeDiscarded sym = 
                match sym with
                | VariableName _         -> sym
                | DiscardedItem          -> nextArgName() |>  NonNullable<string>.New |> VariableName
                | VariableNameTuple many -> many |> Seq.map removeDiscarded |> ImmutableArray.CreateRange |> VariableNameTuple
                | InvalidItem            -> failwith ("InvalidItem received")
            let rec buildInitializeExpression (exp:ResolvedInitializer) = 
                match exp.Resolution with
                | SingleQubitAllocation     -> ((ident alloc) <.> (ident "Apply", [])) 
                | QubitRegisterAllocation e -> ((ident alloc) <.> (ident "Apply", [ (buildExpression e) ])) 
                | QubitTupleAllocation many -> many |> Seq.map buildInitializeExpression |> List.ofSeq |> ``tuple``
// todo: diagnostics
                | InvalidInitializer -> failwith ("InvalidInitializer received")
            let rec buildReleaseExpression (symbol,expr:ResolvedInitializer) : StatementSyntax list =
                let currentLine = lineNumber
                lineNumber <- Some 0
                let buildOne sym =
                    (ident release) <.> (ident "Apply", [ (ident (sym)) ]) |> (statement >> withLineNumber)
                let rec buildDeconstruct sym (rhs:ResolvedInitializer) =
                    match rhs.Resolution with
                    | SingleQubitAllocation     -> [ buildOne sym ]
                    | QubitRegisterAllocation _ -> [ buildOne sym ]
                    | QubitTupleAllocation aa   -> aa |> Seq.mapi (fun i e -> buildDeconstruct (sprintf "%s.Item%d" sym (i + 1)) e) |> Seq.toList |> List.concat
                    | InvalidInitializer -> failwith ("InvalidInitializer received")
                let releases =
                    match (symbol, expr.Resolution) with
                    | VariableName one, SingleQubitAllocation       -> [ buildOne one.Value ]
                    | VariableName one, QubitRegisterAllocation _   -> [ buildOne one.Value ]
                    | VariableName one, QubitTupleAllocation _      -> (buildDeconstruct one.Value expr) 
                    | VariableNameTuple ss, QubitTupleAllocation aa -> Seq.zip ss aa |> Seq.map buildReleaseExpression |> Seq.toList |> List.concat
                    | _ -> failwith ("InvalidItem received")
                lineNumber <- currentLine
                releases    
                
            let symbols = removeDiscarded using.Binding.Lhs
            let exDispatchInfoName = nextArgName() 
            let exDispatchInfoHandle = ident exDispatchInfoName
            let caughtEx = nextArgName()

            // allocations and deallocations
            let lhs = symbols |> buildSymbolNames id
            let rhs = using.Binding.Rhs |> buildInitializeExpression
            let allocation = ``var`` lhs (``:=`` <| rhs ) |> withLineNumber
            let deallocation = buildReleaseExpression (symbols, using.Binding.Rhs)

            // To force that exceptions thrown during the execution of the allocation scope take precedence over the ones thrown upon release
            // we catch all exceptions in a variable and throw after releaseing if necessary. 

            // System.Runtime.ExceptionServices.ExceptionDispatchInfo is used to keep all call stack information when rethrowing
            let exceptionHandle = ``typed var`` "System.Runtime.ExceptionServices.ExceptionDispatchInfo" exDispatchInfoName (``:=`` ``null`` |> Some) |> ``#line hidden`` :> StatementSyntax
            
            let catch = 
                let setEx = exDispatchInfoHandle <-- ``invoke`` (ident "System.Runtime.ExceptionServices.ExceptionDispatchInfo.Capture") ``(`` [ident caughtEx] ``)`` |> statement
                ``catch`` (Some ("Exception", caughtEx)) [setEx; ``throw`` None] // use standard mechanism to rethrow the exception by using "throw;"
            let finallyBlock = 
                let condition = exDispatchInfoHandle .!=. ``null``
                let rethrow = ``invoke`` (exDispatchInfoHandle <|.|> (ident "Throw")) ``(`` [] ``)`` |> statement // rethrow that keeps the call stack unchanged
                let throwIfNecessary = ``if`` ``(`` condition ``)`` [rethrow] None 
                throwIfNecessary :: deallocation
            let body = ``try`` (buildBlock using.Body) [catch |> ``#line hidden``] (``finally`` finallyBlock |> ``#line hidden`` |> Some)
            let statements = [allocation; exceptionHandle; body]

            // Put all statements into their own brackets so variable names have their own context.
            // Make sure the brackets get #line hidden:
            let currentLine = lineNumber
            lineNumber <- lineNumber |> Option.map (fun _ -> 0)
            ``{{`` statements ``}}`` |> this.AddStatement
            lineNumber <- currentLine
            QsQubitScope using

        override this.onFailStatement fs = 
            let failException = ``new`` (``type`` ["ExecutionFailException"]) ``(`` [ (buildExpression fs) ] ``)``
            this.AddStatement (``throw`` <| Some failException)
            QsFailStatement fs

    type SyntaxBuilder (bodyBuilder) = 
        inherit SyntaxTreeTransformation<StatementBlockBuilder>(bodyBuilder)

        override this.beforeSpecialization (sp : QsSpecialization) = 
            count <- 0
            this._Scope.SetStartLine (Some (sp.Location.Offset |> fst))
            sp
    
    let operationDependencies context (od:QsCallable) =
        let seeker = new OperationsSeeker(context)
        (SyntaxTreeTransformation<_>(seeker)).dispatchCallable(od) |> ignore
        seeker.Operations |> Seq.toList

    let getOpName context n = 
        if needsFullPath context n then prependNamespaceString n
        else if isCurrentOp context n then Directives.Self
        else n.Name.Value

    let getTypeOfOp context (n: QsQualifiedName) =
        let name =
            let sameNamespace = match context.current with | None -> false | Some o -> o.Namespace = n.Namespace
            let opName = if sameNamespace then n.Name.Value else n.Namespace.Value + "." + n.Name.Value
            if isGeneric context n then
                let signature = context.allCallables.[n].Signature
                let tIn = signature.ArgumentType
                let tOut = signature.ReturnType
                let count = (getTypeParameters [tIn;tOut]).Length 
                sprintf "%s<%s>" opName (String.replicate (count - 1) ",")
            else 
                opName
        ``invoke`` (ident "typeof") ``(`` [ident name] ``)``

    /// Returns the list of statements of the contructor's body for the given operation.
    let buildInit context (operations : QsQualifiedName list)  =
        let parameters = []
        let body =
            let buildOne n  =
                let name = getOpName context n
                let lhs = ident "this" <|.|> ident name
                let rhs = 
                    if (isCurrentOp context n) && not (isGeneric context n) then 
                        "this" |> ident :> ExpressionSyntax
                    else
                        let signature = roslynCallableTypeName context n
                        let factoryGet = (ident "this" <|.|> ident "Factory" <|.|> (generic "Get" ``<<`` [ signature ] ``>>``))
                        (``invoke`` factoryGet ``(`` [ (getTypeOfOp context n) ] ``)``)
                statement (lhs <-- rhs)
            operations
            |> List.map buildOne        
        ``method`` "void"  "Init" ``<<`` [] ``>>`` 
            ``(`` parameters ``)``  
            [  ``public``; ``override``  ]
            ``{`` body ``}``
        :> MemberDeclarationSyntax
    
    /// Returns the contructor for the given operation.
    let buildConstructor context name : MemberDeclarationSyntax =
        ``constructor`` name ``(`` [ ("m", (``type`` "IOperationFactory")) ] ``)`` 
            ``:`` [ "m" ]
            [ ``public`` ]
            ``{`` [] ``}``
        :> MemberDeclarationSyntax     
       
    /// For each Operation used in the given OperationDeclartion, returns
    /// a Property that returns an instance of the operation by calling the 
    /// IOperationFactory
    let buildOpsProperties context (operations : QsQualifiedName list): MemberDeclarationSyntax list =
        let buildOne n =
            /// eg:
            /// protected opType opName { get; }
            let signature = roslynCallableTypeName context n
            let name = getOpName context n
            ``prop`` signature name [ ``protected`` ] 
            :> MemberDeclarationSyntax
        operations
        |> List.map buildOne

    let buildSpecializationBody context (sp:QsSpecialization) =
        match sp.Implementation with
        | Provided (args, _) ->           
            let returnType  = sp.Signature.ReturnType
            let statements  =
                let builder = new StatementBlockBuilder(context)
                (SyntaxBuilder(builder)).dispatchSpecialization sp |> ignore
                builder.Statements

            let inData = ``ident`` "__in__"
            let ret = 
                match returnType.Resolution with
                | QsTypeKind.UnitType ->
                    [ 
                        ``#line hidden`` <| 
                        ``return`` ( Some ((``ident`` "QVoid") <|.|> (``ident`` "Instance")) ) 
                    ]
                | _ ->
                    []
            let (argName, argsInit) =
//TODO: diagnostics.
                let name = function | ValidName n -> n.Value | InvalidName -> ""
                let rec buildVariableName = function
                    | QsTupleItem  one -> one.VariableName |> name
                    | QsTuple     many -> "(" + (many |> Seq.map buildVariableName |> String.concat ",") + ")"
                match args with
                | QsTupleItem one -> (one.VariableName |> name, [])
                | QsTuple many    ->
                    if many.Length = 0 then 
                        ("__in__", [])
                    elif many.Length = 1 then 
                        ("__in__", [ ``var`` (buildVariableName many.[0]) (``:=`` <| inData) ])
                    else 
                        ("__in__", [ ``var`` (buildVariableName args) (``:=`` <| inData) ])

            Some (``() => {}`` [ argName ] (argsInit @ statements @ ret) :> ExpressionSyntax)
        | Generated SelfInverse -> 
            let adjointedBodyName = 
                match sp.Kind with 
                | QsAdjoint           -> "Body"
                | QsControlledAdjoint -> "ControlledBody"
//TODO: diagnostics.
                | _ -> "Body"
            Some (``ident`` adjointedBodyName :> ExpressionSyntax)
        | _ -> 
            None
        
    let buildSpecialization context (sp:QsSpecialization) : (PropertyDeclarationSyntax * _) option =
        let inType  = roslynTypeName context sp.Signature.ArgumentType
        let outType = roslynTypeName context sp.Signature.ReturnType
        let propertyType = "Func<" + inType + ", " + outType + ">"
        let bodyName = 
            match sp.Kind with 
            | QsBody              -> "Body"
            | QsAdjoint           -> "Adjoint"
            | QsControlled        -> "Controlled"
            | QsControlledAdjoint -> "ControlledAdjoint"
        let body = (buildSpecializationBody context sp)
        let attribute = 
            // since the line numbers throughout the generated code are 1-based, let's also choose them 1-based here
            let startLine = fst sp.Location.Offset + 1
            let endLine = 
                match context.declarationPositions.TryGetValue sp.SourceFile with 
                | true, startPositions -> 
                    let index = startPositions.IndexOf sp.Location.Offset
                    if index + 1 >= startPositions.Count then -1 else fst startPositions.[index + 1] + 1
//TODO: diagnostics.
                | false, _ -> startLine
            ``attribute`` None (ident "SourceLocation") [ 
                ``literal`` sp.SourceFile.Value 
                ``ident`` "OperationFunctor" <|.|> ``ident`` bodyName 
                ``literal`` startLine 
                ``literal`` endLine
            ]

        match body with 
        | Some body ->
            let bodyName = if bodyName = "Body" then bodyName else bodyName + "Body"
            let impl = 
                ``property-arrow_get`` propertyType bodyName [``public``; ``override``]
                    ``get``
                    (``=>`` body)
            Some (impl, attribute)
        | None ->
            None        

    /// Returns a flat list (name, type) with all the named parameters of a DeconstructedTuple
    let flatArgumentsList context args = 
        let rec flatOne found = function
            | QsTupleItem one ->
                match one.VariableName with
                | ValidName n -> found @ [n.Value, one.Type |> roslynTypeName context]
                | InvalidName -> found
            | QsTuple many ->       
                many |> Seq.fold flatOne found
        args
        |> flatOne [] 

    let buildRun context className arguments argumentType returnType : MemberDeclarationSyntax =
        let inType =  roslynTypeName context argumentType 
        let outType = roslynTypeName context returnType

        let task = sprintf "System.Threading.Tasks.Task<%s>" outType
        let flatArgs = arguments |> flatArgumentsList context
        let opFactoryTypes =  [ className; inType; outType ]

        let runArgs = 
            if (isTuple argumentType.Resolution) then 
                let rec buildTuple = function
                    | QsTupleItem one ->
                        match one.VariableName with
                        | ValidName n -> ``ident`` n.Value  :> ExpressionSyntax
                        | InvalidName -> ``ident`` ""       :> ExpressionSyntax
                    | QsTuple many ->       
                        many |> Seq.map buildTuple |> List.ofSeq |> ``tuple``
                buildTuple arguments
            else
                match flatArgs with 
                | []        -> (``ident`` "QVoid") <|.|> (``ident`` "Instance")
                | [(id, _)] -> ``ident`` id :> ExpressionSyntax
                | _         -> flatArgs |> List.map (fst >> ``ident``)  |> ``tuple``
       
        let uniqueArgName = "__m__"
        let body = 
            [ 
                ``return`` (Some ((``ident`` uniqueArgName) <.> (``generic`` "Run" ``<<`` opFactoryTypes ``>>``, [ runArgs ])))
            ]

        let args = 
            (``param`` uniqueArgName ``of`` (``type`` "IOperationFactory") ) 
            :: (flatArgs |> List.map (fun (name, roslynType) -> (``param`` name ``of`` (``type`` roslynType)) ) )         
        ``method`` task "Run" ``<<`` [] ``>>`` 
            ``(`` args ``)``  
            [``public``; ``static``]
            ``{`` body ``}``
        :> MemberDeclarationSyntax
    
    let findUdtBase context n =
        let udt = findUdt context n
        udt.Type

    let rec canHaveQubits context (qsharpType:ResolvedType) = 
        match qsharpType.Resolution with
        | QsTypeKind.Qubit              -> true
        | QsTypeKind.ArrayType at       -> canHaveQubits context at
        | QsTypeKind.TupleType tt       -> tt |> Seq.fold (fun state m -> state || canHaveQubits context m) false 
        | QsTypeKind.UserDefinedType  n ->
            QsQualifiedName.New (n.Namespace, n.Name)
            |> findUdtBase context 
            |> canHaveQubits context
        | QsTypeKind.Operation _
        | QsTypeKind.Function  _        -> true
        | QsTypeKind.TypeParameter _    -> true
        | _                             -> false

    let findQubitFields context (qsharpType:ResolvedType) =  
        let item_n n= ``ident`` (sprintf "Item%d" (n+1))

        let rec buildSimpleTerm current nullable (t:ResolvedType) =
            match t.Resolution with
            | QsTypeKind.Qubit ->
                [ t, current ]
            | QsTypeKind.Operation _
            | QsTypeKind.Function  _ 
            | QsTypeKind.TypeParameter _
            | QsTypeKind.ArrayType _ ->
                if canHaveQubits context t then
                    [ t, current ]
                else
                    []
            | QsTypeKind.UserDefinedType n  ->
                QsQualifiedName.New (n.Namespace, n.Name)
                |> findUdtBase context 
                |> buildSimpleTerm (current <|?.|> (``ident`` "Data")) false
            | QsTypeKind.TupleType tt ->
                let buildOne j t =
                    if nullable then 
                        buildSimpleTerm (current <|?.|> (item_n j)) false t
                    else 
                        buildSimpleTerm (current <|.|>  (item_n j)) false t
                tt  |> Seq.mapi buildOne |> List.concat
            | _ ->
                []
        match qsharpType.Resolution with
        | QsTypeKind.TupleType many  -> 
            many |> Seq.mapi ( fun j -> buildSimpleTerm ( ``ident`` "Data" <|.|> item_n j ) false ) |> List.concat
        | one -> 
            qsharpType |> buildSimpleTerm ( ``ident`` "Data" ) true

    let areAllQubitArgs (argsTypes:ResolvedType list) =
        let isOne = function
        | QsTypeKind.Qubit -> true
        | _       -> false
        argsTypes |> List.fold (fun st t -> st && isOne t.Resolution) true

    let buildQubitsField context (qsharpType:ResolvedType) =        
        let fields =  qsharpType |> findQubitFields context 
        let (fieldTypes, fieldPaths) = fields  |> List.unzip
        if areAllQubitArgs fieldTypes then
            let buildOne path = ``yield return`` path
            match fieldPaths with 
            | [] -> 
                ``property-arrow_get`` "System.Collections.Generic.IEnumerable<Qubit>" "IApplyData.Qubits" [] 
                    ``get`` (``=>`` ``null``)
            | _  ->
                ``property-get`` "System.Collections.Generic.IEnumerable<Qubit>" "IApplyData.Qubits" [] 
                    ``get`` (fieldPaths |> List.map buildOne)
            :> MemberDeclarationSyntax
        else
            let buildOne (field: ResolvedType * ExpressionSyntax) = 
                let t = field |> fst 
                match t.Resolution with
                | QsTypeKind.Function _
                | QsTypeKind.Operation _
                | QsTypeKind.ArrayType _
                | QsTypeKind.UserDefinedType _
                | QsTypeKind.Qubit -> ``((`` ( ``cast`` "IApplyData" (field |> snd) ) ``))`` <|?.|> ``ident`` "Qubits"
                | _       -> (field |> snd)  <?.>  ( ``ident`` "GetQubits", [] )
            let body = 
                match fields with
                | []     -> ``null`` :> ExpressionSyntax
                | [one]  -> buildOne one
                | many   -> ( ``ident`` "Qubit" <.> (``ident`` "Concat", fields |> List.map buildOne) )
            ``property-arrow_get`` "System.Collections.Generic.IEnumerable<Qubit>" "IApplyData.Qubits" [] 
                ``get`` (``=>`` body)
            :> MemberDeclarationSyntax
        |> List.singleton
           
    let buildName name =
        ``property-arrow_get`` "String" "ICallable.Name" [ ] 
            ``get`` (``=>`` (``literal`` name) )
        :> MemberDeclarationSyntax

    let buildFullName (name : QsQualifiedName) =
        let fqn =
            let ns = name.Namespace.Value
            let n  = name.Name.Value
            if ns = "" then n else ns + "." + n
        ``property-arrow_get`` "String" "ICallable.FullName" [ ] 
            ``get`` (``=>`` (``literal`` fqn) )
        :> MemberDeclarationSyntax

    let buildDataWrapper context name qsharpType =
        let buildDataClass =
            let buildValueTupleConstructor =
                let args = [ ("data", ``type`` (roslynTypeName context qsharpType)) ]
                ``constructor`` name ``(`` args ``)`` 
                    ``:`` [ "data" ]
                    [ ``public`` ]
                    ``{``
                        []
                    ``}``
                :> MemberDeclarationSyntax
            let baseClass     = ``simpleBase`` (tupleBaseClassName context qsharpType)
            let modifiers     = [ ``public`` ]
            let constructors  = [ buildValueTupleConstructor ]
            let qubitsField   = buildQubitsField context qsharpType
            ``class`` name ``<<`` [] ``>>``
                ``:`` (Some baseClass) ``,`` [ ``simpleBase`` "IApplyData" ] modifiers
                ``{``
                    (constructors @ qubitsField)
                ``}``
            :> MemberDeclarationSyntax
        let buildMethod t body =  
            let baseType = (roslynTypeName context t)
            let args     = [ (``param`` "data" ``of`` (``type`` (roslynTypeName context t)) ) ]
            ``arrow_method`` "IApplyData" (sprintf "__data%s" name) ``<<`` [] ``>>`` 
                ``(`` args ``)``  
                [``public``; ``override``]
                ( Some ( ``=>`` body) )
            :> MemberDeclarationSyntax

        match qsharpType.Resolution with
        | QsTypeKind.UnitType       
        | QsTypeKind.Qubit                  
        | QsTypeKind.UserDefinedType _
        | QsTypeKind.ArrayType _ -> 
            (``ident`` "data") |> buildMethod qsharpType, None
        | QsTypeKind.TupleType vt -> 
            ( ``new`` (``type`` name) ``(`` [ ``ident`` "data" ] ``)`` ) |> buildMethod qsharpType , (Some buildDataClass)
        | _                 -> 
            ( ``new`` (``generic`` "QTuple" ``<<`` [ roslynTypeName context qsharpType ] ``>>``) ``(`` [ ``ident`` "data" ] ``)`` ) |> buildMethod qsharpType, None

    let typeParametersNames signature = 
// TODO Diagnostics
        let name = function | ValidName n -> sprintf "__%s__" n.Value | InvalidName -> "__"
        signature.TypeParameters |> Seq.map name  |> Seq.sort |> Seq.toList

    let findClassName context (op: QsCallable)  =
        let name = op.FullName.Name.Value
        let typeParameters = typeParametersNames op.Signature
        let nonGeneric = if typeParameters.IsEmpty then name else sprintf "%s<%s>" name (String.Join(",", typeParameters))   
        (name, nonGeneric)

    let isAbstract op = 
        let isBody (sp:QsSpecialization) = match sp.Kind with | QsBody when sp.Implementation <> Intrinsic -> true | _ -> false
        not (op.Specializations |> Seq.exists isBody)

    let isFunction (op:QsCallable) = match op.Kind with | Function -> true | _ -> false

    // Builds the .NET class for the given operation.
    let buildOperationClass (globalContext:CodegenContext) (op: QsCallable) =
        let context = globalContext.setCallable op
        let (name, nonGenericName) = findClassName context op
        let opNames = operationDependencies context op
        
        let constructors = [ (buildConstructor context name) ]
  
        let properties = buildName name :: buildFullName context.current.Value :: buildOpsProperties context opNames
            
        let baseOp =
            if isFunction op then 
                "Function"
            else
                let (adj, ctrl) = op.Signature.Information.Characteristics.SupportedFunctors |> hasAdjointControlled
                match (adj, ctrl) with 
                | (false , false) -> "Operation"
                | (true  , false) -> "Adjointable"
                | (false , true ) -> "Controllable"
                | (true  , true ) -> "Unitary"
        let inType   = op.Signature.ArgumentType |> roslynTypeName context
        let outType  = op.Signature.ReturnType   |> roslynTypeName context
  
        let typeArgsInterface = if (baseOp = "Operation" || baseOp = "Function") then [inType; outType] else [inType]
        let typeParameters = typeParametersNames op.Signature
        let baseClass = genericBase baseOp ``<<`` typeArgsInterface ``>>``
        let bodies, attr = 
            op.Specializations |> Seq.map (buildSpecialization context) |> Seq.choose id |> Seq.toList 
            |> List.map (fun (x, y) -> (x :> MemberDeclarationSyntax, y)) |> List.unzip
        let inData  = (buildDataWrapper context "In"  op.Signature.ArgumentType) 
        let outData = (buildDataWrapper context "Out" op.Signature.ReturnType)
        let innerClasses = [ inData |> snd;  outData |> snd ] |> List.choose id
        let methods = [ opNames |> buildInit context; inData |> fst;  outData |> fst; buildRun context nonGenericName op.ArgumentTuple op.Signature.ArgumentType op.Signature.ReturnType ]
  
        let modifiers = 
            if isAbstract op then            
                [``public``; ``abstract``; ``partial``]
            else
                [``public``; ``partial`` ]

        ``attributes`` attr (
            ``class`` name ``<<`` typeParameters ``>>``
                ``:`` (Some baseClass) ``,`` [ ``simpleBase`` "ICallable" ] modifiers
                ``{``
                    (constructors @ innerClasses @ properties @ bodies @ methods) 
                ``}``
            )
        :> MemberDeclarationSyntax     

    let isUDTDeclaration =                          function | QsCustomType udt -> Some udt | _ -> None
    let isCallableDeclaration =                     function | QsCallable     c -> Some c   | _ -> None

    let buildUdtClass (globalContext:CodegenContext) (udt: QsCustomType) =
        let context = globalContext.setUdt udt
        let name = udt.FullName.Name.Value
        let qsharpType = udt.Type        
        let buildEmtpyConstructor = 
            let baseTupleType = 
                match qsharpType.Resolution with 
                | ArrayType b -> roslynTypeName context b |> sprintf "QArray<%s>"
                | _ -> (roslynTypeName context qsharpType)
            let defaultValue = match qsharpType.Resolution with | ArrayType _ -> [ sprintf "new %s()" baseTupleType] | _ -> [ sprintf "default(%s)" baseTupleType ]
            let args = []
            ``constructor`` name ``(`` args ``)`` 
                ``:`` defaultValue
                [ ``public`` ]
                ``{``
                    []
                ``}``
            :> MemberDeclarationSyntax
        let buildBaseTupleConstructor =
            let baseTupleType = (roslynTypeName context qsharpType)
            let args = [ ("data", ``type`` baseTupleType) ]
            ``constructor`` name ``(`` args ``)`` 
                ``:`` [ "data" ]
                [ ``public`` ]
                ``{``
                    []
                ``}``
            :> MemberDeclarationSyntax

        let buildNamedItemFields = 
            let items = getAllItems (``ident`` "Data") qsharpType
            let rec buildProps = function 
                | QsTuple items -> items |> Seq.collect (fun i -> buildProps i)
                | QsTupleItem (Anonymous _) -> items.Dequeue() |> ignore; Seq.empty
                | QsTupleItem (Named decl) -> seq { yield
                    ``property-arrow_get`` (roslynTypeName context decl.Type) decl.VariableName.Value [ ``public`` ] 
                        ``get`` (``=>`` (items.Dequeue()))
                    :> MemberDeclarationSyntax}
            buildProps udt.TypeItems |> Seq.toList
        let buildItemFields = 
            let buildOne i t =
                ``property-arrow_get`` (roslynTypeName context t) (sprintf "Item%d" (i+1)) [ ``public`` ] 
                    ``get`` (``=>`` (``ident`` "Data" <|.|> ``ident`` (sprintf "Item%d" (i+1))))
                :> MemberDeclarationSyntax
            match qsharpType.Resolution with
            | QsTypeKind.TupleType many  -> many |> Seq.mapi buildOne |> List.ofSeq
            | _                          -> []            
        let buildDeconstruct =
            let body =
                let buildOne i t =
                    let lhs = ``ident`` (sprintf "item%d" (i+1))
                    let rhs = ``ident`` "Data" <|.|> ``ident`` (sprintf "Item%d" (i+1))
                    statement (lhs <-- rhs)
                match qsharpType.Resolution with
                | QsTypeKind.TupleType many  -> many |> Seq.mapi buildOne |> List.ofSeq
                | _                 -> []
            let parameters =                 
                let buildOneParameter i t =
                    let paramType = t |> roslynTypeName context                    
                    ``out param`` (sprintf "item%d" (i+1)) ``of`` (``type`` paramType)
                match qsharpType.Resolution with
                | QsTypeKind.TupleType many  -> many |> Seq.mapi buildOneParameter  |> List.ofSeq
                | _                 -> []
            ``method`` "void"  "Deconstruct" ``<<`` [] ``>>`` 
                ``(`` parameters ``)``  
                [  ``public``  ]
                ``{`` body ``}``
            :> MemberDeclarationSyntax
           
        let baseClassName = udtBaseClassName context qsharpType
        let baseClass     = ``simpleBase`` baseClassName
        let modifiers     = [ ``public`` ]
        let interfaces    = [ ``simpleBase`` "IApplyData" ] 
        let constructors  = [ buildEmtpyConstructor; buildBaseTupleConstructor ]
        let qubitsField   = buildQubitsField context qsharpType
        let itemFields    = buildNamedItemFields @ buildItemFields
        let allFields     = itemFields @ qubitsField
        let allMethods    = [ buildDeconstruct ]
       
        ``class`` name ``<<`` [] ``>>``
            ``:`` (Some baseClass) ``,`` interfaces modifiers
            ``{``
                (constructors @ allFields @ allMethods)
            ``}``
        :> MemberDeclarationSyntax
           
    // Generates the code for all the elements of the given namespace.
    let buildNamespace globalContext (nsName : NonNullable<string>, localElements : QsNamespaceElement list) = 
        let buildOne = function
            | QsCallable op when op.Kind = TypeConstructor -> None
            | QsCustomType udt -> udt |> buildUdtClass globalContext |> Some
            | QsCallable op    -> op  |> buildOperationClass globalContext |> Some
        let members = 
            localElements
            |> List.map buildOne
            |> List.choose id

        ``#line hidden`` <| 
        ``namespace`` nsName.Value
            ``{``
                []
                members
            ``}``
        :> MemberDeclarationSyntax
   

    // Returns only those namespaces and their elements that are defined for the given file.
    let findLocalElements fileName syntaxTree =
        let path = 
            match CompilationBuilder.CompilationUnitManager.TryGetUri fileName with 
            | true, uri -> uri.AbsolutePath |> NonNullable<string>.New
            | false, _ -> NonNullable<string>.New ""
        syntaxTree
        |> Seq.map (fun ns -> (ns.Name, (FilterBySourceFile.Apply (ns, path)).Elements |> Seq.toList))
        |> Seq.filter (fun (_,elements) -> not elements.IsEmpty)
        |> Seq.toList

    // Builds the C# syntaxTree for the Q# elements defined in the given file.
    let buildSyntaxTree (fileName : NonNullable<string>) allQsElements = 
        let globalContext = createContext (Some fileName.Value) allQsElements
        let usings = autoNamespaces |> List.map (fun ns -> ``using`` ns)
        let localElements = findLocalElements fileName allQsElements
        let namespaces = localElements |> List.map (buildNamespace globalContext)

        ``compilation unit`` 
            []
            usings
            namespaces
        // We add a "pragma warning disable 1591" since we don't generate doc comments in our C# code.
        |> ``pragmaDisableWarning`` 1591

    // Helper method that takes a SyntaxTree, adds trivia (formatting) 
    // and returns it as a string
    let formatSyntaxTree tree =
        try 
            let ws = new AdhocWorkspace()
            let formattedRoot = Formatter.Format(tree, ws)
            formattedRoot.ToFullString()
        with 
        | :?  Reflection.ReflectionTypeLoadException as l ->
            let msg = l.LoaderExceptions |> Array.fold (fun msg e -> msg + ";" + e.Message) ""
            failwith msg

             
    // Main entry method for a CodeGenerator.
    // Builds the SyntaxTree for the given Q# syntax tree, formats it and returns it as a string
    let generate fileName allQsElements = 
        allQsElements 
        |> buildSyntaxTree fileName
        |> formatSyntaxTree


    