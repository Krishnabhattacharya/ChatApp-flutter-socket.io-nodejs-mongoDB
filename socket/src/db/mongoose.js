const mongoose = require('mongoose');
module.exports = connection = () => {
    mongoose.connect('mongodb://127.0.0.1:27017/chat-app').then(() => {
        console.log('Database connected');
    }).catch((e) => {
        console.log("error while connicting database " + e.toString());
    })
}