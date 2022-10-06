#!/usr/bin/env pwsh

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -PSEdition Core

pwsh -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "& '$(Join-Path $pwd build build.ps1)' $args"
exit $LASTEXITCODE
