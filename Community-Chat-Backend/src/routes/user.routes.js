const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const authMiddleware = require('../middleware/auth');
const upload = require('../middleware/upload');

// All routes are protected
router.use(authMiddleware);

router.get('/profile', userController.getProfile);
router.get('/nearby', userController.getNearbyUsers);
router.get('/:id', userController.getUserById);
router.put('/profile', userController.updateProfile);
router.post('/upload-photo', upload.single('photo'), userController.uploadPhoto);

module.exports = router;
