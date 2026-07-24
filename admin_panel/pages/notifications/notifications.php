<?php
$currentPage = 'notifications';
$pageTitle   = 'Notifications';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt   = session_get_jwt();
$notifData = api_request('GET', API_ADMIN_NOTIFICATIONS, null, $jwt);
$notifBody = $notifData['body'] ?? [];
$notifList = is_array($notifBody) ? $notifBody : [];

include __DIR__ . '/../../includes/header.php';
include __DIR__ . '/../../includes/sidebar.php';
include __DIR__ . '/../../includes/loader.php';
?>
<div class="sidebar-overlay" id="sidebarOverlay" onclick="MSM.toggleSidebar()"></div>

<div class="admin-content">
    <div class="admin-navbar">
        <div class="navbar-left">
            <button class="btn btn-sm d-lg-none" onclick="MSM.toggleSidebar()" style="font-size:1.2rem;color:var(--msm-muted);"><i class="bi bi-list"></i></button>
            <div class="navbar-brand-text"><span>Notifications</span></div>
        </div>
        <div class="navbar-search d-none d-md-block">
            <i class="bi bi-search search-icon"></i>
            <input type="text" class="form-control" id="globalSearch" placeholder="Search meals, customers, orders..." autocomplete="off">
            <div class="search-results-dropdown" id="searchResults"></div>
        </div>
        <div class="navbar-right">
            <div style="position:relative;">
                <button class="navbar-icon-btn" onclick="MSM.toggleDropdown('notifDropdown')"><i class="bi bi-bell"></i></button>
                <div class="notification-dropdown" id="notifDropdown">
                    <div class="notif-header"><h6>Notifications</h6><a href="<?php echo admin_url('pages/notifications/notifications.php'); ?>" class="text-decoration-none small">View All</a></div>
                    <div class="notif-list"><div class="notif-item"><div class="notif-content"><div class="notif-title">All caught up!</div><div class="notif-msg">No new notifications.</div></div></div></div>
                </div>
            </div>
            <div style="position:relative;">
                <img src="<?php echo htmlspecialchars($adminAvatar); ?>" alt="Admin" class="profile-avatar" onerror="this.src='https://ui-avatars.com/api/?name=<?php echo urlencode($adminName); ?>&background=198754&color=fff&size=36'" onclick="MSM.toggleDropdown('profileDropdown')">
                <div class="profile-dropdown" id="profileDropdown">
                    <div style="padding:0.75rem 1rem;border-bottom:1px solid var(--msm-border);"><div style="font-weight:600;font-size:0.85rem;"><?php echo htmlspecialchars($adminName); ?></div><div style="font-size:0.75rem;color:var(--msm-muted);"><?php echo htmlspecialchars($adminEmail); ?></div></div>
                    <a href="<?php echo admin_url('pages/profile/profile.php'); ?>"><i class="bi bi-person"></i> Profile</a>
                    <a href="<?php echo admin_url('pages/settings/settings.php'); ?>"><i class="bi bi-gear"></i> Settings</a>
                    <div class="dropdown-divider"></div>
                    <a href="<?php echo admin_url('auth/logout.php'); ?>" class="logout-link"><i class="bi bi-box-arrow-right"></i> Logout</a>
                </div>
            </div>
        </div>
    </div>

    <div class="welcome-section animate-in">
        <h3><i class="bi bi-bell text-warning me-2"></i>Notification Center</h3>
        <p>Send push notifications to users or broadcast important updates.</p>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-lg-6 animate-in">
            <div class="msm-card">
                <div class="card-body p-4">

                    <!-- Nav pills -->
                    <div class="d-flex gap-2 mb-4">
                        <span class="badge bg-primary p-2 px-4" style="font-size:0.85rem;cursor:pointer;" onclick="switchMode('broadcast')" id="modeBroadcast">
                            <i class="bi bi-broadcast me-1"></i>Broadcast
                        </span>
                        <span class="badge bg-secondary bg-opacity-25 text-dark p-2 px-4" style="font-size:0.85rem;cursor:pointer;" onclick="switchMode('specific')" id="modeSpecific">
                            <i class="bi bi-person me-1"></i>Specific User
                        </span>
                        <span class="badge bg-secondary bg-opacity-25 text-dark p-2 px-4" style="font-size:0.85rem;cursor:pointer;" onclick="switchMode('schedule')" id="modeSchedule">
                            <i class="bi bi-clock me-1"></i>Schedule
                        </span>
                    </div>

                    <h5 class="fw-bold mb-3">Create Notification</h5>
                    <form id="notifForm" onsubmit="return sendNotification(event)">

                        <div id="userSelectSection" style="display:none;">
                            <div class="mb-3">
                                <label class="form-label">Select User</label>
                                <input type="text" class="form-control" id="userSearch" placeholder="Search users by name or email...">
                                <select class="form-select mt-2" id="userSelect" size="4" style="display:none;"></select>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Notification Type</label>
                            <select class="form-select" id="notifType">
                                <option value="SYSTEM">System</option>
                                <option value="ORDER">Order</option>
                                <option value="DELIVERY">Delivery</option>
                                <option value="PROMOTION">Promotion</option>
                                <option value="ACCOUNT">Account</option>
                                <option value="SECURITY">Security</option>
                                <option value="INVENTORY">Inventory</option>
                            </select>
                        </div>

                        <div class="row">
                            <div class="col-6 mb-3">
                                <label class="form-label">Category</label>
                                <select class="form-select" id="notifCategory">
                                    <option value="promotions">Promotions</option>
                                    <option value="system">System</option>
                                    <option value="orders">Orders</option>
                                    <option value="deliveries">Deliveries</option>
                                    <option value="account">Account</option>
                                    <option value="security">Security</option>
                                    <option value="inventory">Inventory</option>
                                </select>
                            </div>
                            <div class="col-6 mb-3">
                                <label class="form-label">Priority</label>
                                <select class="form-select" id="notifPriority">
                                    <option value="medium">Medium</option>
                                    <option value="low">Low</option>
                                    <option value="high">High</option>
                                    <option value="critical">Critical</option>
                                </select>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Title</label>
                            <input type="text" class="form-control" id="notifTitle" required placeholder="e.g. Flash Sale Today">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Message</label>
                            <textarea class="form-control" id="notifMessage" rows="4" required placeholder="Enter your notification message..."></textarea>
                            <div class="form-text text-end"><span id="charCount">0</span>/500</div>
                        </div>

                        <div id="scheduleSection" style="display:none;">
                            <div class="mb-3">
                                <label class="form-label">Schedule Date & Time</label>
                                <input type="datetime-local" class="form-control" id="notifSchedule">
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Additional Data (JSON)</label>
                            <textarea class="form-control" id="notifData" rows="2" placeholder='{"link": "/promotions/spicy-sale"}'></textarea>
                        </div>

                        <button type="submit" class="btn btn-msm w-100" id="sendNotifBtn">
                            <i class="bi bi-send me-2"></i>Send Notification
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-6 animate-in">
            <div class="msm-card h-100">
                <div class="card-body p-4">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <h5 class="fw-bold mb-0">Recent Notifications</h5>
                        <button class="btn btn-sm btn-msm-outline" onclick="refreshLog()"><i class="bi bi-arrow-clockwise"></i></button>
                    </div>

                    <div class="mb-2">
                        <input type="text" class="form-control form-control-sm" id="logSearch" placeholder="Filter notifications..." onkeyup="filterLog()">
                    </div>

                    <div id="notificationFeed" style="max-height:480px;overflow-y:auto;">
                        <?php if (empty($notifList)): ?>
                        <div class="text-center text-muted py-5">
                            <i class="bi bi-bell-slash" style="font-size:2rem;display:block;margin-bottom:1rem;opacity:.3;"></i>
                            <p>No notifications sent yet.</p>
                            <p class="small">Create and send a notification to see history.</p>
                            <button class="btn btn-sm btn-msm mt-2" onclick="document.getElementById('notifTitle').focus()">Create First</button>
                        </div>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-12 animate-in">
            <div class="msm-card">
                <div class="table-toolbar">
                    <h6 class="mb-0 fw-bold">Notification Templates</h6>
                    <button class="btn btn-sm btn-msm" onclick="showTemplateModal()"><i class="bi bi-plus-lg me-1"></i>Save Current as Template</button>
                </div>
                <div class="table-responsive">
                    <table class="table msm-table align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Title</th>
                                <th>Message</th>
                                <th>Type</th>
                                <th style="width:100px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="templateBody">
                            <tr>
                                <td colspan="4">
                                    <div class="empty-state py-4">
                                        <i class="bi bi-file-text"></i>
                                        <p>No templates saved.</p>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="p-3 text-center">
                    <button class="btn btn-sm btn-msm" onclick="fillPreset('flash_sale')"><i class="bi bi-lightning me-1"></i>Flash Sale</button>
                    <button class="btn btn-sm btn-msm-outline ms-2" onclick="fillPreset('welcome')"><i class="bi bi-emoji-smile me-1"></i>Welcome</button>
                    <button class="btn btn-sm btn-msm-outline ms-2" onclick="fillPreset('restock')"><i class="bi bi-box-seam me-1"></i>Back in Stock</button>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3" id="notifToastContainer" style="z-index:9999;"></div>

<script>
var MSM_JWT = '<?php echo session_get_jwt(); ?>';
var sentLog = <?php echo json_encode($notifList); ?>;
var mode = 'broadcast';

function apiFetch(method, url, body, onSuccess, onError) {
    var xhr = new XMLHttpRequest();
    xhr.open(method, url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.setRequestHeader('Authorization', 'Bearer ' + MSM_JWT);
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return;
        try { var res = JSON.parse(xhr.responseText); if (xhr.status >= 200 && xhr.status < 300) { if (onSuccess) onSuccess(res); } else { if (onError) onError(res); } } catch(e) { if (onError) onError({message:'Invalid response.'}); }
    };
    xhr.onerror = function() { if (onError) onError({message:'Network error.'}); };
    xhr.send(body ? JSON.stringify(body) : null);
}

function showToast(msg, type) {
    type = type||'success'; var bg = type==='danger'?'bg-danger':type==='warning'?'bg-warning text-dark':'bg-success'; var icon = type==='danger'?'bi-x-circle':type==='warning'?'bi-exclamation-circle':'bi-check-circle';
    var c = document.getElementById('notifToastContainer'); var el = document.createElement('div');
    el.className = 'toast align-items-center text-white border-0 '+bg;
    el.setAttribute('role','alert');
    el.innerHTML = '<div class="d-flex"><div class="toast-body"><i class="bi '+icon+' me-2"></i>'+msg+'</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>';
    c.appendChild(el);
    var t = new bootstrap.Toast(el,{autohide:true,delay:4000}); t.show(); el.addEventListener('hidden.bs.toast',function(){el.remove();});
}

function escapeHtml(s) {
    if (!s) return ''; var d = document.createElement('div'); d.appendChild(document.createTextNode(s)); return d.innerHTML;
}

function switchMode(newMode) {
    mode = newMode;
    document.querySelectorAll('[style*="cursor:pointer"]').forEach(function(b) {
        if (b.id && b.id.startsWith('mode')) { b.className = 'badge bg-secondary bg-opacity-25 text-dark p-2 px-4'; }
    });
    var el = document.getElementById('mode' + newMode.charAt(0).toUpperCase() + newMode.slice(1));
    if (el) el.className = 'badge bg-primary p-2 px-4';
    document.getElementById('userSelectSection').style.display = newMode === 'specific' ? 'block' : 'none';
    document.getElementById('scheduleSection').style.display = newMode === 'schedule' ? 'block' : 'none';
}

document.getElementById('notifMessage').addEventListener('input', function() {
    document.getElementById('charCount').textContent = Math.min(this.value.length, 500);
    if (this.value.length > 500) this.value = this.value.substring(0, 500);
});

var searchTimeout = null;
document.getElementById('userSearch').addEventListener('input', function() {
    var q = this.value.trim();
    var sel = document.getElementById('userSelect');
    if (q.length < 2) { sel.style.display = 'none'; return; }
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(function() {
        apiFetch('GET', '<?php echo API_ADMIN_CUSTOMERS; ?>?search=' + encodeURIComponent(q), null, function(data) {
            var users = Array.isArray(data) ? data : [];
            if (users.length === 0) {
                sel.innerHTML = '<option disabled>No users found</option>';
            } else {
                sel.innerHTML = users.map(function(u) {
                    return '<option value="' + u._id + '">' + escapeHtml(u.fullName) + ' (' + escapeHtml(u.email) + ')</option>';
                }).join('');
            }
            sel.style.display = 'block';
        }, function() {
            sel.innerHTML = '<option disabled>Search failed</option>';
            sel.style.display = 'block';
        });
    }, 300);
});

function sendNotification(e) {
    e.preventDefault();
    var title = document.getElementById('notifTitle').value.trim();
    var message = document.getElementById('notifMessage').value.trim();
    if (!title || !message) { showToast('Title and message are required.', 'warning'); return; }

    var btn = document.getElementById('sendNotifBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Sending...';

    var data = { title: title, message: message, type: document.getElementById('notifType').value, category: document.getElementById('notifCategory').value, priority: document.getElementById('notifPriority').value };

    if (mode === 'specific') {
        var sel = document.getElementById('userSelect');
        if (sel.value) data.userId = sel.value;
        data.broadcast = false;
    } else if (mode === 'schedule') {
        var sched = document.getElementById('notifSchedule').value;
        if (sched) data.scheduledAt = sched;
        data.broadcast = true;
    } else {
        data.broadcast = true;
    }

    var extra = document.getElementById('notifData').value.trim();
    if (extra) { try { data.data = JSON.parse(extra); } catch(err) { data.data = extra; } }

    apiFetch('POST', '<?php echo API_ADMIN_NOTIFICATIONS; ?>', data, function(res) {
        showToast('Notification sent successfully.');
        if (res.data) {
            sentLog.unshift({
                _id: res.data._id,
                title: title,
                message: message,
                type: data.type || 'push',
                broadcast: data.broadcast !== false,
                userId: res.data.userId || null,
                createdAt: new Date().toISOString(),
                isRead: false
            });
        }
        renderLog();
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-send me-2"></i>Send Notification';
        document.getElementById('notifForm').reset();
    }, function(err) {
        showToast(err && err.message ? err.message : 'Failed to send notification.', 'danger');
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-send me-2"></i>Send Notification';
    });
    return false;
}

function renderLog() {
    var feed = document.getElementById('notificationFeed');
    if (!sentLog || sentLog.length === 0) {
        feed.innerHTML = '<div class="text-center text-muted py-5"><i class="bi bi-bell-slash" style="font-size:2rem;display:block;margin-bottom:1rem;opacity:.3;"></i><p>No notifications sent yet.</p><p class="small">Create and send a notification to see history.</p></div>';
        return;
    }
    var q = (document.getElementById('logSearch').value||'').toLowerCase();
    var filtered = q ? sentLog.filter(function(e) { return (e.title||'').toLowerCase().indexOf(q) !== -1 || (e.message||'').toLowerCase().indexOf(q) !== -1; }) : sentLog;

    var h = '';
    filtered.forEach(function(e) {
        var typeIcon = e.type === 'sms' ? 'bi-chat-dots' : (e.type === 'email' ? 'bi-envelope' : 'bi-bell');
        var typeColor = e.type === 'sms' ? 'text-primary' : (e.type === 'email' ? 'text-info' : 'text-warning');
        var broadcastTag = e.broadcast ? '<span class="badge bg-primary" style="font-size:0.6rem;">Broadcast</span>' : '<span class="badge bg-secondary" style="font-size:0.6rem;">Direct</span>';
        var time = e.createdAt ? MSM.timeAgo(e.createdAt) : 'Just now';

        h += '<div class="activity-item">';
        h += '<div class="activity-avatar-placeholder text-light ' + typeColor + ' bg-opacity-25" style="height:36px;width:36px;"><i class="bi ' + typeIcon + '"></i></div>';
        h += '<div class="activity-content"><div class="activity-title">' + escapeHtml(e.title) + ' ' + broadcastTag + '</div>';
        h += '<div class="activity-sub" style="font-size:0.78rem;">' + escapeHtml(e.message) + '</div></div>';
        h += '<div class="activity-time">' + time + '</div></div>';
    });
    feed.innerHTML = h;
}

function filterLog() { renderLog(); }

function refreshLog() { renderLog(); showToast('Log refreshed.'); }

var templates = [];

function fillPreset(name) {
    var presets = {
        flash_sale: { title: 'Flash Sale Alert! 🚀', message: 'Get up to 50% OFF on selected spices and seasonings. Limited time offer, grab yours before they run out!', type: 'push' },
        welcome: { title: 'Welcome to My SpiceMarket!', message: 'Thank you for joining us! Enjoy 20% off your first order with code WELCOME20.', type: 'email' },
        restock: { title: 'Back in Stock!', message: 'Items you love are back in stock. Shop now before they sell out again.', type: 'push' }
    };
    var p = presets[name];
    if (!p) return;
    document.getElementById('notifTitle').value = p.title;
    document.getElementById('notifMessage').value = p.message;
    document.getElementById('notifType').value = p.type;
    document.getElementById('charCount').textContent = p.message.length;
}

function showTemplateModal() {
    var title = document.getElementById('notifTitle').value.trim();
    var msg = document.getElementById('notifMessage').value.trim();
    if (!title || !msg) { showToast('Fill in the form first.', 'warning'); return; }
    templates.push({ title: title, message: msg, type: document.getElementById('notifType').value });
    renderTemplates();
    showToast('Template saved.');
}

function renderTemplates() {
    var tb = document.getElementById('templateBody');
    if (templates.length === 0) {
        tb.innerHTML = '<tr><td colspan="4"><div class="empty-state py-3"><i class="bi bi-file-text"></i><p>No templates.</p></div></td></tr>';
        return;
    }
    var h = '';
    templates.forEach(function(t, idx) {
        h += '<tr><td style="font-weight:500;">' + escapeHtml(t.title) + '</td><td style="font-size:0.82rem;">' + escapeHtml(t.message.substring(0,60)) + (t.message.length > 60 ? '...' : '') + '</td><td><span class="badge badge-status bg-info text-dark small">'+t.type+'</span></td>';
        h += '<td><button class="btn btn-sm btn-outline-primary" onclick="applyTemplate('+idx+')">Use</button></td></tr>';
    });
    tb.innerHTML = h;
}

function applyTemplate(idx) {
    var t = templates[idx];
    if (!t) return;
    document.getElementById('notifForm').reset();
    document.getElementById('notifTitle').value = t.title;
    document.getElementById('notifMessage').value = t.message;
    document.getElementById('notifType').value = t.type || 'push';
    document.getElementById('charCount').textContent = t.message.length;
}

document.addEventListener('DOMContentLoaded', function() {
    renderLog();
    MSM.initSearch('<?php echo API_ADMIN_SEARCH; ?>');
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
