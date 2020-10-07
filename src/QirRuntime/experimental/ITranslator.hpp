#pragma once
#include <sstream>

namespace quantum
{
    // Currently, there is implicit expectation that the simulator knows the runtime type of the translator and can cast
    // to it in order to access callbacks that allow the translator to accumulate necessary information. The client must
    // create matching (simulator, translator) pair using the corresponding factory methods, but they don't get access
    // to the inner-workings of the translator.
    struct ITranslator
    {
        virtual ~ITranslator() {}

        virtual void PrintRepresentation(std::ostringstream& os, std::ostringstream* errors = nullptr) = 0;
    };

} // namespace quantum