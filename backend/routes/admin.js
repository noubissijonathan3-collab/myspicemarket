const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const User = require("../models/User");
const Meal = require("../models/Meal");
const Category = require("../models/Category");
const Order = require("../models/Order");
const Product = require("../models/Product");
const Review = require("../models/Review");
const Banner = require("../models/Banner");
const Rider = require("../models/Rider");
const Promotion = require("../models/Promotion");
const Setting = require("../models/Setting");
const Favorite = require("../models/Favorite");
const Notification = require("../models/Notification");
const MealIngredient = require("../models/MealIngredient");
const { protect, admin } = require("../middleware/auth");

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, "../uploads/products");
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${path.extname(file.originalname)}`);
  },
});
const upload = multer({ storage });

router.use(protect, admin);

// ==================== DASHBOARD ====================

router.get("/dashboard", async (req, res) => {
  try {
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const totalProducts = await Meal.countDocuments();
    const totalOrders = await Order.countDocuments();
    const totalCustomers = await User.countDocuments({ role: "customer" });

    const revenueAgg = await Order.aggregate([
      { $match: { status: "Delivered" } },
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);
    const totalRevenue = revenueAgg.length > 0 ? revenueAgg[0].total : 0;

    const revenueTodayAgg = await Order.aggregate([
      { $match: { status: "Delivered", createdAt: { $gte: startOfDay } } },
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);
    const revenueToday = revenueTodayAgg.length > 0 ? revenueTodayAgg[0].total : 0;

    const revenueMonthAgg = await Order.aggregate([
      { $match: { status: "Delivered", createdAt: { $gte: startOfMonth } } },
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);
    const revenueThisMonth = revenueMonthAgg.length > 0 ? revenueMonthAgg[0].total : 0;

    const pendingOrders = await Order.countDocuments({ status: "Pending" });
    const activeDeliveries = await Order.countDocuments({ status: "Out for Delivery" });
    const newCustomersToday = await User.countDocuments({ role: "customer", createdAt: { $gte: startOfDay } });

    const activeRidersFromRider = await Rider.countDocuments({ isAvailable: true });
    const totalRidersFromRider = await Rider.countDocuments();
    const totalRidersFromUser = await User.countDocuments({ role: "deliveryAgent" });
    const activeRiders = activeRidersFromRider + Math.max(0, totalRidersFromUser - totalRidersFromRider);
    const totalRiders = Math.max(totalRidersFromRider, totalRidersFromUser);

    const ratingAgg = await Review.aggregate([
      { $group: { _id: null, avg: { $avg: "$rating" } } },
    ]);
    const avgRating = ratingAgg.length > 0 ? Math.round(ratingAgg[0].avg * 10) / 10 : 0;

    const categoryDistribution = await Order.aggregate([
      { $match: { status: "Delivered" } },
      { $lookup: { from: "orderitems", localField: "_id", foreignField: "orderId", as: "items" } },
      { $unwind: "$items" },
      { $lookup: { from: "meals", localField: "items.mealId", foreignField: "_id", as: "meal" } },
      { $unwind: { path: "$meal", preserveNullAndEmptyArrays: true } },
      { $lookup: { from: "categories", localField: "meal.categoryId", foreignField: "_id", as: "cat" } },
      { $unwind: { path: "$cat", preserveNullAndEmptyArrays: true } },
      { $group: { _id: "$cat.name", count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 6 },
    ]);

    const topMeals = await Order.aggregate([
      { $match: { status: "Delivered" } },
      { $lookup: { from: "orderitems", localField: "_id", foreignField: "orderId", as: "items" } },
      { $unwind: "$items" },
      { $group: { _id: "$items.mealId", totalSold: { $sum: "$items.quantity" } } },
      { $sort: { totalSold: -1 } },
      { $limit: 5 },
      { $lookup: { from: "meals", localField: "_id", foreignField: "_id", as: "meal" } },
      { $unwind: "$meal" },
      { $project: { name: "$meal.name", image: "$meal.image", totalSold: 1 } },
    ]);

    const monthlyRevenue = await Order.aggregate([
      {
        $match: {
          status: "Delivered",
          createdAt: { $gte: new Date(now.getFullYear(), 0, 1) },
        },
      },
      { $group: { _id: { $month: "$createdAt" }, revenue: { $sum: "$total" } } },
      { $sort: { _id: 1 } },
    ]);

    const recentOrders = await Order.find()
      .populate("userId", "fullName")
      .sort({ createdAt: -1 })
      .limit(8);

    const lowStock = await Product.find({ stock: { $lt: 10 } }).sort({ stock: 1 });

    const recentReviews = await Review.find()
      .populate("userId", "fullName")
      .populate("mealId", "name")
      .sort({ createdAt: -1 })
      .limit(5);

    const recentCustomers = await User.find({ role: "customer" })
      .select("-password")
      .sort({ createdAt: -1 })
      .limit(5);

    const alerts = [];
    if (pendingOrders > 5) alerts.push({ type: "warning", icon: "bi-clock-history", title: "High Pending Orders", message: `${pendingOrders} orders are awaiting confirmation.` });
    if (lowStock.length > 0) alerts.push({ type: "danger", icon: "bi-exclamation-triangle", title: "Low Inventory", message: `${lowStock.length} product(s) are running low on stock.` });
    if (activeDeliveries > 0) alerts.push({ type: "info", icon: "bi-truck", title: "Active Deliveries", message: `${activeDeliveries} order(s) are currently out for delivery.` });

    res.json({
      totalProducts,
      totalOrders,
      totalCustomers,
      totalRevenue,
      revenueToday,
      revenueThisMonth,
      pendingOrders,
      activeDeliveries,
      newCustomersToday,
      activeRiders,
      totalRiders,
      avgRating,
      categoryDistribution,
      topMeals,
      monthlyRevenue,
      recentOrders,
      lowStock,
      recentReviews,
      recentCustomers,
      alerts,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== PRODUCTS ====================

router.get("/products", async (req, res) => {
  try {
    const { search, category } = req.query;
    const query = {};
    if (search) query.name = { $regex: search, $options: "i" };
    if (category) query.categoryId = category;
    const products = await Meal.find(query).populate("categoryId");
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/products/:id", async (req, res) => {
  try {
    const product = await Meal.findById(req.params.id).populate("categoryId");
    if (!product) return res.status(404).json({ message: "Product not found" });
    res.json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/products", upload.single("image"), async (req, res) => {
  try {
    const { name, description, price, category, stock, servings, preparationTime, isAvailable } = req.body;
    const image = req.file ? `/uploads/products/${req.file.filename}` : "";
    const meal = await Meal.create({
      name,
      description,
      categoryId: category,
      image,
      preparationTime: preparationTime || 30,
      servings: servings || 2,
    });
    await Product.create({
      name,
      description,
      type: "meal",
      category,
      price,
      stock: stock || 0,
      image,
      isAvailable: isAvailable !== undefined ? isAvailable : true,
      preparationTime: preparationTime || 30,
      servings: servings || 2,
    });
    res.status(201).json(meal);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/products/:id", upload.single("image"), async (req, res) => {
  try {
    const mealDoc = await Meal.findById(req.params.id);
    if (!mealDoc) return res.status(404).json({ message: "Product not found" });

    const updateData = { ...req.body };
    if (updateData.category) {
      updateData.categoryId = updateData.category;
      delete updateData.category;
    }
    if (req.file) updateData.image = `/uploads/products/${req.file.filename}`;

    const meal = await Meal.findByIdAndUpdate(req.params.id, { $set: updateData }, { returnDocument: "after" });

    const productUpdate = { ...req.body };
    if (req.file) productUpdate.image = `/uploads/products/${req.file.filename}`;
    await Product.findOneAndUpdate(
      { name: mealDoc.name },
      { $set: productUpdate },
    );

    res.json(meal);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/products/:id", async (req, res) => {
  try {
    const meal = await Meal.findByIdAndDelete(req.params.id);
    if (!meal) return res.status(404).json({ message: "Product not found" });
    await Product.findOneAndDelete({ name: meal.name });
    res.json({ message: "Product deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== CATEGORIES ====================

router.get("/categories", async (req, res) => {
  try {
    const categories = await Category.find().sort({ name: 1 });
    const catIds = categories.map((c) => c._id);
    const counts = await Meal.aggregate([
      { $match: { categoryId: { $in: catIds } } },
      { $group: { _id: "$categoryId", count: { $sum: 1 } } },
    ]);
    const countMap = {};
    counts.forEach((c) => (countMap[c._id.toString()] = c.count));
    const result = categories.map((cat) => ({
      ...cat.toObject(),
      productCount: countMap[cat._id.toString()] || 0,
    }));
    res.json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/categories", async (req, res) => {
  try {
    const category = await Category.create(req.body);
    res.status(201).json(category);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/categories/:id", async (req, res) => {
  try {
    const category = await Category.findByIdAndUpdate(req.params.id, { $set: req.body }, { returnDocument: "after" });
    if (!category) return res.status(404).json({ message: "Category not found" });
    res.json(category);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/categories/:id", async (req, res) => {
  try {
    const linked = await Meal.countDocuments({ categoryId: req.params.id });
    if (linked > 0) {
      return res.status(400).json({ message: `Cannot delete category: ${linked} products are linked to it` });
    }
    const category = await Category.findByIdAndDelete(req.params.id);
    if (!category) return res.status(404).json({ message: "Category not found" });
    res.json({ message: "Category deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== ORDERS ====================

router.get("/orders", async (req, res) => {
  try {
    const query = {};
    if (req.query.status) query.status = req.query.status;
    const orders = await Order.find(query)
      .populate("userId", "fullName email phone")
      .populate("deliveryAgent", "fullName email phone")
      .populate("preparationAgent", "fullName phone")
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/orders/:id", async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate("userId", "fullName email phone address")
      .populate("deliveryAgent", "fullName email phone vehicleType");
    if (!order) return res.status(404).json({ message: "Order not found" });
    const OrderItem = require("../models/OrderItem");
    const items = await OrderItem.find({ orderId: order._id }).populate("foodstuffId", "name image unit price");
    res.json({ order, items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/orders/:id/status", async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findByIdAndUpdate(req.params.id, { $set: { status } }, { returnDocument: "after" });
    if (!order) return res.status(404).json({ message: "Order not found" });
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/orders/:id/rider", async (req, res) => {
  try {
    const { riderId } = req.body;

    let agentUserId = null;

    const user = await User.findById(riderId).select("_id role");
    if (user && user.role === "deliveryAgent") {
      agentUserId = user._id;
    } else {
      const rider = await Rider.findById(riderId);
      if (!rider) return res.status(404).json({ message: "Rider not found" });

      const linkedUser = await User.findOne({ email: rider.email, role: "deliveryAgent" }).select("_id");
      if (linkedUser) {
        agentUserId = linkedUser._id;
      } else {
        const newUser = await User.create({
          fullName: rider.fullName,
          email: rider.email,
          phone: rider.phone,
          password: rider.password,
          role: "deliveryAgent",
          isVerified: true,
        });
        agentUserId = newUser._id;
      }
    }

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { $set: { deliveryAgent: agentUserId, deliveryStatus: "assigned" } },
      { returnDocument: "after" }
    );
    if (!order) return res.status(404).json({ message: "Order not found" });
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Assign preparation agent to order
router.put("/orders/:id/prep-agent", async (req, res) => {
  try {
    const { agentId } = req.body;
    const user = await User.findById(agentId).select("_id role");
    if (!user || (user.role !== "preparationAgent" && user.role !== "admin")) {
      return res.status(400).json({ message: "Invalid preparation agent" });
    }

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { $set: { preparationAgent: agentId, status: "Preparing" } },
      { returnDocument: "after" }
    ).populate("userId", "fullName phone email address")
     .populate("preparationAgent", "fullName phone");

    if (!order) return res.status(404).json({ message: "Order not found" });
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get unassigned prep agents
router.get("/prep-agents", async (req, res) => {
  try {
    const agents = await User.find({ role: "preparationAgent" }).select("-password").sort({ fullName: 1 });
    res.json(agents);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== CUSTOMERS ====================

router.get("/customers", async (req, res) => {
  try {
    const query = { role: "customer" };
    if (req.query.search) {
      const re = { $regex: req.query.search, $options: "i" };
      query.$or = [{ fullName: re }, { email: re }];
    }
    const customers = await User.find(query).select("-password").sort({ createdAt: -1 });
    res.json(customers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/customers/:id", async (req, res) => {
  try {
    const customer = await User.findById(req.params.id).select("-password");
    if (!customer) return res.status(404).json({ message: "Customer not found" });
    const orderCount = await Order.countDocuments({ userId: req.params.id });
    res.json({ ...customer.toObject(), orderCount });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/customers/:id/toggle-status", async (req, res) => {
  try {
    const customer = await User.findById(req.params.id);
    if (!customer) return res.status(404).json({ message: "Customer not found" });
    customer.isVerified = !customer.isVerified;
    await customer.save();
    res.json({ isVerified: customer.isVerified });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== RIDERS ====================

router.get("/riders", async (req, res) => {
  try {
    const riders = await Rider.find().select("-password").sort({ createdAt: -1 });

    const enriched = await Promise.all(riders.map(async (rider) => {
      const riderObj = rider.toObject();
      const linkedUser = await User.findOne({ email: rider.email, role: "deliveryAgent" }).select("_id");
      riderObj.userId = linkedUser ? linkedUser._id : null;

      const deliveryCount = linkedUser
        ? await Order.countDocuments({ deliveryAgent: linkedUser._id, status: "Delivered" })
        : 0;
      riderObj.activeDeliveries = linkedUser
        ? await Order.countDocuments({ deliveryAgent: linkedUser._id, status: { $in: ["Out for Delivery", "On Route"] } })
        : 0;
      riderObj.syncedDeliveries = deliveryCount;
      riderObj.source = "rider";
      return riderObj;
    }));

    const riderEmails = riders.map(r => r.email);

    const userOnlyAgents = await User.find({
      role: "deliveryAgent",
      email: { $nin: riderEmails },
    }).select("-password").sort({ createdAt: -1 });

    const userAgents = await Promise.all(userOnlyAgents.map(async (user) => {
      const userObj = user.toObject();
      userObj.userId = user._id;
      userObj.vehicleType = user.vehicleType || "Bike";
      userObj.isAvailable = user.isAvailable !== false;
      userObj.source = "user";

      const deliveryCount = await Order.countDocuments({ deliveryAgent: user._id, status: "Delivered" });
      userObj.activeDeliveries = await Order.countDocuments({
        deliveryAgent: user._id,
        status: { $in: ["Out for Delivery", "On Route"] },
      });
      userObj.syncedDeliveries = deliveryCount;
      return userObj;
    }));

    const allRiders = [...enriched, ...userAgents].sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    res.json(allRiders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/riders/:id", async (req, res) => {
  try {
    const rider = await Rider.findById(req.params.id).select("-password");
    if (!rider) return res.status(404).json({ message: "Rider not found" });
    const riderObj = rider.toObject();
    const linkedUser = await User.findOne({ email: rider.email, role: "deliveryAgent" }).select("_id");
    riderObj.userId = linkedUser ? linkedUser._id : null;
    res.json(riderObj);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/riders", async (req, res) => {
  try {
    const { fullName, email, phone, password, vehicleType } = req.body;
    const existing = await Rider.findOne({ email });
    if (existing) return res.status(400).json({ message: "Rider with this email already exists" });
    const hashedPassword = await bcrypt.hash(password, 10);

    const rider = await Rider.create({ fullName, email, phone, password: hashedPassword, vehicleType });

    const existingUser = await User.findOne({ email });
    if (!existingUser) {
      await User.create({
        fullName,
        email,
        phone,
        password: hashedPassword,
        role: "deliveryAgent",
        isVerified: true,
      });
    } else if (existingUser.role === "customer") {
      existingUser.role = "deliveryAgent";
      await existingUser.save();
    }

    const result = rider.toObject();
    delete result.password;
    res.status(201).json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/riders/:id", async (req, res) => {
  try {
    const { password, ...rest } = req.body;
    const updateData = { ...rest };
    if (password) updateData.password = await bcrypt.hash(password, 10);
    const rider = await Rider.findByIdAndUpdate(req.params.id, { $set: updateData }, { returnDocument: "after" }).select("-password");
    if (!rider) return res.status(404).json({ message: "Rider not found" });

    const userUpdate = {};
    if (rest.fullName) userUpdate.fullName = rest.fullName;
    if (rest.phone) userUpdate.phone = rest.phone;
    if (password) userUpdate.password = updateData.password;
    if (Object.keys(userUpdate).length > 0) {
      await User.findOneAndUpdate({ email: rider.email, role: "deliveryAgent" }, { $set: userUpdate });
    }

    res.json(rider);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/riders/:id", async (req, res) => {
  try {
    const rider = await Rider.findByIdAndDelete(req.params.id);
    if (!rider) return res.status(404).json({ message: "Rider not found" });

    await User.findOneAndDelete({ email: rider.email, role: "deliveryAgent" });
    res.json({ message: "Rider deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/riders-select", async (req, res) => {
  try {
    const users = await User.find({ role: "deliveryAgent" }).select("fullName email phone").sort({ fullName: 1 });
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== REVIEWS ====================

router.get("/reviews", async (req, res) => {
  try {
    const query = {};
    if (req.query.rating) query.rating = Number(req.query.rating);
    const reviews = await Review.find(query)
      .populate("userId", "fullName email")
      .populate("mealId", "name image")
      .sort({ createdAt: -1 });
    res.json(reviews);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/reviews/:id", async (req, res) => {
  try {
    const review = await Review.findByIdAndDelete(req.params.id);
    if (!review) return res.status(404).json({ message: "Review not found" });
    res.json({ message: "Review deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== PROMOTIONS ====================

router.get("/promotions", async (req, res) => {
  try {
    const promotions = await Promotion.find().sort({ createdAt: -1 });
    res.json(promotions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/promotions", async (req, res) => {
  try {
    const promotion = await Promotion.create(req.body);
    res.status(201).json(promotion);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/promotions/:id", async (req, res) => {
  try {
    const promotion = await Promotion.findByIdAndUpdate(req.params.id, { $set: req.body }, { returnDocument: "after" });
    if (!promotion) return res.status(404).json({ message: "Promotion not found" });
    res.json(promotion);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/promotions/:id", async (req, res) => {
  try {
    const promotion = await Promotion.findByIdAndDelete(req.params.id);
    if (!promotion) return res.status(404).json({ message: "Promotion not found" });
    res.json({ message: "Promotion deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== REPORTS ====================

router.get("/reports", async (req, res) => {
  try {
    const deliveredAgg = await Order.aggregate([
      { $match: { status: "Delivered" } },
      { $group: { _id: null, total: { $sum: "$total" }, count: { $sum: 1 } } },
    ]);
    const totalRevenue = deliveredAgg.length > 0 ? deliveredAgg[0].total : 0;
    const totalOrders = deliveredAgg.length > 0 ? deliveredAgg[0].count : 0;
    const avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    const activeCustomers = await Order.distinct("userId", { status: "Delivered" });

    const monthlyRevenue = await Order.aggregate([
      {
        $match: {
          status: "Delivered",
          createdAt: { $gte: new Date(new Date().getFullYear(), 0, 1) },
        },
      },
      { $group: { _id: { $month: "$createdAt" }, revenue: { $sum: "$total" } } },
      { $sort: { _id: 1 } },
    ]);

    const orderStatusDistribution = await Order.aggregate([
      { $group: { _id: "$status", count: { $sum: 1 } } },
    ]);

    res.json({
      totalRevenue,
      totalOrders,
      avgOrderValue: Math.round(avgOrderValue * 100) / 100,
      activeCustomers: activeCustomers.length,
      monthlyRevenue,
      orderStatusDistribution,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== SETTINGS ====================

router.get("/settings", async (req, res) => {
  try {
    const dbSettings = await Setting.findOne();
    res.json(
      dbSettings || {
        appName: "MySpiceMarket",
        currency: "FCFA",
        deliveryFee: 1500,
        taxRate: 0,
        emailNotifications: true,
        orderConfirmation: true,
        newUserRegistration: true,
        maintenanceMode: false,
      }
    );
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/settings", async (req, res) => {
  try {
    const settings = await Setting.findOneAndUpdate({}, { $set: req.body }, { returnDocument: "after", upsert: true });
    res.json(settings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== SEARCH ====================

router.get("/search", async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) return res.json({ meals: [], products: [], customers: [], orders: [] });
    const re = { $regex: q, $options: "i" };

    const meals = await Meal.find({ name: re }).limit(5).populate("categoryId", "name");
    const customers = await User.find({ role: "customer", $or: [{ fullName: re }, { email: re }] }).select("-password").limit(5);
    const orders = await Order.find().populate("userId", "fullName").sort({ createdAt: -1 }).limit(5);

    res.json({ meals, customers, orders });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== ADMINS ====================

router.get("/admins", async (req, res) => {
  try {
    const admins = await User.find({ role: "admin" }).select("-password");
    res.json(admins);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/admins", async (req, res) => {
  try {
    const { fullName, email, password } = req.body;
    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ message: "User with this email already exists" });
    const hashedPassword = await bcrypt.hash(password, 10);
    const adminUser = await User.create({ fullName, email, password: hashedPassword, role: "admin" });
    const result = adminUser.toObject();
    delete result.password;
    res.status(201).json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/admins/:id", async (req, res) => {
  try {
    const { fullName, email, role } = req.body;
    const updateData = {};
    if (fullName) updateData.fullName = fullName;
    if (email) updateData.email = email;
    if (role) updateData.role = role;
    const adminUser = await User.findByIdAndUpdate(req.params.id, { $set: updateData }, { returnDocument: "after" }).select("-password");
    if (!adminUser) return res.status(404).json({ message: "Admin not found" });
    res.json(adminUser);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/admins/:id", async (req, res) => {
  try {
    if (req.params.id === req.user._id.toString()) {
      return res.status(400).json({ message: "Cannot delete your own account" });
    }
    const adminUser = await User.findByIdAndDelete(req.params.id);
    if (!adminUser) return res.status(404).json({ message: "Admin not found" });
    res.json({ message: "Admin deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== MEAL INGREDIENTS ====================

router.get("/meals/:mealId/ingredients", async (req, res) => {
  try {
    const ingredients = await MealIngredient.find({ mealId: req.params.mealId })
      .populate("foodstuffId", "name price unit image stock isAvailable")
      .sort({ displayOrder: 1, createdAt: 1 });
    res.json(ingredients);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/meals/:mealId/ingredients", async (req, res) => {
  try {
    const { foodstuffId, quantity, unit, displayOrder, defaultPrice, isOptional, isModifiable } = req.body;
    if (!foodstuffId || quantity == null) {
      return res.status(400).json({ message: "foodstuffId and quantity are required" });
    }
    const existing = await MealIngredient.findOne({ mealId: req.params.mealId, foodstuffId });
    if (existing) {
      return res.status(400).json({ message: "This ingredient is already assigned to this meal" });
    }
    const ingredient = await MealIngredient.create({
      mealId: req.params.mealId,
      foodstuffId,
      quantity,
      unit: unit || "g",
      displayOrder: displayOrder || 0,
      defaultPrice: defaultPrice != null ? defaultPrice : null,
      isOptional: isOptional || false,
      isModifiable: isModifiable !== undefined ? isModifiable : true,
    });
    const populated = await ingredient.populate("foodstuffId", "name price unit image stock isAvailable");
    res.status(201).json(populated);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/meals/:mealId/ingredients/:id", async (req, res) => {
  try {
    const { quantity, unit, displayOrder, defaultPrice, isOptional, isModifiable } = req.body;
    const updateData = {};
    if (quantity != null) updateData.quantity = quantity;
    if (unit != null) updateData.unit = unit;
    if (displayOrder != null) updateData.displayOrder = displayOrder;
    if (defaultPrice !== undefined) updateData.defaultPrice = defaultPrice;
    if (isOptional != null) updateData.isOptional = isOptional;
    if (isModifiable != null) updateData.isModifiable = isModifiable;

    const ingredient = await MealIngredient.findByIdAndUpdate(
      req.params.id,
      { $set: updateData },
      { returnDocument: "after" }
    ).populate("foodstuffId", "name price unit image stock isAvailable");
    if (!ingredient) return res.status(404).json({ message: "Ingredient not found" });
    res.json(ingredient);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/meals/:mealId/ingredients/:id", async (req, res) => {
  try {
    const ingredient = await MealIngredient.findByIdAndDelete(req.params.id);
    if (!ingredient) return res.status(404).json({ message: "Ingredient not found" });
    res.json({ message: "Ingredient removed from meal" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/meals/:mealId/ingredients-order", async (req, res) => {
  try {
    const { order } = req.body;
    if (!Array.isArray(order)) return res.status(400).json({ message: "order array is required" });
    const ops = order.map((item, idx) => ({
      updateOne: { filter: { _id: item.id }, update: { $set: { displayOrder: idx } } }
    }));
    await MealIngredient.bulkWrite(ops);
    res.json({ message: "Order updated" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== FAVORITES ====================

router.get("/favorites", async (req, res) => {
  try {
    const favorites = await Favorite.find()
      .populate("userId", "fullName email")
      .populate({
        path: "mealId",
        populate: { path: "categoryId", select: "name" },
      })
      .sort({ createdAt: -1 });

    const mealMap = {};
    favorites.forEach((fav) => {
      if (!fav.mealId) return;
      const mealId = fav.mealId._id.toString();
      if (!mealMap[mealId]) {
        mealMap[mealId] = {
          mealId,
          name: fav.mealId.name,
          image: fav.mealId.image || "",
          category: fav.mealId.categoryId ? fav.mealId.categoryId.name : "Uncategorized",
          favorites: 0,
          customers: [],
          lastAdded: fav.createdAt,
        };
      }
      mealMap[mealId].favorites++;
      if (fav.userId) {
        mealMap[mealId].customers.push({ _id: fav.userId._id, fullName: fav.userId.fullName });
      }
      if (fav.createdAt > mealMap[mealId].lastAdded) {
        mealMap[mealId].lastAdded = fav.createdAt;
      }
    });

    const items = Object.values(mealMap).sort((a, b) => b.favorites - a.favorites);
    const totalFavorites = favorites.length;
    const uniqueCustomerIds = new Set(favorites.map((f) => f.userId ? f.userId._id.toString() : null));
    uniqueCustomerIds.delete(null);
    const uniqueCustomers = uniqueCustomerIds.size;
    const avgPerCustomer = uniqueCustomers > 0 ? Math.round((totalFavorites / uniqueCustomers) * 10) / 10 : 0;
    const topItem = items.length > 0 ? items[0] : null;

    res.json({
      totalFavorites,
      uniqueCustomers,
      avgPerCustomer,
      topItem: topItem ? { name: topItem.name, favorites: topItem.favorites } : null,
      items,
      recentFavorites: favorites.slice(0, 20).map((fav) => ({
        _id: fav._id,
        userName: fav.userId ? fav.userId.fullName : "Unknown",
        mealName: fav.mealId ? fav.mealId.name : "Deleted",
        createdAt: fav.createdAt,
      })),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/favorites/:id", async (req, res) => {
  try {
    const fav = await Favorite.findByIdAndDelete(req.params.id);
    if (!fav) return res.status(404).json({ message: "Favorite not found" });
    await Meal.findByIdAndUpdate(fav.mealId, { $inc: { favoritesCount: -1 } });
    res.json({ message: "Favorite removed" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== NOTIFICATIONS ====================

router.get("/notifications", async (req, res) => {
  try {
    const notifications = await Notification.find()
      .populate("userId", "fullName email")
      .sort({ createdAt: -1 })
      .limit(100);
    res.json(notifications);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/notifications", async (req, res) => {
  try {
    const { title, message, type, broadcast, userId, scheduledAt, data } = req.body;
    if (!title || !message) {
      return res.status(400).json({ message: "Title and message are required" });
    }

    const created = [];

    if (broadcast !== false) {
      const users = await User.find({ role: "customer" }).select("_id");
      const docs = users.map((u) => ({
        userId: u._id,
        title,
        message,
        type: type || "push",
        broadcast: true,
        scheduledAt: scheduledAt || null,
        data: data || null,
        sentBy: req.user._id,
      }));
      if (docs.length > 0) {
        const result = await Notification.insertMany(docs);
        created.push(...result);
      }
      res.json({ message: "Notification broadcast to " + users.length + " users", count: users.length, data: created[0] || null });
    } else {
      if (!userId) return res.status(400).json({ message: "userId is required for direct notifications" });
      const notif = await Notification.create({
        userId,
        title,
        message,
        type: type || "push",
        broadcast: false,
        scheduledAt: scheduledAt || null,
        data: data || null,
        sentBy: req.user._id,
      });
      created.push(notif);
      res.json({ message: "Notification sent", count: 1, data: notif });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/notifications/:id", async (req, res) => {
  try {
    const notif = await Notification.findByIdAndDelete(req.params.id);
    if (!notif) return res.status(404).json({ message: "Notification not found" });
    res.json({ message: "Notification deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
