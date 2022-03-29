# jupyter-langs:latest

ARG GOLANG_VERSION=1.18.0
ARG JULIA_VERSION=1.7.2
ARG DOTNET_SDK_VERSION=6.0.201

# https://hub.docker.com/_/golang
FROM golang:${GOLANG_VERSION}-buster as golang
# https://hub.docker.com/_/julia
FROM julia:${JULIA_VERSION}-buster as julia
# https://hub.docker.com/_/microsoft-dotnet-sdk
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_SDK_VERSION}-bullseye-slim as dotnet-sdk

FROM ghcr.io/heromo/jupyter-langs/python:5.15.1
LABEL maintainer="HeRoMo"
LABEL Description="Jupyter lab for various languages"
LABEL Version="5.15.0"

# Install SPARQL
RUN pip install sparqlkernel && \
    jupyter sparqlkernel install

# Install R
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc
RUN mamba install --quiet --yes -c conda-forge \
            'r-base>=4.1' \
            'r-caret' \
            'r-crayon' \
            # 'r-devtools' \
            'r-e1071' \
            'r-forecast' \
            'r-hexbin' \
            'r-htmltools' \
            'r-htmlwidgets' \
            'r-irkernel' \
            'r-nycflights13' \
            'r-randomforest' \
            'r-rcurl' \
            'r-rodbc' \
            'r-rsqlite' \
            'r-shiny' \
            'rpy2' \
            'unixodbc' \
            'r-markdown' \
            'r-plotly'

# Install Julia
ENV JULIA_PATH /usr/local/julia
ENV PATH ${JULIA_PATH}/bin:$PATH
COPY --from=julia ${JULIA_PATH} ${JULIA_PATH}
RUN julia --version
RUN julia -e 'using Pkg; Pkg.add("IJulia"); Pkg.add("DataFrames"); Pkg.add("CSV"); Pkg.add("Colors"); Pkg.add("ColorSchemes"); Pkg.add("PlotlyJS");'

# Install golang
ENV GOLANG_VERSION=${GOLANG_VERSION}
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=golang /usr/local/go/ /usr/local/go/
RUN env GO111MODULE=off go get -d -u github.com/gopherdata/gophernotes \
    && cd "$(go env GOPATH)"/src/github.com/gopherdata/gophernotes \
    && env GO111MODULE=on go install \
    && mkdir -p $HOME/.local/share/jupyter/kernels/gophernotes \
    && cp kernel/* $HOME/.local/share/jupyter/kernels/gophernotes \
    && cd $HOME/.local/share/jupyter/kernels/gophernotes \
    && chmod +w ./kernel.json \
    && sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < kernel.json.in > kernel.json

# Install Rust https://www.rust-lang.org/
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
ENV RUST_VERSION=1.59.0
ENV RUSTUP_VERSION=1.24.3
RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='3dc5ef50861ee18657f9db2eeb7392f9c2a6c95c90ab41e45ab4ca71476b4338' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='32a1532f7cef072a667bac53f1a5542c99666c4071af0c9549795bbdb2069ec1' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${rustArch}/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --default-toolchain ${RUST_VERSION}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;
RUN cargo install evcxr_jupyter \
    && evcxr_jupyter --install

# Install Ruby https://www.ruby-lang.org
ENV RUBY_VERSION=3.1.1
ENV RUBY_HOME=/opt/ruby
RUN apt-get update -y \
    && apt-get install  -y --no-install-recommends \
		bzip2 \
		ca-certificates \
		libffi-dev \
		libgmp-dev \
		libssl-dev \
		libyaml-dev \
		procps \
		zlib1g-dev \
        autoconf \
		bison \
		dpkg-dev \
		gcc \
		libbz2-dev \
		libgdbm-compat-dev \
		libgdbm-dev \
		libglib2.0-dev \
		libncurses-dev \
		libreadline-dev \
		libxml2-dev \
		libxslt-dev \
		make \
		ruby \
		wget \
		xz-utils
RUN git clone https://github.com/rbenv/ruby-build.git \
    && PREFIX=/usr/local ./ruby-build/install.sh \
    && mkdir -p ${RUBY_HOME} \
    && ruby-build ${RUBY_VERSION} ${RUBY_HOME}/${RUBY_VERSION}
ENV PATH=${RUBY_HOME}/${RUBY_VERSION}/bin:$PATH
RUN gem install --no-document \
                benchmark_driver \
                cztop \
                iruby \
    && iruby register --force

# Install JVM languages
## Java
RUN mamba install --quiet --yes -c conda-forge 'openjdk' \
    && git clone https://github.com/SpencerPark/IJava.git && cd IJava/ \
    && ./gradlew installKernel
## Kotlin
RUN mamba install --quiet --yes -c jetbrains 'kotlin-jupyter-kernel'
## Scala 
RUN curl -Lo coursier https://git.io/coursier-cli \
    && chmod +x coursier \
    && ./coursier launch --fork almond:0.11.1 -- --install \
    && rm -f coursier

# Install Erlang and Elixir
RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb \
    && dpkg -i erlang-solutions_2.0_all.deb \
    && rm -f erlang-solutions_2.0_all.deb
RUN apt-get update; exit 0
RUN apt-get install  -y --no-install-recommends \
        erlang \
        elixir=1.12.2-1 # workarond for filmor/ierl
RUN mix local.hex --force \
    && mix local.rebar --force
RUN git clone https://github.com/filmor/ierl.git ierl \
    && cd ierl \
    && mkdir $HOME/.ierl \
    && mix deps.get \
    # Build lfe explicitly for now
    && (cd deps/lfe && ~/.mix/rebar3 compile) \
    && (cd apps/ierl && env MIX_ENV=prod mix escript.build) \
    && cp apps/ierl/ierl $HOME/.ierl/ierl.escript \
    && chmod +x $HOME/.ierl/ierl.escript \
    && $HOME/.ierl/ierl.escript install erlang --user \
    && $HOME/.ierl/ierl.escript install elixir --user \
    && cd .. \
    && rm -rf ierl

# Install .NET5
ENV DOTNET_ROOT=/usr/share/dotnet
ENV DOTNET_SDK_VERSION=${DOTNET_SDK_VERSION}
ENV PATH=/usr/share/dotnet:/root/.dotnet/tools:$PATH
COPY --from=dotnet-sdk ${DOTNET_ROOT} ${DOTNET_ROOT}
RUN ln -s ${DOTNET_ROOT}/dotnet /usr/bin/dotnet \
    && dotnet help
RUN dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive \
    && dotnet interactive jupyter install

# ↓ 削除系ははまとめてここでやる    
RUN mamba clean --all \
    && apt-get autoremove \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*
