# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# DEPRECATED !!!

import os, sys, subprocess, datetime, shutil, pathlib

# =============================================================================
def log(message):
  now = datetime.datetime.now()
  current_time = now.strftime("%H:%M:%S")
  print(current_time + ": " + message)
# =============================================================================

# =============================================================================
# The Q# project should be located in a subfolder under test_dir, named "qsharp"
def do_generate_qir(test_dir):
  qsharp_project_path = os.path.join(test_dir, "qsharp")
  qirgencmd = "dotnet build " + qsharp_project_path
  log("running: " + qirgencmd)
  result = subprocess.run(qirgencmd, shell = True)
  if result.returncode != 0:
    return result

  # really, expect to have only one file
  for generated_qir_file in os.listdir(os.path.join(qsharp_project_path, "qir")):
    shutil.copyfile(
      os.path.join(os.path.join(qsharp_project_path, "qir", generated_qir_file)),
      os.path.join(test_dir, generated_qir_file))

  return result
# =============================================================================

# =============================================================================
def do_generate_all(root_dir):
  test_projects = [
    os.path.join(root_dir, "test", "QIR-static"),
    os.path.join(root_dir, "samples", "StandaloneInputReference")
    # add other test folders here
  ]

  for test_dir in test_projects:
      log("generating QIR for: " + test_dir)
      result = do_generate_qir(test_dir)
      if result.returncode != 0:
        log("Failed to generate QIR for: " + test_dir)
        return result.returncode

  return 0
# =============================================================================

if __name__ == '__main__':
  root_dir = os.path.dirname(os.path.abspath(__file__))
  do_generate_all(root_dir)


