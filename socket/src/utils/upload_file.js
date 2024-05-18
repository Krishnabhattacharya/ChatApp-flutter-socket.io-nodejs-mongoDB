const cloudinary = require('cloudinary').v2;
const fs = require('fs');

const path = require('path');
cloudinary.config({
    cloud_name: "delcuaej9",
    api_key: "422144646849997",
    api_secret: "zEezg3eX2KK9zuaS_TggwaDoIEs",
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

}

module.exports = uploadToCloudinary;
