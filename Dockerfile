FROM rails:4.2.6
MAINTAINER jay.lynch@eulersbridge.com

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY . ./
RUN cat ./hosts >> /etc/hosts
