FROM node:16.13.1-alpine as builder
LABEL maintainer wanghao 

WORKDIR /home/node
USER node

ENV SASS_BINARY_SITE="http://npm.taobao.org/mirrors/node-sass"
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

COPY --chown=node package.json  ./
RUN npm install --chromedriver_cdnurl=http://cdn.npm.taobao.org/dist/chromedriver --registry=https://registry.npm.taobao.org
COPY --chown=node . ./
RUN npm run build:prod

FROM openresty/openresty:1.19.9.1-2-alpine
COPY --from=builder /home/node/dist/ /usr/share/nginx/html/
COPY --from=builder /home/node/nginx/default.conf /etc/nginx/conf.d/
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

CMD ["nginx", "-g", "daemon off;"]