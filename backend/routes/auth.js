const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const User = require("../models/User");
const { protect: authMiddleware, admin } = require("../middleware/auth");
const { profileUpload } = require("../middleware/upload");
const { generateOTP } = require("../utils/otpGenerator");
const { sendOTPEmail } = require("../utils/emailService");
const { sendOTPSMS } = require("../utils/smsService");

const router = express.Router();

// =======================================
// REGISTER
// =======================================
router.post("/register", async (req, res) => {
  try {
    const { fullName, email, phone, password } = req.body;

    if (!fullName || !email || !password) {
      return res.status(400).json({
        message: "Full name, email, and password are required",
      });
    }

    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({
        message: "User already exists",
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = new User({
      fullName,
      email,
      phone,
      password: hashedPassword,
    });

    await user.save();

    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || "myspicemarket_secret_key",
      { expiresIn: "7d" },
    );

    res.status(201).json({
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        profileImage: user.profileImage,
        address: user.address,
        role: user.role,
        isVerified: user.isVerified,
      },
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
});

// =======================================
// LOGIN
// =======================================
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({
      email,
    });

    if (!user) {
      return res.status(400).json({
        message: "Invalid email or password",
      });
    }

    const isMatch = await bcrypt.compare(
      password,
      user.password,
    );

    if (!isMatch) {
      return res.status(400).json({
        message: "Invalid email or password",
      });
    }

    const token = jwt.sign(
      {
        userId: user._id,
      },
      process.env.JWT_SECRET || "myspicemarket_secret_key",
      {
        expiresIn: "7d",
      },
    );

    res.json({
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        profileImage: user.profileImage,
        address: user.address,
        role: user.role,
        isVerified: user.isVerified,
      },
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
});

function maskEmail(email) {
  const [local, domain] = email.split("@");
  if (local.length <= 2) return `${local[0]}****@${domain}`;
  return `${local[0]}${local[1]}****${local[local.length - 1]}@${domain}`;
}

function maskPhone(phone) {
  const digits = phone.replace(/\D/g, "");
  if (digits.length < 6) return `****${digits.slice(-4)}`;
  return `${digits.slice(0, 3)}****${digits.slice(-4)}`;
}

// =======================================
// FIND ACCOUNT (step 1)
// =======================================
router.post("/find-account", async (req, res) => {
  try {
    const { identifier } = req.body;

    if (!identifier) {
      return res.status(400).json({ message: "Email or phone number is required." });
    }

    const user = await User.findOne({
      $or: [{ email: identifier }, { phone: identifier }],
    });

    if (!user) {
      return res.status(404).json({ message: "No account was found with this email or phone number." });
    }

    res.json({
      success: true,
      email: user.email ? maskEmail(user.email) : null,
      phone: user.phone ? maskPhone(user.phone) : null,
    });
  } catch (error) {
    res.status(500).json({ message: "Unable to connect. Please check your internet connection and try again." });
  }
});

// =======================================
// FORGOT PASSWORD (step 2 – send OTP)
// =======================================
router.post("/forgot-password", async (req, res) => {
  try {
    const { identifier, method } = req.body;

    if (!identifier) {
      return res.status(400).json({ message: "Email or phone number is required." });
    }

    if (!method || !["email", "sms"].includes(method)) {
      return res.status(400).json({ message: "A valid verification method (email or sms) is required." });
    }

    const user = await User.findOne({
      $or: [{ email: identifier }, { phone: identifier }],
    });

    if (!user) {
      return res.status(404).json({ message: "No account was found with this email or phone number." });
    }

    const otp = generateOTP();
    const expiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    user.resetOTP = otp;
    user.resetOTPExpiry = expiry;
    user.resetVerified = false;
    await user.save();

    if (method === "email") {
      await sendOTPEmail(user.email, otp);
    } else {
      await sendOTPSMS(user.phone, otp);
    }

    res.json({ success: true, message: "Verification code sent successfully." });
  } catch (error) {
    res.status(500).json({ message: "Unable to connect. Please check your internet connection and try again." });
  }
});

// =======================================
// VERIFY OTP
// =======================================
router.post("/verify-otp", async (req, res) => {
  try {
    const { identifier, otp } = req.body;

    if (!identifier || !otp) {
      return res.status(400).json({ message: "Identifier and OTP are required" });
    }

    const user = await User.findOne({
      $or: [{ email: identifier }, { phone: identifier }],
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (!user.resetOTP || user.resetOTP !== otp) {
      return res.status(400).json({ message: "Invalid verification code" });
    }

    if (!user.resetOTPExpiry || new Date() > user.resetOTPExpiry) {
      return res.status(400).json({ message: "Verification code has expired" });
    }

    user.resetVerified = true;
    user.resetOTP = null;
    user.resetOTPExpiry = null;
    await user.save();

    res.json({ success: true, message: "OTP verified successfully." });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// =======================================
// RESET PASSWORD
// =======================================
router.post("/reset-password", async (req, res) => {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({ message: "Identifier and new password are required" });
    }

    if (password.length < 6) {
      return res.status(400).json({ message: "Password must be at least 6 characters" });
    }

    const user = await User.findOne({
      $or: [{ email: identifier }, { phone: identifier }],
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (!user.resetVerified) {
      return res.status(400).json({ message: "OTP verification required before resetting password" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    user.password = hashedPassword;
    user.resetVerified = false;
    await user.save();

    res.json({ success: true, message: "Password reset successfully." });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// =======================================
// GET LOGGED-IN USER
// =======================================
router.get("/me", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(
      req.user._id,
    ).select("-password");

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
});
router.get("/profile", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(
      req.user._id,
    ).select("-password");

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
});

// =======================================
// UPDATE PROFILE
// =======================================
const fs = require("fs");
const path = require("path");

const saveBase64Image = (base64) => {
  const matches = base64.match(/^data:image\/(\w+);base64,(.+)$/);
  const ext = matches ? matches[1] : "jpg";
  const data = matches ? matches[2] : base64;
  const buffer = Buffer.from(data, "base64");
  const filename = `${Date.now()}-${Math.round(Math.random() * 1E9)}.${ext}`;
  const dir = path.join(__dirname, "../uploads/profiles");
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, filename), buffer);
  return `/uploads/profiles/${filename}`;
};

const updateProfile = async (req, res) => {
  try {
    const updates = {};
    const allowed = ["fullName", "phone", "address"];
    for (const field of allowed) {
      if (req.body[field] != null && req.body[field] !== "") updates[field] = req.body[field];
    }
    if (req.file) {
      updates.profileImage = "/uploads/profiles/" + req.file.filename;
    } else if (req.body.avatar && req.body.avatar.length > 100) {
      updates.profileImage = saveBase64Image(req.body.avatar);
    }
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $set: updates },
      { returnDocument: 'after', runValidators: true }
    ).select("-password");

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

router.put("/me", authMiddleware, profileUpload.single("profileImage"), updateProfile);
router.put("/profile", authMiddleware, profileUpload.single("profileImage"), updateProfile);

// =======================================
// DEBUG: Get current OTP (dev only)
// =======================================
router.get("/debug-otp", async (req, res) => {
  try {
    const latest = await User.findOne({ resetOTP: { $ne: null } }).sort({ updatedAt: -1 });
    if (latest && latest.resetOTP) {
      return res.json({ otp: latest.resetOTP });
    }
    res.json({ otp: null });
  } catch (_) {
    res.json({ otp: null });
  }
});

// =======================================
// ADMIN LOGIN
// =======================================
router.post("/admin/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Invalid email or password" });
    }
    if (user.role !== "admin") {
      return res.status(403).json({ message: "Admin access required" });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid email or password" });
    }
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || "myspicemarket_secret_key",
      { expiresIn: "7d" }
    );
    res.json({
      success: true,
      token,
      admin: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/admin/profile", authMiddleware, admin, async (req, res) => {
  res.json({ admin: req.user });
});

module.exports = router;
