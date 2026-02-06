const pool = require('../config/database');
const path = require('path');

// Get user profile
exports.getProfile = async (req, res) => {
    try {
        const userId = req.user.id;

        const result = await pool.query(
            'SELECT id, name, email, bio, gender, age, profile_photo, latitude, longitude, is_online, created_at FROM users WHERE id = $1',
            [userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const user = result.rows[0];

        res.json({
            success: true,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                bio: user.bio,
                gender: user.gender,
                age: user.age,
                profilePhoto: user.profile_photo,
                latitude: user.latitude,
                longitude: user.longitude,
                isOnline: user.is_online,
                createdAt: user.created_at
            }
        });
    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

// Get user by ID
exports.getUserById = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            'SELECT id, name, email, bio, gender, age, profile_photo, latitude, longitude, is_online, created_at FROM users WHERE id = $1',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const user = result.rows[0];

        res.json({
            success: true,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                bio: user.bio,
                gender: user.gender,
                age: user.age,
                profilePhoto: user.profile_photo,
                latitude: user.latitude,
                longitude: user.longitude,
                isOnline: user.is_online,
                createdAt: user.created_at
            }
        });
    } catch (error) {
        console.error('Get user by ID error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

// Update user profile
exports.updateProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const { name, bio, gender, age, latitude, longitude } = req.body;

        const result = await pool.query(
            `UPDATE users 
       SET name = COALESCE($1, name),
           bio = COALESCE($2, bio),
           gender = COALESCE($3, gender),
           age = COALESCE($4, age),
           latitude = COALESCE($5, latitude),
           longitude = COALESCE($6, longitude)
       WHERE id = $7
       RETURNING id, name, email, bio, gender, age, profile_photo, latitude, longitude`,
            [name, bio, gender, age, latitude, longitude, userId]
        );

        const user = result.rows[0];

        res.json({
            success: true,
            message: 'Profile updated successfully',
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                bio: user.bio,
                gender: user.gender,
                age: user.age,
                profilePhoto: user.profile_photo,
                latitude: user.latitude,
                longitude: user.longitude
            }
        });
    } catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

// Upload profile photo
exports.uploadPhoto = async (req, res) => {
    try {
        const userId = req.user.id;

        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: 'No file uploaded'
            });
        }

        const photoUrl = `/uploads/${req.file.filename}`;

        await pool.query(
            'UPDATE users SET profile_photo = $1 WHERE id = $2',
            [photoUrl, userId]
        );

        res.json({
            success: true,
            message: 'Photo uploaded successfully',
            photoUrl
        });
    } catch (error) {
        console.error('Upload photo error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

// Get nearby users
exports.getNearbyUsers = async (req, res) => {
    try {
        const { latitude, longitude, radius = 2 } = req.query;
        const userId = req.user.id;

        if (!latitude || !longitude) {
            return res.status(400).json({
                success: false,
                message: 'Latitude and longitude are required'
            });
        }

        // Haversine formula to find users within radius (in km)
        const result = await pool.query(
            `SELECT 
        id, name, email, bio, gender, age, profile_photo, latitude, longitude, is_online,
        (6371 * acos(cos(radians($1)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($1)) * sin(radians(latitude)))) AS distance
       FROM users
       WHERE id != $3
         AND latitude IS NOT NULL
         AND longitude IS NOT NULL
       HAVING distance < $4
       ORDER BY distance`,
            [parseFloat(latitude), parseFloat(longitude), userId, parseFloat(radius)]
        );

        const users = result.rows.map(user => ({
            id: user.id,
            name: user.name,
            email: user.email,
            bio: user.bio,
            gender: user.gender,
            age: user.age,
            profilePhoto: user.profile_photo,
            latitude: parseFloat(user.latitude),
            longitude: parseFloat(user.longitude),
            isOnline: user.is_online,
            distance: parseFloat(user.distance).toFixed(2)
        }));

        res.json({
            success: true,
            users
        });
    } catch (error) {
        console.error('Get nearby users error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};
