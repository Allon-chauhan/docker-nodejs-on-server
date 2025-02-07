# 🐳 Deploying Docker Application on a Remote Server with Docker Compose

### 🛠️ Technologies Used:
1. Docker
2. Amazon ECR
3. Node.js
4. MongoDB
5. MongoExpress
6. DigitalOcean Droplet

## ✅ Prerequisites:
1. This is a continuation from my previous [repository](https://github.com/Allon-chauhan/docker-node-awsecr).
2. A sample Node.js application downloaded from [here](https://gitlab.com/twn-devops-bootcamp/latest/07-docker/js-app.git).
3. An available account and credits on DigitalOcean to create a remote server.
4. Access key created for your AWS IAM user to configure AWS CLI.
5. SSH key generated on your local machine for secure server access.

### 📜 Configuring `server.js` File
1. Since we are using Docker Compose to create containers and its isolated network, we need to update our `server.js` file to ensure the `node` container can communicate with the `mongodb` container.
2. Add the following code in the `server.js` file:
   ```js
   let mongoUrlDockerCompose = "mongodb://admin:password@mongodb";
   ```
3. Replace `mongoUrlLocal` with `mongoUrlDockerCompose` where `MongoClient.connect` is mentioned.

### 📦 Writing and Configuring `Dockerfile`
1. In the directory where the Node.js application's `app` folder is saved, create a new file named **Dockerfile**.
2. Input the following in the **Dockerfile**:
   ```dockerfile
   FROM node:latest
   
   ENV MONGO_DB_USERNAME=admin \
       MONGO_DB_PWD=password
   
   RUN mkdir -p /home/node-app
   
   COPY ./app /home/node-app
   
   WORKDIR /home/node-app
   
   RUN npm install
   
   CMD ["node", "server.js"]
   ```

### 🔨 Building Docker Image
1. Run the following command to build the Docker image:
   ```bash
   docker build -t my-app .
   ```

⚠️ **IMPORTANT:** 🚨 If your local machine is macOS but the remote server is Linux, build the image for the correct architecture using:
   ```bash
   docker build -t my-app:2.0 --platform linux/amd64 .
   ```

### 🚀 Pushing the Docker Image to AWS ECR
1. **Create a repository** in AWS ECR.
2. **Authenticate Docker** with AWS ECR using the "push commands" available in the AWS ECR portal:
   ```bash
   aws ecr get-login-password --region [region] | \
   docker login --username AWS --password-stdin [aws-account-id].dkr.ecr.[region].amazonaws.com
   ```

   ⚠️ **IMPORTANT:** 🚨 Authentication is required before pushing images to AWS ECR! 🚨

3. **Tag the Docker image** before pushing:
   ```bash
   docker tag my-app:2.0 [aws-account-id].dkr.ecr.[region].amazonaws.com/my-app:2.0
   ```
4. **Push the tagged Docker image** to the AWS ECR repository:
   ```bash
   docker push [aws-account-id].dkr.ecr.[region].amazonaws.com/my-app:2.0
   ```

⚠️ **IMPORTANT:** 🚨 Ensure your AWS credentials and IAM permissions are properly configured to avoid authentication errors! 🚨

(I followed the official [AWS CLI Documentation](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html) to configure environment variables.)

### 🌍 Creating and Configuring a DigitalOcean Droplet
1. **Create a small, cost-effective droplet** in your nearest region.
2. Choose **SSH** as the authentication method.
3. **Create a new SSH key**, copy the public key from your local machine, and save the changes.
4. Once the droplet is ready, note down the **public IPv4** address.
5. **Connect to the server** via terminal:
   ```bash
   ssh root@<droplet-ipv4>
   ```

⚠️ **SECURITY NOTE:** 🚨 Set up firewall rules to allow inbound connections **only from trusted IPs** to ports: **3000** (Node.js app), **8081** (MongoExpress), **27017** (MongoDB), and **SSH**. 🚨

### ⚙️ Installing AWS CLI & Docker on the Remote Server
1. Install Docker:
   ```bash
   snap install docker
   ```
2. Install AWS CLI:
   ```bash
   apt install awscli
   ```

⚠️ **IMPORTANT:** 🚨 Ensure AWS CLI is configured correctly on the remote server for authentication! 🚨

(I followed the official [AWS CLI Documentation](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html) to set up environment variables.)

### 📝 Writing Docker Compose File on Remote Server
1. Create a new file:
   ```bash
   vim docker-compose.yaml
   ```
2. Input the following code:
   ```yaml
   version: '3'
   services:
     own-image:
       image: [aws-account-id].dkr.ecr.[region].amazonaws.com/my-app:latest
       ports:
         - "3000:3000"
     mongodb:
       image: mongo:latest
       ports:
         - "27017:27017"
       environment:
         - MONGO_INITDB_ROOT_USERNAME=admin
         - MONGO_INITDB_ROOT_PASSWORD=password
     mongo-express:
       image: mongo-express:latest
       ports:
         - "8081:8081"
       restart: always
       environment:
         - ME_CONFIG_MONGODB_ADMINUSERNAME=admin
         - ME_CONFIG_MONGODB_ADMINPASSWORD=password
         - ME_CONFIG_MONGODB_SERVER=mongodb
   ```

### ▶️ Running Docker Compose
1. **Start creating containers** by running:
   ```bash
   docker-compose -f docker-compose.yaml up
   ```

### 🔍 Testing
1. Open your browser and navigate to **MongoExpress**:
   ```
   http://[server-public-ip]:8081
   ```
2. **Create a new database** named `user-account`.
3. **Create a new collection** named `users` within `user-account`.
4. If the HTML page doesn’t render properly, use **CURL** to make a POST request from the remote server:
   ```bash
   curl --header "Content-Type: application/json" \
        --request POST \
        --data '{"interests":"coding, travel"}' \
        http://localhost:3000/update-profile
   ```
5. Verify that the data appears in **MongoExpress** under the `users` collection.

🎉 **Deployment Complete!** 🚀
