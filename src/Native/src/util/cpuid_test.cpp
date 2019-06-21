// Copyright © 2017 Microsoft Corporation. All Rights Reserved.

#include "cpuid.hpp"
#include <iostream>

int main()
{
  if(Microsoft::Quantum::haveAVX512())
  std::cout << "Have AVX-512\n";
  if(Microsoft::Quantum::haveAVX2())
  std::cout << "Have AVX2\n";
  if(Microsoft::Quantum::haveFMA())
  std::cout << "Have FMA\n";
  if(Microsoft::Quantum::haveAVX())
    std::cout << "Have AVX\n";
  else
    std::cout << "Don't have AVX\n";
    return 0;
}
