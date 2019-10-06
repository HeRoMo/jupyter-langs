# jupyter-langs:latest
FROM golang:1.13.1-buster as golang
FROM node:12.11-buster-slim as nodejs

FROM hero/jupyter-langs:python
LABEL   Maintainer="HeRoMo" \
        Description="Jupyter lab for various languages" \
        Version="3.1.0"

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
            'r-tensorflow'

# Install golang
ENV GO_VERSION=1.13.1 \
    GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=golang /usr/local/go/ /usr/local/go/
RUN go get -u github.com/gopherdata/gophernotes && \
    mkdir -p $HOME/.local/share/jupyter/kernels/gophernotes && \
    cp -r /go/src/github.com/gopherdata/gophernotes/kernel/* $HOME/.local/share/jupyter/kernels/gophernotes

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

# Install Rust 
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.38.0 \
    rustupSha256='36285482ae5c255f2decfab27d32ba19465804cb3ddf5a23e6ff2a7b0f6e0250'
RUN set -eux; \
    url="https://static.rust-lang.org/rustup/archive/1.19.0/x86_64-unknown-linux-gnu/rustup-init"; \
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

# Install Ruby
ENV RUBY_VERSION=2.6.5 \
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

# Install Javascript
ENV YARN_VERSION 1.17.3
RUN mkdir -p /opt
COPY --from=nodejs /opt/yarn-v${YARN_VERSION} /opt/yarn
COPY --from=nodejs /usr/local/bin/node /usr/local/bin/
COPY --from=nodejs /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx
RUN yarn global add ijavascript typescript itypescript @types/node && \
    ijsinstall && \
    its --install=global

# Install Scala and JVM langs
RUN conda install 'openjdk=8.0.152' --quiet --yes \
    && conda install -y -c conda-forge ipywidgets beakerx \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager \
    && jupyter labextension install beakerx-jupyterlab \
    && rm -rf /root/anaconda3/share/jupyter/kernels/clojure \
    && rm -rf /root/anaconda3/share/jupyter/kernels/sql \
    && conda build purge-all
# ↑ conda build purge-all はまとめてここでやる