# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Returns true if a command with the specified name exists.
function Test-CommandExists($name) {
    $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}
