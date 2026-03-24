# VDF Deployment Guide

Complete guide for deploying VDF application to production.

## 📋 Prerequisites

- GitHub account
- Vercel account (for frontend)
- Render account (for backend)
- Neon DB account (for database)
- Gmail account with App Password (for email notifications)

---

## 🗄️ Step 1: Setup Neon Database

1. Go to [neon.tech](https://neon.tech) and sign up/login
2. Click "Create Project"
3. Choose a name: `vdf-production`
4. Select region closest to your users
5. Click "Create Project"
6. Copy the connection string (looks like):
   ```
   postgresql://username:password@ep-xxx.region.aws.neon.tech/dbname?sslmode=require
   ```
7. Save these values:
   - Full URL: `postgresql://...`
   - Username: (from connection string)
   - Password: (from connection string)

---

## 🔧 Step 2: Setup Gmail App Password

1. Go to your Google Account settings
2. Enable 2-Factor Authentication if not already enabled
3. Go to Security → 2-Step Verification → App passwords
4. Generate new app password for "Mail"
5. Copy the 16-character password (format: `xxxx xxxx xxxx xxxx`)
6. Save this password securely

---

## 🚀 Step 3: Deploy Backend to Render

1. Go to [render.com](https://render.com) and sign up/login
2. Click "New +" → "Web Service"
3. Connect your GitHub repository: `tnsurya7/vdf-testing`
4. Configure the service:
   - **Name**: `vdf-backend`
   - **Region**: Choose closest to your users
   - **Branch**: `main`
   - **Root Directory**: `backend`
   - **Runtime**: `Java`
   - **Build Command**: `mvn clean package -DskipTests`
   - **Start Command**: `java -jar target/vdf-backend-1.0.0-SNAPSHOT.jar`
   - **Instance Type**: Free or Starter

5. Add Environment Variables (click "Advanced" → "Add Environment Variable"):

   ```
   SPRING_DATASOURCE_URL=<your-neon-connection-string>
   SPRING_DATASOURCE_USERNAME=<your-neon-username>
   SPRING_DATASOURCE_PASSWORD=<your-neon-password>
   VDF_JWT_SECRET=<generate-random-256-bit-string>
   MAIL_USERNAME=<your-gmail-address>
   MAIL_PASSWORD=<your-gmail-app-password>
   VDF_APP_BASE_URL=https://your-frontend-url.vercel.app
   VDF_CORS_ORIGINS=https://your-frontend-url.vercel.app
   SPRING_PROFILES_ACTIVE=prod
   ```

   **To generate JWT_SECRET** (run in terminal):
   ```bash
   openssl rand -base64 32
   ```

6. Click "Create Web Service"
7. Wait for deployment (first deploy takes 5-10 minutes)
8. Copy your backend URL: `https://vdf-backend-xxxx.onrender.com`

---

## 🎨 Step 4: Deploy Frontend to Vercel

1. Go to [vercel.com](https://vercel.com) and sign up/login
2. Click "Add New" → "Project"
3. Import your GitHub repository: `tnsurya7/vdf-testing`
4. Configure the project:
   - **Framework Preset**: Vite
   - **Root Directory**: `frontend`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`

5. Add Environment Variable:
   ```
   VITE_API_BASE_URL=<your-render-backend-url>
   ```
   Example: `https://vdf-backend-xxxx.onrender.com`

6. Click "Deploy"
7. Wait for deployment (2-3 minutes)
8. Copy your frontend URL: `https://your-project.vercel.app`

---

## 🔄 Step 5: Update Backend CORS

1. Go back to Render dashboard
2. Open your backend service
3. Go to "Environment" tab
4. Update these variables with your actual Vercel URL:
   ```
   VDF_APP_BASE_URL=https://your-project.vercel.app
   VDF_CORS_ORIGINS=https://your-project.vercel.app
   ```
5. Click "Save Changes"
6. Service will automatically redeploy

---

## ✅ Step 6: Verify Deployment

1. Open your frontend URL in browser
2. You should see the VDF login page
3. Try logging in with demo user:
   - Email: `applicant@demo.com`
   - Password: `password`

4. Check backend health:
   - Visit: `https://your-backend-url.onrender.com/swagger-ui.html`
   - You should see API documentation

---

## 🔐 Security Checklist

- [ ] JWT_SECRET is a strong random string (not the example)
- [ ] Database password is strong and unique
- [ ] Gmail App Password is used (not account password)
- [ ] CORS is set to your specific frontend URL (not *)
- [ ] No .env files committed to git
- [ ] All secrets are in environment variables only

---

## 🐛 Troubleshooting

### Backend won't start
- Check Render logs for errors
- Verify all environment variables are set
- Ensure Neon DB connection string is correct
- Check if database is accessible

### Frontend can't connect to backend
- Verify VITE_API_BASE_URL is correct
- Check CORS settings in backend
- Look at browser console for errors
- Ensure backend is running (not sleeping)

### Database connection errors
- Verify Neon DB is active
- Check connection string format
- Ensure SSL mode is included: `?sslmode=require`
- Check if IP is whitelisted (Neon allows all by default)

### Email not sending
- Verify Gmail App Password is correct
- Check if 2FA is enabled on Gmail
- Look at backend logs for email errors
- Ensure MAIL_USERNAME and MAIL_PASSWORD are set

---

## 📊 Monitoring

### Render (Backend)
- View logs: Dashboard → Your Service → Logs
- Monitor metrics: Dashboard → Your Service → Metrics
- Check health: Visit `/actuator/health` endpoint

### Vercel (Frontend)
- View deployments: Dashboard → Your Project → Deployments
- Check analytics: Dashboard → Your Project → Analytics
- View logs: Click on deployment → View Function Logs

### Neon (Database)
- Monitor usage: Dashboard → Your Project → Usage
- View queries: Dashboard → Your Project → Queries
- Check connections: Dashboard → Your Project → Operations

---

## 🔄 Updating the Application

### Update Code
```bash
git add .
git commit -m "Your update message"
git push origin main
```

Both Vercel and Render will automatically redeploy on push to main branch.

### Update Environment Variables
- Render: Dashboard → Service → Environment → Edit
- Vercel: Dashboard → Project → Settings → Environment Variables

---

## 💰 Cost Estimates

- **Neon DB**: Free tier (0.5 GB storage, 100 hours compute/month)
- **Render**: Free tier (750 hours/month, sleeps after 15 min inactivity)
- **Vercel**: Free tier (100 GB bandwidth, unlimited deployments)

**Total**: $0/month for development/testing

For production with better performance:
- Neon Pro: ~$19/month
- Render Starter: ~$7/month
- Vercel Pro: ~$20/month
**Total**: ~$46/month

---

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review service logs (Render/Vercel dashboards)
3. Verify all environment variables are correct
4. Ensure database is accessible
