import React, { useState, useEffect } from 'react';
import { Search, Trash2, X, AlertTriangle, ShieldCheck, ShieldAlert, Award } from 'lucide-react';
import { fetchUsers, suspendUser, activateUser, deleteUser, fetchUserCommunities, MEDIA_BASE } from '../api';

export default function UsersManagement() {
  const [users, setUsers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Modal states
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [showCommunitiesModal, setShowCommunitiesModal] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [userCommunities, setUserCommunities] = useState([]);
  const [loadingCommunities, setLoadingCommunities] = useState(false);

  const loadUsers = () => {
    setLoading(true);
    fetchUsers()
      .then((data) => {
        setUsers(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setError(err.message);
        setLoading(false);
      });
  };

  useEffect(() => {
    loadUsers();
  }, []);

  // Toggle user active status
  const handleToggleStatus = (id, isActive) => {
    const action = isActive ? suspendUser : activateUser;
    
    action(id)
      .then(() => {
        // Optimistically update list
        setUsers(users.map(u => u.id === id ? { ...u, isActive: !isActive } : u));
      })
      .catch((err) => alert(err.message));
  };

  // Confirm delete dialog
  const openDeleteConfirm = (user) => {
    setSelectedUser(user);
    setShowDeleteModal(true);
  };

  // Execute delete user
  const handleDeleteUser = () => {
    if (!selectedUser) return;
    deleteUser(selectedUser.id)
      .then(() => {
        setUsers(users.filter(u => u.id !== selectedUser.id));
        setShowDeleteModal(false);
        setSelectedUser(null);
      })
      .catch((err) => {
        alert(err.message);
        setShowDeleteModal(false);
      });
  };

  // View joined / created communities modal
  const viewCommunities = (user) => {
    setSelectedUser(user);
    setShowCommunitiesModal(true);
    setLoadingCommunities(true);
    setUserCommunities([]);
    
    fetchUserCommunities(user.id)
      .then((data) => {
        setUserCommunities(data);
        setLoadingCommunities(false);
      })
      .catch((err) => {
        console.error(err);
        setLoadingCommunities(false);
      });
  };

  const filteredUsers = users.filter((u) => {
    const term = searchTerm.toLowerCase();
    return (
      (u.name && u.name.toLowerCase().includes(term)) ||
      (u.email && u.email.toLowerCase().includes(term))
    );
  });

  return (
    <div>
      <div className="page-header">
        <div className="page-title-desc">
          <h2>User Accounts</h2>
          <p>View, suspend/activate, or terminate user profiles.</p>
        </div>
      </div>

      <div className="card-container">
        {/* Search bar */}
        <div className="search-bar-container">
          <div style={{ position: 'relative', flex: 1, display: 'flex', alignItems: 'center' }}>
            <Search size={18} style={{ position: 'absolute', left: '12px', color: 'var(--text-muted)' }} />
            <input
              type="text"
              className="search-input"
              style={{ paddingLeft: '40px' }}
              placeholder="Search by name or email address..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <button className="btn btn-primary" onClick={loadUsers}>Refresh</button>
        </div>

        {/* User list table */}
        {loading ? (
          <div style={{ padding: '40px', textAlign: 'center' }}>Loading user profiles...</div>
        ) : error ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--danger)' }}>{error}</div>
        ) : filteredUsers.length === 0 ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-muted)' }}>No user accounts found matching your query.</div>
        ) : (
          <div className="moderation-table-wrapper">
            <table className="moderation-table">
              <thead>
                <tr>
                  <th>User Profile</th>
                  <th>ID</th>
                  <th>Age / Gender</th>
                  <th>Account Status</th>
                  <th>Created At</th>
                  <th style={{ textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((user) => {
                  const initial = user.name ? user.name.charAt(0).toUpperCase() : '?';
                  const isActive = user.isActive !== false;
                  return (
                    <tr key={user.id}>
                      <td>
                        <div className="user-info-row">
                          {user.profilePhoto ? (
                            <img src={`${MEDIA_BASE}${user.profilePhoto}`} className="user-avatar-mini" alt="" onError={(e) => { e.target.style.display = 'none'; }} />
                          ) : (
                            <div className="user-avatar-mini" style={{ backgroundColor: 'var(--accent-light)', color: 'var(--accent-color)' }}>
                              {initial}
                            </div>
                          )}
                          <div className="user-details-mini">
                            <span className="user-name-mini" style={{ cursor: 'pointer', textDecoration: 'underline' }} onClick={() => viewCommunities(user)}>
                              {user.name || 'Anonymous'}
                            </span>
                            <span className="user-email-mini">{user.email}</span>
                          </div>
                        </div>
                      </td>
                      <td style={{ fontFamily: 'monospace', fontSize: '11px', color: 'var(--text-muted)' }}>
                        {user.id.substring(0, 8)}...
                      </td>
                      <td>
                        {user.age || 'N/A'} yrs / {user.gender || 'N/A'}
                      </td>
                      <td>
                        <span className={`status-badge ${isActive ? 'active' : 'inactive'}`}>
                          {isActive ? 'Active' : 'Suspended'}
                        </span>
                      </td>
                      <td style={{ color: 'var(--text-muted)', fontSize: '13px' }}>
                        {new Date(user.createdAt).toLocaleDateString()}
                      </td>
                      <td style={{ textAlign: 'right' }}>
                        <div style={{ display: 'inline-flex', gap: '8px' }}>
                          <button
                            className="btn"
                            style={{ padding: '6px 12px', fontSize: '12px', backgroundColor: 'var(--border-color)', color: 'var(--text-primary)' }}
                            onClick={() => viewCommunities(user)}
                          >
                            Groups
                          </button>
                          <button
                            className={`btn-toggle ${isActive ? 'deactivate' : 'activate'}`}
                            onClick={() => handleToggleStatus(user.id, isActive)}
                          >
                            {isActive ? 'Suspend' : 'Activate'}
                          </button>
                          <button
                            className="btn-icon delete"
                            onClick={() => openDeleteConfirm(user)}
                          >
                            <Trash2 size={16} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Delete Confirmation Modal */}
      {showDeleteModal && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--danger)' }}>
                <AlertTriangle size={20} /> Delete Account?
              </h3>
              <button className="btn-icon" onClick={() => setShowDeleteModal(false)}>
                <X size={18} />
              </button>
            </div>
            <p style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '24px' }}>
              Are you sure you want to permanently delete the profile for <strong>{selectedUser?.name}</strong> ({selectedUser?.email})? This action will remove all user records and cannot be undone.
            </p>
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
              <button className="btn" style={{ backgroundColor: 'var(--border-color)' }} onClick={() => setShowDeleteModal(false)}>
                Cancel
              </button>
              <button className="btn" style={{ backgroundColor: 'var(--danger)', color: 'white' }} onClick={handleDeleteUser}>
                Permanently Delete
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Communities Modal */}
      {showCommunitiesModal && (
        <div className="modal-overlay">
          <div className="modal-content" style={{ maxWidth: '600px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '18px', fontWeight: '600' }}>
                Joined & Created Communities — {selectedUser?.name}
              </h3>
              <button className="btn-icon" onClick={() => setShowCommunitiesModal(false)}>
                <X size={18} />
              </button>
            </div>
            
            {loadingCommunities ? (
              <p style={{ padding: '20px 0', textAlign: 'center' }}>Loading communities...</p>
            ) : userCommunities.length === 0 ? (
              <p style={{ padding: '20px 0', textAlign: 'center', color: 'var(--text-muted)' }}>
                This user is not enrolled in any communities.
              </p>
            ) : (
              <div style={{ maxHeight: '350px', overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '12px' }}>
                {userCommunities.map((c) => (
                  <div key={c.id} style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '12px 16px',
                    borderRadius: '8px',
                    border: '1px solid var(--border-color)',
                    backgroundColor: 'var(--bg-primary)'
                  }}>
                    <div>
                      <div style={{ fontWeight: '600', fontSize: '14px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                        {c.name}
                        {c.creatorId === selectedUser?.id && (
                          <span style={{ color: 'var(--warning)', display: 'inline-flex', alignItems: 'center', title: 'Creator' }}>
                            <Award size={14} />
                          </span>
                        )}
                      </div>
                      <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>
                        {c.district || 'No District'} · {c.block || 'No Block'}
                      </div>
                    </div>
                    <div style={{ display: 'flex', gap: '6px' }}>
                      <span className={`status-badge ${c.type === 'public' ? 'active' : 'inactive'}`} style={{ textTransform: 'capitalize' }}>
                        {c.type}
                      </span>
                      <span className={`status-badge ${c.isActive !== false ? 'active' : 'inactive'}`}>
                        {c.isActive !== false ? 'Active' : 'Inactive'}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
            
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '24px' }}>
              <button className="btn btn-primary" onClick={() => setShowCommunitiesModal(false)}>
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
