import React, { useState } from 'react';
import axios from 'axios';

function App() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const handleLogin = async () => {
    if (!email || !password) {
      setMessage('Please enter both email and password.');
      return;
    }

    setLoading(true);
    try {
      // Send login credentials to the backend
      const response = await axios.post('http://localhost:5000/validate-credentials', {
        email,
        password,
      });

      if (response.data.success) {
        setMessage('Login successful. Awaiting fingerprint authentication...');

        // Trigger the login request to the mobile app
        const loginResponse = await axios.post('http://localhost:5000/login-request');
        const { loginId } = loginResponse.data;

        // Inform the user to authenticate with fingerprint
        setMessage('Please authenticate with your fingerprint on the mobile app.');

        // Polling for the status of the fingerprint authentication
        const checkStatus = async () => {
          const statusResponse = await axios.get(`http://localhost:5000/status/${loginId}`);
          if (statusResponse.data.status === 'approved') {
            setMessage('Login successful!');
            setLoading(false);
          } else if (statusResponse.data.status === 'pending') {
            setTimeout(checkStatus, 2000); // Keep checking every 2 seconds
          }
        };

        checkStatus(); // Start polling
      } else {
        setMessage('Invalid credentials.');
        setLoading(false);
      }
    } catch (error) {
      console.error('Login failed:', error);
      setMessage('An error occurred. Please try again.');
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <h1>Login</h1>
      <div>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Email"
        />
      </div>
      <div>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
        />
      </div>
      <button onClick={handleLogin} disabled={loading}>
        {loading ? 'Logging in...' : 'Login'}
      </button>
      {message && <p>{message}</p>}
    </div>
  );
}

export default App;
