FROM mcr.microsoft.com/dotnet/sdk:3.1-focal

# Install Mono and Nuget CLI
RUN apt-get -y update && \
    apt-get -y install dirmngr gnupg apt-transport-https ca-certificates && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    sh -c 'echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" > /etc/apt/sources.list.d/mono-official-stable.list' && \
    apt-get -y update && \
    apt-get -y install --no-install-recommends mono-complete nuget && \
    apt-get clean && rm -rf /var/lib/apt/lists/

# Install CMake, Ninja, LLVM/Clang tools
RUN apt update \
    && apt-get install -y cmake \
    && apt-get install -y ninja-build \
    && apt-get install -y clang-11 \
    && apt-get install -y clang-tidy-11

# Install C/C++ build tools and libraries
RUN apt-get install -y build-essential
