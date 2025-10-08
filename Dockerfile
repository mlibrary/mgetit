FROM ruby:3.4 AS base

#Set up variables for creating a user to run the app in the container
ARG UNAME=app
ARG UID=1000
ARG GID=1000
ARG APP_HOME=/home/${UNAME}
ARG BUNDLE_PATH=/bundle

ENV RAILS_LOG_TO_STDOUT 1
ENV RAILS_SERVE_STATIC_FILES 1
ENV APP_HOME ${APP_HOME}
ENV BUNDLE_PATH ${BUNDLE_PATH}

#Create the group for the user
#Create the User and assign ${APP_HOME} as its home directory
RUN mkdir -p ${APP_HOME} ${BUNDLE_PATH} \
 && groupadd -g ${GID} -o ${UNAME} \
 && useradd -m -d ${APP_HOME} -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME} \
 && chown ${UID}:${GID} ${BUNDLE_PATH} ${APP_HOME}

RUN apt update \
 && apt install -y curl default-libmysqlclient-dev \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR ${APP_HOME}
USER $UNAME
CMD bundle exec puma -C config/puma.rb

FROM base AS development

FROM base AS production

COPY --chown=${UID}:${GID} Gemfile Gemfile.lock ${APP_HOME}/
COPY --chown=${UID}:${GID} gems/ ${APP_HOME}/gems/
RUN bundle install

COPY --chown=${UID}:${GID} . .
RUN mkdir -p ${APP_HOME}/tmp/pids/
RUN bundle exec rake assets:precompile
