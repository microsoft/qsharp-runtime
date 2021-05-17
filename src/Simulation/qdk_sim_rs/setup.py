from setuptools import setup
from setuptools_rust import Binding, RustExtension

setup(
    name="qdk_sim",
    version="1.0",
    rust_extensions=[RustExtension("qdk_sim._qdk_sim_rs", binding=Binding.PyO3, features=["python"])],
    packages=["qdk_sim"],
    # rust extensions are not zip safe, just like C-extensions.
    zip_safe=False,
    include_package_data=True,
)
