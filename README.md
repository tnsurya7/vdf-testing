# VDF (Venture Debt Fund) Application

Full-stack application for managing venture debt fund applications with workflow management.

## 🏗️ Architecture

- **Frontend**: React + TypeScript + Vite + Tailwind CSS
- **Backend**: Spring Boot 3.2 + PostgreSQL
- **Authentication**: JWT-based auth with role-based access control

## 📁 Project Structure

```
vdf-testing/
├── frontend/          # React frontend application
│   ├── src/
│   ├── package.json
│   └── vercel.json   # Vercel deployment config
├── backend/           # Spring Boot backend API
│   ├── src/
│   ├── pom.xml
│   └── render.yaml   # Render deployment config
└── README.md
```

## 🚀 Deployment

### Frontend (Vercel)

1. Push code to GitHub
2. Import project in Vercel
3. Set root directory to `frontend`
4. Add environment variable:
   - `VITE_API_BASE_URL`: Your backend URL (e.g., `https://your-app.onrender.com`)
5. Deploy

### Backend (Render)

1. Create PostgreSQL database on Neon DB
2. Import project in Render
3. Set root directory to `backend`
4. Add environment variables:
   - `SPRING_DATASOURCE_URL`: Neon DB connection string
   - `SPRING_DATASOURCE_USERNAME`: Database username
   - `SPRING_DATASOURCE_PASSWORD`: Database password
   - `VDF_JWT_SECRET`: Random 256-bit secret key
   - `MAIL_USERNAME`: Gmail address
   - `MAIL_PASSWORD`: Gmail app password
   - `VDF_APP_BASE_URL`: Your frontend URL
   - `VDF_CORS_ORIGINS`: Your frontend URL
5. Deploy

### Database (Neon DB)

1. Create account at neon.tech
2. Create new PostgreSQL database
3. Copy connection string
4. Database schema will be created automatically by Flyway migrations on first backend startup

## 🔐 Security

- Never commit `.env` files
- Never commit `run.ps1` or `run.sh` with real credentials
- Use environment variables for all secrets
- Rotate JWT secrets regularly
- Use Gmail app passwords, not account passwords

## 📚 Documentation

- Frontend: See `frontend/README.md`
- Backend: See `backend/README.md`
- API Docs: Available at `/swagger-ui.html` when backend is running

## 👥 Demo Users

After deployment, the following demo users will be available (password: `password`):

- `applicant@demo.com` - Applicant role
- `sidbi-maker@demo.com` - SIDBI Maker
- `sidbi-checker@demo.com` - SIDBI Checker
- `sidbi-convenor@demo.com` - SIDBI Convenor
- `sidbi-committee@demo.com` - Committee Member
- `sidbi-approving@demo.com` - Approving Authority
- `admin@demo.com` - Admin role

## 🛠️ Local Development

See individual README files in `frontend/` and `backend/` directories for local setup instructions.
