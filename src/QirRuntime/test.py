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
print(os.environ["LD_LIBRARY_PATH"])
log("========= Running native tests =========")
test_binaries = []

for name in test_binaries:
  test_binary = os.path.join(install_dir, name + exe_ext)
  log(test_binary)
  print(test_binary)
  subprocess.run(test_binary + " ~[skip]", shell = True)

print("\n")

from scipy.optimize import minimize

def run_program(var_params, num_samples) -> float:
    # run parameterized quantum program for VQE algorithm
    theta1, theta2, theta3 = var_params
    cmd = os.path.join(install_dir, "qir-exe") + f" 1 {theta1} {theta2} {theta3} {num_samples}"
    result = subprocess.run(cmd, shell = True, capture_output=True)
    idx = str(result.stdout).find("Result 0: ")
    value = float(result.stdout[idx+3:-2])
    print(var_params, value)
    return value
 
def VQE(initial_var_params, num_samples):
    """ Run VQE Optimization to find the optimal energy and the associated variational parameters """
    print(f"Starting VQE algorithm: {initial_var_params}, {num_samples}")
 
    opt_result = minimize(run_program,
                          initial_var_params,
                          args=(num_samples,),
                          method="COBYLA",
                          tol=0.000001,
                          options={'disp': True, 'maxiter': 200,'rhobeg' : 0.05})
 
    return opt_result

# Initial variational parameters
var_params = [0.001, -0.001, 0.001]

# Run VQE and print the results of the optimization process
# A large number of samples is selected for higher accuracy
opt_result = VQE(var_params, num_samples=100)
print(opt_result)

# Print difference with exact FCI value known for this bond length
fci_value = -1.1372704220924401
print("Difference with exact FCI value :: ", abs(opt_result.fun - fci_value))
