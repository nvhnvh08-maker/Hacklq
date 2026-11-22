//
//  server.js
//  Share Map Realtime Telemetry Server
//  Tác giả: by trbaomod (tương thích 100% giao diện https://map.yong38.com)
//

const http = require("http");
const express = require("express");
const WebSocket = require("ws");
const path = require("path");
const fs = require("fs");

const app = express();
app.use(express.json({ limit: "5mb" }));

// Cấu hình CORS
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.header("Access-Control-Allow-Headers", "Content-Type, Authorization");
  if (req.method === "OPTIONS") return res.sendStatus(200);
  next();
});

// Lưu trữ in-memory các phiên phát sóng
// sessions[sessionId] = { frame: {...}, updatedAt: timestamp, viewers: Set<WebSocket> }
const sessions = new Map();

// Dọn dẹp các session không hoạt động sau 30 phút
setInterval(() => {
  const now = Date.now();
  for (const [code, s] of sessions.entries()) {
    if (now - s.updatedAt > 30 * 60 * 1000 && (!s.viewers || s.viewers.size === 0)) {
      sessions.delete(code);
      console.log(`[Cleaner] Đã xóa session hết hạn: ${code}`);
    }
  }
}, 60 * 1000);

// Phục vụ file tĩnh
app.use(express.static(path.join(__dirname, "public")));

// Route trang chủ nhập mã: /
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

// Route điều hướng /go?code=...
app.get("/go", (req, res) => {
  const code = (req.query.code || "").toUpperCase().trim();
  if (code && code.length === 6) {
    res.redirect(`/m/${code}`);
  } else {
    res.redirect("/?e=1");
  }
});

// Route xem map trực tiếp: /m/:sessionId
app.get("/m/:sessionId", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "viewer.html"));
});

// API kiểm tra và lấy snapshot: GET /api/sessions/:sessionId/snapshot
app.get("/api/sessions/:sessionId/snapshot", (req, res) => {
  const code = (req.params.sessionId || "").toUpperCase();
  const session = sessions.get(code);
  
  if (!session) {
    // Nếu chưa có session nhưng có request từ viewer, tạo khung chờ
    return res.status(200).json({
      version: 1,
      state: "waiting_for_battle",
      sessionId: code,
      players: [],
      towers: []
    });
  }
  
  res.json(session.frame);
});

// API cập nhật snapshot từ game app: POST /api/sessions/:sessionId/snapshot
app.post("/api/sessions/:sessionId/snapshot", (req, res) => {
  const code = (req.params.sessionId || "").toUpperCase();
  const frame = req.body;
  
  if (!code || !frame) {
    return res.status(400).json({ error: "Missing session or frame data" });
  }
  
  let session = sessions.get(code);
  if (!session) {
    session = { frame: null, updatedAt: Date.now(), viewers: new Set() };
    sessions.set(code, session);
  }
  
  session.frame = frame;
  session.updatedAt = Date.now();
  
  // Broadcast tới tất cả viewers WebSocket đang xem phòng này
  broadcastToViewers(session, frame);
  
  res.json({ success: true, viewers: session.viewers.size });
});

function broadcastToViewers(session, frame) {
  if (!session.viewers || session.viewers.size === 0) return;
  const payload = JSON.stringify({ type: "frame", frame: frame });
  for (const ws of session.viewers) {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(payload);
    }
  }
}

// Khởi tạo HTTP Server
const PORT = process.env.PORT || 3000;
const server = http.createServer(app);

// WebSocket Server
const wss = new WebSocket.Server({ noServer: true });

server.on("upgrade", (request, socket, head) => {
  const url = new URL(request.url, `http://${request.headers.host}`);
  const pathname = url.pathname;
  
  // Route WebSocket cho viewer: /ws/view/:sessionId
  // Route WebSocket cho publisher (app): /ws/publish/:sessionId
  if (pathname.startsWith("/ws/view/") || pathname.startsWith("/ws/publish/")) {
    wss.handleUpgrade(request, socket, head, (ws) => {
      wss.emit("connection", ws, request);
    });
  } else {
    socket.destroy();
  }
});

wss.on("connection", (ws, req) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const pathname = url.pathname;
  const isPublisher = pathname.startsWith("/ws/publish/");
  const parts = pathname.split("/");
  const code = (parts[parts.length - 1] || "").toUpperCase();
  
  if (!code || code.length !== 6) {
    ws.close(1008, "Mã phòng không hợp lệ");
    return;
  }
  
  let session = sessions.get(code);
  if (!session) {
    session = {
      frame: { version: 1, state: "waiting_for_battle", sessionId: code, players: [], towers: [] },
      updatedAt: Date.now(),
      viewers: new Set()
    };
    sessions.set(code, session);
  }
  
  if (isPublisher) {
    console.log(`[Publisher Connected] App Liên Quân kết nối phòng: ${code}`);
    
    ws.on("message", (msgData) => {
      try {
        const parsed = JSON.parse(msgData.toString());
        session.frame = parsed.type === "frame" ? parsed.frame : parsed;
        session.updatedAt = Date.now();
        broadcastToViewers(session, session.frame);
      } catch (err) {
        console.error("Lỗi parse frame publisher:", err);
      }
    });
    
    ws.on("close", () => {
      console.log(`[Publisher Disconnected] App ngắt kết nối phòng: ${code}`);
    });
  } else {
    // Viewer
    console.log(`[Viewer Connected] Người xem kết nối phòng: ${code}`);
    session.viewers.add(ws);
    
    // Gửi frame hiện tại ngay khi vừa kết nối
    if (session.frame) {
      ws.send(JSON.stringify({ type: "frame", frame: session.frame }));
    }
    
    ws.on("close", () => {
      session.viewers.delete(ws);
      console.log(`[Viewer Disconnected] Người xem rời phòng: ${code}`);
    });
  }
});

server.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(`🚀 TrbaoMod Share Map Server đang chạy tại cổng: ${PORT}`);
  console.log(`🌐 Truy cập: http://localhost:${PORT}`);
  console.log(`=======================================================`);
});
