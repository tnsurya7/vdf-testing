# Demo Accounts

All demo accounts use the password: `password`

## 📋 Available Demo Accounts

### Applicant
- **Email**: `applicant@demo.com`
- **Password**: `password`
- **Role**: Applicant
- **Description**: Can register, submit applications, view own applications

### Admin
- **Email**: `admin@demo.com`
- **Password**: `password`
- **Role**: Admin
- **Description**: Full system access, manage users and registrations

### SIDBI Maker
- **Email**: `sidbi-maker@demo.com`
- **Password**: `password`
- **Role**: Maker
- **Description**: Create and submit applications for review

### SIDBI Checker
- **Email**: `sidbi-checker@demo.com`
- **Password**: `password`
- **Role**: Checker
- **Description**: Review and approve/reject applications from makers

### SIDBI Convenor
- **Email**: `sidbi-convenor@demo.com`
- **Password**: `password`
- **Role**: Convenor
- **Description**: Convene committee meetings, manage meeting workflow

### SIDBI ICVD Committee Member
- **Email**: `sidbi-icvd@demo.com`
- **Password**: `password`
- **Role**: ICVD Committee Member
- **Description**: Vote on applications in ICVD committee meetings

### SIDBI CCIC Committee Member
- **Email**: `sidbi-ccic@demo.com`
- **Password**: `password`
- **Role**: CCIC Committee Member
- **Description**: Vote on applications in CCIC committee meetings

---

## 🧪 Testing Locally with Neon DB

### Step 1: Setup Environment
```bash
cd vdf-testing/backend
cp .env.local .env
```

### Step 2: Update Email (Optional)
Edit `.env` and add your Gmail credentials if you want to test email:
```
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-gmail-app-password
```

### Step 3: Run Backend
```bash
mvn spring-boot:run
```

The backend will:
1. Connect to Neon DB
2. Run Flyway migrations (create tables)
3. Seed demo users automatically
4. Start on http://localhost:8080

### Step 4: Verify Users
Check Swagger UI: http://localhost:8080/swagger-ui.html

Test login:
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@demo.com","password":"password"}'
```

---

## 🚀 Testing on Production (Render)

Once deployed on Render, the same demo accounts will be available:

**Frontend**: https://sidbi-venture.vercel.app
**Backend**: https://your-backend.onrender.com

Login with any of the demo accounts above.

---

## 🔐 Password Hash

All accounts use BCrypt hash for password "password":
```
$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
```

This is generated with BCrypt rounds=10 and is secure for demo purposes.

---

## 📊 Database Schema

Users are stored in the `vdf_user_account` table:

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| email | VARCHAR | Unique email (login) |
| password_hash | VARCHAR | BCrypt hashed password |
| user_type | VARCHAR | applicant, sidbi, admin |
| sidbi_role | VARCHAR | maker, checker, convenor, etc. |
| enabled | BOOLEAN | Account active status |
| password_set | BOOLEAN | Password has been set |

---

## 🔄 Resetting Demo Data

If you need to reset the demo accounts:

### Option 1: Delete and Re-run Migrations
```sql
-- Connect to Neon DB
DELETE FROM vdf_user_account WHERE email LIKE '%@demo.com';
```

Then restart the backend - Flyway will re-seed the users.

### Option 2: Manual Insert
```sql
INSERT INTO vdf_user_account (id, email, password_hash, user_type, sidbi_role, enabled, password_set)
VALUES
    (gen_random_uuid(), 'test@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'applicant', NULL, true, true);
```

---

## ✅ Verification Checklist

After deployment, verify each account:

- [ ] applicant@demo.com - Can login and see applicant dashboard
- [ ] admin@demo.com - Can access admin panel
- [ ] sidbi-maker@demo.com - Can access SIDBI maker dashboard
- [ ] sidbi-checker@demo.com - Can access SIDBI checker dashboard
- [ ] sidbi-convenor@demo.com - Can create meetings
- [ ] sidbi-icvd@demo.com - Can vote in ICVD meetings
- [ ] sidbi-ccic@demo.com - Can vote in CCIC meetings

All should login with password: `password`
