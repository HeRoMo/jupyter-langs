# jupyter-langs:latest
FROM golang:1.16.4-buster as golang
FROM julia:1.6.1-buster as julia

FROM ghcr.io/heromo/jupyter-langs/python:latest
LABEL Maintainer="HeRoMo"
LABEL Description="Jupyter lab for various languages"
LABEL Version="5.6.0"

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
ENV GO_VERSION=1.16.4
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

# Install Rust 
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
ENV RUST_VERSION=1.51.0
ENV rustupSha256='ed7773edaf1d289656bdec2aacad12413b38ad0193fff54b2231f5140a4b07c5'
RUN set -eux; \
    url="https://static.rust-lang.org/rustup/archive/1.23.1/x86_64-unknown-linux-gnu/rustup-init"; \
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
ENV RUBY_VERSION=3.0.0
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
        'https://packages.erlang-solutions.com/erlang/debian/pool/esl-erlang_23.2.3-1~debian~buster_amd64.deb'
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

# Install .NET5
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:/root/.dotnet/tools:$PATH
RUN wget -O dotnet.tar.gz https://download.visualstudio.microsoft.com/download/pr/73a9cb2a-1acd-4d20-b864-d12797ca3d40/075dbe1dc3bba4aa85ca420167b861b6/dotnet-sdk-5.0.201-linux-x64.tar.gz \
    && wget -O dotnet_runtime.tar.gz https://download.visualstudio.microsoft.com/download/pr/131d9f6b-0f49-474e-a7c5-33754d4e9195/52fae63c358d8e8e6211a50a64fe3dfd/aspnetcore-runtime-5.0.4-linux-x64.tar.gz \
    && dotnet_sha512='099084cc7935482e363bd7802d2fdd909b3d72d2e9706e9ba4df95e3d142a28b780d2b85e5fb4662dcaad18e91c7e06519184fae981a521425eed605770c3c5a' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && dotnet_runtime_sha512='6075649abf4f99ff19f472a3ce6290cf277e7620ab9e65a09d5884a265c50884d50496d6ceb70011b9caaad09ff8428a149cb0aa0b965a17f0a4f5f5e02b920c' \
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

# ↓ 削除系ははまとめてここでやる    
RUN conda clean --all \
    && apt-get autoremove \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*
