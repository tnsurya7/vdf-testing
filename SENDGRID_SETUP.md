# SendGrid Email Setup

The VDF backend now uses SendGrid API for sending emails instead of SMTP.

## Setup Instructions

### 1. Create SendGrid Account
1. Go to https://sendgrid.com/
2. Sign up for a free account (100 emails/day free tier)
3. Verify your email address

### 2. Create API Key
1. Log in to SendGrid dashboard
2. Go to Settings → API Keys
3. Click "Create API Key"
4. Name: `VDF Production`
5. Permissions: Select "Full Access" or "Mail Send" only
6. Click "Create & View"
7. **Copy the API key immediately** (you won't be able to see it again)

### 3. Verify Sender Identity
1. Go to Settings → Sender Authentication
2. Choose "Single Sender Verification" (for free tier)
3. Add sender email: `noreply@sidbi.in` (or your domain)
4. Fill in the form and verify the email
5. Alternatively, verify your entire domain if you own it

### 4. Configure Render Environment Variables

Add these environment variables in Render:

```
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@sidbi.in
SENDGRID_FROM_NAME=SIDBI VDF Portal
```

**Important**: 
- The `SENDGRID_FROM_EMAIL` must match the verified sender email in SendGrid
- You can now remove the old `MAIL_USERNAME` and `MAIL_PASSWORD` variables

### 5. Local Development

For local testing, add to your `.env` file:

```
SENDGRID_API_KEY=SG.your_api_key_here
SENDGRID_FROM_EMAIL=noreply@sidbi.in
SENDGRID_FROM_NAME=SIDBI VDF Portal
```

## Testing

After deployment, test the email functionality:

1. Go to the login page
2. Click "Forgot Password"
3. Enter a test email
4. Check the email inbox (or SendGrid dashboard → Activity)

## Troubleshooting

### Email not received
- Check SendGrid Activity dashboard for delivery status
- Verify the sender email is verified in SendGrid
- Check spam folder
- Ensure API key has "Mail Send" permission

### API Key Invalid
- Regenerate the API key in SendGrid
- Update the `SENDGRID_API_KEY` in Render
- Redeploy the service

### Rate Limits
- Free tier: 100 emails/day
- If you need more, upgrade your SendGrid plan

## Benefits over SMTP

✅ No Gmail security issues
✅ Better deliverability
✅ Email tracking and analytics
✅ No port/firewall issues
✅ Faster sending
✅ Professional sender reputation
