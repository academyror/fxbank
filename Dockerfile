# syntax = docker/dockerfile:1
# Multi-stage production build for FxBank SaaS Platform
# Course 1: Building a Modern SaaS Banking Application with Ruby on Rails
ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# -------------------------------------------------------------
# Stage 1: Build stage (compilers, asset bundling, gem install)
# -------------------------------------------------------------
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev nodejs npm && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock* ./
RUN if [ -f yarn.lock ]; then npm install -g yarn && yarn install --frozen-lockfile; else npm install; fi

COPY . .
RUN SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

# -------------------------------------------------------------
# Stage 2: Final minimal runtime stage
# -------------------------------------------------------------
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libpq5 libvips libjemalloc2 postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Optimize memory allocation with jemalloc
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libjemalloc.so.2"

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run as non-root user for banking security compliance:
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
