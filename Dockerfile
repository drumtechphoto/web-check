FROM node:14 as build_node
WORKDIR /app
COPY package.json ./
RUN npm install --save-dev chromedriver && \
    cp $HOME/.npmrc /root/chromium #optional but needed for screenshots
RUN apt-get update -qqy && \
    apt-get install -y --no-install-recommends chromium traceroute python make g++ && \
    rm -rf /var/lib/apt/lists/* /app/node_modules/.cache
# Set the working directory to /app
WORKDIR /app
# Copy package.json and yarn.lock to the working directory
COPY package.json yarn.lock ./
# Run npm install to install dependencies and clear cache
RUN yarn install --frozen-lockfile && \
    rm -rf /app/node_modules/.cache
# Copy all files to working directory
COPY . .
# Run yarn build to build the application
RUN yarn build --production
# Final stage
FROM node:14  AS final
WORKDIR /app
COPY package.json yarn.lock ./
COPY --from=build /app .
RUN apt-get update && \
    apt-get install -y --no-install-recommends chromium traceroute && \
    chmod 755 /usr/bin/chromium && \
    rm -rf /var/lib/apt/lists/* /app/node_modules/.cache
# Set the environment variable CHROME_PATH to specify the path to the Chromium binaries
ENV CHROME_PATH='/usr/bin/chromium'
# Define the command executed when the container starts and start the server.js of the Node.js application
CMD ["yarn", "start"]