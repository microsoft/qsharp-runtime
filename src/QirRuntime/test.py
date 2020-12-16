# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

import sys, os, platform, subprocess, datetime, shutil
import build

# =============================================================================
#  Accepts arguments:
#    nobuild [if omitted, will attempt to build the project]
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

root_dir = os.path.dirname(os.path.abspath(__file__))

# parameters
flavor = "Debug"
nobuild = False
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
  else:
    log("unrecognized argument: " + arg)
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
  "qir-runtime-unittests",
  "qir-static-tests",
  "qir-dynamic-tests",
  "qir-tracer-tests"
]

for name in test_binaries:
  test_binary = os.path.join(install_dir, name + exe_ext)
  log(test_binary)
  subprocess.run(test_binary + " ~[skip]", shell = True)

print("\n")