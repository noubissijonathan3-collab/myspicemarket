<?php
/**
 * Orders Management
 *
 * Full order lifecycle: list, filter, search, view details, change status,
 * and assign riders.  All data fetched via AJAX with JWT in session.
 */

$currentPage = 'orders';
$pageTitle   = 'Orders';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt = session_get_jwt();

include __DIR__ . '/../../includes/header.php';
include __DIR__ . '/../../includes/sidebar.php';
include __DIR__ . '/../../includes/loader.php';
?>

<div class="sidebar-overlay" id="sidebarOverlay" onclick="MSM.toggleSidebar()"></div>

<div class="admin-content">

    <!-- ═══════ TOP NAVBAR ═══════ -->
    <div class="admin-navbar">
        <div class="navbar-left">
            <button class="btn btn-sm d-lg-none" onclick="MSM.toggleSidebar()" style="font-size:1.2rem;color:var(--msm-muted);">
                <i class="bi bi-list"></i>
            </button>
            <div class="navbar-brand-text"><span><?php echo $pageTitle; ?></span></div>
        </div>
        <div class="navbar-right">
            <div style="position:relative;">
                <button class="navbar-icon-btn" onclick="MSM.toggleDropdown('notifDropdown')" title="Notifications">
                    <i class="bi bi-bell"></i>
                </button>
                <div class="notification-dropdown" id="notifDropdown">
                    <div class="notif-header"><h6>Notifications</h6></div>
                    <div class="notif-list"><div class="notif-item"><div class="notif-content"><div class="notif-title">No new notifications</div></div></div></div>
                </div>
            </div>
            <div style="position:relative;">
                <img src="<?php echo htmlspecialchars($adminAvatar); ?>" alt="Admin" class="profile-avatar" onerror="this.src='https://ui-avatars.com/api/?name=<?php echo urlencode($adminName); ?>&background=198754&color=fff&size=36'" onclick="MSM.toggleDropdown('profileDropdown')">
                <div class="profile-dropdown" id="profileDropdown">
                    <div style="padding:0.75rem 1rem;border-bottom:1px solid var(--msm-border);">
                        <div style="font-weight:600;font-size:0.85rem;"><?php echo htmlspecialchars($adminName); ?></div>
                        <div style="font-size:0.75rem;color:var(--msm-muted);"><?php echo htmlspecialchars($adminEmail); ?></div>
                    </div>
                    <a href="<?php echo admin_url('pages/profile/profile.php'); ?>"><i class="bi bi-person"></i> Profile</a>
                    <a href="<?php echo admin_url('pages/settings/settings.php'); ?>"><i class="bi bi-gear"></i> Settings</a>
                    <div class="dropdown-divider" style="border-top:1px solid var(--msm-border);"></div>
                    <a href="<?php echo admin_url('auth/logout.php'); ?>" class="logout-link"><i class="bi bi-box-arrow-right"></i> Logout</a>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══════ STAT CARDS ═══════ -->
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-2 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#6c757d,#5a6268);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Total Orders</div>
                        <div class="stat-value" id="statTotal" data-count="0">0</div>
                    </div>
                    <div class="stat-icon bg-secondary bg-opacity-10 text-secondary">
                        <i class="bi bi-cart-check"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-2 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#6c757d,#5a6268);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Pending</div>
                        <div class="stat-value text-secondary" id="statPending" data-count="0">0</div>
                    </div>
                    <div class="stat-icon bg-secondary bg-opacity-10 text-secondary">
                        <i class="bi bi-hourglass-split"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-2 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Preparing</div>
                        <div class="stat-value" style="color:#e0a800;" id="statPreparing" data-count="0">0</div>
                    </div>
                    <div class="stat-icon bg-warning bg-opacity-10 text-warning">
                        <i class="bi bi-fire"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-2 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0d6efd,#0b5ed7);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Out for Delivery</div>
                        <div class="stat-value" style="color:#0d6efd;" id="statOutForDelivery" data-count="0">0</div>
                    </div>
                    <div class="stat-icon bg-primary bg-opacity-10 text-primary">
                        <i class="bi bi-truck"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-2 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Delivered</div>
                        <div class="stat-value text-success" id="statDelivered" data-count="0">0</div>
                    </div>
                    <div class="stat-icon bg-success bg-opacity-10 text-success">
                        <i class="bi bi-check-circle"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-2 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#dc3545,#b02a37);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Cancelled</div>
                        <div class="stat-value text-danger" id="statCancelled" data-count="0">0</div>
                    </div>
                    <div class="stat-icon bg-danger bg-opacity-10 text-danger">
                        <i class="bi bi-x-circle"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══════ STATUS FILTER TABS ═══════ -->
    <div class="msm-card mb-4 animate-in">
        <div class="table-toolbar" style="flex-wrap:wrap;gap:0.75rem;">
            <div class="d-flex align-items-center gap-2 flex-wrap" id="statusTabs">
                <button class="btn btn-sm btn-msm active" data-status="">All</button>
                <button class="btn btn-sm btn-outline-secondary" data-status="Pending">Pending</button>
                <button class="btn btn-sm btn-outline-info" data-status="Confirmed">Confirmed</button>
                <button class="btn btn-sm btn-outline-warning" data-status="Preparing">Preparing</button>
                <button class="btn btn-sm btn-outline-success" data-status="Ready">Ready</button>
                <button class="btn btn-sm btn-outline-primary" data-status="Out for Delivery">Out for Delivery</button>
                <button class="btn btn-sm btn-outline-purple" data-status="On Route" style="border-color:#6f42c1;color:#6f42c1;">On Route</button>
                <button class="btn btn-sm btn-outline-success" data-status="Delivered">Delivered</button>
                <button class="btn btn-sm btn-outline-danger" data-status="Cancelled">Cancelled</button>
            </div>
            <div class="d-flex align-items-center gap-2">
                <div class="input-group input-group-sm" style="width:260px;">
                    <span class="input-group-text bg-transparent"><i class="bi bi-search"></i></span>
                    <input type="text" class="form-control" id="orderSearch" placeholder="Search order ID or customer...">
                </div>
                <button class="btn btn-sm btn-outline-secondary" id="btnRefresh" title="Refresh">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
            </div>
        </div>
    </div>

    <!-- ═══════ ORDERS TABLE ═══════ -->
    <div class="msm-card p-0 animate-in">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Order ID</th>
                        <th>Customer</th>
                        <th>Items</th>
                        <th>Total</th>
                        <th>Agent</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody id="ordersTableBody">
                    <tr>
                        <td colspan="8">
                            <div class="empty-state py-5">
                                <div class="spinner-border text-success" role="status"></div>
                                <p class="mt-2">Loading orders...</p>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

</div>

<!-- ═══════ ORDER DETAIL MODAL ═══════ -->
<div class="modal fade" id="orderDetailModal" tabindex="-1" aria-labelledby="orderDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold" id="orderDetailModalLabel">Order Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="orderDetailBody">
                <div class="text-center py-4">
                    <div class="spinner-border text-success"></div>
                    <p class="mt-2 text-muted">Loading order details...</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ═══════ ASSIGN RIDER MODAL ═══════ -->
<div class="modal fade" id="assignRiderModal" tabindex="-1" aria-labelledby="assignRiderModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold" id="assignRiderModalLabel">Assign Rider</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="assignRiderOrderId">
                <p class="text-muted mb-3" id="assignRiderOrderLabel">Select a rider for this order.</p>
                <div class="mb-3">
                    <label for="riderSelect" class="form-label fw-semibold">Rider</label>
                    <select class="form-select" id="riderSelect">
                        <option value="">-- Select Rider --</option>
                    </select>
                </div>
                <div id="riderListContainer"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-msm btn-sm" id="btnConfirmAssignRider">
                    <i class="bi bi-check-lg me-1"></i> Assign Rider
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ═══════ STATUS CHANGE CONFIRMATION MODAL ═══════ -->
<div class="modal fade" id="statusChangeModal" tabindex="-1" aria-labelledby="statusChangeModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold" id="statusChangeModalLabel">Confirm Status Change</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="statusChangeOrderId">
                <input type="hidden" id="statusChangeNewStatus">
                <div class="d-flex align-items-center gap-3 p-3 rounded" style="background:var(--msm-bg);">
                    <div class="text-center">
                        <div class="badge badge-status mb-1" id="statusChangeFrom" style="font-size:0.8rem;">Current</div>
                        <div class="small text-muted">Current</div>
                    </div>
                    <i class="bi bi-arrow-right fs-4 text-muted"></i>
                    <div class="text-center">
                        <div class="badge badge-status mb-1" id="statusChangeTo" style="font-size:0.8rem;">New</div>
                        <div class="small text-muted">New Status</div>
                    </div>
                </div>
                <p class="mt-3 mb-0 text-muted" id="statusChangeMessage">Are you sure you want to change the order status?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-msm btn-sm" id="btnConfirmStatusChange">
                    <i class="bi bi-check-lg me-1"></i> Confirm Change
                </button>
            </div>
        </div>
    </div>
</div>


<script>
(function() {
    /* ─── Config ────────────────────────────────────────── */
    var JWT = '<?php echo addslashes($jwt); ?>';
    var ORDERS_URL = '<?php echo API_ADMIN_ORDERS; ?>';
    var RIDERS_URL = '<?php echo API_ADMIN_RIDERS; ?>';
    var API_BASE_URL = '<?php echo API_BASE_URL; ?>';

    /* ─── State ─────────────────────────────────────────── */
    var allOrders = [];
    var currentFilter = '';
    var searchQuery = '';
    var riders = [];

    /* ─── Status helpers ────────────────────────────────── */
    var STATUS_ORDER = ['Pending','Confirmed','Preparing','Ready','Out for Delivery','On Route','Delivered','Cancelled'];
    var STATUS_BADGE = {
        'Pending':          'bg-secondary',
        'Confirmed':        'bg-info text-dark',
        'Preparing':        'bg-warning text-dark',
        'Ready':            'bg-success',
        'Out for Delivery': 'bg-primary',
        'On Route':         'text-bg-dark',
        'Delivered':        'bg-success',
        'Cancelled':        'bg-danger'
    };
    var STATUS_NEXT = {
        'Pending':          'Confirmed',
        'Confirmed':        'Preparing',
        'Preparing':        'Ready',
        'Ready':            'Out for Delivery',
        'Out for Delivery': 'On Route',
        'On Route':         'Delivered'
    };

    /* ─── Fetch helpers ─────────────────────────────────── */
    function apiFetch(url, method, body) {
        var opts = {
            method: method || 'GET',
            headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' }
        };
        if (JWT) opts.headers['Authorization'] = 'Bearer ' + JWT;
        if (body) opts.body = JSON.stringify(body);
        return fetch(url, opts).then(function(r) {
            if (!r.ok) throw new Error('HTTP ' + r.status);
            return r.json();
        });
    }

    /* ─── Render orders table ───────────────────────────── */
    function renderOrders() {
        var filtered = allOrders;
        if (currentFilter) {
            filtered = filtered.filter(function(o) { return o.status === currentFilter; });
        }
        if (searchQuery) {
            var q = searchQuery.toLowerCase();
            filtered = filtered.filter(function(o) {
                var oid = (o._id || o.id || '').toLowerCase();
                var name = ((o.userId && o.userId.fullName) || '').toLowerCase();
                var agent = ((o.deliveryAgent && o.deliveryAgent.fullName) || '').toLowerCase();
                return oid.indexOf(q) !== -1 || name.indexOf(q) !== -1 || agent.indexOf(q) !== -1;
            });
        }

        var tbody = document.getElementById('ordersTableBody');
        if (!filtered.length) {
            tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state py-5"><i class="bi bi-cart-x"></i><p>No orders found.</p></div></td></tr>';
            return;
        }

        var html = '';
        filtered.forEach(function(order) {
            var oid = order._id || order.id || '';
            var shortId = '#' + oid.slice(-6);
            var customer = (order.userId && order.userId.fullName) ? order.userId.fullName : 'N/A';
            var itemCount = (order.items && order.items.length) ? order.items.length : (order.itemCount || 0);
            var total = MSM.formatCurrency(order.total || 0);
            var status = order.status || 'Pending';
            var badge = STATUS_BADGE[status] || 'bg-secondary';
            var date = MSM.timeAgo(order.createdAt);
            var agentName = (order.deliveryAgent && order.deliveryAgent.fullName) ? order.deliveryAgent.fullName : '<span class="text-muted">—</span>';

            html += '<tr class="order-row" data-id="' + oid + '">';
            html += '<td><span class="fw-semibold" style="font-size:0.85rem;">' + shortId + '</span></td>';
            html += '<td>';
            html += '<div class="d-flex align-items-center gap-2">';
            html += '<div class="activity-avatar-placeholder" style="width:32px;height:32px;font-size:0.7rem;background:#198754;">' + customer.charAt(0).toUpperCase() + '</div>';
            html += '<span>' + MSM.truncate(customer, 25) + '</span>';
            html += '</div></td>';
            html += '<td><span class="badge bg-light text-dark">' + itemCount + ' item' + (itemCount !== 1 ? 's' : '') + '</span></td>';
            html += '<td class="fw-semibold">' + total + '</td>';
            html += '<td><span class="small">' + agentName + '</span></td>';
            html += '<td><span class="badge ' + badge + ' badge-status">' + status + '</span></td>';
            html += '<td class="text-muted small">' + date + '</td>';
            html += '<td class="text-end">';
            html += '<div class="d-flex align-items-center justify-content-end gap-1">';

            /* View Details */
            html += '<button class="btn btn-sm btn-outline-secondary btn-view-order" data-id="' + oid + '" title="View Details"><i class="bi bi-eye"></i></button>';

            /* Status Change */
            if (STATUS_NEXT[status]) {
                var nextStatus = STATUS_NEXT[status];
                html += '<button class="btn btn-sm btn-outline-primary btn-change-status" data-id="' + oid + '" data-next="' + nextStatus + '" title="Mark as ' + nextStatus + '"><i class="bi bi-arrow-right-circle"></i></button>';
            }

            /* Cancel (from any non-terminal state) */
            if (status !== 'Delivered' && status !== 'Cancelled') {
                html += '<button class="btn btn-sm btn-outline-danger btn-cancel-order" data-id="' + oid + '" title="Cancel Order"><i class="bi bi-x-lg"></i></button>';
            }

            /* Assign Rider (for orders without agent) */
            if ((status === 'Pending' || status === 'Confirmed' || status === 'Ready' || status === 'Out for Delivery') && !order.deliveryAgent) {
                html += '<button class="btn btn-sm btn-outline-success btn-assign-rider" data-id="' + oid + '" title="Assign Rider"><i class="bi bi-bicycle"></i></button>';
            }

            html += '</div></td>';
            html += '</tr>';
        });
        tbody.innerHTML = html;

        attachRowEvents();
    }

    /* ─── Update stats from all orders ──────────────────── */
    function updateStats() {
        var counts = { total: allOrders.length, Pending: 0, Confirmed: 0, Preparing: 0, Ready: 0, 'Out for Delivery': 0, 'On Route': 0, Delivered: 0, Cancelled: 0 };
        allOrders.forEach(function(o) {
            if (counts.hasOwnProperty(o.status)) counts[o.status]++;
        });
        setText('statTotal', counts.total);
        setText('statPending', counts.Pending);
        setText('statPreparing', counts.Preparing + counts.Confirmed);
        setText('statOutForDelivery', counts['Out for Delivery'] + counts['On Route'] + counts.Ready);
        setText('statDelivered', counts.Delivered);
        setText('statCancelled', counts.Cancelled);

        document.querySelectorAll('[data-count]').forEach(function(el) {
            var val = parseInt(el.textContent.replace(/,/g,''), 10);
            if (!isNaN(val)) el.setAttribute('data-count', val);
        });
        MSM.initCounters();
    }

    function setText(id, val) {
        var el = document.getElementById(id);
        if (el) el.textContent = val;
    }

    /* ─── Load all orders ───────────────────────────────── */
    function loadOrders() {
        apiFetch(ORDERS_URL, 'GET')
            .then(function(res) {
                allOrders = Array.isArray(res) ? res : (res.orders || res.data || []);
                updateStats();
                renderOrders();
            })
            .catch(function(err) {
                console.error('Failed to load orders:', err);
                document.getElementById('ordersTableBody').innerHTML =
                    '<tr><td colspan="8"><div class="empty-state py-5"><i class="bi bi-exclamation-triangle text-warning"></i><p>Failed to load orders. Please try again.</p><button class="btn btn-sm btn-msm mt-2" onclick="document.getElementById(\'btnRefresh\').click()"><i class="bi bi-arrow-clockwise me-1"></i> Retry</button></div></td></tr>';
            });
    }

    /* ─── Load riders ───────────────────────────────────── */
    function loadRiders() {
        var ridersSelectUrl = API_BASE_URL + '/admin/riders-select';
        apiFetch(ridersSelectUrl, 'GET')
            .then(function(res) {
                riders = Array.isArray(res) ? res : (res.riders || res.data || []);
                var sel = document.getElementById('riderSelect');
                sel.innerHTML = '<option value="">-- Select Rider --</option>';
                riders.forEach(function(r) {
                    var name = r.fullName || r.name || 'Rider';
                    var phone = r.phone ? ' (' + r.phone + ')' : '';
                    var opt = document.createElement('option');
                    opt.value = r._id || r.id;
                    opt.textContent = name + phone;
                    sel.appendChild(opt);
                });
                if (riders.length === 0) {
                    showToast('warning', 'No delivery agents found. Please add riders first.');
                }
            })
            .catch(function(err) {
                console.error('Failed to load riders:', err);
                showToast('error', 'Failed to load riders. Please refresh the page.');
            });
    }

    /* ─── Load single order details ─────────────────────── */
    function loadOrderDetail(orderId) {
        var body = document.getElementById('orderDetailBody');
        body.innerHTML = '<div class="text-center py-4"><div class="spinner-border text-success"></div><p class="mt-2 text-muted">Loading...</p></div>';

        var bsModal = bootstrap.Modal.getOrCreateInstance(document.getElementById('orderDetailModal'));
        bsModal.show();

        apiFetch(ORDERS_URL + '/' + orderId, 'GET')
            .then(function(data) {
                var order = data.order || data;
                var items = data.items || order.items || [];
                order.items = items;
                renderOrderDetail(order);
            })
            .catch(function() {
                body.innerHTML = '<div class="text-center py-4"><i class="bi bi-exclamation-triangle text-danger fs-1"></i><p class="mt-2">Failed to load order details.</p></div>';
            });
    }

    /* ─── Render order detail inside modal ──────────────── */
    function renderOrderDetail(order) {
        var body = document.getElementById('orderDetailBody');
        var oid = order._id || order.id || '';
        var status = order.status || 'Pending';
        var badge = STATUS_BADGE[status] || 'bg-secondary';
        var customer = order.userId || {};
        var delivery = order.delivery || {};
        var items = order.items || [];

        var html = '';

        /* Status Progress Bar */
        var statusSteps = ['Pending','Confirmed','Preparing','Ready','Out for Delivery','On Route','Delivered'];
        var currentIdx = statusSteps.indexOf(status);
        if (status === 'Cancelled') currentIdx = -1;
        html += '<div class="mb-4">';
        html += '<div class="d-flex align-items-center justify-content-between mb-2">';
        statusSteps.forEach(function(step, i) {
            var cls = (currentIdx >= 0 && i <= currentIdx) ? 'text-success fw-bold' : 'text-muted';
            html += '<div class="text-center ' + cls + '" style="flex:1;font-size:0.7rem;">';
            html += '<div class="rounded-circle mx-auto mb-1 d-flex align-items-center justify-content-center ' + (currentIdx >= 0 && i <= currentIdx ? 'bg-success text-white' : 'bg-light text-muted') + '" style="width:28px;height:28px;font-size:0.65rem;">' + (i + 1) + '</div>';
            html += step;
            html += '</div>';
        });
        html += '</div>';
        html += '<div class="progress" style="height:4px;">';
        var pct = currentIdx >= 0 ? ((currentIdx / (statusSteps.length - 1)) * 100) : 0;
        html += '<div class="progress-bar bg-success" style="width:' + pct + '%;"></div>';
        html += '</div>';
        if (status === 'Cancelled') {
            html += '<div class="text-center mt-2"><span class="badge bg-danger">Order Cancelled</span></div>';
        }
        html += '</div>';

        /* Order Info */
        html += '<div class="row g-3 mb-4">';
        html += '<div class="col-md-6">';
        html += '<div class="p-3 rounded" style="background:var(--msm-bg);">';
        html += '<h6 class="fw-bold mb-3"><i class="bi bi-receipt me-2"></i>Order Information</h6>';
        html += '<div class="mb-2"><span class="text-muted small">Order ID:</span><br><span class="fw-semibold">#' + oid.slice(-6) + '</span></div>';
        html += '<div class="mb-2"><span class="text-muted small">Date:</span><br><span class="fw-semibold">' + MSM.formatDateTime(order.createdAt) + '</span></div>';
        html += '<div class="mb-2"><span class="text-muted small">Status:</span><br><span class="badge ' + badge + ' badge-status">' + status + '</span></div>';
        html += '<div><span class="text-muted small">Total:</span><br><span class="fw-bold fs-5 text-success">' + MSM.formatCurrency(order.total || 0) + '</span></div>';
        html += '</div></div>';

        /* Customer Info */
        html += '<div class="col-md-6">';
        html += '<div class="p-3 rounded" style="background:var(--msm-bg);">';
        html += '<h6 class="fw-bold mb-3"><i class="bi bi-person me-2"></i>Customer Information</h6>';
        html += '<div class="mb-2"><span class="text-muted small">Name:</span><br><span class="fw-semibold">' + MSM.truncate(customer.fullName || 'N/A', 40) + '</span></div>';
        html += '<div class="mb-2"><span class="text-muted small">Email:</span><br><span class="fw-semibold">' + MSM.truncate(customer.email || 'N/A', 35) + '</span></div>';
        html += '<div><span class="text-muted small">Phone:</span><br><span class="fw-semibold">' + (customer.phone || 'N/A') + '</span></div>';
        html += '</div></div>';
        html += '</div>';

        /* Delivery Info */
        if (delivery.address || delivery.receiver) {
            html += '<div class="p-3 rounded mb-4" style="background:var(--msm-bg);">';
            html += '<h6 class="fw-bold mb-3"><i class="bi bi-geo-alt me-2"></i>Delivery Information</h6>';
            html += '<div class="row g-3">';
            html += '<div class="col-md-4"><span class="text-muted small">Receiver:</span><br><span class="fw-semibold">' + MSM.truncate(delivery.receiver || 'N/A', 30) + '</span></div>';
            html += '<div class="col-md-4"><span class="text-muted small">Phone:</span><br><span class="fw-semibold">' + (delivery.phone || 'N/A') + '</span></div>';
            html += '<div class="col-md-4"><span class="text-muted small">Address:</span><br><span class="fw-semibold">' + MSM.truncate(delivery.address || 'N/A', 40) + '</span></div>';
            html += '</div></div>';
        }

        /* Assigned Agent Info */
        var agent = order.deliveryAgent || {};
        if (agent.fullName) {
            html += '<div class="p-3 rounded mb-4" style="background:var(--msm-bg);">';
            html += '<h6 class="fw-bold mb-3"><i class="bi bi-bicycle me-2"></i>Assigned Agent</h6>';
            html += '<div class="row g-3">';
            html += '<div class="col-md-4"><span class="text-muted small">Name:</span><br><span class="fw-semibold">' + MSM.truncate(agent.fullName || 'N/A', 30) + '</span></div>';
            html += '<div class="col-md-4"><span class="text-muted small">Phone:</span><br><span class="fw-semibold">' + (agent.phone || 'N/A') + '</span></div>';
            html += '<div class="col-md-4"><span class="text-muted small">Email:</span><br><span class="fw-semibold">' + MSM.truncate(agent.email || 'N/A', 35) + '</span></div>';
            if (order.deliveryStatus) {
                html += '<div class="col-md-4"><span class="text-muted small">Delivery Status:</span><br><span class="badge bg-dark">' + order.deliveryStatus + '</span></div>';
            }
            if (order.pickupTime) {
                html += '<div class="col-md-4"><span class="text-muted small">Picked Up:</span><br><span class="fw-semibold">' + MSM.formatDateTime(order.pickupTime) + '</span></div>';
            }
            if (order.deliveryTime) {
                html += '<div class="col-md-4"><span class="text-muted small">Delivered:</span><br><span class="fw-semibold">' + MSM.formatDateTime(order.deliveryTime) + '</span></div>';
            }
            html += '</div></div>';
        } else if (status !== 'Delivered' && status !== 'Cancelled') {
            html += '<div class="p-3 rounded mb-4" style="background:var(--msm-bg);">';
            html += '<h6 class="fw-bold mb-3"><i class="bi bi-bicycle me-2"></i>Assigned Agent</h6>';
            html += '<div class="text-muted small"><i class="bi bi-info-circle me-1"></i> No agent assigned yet. Use the bicycle icon to assign a rider.</div>';
            html += '</div>';
        }

        /* Items Table */
        html += '<h6 class="fw-bold mb-3"><i class="bi bi-bag me-2"></i>Order Items</h6>';
        if (items.length) {
            html += '<div class="table-responsive"><table class="table table-sm align-middle mb-0">';
            html += '<thead class="table-light"><tr><th>Product</th><th class="text-center">Qty</th><th class="text-end">Unit Price</th><th class="text-end">Subtotal</th></tr></thead>';
            html += '<tbody>';
            items.forEach(function(item) {
                var food = item.foodstuffId || {};
                var name = food.name || item.name || 'Product';
                var img = food.image || item.image || '';
                var qty = item.quantity || 1;
                var price = item.price || 0;
                var lineTotal = qty * price;
                html += '<tr>';
                html += '<td><div class="d-flex align-items-center gap-2">';
                if (img) {
                    html += '<img src="' + msmImgUrl(img) + '" alt="" style="width:36px;height:36px;object-fit:cover;border-radius:6px;">';
                } else {
                    html += '<div style="width:36px;height:36px;border-radius:6px;background:var(--msm-bg);display:flex;align-items:center;justify-content:center;"><i class="bi bi-box-seam text-muted"></i></div>';
                }
                html += '<span class="fw-semibold">' + MSM.truncate(name, 30) + '</span>';
                html += '</div></td>';
                html += '<td class="text-center">' + qty + '</td>';
                html += '<td class="text-end">' + MSM.formatCurrency(price) + '</td>';
                html += '<td class="text-end fw-semibold">' + MSM.formatCurrency(lineTotal) + '</td>';
                html += '</tr>';
            });
            html += '</tbody></table></div>';
        } else {
            html += '<div class="empty-state py-3"><i class="bi bi-bag-x"></i><p>No item details available.</p></div>';
        }

        body.innerHTML = html;
    }

    /* ─── Status change flow ────────────────────────────── */
    function openStatusChange(orderId, newStatus) {
        var order = allOrders.find(function(o) { return (o._id || o.id) === orderId; });
        if (!order) return;

        document.getElementById('statusChangeOrderId').value = orderId;
        document.getElementById('statusChangeNewStatus').value = newStatus;

        var fromEl = document.getElementById('statusChangeFrom');
        var toEl = document.getElementById('statusChangeTo');
        fromEl.textContent = order.status;
        fromEl.className = 'badge badge-status mb-1 ' + (STATUS_BADGE[order.status] || 'bg-secondary');
        toEl.textContent = newStatus;
        toEl.className = 'badge badge-status mb-1 ' + (STATUS_BADGE[newStatus] || 'bg-secondary');

        document.getElementById('statusChangeMessage').textContent =
            'Are you sure you want to change order #' + orderId.slice(-6) + ' status from "' + order.status + '" to "' + newStatus + '"?';

        var bsModal = bootstrap.Modal.getOrCreateInstance(document.getElementById('statusChangeModal'));
        bsModal.show();
    }

    function confirmStatusChange() {
        var orderId = document.getElementById('statusChangeOrderId').value;
        var newStatus = document.getElementById('statusChangeNewStatus').value;
        if (!orderId || !newStatus) return;

        var btn = document.getElementById('btnConfirmStatusChange');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Updating...';

        apiFetch(ORDERS_URL + '/' + orderId + '/status', 'PUT', { status: newStatus })
            .then(function() {
                bootstrap.Modal.getOrCreateInstance(document.getElementById('statusChangeModal')).hide();
                showToast('success', 'Order status updated to "' + newStatus + '".');
                loadOrders();
            })
            .catch(function(err) {
                showToast('error', 'Failed to update status. ' + (err.message || ''));
            })
            .finally(function() {
                btn.disabled = false;
                btn.innerHTML = '<i class="bi bi-check-lg me-1"></i> Confirm Change';
            });
    }

    /* ─── Cancel order ──────────────────────────────────── */
    function cancelOrder(orderId) {
        openStatusChange(orderId, 'Cancelled');
    }

    /* ─── Assign rider flow ─────────────────────────────── */
    function openAssignRider(orderId) {
        document.getElementById('assignRiderOrderId').value = orderId;
        document.getElementById('assignRiderOrderLabel').textContent = 'Select a rider for order #' + orderId.slice(-6) + '.';
        document.getElementById('riderSelect').value = '';
        loadRiders();
        var bsModal = bootstrap.Modal.getOrCreateInstance(document.getElementById('assignRiderModal'));
        bsModal.show();
    }

    function confirmAssignRider() {
        var orderId = document.getElementById('assignRiderOrderId').value;
        var riderId = document.getElementById('riderSelect').value;
        if (!riderId) {
            showToast('warning', 'Please select a rider.');
            return;
        }

        var btn = document.getElementById('btnConfirmAssignRider');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Assigning...';

        apiFetch(ORDERS_URL + '/' + orderId + '/rider', 'PUT', { riderId: riderId })
            .then(function() {
                bootstrap.Modal.getOrCreateInstance(document.getElementById('assignRiderModal')).hide();
                showToast('success', 'Rider assigned successfully.');
                loadOrders();
            })
            .catch(function(err) {
                showToast('error', 'Failed to assign rider. ' + (err.message || ''));
            })
            .finally(function() {
                btn.disabled = false;
                btn.innerHTML = '<i class="bi bi-check-lg me-1"></i> Assign Rider';
            });
    }

    /* ─── Event bindings ────────────────────────────────── */
    function attachRowEvents() {
        document.querySelectorAll('.btn-view-order').forEach(function(btn) {
            btn.addEventListener('click', function() { loadOrderDetail(btn.dataset.id); });
        });
        document.querySelectorAll('.btn-change-status').forEach(function(btn) {
            btn.addEventListener('click', function() { openStatusChange(btn.dataset.id, btn.dataset.next); });
        });
        document.querySelectorAll('.btn-cancel-order').forEach(function(btn) {
            btn.addEventListener('click', function() { cancelOrder(btn.dataset.id); });
        });
        document.querySelectorAll('.btn-assign-rider').forEach(function(btn) {
            btn.addEventListener('click', function() { openAssignRider(btn.dataset.id); });
        });
    }

    /* ─── Status tabs ───────────────────────────────────── */
    document.getElementById('statusTabs').addEventListener('click', function(e) {
        var btn = e.target.closest('[data-status]');
        if (!btn) return;
        currentFilter = btn.dataset.status || '';
        document.querySelectorAll('#statusTabs .btn').forEach(function(b) {
            b.className = 'btn btn-sm' + (b.dataset.status === currentFilter ? ' btn-msm active' : ' btn-outline-secondary');
        });
        renderOrders();
    });

    /* ─── Search ────────────────────────────────────────── */
    var searchTimer = null;
    document.getElementById('orderSearch').addEventListener('input', function() {
        clearTimeout(searchTimer);
        var val = this.value;
        searchTimer = setTimeout(function() {
            searchQuery = val.trim();
            renderOrders();
        }, 250);
    });

    /* ─── Refresh ───────────────────────────────────────── */
    document.getElementById('btnRefresh').addEventListener('click', function() { loadOrders(); });

    /* ─── Confirm buttons ───────────────────────────────── */
    document.getElementById('btnConfirmStatusChange').addEventListener('click', confirmStatusChange);
    document.getElementById('btnConfirmAssignRider').addEventListener('click', confirmAssignRider);

    /* ─── Init ──────────────────────────────────────────── */
    loadOrders();
})();
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
