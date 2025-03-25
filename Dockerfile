FROM ruby:3.4.2-alpine

RUN apk add --no-cache --virtual .build-deps \
  build-base \
  ca-certificates \
  curl \
  git

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# Add missing certificates
RUN curl -s https://letsencrypt.org/certs/2024/e5.pem -o /etc/ssl/certs/e5.pem && \
  curl -s https://letsencrypt.org/certs/2024/e5.pem -o /etc/ssl/certs/e5.pem && \
  curl -s https://letsencrypt.org/certs/2024/e6.pem -o /etc/ssl/certs/e6.pem && \
  curl -s https://letsencrypt.org/certs/2024/r10.pem -o /etc/ssl/certs/r10.pem && \
  curl -s https://letsencrypt.org/certs/2024/r11.pem -o /etc/ssl/certs/r11.pem && \
  update-ca-certificates

RUN mkdir -p /bundle && chmod 777 /bundle

ENV GEM_HOME="/bundle"
ENV PATH=$GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

RUN mkdir -p /app
WORKDIR /app

COPY . .
RUN bundle install

ENTRYPOINT ["/app/entrypoint.sh"]
