const express = require('express');
const { register, login, getAllUsersExceptCurrent, saveChat } = require('../controller/user.controller.js');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const authMiddleware = require('../middleware/user.middleware.js');
const router = express.Router();

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, path.join(__dirname, '../assets'))
    },
    filename: function (req, file, cb) {
        const name = Date.now() + '-' + file.originalname;
        cb(null, name);
    },
});
const upload = multer({ storage: storage });

router.post('/auth/register', upload.single('image'), register);
router.post('/auth/login', login);
router.post('/save-chat', saveChat);
router.get('/auth/getAllUsersExceptCurrent/:id', authMiddleware, getAllUsersExceptCurrent);
module.exports = router;