
const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userSchema = mongoose.Schema({
    name: {
        required: true,
        type: String,
    },
    email: {
        required: true,
        type: String,
        unique: true,
        validate: validator.isEmail
    },
    password: {
        type: String,
        required: true,
    },
    image: {
        type: String,

    },
    isOnline: {
        type: String,
        default: '0',
    },
    tokens: [{
        token: {
            type: String,
            required: true
        }
    }],

}, { timestamps: true });



userSchema.pre("save", async function (next) {
    const user = this;
    if (user.isModified) {
        user.password = await bcrypt.hash(user.password, 10);
    }
    next();
})


userSchema.methods.generateToken = async function () {
    const user = this;
    const token = jwt.sign({ id: user._id.toString() }, "chatAppJwt");
    user.tokens = user.tokens.concat({ token });
    await user.save();
    return token;
}

userSchema.methods.comparePassword = async function (enteredPassword) {
    const isMatch = await bcrypt.compare(enteredPassword, this.password);
    return isMatch;
};

userSchema.methods.toJSON = function () {
    const user = this;
    const userObject = user.toObject();
    delete userObject.password;
    delete userObject.tokens;
    return userObject;
}



const User = mongoose.model("User", userSchema);
module.exports = User;