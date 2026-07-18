require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const app = express();

// Security
app.use(helmet());

// CORS (production safe)
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "*",
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
);

// Body parser
app.use(express.json({ limit: "10kb" }));
app.use(express.urlencoded({ extended: true }));

// DB connect
require("./config/db");

// Routes
const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const drugRoutes = require("./routes/drugRoutes");
const manufacturerRoutes = require("./routes/manufacturerRoutes");
const wholesalerRoutes = require("./routes/wholesalerRoutes");
const retailerRoutes = require("./routes/retailerRoutes");
const batchRoutes = require("./routes/batchRoutes");
const stockRoutes = require("./routes/stockRoutes");
const invoiceRoutes = require("./routes/invoiceRoutes");
const inspectionRoutes = require("./routes/inspectionRoutes");
const adminRoutes = require("./routes/adminRoutes");

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/drugs", drugRoutes);
app.use("/api/manufacturers", manufacturerRoutes);
app.use("/api/wholesalers", wholesalerRoutes);
app.use("/api/retailers", retailerRoutes);
app.use("/api/batches", batchRoutes);
app.use("/api/stock", stockRoutes);
app.use("/api/invoices", invoiceRoutes);
app.use("/api/inspections", inspectionRoutes);
app.use("/api/admin", adminRoutes);

// Health check
app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "API Running",
  });
});

// 404
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found",
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error(err);

  if (res.headersSent) {
    return next(err);
  }

  res.status(err.statusCode || err.status || 500).json({
    success: false,
    message: err.message || "Internal Server Error",
  });
});

// Server start
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});

// Crash handlers
process.on("unhandledRejection", (err) => {
  console.error("Unhandled Rejection:", err);
});

process.on("uncaughtException", (err) => {
  console.error("Uncaught Exception:", err);
});
