import json
import qdk_sim._qdk_sim_rs as _native

# Re-export native classes.
from qdk_sim._qdk_sim_rs import (
    Tableau, NoiseModel, Instrument
)

def build_info():
    return json.loads(_native.build_info_json())
