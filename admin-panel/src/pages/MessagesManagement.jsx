import React, { useState, useEffect } from 'react';
import { Search, Trash2 } from 'lucide-react';
import { fetchMessages, deleteMessage } from '../api';

export default function MessagesManagement() {
  const [messages, setMessages] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const loadMessages = () => {
    setLoading(true);
    fetchMessages()
      .then((data) => {
        setMessages(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setError(err.message);
        setLoading(false);
      });
  };

  useEffect(() => {
    loadMessages();
  }, []);

  // Execute delete message
  const handleDeleteMessage = (id) => {
    if (!window.confirm('Are you sure you want to delete this message? This action is immediate.')) return;
    deleteMessage(id)
      .then(() => {
        setMessages(messages.filter(m => m.id !== id));
      })
      .catch((err) => alert(err.message));
  };

  const filteredMessages = messages.filter((m) => {
    const term = searchTerm.toLowerCase();
    return (
      (m.message && m.message.toLowerCase().includes(term)) ||
      (m.senderName && m.senderName.toLowerCase().includes(term)) ||
      (m.receiverName && m.receiverName.toLowerCase().includes(term)) ||
      (m.communityName && m.communityName.toLowerCase().includes(term))
    );
  });

  return (
    <div>
      <div className="page-header">
        <div className="page-title-desc">
          <h2>Message Audit Logs</h2>
          <p>Monitor recent public and direct messages. Remove inappropriate content.</p>
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
              placeholder="Search by keyword, sender name, community, or direct receiver..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <button className="btn btn-primary" onClick={loadMessages}>Refresh</button>
        </div>

        {/* Messages Audit Table */}
        {loading ? (
          <div style={{ padding: '40px', textAlign: 'center' }}>Loading message audit logs...</div>
        ) : error ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--danger)' }}>{error}</div>
        ) : filteredMessages.length === 0 ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-muted)' }}>No messages found matching your query.</div>
        ) : (
          <div className="moderation-table-wrapper">
            <table className="moderation-table">
              <thead>
                <tr>
                  <th>Sender</th>
                  <th>Message Content</th>
                  <th>Recipient / Scope</th>
                  <th>Status</th>
                  <th>Timestamp</th>
                  <th style={{ textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredMessages.map((m) => {
                  return (
                    <tr key={m.id}>
                      <td style={{ fontWeight: '600', color: 'var(--text-primary)' }}>
                        {m.senderName || 'Anonymous'}
                      </td>
                      <td className="message-cell" style={{ maxWidth: '350px', whiteSpace: 'normal', wordBreak: 'break-all' }}>
                        {m.message}
                      </td>
                      <td>
                        {m.communityName ? (
                          <span className="status-badge" style={{ backgroundColor: 'rgba(245, 158, 11, 0.15)', color: 'var(--warning)' }}>
                            Hub: {m.communityName}
                          </span>
                        ) : m.receiverName ? (
                          <span className="status-badge" style={{ backgroundColor: 'var(--accent-light)', color: 'var(--accent-color)' }}>
                            Direct: {m.receiverName}
                          </span>
                        ) : (
                          <span style={{ color: 'var(--text-muted)', fontSize: '13px' }}>Unknown scope</span>
                        )}
                      </td>
                      <td>
                        <span className="status-badge" style={{ backgroundColor: 'var(--border-color)', color: 'var(--text-secondary)' }}>
                          {m.status}
                        </span>
                      </td>
                      <td style={{ color: 'var(--text-muted)', fontSize: '13px' }}>
                        {new Date(m.createdAt).toLocaleDateString()} {new Date(m.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                      </td>
                      <td style={{ textAlign: 'right' }}>
                        <button
                          className="btn-icon delete"
                          onClick={() => handleDeleteMessage(m.id)}
                        >
                          <Trash2 size={16} />
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
