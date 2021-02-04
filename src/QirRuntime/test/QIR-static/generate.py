# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

import sys, os, platform, subprocess, datetime, shutil

# =============================================================================
#  Generates QIR files for all *.qs files in this folder
#  Accepts arguments:
#    path to qsc.exe (absolute or rely on Path env)
#
#  For example: "generate.py qsc.exe"
# =============================================================================

# =============================================================================
def log(message):
  now = datetime.datetime.now()
  current_time = now.strftime("%H:%M:%S")
  print(current_time + ": " + message)
# =============================================================================

root_dir = os.path.dirname(os.path.abspath(__file__))

# parameters
qsc = sys.argv[1] # argv[0] is the name of this script file

# if no file name argument, process all qs files in this folder, otherwise treat all additional args as input files
files_to_process = ""
output_file = "qir-test-qsharp"
if len(sys.argv) == 2:
  for file in os.listdir(root_dir):
    (file_name, ext) = os.path.splitext(file)
    if ext == ".qs":
      files_to_process = files_to_process + " " + file
else:
  for i in range(2, len(sys.argv)):
    (file_name, ext) = os.path.splitext(sys.argv[i])
    files_to_process = files_to_process + " " + file_name + ".qs"
    if i == 2 and len(sys.argv) == 3:
      output_file = file_name

command = (qsc + " build --qir s --build-exe --input " + files_to_process +
           " compiler\\qircore.qs compiler\\qirtarget.qs --proj " + output_file)
log("Executing: " + command)
subprocess.run(command, shell = True)

