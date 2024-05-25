
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
const nameSpace = io.of('/user-namespace');//create a namespace
nameSpace.on('connection', async (socket) => {// for connect a user
    console.log("User connected" + socket.id);
    const sender_id = socket.handshake.query.sender_id;//to get the sender id(connected user id)

    if (sender_id) {
        onlineUsers.set(sender_id, socket.id);//ad to online user map
        console.log("Online users:", onlineUsers);
        nameSpace.emit('getOnlineUser', { sender_id });//send to the client side online user map
        await User.findByIdAndUpdate({ _id: sender_id }, { $set: { isOnline: "1" } });//update the database

        socket.on('disconnect', async () => {//same operation when disconnected
            onlineUsers.delete(sender_id);
            console.log("Online users:", onlineUsers);
            nameSpace.emit('getOfflineStatus', { sender_id });
            await User.findByIdAndUpdate({ _id: sender_id }, { $set: { isOnline: "0" } });

            console.log("User disconnected" + socket.id);
        });
    }

    socket.on('sendMessage', (data) => {// get the message from client side 
        const receiverSocketId = onlineUsers.get(data.receiverId);
        if (receiverSocketId) {
            socket.to(receiverSocketId).emit('reciverMessage', data);// broadcast to the client side
        }
    });

    socket.on('getoldMessage', async (data) => {
        try {
            let chats = await Chat.find({//find the message based on the sender and reciver id
                $or: [
                    { senderId: data.senderId, reciverId: data.reciverId },
                    { senderId: data.reciverId, reciverId: data.senderId }
                ]
            }).lean();//to convert in a js object
            socket.emit("loadOldMessage", { chats: chats });//send to the client side
        } catch (error) {
            console.error("Error fetching old messages:", error);
            socket.emit("loadOldMessage", { error: "Failed to fetch old messages" });
        }
    });
});


server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
});
