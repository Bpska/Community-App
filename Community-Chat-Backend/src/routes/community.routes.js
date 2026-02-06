const express = require('express');
const router = express.Router();
const communityController = require('../controllers/community.controller');
const authMiddleware = require('../middleware/auth');
const upload = require('../middleware/upload');

// All routes are protected
router.use(authMiddleware);

router.get('/list', communityController.getAllCommunities);
router.get('/search', communityController.searchCommunities);
router.post(
    '/create',
    upload.fields([
        { name: 'logo', maxCount: 1 },
        { name: 'cover', maxCount: 1 }
    ]),
    communityController.createCommunity
);
router.post('/join', communityController.joinCommunity);
router.get('/details/:id', communityController.getCommunityDetails);

module.exports = router;
