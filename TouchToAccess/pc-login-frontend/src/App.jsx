import React, { useState, useEffect } from 'react';
import axios from 'axios';

const App = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loginStatus, setLoginStatus] = useState('');
  const [loginId, setLoginId] = useState('');
  const [isPolling, setIsPolling] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      const response = await axios.post('http://localhost:5000/validate-credentials', {
        email,
        password,
      });

      if (response.data.success) {
        setLoginStatus('Login successful!');
        handleLoginRequest();
      } else {
        setLoginStatus('Login failed. Check your credentials.');
      }
    } catch (error) {
      console.error('Error during login request:', error);
      setLoginStatus('An error occurred while logging in.');
    }
  };

  const handleLoginRequest = async () => {
    try {
      const response = await axios.post('http://localhost:5000/login-request');
      if (response.data.loginId) {
        setLoginId(response.data.loginId);
        setLoginStatus('Login request initiated. Waiting for mobile approval...');
        setIsPolling(true);
      }
    } catch (error) {
      console.error('Error creating login request:', error);
      setLoginStatus('An error occurred while initiating the login request.');
    }
  };

  // 🔁 Polling logic
  useEffect(() => {
    if (!loginId || !isPolling) return;

    const maxAttempts = 20;
    let attempts = 0;

    const interval = setInterval(async () => {
      try {
        const response = await axios.get(`http://localhost:5000/status/${loginId}`);
        if (response.data.status === 'approved') {
          clearInterval(interval);
          setLoginStatus('✅ Login approved from mobile!');
          setIsPolling(false);
          // TODO: Navigate to dashboard
        }

        if (++attempts >= maxAttempts) {
          clearInterval(interval);
          setLoginStatus('❌ Login timed out.');
          setIsPolling(false);
        }
      } catch (error) {
        console.error('Polling error:', error);
      }
    }, 3000); // every 3 seconds

    return () => clearInterval(interval); // cleanup if component unmounts
  }, [loginId, isPolling]);

  return (
    <div>
      <h1>PC Login</h1>
      <form onSubmit={handleSubmit}>
        <label>
          Email:
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        </label>
        <br />
        <label>
          Password:
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </label>
        <br />
        <button type="submit" disabled={isPolling}>
          Login
        </button>
      </form>
      <p>{loginStatus}</p>
      {loginId && <p>Login ID: {loginId}</p>}
    </div>
  );
};

export default App;
