const jwt = require("jsonwebtoken");
const User = require("../../models/User");

exports.aiProtect = async (req, res, next) => {
  const token = req.headers.authorization?.startsWith("Bearer ") ? req.headers.authorization.split(" ")[1] : null;

  if (!token) {
    return res.status(401).json({ message: "Authentication required" });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || "spicemarket_jwt_secret");
    const user = await User.findById(decoded.userId).select("-password");
    if (!user) {
      return res.status(401).json({ message: "User not found" });
    }
    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid token" });
  }
};
