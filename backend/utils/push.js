const FcmToken = require("../models/FcmToken");

let admin = null;

function initializeFirebase() {
  try {
    const firebaseAdmin = require("firebase-admin");
    if (!firebaseAdmin.apps.length) {
      const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT;
      if (serviceAccount) {
        firebaseAdmin.initializeApp({
          credential: firebaseAdmin.credential.cert(JSON.parse(serviceAccount)),
        });
        console.log("Firebase Admin initialized for push notifications");
      } else {
        console.log("FIREBASE_SERVICE_ACCOUNT not set — push notifications disabled");
        return;
      }
    }
    admin = firebaseAdmin;
  } catch (err) {
    console.log("firebase-admin not available — push notifications disabled:", err.message);
  }
}

async function sendPushNotification(userId, { title, message, orderId, actionLink, actionType, type, priority }) {
  if (!admin) return;

  try {
    const tokens = await FcmToken.find({ user: userId, isActive: true });
    if (tokens.length === 0) return;

    const fcmTokens = tokens.map((t) => t.token);
    const priorityMap = { critical: "high", high: "high", medium: "normal", low: "normal" };

    const notification = {
      title,
      body: message,
    };

    const data = {
      type: type || "ORDER",
      priority: priority || "medium",
      orderId: orderId ? orderId.toString() : "",
      actionLink: actionLink || "",
      actionType: actionType || "",
    };

    const message_payload = {
      notification,
      data,
      tokens: fcmTokens,
      android: {
        priority: priorityMap[priority] || "normal",
        notification: {
          channelId: "myspicemarket_default",
          priority: priorityMap[priority] || "normal",
        },
      },
    };

    const response = await admin.messaging().sendEachForMulticast(message_payload);

    const failedTokens = [];
    response.responses.forEach((resp, idx) => {
      if (!resp.success) {
        failedTokens.push(fcmTokens[idx]);
      }
    });

    if (failedTokens.length > 0) {
      await FcmToken.deleteMany({ token: { $in: failedTokens } });
      console.log(`Cleaned ${failedTokens.length} invalid FCM tokens`);
    }

    console.log(`Push sent to user ${userId}: ${response.successCount}/${fcmTokens.length} succeeded`);
  } catch (err) {
    console.error("sendPushNotification error:", err.message);
  }
}

async function registerToken(userId, token, platform = "android", appType = "customer") {
  try {
    await FcmToken.findOneAndUpdate(
      { token },
      { user: userId, platform, appType, isActive: true, lastUsed: new Date() },
      { upsert: true, new: true }
    );
  } catch (err) {
    console.error("registerToken error:", err.message);
  }
}

async function unregisterToken(token) {
  try {
    await FcmToken.findOneAndUpdate({ token }, { isActive: false });
  } catch (_) {}
}

module.exports = {
  initializeFirebase,
  sendPushNotification,
  registerToken,
  unregisterToken,
};
