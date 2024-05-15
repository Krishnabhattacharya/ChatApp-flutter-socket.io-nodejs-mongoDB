const User = require('../models/user.model.js');
const uploadToCloudinary = require('../utils/upload_file.js');

const register = async (req, res) => {
    try {
        const { name, email, password } = req.body;
        const file = req.file;

        if (!name || !email || !password) {
            return res.status(400).send({
                success: false,
                message: "Please provide name, email, and password"
            });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).send({
                success: false,
                message: "User already exists",
            });
        }

        if (!file) {
            return res.status(400).send({ message: "No file uploaded" });
        }

        const imageUploadResult = await uploadToCloudinary(file.path);
        console.log(imageUploadResult);
        if (imageUploadResult.message !== 'Success') {
            return res.status(500).send({ message: "Failed to upload image" });
        }

        const user = await User.create({ name, email, password, image: imageUploadResult.url });
        const token = await user.generateToken();
        res.status(201).send({
            success: true,
            user,
            token
        });
    } catch (error) {
        console.error("Error registering user:", error);
        res.status(500).send({
            success: false,
            message: "Internal server error"
        });
    }
};
const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email });
        if (!user) {
            res.status(401).send({
                success: true,
                message: "user not found",
            })
        }
        const isMatch = user.comparePassword(password);
        if (!isMatch) {
            return res.status(404).send({
                success: false,
                message: "Invalid password"
            });
        }
        const token = await user.generateToken();
        res.status(201).send({
            success: true,
            user: user,
            token
        });
    } catch (error) {
        res.status(500).send({
            success: false,
            message: error.message
        })
    }
}
module.exports = { register, login };
