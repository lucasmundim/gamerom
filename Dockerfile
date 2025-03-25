FROM ruby:3.4.2-alpine

RUN apk add --no-cache --virtual .build-deps \
  build-base \
  git

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /bundle && chmod 777 /bundle

ENV GEM_HOME="/bundle"
ENV PATH=$GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

RUN mkdir -p /app
WORKDIR /app

COPY . .
RUN bundle install

ENTRYPOINT ["/app/entrypoint.sh"]
