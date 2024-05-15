const express = require("express");
const path = require('path');
const http = require('http');
const dotenv = require('dotenv');
const socketio = require('socket.io');
const connection = require('../src/db/mongoose.js');
const route = require("./routes/user.route.js");
const app = express();
const server = http.createServer(app);
const io = socketio(server);
const PORT = process.env.PORT || 3000;
connection();
dotenv.config();
app.use(express.json());
app.use(route);
io.on('connection', (socket) => {
    console.log("socket connected");
    // socket.emit('countupdate', count)//to send data or event toclient side
    // socket.on('increment', () => {
    //     count++;
    //     io.emit('countupdate', count)
    // })

    socket.emit('message', 'welcome');
    socket.broadcast.emit('message', 'a new user join');// get this message to all but the current socket/user
    socket.on('sendMessage', (msg, callback) => {//get the message from client
        io.emit('message', msg);//broadcast the message to all user
        callback("done");
    })
    socket.on('disconnect', () => {
        io.emit("a user left");
    })
})

server.listen(PORT, '0.0.0.0', function () {
    console.log("Server running on = " + PORT);
});
