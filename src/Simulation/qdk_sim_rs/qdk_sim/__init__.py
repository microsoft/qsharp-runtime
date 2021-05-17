import json
import qdk_sim._qdk_sim_rs as _native

def build_info():
    return json.loads(_native.build_info_json())
