FROM ruby:2.5

#Set up variables for creating a user to run the app in the container
ARG UNAME=app
ARG UID=1000
ARG GID=1000

#Create the group for the user
RUN groupadd -g ${GID} -o ${UNAME}

#Create the User and assign /app as its home directory
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}

RUN apt update && \
  apt install -y curl default-libmysqlclient-dev && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*


ENV BUNDLE_PATH /bundle
ENV RAILS_LOG_TO_STDOUT 1
ENV RAILS_SERVE_STATIC_FILES 1
ENV APP_HOME /home/app


RUN mkdir -p ${BUNDLE_PATH} ${APP_HOME} && chown ${UID}:${GID} ${BUNDLE_PATH} ${APP_HOME}
WORKDIR $APP_HOME

USER $UNAME

COPY  --chown=${UID}:${GID} Gemfile Gemfile.lock ${APP_HOME}/
RUN bundle install

COPY . .

CMD bundle exec rails s
