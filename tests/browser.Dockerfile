FROM mcr.microsoft.com/playwright:v1.62.1-noble
WORKDIR /runner
RUN npm init -y && npm install --save-exact playwright@1.62.1
COPY . /kit
ENV HOME=/tmp/browser-home
USER pwuser
CMD ["node", "/kit/tests/browser-fixtures.cjs"]
