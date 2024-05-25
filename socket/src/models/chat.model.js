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

    },
    image: {
        type: String,
    },
    status: {
        type: String,
        enum: ['not seen', 'seen'],
        default: 'not seen'
    }
}, { timestamps: true });
const Chat = mongoose.model('Chat', chatSchema);
module.exports = Chat;