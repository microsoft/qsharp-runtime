use assert_json_diff::assert_json_eq;
use qdk_sim::NoiseModel;
use serde_json::Value;

// Use include_str! to store test case JSON as a string into the compiled
// test executable.
static IDEAL_NOISE_MODEL_JSON: &str = include_str!("data/ideal-noise-model.json");

#[test]
fn ideal_noise_model_serializes_correctly() {
    let noise_model = NoiseModel::ideal();
    let expected: Value =
        serde_json::from_str(&*(serde_json::to_string(&noise_model).unwrap())).unwrap();

    assert_json_eq!(noise_model, expected);
}

#[test]
fn ideal_noise_model_deserializes_correctly() {
    let actual: NoiseModel = serde_json::from_str(IDEAL_NOISE_MODEL_JSON).unwrap();

    assert_json_eq!(actual, NoiseModel::ideal());
}
