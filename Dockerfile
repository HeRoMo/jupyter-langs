# jupyter-langs:latest

ARG GOLANG_VERSION=1.19.1
ARG JULIA_VERSION=1.8.0
ARG DOTNET_SDK_VERSION=6.0.400-1

# https://hub.docker.com/_/golang
FROM golang:${GOLANG_VERSION}-bullseye as golang
# https://hub.docker.com/_/julia
FROM julia:${JULIA_VERSION}-bullseye as julia
# https://hub.docker.com/_/erlang
# https://hub.docker.com/_/elixir
FROM elixir:1.12.3-slim as elixir
# https://hub.docker.com/_/microsoft-dotnet-sdk
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_SDK_VERSION}-bullseye-slim as dotnet-sdk
# https://hub.docker.com/_/openjdk
FROM openjdk:18.0.2.1-jdk-bullseye as openjdk

FROM ghcr.io/heromo/jupyter-langs/python:5.16.0
LABEL maintainer="HeRoMo"
LABEL Description="Jupyter lab for various languages"
LABEL Version="5.16.0"

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
ENV RUST_VERSION=1.64.0
ENV RUSTUP_VERSION=1.25.1
RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='5cc9ffd1026e82e7fb2eec2121ad71f4b0f044e88bca39207b3f6b769aaa799c' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='e189948e396d47254103a49c987e7fb0e5dd8e34b200aa4481ecc4b8e41fb929' ;; \
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
ENV RUBY_VERSION=3.1.2
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

# Install .NET6
ENV DOTNET_ROOT=/usr/share/dotnet
ENV DOTNET_SDK_VERSION=${DOTNET_SDK_VERSION}
ENV PATH=/usr/share/dotnet:/root/.dotnet/tools:$PATH
COPY --from=dotnet-sdk ${DOTNET_ROOT} ${DOTNET_ROOT}
RUN ln -s ${DOTNET_ROOT}/dotnet /usr/bin/dotnet \
    && dotnet help
RUN dotnet tool install -g Microsoft.dotnet-interactive \
    && dotnet interactive jupyter install

# Install Erlang and Elixir
COPY --from=elixir /usr/local/lib/erlang /usr/local/lib/erlang
COPY --from=elixir /usr/local/lib/elixir /usr/local/lib/elixir
COPY --from=elixir /usr/local/bin/rebar3 /usr/local/bin/rebar3

RUN runtimeDeps=' \
		libodbc1 \
		libssl1.1 \
		libsctp1 \
	' \
	&& apt-get update \
    && apt-get install -y --no-install-recommends $runtimeDeps

RUN ln -s /usr/local/lib/erlang/bin/ct_run /usr/local/bin/ct_run \
    && ln -s /usr/local/lib/erlang/bin/dialyzer /usr/local/bin/dialyzer \
    && ln -s /usr/local/lib/erlang/bin/epmd /usr/local/bin/epmd \
    && ln -s /usr/local/lib/erlang/bin/erl /usr/local/bin/erl \
    && ln -s /usr/local/lib/erlang/bin/erlc /usr/local/bin/erlc \
    && ln -s /usr/local/lib/erlang/bin/escript /usr/local/bin/escript \
    && ln -s /usr/local/lib/erlang/bin/run_erl /usr/local/bin/run_erl \
    && ln -s /usr/local/lib/erlang/bin/to_erl /usr/local/bin/to_erl \
    && ln -s /usr/local/lib/erlang/bin/typer /usr/local/bin/typer \
    && ln -s /usr/local/lib/elixir/bin/elixir /usr/local/bin/elixir \
    && ln -s /usr/local/lib/elixir/bin/elixirc /usr/local/bin/elixirc \
    && ln -s /usr/local/lib/elixir/bin/iex /usr/local/bin/iex \
    && ln -s /usr/local/lib/elixir/bin/mix /usr/local/bin/mix
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

# Install JVM languages
## Java
# https://github.com/allen-ball/ganymede
ENV JAVA_HOME /usr/local/openjdk-18
ENV PATH $JAVA_HOME/bin:$PATH
ENV GANYMEDE_VERSION=2.0.1.20220723
COPY --from=openjdk ${JAVA_HOME} ${JAVA_HOME}
RUN wget https://github.com/allen-ball/ganymede/releases/download/v${GANYMEDE_VERSION}/ganymede-${GANYMEDE_VERSION}.jar -O /tmp/ganymede.jar
RUN ${JAVA_HOME}/bin/java \
      -jar /tmp/ganymede.jar  \
      -i --sys-prefix --copy-jar=true
## Kotlin
RUN mamba install --quiet --yes -c jetbrains 'kotlin-jupyter-kernel'
## Scala 
RUN curl -Lo coursier https://git.io/coursier-cli \
    && chmod +x coursier \
    && ./coursier launch --fork almond -- --install \
    && rm -f coursier

# ↓ 削除系ははまとめてここでやる
RUN mamba clean --all \
    && apt-get autoremove \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*
