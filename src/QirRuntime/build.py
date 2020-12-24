# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

import sys, os, platform, subprocess, datetime

# =============================================================================
#  The script will create [root]\build\[OS]\[Debug|Release] folder for the output.
#
#  Accepts arguments:
#    make/nomake
#       'make' will limit action to producing make files only
#       'nomake' will skip make step and build using the current cmake cache
#       if omitted will make and then build the project
#    debug/release
#       default: debug
#
#  For example: "build.py nomake debug ir" or "build.py release"
# =============================================================================

# =============================================================================
def log(message):
  now = datetime.datetime.now()
  current_time = now.strftime("%H:%M:%S")
  print(current_time + ": " + message)
# =============================================================================

# =============================================================================
def create_if_doesnot_exist(dir):
  if not os.path.isdir(dir):
    os.mkdir(dir)

def create_folder_structure(start_dir, dirs):
  new_dir = start_dir
  for dir in dirs:
    new_dir = os.path.join(new_dir, dir)
    create_if_doesnot_exist(new_dir)
  return new_dir
# =============================================================================

# =============================================================================
def do_build(root_dir, should_make, should_build, flavor):
  build_dir = create_folder_structure(root_dir, ["build", platform.system(), flavor])
  os.chdir(build_dir)

  flavorWithDebInfo = flavor
  if flavor == "Release" :
      flavorWithDebInfo = "RelWithDebInfo"

  if should_make:
    cmd = "cmake -G Ninja -DCMAKE_CXX_CLANG_TIDY=clang-tidy -DCMAKE_BUILD_TYPE=" + flavorWithDebInfo + " ../../.."
    log("running: " + cmd)
    result = subprocess.run(cmd, shell = True)
    if result.returncode != 0:
      return result

  if should_build:
    cmd = "cmake --build . --target install --config " + flavorWithDebInfo
    log("running: " + cmd)
    result = subprocess.run(cmd, shell = True)

    return result
# =============================================================================

if __name__ == '__main__':
  # this script is executed as script
  # parameters
  flavor = "Debug"
  should_make = True
  should_build = True

  for arg in sys.argv:
    arg = arg.lower()
    if "build.py" in arg:
      continue
    elif arg == "debug":
      flavor = "Debug"
    elif arg == "release":
      flavor = "Release"
    elif arg == "nomake":
      should_make = False
    elif arg == "make":
      should_build = False
    else:
      log("unrecognized argument: " + arg)
      sys.exit()
  
  root_dir = os.path.dirname(os.path.abspath(__file__))
  do_build(root_dir, should_make, should_build, flavor)