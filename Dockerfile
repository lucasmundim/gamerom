FROM ruby:3.0.0-alpine as build

RUN apk add --no-cache --virtual .build-deps \
  build-base \
  git

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /app
WORKDIR /app

COPY . .
RUN bundle install

ENTRYPOINT ["bundle", "exec", "./exe/rom"]
