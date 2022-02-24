ARG RUBY_VERSION=3.1.1
FROM ruby:$RUBY_VERSION-slim-buster as base

COPY .docker/Aptfile /tmp/Aptfile

ARG PG_MAJOR=13
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq \
  && apt-get install -yq --no-install-recommends curl gnupg2 \
  && curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list \
  && apt-get update -qq \
  && apt-get -yq dist-upgrade \
  && apt-get install -yq --no-install-recommends \
    libpq-dev \
    postgresql-client-$PG_MAJOR \
  $(cat /tmp/Aptfile | xargs) \
  && apt-get purge -y curl gnupg2 \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

ARG BUNDLER_VERSION=2.3.9
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_BIN=/usr/local/bin \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  MAKE="make --jobs 8" \
  LANG=C.UTF-8 \
  PATH=/app/bin:$PATH

RUN groupadd --gid 1001 nonroot \
  && useradd --uid 1001 --gid nonroot --shell /bin/bash --create-home nonroot

RUN gem update --system && \
  rm -f /usr/local/bin/ruby/gems/*/specifications/default/bundler-*.gemspec && \
  gem install bundler -v $BUNDLER_VERSION

# chown /app so it's writable by yarn & bootsnap
RUN mkdir /app && chown -R nonroot:nonroot /app

WORKDIR /app

FROM base as builder

RUN apt-get update -qq \
  && apt-get install -yq --no-install-recommends build-essential git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

FROM builder as gems

COPY --chown=nonroot:nonroot .bundle/ci-deploy/config /app/.bundle/config
COPY --chown=nonroot:nonroot Gemfile* /app/
RUN bundle install

FROM gems as test
COPY --chown=nonroot:nonroot .bundle/ci-build/config /app/.bundle/config
ENV RAILS_ENV=test

RUN bundle config set --local without deploy && bundle install
COPY --chown=nonroot:nonroot . /app

FROM gems as gems_and_assets

COPY --chown=nonroot:nonroot . /app
COPY --chown=nonroot:nonroot .docker/application.yml /app/config
ARG RAILS_ENV=production

RUN --mount=type=secret,id=app_secrets,target=/app/config/application.yml bundle exec rails assets:precompile \
  && (rm -rf /tmp/* || true) \
  && rm -rf $BUNDLE_PATH/*.gem \
  && find $BUNDLE_PATH/ruby -name "*.c" -delete \
  && find $BUNDLE_PATH/ruby -name "*.o" -delete \
  && find $BUNDLE_PATH/ruby -name ".git"  -type d -prune -execdir rm -rf {} + \
  && bundle exec rails tmp:clear \
  && bundle exec bootsnap precompile --gemfile app/ lib/

# https://github.com/rubygems/rubygems/issues/3225
RUN rm -rf /usr/local/bundle/ruby/*/cache

FROM base as deploy

# copy the gems
COPY --chown=nonroot:nonroot --from=gems_and_assets $BUNDLE_PATH $BUNDLE_PATH
# copy app code
COPY --chown=nonroot:nonroot . /app
# copy bootsnap cache
COPY --chown=nonroot:nonroot --from=gems_and_assets /app/tmp /app/tmp
# copy assets
COPY --chown=nonroot:nonroot --from=gems_and_assets /app/public/assets /app/public/assets

USER nonroot
ENV RAILS_LOG_TO_STDOUT=true

CMD bundle exec rails s -b 0.0.0.0
