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
RUN apk add --update --no-cache aria2 nginx nginx-mod-http-fancyindex parallel
RUN mkdir -p /etc/aria2\
  && mkdir -p /var/log/aria2\
  && mkdir -p /data\
  && mkdir -p /root/Nginx-Fancyindex-Theme
RUN wget -qO- https://github.com/Naereen/Nginx-Fancyindex-Theme/archive/master.tar.gz | tar --strip-components=1 -C /root/Nginx-Fancyindex-Theme -xvzf -\
  && cp -r /root/Nginx-Fancyindex-Theme/Nginx-Fancyindex-Theme-dark /data/Nginx-Fancyindex-Theme-dark\
  && rm -rf /root/Nginx-Fancyindex-Theme
RUN adduser aria2\
  --disabled-password
RUN addgroup aria2 nginx
VOLUME /data
COPY ./config /app/config
RUN echo "$(cat /app/config/aria2.conf)" >> /etc/aria2/aria2.conf\
  && echo "$(cat /app/config/nginx.conf)" > /etc/nginx/http.d/default.conf
RUN chown -R aria2:aria2 /app\
  && chown -R aria2:aria2 /data\
  && chmod -R 0755 /data
RUN chmod -R g+rwx /var/log/nginx\
  && chmod -R g+rwx /var/lib/nginx\
  && chmod -R g+rwx /run/nginx\
  && chmod -R g+rwx /usr/lib/nginx
# create aria2.session
RUN touch /etc/aria2/aria2.session
COPY --from=aria2webui-builder /app/dist/ /app/static
EXPOSE $WEBUI_PORT $RPC_LISTEN_PORT $BT_LISTEN_PORT $DHT_LISTEN_PORT
USER aria2
CMD [ "/usr/bin/parallel", ":::", "aria2c --conf-path=/etc/aria2/aria2.conf","nginx -g 'daemon off;'" ]