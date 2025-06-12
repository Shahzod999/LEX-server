import dotenv from "dotenv";
import express from "express";
import cors from "cors";
import { createServer } from "http"; //new
import connectDB from "./config/db";
import cookieParser from "cookie-parser";
import usersRoutes from "./routes/usersRoutes";
import chatRoutes from "./routes/chatRoutes";
import documentRoutes from "./routes/documentRoutes";
import uploadImages from "./routes/uploadImages";
import { ChatWebSocketServer } from "./controllers/websocketController"; //new
import reminderRoutes from "./routes/reminderRoutes";
import openaiRoutes from "./routes/openaiRoutes";
import { errorHandler } from "./middleware/errorHandler";
import { telegramNotifier } from "./utils/telegramNotifier";
import path from "path";

dotenv.config();

const app = express();
const server = createServer(app); //new
const port = process.env.PORT ? parseInt(process.env.PORT) : 3000;

const allowedOrigins = ["http://localhost:3000", "https://lexhelps.com", "https://www.lexhelps.com"];

app.use(
  cors({
    origin: allowedOrigins,
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true,
  })
);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// Connect to database
connectDB();

// chatWS - экземпляр класса ChatWebSocketServer, который управляет WebSocket соединениями
const chatWS = new ChatWebSocketServer(server);

app.get("/", (_req, res) => {
  res.send({ message: "nice" });
});

// API routes
app.use("/api/users", usersRoutes);
app.use("/api/documents", documentRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/upload", uploadImages);
app.use("/api/openai", openaiRoutes);
app.use("/api/reminder", reminderRoutes);

app.get("/privacy", (_req, res) => {
  res.sendFile(path.join(__dirname, "doc", "privacy.html"));
});

app.get("/terms-of-use", (_req, res) => {
  res.sendFile(path.join(__dirname, "doc", "termsOfUse.html"));
});

app.get("/support", (_req, res) => {
  res.sendFile(path.join(__dirname, "doc", "support.html"));
});

// WebSocket stats endpoint
app.get("/api/websocket/stats", (_req, res) => {
  try {
    const stats = chatWS.getStats();
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: "Failed to get WebSocket stats" });
  }
});

// Health check endpoint
app.get("/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// Error handling middleware (должен быть последним)
app.use(errorHandler);

// Start server
server.listen(port, () => {
  console.log(`Server running on port ${port}`);
  console.log(`WebSocket server available at ws://localhost:${port}/ws/chat`);

  // Уведомляем о запуске сервера
  telegramNotifier
    .notifyInfo(`🚀 LEX Server started on port ${port} Bismillahir Rohmanir Rohim`)
    .catch((err) => console.error("Failed to send startup notification:", err));
});

export default app;
export { server, chatWS }; //new
