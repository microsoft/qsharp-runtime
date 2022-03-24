#ifndef JW_JSON_HPP
#define JW_JSON_HPP

#include "nlohmann/json.hpp"
#include "JW.hpp"

using json = nlohmann::json;

void from_json(const json& j, HTerm& d);
void from_json(const json& j, JWOptimizedHTerms& d);
void from_json(const json& j, JWInputState& d);
void from_json(const json& j, JWInputStates& d);
void from_json(const json& j, JWData& d);

#endif
