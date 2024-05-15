const mongoose = require('mongoose');
const chatSchema = mongoose.Schema({
    senderId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    reciverId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    message: {
        type: String,
        requireed: true,
    },

}, { timestamps: true });
const Chat = mongoose.model('Chat', chatSchema);
module.exports = Chat;