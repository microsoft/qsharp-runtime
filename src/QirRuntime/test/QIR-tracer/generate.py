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

for file in os.listdir(root_dir):
  (file_name, ext) = os.path.splitext(file)
  if ext == ".qs" and file_name != "tracer-core" and file_name != "tracer-target":
    log("Generating QIR from " + file)
    subprocess.run(
      qsc + " build --qir s --build-exe --input " + file + 
      " tracer-core.qs tracer-target.qs --proj " + file_name, shell = True)
