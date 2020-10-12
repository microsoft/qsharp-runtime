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

# =============================================================================
def create_path(start_dir, dirs):
  new_dir = start_dir
  for dir in dirs:
    new_dir = os.path.join(new_dir, dir)
  return new_dir
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
  result = build.do_build(root_dir, True, True, False, flavor) # should_make, should_build, no_ir
  if result.returncode != 0:
    log("build failed with exit code {0} => won't execute the tests".format(result.returncode))
    log("to execute the tests from the last successful build run `test.py nobuild`")
    sys.exit()

install_dir = create_path(root_dir, ["build", platform.system(), flavor, "bin"])
if not os.path.isdir(install_dir):
  log("please build first: 'build.py [debug|release] [ir]'")
  sys.exit()

print("\n")
exe_ext = ""

if platform.system() == "Windows":
  exe_ext = ".exe"
else:
  # add the folder to the list of locations to load libraries from
  os.environ['LD_LIBRARY_PATH'] = install_dir

log("========= Running native tests =========")
test_binaries = [
  "unittests",
  "experimental-unittests",
  "tracer-tests",
  "qir-static-tests",
  "qir-dynamic-tests"
]

for name in test_binaries:
  test_binary = os.path.join(install_dir, name + exe_ext)
  log(test_binary)
  subprocess.run(test_binary, shell = True)

log("========= Running interop tests =========")
if platform.system() == "Windows":
  managed_interop_tests_dir = create_path(root_dir, ["build", "Windows", flavor, "test"])
  os.chdir(managed_interop_tests_dir)
  shutil.copy2(os.path.join(install_dir, "qdk.dll"), os.path.join(managed_interop_tests_dir, "netcoreapp3.1"))
  shutil.copy2(
    os.path.join(install_dir, "Microsoft.Quantum.Simulator.Runtime.dll"),
    os.path.join(managed_interop_tests_dir, "netcoreapp3.1"))
  subprocess.run("dotnet test netcoreapp3.1\interop.dll", shell = True)
else:
  log("C# interop tests not supported on this platform")

print("\n")