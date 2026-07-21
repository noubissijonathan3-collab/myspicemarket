const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  host: "smtp-mail.outlook.com",
  port: 587,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER || "",
    pass: process.env.EMAIL_PASS || "",
  },
});

async function sendOTPEmail(toEmail, otp) {
  if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
    console.log("EMAIL_USER/EMAIL_PASS not set — skipping real email send");
    console.log(`OTP for ${toEmail}: ${otp}`);
    return true;
  }

  const mailOptions = {
    from: `"My SpiceMarket" <${process.env.EMAIL_USER}>`,
    to: toEmail,
    subject: "Your Password Reset Code — My SpiceMarket",
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto;">
        <div style="background: #006E2F; padding: 24px; text-align: center;">
          <h1 style="color: #fff; margin: 0; font-size: 24px;">My SpiceMarket</h1>
        </div>
        <div style="padding: 32px 24px; background: #f9f9f9;">
          <p style="font-size: 16px; color: #333;">Hello,</p>
          <p style="font-size: 16px; color: #333;">
            We received a request to reset your password. Use the verification code below:
          </p>
          <div style="text-align: center; margin: 24px 0;">
            <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #006E2F;">
              ${otp}
            </span>
          </div>
          <p style="font-size: 14px; color: #666;">
            This code expires in <strong>10 minutes</strong>.
          </p>
          <p style="font-size: 14px; color: #666;">
            If you didn't request this, please ignore this email.
          </p>
        </div>
        <div style="padding: 16px; text-align: center; color: #999; font-size: 12px;">
          &copy; ${new Date().getFullYear()} My SpiceMarket
        </div>
      </div>
    `,
  };

  await transporter.sendMail(mailOptions);
  return true;
}

module.exports = { sendOTPEmail };
