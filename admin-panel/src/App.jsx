import React, { useState, useEffect } from 'react';
import { LayoutDashboard, Users, ShieldAlert, MessageSquare, ShieldCheck, LogOut } from 'lucide-react';
import Dashboard from './pages/Dashboard';
import UsersManagement from './pages/UsersManagement';
import CommunitiesManagement from './pages/CommunitiesManagement';
import MessagesManagement from './pages/MessagesManagement';
import Login from './pages/Login';
import { getToken, getAdminUser, clearToken, registerLogoutHandler } from './api';

function App() {
  const [token, setToken] = useState(getToken());
  const [adminUser, setAdminUser] = useState(getAdminUser());
  const [activeTab, setActiveTab] = useState('dashboard');

  useEffect(() => {
    // Automatically log out if a 401 response triggers the handler
    registerLogoutHandler(() => {
      setToken(null);
      setAdminUser(null);
    });
  }, []);

  const handleLoginSuccess = (newToken, newUser) => {
    setToken(newToken);
    setAdminUser(newUser);
  };

  const handleLogout = () => {
    clearToken();
    setToken(null);
    setAdminUser(null);
  };

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <Dashboard />;
      case 'users':
        return <UsersManagement />;
      case 'communities':
        return <CommunitiesManagement />;
      case 'messages':
        return <MessagesManagement />;
      default:
        return <Dashboard />;
    }
  };

  const getPageTitle = () => {
    switch (activeTab) {
      case 'dashboard': return 'Dashboard Overview';
      case 'users': return 'User Accounts Moderation';
      case 'communities': return 'Communities Moderation';
      case 'messages': return 'Message Audit Logs';
      default: return 'NearMe Admin';
    }
  };

  if (!token) {
    return <Login onLoginSuccess={handleLoginSuccess} />;
  }

  return (
    <div className="app-container">
      {/* Sidebar Navigation */}
      <aside className="sidebar">
        <div className="sidebar-logo">
          Near<span>Me</span> Admin
        </div>
        
        <ul className="sidebar-menu">
          <li className="sidebar-item">
            <a 
              className={`sidebar-link ${activeTab === 'dashboard' ? 'active' : ''}`}
              onClick={() => setActiveTab('dashboard')}
            >
              <LayoutDashboard size={18} />
              Dashboard
            </a>
          </li>
          <li className="sidebar-item">
            <a 
              className={`sidebar-link ${activeTab === 'users' ? 'active' : ''}`}
              onClick={() => setActiveTab('users')}
            >
              <Users size={18} />
              Manage Users
            </a>
          </li>
          <li className="sidebar-item">
            <a 
              className={`sidebar-link ${activeTab === 'communities' ? 'active' : ''}`}
              onClick={() => setActiveTab('communities')}
            >
              <ShieldCheck size={18} />
              Communities
            </a>
          </li>
          <li className="sidebar-item">
            <a 
              className={`sidebar-link ${activeTab === 'messages' ? 'active' : ''}`}
              onClick={() => setActiveTab('messages')}
            >
              <MessageSquare size={18} />
              Message Logs
            </a>
          </li>
        </ul>

        {/* Logout Section */}
        <div style={{ padding: '16px', borderTop: '1px solid rgba(255, 255, 255, 0.05)' }}>
          <button 
            onClick={handleLogout}
            style={{
              width: '100%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              padding: '10px',
              borderRadius: '8px',
              backgroundColor: 'var(--danger-bg)',
              color: 'var(--danger)',
              border: 'none',
              cursor: 'pointer',
              fontWeight: '600',
              fontSize: '13px',
              transition: 'background-color 0.2s'
            }}
          >
            <LogOut size={16} />
            Sign Out
          </button>
        </div>
        
        <div style={{ padding: '24px', borderTop: '1px solid rgba(255, 255, 255, 0.05)', fontSize: '12px', color: 'rgba(255, 255, 255, 0.3)' }}>
          Version 1.0.0 (Vite React)
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="main-wrapper">
        <header className="header">
          <div className="header-title">
            <h1>{getPageTitle()}</h1>
          </div>
          
          <div className="header-profile">
            <span className="admin-badge">SYSTEM ADMIN</span>
            <div 
              style={{ 
                width: '38px', 
                height: '38px', 
                borderRadius: '50%', 
                backgroundColor: 'var(--accent-color)', 
                color: 'white', 
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: 'center',
                fontWeight: 'bold',
                fontSize: '14px'
              }}
            >
              {adminUser?.username?.substring(0, 2).toUpperCase() || 'AD'}
            </div>
          </div>
        </header>

        <main className="content-container">
          {renderContent()}
        </main>
      </div>
    </div>
  );
}

export default App;
