# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

########################################
# .Description
# When creating a package with dotnet pack, nuget changes every ProjectReference to be itself
# a PackageReference (without checking if that project has a corresponding package).
# This is problematic because we currently don't want to create a package for every dll.
#
# On the other hand, when creating a package using nuget pack, nuget does not
# identify PackageReferences defined in the csproj, so all the dependencies
# are not listed and the package doesn't work.
#
# We don't want to hardcode the list of dependencies on the .nuspec, as they can
# quickly become out-of-sync.
# This script will find the PackageReferences recursively on the simulation projects and add them
# to the nuspec, so we can then create the package using nuget pack with the corresponding
# dependencies listed.
#
# nuget is tracking this problem at: https://github.com/NuGet/Home/issues/4491
########################################

$target = Join-Path $PSScriptRoot "Microsoft.Quantum.Simulators.Type3.nuspec"

if (Test-Path $target) { 
    Write-Host "$target exists. Skipping generating new one."
    exit
 }


# Start with the nuspec template
$nuspec = [xml](Get-Content (Join-Path $PSScriptRoot "Microsoft.Quantum.Simulators.Type3.nuspec.template"))
$dep = $nuspec.CreateElement('dependencies', $nuspec.package.metadata.NamespaceURI)

function Add-PackageReferenceIfNew($ref) {
    # Identify package's id either from "Include" or "Update" attribute:
    $id = $ref.Include
    $version = $ref.Version
    
    if ($id -eq $null -or $id -eq "") {
        $id = $ref.Update
    }
    if ($id.EndsWith('.csproj') -or $id.EndsWith('.fsproj')) {
        $id = [System.IO.Path]::GetFileNameWithoutExtension($id)
    }

    if ("$version" -eq "") {
        $version = '$version$'
    }

    # Check if package already added as dependency, only add if new:
    $added = $dep.dependency | Where { $_.id -eq $id }
    if (!$added) {
        Write-Host "Adding $id (version: $version)"
        $onedependency = $dep.AppendChild($nuspec.CreateElement('dependency', $nuspec.package.metadata.NamespaceURI))
        $onedependency.SetAttribute('id', $id)
        $onedependency.SetAttribute('version', $version)
    }
}

# Recursively find PackageReferences on all ProjectReferences:
function Add-NuGetDependencyFromCsprojToNuspec($PathToCsproj) {
    Write-Host "`nFinding dependencies for $PathToCsproj"
    $csproj = [xml](Get-Content $PathToCsproj)

    # Find all PackageReferences nodes:
    $packageDependency = $csproj.Project.ItemGroup.PackageReference | Where-Object { $null -ne $_ }
    $packageDependency | ForEach-Object {
        $id = $_.Include
        Write-Host "Detected package dependencies: $id"
    }

    $packageDependency | ForEach-Object {
        Add-PackageReferenceIfNew $_ 
    }

    $projectDependency = $csproj.Project.ItemGroup.ProjectReference | Where-Object { $null -ne $_ }
    $projectDependency | ForEach-Object {
        $id = $_.Include
        Write-Host "Detected project dependencies: $id"
    }

    # Assume there is a package for project references that are not tagged as to be included in the simulator package:
    $projectDependency | Where-Object {$_.IncludeInSimulatorPackage -ne 'true' -and $_.IsQscReference -ne 'true'} | ForEach-Object {
        Add-PackageReferenceIfNew $_ 
    }

    # Recursively check on project references if they are private:
    $projectDependency | Where-Object {$_.IncludeInSimulatorPackage -eq 'true' -and $_.IsQscReference -ne 'true'} | ForEach-Object {
        $id = $_.Include
        Write-Host "Recurring for $id"
        Add-NuGetDependencyFromCsprojToNuspec $_.Include 
    }
}

# Find all dependencies packaged as part of Microsoft.Quantum.Simulators.Type3
Add-NuGetDependencyFromCsprojToNuspec "Microsoft.Quantum.Simulators.Type3.csproj"

# Save into .nuspec file:
$nuspec.package.metadata.AppendChild($dep)
$nuspec.Save($target)
