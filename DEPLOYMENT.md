# 🚀 NearMe Backend Deployment Guide

This guide provides step-by-step instructions to deploy the NearMe Node.js backend and PostgreSQL database to a Linux VPS (Virtual Private Server) using Docker.

## 📋 Prerequisites
Before you begin, ensure you have the following on your local machine and your VPS:
1. A Linux VPS (Ubuntu 22.04/24.04 recommended) with a public IP address.
2. Root or `sudo` access to the VPS.
3. SSH client on your local machine to connect to the server.

---

## 🛠️ Step 1: Connect to your VPS

Open a terminal on your computer and connect to your VPS using SSH:
```bash
ssh root@YOUR_VPS_IP_ADDRESS
```
*(Replace `YOUR_VPS_IP_ADDRESS` with the actual IP address of your server)*

---

## 🐋 Step 2: Install Docker and Docker Compose

Once connected to your VPS, update the package list and install Docker:

```bash
# Update packages
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install docker.io -y

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo apt install docker-compose-v2 -y
```

---

## 📂 Step 3: Transfer your Code to the VPS

You need to get your `backend` folder onto the VPS. You can either use **Git** to clone your repository, or **SCP** (Secure Copy) from your local machine. 

### Option A: Using Git (Recommended)
```bash
git clone https://github.com/your-repo/Community-App.git
cd Community-App/backend
```

### Option B: Using SCP (Run this on your LOCAL computer, not the VPS)
```bash
# Upload the entire backend folder to the root directory of your VPS
scp -r d:\D-Drive\App_Project\Community-App\backend root@YOUR_VPS_IP_ADDRESS:~/backend
```
Then, on the VPS, navigate to the folder:
```bash
cd ~/backend
```

---

## ⚙️ Step 4: Configure Environment Variables

Inside the `backend` directory on your VPS, you need to ensure your `.env` file is set up correctly.

```bash
# Create or edit the .env file
nano .env
```

Paste the following configuration (make sure the PORT matches what you configured, e.g., 3002):

```env
PORT=3002
DB_USER=postgres
DB_HOST=db
DB_NAME=community_app
DB_PASSWORD=bps
DB_PORT=5432
JWT_SECRET=supersecretjwtkey_change_in_production_to_something_secure
```
*Press `CTRL+X`, then `Y`, then `ENTER` to save and exit nano.*

---

## 🚀 Step 5: Build and Run the Docker Containers

Now that your code and `.env` are ready, use Docker Compose to start the application and the database.

```bash
# Build the Docker image and start the containers in the background (-d)
sudo docker compose up -d --build
```

Docker will:
1. Pull the PostgreSQL 15 image.
2. Build the Node.js backend image using your `Dockerfile`.
3. Mount `schema.sql` so the database automatically creates your tables.
4. Start both services.

---

## ✅ Step 6: Verify the Deployment

Check if your containers are running properly:

```bash
sudo docker compose ps
```
You should see both `community_backend` and `community_postgres` marked as `Up`.

Check the backend logs to make sure there are no errors:
```bash
sudo docker compose logs -f backend
```
You should see a message like: `Server is running on port 3002`. *(Press `CTRL+C` to exit logs)*

---

## 🌐 Step 7: Access Your API

Your backend is now live! You can test it by visiting this URL in your browser or Postman:
```text
http://YOUR_VPS_IP_ADDRESS:3002/
```

### Connecting Your Flutter App:
In your Flutter app (`app_config.dart` or API service), change your API Base URL to point to your VPS:
```dart
const String apiBaseUrl = 'http://YOUR_VPS_IP_ADDRESS:3002/api';
```

---

## 🔒 Step 8: (Optional but Recommended) Setup Nginx and SSL/HTTPS

Mobile apps (especially iOS) often require **HTTPS** connections. To add SSL to your backend, set up an Nginx reverse proxy.

1. **Install Nginx:**
   ```bash
   sudo apt install nginx -y
   ```
2. **Configure Nginx:**
   ```bash
   sudo nano /etc/nginx/sites-available/nearme-backend
   ```
   *Add the following, replacing `yourdomain.com` with your actual domain:*
   ```nginx
   server {
       listen 80;
       server_name yourdomain.com;

       location / {
           proxy_pass http://localhost:3002;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```
3. **Enable the site and restart Nginx:**
   ```bash
   sudo ln -s /etc/nginx/sites-available/nearme-backend /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```
4. **Get a free SSL Certificate (Certbot):**
   ```bash
   sudo apt install certbot python3-certbot-nginx -y
   sudo certbot --nginx -d yourdomain.com
   ```

Your backend is now securely hosted at `https://yourdomain.com`! 🎉
