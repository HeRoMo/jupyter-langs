# jupyter-langs:latest
FROM hero/jupyter-langs:python
LABEL   Maintainer="HeRoMo" \
        Description="Jupyter lab for various languages" \
        Version="2.1.0"

# Install SPARQL
RUN pip install sparqlkernel && \
    jupyter sparqlkernel install

# Install R
RUN conda install --quiet --yes \
            'r-base' \
            'r-irkernel' \
            'r-plyr' \
            'r-devtools' \
            'r-tidyverse' \
            'r-shiny' \
            'r-rmarkdown' \
            'r-forecast' \
            'r-rsqlite' \
            'r-reshape2' \
            'r-nycflights13' \
            'r-caret' \
            'r-rcurl' \
            'r-crayon' \
            'r-randomforest' \
            'r-tensorflow' \
    && conda build purge-all

# Install Javascript
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        yarn \
        nodejs \
    && rm -rf /var/lib/apt/lists/*
RUN yarn global add ijavascript itypescript && \
    ijsinstall && \
    its --install=global

# Install golang
ENV GO_VERSION=1.12.1 \
    GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
RUN wget -O go.tgz https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go.tgz && \
    rm go.tgz
RUN go get -u github.com/gopherdata/gophernotes && \
    mkdir -p $HOME/.local/share/jupyter/kernels/gophernotes && \
    cp -r /go/src/github.com/gopherdata/gophernotes/kernel/* $HOME/.local/share/jupyter/kernels/gophernotes

# Install Rust 
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.33.0 \
    rustupSha256='2d4ddf4e53915a23dda722608ed24e5c3f29ea1688da55aa4e98765fc6223f71'
RUN set -eux; \
    url="https://static.rust-lang.org/rustup/archive/1.16.0/x86_64-unknown-linux-gnu/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --default-toolchain $RUST_VERSION; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;
RUN cargo install evcxr_jupyter && \
    evcxr_jupyter --install

# Install Scala and JVM langs
RUN conda install 'openjdk>8.0.121' --quiet --yes \
    && conda install -y -c conda-forge ipywidgets beakerx \
    && conda build purge-all \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager \
    && jupyter labextension install beakerx-jupyterlab \
    && rm -rf /root/anaconda3/share/jupyter/kernels/clojure \
    && rm -rf /root/anaconda3/share/jupyter/kernels/sql

# Install Erlang and Elixir
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && dpkg -i erlang-solutions_1.0_all.deb \
    && apt-get update -y \
    && apt-get install  -y --no-install-recommends \
        erlang \
        elixir \
    && rm -rf /var/lib/apt/lists/* \
    && mix local.hex --force \
    && mix local.rebar --force
RUN git clone https://github.com/filmor/ierl.git ierl && \
    cd ierl && \
    mkdir $HOME/.ierl && \
    mix deps.get && \
    # Build lfe explicitly for now
    (cd deps/lfe && ~/.mix/rebar3 compile) && \
    env MIX_ENV=prod mix escript.build && \
    cp ierl $HOME/.ierl/ierl.escript && \
    chmod +x $HOME/.ierl/ierl.escript && \
    $HOME/.ierl/ierl.escript install erlang --user && \
    $HOME/.ierl/ierl.escript install elixir --user && \
    cd .. && \
    rm -rf ierl

# Install Ruby
ENV RUBY_VERSION=2.6.2 \
    RUBY_HOME=/opt/ruby
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
