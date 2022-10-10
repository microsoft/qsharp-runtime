
function Write-GroupBegin([string]$message) {
    Write-DevOpsLog "group" $message
}

function Write-GroupEnd() {
    Write-DevOpsLog "endgroup" ""
}

function Write-Debug([string]$message) {
    Write-DevOpsLog "debug" $message
}

function Write-Warning([string]$message) {
    Write-DevOpsLog "warning" $message
}

function Write-Error([string]$message) {
    Write-DevOpsLog "error" $message
}

function Write-Section([string]$message) {
    Write-DevOpsLog "section" $message
}

function Write-Command([string]$message) {
    Write-DevOpsLog "command" $message
}

function Write-DevOpsLog([string]$type, [string]$message) {
    Write-Output "##[$type]$message"
}

# https://learn.microsoft.com/en-us/azure/devops/pipelines/scripts/logging-commands?view=azure-devops&tabs=bash#task-commands
function Write-LogIssueError([string]$message, [string]$sourcepath, [string]$linenumber, [string]$columnnumber, [string]$number) {
    Write-LogIssue $message "error" $sourcepath $linenumber $columnnumber $number
}
function Write-LogIssueWarning([string]$message, [string]$sourcepath, [string]$linenumber, [string]$columnnumber, [string]$number) {
    Write-LogIssue $message "warning" $sourcepath $linenumber $columnnumber $number
}
function Write-LogIssue([string]$message, [string]$type, [string]$sourcepath, [string]$linenumber, [string]$columnnumber, [string]$number) {
    $properties = "task.logissue "
    Assert (($type -eq "error") -or ($type -eq "warning")) "type must be 'error' or 'warning'"
    $properties += "type=$type"
    if ($sourcepath) {
        $properties += ";sourcepath=$sourcepath"
    }
    if ($linenumber) {
        $properties += ";linenumber=$linenumber"
    }
    if ($columnnumber) {
        $properties += ";columnnumber=$columnnumber"
    }
    if ($code) {
        $properties += ";code=$code"
    }
    Write-Output "##vso[$properties]$message"
}