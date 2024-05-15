const cloudinary = require('cloudinary').v2;
const fs = require('fs');
require('dotenv').config();
const path = require('path');
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

async function uploadToCloudinary(localFilePath) {
    try {
        const mainFolderName = "main";
        const fileName = path.basename(localFilePath);
        const filePathOnCloudinary = `${mainFolderName}/${fileName}`;

        console.log("Uploading file:", localFilePath);

        const result = await cloudinary.uploader.upload(localFilePath, { public_id: filePathOnCloudinary });
        fs.unlinkSync(localFilePath);

        console.log("Upload successful. URL:", result.url);

        return {
            message: "Success",
            url: result.url,
        };
    } catch (error) {
        fs.unlinkSync(localFilePath);
        console.error("Error uploading file:", error.message);
        return { message: "Fail" };
    }
    finally {
        try {
            fs.unlinkSync(localFilePath);
            console.log("File deleted successfully");
        } catch (err) {
            console.error("Error deleting file:", err);
        }
    }
}

module.exports = uploadToCloudinary;
