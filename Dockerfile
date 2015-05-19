FROM ruby:2.2

RUN mkdir /app

WORKDIR /app

ADD Gemfile /app/
ADD Gemfile.lock /app/
RUN bundle install --deployment

ENV PATH /app/bin:$PATH

ADD . /app
