import React, { useState, useEffect } from 'react';
import { Search, Trash2, X, AlertTriangle, Users, Globe, Lock } from 'lucide-react';
import { fetchCommunities, toggleCommunityStatus, deleteCommunity, fetchCommunityMembers, MEDIA_BASE } from '../api';

export default function CommunitiesManagement() {
  const [communities, setCommunities] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Modal states
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [showMembersModal, setShowMembersModal] = useState(false);
  const [selectedCommunity, setSelectedCommunity] = useState(null);
  const [communityMembers, setCommunityMembers] = useState([]);
  const [loadingMembers, setLoadingMembers] = useState(false);

  const loadCommunities = () => {
    setLoading(true);
    fetchCommunities()
      .then((data) => {
        setCommunities(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setError(err.message);
        setLoading(false);
      });
  };

  useEffect(() => {
    loadCommunities();
  }, []);

  // Toggle active status
  const handleToggleStatus = (id, currentStatus) => {
    const nextStatus = !currentStatus;
    toggleCommunityStatus(id, nextStatus)
      .then(() => {
        // Optimistically update list
        setCommunities(communities.map(c => c.id === id ? { ...c, isActive: nextStatus } : c));
      })
      .catch((err) => alert(err.message));
  };

  // Confirm delete dialog
  const openDeleteConfirm = (community) => {
    setSelectedCommunity(community);
    setShowDeleteModal(true);
  };

  // Execute delete community
  const handleDeleteCommunity = () => {
    if (!selectedCommunity) return;
    deleteCommunity(selectedCommunity.id)
      .then(() => {
        setCommunities(communities.filter(c => c.id !== selectedCommunity.id));
        setShowDeleteModal(false);
        setSelectedCommunity(null);
      })
      .catch((err) => {
        alert(err.message);
        setShowDeleteModal(false);
      });
  };

  // View community members
  const viewMembers = (community) => {
    setSelectedCommunity(community);
    setShowMembersModal(true);
    setLoadingMembers(true);
    setCommunityMembers([]);
    
    fetchCommunityMembers(community.id)
      .then((data) => {
        setCommunityMembers(data);
        setLoadingMembers(false);
      })
      .catch((err) => {
        console.error(err);
        setLoadingMembers(false);
      });
  };

  const filteredCommunities = communities.filter((c) => {
    const term = searchTerm.toLowerCase();
    return (
      (c.name && c.name.toLowerCase().includes(term)) ||
      (c.category && c.category.toLowerCase().includes(term)) ||
      (c.district && c.district.toLowerCase().includes(term)) ||
      (c.block && c.block.toLowerCase().includes(term))
    );
  });

  return (
    <div>
      <div className="page-header">
        <div className="page-title-desc">
          <h2>Local Communities</h2>
          <p>Audit and manage proximity-based community groups and hubs.</p>
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
              placeholder="Search by name, category, district, or block..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <button className="btn btn-primary" onClick={loadCommunities}>Refresh</button>
        </div>

        {/* Communities Table */}
        {loading ? (
          <div style={{ padding: '40px', textAlign: 'center' }}>Loading local communities...</div>
        ) : error ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--danger)' }}>{error}</div>
        ) : filteredCommunities.length === 0 ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-muted)' }}>No local communities found matching your query.</div>
        ) : (
          <div className="moderation-table-wrapper">
            <table className="moderation-table">
              <thead>
                <tr>
                  <th>Community Hub</th>
                  <th>Location Info</th>
                  <th>Type</th>
                  <th>Radius</th>
                  <th>Members</th>
                  <th>Status</th>
                  <th style={{ textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredCommunities.map((c) => {
                  const initial = c.name ? c.name.charAt(0).toUpperCase() : '?';
                  const isActive = c.isActive !== false;
                  return (
                    <tr key={c.id}>
                      <td>
                        <div style={{ display: 'flex', gap: '12px', alignItems: 'flex-start' }}>
                          <div className="user-avatar-mini" style={{ borderRadius: '8px', backgroundColor: 'rgba(245, 158, 11, 0.15)', color: 'var(--warning)' }}>
                            {initial}
                          </div>
                          <div style={{ display: 'flex', flexDirection: 'column' }}>
                            <span style={{ fontWeight: '600', color: 'var(--text-primary)', cursor: 'pointer', textDecoration: 'underline' }} onClick={() => viewMembers(c)}>
                              {c.name}
                            </span>
                            <span style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', maxWidth: '280px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                              {c.description}
                            </span>
                          </div>
                        </div>
                      </td>
                      <td>
                        <div style={{ display: 'flex', flexDirection: 'column', fontSize: '13px' }}>
                          <span style={{ fontWeight: '500' }}>Dist: {c.district || '—'}</span>
                          <span style={{ color: 'var(--text-muted)' }}>Block: {c.block || '—'}</span>
                          {c.latitude && c.longitude && (
                            <span style={{ fontSize: '11px', color: 'var(--accent-color)', marginTop: '2px' }}>
                              GPS: {parseFloat(c.latitude).toFixed(5)}, {parseFloat(c.longitude).toFixed(5)}
                            </span>
                          )}
                        </div>
                      </td>
                      <td>
                        <span className={`status-badge ${c.type === 'public' ? 'active' : 'inactive'}`} style={{ textTransform: 'capitalize', gap: '4px' }}>
                          {c.type === 'public' ? <Globe size={12} /> : <Lock size={12} />}
                          {c.type}
                        </span>
                      </td>
                      <td style={{ color: 'var(--text-secondary)' }}>
                        {c.radius} km
                      </td>
                      <td>
                        <span style={{ fontWeight: '600', cursor: 'pointer', textDecoration: 'underline' }} onClick={() => viewMembers(c)}>
                          {c.membersCount || 0}
                        </span> members
                      </td>
                      <td>
                        <span className={`status-badge ${isActive ? 'active' : 'inactive'}`}>
                          {isActive ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                      <td style={{ textAlign: 'right' }}>
                        <div style={{ display: 'inline-flex', gap: '8px' }}>
                          <button
                            className="btn"
                            style={{ padding: '6px 12px', fontSize: '12px', backgroundColor: 'var(--border-color)', color: 'var(--text-primary)' }}
                            onClick={() => viewMembers(c)}
                          >
                            Members
                          </button>
                          <button
                            className={`btn-toggle ${isActive ? 'deactivate' : 'activate'}`}
                            onClick={() => handleToggleStatus(c.id, isActive)}
                          >
                            {isActive ? 'Deactivate' : 'Activate'}
                          </button>
                          <button
                            className="btn-icon delete"
                            onClick={() => openDeleteConfirm(c)}
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
                <AlertTriangle size={20} /> Delete Community Hub?
              </h3>
              <button className="btn-icon" onClick={() => setShowDeleteModal(false)}>
                <X size={18} />
              </button>
            </div>
            <p style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '24px' }}>
              Are you sure you want to delete the community hub <strong>{selectedCommunity?.name}</strong>? All members will be detached, and past history associated with this hub will be deleted. This cannot be undone.
            </p>
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
              <button className="btn" style={{ backgroundColor: 'var(--border-color)' }} onClick={() => setShowDeleteModal(false)}>
                Cancel
              </button>
              <button className="btn" style={{ backgroundColor: 'var(--danger)', color: 'white' }} onClick={handleDeleteCommunity}>
                Delete Hub
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Members Modal */}
      {showMembersModal && (
        <div className="modal-overlay">
          <div className="modal-content" style={{ maxWidth: '500px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '18px', fontWeight: '600' }}>
                Community Members — {selectedCommunity?.name}
              </h3>
              <button className="btn-icon" onClick={() => setShowMembersModal(false)}>
                <X size={18} />
              </button>
            </div>

            {loadingMembers ? (
              <p style={{ padding: '20px 0', textAlign: 'center' }}>Loading members...</p>
            ) : communityMembers.length === 0 ? (
              <p style={{ padding: '20px 0', textAlign: 'center', color: 'var(--text-muted)' }}>
                No members found in this community.
              </p>
            ) : (
              <div style={{ maxHeight: '350px', overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '10px' }}>
                {communityMembers.map((m) => {
                  const initial = m.name ? m.name.charAt(0).toUpperCase() : '?';
                  return (
                    <div key={m.id || m.userId} style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '12px',
                      padding: '10px 12px',
                      borderRadius: '8px',
                      border: '1px solid var(--border-color)',
                      backgroundColor: 'var(--bg-primary)'
                    }}>
                      {m.profilePhoto ? (
                        <img src={`${MEDIA_BASE}${m.profilePhoto}`} className="user-avatar-mini" alt="" onError={(e) => { e.target.style.display = 'none'; }} />
                      ) : (
                        <div className="user-avatar-mini" style={{ backgroundColor: 'var(--accent-light)', color: 'var(--accent-color)', width: '32px', height: '32px', fontSize: '12px' }}>
                          {initial}
                        </div>
                      )}
                      <div style={{ display: 'flex', flexDirection: 'column' }}>
                        <span style={{ fontSize: '13px', fontWeight: '600' }}>{m.name || 'Anonymous'}</span>
                        <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{m.email}</span>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}

            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '24px' }}>
              <button className="btn btn-primary" onClick={() => setShowMembersModal(false)}>
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
