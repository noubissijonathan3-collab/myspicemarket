const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const path = require("path");
const http = require("http");
const { Server } = require("socket.io");

require("dotenv").config();

const authRoutes = require("./routes/auth");
const categoryRoutes = require("./routes/categories");
const mealRoutes = require("./routes/meals");
const foodstuffRoutes = require("./routes/foodstuffs");
const bannerRoutes = require("./routes/banners");
const favoriteRoutes = require("./routes/favorites");
const cartRoutes = require("./routes/cart");
const notificationRoutes = require("./routes/notifications");
const orderRoutes = require("./routes/orders");
const addressRoutes = require("./routes/address");
const recommendationRoutes = require("./routes/recommendation");
const recentlyViewedRoutes = require("./routes/recentlyViewed");
const locationRoutes = require("./routes/location");
const benefitRoutes = require("./routes/benefits");
const reviewRoutes = require("./routes/reviews");
const ratingRoutes = require("./routes/ratings");
const chatRoutes = require("./routes/chat");
const aiChatRoutes = require("./ai/routes/aiRoutes");
const aiMealRoutes = require("./ai/routes/mealRoutes");
const aiNutritionRoutes = require("./ai/routes/nutritionRoutes");
const aiShoppingRoutes = require("./ai/routes/shoppingRoutes");
const aiVoiceRoutes = require("./ai/routes/voiceRoutes");
const aiTranslationRoutes = require("./ai/routes/translationRoutes");
const settingsRoutes = require("./routes/settings");
const languageRoutes = require("./routes/languages");
const adminRoutes = require("./routes/admin");
const agentRoutes = require("./routes/agent");
const deliveryTrackingRoutes = require("./routes/deliveryTracking");
const { initializeFirebase, sendPushNotification } = require("./utils/push");
const { setSocketIO, setPushSender } = require("./utils/notify");
const fcmRoutes = require("./routes/fcm");
const fcmTokenRoutes = require("./routes/fcm");
const setupSocket = require("./socketHandler");
const setupAiSocket = require("./ai/socket/aiSocketHandler");

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*", methods: ["GET", "POST"] },
});
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json({ limit: "10mb" }));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.get("/", (req, res) => {
  res.send("My SpiceMarket API is running");
});

app.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    server: "Running",
    database: mongoose.connection.readyState === 1 ? "Connected" : "Disconnected",
    timestamp: new Date(),
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/meals", mealRoutes);
app.use("/api/foodstuffs", foodstuffRoutes);
app.use("/api/banners", bannerRoutes);
app.use("/api/favorites", favoriteRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/address", addressRoutes);
app.use("/api/recommendations", recommendationRoutes);
app.use("/api/recently-viewed", recentlyViewedRoutes);
app.use("/api/location", locationRoutes);
app.use("/api/benefits", benefitRoutes);
app.use("/api/reviews", reviewRoutes);
app.use("/api/ratings", ratingRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/ai", aiChatRoutes);
app.use("/api/ai/meals", aiMealRoutes);
app.use("/api/ai/nutrition", aiNutritionRoutes);
app.use("/api/ai/shopping", aiShoppingRoutes);
app.use("/api/ai/voice", aiVoiceRoutes);
app.use("/api/ai/translate", aiTranslationRoutes);
app.use("/api/settings", settingsRoutes);
app.use("/api/languages", languageRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/agent", agentRoutes);
app.use("/api/tracking", deliveryTrackingRoutes);
app.use("/api/fcm", fcmTokenRoutes);

setupSocket(io);
setupAiSocket(io);

setSocketIO(io);
setPushSender(sendPushNotification);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Endpoint not found",
  });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || "Internal Server Error",
  });
});

if (!process.env.MONGO_URI) {
  console.error("ERROR: MONGO_URI is missing in backend/.env");
  process.exit(1);
} else {
  mongoose
    .connect(process.env.MONGO_URI)
    .then(() => {
      console.log("MongoDB Connected");
      initializeFirebase();
      server.listen(PORT, "0.0.0.0", () => {
        console.log(`Server running on port ${PORT}`);
      });
    })
    .catch((err) => {
      console.error("MongoDB Connection Error:", err);
      process.exit(1);
    });
}
