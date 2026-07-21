async function sendOTPSMS(toPhone, otp) {
  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const authToken = process.env.TWILIO_AUTH_TOKEN;
  const fromNumber = process.env.TWILIO_PHONE_NUMBER;

  if (!accountSid || !authToken || !fromNumber) {
    console.log("TWILIO env vars not set — skipping real SMS send");
    console.log(`OTP for ${toPhone}: ${otp}`);
    return true;
  }

  try {
    const twilio = require("twilio");
    const client = twilio(accountSid, authToken);
    await client.messages.create({
      body: `Your My SpiceMarket verification code is: ${otp}. It expires in 10 minutes.`,
      from: fromNumber,
      to: toPhone,
    });
    return true;
  } catch (error) {
    console.error("SMS send error:", error.message);
    throw new Error("Failed to send SMS. Please try again.");
  }
}

module.exports = { sendOTPSMS };
