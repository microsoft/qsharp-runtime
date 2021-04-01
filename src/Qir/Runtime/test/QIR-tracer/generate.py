# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import sys, os, platform, subprocess, datetime, shutil

# =============================================================================
#  Generates QIR files for all *.qs files in this folder
#  Accepts arguments:
#    path to qsc.exe (absolute or rely on Path env)
#
#  For example: "generate.py qsc.exe" or "generate.py c:\qsharp-compiler\qsc.exe"
# =============================================================================

# =============================================================================
def log(message):
  now = datetime.datetime.now()
  current_time = now.strftime("%H:%M:%S")
  print(current_time + ": " + message)
# =============================================================================

if __name__ == '__main__':
  # this script is executed as script
  root_dir = os.path.dirname(os.path.abspath(__file__))

  # parameters
  qsc = sys.argv[1] # argv[0] is the name of this script file

  # find all qs files in this folder
  files_to_process = ""
  output_file = "tracer-qir"
  for file in os.listdir(root_dir):
    (file_name, ext) = os.path.splitext(file)
    if ext == ".qs":
      files_to_process = files_to_process + " " + file

  # Compile as a lib so all functions are retained and don't have to workaround the current limitations of
  # @EntryPoint attribute.
  command = (qsc + " build --qir qir --input " + files_to_process + " --proj " + output_file)
  log("Executing: " + command)
  subprocess.run(command, shell = True)

  # copy the generated file into tracer's input files
  generated_file = os.path.join(root_dir, "qir", output_file) + ".ll"
  build_input_file = os.path.join(root_dir, output_file) + ".ll"
  shutil.copyfile(generated_file, build_input_file)

