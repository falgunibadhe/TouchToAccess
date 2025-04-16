const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors());
app.use(express.json());

// MongoDB setup
mongoose.connect('mongodb+srv://falguni:Passw0rd@cluster0.yf2dhxe.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0', {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
    .then(() => console.log("Connected to MongoDB"))
    .catch(err => console.log("MongoDB connection error: ", err));

// MongoDB Schema for User and Login Request
const userSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true }, // This should be a hashed password
    fingerprint_id: { type: String, required: true, unique: true } // Store fingerprint ID here
});

const loginRequestSchema = new mongoose.Schema({
    loginId: String,
    status: { type: String, default: 'pending' }
});

const User = mongoose.model('User', userSchema);
const LoginRequest = mongoose.model('LoginRequest', loginRequestSchema);

// Endpoint to validate email and password
app.post('/validate-credentials', async (req, res) => {
    const { email, password } = req.body;

    // Find user by email
    const user = await User.findOne({ email });
    if (user && await bcrypt.compare(password, user.password)) {
        res.json({ success: true });
    } else {
        res.json({ success: false });
    }
});

// PC triggers login attempt
app.post('/login-request', async (req, res) => {
    const loginId = uuidv4(); // Generate a unique login ID
    const loginRequest = new LoginRequest({ loginId, status: 'pending' });
    await loginRequest.save();
    res.json({ loginId });
});

// Mobile approves the login
app.post('/approve-login', async (req, res) => {
    const { loginId } = req.body;
    const loginRequest = await LoginRequest.findOne({ loginId });

    if (loginRequest) {
        loginRequest.status = 'approved';
        await loginRequest.save();
        res.json({ success: true });
    } else {
        res.status(404).json({ error: 'Login ID not found' });
    }
});

// PC checks status
app.get('/status/:id', async (req, res) => {
    const id = req.params.id;
    const request = await LoginRequest.findOne({ loginId: id });

    if (request) {
        res.json({ status: request.status });
    } else {
        res.status(404).json({ error: 'Login ID not found' });
    }
});

// Helper function to hash password for a new user (for initial setup)
async function hashPassword(password) {
    const salt = await bcrypt.genSalt(10);
    return await bcrypt.hash(password, salt);
}

app.post('/register', async (req, res) => {
    console.log('Register request received:', req.body);  // Log the request data

    const { email, password, fingerprint_id } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
        console.log('User already exists');  // Log if user exists
        return res.status(400).json({ error: 'User already exists' });
    }

    // Check if fingerprint_id already exists
    const existingFingerprint = await User.findOne({ fingerprint_id });
    if (existingFingerprint) {
        console.log('Fingerprint ID already registered');  // Log if fingerprint ID exists
        return res.status(400).json({ error: 'Fingerprint ID already registered' });
    }

    // Hash the password
    const hashedPassword = await hashPassword(password);

    const newUser = new User({ email, password: hashedPassword, fingerprint_id });
    await newUser.save();

    console.log('User registered successfully');
    res.json({ success: true, message: 'User registered successfully' });
});

// Endpoint to validate fingerprint ID during login
app.post('/validate-fingerprint', async (req, res) => {
    const { fingerprint_id } = req.body;

    // Find user by fingerprint_id
    const user = await User.findOne({ fingerprint_id });
    if (user) {
        res.json({ success: true });
    } else {
        res.json({ success: false });
    }
});

const PORT = 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Backend running on http://0.0.0.0:${PORT}`));
