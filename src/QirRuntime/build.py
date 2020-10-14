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
#    ir [to use it must provide llvm-tools, only valid with 'make']
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
def do_build(root_dir, should_make, should_build, gen_ir, flavor):
  build_dir = create_folder_structure(root_dir, ["build", platform.system(), flavor])
  os.chdir(build_dir)

  if should_make:
    gen_ir_flag = " -DGENERATE_IR=True" if gen_ir else ""
    cmd = "cmake -G Ninja -DCMAKE_CXX_CLANG_TIDY=clang-tidy -DCMAKE_BUILD_TYPE=" + flavor + gen_ir_flag + " ../../.."
    log("running: " + cmd)
    result = subprocess.run(cmd, shell = True)
    if result.returncode != 0:
      return result

  if should_build:
    cmd = "cmake --build . --target install --config " + flavor
    log("running: " + cmd)
    result = subprocess.run(cmd, shell = True)
    if result.returncode != 0:
      return result

    if platform.system() == "Windows":
      interop_tests_dir = os.path.join(root_dir, "test")
      interop_tests_dir = os.path.join(interop_tests_dir, "interop")
      cmd = "dotnet build -c " + flavor +" " + interop_tests_dir
      log("running: " + cmd)
      result = subprocess.run(cmd, shell = True)

    return result
# =============================================================================

if __name__ == '__main__':
  # this script is executed as script
  # parameters
  flavor = "Debug"
  gen_ir = False
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
    elif arg == "ir":
      gen_ir = True
    elif arg == "nomake":
      should_make = False
    elif arg == "make":
      should_build = False
    else:
      log("unrecognized argument: " + arg)
      sys.exit()
  
  root_dir = os.path.dirname(os.path.abspath(__file__))
  do_build(root_dir, should_make, should_build, gen_ir, flavor)