# Render Deployment Guide (Docker)

Complete step-by-step guide to deploy VDF backend on Render using Docker.

## 📋 Prerequisites

Before starting, you need:
1. ✅ Neon DB database created and connection string ready
2. ✅ Gmail account with App Password generated
3. ✅ Frontend deployed on Vercel: https://sidbi-venture.vercel.app
4. ✅ GitHub repository: https://github.com/tnsurya7/vdf-testing

---

## 🚀 Step-by-Step Deployment

### Step 1: Create Neon Database (if not done)

1. Go to [neon.tech](https://neon.tech)
2. Sign up/Login
3. Click "Create Project"
4. Name: `vdf-production`
5. Copy connection string:
   ```
   postgresql://username:password@ep-xxx.region.aws.neon.tech/dbname?sslmode=require
   ```

### Step 2: Generate JWT Secret

Run this command in your terminal:
```bash
openssl rand -base64 32
```

Save the output - you'll need it for environment variables.

### Step 3: Deploy to Render

1. Go to [render.com](https://render.com)
2. Sign up/Login with GitHub
3. Click "New +" → "Web Service"

### Step 4: Connect Repository

1. Click "Connect a repository"
2. Find and select: `tnsurya7/vdf-testing`
3. Click "Connect"

### Step 5: Configure Service

Fill in these settings:

**Basic Settings:**
- **Name**: `vdf-backend` (or your preferred name)
- **Region**: Choose closest to your users (e.g., Oregon, Frankfurt)
- **Branch**: `main`
- **Root Directory**: `backend`
- **Environment**: `Docker`
- **Dockerfile Path**: `./Dockerfile` (should auto-detect)

**Instance Type:**
- Free tier: Select "Free" (sleeps after 15 min inactivity)
- Production: Select "Starter" ($7/month, always on)

### Step 6: Add Environment Variables

Click "Advanced" → Scroll to "Environment Variables" → Add these:

```bash
# Database Configuration (from Neon)
SPRING_DATASOURCE_URL=postgresql://username:password@ep-xxx.region.aws.neon.tech/dbname?sslmode=require
SPRING_DATASOURCE_USERNAME=your-neon-username
SPRING_DATASOURCE_PASSWORD=your-neon-password

# JWT Secret (generated in Step 2)
VDF_JWT_SECRET=your-generated-secret-here

# Email Configuration (Gmail)
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-gmail-app-password

# Frontend URL (already deployed)
VDF_APP_BASE_URL=https://sidbi-venture.vercel.app
VDF_CORS_ORIGINS=https://sidbi-venture.vercel.app

# Spring Profile
SPRING_PROFILES_ACTIVE=prod

# Port (Render provides this automatically)
PORT=8080
```

**Important Notes:**
- Replace all placeholder values with your actual credentials
- Don't include quotes around values
- Ensure no extra spaces before/after values
- Gmail password should be the 16-character App Password

### Step 7: Deploy

1. Click "Create Web Service"
2. Wait for deployment (first build takes 5-10 minutes)
3. Watch the logs for any errors

### Step 8: Verify Deployment

Once deployed, you'll get a URL like: `https://vdf-backend-xxxx.onrender.com`

**Test the backend:**

1. **Health Check:**
   ```
   https://your-backend-url.onrender.com/actuator/health
   ```
   Should return: `{"status":"UP"}`

2. **API Documentation:**
   ```
   https://your-backend-url.onrender.com/swagger-ui.html
   ```
   Should show Swagger UI

3. **Test Login:**
   ```bash
   curl -X POST https://your-backend-url.onrender.com/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"applicant@demo.com","password":"password"}'
   ```
   Should return JWT token

### Step 9: Update Frontend

1. Go to Vercel dashboard
2. Open your project: `sidbi-venture`
3. Go to Settings → Environment Variables
4. Update or add:
   ```
   VITE_API_BASE_URL=https://your-backend-url.onrender.com
   ```
5. Go to Deployments → Click "..." → "Redeploy"

### Step 10: Test Full Application

1. Open: https://sidbi-venture.vercel.app
2. Login with demo user:
   - Email: `applicant@demo.com`
   - Password: `password`
3. Verify you can see the dashboard

---

## 🐛 Troubleshooting

### Build Fails

**Error: "Cannot find Dockerfile"**
- Solution: Ensure Root Directory is set to `backend`
- Check Dockerfile Path is `./Dockerfile`

**Error: "Maven build failed"**
- Check logs for specific error
- Ensure pom.xml is valid
- Try deploying again (sometimes transient issues)

### Deployment Succeeds but App Crashes

**Check logs for:**

1. **Database Connection Error**
   ```
   Connection refused / timeout
   ```
   - Verify SPRING_DATASOURCE_URL is correct
   - Ensure `?sslmode=require` is at the end
   - Check Neon DB is active

2. **JWT Secret Error**
   ```
   JWT secret must be at least 256 bits
   ```
   - Generate new secret: `openssl rand -base64 32`
   - Update VDF_JWT_SECRET environment variable

3. **Email Configuration Error**
   ```
   Authentication failed
   ```
   - Verify Gmail App Password is correct
   - Ensure 2FA is enabled on Gmail account
   - Check MAIL_USERNAME and MAIL_PASSWORD

### Frontend Can't Connect

**CORS Error in Browser Console:**
```
Access to XMLHttpRequest blocked by CORS policy
```

**Solution:**
1. Go to Render dashboard
2. Open your service
3. Environment → Edit VDF_CORS_ORIGINS
4. Ensure it matches exactly: `https://sidbi-venture.vercel.app`
5. Save and redeploy

### Service Sleeps (Free Tier)

**Issue:** Backend sleeps after 15 minutes of inactivity

**Solutions:**
1. Upgrade to Starter plan ($7/month) - always on
2. Use a ping service (e.g., UptimeRobot) to keep it awake
3. Accept the cold start delay (15-30 seconds on first request)

---

## 📊 Monitoring

### View Logs
1. Render Dashboard → Your Service
2. Click "Logs" tab
3. Filter by severity: Info, Warning, Error

### Check Metrics
1. Render Dashboard → Your Service
2. Click "Metrics" tab
3. View CPU, Memory, Request rate

### Health Endpoint
Monitor: `https://your-backend-url.onrender.com/actuator/health`

---

## 🔄 Updating the Application

### Automatic Deployment
Render automatically redeploys when you push to `main` branch:

```bash
git add .
git commit -m "Update backend"
git push origin main
```

### Manual Deployment
1. Render Dashboard → Your Service
2. Click "Manual Deploy" → "Deploy latest commit"

### Rollback
1. Render Dashboard → Your Service
2. Click "Events" tab
3. Find previous successful deployment
4. Click "Rollback to this version"

---

## 💰 Cost Breakdown

### Free Tier
- **Cost**: $0/month
- **Limitations**: 
  - Sleeps after 15 min inactivity
  - 750 hours/month
  - Shared CPU/RAM
- **Best for**: Development, testing, demos

### Starter Plan
- **Cost**: $7/month
- **Benefits**:
  - Always on (no sleep)
  - Dedicated resources
  - Better performance
- **Best for**: Production, small apps

### Professional Plan
- **Cost**: $25/month
- **Benefits**:
  - More resources
  - Auto-scaling
  - Priority support
- **Best for**: High-traffic production apps

---

## 🔐 Security Checklist

After deployment, verify:

- [ ] All environment variables are set correctly
- [ ] JWT_SECRET is strong and unique (not example value)
- [ ] Database password is strong
- [ ] Gmail App Password is used (not account password)
- [ ] CORS is set to specific frontend URL (not *)
- [ ] HTTPS is enforced (Render does this automatically)
- [ ] Health endpoint is accessible
- [ ] Swagger UI is accessible (for testing only)
- [ ] No secrets in logs or error messages

---

## 📞 Support

**Render Support:**
- Documentation: https://render.com/docs
- Community: https://community.render.com
- Status: https://status.render.com

**Common Issues:**
1. Build fails → Check Dockerfile and logs
2. App crashes → Check environment variables
3. Can't connect → Check CORS settings
4. Slow response → Consider upgrading plan

---

## ✅ Deployment Complete!

Your backend should now be running at:
```
https://your-backend-url.onrender.com
```

Your frontend should be accessible at:
```
https://sidbi-venture.vercel.app
```

Test the full application and verify all features work correctly!
