FROM node:20.11.0-alpine

WORKDIR /app

# package.json을 최소한으로 설정하고 ethers 최신 버전 설치
RUN npm init -y && npm install ethers@latest --omit=dev

CMD ["node", "index.js"]

# docker build -t blockchain .
# 잘 안되면 node 버전 때문인가? -> ./blockchain
# 걍 일단 node index.js 로 일단 해보기