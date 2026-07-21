const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
require("dotenv").config({ path: require("path").resolve(__dirname, ".env") });

const User = require("./models/User");

const AGENTS_DATA = [
  {
    fullName: "Chef Koffi",
    email: "prep@spicemarket.com",
    phone: "+237677123456",
    password: "password123",
    role: "preparationAgent",
    isVerified: true,
  },
  {
    fullName: "Rider Amadou",
    email: "rider@spicemarket.com",
    phone: "+237699987654",
    password: "password123",
    role: "deliveryAgent",
    isVerified: true,
  }
];

async function seed() {
  try {
    if (!process.env.MONGO_URI) {
      throw new Error("MONGO_URI not specified in backend/.env");
    }
    
    await mongoose.connect(process.env.MONGO_URI);
    console.log("Connected to MongoDB for agent seeding...");

    for (const agent of AGENTS_DATA) {
      const existing = await User.findOne({ email: agent.email });
      const hashedPassword = await bcrypt.hash(agent.password, 10);
      
      if (existing) {
        existing.fullName = agent.fullName;
        existing.phone = agent.phone;
        existing.role = agent.role;
        existing.password = hashedPassword;
        await existing.save();
        console.log(`Agent updated: ${agent.email} (${agent.fullName})`);
      } else {
        await User.create({
          fullName: agent.fullName,
          email: agent.email,
          phone: agent.phone,
          password: hashedPassword,
          role: agent.role,
          isVerified: agent.isVerified,
        });
        console.log(`Agent created: ${agent.email} (${agent.fullName})`);
      }
    }

    console.log("\nAgent accounts seeded successfully!");
    console.log("-----------------------------------");
    console.log("Prep Agent:     prep@spicemarket.com / password123");
    console.log("Delivery Agent: rider@spicemarket.com / password123");
    
    process.exit(0);
  } catch (error) {
    console.error("Seed failed:", error.message);
    process.exit(1);
  }
}

seed();
