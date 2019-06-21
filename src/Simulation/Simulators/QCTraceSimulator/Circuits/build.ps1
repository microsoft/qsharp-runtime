# //////////////////////////////////////////////

$qbc="..\..\..\..\qflat\Qbc\bin\Debug\Qbc.exe"

$utils =  
 "FailOn.qb " + 
 "IndiciesOfNonIdentity.qb " + 
 "PauliArrayByIndex.qb " +
 "ApplyByIndex.qb " +
 "Mod.qb " +
 "ReducedForm.qb "

$internal=
 "Interface.qb "+
 "InternalOperations.qb "

$fixedQubits =
 "PauliZFlip.qb " +
 "PauliXFlip.qb " +
 "CY.qb " +
 "CZ.qb " +
 "ExpZZ.qb " +
 "ExpFracZZ.qb " +
 "ExpFracZZZ.qb " +
 "CCZ.qb " +
 "CCX.qb " +
 "CCminusIZ.qb " +
 "CCminusIX.qb " +
 "ControlledH.qb " +
 "ControlledRZ.qb " +
 "ControlledR.qb " +
 "ControlledSWAP.qb " +
 "ControlledR1.qb " +
 "ControlledT.qb " +
 "ControlledTS.qb " +
 "ControlledTPower.qb " +
 "ControlledR1Frac.qb " +
 "ControlledRzFrac.qb " +
 "ControlledRFrac.qb "

$variableQubit =
 "MultiCX.qb " +
 "AndLadder.qb " +
 "MultiControlledU.qb " +
 "MultiControlledMultiNot.qb " +
 "MultiPauliFlip.qb " +
 "MultiControlledFromOpAndSinglyCtrldOp.qb "

$primitiveRotations=
 "Primitive.R.qb " +
 "Primitive.RFrac.qb " +
 "Primitive.R1.qb " +
 "Primitive.R1Frac.qb " +
 "Primitive.MultiX.qb " +
 "Primitive.Rx.qb " +
 "Primitive.Rz.qb " +
 "Primitive.Ry.qb "

$primitiveWithSlice =
 "Primitive.X.qb " +
 "Primitive.Y.qb " +
 "Primitive.Z.qb "

$primitiveSimple=
 "Primitive.H.qb " +
 "Primitive.S.qb " +
 "Primitive.HY.qb " +
 "Primitive.T.qb " +
 "Primitive.CNOT.qb " +
 "Primitive.CCNOT.qb " +
 "Primitive.SWAP.qb "

$Exp =
 "Primitive.Exp.qb " + 
 "Primitive.ExpFrac.qb "


$files=
 $utils + 
 $internal + 
 $fixedQubits +
 $variableQubit +
 $primitiveRotations+
 $Exp + 
 $primitiveSimple + 
 $primitiveWithSlice

$arguments = " --input " + $files
$command = $qbc + $arguments

Write-Host "Building..."
$cmdOutput = cmd /c $command '2>&1' | Out-String

if( $lastexitcode -eq 0 )
{
    Write-Host "Build OK"
}
else
{
    Write-Host "Build fail"
    [IO.File]::WriteAllLines("build_log.txt", $cmdOutput)
    exit $lastexitcode
}