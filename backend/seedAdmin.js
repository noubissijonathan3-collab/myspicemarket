const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
require("dotenv").config({ path: require("path").resolve(__dirname, ".env") });

const User = require("./models/User");

const ADMIN_DATA = {
  fullName: "Super Admin",
  email: "admin@gmail.com",
  phone: "",
  password: "101010",
  role: "admin",
  isVerified: true,
};

async function seed() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("Connected to MongoDB");

    const existing = await User.findOne({ email: ADMIN_DATA.email });
    if (existing) {
      existing.role = "admin";
      existing.password = await bcrypt.hash(ADMIN_DATA.password, 10);
      existing.fullName = ADMIN_DATA.fullName;
      await existing.save();
      console.log(`Admin updated: ${ADMIN_DATA.email}`);
    } else {
      const hashedPassword = await bcrypt.hash(ADMIN_DATA.password, 10);
      await User.create({ ...ADMIN_DATA, password: hashedPassword });
      console.log(`Admin created: ${ADMIN_DATA.email}`);
    }

    console.log("Email:    admin@gmail.com");
    console.log("Password: 101010");
    console.log("Role:     admin");

    process.exit(0);
  } catch (error) {
    console.error("Seed failed:", error.message);
    process.exit(1);
  }
}

seed();
