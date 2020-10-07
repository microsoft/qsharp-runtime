#pragma once
#include <sstream>

namespace quantum
{
    static const char* names[] = {"cX", "cCX", "cY",  "cCY",  "cZ", "cCZ", "cH",  "cCH",  "cR", "cCR",
                                  "cS", "cCS", "cAS", "cCAS", "cT", "cCT", "cAT", "cCAT", "cM"};
    static constexpr int counters = sizeof(names) / sizeof(char*);

    struct ResourceStatistics
    {
        // these members must match names[] above
        long cX, cCX = 0;
        long cY, cCY = 0;
        long cZ, cCZ = 0;
        long cH, cCH = 0;
        long cR, cCR = 0;
        long cS, cCS, cAS, cCAS = 0;
        long cT, cCT, cAT, cCAT = 0;
        long cM = 0;
        //=========================================

        long cQubitWidth = 0;
        long cQubits = 0;

        long cCircuitDepth = 0;

        // {"qubit_width":3, "circuit_depth": 2, "statistics":[{"metric":"cX","value":1},{"metric":"cR","value":2}]}
        // qubit_width is required even if it's equal zero, other metrics reported only if non-zero.
        void Print(std::ostringstream& os)
        {
            os << "{";
            os << "\"qubit_width\":" << cQubitWidth;

            if (cCircuitDepth > 0)
            {
                os << ",\"circuit_depth\":" << cCircuitDepth;
            }

            os << ",\"statistics\":[";
            long* fields = reinterpret_cast<long*>(this);
            for (int i = 0; i < counters; i++)
            {
                if (fields[i] > 0)
                {
                    os << "{\"metric\":\"" << names[i] << "\",\"value\":" << fields[i] << "},";
                }
            }
            os << "]}";
        }
    };
} // namespace quantum