# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

import sys, os, platform, subprocess, datetime, shutil
import build, generateqir

# =============================================================================
#  Accepts arguments:
#    nobuild [if omitted, will attempt to build the project]
#    noqirgen [if omitted, will attempt to generate qir from Q# projects]
#    debug/release
#
#  For example: "test.py nobuild debug"
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
  flavor = "Debug"
  nobuild = False
  noqirgen = False
  for arg in sys.argv:
    arg = arg.lower()
    if arg == "test.py":
      continue
    elif arg == "debug":
      flavor = "Debug"
    elif arg == "release":
      flavor = "Release"
    elif arg == "nobuild":
      nobuild = True
      noqirgen = True
    elif arg == "noqirgen":
      noqirgen = True
    else:
      log("unrecognized argument: " + arg)
      sys.exit()

  if not noqirgen:
    if generateqir.do_generate_all(root_dir) != 0:
      log("build failed to generate QIR => won't execute the tests")
      log("to execute the tests from the last successful build run `test.py nobuild`")
      sys.exit()

  if not nobuild:
    result = build.do_build(root_dir, True, True, flavor) # should_make, should_build
    if result.returncode != 0:
      log("build failed with exit code {0} => won't execute the tests".format(result.returncode))
      log("to execute the tests from the last successful build run `test.py nobuild`")
      sys.exit()

  install_dir = os.path.join(root_dir, "build", platform.system(), flavor, "bin")
  if not os.path.isdir(install_dir):
    log("please build first: 'build.py [debug|release] [ir]'")
    sys.exit()

  print("\n")

  # Configure DLL lookup locations to include full state simulator and qdk
  exe_ext = ""
  fullstate_sim_dir = os.path.join(root_dir, "..", "Simulation", "Native", "build", flavor)
  if platform.system() == "Windows":
    exe_ext = ".exe"
    os.environ['PATH'] = os.environ['PATH'] + ";" + fullstate_sim_dir + ";" + install_dir
  else:
    # add the folder to the list of locations to load libraries from
    old = os.environ.get("LD_LIBRARY_PATH")
    if old:
        os.environ["LD_LIBRARY_PATH"] = old + ":" + fullstate_sim_dir + ":" + install_dir
    else:
        os.environ["LD_LIBRARY_PATH"] = fullstate_sim_dir + ":" + install_dir

    old = os.environ.get("DYLD_LIBRARY_PATH")
    if old:
        os.environ["DYLD_LIBRARY_PATH"] = old + ":" + fullstate_sim_dir + ":" + install_dir
    else:
        os.environ["DYLD_LIBRARY_PATH"] = fullstate_sim_dir + ":" + install_dir

  log("========= Running native tests =========")
  test_binaries = [
    "fullstate-simulator-tests",
    "qir-runtime-unittests",
    "qir-static-tests",
    "qir-dynamic-tests",
    "qir-tracer-tests"
  ]

  for name in test_binaries:
    test_binary = os.path.join(install_dir, name + exe_ext)
    log(test_binary)
    subprocess.run(test_binary + " ~[skip]", shell = True)

  log("========= Running samples =========")
  subprocess.run(
    "qir-input-reference-standalone" +\
    " --int-value 1" +\
    " --integer-array 1 2 3 4 5" +\
    " --double-value 0.5" +\
    " --double-array 0.1 0.2 0.3 0.4 0.5" +\
    " --bool-value true" +\
    " --bool-array true TRUE false fALSe 0" +\
    " --pauli-value PauliX" +\
    " --pauli-array PauliI paulix PAULIY PAulIZ" +\
    " --range-value 1 2 10" +\
    " --range-array 1 2 10 5 5 50 10 1 20" +\
    " --string-value ASampleString" +\
    " --result-value one" +\
    " --result-array one ONE true TRUE 1 zero ZERO false FALSE 0")

  print("\n")