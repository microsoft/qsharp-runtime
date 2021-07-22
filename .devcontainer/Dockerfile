FROM mcr.microsoft.com/dotnet/sdk:3.1-focal

# Install Mono, NuGet, CMake, Ninja, Clang-11, build-essential
RUN apt-get -y update \
    && apt-get -y install dirmngr gnupg apt-transport-https ca-certificates \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && sh -c 'echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" > /etc/apt/sources.list.d/mono-official-stable.list' \
    && apt-get -y update \
    && apt-get -y install --no-install-recommends mono-complete nuget \
    && apt-get -y install cmake \
                          ninja-build \
                          clang-11 \
                          clang-tidy-11 \
                          build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/

# Install CMake 3.20 (required since apt-get uses 3.16 and repo requires 3.20)
RUN curl -SsL https://github.com/Kitware/CMake/releases/download/v3.20.5/cmake-3.20.5-linux-x86_64.sh -o cmakeinstall.sh \
    && echo "f582e02696ceee81818dc3378531804b2213ed41c2a8bc566253d16d894cefab cmakeinstall.sh" | sha256sum -c --strict - \
    && chmod +x cmakeinstall.sh \
    && ./cmakeinstall.sh --prefix=/usr/local --exclude-subdir \
    && rm cmakeinstall.sh

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

CMD [ "pwsh" ]
