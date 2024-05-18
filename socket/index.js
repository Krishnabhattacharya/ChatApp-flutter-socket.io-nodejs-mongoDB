const express = require("express");
const http = require('http');
const socketio = require('socket.io');
const connection = require('./src/db/mongoose.js');
const route = require("./src/routes/user.route.js");
const User = require("./src/models/user.model.js");
const Chat = require('./src/models/chat.model.js')
const app = express();
const server = http.createServer(app);
const io = socketio(server);
const PORT = process.env.PORT || 3000;

connection();

app.use(express.json());
app.use(route);

let onlineUsers = new Map();
const nameSpace = io.of('/user-namespace');
nameSpace.on('connection', async (socket) => {
    console.log("User connected" + socket.id);
    const sender_id = socket.handshake.query.sender_id;

    if (sender_id) {
        onlineUsers.set(sender_id, socket.id);
        console.log("Online users:", onlineUsers);
        nameSpace.emit('getOnlineUser', { sender_id });
        await User.findByIdAndUpdate({ _id: sender_id }, { $set: { isOnline: "1" } });

        socket.on('disconnect', async () => {
            onlineUsers.delete(sender_id);
            console.log("Online users:", onlineUsers);
            nameSpace.emit('getOfflineStatus', { sender_id });
            await User.findByIdAndUpdate({ _id: sender_id }, { $set: { isOnline: "0" } });

            console.log("User disconnected" + socket.id);
        });
    }
    socket.on('sendMessage', (data) => {
        socket.broadcast.emit('reciverMessage', data);
    });
    socket.on('getoldMessage', async (data) => {
        try {
            let chats = await Chat.find({
                $or: [
                    { senderId: data.senderId },
                    { reciverId: data.reciverId }
                ]
            }).lean(); // Convert Mongoose documents to plain JavaScript objects
            console.log(chats);
            socket.emit("loadOldMessage", { chats: chats });
        } catch (error) {
            console.error("Error fetching old messages:", error);
            socket.emit("loadOldMessage", { error: "Failed to fetch old messages" });
        }
    });
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
});
