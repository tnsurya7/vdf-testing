# Quick Start - VDF Deployment

## 🎯 What You Have

- ✅ **Frontend**: https://sidbi-venture.vercel.app (Deployed on Vercel)
- ⏳ **Backend**: Ready to deploy on Render
- 📦 **Repository**: https://github.com/tnsurya7/vdf-testing

---

## 🚀 Deploy Backend in 5 Minutes

### 1. Create Neon Database (2 min)
```
1. Go to neon.tech → Sign up
2. Create Project → Name: vdf-production
3. Copy connection string
```

### 2. Generate JWT Secret (30 sec)
```bash
openssl rand -base64 32
```

### 3. Deploy on Render (2 min)
```
1. Go to render.com → Sign up with GitHub
2. New + → Web Service
3. Connect: tnsurya7/vdf-testing
4. Configure:
   - Root Directory: backend
   - Environment: Docker
5. Add environment variables (see below)
6. Click "Create Web Service"
```

### 4. Environment Variables
```bash
SPRING_DATASOURCE_URL=<your-neon-connection-string>
SPRING_DATASOURCE_USERNAME=<neon-username>
SPRING_DATASOURCE_PASSWORD=<neon-password>
VDF_JWT_SECRET=<generated-secret>
MAIL_USERNAME=<your-gmail>
MAIL_PASSWORD=<gmail-app-password>
VDF_APP_BASE_URL=https://sidbi-venture.vercel.app
VDF_CORS_ORIGINS=https://sidbi-venture.vercel.app
SPRING_PROFILES_ACTIVE=prod
```

### 5. Update Frontend (30 sec)
```
1. Vercel Dashboard → sidbi-venture
2. Settings → Environment Variables
3. Add: VITE_API_BASE_URL=<your-render-url>
4. Deployments → Redeploy
```

---

## 🧪 Test Your Deployment

### Backend Health Check
```
https://your-backend.onrender.com/actuator/health
```
Should return: `{"status":"UP"}`

### Frontend Login
```
https://sidbi-venture.vercel.app
Email: applicant@demo.com
Password: password
```

---

## 📚 Detailed Guides

- **Full Deployment**: See `DEPLOYMENT.md`
- **Render Specific**: See `RENDER_DEPLOYMENT.md`
- **Security Audit**: See `SECURITY_AUDIT.md`

---

## 🆘 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails | Check Root Directory = `backend` |
| App crashes | Verify all environment variables |
| CORS error | Check VDF_CORS_ORIGINS matches frontend URL |
| Can't login | Check backend logs, verify database connection |
| Email not working | Use Gmail App Password, not account password |

---

## 📞 Need Help?

1. Check logs in Render dashboard
2. Review `RENDER_DEPLOYMENT.md` for detailed steps
3. Verify all environment variables are correct
4. Ensure Neon DB is active and accessible

---

## ✅ Success Checklist

- [ ] Neon database created
- [ ] JWT secret generated
- [ ] Backend deployed on Render
- [ ] All environment variables set
- [ ] Health check returns UP
- [ ] Frontend updated with backend URL
- [ ] Can login to application
- [ ] Dashboard loads correctly

---

**Repository**: https://github.com/tnsurya7/vdf-testing
**Frontend**: https://sidbi-venture.vercel.app
**Backend**: Deploy now on Render!
