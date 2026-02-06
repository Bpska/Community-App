const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chat.controller');
const authMiddleware = require('../middleware/auth');

// All routes are protected
router.use(authMiddleware);

router.get('/history/:userId', chatController.getChatHistory);
router.get('/conversations', chatController.getConversations);
router.post('/send', chatController.sendMessage);
router.get('/community/:communityId', chatController.getCommunityChatHistory);

module.exports = router;
