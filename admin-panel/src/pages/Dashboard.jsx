import React, { useState, useEffect } from 'react';
import { Users, Shield, MessageSquare, Activity, Heart, Globe, Lock, ShieldAlert } from 'lucide-react';
import { fetchStats } from '../api';

export default function Dashboard() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    onlineUsers: 0,
    totalCommunities: 0,
    publicCommunities: 0,
    privateCommunities: 0,
    activeCommunities: 0,
    inactiveCommunities: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchStats()
      .then((data) => {
        setStats(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '200px' }}>
        <p>Loading dashboard metrics...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ padding: '24px', backgroundColor: 'var(--danger-bg)', color: 'var(--danger)', borderRadius: '12px' }}>
        <p>Error loading dashboard: {error}</p>
      </div>
    );
  }

  const onlineRate = stats.totalUsers > 0 ? Math.round((stats.onlineUsers / stats.totalUsers) * 100) : 0;

  return (
    <div>
      <div className="page-header">
        <div className="page-title-desc">
          <h2>Overview Dashboard</h2>
          <p>Real-time app statistics and community activity metrics.</p>
        </div>
      </div>

      <div className="dashboard-grid">
        {/* Total Users Card */}
        <div className="stat-card">
          <div className="stat-details">
            <span className="stat-label">Total Users</span>
            <span className="stat-value">{stats.totalUsers}</span>
          </div>
          <div className="stat-icon-wrapper" style={{ backgroundColor: 'var(--accent-light)', color: 'var(--accent-color)' }}>
            <Users size={24} />
          </div>
        </div>

        {/* Online Members Card */}
        <div className="stat-card">
          <div className="stat-details">
            <span className="stat-label">Members Online</span>
            <span className="stat-value">{stats.onlineUsers}</span>
          </div>
          <div className="stat-icon-wrapper" style={{ backgroundColor: 'rgba(16, 185, 129, 0.15)', color: 'var(--success)' }}>
            <Activity size={24} />
          </div>
        </div>

        {/* Total Communities Card */}
        <div className="stat-card">
          <div className="stat-details">
            <span className="stat-label">Total Communities</span>
            <span className="stat-value">{stats.totalCommunities}</span>
          </div>
          <div className="stat-icon-wrapper" style={{ backgroundColor: 'rgba(245, 158, 11, 0.15)', color: 'var(--warning)' }}>
            <Shield size={24} />
          </div>
        </div>

        {/* Active Communities Card */}
        <div className="stat-card">
          <div className="stat-details">
            <span className="stat-label">Active Communities</span>
            <span className="stat-value">{stats.activeCommunities}</span>
          </div>
          <div className="stat-icon-wrapper" style={{ backgroundColor: 'rgba(99, 102, 241, 0.15)', color: '#6366f1' }}>
            <Heart size={24} />
          </div>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '24px', marginTop: '32px' }}>
        {/* Community Scope Health */}
        <div className="card-container" style={{ padding: '28px' }}>
          <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Shield size={18} color="var(--warning)" /> Community Types Breakdown
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px', color: 'var(--text-secondary)' }}>
                <Globe size={16} /> Public Groups
              </span>
              <span style={{ fontWeight: '700', fontSize: '16px' }}>{stats.publicCommunities}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px', color: 'var(--text-secondary)' }}>
                <Lock size={16} /> Private Groups
              </span>
              <span style={{ fontWeight: '700', fontSize: '16px' }}>{stats.privateCommunities}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '12px', borderTop: '1px solid var(--border-color)' }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px', color: 'var(--text-secondary)' }}>
                <ShieldAlert size={16} /> Suspended/Inactive Groups
              </span>
              <span style={{ fontWeight: '700', fontSize: '16px', color: 'var(--danger)' }}>{stats.inactiveCommunities}</span>
            </div>
          </div>
        </div>

        {/* User Health Card */}
        <div className="card-container" style={{ padding: '28px' }}>
          <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Activity size={18} color="var(--success)" /> User Connectivity Ratio
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px', marginBottom: '6px' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Online Members Ratio</span>
                <span style={{ fontWeight: '600' }}>{onlineRate}%</span>
              </div>
              <div style={{ height: '8px', backgroundColor: 'var(--border-color)', borderRadius: '4px', overflow: 'hidden' }}>
                <div style={{ width: `${onlineRate}%`, height: '100%', backgroundColor: 'var(--success)', borderRadius: '4px' }}></div>
              </div>
            </div>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
              Out of the total registered accounts, {stats.onlineUsers} accounts are currently active in community rooms. Inactive accounts can be moderated or reviewed under the Users panel.
            </p>
          </div>
        </div>

        {/* Server Info Card */}
        <div className="card-container" style={{ padding: '28px' }}>
          <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Globe size={18} color="var(--accent-color)" /> System Information
          </h3>
          <p style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
            Welcome to the NearMe Administration Dashboard. You have full oversight on user activities, chat logs, and local community spaces.
          </p>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', padding: '12px', borderRadius: '8px', border: '1px solid var(--border-color)', fontSize: '13px' }}>
              <span>Database Status</span>
              <span style={{ color: 'var(--success)', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '4px' }}>
                Online <div style={{ width: '8px', height: '8px', borderRadius: '50%', backgroundColor: 'var(--success)' }}></div>
              </span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', padding: '12px', borderRadius: '8px', border: '1px solid var(--border-color)', fontSize: '13px' }}>
              <span>Server Host IP</span>
              <span style={{ fontWeight: '600', color: 'var(--text-muted)' }}>{window.location.hostname}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
