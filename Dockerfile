FROM node:alpine

RUN apk add envsubst && \
    npm install -g @bitwarden/cli@2024.6.0

COPY entrypoint.sh /entrypoint.sh
COPY bw_variables_export /bw_variables_export

ENTRYPOINT ["/entrypoint.sh"]
