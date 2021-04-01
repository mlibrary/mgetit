FROM ruby:2.4

RUN apt update && \
  apt install -y curl default-libmysqlclient-dev && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*


ENV BUNDLE_PATH /bundle
ENV RAILS_LOG_TO_STDOUT 1
ENV RAILS_SERVE_STATIC_FILES 1
ENV APP_HOME /home/app


RUN mkdir -p $BUNDLE_PATH $APP_HOME
WORKDIR $APP_HOME

#COPY Gemfile Gemfile.lock ${APP_HOME}/
#RUN bundle install

COPY . .

CMD bundle exec rails s
