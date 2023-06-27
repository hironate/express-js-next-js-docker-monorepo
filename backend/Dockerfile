FROM node:16.15.0-alpine as base
ENV NODE_ENV=production
EXPOSE 3000
WORKDIR /app
COPY package*.json ./
RUN npm config list \ 
    && npm ci --only=production \
    && npm cache clean --force
ENV PATH /app/node_modules/.bin:$PATH

FROM base as dev
ENV NODE_ENV=development
RUN npm config list \ 
    && npm i --only=development \
    && npm cache clean --force
COPY . .
USER node

FROM dev as test
ENV NODE_ENV=development


FROM dev as pre-prod
USER root
RUN rm -rf ./node_modules

FROM base as prod
COPY --from=pre-prod /app /app/
USER node