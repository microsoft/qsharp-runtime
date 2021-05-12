FROM mcr.microsoft.com/dotnet/sdk:3.1-focal
RUN apt update \
    && apt-get install -y cmake \
                          ninja-build \
                          clang-11 \
                          clang-tidy-11 \
                          build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
CMD [ "pwsh" ]
