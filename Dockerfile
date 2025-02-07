FROM node:latest

ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PWD=password

RUN mkdir -p /hom/node-app

COPY ./app /home/node-app

WORKDIR /home/node-app

RUN npm install

CMD ["node", "server.js"]