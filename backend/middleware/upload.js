const multer = require('multer');
const path = require('path');


const storage = multer.memoryStorage();

const upload = multer({
  storage,
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
    if (!allowedTypes.includes(file.mimetype)) {
      return cb(new Error('Format de fichier invalide'), false);
    }
    cb(null, true);
  },
});

module.exports = upload;