FROM node:fermium-slim

WORKDIR /srv

#RUN yarn create strapi-app strapi --no-run --quickstart
#RUN yarn --cwd ./strapi install
#RUN yarn --cwd ./strapi build

RUN echo 'if [ -f "/app/strapi/package.json" ]; then' >> start.sh
RUN echo '  yarn --cwd /app/strapi && yarn --cwd /app/strapi start' >> start.sh
RUN echo 'else' >> start.sh
RUN echo '  tail -f /dev/null' >> /srv/start.sh
RUN echo 'fi' >> start.sh
RUN chmod +x start.sh

RUN echo 'if [ -f "/app/strapi/package.json" ]; then' >> develop.sh
RUN echo '  yarn --cwd /app/strapi && yarn --cwd /app/strapi develop' >> develop.sh
RUN echo 'else' >> develop.sh
RUN echo '  tail -f /dev/null' >> /srv/develop.sh
RUN echo 'fi' >> develop.sh
RUN chmod +x develop.sh

EXPOSE 1337

VOLUME ["/app/strapi"]

CMD ["/srv/start.sh"]
