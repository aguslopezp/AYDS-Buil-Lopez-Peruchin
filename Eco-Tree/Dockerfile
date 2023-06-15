FROM ruby:2.7.5

ADD . /src
WORKDIR /src
#COPY . .
#ENV BUNDLE_APP_CONFIG=/src/.bundler
#RUN gem install bundler:2.3.7

RUN bundle install

EXPOSE 4567

CMD ["/bin/bash"]
