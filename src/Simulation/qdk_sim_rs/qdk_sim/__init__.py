from enum import Enum
import enum
import json
import qdk_sim._qdk_sim_rs as _native

# Re-export native classes.
from qdk_sim._qdk_sim_rs import (
    Tableau, NoiseModel, Instrument, State, Process
)

class Pauli(enum.Enum):
    I = 0
    X = 1
    Y = 3
    Z = 2

def build_info():
    return json.loads(_native.build_info_json())
