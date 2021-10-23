FROM alpine:3 AS aria2webui-builder

WORKDIR /app
RUN apk add --update nodejs npm
RUN wget -qO- https://github.com/mayswind/AriaNg/archive/master.tar.gz | tar --strip-components=1 -C /app -xvzf -
RUN npm i -g gulp
RUN npm i -y
RUN gulp clean build

FROM alpine:3

ENV WEBUI_PORT 3000
ENV RPC_LISTEN_PORT 6800
ENV BT_LISTEN_PORT 51413
ENV DHT_LISTEN_PORT 51415
WORKDIR /app

RUN apk add --update --no-cache aria2 thttpd supervisor
RUN apk add --update gosu --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN adduser aria2\
  --disabled-password
RUN mkdir -p /etc/aria2\
  && mkdir -p /var/log/aria2\
  && mkdir -p /aria2download
VOLUME /aria2download
COPY ./config /app/config
RUN echo "$(cat /app/config/supervisor.conf)" >> /etc/supervisord.conf\
  && echo "$(cat /app/config/aria2.conf)" >> /etc/aria2/aria2.conf
RUN chown -R aria2:aria2 /app\
  && chown -R aria2:aria2 /aria2download\
  && chmod -R 0777 /aria2download

# create aria2.session
RUN touch /etc/aria2/aria2.session

COPY --from=aria2webui-builder /app/dist/ /app/static

EXPOSE $WEBUI_PORT $RPC_LISTEN_PORT $BT_LISTEN_PORT $DHT_LISTEN_PORT

CMD [ "supervisord","-c","/etc/supervisord.conf" ]