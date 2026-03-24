package com.sidbi.vdf.service;

import com.sendgrid.Method;
import com.sendgrid.Request;
import com.sendgrid.Response;
import com.sendgrid.SendGrid;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import com.sendgrid.helpers.mail.objects.Email;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
@Slf4j
public class EmailService {

    private final SendGrid sendGrid;

    @Value("${vdf.app.base-url:http://localhost:5173}")
    private String baseUrl;

    @Value("${sendgrid.from-email:noreply@sidbi.in}")
    private String fromEmail;

    @Value("${sendgrid.from-name:SIDBI VDF Portal}")
    private String fromName;

    public EmailService(@Value("${sendgrid.api-key:}") String apiKey) {
        this.sendGrid = new SendGrid(apiKey);
    }

    public void sendPasswordSetupEmail(String toEmail, String name, String token) {
        String link = baseUrl + "/#/set-password/" + token;
        String subject = "Set Your Password - Venture Debt Fund Portal";
        String html = buildSetupEmailHtml(name, link);
        try {
            sendHtmlEmail(toEmail, subject, html);
            log.info("Password setup email sent to: {}", toEmail);
        } catch (Exception e) {
            log.warn("Could not send password setup email to {}: {}", toEmail, e.getMessage());
            log.info("Password setup link for {}: {}", toEmail, link);
        }
    }

    public void sendPasswordResetEmail(String toEmail, String name, String token) {
        String link = baseUrl + "/#/set-password/" + token;
        String subject = "Reset Your Password - Venture Debt Fund Portal";
        String html = buildResetEmailHtml(name, link);
        try {
            sendHtmlEmail(toEmail, subject, html);
            log.info("Password reset email sent to: {}", toEmail);
        } catch (Exception e) {
            log.warn("Could not send password reset email to {}: {}", toEmail, e.getMessage());
            log.info("Password reset link for {}: {}", toEmail, link);
        }
    }

    private void sendHtmlEmail(String to, String subject, String htmlContent) throws IOException {
        Email from = new Email(fromEmail, fromName);
        Email toEmail = new Email(to);
        Content content = new Content("text/html", htmlContent);
        Mail mail = new Mail(from, subject, toEmail, content);

        Request request = new Request();
        try {
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            Response response = sendGrid.api(request);
            
            if (response.getStatusCode() >= 400) {
                throw new IOException("SendGrid API error: " + response.getStatusCode() + " - " + response.getBody());
            }
        } catch (IOException ex) {
            throw ex;
        }
    }

    private String buildSetupEmailHtml(String name, String link) {
        return emailTemplate(
            "Welcome to SIDBI Venture Debt Fund Portal",
            "Dear " + name + ",",
            "Your account has been created on the <strong>SIDBI Venture Debt Fund Portal</strong>. Please set your password using the button below to activate your account.",
            "Set Your Password",
            link,
            "This link will expire in <strong>15 minutes</strong>. If you did not request this, please ignore this email."
        );
    }

    private String buildResetEmailHtml(String name, String link) {
        return emailTemplate(
            "Reset Your Password — SIDBI VDF Portal",
            "Dear " + name + ",",
            "We received a request to reset your password for the <strong>SIDBI Venture Debt Fund Portal</strong>. Click the button below to set a new password.",
            "Reset Password",
            link,
            "This link will expire in <strong>15 minutes</strong>. If you did not request a password reset, please ignore this email."
        );
    }

    private String emailTemplate(String title, String greeting, String body, String btnText, String btnLink, String footer) {
        return """
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta charset="UTF-8"/>
              <meta name="viewport" content="width=device-width,initial-scale=1"/>
              <title>%s</title>
            </head>
            <body style="margin:0;padding:0;background:#f4f4f4;font-family:Arial,sans-serif;">
              <table width="100%%" cellpadding="0" cellspacing="0" style="background:#f4f4f4;padding:40px 0;">
                <tr><td align="center">
                  <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border:1px solid #e0e0e0;">

                    <!-- Header -->
                    <tr>
                      <td style="background:#1a3a6b;padding:24px 32px;">
                        <table width="100%%" cellpadding="0" cellspacing="0">
                          <tr>
                            <td>
                              <p style="margin:0;color:#ffffff;font-size:20px;font-weight:bold;letter-spacing:1px;">SIDBI</p>
                              <p style="margin:4px 0 0;color:#a8c4e8;font-size:12px;letter-spacing:0.5px;">SMALL INDUSTRIES DEVELOPMENT BANK OF INDIA</p>
                            </td>
                            <td align="right">
                              <p style="margin:0;color:#a8c4e8;font-size:11px;">Venture Debt Fund Portal</p>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>

                    <!-- Blue accent bar -->
                    <tr><td style="background:#f0a500;height:4px;"></td></tr>

                    <!-- Body -->
                    <tr>
                      <td style="padding:40px 32px;">
                        <p style="margin:0 0 8px;font-size:22px;font-weight:bold;color:#1a3a6b;">%s</p>
                        <p style="margin:0 0 20px;font-size:14px;color:#555555;">%s</p>

                        <!-- CTA Button -->
                        <table cellpadding="0" cellspacing="0" style="margin:28px 0;">
                          <tr>
                            <td style="background:#1a3a6b;border-radius:2px;">
                              <a href="%s" style="display:inline-block;padding:14px 32px;color:#ffffff;font-size:14px;font-weight:bold;text-decoration:none;letter-spacing:0.5px;">%s</a>
                            </td>
                          </tr>
                        </table>

                        <p style="margin:0;font-size:12px;color:#999999;">%s</p>
                      </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                      <td style="background:#f8f8f8;padding:20px 32px;border-top:1px solid #e0e0e0;">
                        <p style="margin:0;font-size:11px;color:#aaaaaa;text-align:center;">
                          SIDBI Tower, 15 Ashok Marg, Lucknow - 226001 &nbsp;|&nbsp; 0522-2288546<br/>
                          &copy; 2026 Small Industries Development Bank of India. All Rights Reserved.
                        </p>
                      </td>
                    </tr>

                  </table>
                </td></tr>
              </table>
            </body>
            </html>
            """.formatted(title, greeting, body, btnLink, btnText, footer);
    }
}