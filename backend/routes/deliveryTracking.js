const express = require("express");
const DeliveryLocation = require("../models/DeliveryLocation");
const Order = require("../models/Order");
const { protect } = require("../middleware/auth");

const router = express.Router();
router.use(protect);

const deliveryOnly = (req, res, next) => {
  if (req.user.role !== "deliveryAgent" && req.user.role !== "admin") {
    return res.status(403).json({ message: "Delivery agent access required" });
  }
  next();
};

// Proximity thresholds (meters)
const PICKUP_ARRIVAL_RADIUS = 100;
const CUSTOMER_NEAR_RADIUS = 200;
const CUSTOMER_ARRIVAL_RADIUS = 50;

function haversineDistance(lat1, lng1, lat2, lng2) {
  const R = 6371000;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function calculateETA(distanceMeters, speedMs) {
  if (speedMs <= 0) return Math.round((distanceMeters / 12.5) * 1000);
  return Math.round((distanceMeters / speedMs) * 1000);
}

// Update agent location with automatic status detection
router.post("/update", deliveryOnly, async (req, res) => {
  try {
    const {
      latitude,
      longitude,
      speed,
      heading,
      altitude,
      accuracy,
      orderId,
    } = req.body;

    if (latitude == null || longitude == null) {
      return res
        .status(400)
        .json({ message: "latitude and longitude are required" });
    }

    let detectedStatus = "en_route_to_pickup";
    let order = null;

    if (orderId) {
      order = await Order.findById(orderId);
      if (order) {
        const customerLat =
          order.delivery?.latitude || order.latitude || 4.0511;
        const customerLng =
          order.delivery?.longitude || order.longitude || 9.7679;
        const storeLat = 4.0511;
        const storeLng = 9.7679;

        const distToStore = haversineDistance(
          latitude,
          longitude,
          storeLat,
          storeLng
        );
        const distToCustomer = haversineDistance(
          latitude,
          longitude,
          customerLat,
          customerLng
        );

        if (order.status === "Out for Delivery" || order.status === "On Route") {
          if (distToStore <= PICKUP_ARRIVAL_RADIUS) {
            detectedStatus = "arrived_at_pickup";
          } else if (order.status === "On Route") {
            if (distToCustomer <= CUSTOMER_ARRIVAL_RADIUS) {
              detectedStatus = "arrived";
            } else if (distToCustomer <= CUSTOMER_NEAR_RADIUS) {
              detectedStatus = "near_customer";
            } else {
              detectedStatus = "en_route_to_customer";
            }
          }
        } else if (order.status === "Confirmed" || order.status === "Ready") {
          if (distToStore <= PICKUP_ARRIVAL_RADIUS) {
            detectedStatus = "arrived_at_pickup";
          }
        }

        // Auto-update order status based on GPS proximity
        if (
          detectedStatus === "near_customer" &&
          order.status === "On Route"
        ) {
          await Order.findByIdAndUpdate(orderId, {
            deliveryStatus: "near_customer",
          });
        }
      }
    }

    const storeLat = 4.0511;
    const storeLng = 9.7679;
    const customerLat =
      order?.delivery?.latitude || order?.latitude || storeLat;
    const customerLng =
      order?.delivery?.longitude || order?.longitude || storeLng;

    const remainingDistance = haversineDistance(
      latitude,
      longitude,
      customerLat,
      customerLng
    );
    const estimatedArrival = calculateETA(
      remainingDistance,
      speed || 0
    );

    const location = await DeliveryLocation.create({
      deliveryAgent: req.user._id,
      orderId: orderId || null,
      storeLocation: { latitude: storeLat, longitude: storeLng },
      customerLocation: { latitude: customerLat, longitude: customerLng },
      latitude,
      longitude,
      speed: speed || 0,
      heading: heading || 0,
      altitude: altitude || 0,
      accuracy: accuracy || 0,
      status: detectedStatus,
      remainingDistance,
      estimatedArrival,
      timestamp: new Date(),
    });

    res.json({ success: true, location, detectedStatus });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Bulk sync offline queued locations
router.post("/sync", deliveryOnly, async (req, res) => {
  try {
    const { locations } = req.body;
    if (!Array.isArray(locations) || locations.length === 0) {
      return res.status(400).json({ message: "locations array is required" });
    }

    const docs = locations.map((loc) => ({
      deliveryAgent: req.user._id,
      orderId: loc.orderId || null,
      latitude: loc.latitude,
      longitude: loc.longitude,
      speed: loc.speed || 0,
      heading: loc.heading || 0,
      altitude: loc.altitude || 0,
      accuracy: loc.accuracy || 0,
      status: loc.status || "en_route_to_pickup",
      remainingDistance: loc.remainingDistance || 0,
      estimatedArrival: loc.estimatedArrival || 0,
      offlineQueued: true,
      timestamp: new Date(loc.timestamp || Date.now()),
    }));

    await DeliveryLocation.insertMany(docs);
    res.json({ success: true, synced: docs.length });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get latest location of a specific agent
router.get("/agent/:agentId", async (req, res) => {
  try {
    const location = await DeliveryLocation.findOne({
      deliveryAgent: req.params.agentId,
    })
      .sort({ timestamp: -1 })
      .populate("deliveryAgent", "fullName phone vehicleType")
      .populate("orderId", "status delivery");

    res.json(location || null);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get my latest location
router.get("/me", deliveryOnly, async (req, res) => {
  try {
    const location = await DeliveryLocation.findOne({
      deliveryAgent: req.user._id,
    }).sort({ timestamp: -1 });
    res.json(location || null);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get all active agent locations (for admin/customer tracking)
router.get("/active", async (req, res) => {
  try {
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

    const pipeline = [
      { $match: { timestamp: { $gte: fiveMinutesAgo } } },
      { $sort: { timestamp: -1 } },
      {
        $group: {
          _id: "$deliveryAgent",
          latitude: { $first: "$latitude" },
          longitude: { $first: "$longitude" },
          speed: { $first: "$speed" },
          heading: { $first: "$heading" },
          status: { $first: "$status" },
          remainingDistance: { $first: "$remainingDistance" },
          estimatedArrival: { $first: "$estimatedArrival" },
          timestamp: { $first: "$timestamp" },
          orderId: { $first: "$orderId" },
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "_id",
          foreignField: "_id",
          as: "agent",
        },
      },
      { $unwind: { path: "$agent", preserveNullAndEmptyArrays: true } },
      {
        $lookup: {
          from: "orders",
          localField: "orderId",
          foreignField: "_id",
          as: "order",
        },
      },
      {
        $unwind: { path: "$order", preserveNullAndEmptyArrays: true },
      },
      {
        $project: {
          _id: 1,
          latitude: 1,
          longitude: 1,
          speed: 1,
          heading: 1,
          status: 1,
          remainingDistance: 1,
          estimatedArrival: 1,
          timestamp: 1,
          orderId: 1,
          "agent.fullName": 1,
          "agent.phone": 1,
          "agent.vehicleType": 1,
          "agent._id": 1,
          "order.status": 1,
          "order.total": 1,
          "order.delivery": 1,
        },
      },
    ];

    const locations = await DeliveryLocation.aggregate(pipeline);
    res.json(locations);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get location history for an order
router.get("/order/:orderId", async (req, res) => {
  try {
    const locations = await DeliveryLocation.find({
      orderId: req.params.orderId,
    })
      .sort({ timestamp: 1 })
      .select(
        "latitude longitude speed heading status remainingDistance estimatedArrival timestamp"
      );
    res.json(locations);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get route between two points (proxied from OpenRouteService)
router.get("/route", async (req, res) => {
  try {
    const { startLat, startLng, endLat, endLng } = req.query;
    if (!startLat || !startLng || !endLat || !endLng) {
      return res
        .status(400)
        .json({ message: "startLat, startLng, endLat, endLng are required" });
    }

    const axios = require("axios");
    const apiKey =
      process.env.OPENROUTESERVICE_API_KEY ||
      "5b3ce3597851110001cf624800000000";
    const url = `https://api.openrouteservice.org/v2/directions/driving-car?start=${startLng},${startLat}&end=${endLng},${endLat}`;

    const response = await axios.get(url, {
      headers: {
        Authorization: apiKey,
        Accept: "application/json",
      },
    });

    res.json(response.data);
  } catch (error) {
    res.status(500).json({ message: error.message || "Failed to fetch route" });
  }
});

module.exports = router;
