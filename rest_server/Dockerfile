From node:19-alpine

# Create app directory
WORKDIR /usr/src/app
COPY ./src/package*.json ./

# Download packages
RUN npm install
# If you are building your code for production
# RUN npm ci --omit=dev

# Build
COPY ./src/ ./

# Expose the port that your app binds to
EXPOSE 3000

# Run
CMD ["node", "app.js"]