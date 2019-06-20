$qbc="..\..\..\qflat\Qbc\bin\Release\Qbc.exe"

function FixNamespace($code,$namespace)
{
    ($code) -replace 'namespace Microsoft.Quantum',('namespace ' + $namespace)
}

function HideAbstractClass($code,$className)
{
    $prefix = "hidden__" + [System.GUID]::NewGuid().ToString() + "__"

    #class declaration 
    $code = $code -replace `
      [Regex]::Escape("public abstract class " + $className),`
      ("internal abstract class " + $prefix + $className)
    
    #constructor
    $code = $code -replace `
      [Regex]::Escape("public "+$className+"(IOperationFactory m) : base(m)"),`
      ("public "+$prefix+$className+"(IOperationFactory m) : base(m)")

    #run method
    $code = $code -replace `
      [Regex]::Escape("return m.Run<"+$className),`
      ("return m.Run<"+$prefix+$className)

    $code
}

function HidePrimitives( $code )
{
    $classesToHide = `
        "X",`
        "Y",`
        "Z",`
        "H",`
        "HY",`
        "S",`
        "T",`
        "CNOT",`
        "CCNOT",`
        "R","Rx","Ry","Rz",`
        "RFrac","R1Frac","R1",`
        "Exp","ExpFrac",`
        "Assert","AssertProb",`
        "Random","Measure","M"

    foreach( $className in $classesToHide )
    {
        $code = HideAbstractClass -code $code -className $className
    }
    $code
}

function HackFile( $filename, $namespace )
{
    $generatedCode = Get-Content $filename | Out-String
    $generatedCode = FixNamespace -code $generatedCode -namespace $namespace
    #$generatedCode = HidePrimitives -code $generatedCode
    $generatedCode > $filename
}

function BuildFiles( $filenames, $outputFile, $namespace )
{
    $files = ""
    foreach( $filename in $filenames )
    {
        $files = $files + " " + $filename
    }
    $arguments = " --input" + $files + " --outputfile " + $outputFile + " --operation generate"
    $command = $qbc + $arguments
    $cmdOutput = cmd /c $command '2>&1' | Out-String
    
    Write-Host "Building:"
    Write-Host $filenames

    if( $lastexitcode -eq 0 )
    {
        Write-Host "Build OK"
        Write-Host "Hacking generated code..."
        #do some fixes to the outputFile
        HackFile -filename $outputFile -namespace $namespace
    }
    else
    {
        Write-Host "Build fail"
    }
    [IO.File]::WriteAllLines("build_log.txt", $cmdOutput)
}

function BuildFile( $filename, $namespace )
{
    BuildFiles -filenames $filename -outputFile ([System.IO.Path]::GetFileNameWithoutExtension($filename) + ".g.cs") -namespace $namespace
}

BuildFile -filename "AssertQubitState.qb" -namespace "Microsoft.Quantum.Simulation.Simulators.Tests.Circuits"
BuildFile -filename "CatState.qb" -namespace "Microsoft.Quantum.Simulation.Simulators.Tests.Circuits"