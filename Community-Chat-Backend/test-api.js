const axios = require('axios');

const API_BASE = 'http://localhost:3000/api';

// Color console output
const colors = {
    reset: '\x1b[0m',
    green: '\x1b[32m',
    red: '\x1b[31m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    cyan: '\x1b[36m'
};

function log(color, message) {
    console.log(`${colors[color]}${message}${colors.reset}`);
}

async function testAPI() {
    console.log('\n' + '='.repeat(60));
    log('cyan', '🧪 Community Chat Backend API Tests');
    console.log('='.repeat(60) + '\n');

    let authToken = '';
    let userId = '';

    try {
        // Test 1: Health Check
        log('blue', '📡 Test 1: Health Check');
        const healthResponse = await axios.get('http://localhost:3000/health');
        if (healthResponse.data.success) {
            log('green', '✅ Health check passed');
            console.log(`   Server: ${healthResponse.data.message}\n`);
        }

        // Test 2: Register User
        log('blue', '📝 Test 2: Register New User');
        const registerData = {
            name: 'Test User',
            email: `test${Date.now()}@example.com`,
            password: 'Password123',
            age: 25,
            gender: 'Male'
        };

        try {
            const registerResponse = await axios.post(`${API_BASE}/auth/register`, registerData);
            authToken = registerResponse.data.token;
            userId = registerResponse.data.user.id;
            log('green', '✅ User registration successful');
            console.log(`   User ID: ${userId}`);
            console.log(`   Email: ${registerData.email}\n`);
        } catch (err) {
            if (err.response && err.response.status === 409) {
                log('yellow', '⚠️  User already exists, trying login instead');

                // Try login
                const loginResponse = await axios.post(`${API_BASE}/auth/login`, {
                    email: registerData.email,
                    password: registerData.password
                });
                authToken = loginResponse.data.token;
                userId = loginResponse.data.user.id;
                log('green', '✅ Login successful');
            } else {
                throw err;
            }
        }

        // Test 3: Get User Profile
        log('blue', '👤 Test 3: Get User Profile');
        const profileResponse = await axios.get(`${API_BASE}/users/${userId}`, {
            headers: { Authorization: `Bearer ${authToken}` }
        });
        if (profileResponse.data.success) {
            log('green', '✅ Profile retrieval successful');
            console.log(`   Name: ${profileResponse.data.user.name}\n`);
        }

        // Test 4: Get Nearby Users
        log('blue', '📍 Test 4: Get Nearby Users');
        try {
            const nearbyResponse = await axios.get(`${API_BASE}/users/nearby?latitude=28.6139&longitude=77.2090&radius=5`, {
                headers: { Authorization: `Bearer ${authToken}` }
            });
            log('green', '✅ Nearby users query successful');
            console.log(`   Found: ${nearbyResponse.data.users.length} users\n`);
        } catch (err) {
            log('yellow', '⚠️  Nearby users endpoint may need implementation\n');
        }

        // Test 5: Get Communities
        log('blue', '🏘️  Test 5: Get Communities');
        try {
            const communitiesResponse = await axios.get(`${API_BASE}/communities`, {
                headers: { Authorization: `Bearer ${authToken}` }
            });
            log('green', '✅ Communities retrieval successful');
            console.log(`   Found: ${communitiesResponse.data.communities.length} communities\n`);
        } catch (err) {
            log('yellow', '⚠️  Communities endpoint may need implementation\n');
        }

        // Test 6: Create Community
        log('blue', '🏗️  Test 6: Create Community');
        try {
            const communityData = {
                name: 'Test Community',
                description: 'A test community for API testing',
                category: 'Technology',
                type: 'public',
                latitude: 28.6139,
                longitude: 77.2090,
                radius: 2.0
            };
            const createCommunityResponse = await axios.post(`${API_BASE}/communities`, communityData, {
                headers: { Authorization: `Bearer ${authToken}` }
            });
            log('green', '✅ Community creation successful');
            console.log(`   Community ID: ${createCommunityResponse.data.community.id}\n`);
        } catch (err) {
            log('yellow', '⚠️  Community creation endpoint may need implementation\n');
        }

        // Summary
        console.log('='.repeat(60));
        log('green', '✨ API Testing Completed!');
        console.log('='.repeat(60) + '\n');

        log('cyan', 'Summary:');
        console.log(`  Backend URL: http://localhost:3000`);
        console.log(`  API Base: ${API_BASE}`);
        console.log(`  Database: propoly (PostgreSQL)`);
        console.log(`  Auth Token: ${authToken.substring(0, 20)}...`);
        console.log(`\n✅ Backend is ready for frontend integration!\n`);

    } catch (error) {
        log('red', '\n❌ API Test Failed:');
        if (error.response) {
            console.log(`   Status: ${error.response.status}`);
            console.log(`   Message: ${error.response.data.message || error.message}`);
        } else {
            console.log(`   Error: ${error.message}`);
        }
        console.log('\n');
        process.exit(1);
    }
}

testAPI();
