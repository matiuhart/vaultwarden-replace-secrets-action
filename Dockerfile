# Container image that runs your code
FROM node:alpine

RUN apk add envsubst && \
    npm install -g @bitwarden/cli

COPY entrypoint.sh /entrypoint.sh
COPY bw_variables_export /bw_variables_export

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["sleep", "3200"]