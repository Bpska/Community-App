const pool = require('../config/database');

// Get all communities
exports.getAllCommunities = async (req, res) => {
    try {
        const userId = req.user.id;

        const result = await pool.query(
            `SELECT 
        c.id, c.name, c.description, c.logo, c.cover, c.category, c.type, c.radius, c.created_at,
        c.created_by, u.name as creator_name,
        COUNT(DISTINCT cm.id) as member_count,
        EXISTS(SELECT 1 FROM community_members WHERE community_id = c.id AND user_id = $1) as is_member
       FROM communities c
       JOIN users u ON c.created_by = u.id
       LEFT JOIN community_members cm ON c.id = cm.community_id AND cm.status = 'joined'
       GROUP BY c.id, u.name
       ORDER BY c.created_at DESC`,
            [userId]
        );

        const communities = result.rows.map(comm => ({
            id: comm.id,
            name: comm.name,
            description: comm.description,
            logo: comm.logo,
            cover: comm.cover,
            category: comm.category,
            type: comm.type,
            radius: parseFloat(comm.radius),
            createdBy: comm.created_by,
            creatorName: comm.creator_name,
            memberCount: parseInt(comm.member_count),
            isMember: comm.is_member,
            createdAt: comm.created_at
        }));

        res.json({
            success: true,
            communities
        });
    } catch (error) {
        console.error('Get communities error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

// Search communities
exports.searchCommunities = async (req, res) => {
    try {
        const { query } = req.query;
        const userId = req.user.id;

        if (!query) {
            return res.status(400).json({
                success: false,
                message: 'Search query is required'
            });
        }

        const result = await pool.query(
            `SELECT 
        c.id, c.name, c.description, c.logo, c.cover, c.category, c.type, c.radius, c.created_at,
        COUNT(DISTINCT cm.id) as member_count,
        EXISTS(SELECT 1 FROM community_members WHERE community_id = c.id AND user_id = $1) as is_member
       FROM communities c
       LEFT JOIN community_members cm ON c.id = cm.community_id AND cm.status = 'joined'
       WHERE c.name ILIKE $2 OR c.description ILIKE $2 OR c.category ILIKE $2
       GROUP BY c.id
       ORDER BY c.created_at DESC`,
            [userId, `%${query}%`]
        );

        const communities = result.rows.map(comm => ({
            id: comm.id,
            name: comm.name,
            description: comm.description,
            logo: comm.logo,
            cover: comm.cover,
            category: comm.category,
            type: comm.type,
            radius: parseFloat(comm.radius),
            memberCount: parseInt(comm.member_count),
            isMember: comm.is_member,
            createdAt: comm.created_at
        }));

        res.json({
            success: true,
            communities
        });
    } catch (error) {
        console.error('Search communities error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

// Create community
exports.createCommunity = async (req, res) => {
    try {
        const userId = req.user.id;
        const { name, description, category, type, radius } = req.body;

        if (!name || !description || !category) {
            return res.status(400).json({
                success: false,
                message: 'Name, description, and category are required'
            });
        }

        // Get logo and cover from uploaded files
        const logo = req.files?.logo ? `/uploads/${req.files.logo[0].filename}` : null;
        const cover = req.files?.cover ? `/uploads/${req.files.cover[0].filename}` : null;

        const result = await pool.query(
            `INSERT INTO communities (name, description, logo, cover, category, type, radius, created_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
            [name, description, logo, cover, category, type || 'public', radius || 2.0, userId]
        );

        const community = result.rows[0];

        // Automatically add creator as member
        await pool.query(
            'INSERT INTO community_members (community_id, user_id, status) VALUES ($1, $2, $3)',
            [community.id, userId, 'joined']
        );

        res.status(201).json({
            success: true,
            message: 'Community created successfully',
            community: {
                id: community.id,
                name: community.name,
                description: community.description,
                logo: community.logo,
                cover: community.cover,
                category: community.category,
                type: community.type,
                radius: parseFloat(community.radius),
                createdBy: community.created_by,
                createdAt: community.created_at
            }
        });
    } catch (error) {
        console.error('Create community error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

// Join community
exports.joinCommunity = async (req, res) => {
    try {
        const userId = req.user.id;
        const { communityId } = req.body;

        if (!communityId) {
            return res.status(400).json({
                success: false,
                message: 'Community ID is required'
            });
        }

        // Check if community exists
        const communityResult = await pool.query(
            'SELECT * FROM communities WHERE id = $1',
            [communityId]
        );

        if (communityResult.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Community not found'
            });
        }

        // Check if already a member
        const memberCheck = await pool.query(
            'SELECT * FROM community_members WHERE community_id = $1 AND user_id = $2',
            [communityId, userId]
        );

        if (memberCheck.rows.length > 0) {
            return res.status(400).json({
                success: false,
                message: 'Already a member of this community'
            });
        }

        // Add user to community
        await pool.query(
            'INSERT INTO community_members (community_id, user_id, status) VALUES ($1, $2, $3)',
            [communityId, userId, 'joined']
        );

        res.json({
            success: true,
            message: 'Successfully joined community'
        });
    } catch (error) {
        console.error('Join community error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

// Get community details
exports.getCommunityDetails = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const result = await pool.query(
            `SELECT 
        c.*, u.name as creator_name,
        COUNT(DISTINCT cm.id) as member_count,
        EXISTS(SELECT 1 FROM community_members WHERE community_id = c.id AND user_id = $1) as is_member
       FROM communities c
       JOIN users u ON c.created_by = u.id
       LEFT JOIN community_members cm ON c.id = cm.community_id AND cm.status = 'joined'
       WHERE c.id = $2
       GROUP BY c.id, u.name`,
            [userId, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Community not found'
            });
        }

        const comm = result.rows[0];

        res.json({
            success: true,
            community: {
                id: comm.id,
                name: comm.name,
                description: comm.description,
                logo: comm.logo,
                cover: comm.cover,
                category: comm.category,
                type: comm.type,
                radius: parseFloat(comm.radius),
                createdBy: comm.created_by,
                creatorName: comm.creator_name,
                memberCount: parseInt(comm.member_count),
                isMember: comm.is_member,
                createdAt: comm.created_at
            }
        });
    } catch (error) {
        console.error('Get community details error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};
