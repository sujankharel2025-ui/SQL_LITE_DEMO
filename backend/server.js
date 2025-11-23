// backend/server.js
const express = require("express");
const cors = require("cors");
const fs = require("fs");
const path = require("path");

const app = express();
app.use(cors());
app.use(express.json());

const DB_PATH = path.join(__dirname, "db.json");

// Read db.json (safely)
function loadDB() {
  try {
    const raw = fs.readFileSync(DB_PATH, "utf8");
    return JSON.parse(raw);
  } catch (err) {
    return { messages: [] };
  }
}

// Save db.json
function saveDB(data) {
  fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2));
}

// Helper: find message by id
function findById(messages, id) {
  return messages.find(m => m.id === id);
}

// GET all messages (simple)
app.get("/messages", (req, res) => {
  const db = loadDB();
  res.json(db.messages);
});

// SYNC endpoint
// Expects: { localMessages: [ ... ], lastSyncTime: "<ISO string>" }
// Returns: { success: true, serverMessages: [ ... ] }
app.post("/sync", (req, res) => {
  const { localMessages = [], lastSyncTime = "1970-01-01T00:00:00.000Z" } = req.body || {};
  const db = loadDB();

  // 1) Merge local messages into server (LWW by timestamp)
  localMessages.forEach(local => {
    if (!local || !local.id) return;

    // Mark as synced since it's now on the server
    local.isSynced = true;

    const serverMsg = findById(db.messages, local.id);
    if (!serverMsg) {
      // new message -> add
      db.messages.push(local);
    } else {
      // message exists on server -> keep the one with later timestamp (LWW)
      // Compare ISO strings directly (they are lexicographically comparable when ISO8601)
      if ((local.timestamp || "") > (serverMsg.timestamp || "")) {
        Object.assign(serverMsg, local);
      }
    }
  });

  // 2) Save changes to db.json
  saveDB(db);

  // 3) Collect server messages newer than lastSyncTime to return to client
  const updates = db.messages.filter(m => {
    const ts = m.timestamp || "1970-01-01T00:00:00.000Z";
    return ts > lastSyncTime;
  });

  // 4) Return updates
  res.json({ success: true, serverMessages: updates });
});

// Simple POST /messages for quick testing (optional)
app.post("/messages", (req, res) => {
  const db = loadDB();
  const msg = req.body;
  if (!msg || !msg.id) return res.status(400).json({ error: "invalid message" });
  if (!findById(db.messages, msg.id)) {
    db.messages.push(msg);
    saveDB(db);
  }
  res.status(201).json({ success: true, message: msg });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
