#!/bin/env python
# -*- coding: utf-8 -*-
##
# setup.py: Installs Python integration for qdk_sim_experimental.
##
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
##

## IMPORTS ##

import setuptools
from setuptools_rust import Binding, RustExtension
import os

## VERSION INFORMATION ##
# Our build process sets the PYTHON_VERSION environment variable to a version
# string that is compatible with PEP 440, and so we inherit that version number
# here and propagate that to qsharp/version.py.
#
# To make sure that local builds still work without the same environment
# variables, we'll default to 0.0.0.1 as a development version.

version = os.environ.get('PYTHON_VERSION', '0.0.0.1')
is_conda = bool(os.environ.get('CONDA_BUILD', False))

with open('./qdk_sim_experimental/version.py', 'w') as f:
    f.write(f'''# Auto-generated file, do not edit.
##
# version.py: Specifies the version of the qsharp package.
##
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
##
__version__ = "{version}"
_is_conda = {is_conda}
''')

setuptools.setup(
    name="qdk_sim_experimental",
    version=version,
    rust_extensions=[RustExtension("qdk_sim_experimental._qdk_sim_rs", binding=Binding.PyO3, features=["python"])],
    packages=["qdk_sim_experimental"],
    # rust extensions are not zip safe, just like C-extensions.
    zip_safe=False,
    include_package_data=True,
)
