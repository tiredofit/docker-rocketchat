FROM tiredofit/alpine:3.4
MAINTAINER Dave Conroy <dave at tiredofit dot ca>

### Set Environment Variables
ENV RC_VERSION 0.58.1
# needs a mongoinstance - defaults to container linking with alias 'db'
ENV MONGO_URL=mongodb://db:27017/meteor \
    HOME=/tmp \
    PORT=3000 \
    ROOT_URL=http://localhost:3000 \
    Accounts_AvatarStorePath=/app/uploads/avatars

### Create Accounts
RUN addgroup -g 1100 rocketchat && \
    adduser -Ss /bin/false -u 1100 -G rocketchat -h /app rocketchat && \
    mkdir -p /app/uploads && \
    chown rocketchat:rocketchat /app/uploads

### Build Rocketchat
# gpg: key 4FD08014: public key "Rocket.Chat Buildmaster <buildmaster@rocket.chat>" imported
RUN apk update && \
    apk add --no-cache \
        curl \
        g++ \
        gnupg \
        nodejs-lts \ 
        make \
        python && \
    gpg --keyserver pgp.mit.edu --recv-keys "0E163286C20D07B9787EBE9FD7F9D0414FD08104" && \
    cd /app && \
    curl -fSL "https://rocket.chat/releases/${RC_VERSION}/download" -o rocket.chat.tgz && \
    curl -fSL "https://rocket.chat/releases/${RC_VERSION}/asc" -o rocket.chat.tgz.asc && \
    gpg --batch --verify rocket.chat.tgz.asc rocket.chat.tgz && \
    tar zxvf rocket.chat.tgz && \
    rm rocket.chat.tgz rocket.chat.tgz.asc && \
    cd /app/bundle/programs/server && \
    npm install && \
    apk del gnupg


### S6 Configuration
ADD install/s6 /etc/s6

### Networking Configuration
EXPOSE 3000

### Entrypoint Configuration
WORKDIR /app/bundle
ENTRYPOINT ["/init"]

