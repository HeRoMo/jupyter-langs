# jupyter-langs:latest
FROM golang:1.15.5-buster as golang
FROM julia:1.5.3-buster as julia

FROM ghcr.io/heromo/jupyter-langs/python:latest
LABEL Maintainer="HeRoMo"
LABEL Description="Jupyter lab for various languages"
LABEL Version="5.4.0"

# Install SPARQL
RUN pip install sparqlkernel && \
    jupyter sparqlkernel install

# Install R
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc
RUN conda install --quiet --yes -c conda-forge \
            'r-base>=4.0.3' \
            'r-caret' \
            'r-crayon' \
            'r-devtools' \
            'r-forecast' \
            'r-hexbin' \
            'r-htmltools' \
            'r-htmlwidgets' \
            'r-irkernel' \
            'r-nycflights13' \
            'r-randomforest' \
            'r-rcurl' \
            'r-rmarkdown' \
            'r-rodbc' \
            'r-rsqlite' \
            'r-shiny' \
            'r-tidyverse' \
            'unixodbc' \
            'r-tidymodels' \
            'r-e1071'

# Install Julia
ENV JULIA_PATH /usr/local/julia
ENV PATH ${JULIA_PATH}/bin:$PATH
COPY --from=julia ${JULIA_PATH} ${JULIA_PATH}
RUN julia --version
RUN julia -e 'using Pkg; Pkg.add("IJulia")'

# Install golang
ENV GO_VERSION=1.15.5
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=golang /usr/local/go/ /usr/local/go/
RUN go get -u github.com/gopherdata/gophernotes \
    && mkdir -p $HOME/.local/share/jupyter/kernels/gophernotes \
    && cp -r /go/src/github.com/gopherdata/gophernotes/kernel/* $HOME/.local/share/jupyter/kernels/gophernotes

# Install Rust 
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
ENV RUST_VERSION=1.48.0
ENV rustupSha256='49c96f3f74be82f4752b8bffcf81961dea5e6e94ce1ccba94435f12e871c3bdb'
RUN set -eux; \
    url="https://static.rust-lang.org/rustup/archive/1.22.1/x86_64-unknown-linux-gnu/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --default-toolchain $RUST_VERSION; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;
RUN cargo install evcxr_jupyter \
    && evcxr_jupyter --install

# Install Ruby
ENV RUBY_VERSION=2.7.2
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
RUN conda install --quiet --yes -c conda-forge \
            'scijava-jupyter-kernel'
## Kotlin
RUN conda install --quiet --yes -c jetbrains \
            'kotlin-jupyter-kernel'
## Scala
RUN curl -Lo coursier https://git.io/coursier-cli \
    && chmod +x coursier \
    && ./coursier launch --fork almond -- --install \
    && rm -f coursier

# Install Erlang and Elixir
# RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb \
#     && dpkg -i erlang-solutions_2.0_all.deb \
#     && rm -f erlang-solutions_2.0_all.deb
# RUN apt-get update; exit 0
# RUN apt-get install  -y --no-install-recommends \
#         erlang \
#         elixir \
RUN wget --header 'Accept-Encoding: gzip' \
        -O /tmp/esl-erlang.deb \
        'https://packages.erlang-solutions.com/erlang/debian/pool/esl-erlang_23.1-1~debian~buster_amd64.deb'
RUN wget --header 'Accept-Encoding: gzip' \
        -O /tmp/elixir.deb \
        'https://packages.erlang-solutions.com/erlang/debian/pool/elixir_1.11.2-1~debian~buster_all.deb'
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        libncurses5 \
        libwxbase3.0-0v5 \
        libwxgtk3.0-0v5 \
        libwxgtk3.0-gtk3-0v5 \
        libsctp1 \
    && dpkg -i /tmp/esl-erlang.deb \
    && dpkg -i /tmp/elixir.deb \
    && rm -rf /tmp/*.deb
RUN mix local.hex --force \
    && mix local.rebar --force
RUN git clone https://github.com/filmor/ierl.git ierl \
    && cd ierl \
    && mkdir $HOME/.ierl \
    && mix deps.get \
    # Build lfe explicitly for now
    && (cd deps/lfe && ~/.mix/rebar3 compile) \
    && env MIX_ENV=prod mix escript.build \
    && cp ierl $HOME/.ierl/ierl.escript \
    && chmod +x $HOME/.ierl/ierl.escript \
    && $HOME/.ierl/ierl.escript install erlang --user \
    && $HOME/.ierl/ierl.escript install elixir --user \
    && cd .. \
    && rm -rf ierl

# ↓ 削除系ははまとめてここでやる    
RUN conda clean --all \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install .NET5
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:/root/.dotnet/tools:$PATH

RUN wget -O dotnet.tar.gz https://download.visualstudio.microsoft.com/download/pr/a0487784-534a-4912-a4dd-017382083865/be16057043a8f7b6f08c902dc48dd677/dotnet-sdk-5.0.101-linux-x64.tar.gz \
    && wget -O dotnet_runtime.tar.gz https://download.visualstudio.microsoft.com/download/pr/6bea1cea-89e8-4bf7-9fc1-f77380443db1/0fb741b7d587cce798ebee80732196ef/aspnetcore-runtime-5.0.1-linux-x64.tar.gz \
    && dotnet_sha512='398d88099d765b8f5b920a3a2607c2d2d8a946786c1a3e51e73af1e663f0ee770b2b624a630b1bec1ceed43628ea8bc97963ba6c870d42bec064bde1cd1c9edb' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && dotnet_runtime_sha512='fec655aed2e73288e84d940fd356b596e266a3e74c37d9006674c4f923fb7cde5eafe30b7dcb43251528166c02724df5856e7174f1a46fc33036b0f8db92688a' \
    && echo "$dotnet_runtime_sha512  dotnet_runtime.tar.gz" | sha512sum -c - \
    && mkdir -p "/usr/share/dotnet" \
    && mkdir -p "/usr/bin/dotnet" \
    && mkdir -p "/root/.dotnet/tools" \
    && tar zxf dotnet.tar.gz -C "/usr/share/dotnet" \
    && rm dotnet.tar.gz \
    && tar zxf dotnet_runtime.tar.gz -C "/usr/share/dotnet" \
    && rm dotnet_runtime.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && dotnet help

RUN dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive \
    && dotnet interactive jupyter install
