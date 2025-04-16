// src/index.js
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';  // Your main App component

// Render the App component inside the root div in index.html
ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')  // Make sure this matches the id in your public/index.html
);
