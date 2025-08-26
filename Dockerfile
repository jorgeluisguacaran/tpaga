FROM ruby:3.3-slim-trixie AS development

RUN apt update
RUN apt upgrade -y
RUN apt install -y build-essential libpq-dev curl git libjemalloc2 libvips &&\
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV DIR=/var/www

RUN mkdir $DIR
WORKDIR $DIR

ENV GEM_HOME=/bundle
ENV BUNDLE_PATH=/bundle
ENV BUNDLE_BIN=/bundle/bin
ENV BUNDLE_APP_CONFIG=/bundle
ENV PATH=/bundle/bin:$PATH

COPY . .

COPY ./start.sh .

COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# CMD ["/bin/bash"]

ENTRYPOINT ["./start.sh"]

