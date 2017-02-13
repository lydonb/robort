FROM node
MAINTAINER Daniel Ness, daniel@everyonce.com
# Robort Dockerfile
# copy the env.sample file to your own environment file, put it wherever you want (/home/user/robort.env)
# Build the docker container image with:
#
# docker build -t myrobort .
#
# Run a new container based on your image above:
#
# docker run -it --env-file=/home/user/robort.env myrobort
#
ENV BOTDIR /opt/bot
ENV HUBOT_PORT 8080
ENV HUBOT_ADAPTER slack
ENV HUBOT_NAME bot-name
ENV HUBOT_GOOGLE_API_KEY xxxxxxxxxxxxxxxxxxxxxx
ENV HUBOT_SLACK_TOKEN xxxxxxxxxxxxxxxxxxxxx
ENV HUBOT_SLACK_TEAM team-name
ENV HUBOT_SLACK_BOTNAME ${HUBOT_NAME}
ENV PORT ${HUBOT_PORT}

EXPOSE ${HUBOT_PORT}

# RUN git clone --depth=1 https://github.com/lydonb/robort.git ${BOTDIR}

WORKDIR ${BOTDIR}

ADD . ${BOTDIR}

RUN npm install

CMD bin/hubot
