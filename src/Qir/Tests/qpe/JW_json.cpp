#include "nlohmann/json.hpp"
#include "JW_json.hpp"
#include "JW.hpp"

using json = nlohmann::json;

void from_json(const json& j, HTerm& d) 
{
    j.at(0).get_to(d.termIdxs);
    j.at(1).get_to(d.coeffs  );
}

void from_json(const json& j, JWOptimizedHTerms& d) 
{
    j.at(0).get_to(d.zTerms        );
    j.at(1).get_to(d.zzTerms       );
    j.at(2).get_to(d.pqAndPqqrTerms);
    j.at(3).get_to(d.h0123Terms    );
}

void from_json(const json& j, JWInputState& d) 
{
    j.at(0).get_to(d.cmplxStateCoeffs);
    j.at(1).get_to(d.ints            );
}

void from_json(const json& j, JWInputStates& d) 
{
    j.at(0).get_to(d.stateType   );
    j.at(1).get_to(d.stateTerms  );
}

void from_json(const json& j, JWData& d) 
{
    j.at(0).get_to(d.nQubits);
    j.at(1).get_to(d.terms);
    j.at(2).get_to(d.inputStates);
    j.at(3).get_to(d.energyOffset);
}
