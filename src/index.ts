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

dotenv.config();

const app = express();
const server = createServer(app); //new
const port = process.env.PORT ? parseInt(process.env.PORT) : 3000;

const allowedOrigins = ["http://localhost:3000"];

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

// WebSocket stats endpoint
app.get("/api/websocket/stats", (_req, res) => {
  try {
    const stats = chatWS.getStats();
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: "Failed to get WebSocket stats" });
  }
});

// Start server
server.listen(port, () => {
  console.log(`Server running on port ${port}`);
  console.log(`WebSocket server available at ws://localhost:${port}/ws/chat`);
});

export default app;
export { server, chatWS }; //new
