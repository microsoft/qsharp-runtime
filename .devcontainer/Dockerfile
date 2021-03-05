FROM mcr.microsoft.com/dotnet/sdk:3.1-focal
RUN apt update \
    && apt-get install -y cmake \
    && apt-get install -y ninja-build \
    && apt-get install -y clang-11 \
    && apt-get install -y clang-tidy-11
RUN apt-get install -y build-essential
CMD [ "pwsh" ]