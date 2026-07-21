<?php
/**
 * Payments Management
 *
 * Read-only payment view derived from Delivered orders.
 * All data fetched via AJAX with JWT in session.
 */

$currentPage = 'payments';
$pageTitle   = 'Payments';

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
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Total Revenue</div>
                        <div class="stat-value text-success" id="statTotalRevenue" data-count="0">0</div>
                        <div class="stat-label" style="text-transform:none;font-weight:400;">FCFA</div>
                    </div>
                    <div class="stat-icon bg-success bg-opacity-10 text-success">
                        <i class="bi bi-currency-exchange"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0d6efd,#0b5ed7);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">This Month</div>
                        <div class="stat-value" style="color:#0d6efd;" id="statMonthRevenue" data-count="0">0</div>
                        <div class="stat-label" style="text-transform:none;font-weight:400;">FCFA</div>
                    </div>
                    <div class="stat-icon bg-primary bg-opacity-10 text-primary">
                        <i class="bi bi-calendar-month"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0dcaf0,#0aa2c0);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Avg Order Value</div>
                        <div class="stat-value" style="color:#0aa2c0;" id="statAvgOrder" data-count="0">0</div>
                        <div class="stat-label" style="text-transform:none;font-weight:400;">FCFA</div>
                    </div>
                    <div class="stat-icon bg-info bg-opacity-10 text-info">
                        <i class="bi bi-graph-up-arrow"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Completed Payments</div>
                        <div class="stat-value" style="color:#e0a800;" id="statCompletedCount" data-count="0">0</div>
                    </div>
                    <div class="stat-icon bg-warning bg-opacity-10 text-warning">
                        <i class="bi bi-check-circle"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══════ DATE FILTER ═══════ -->
    <div class="msm-card mb-4 animate-in">
        <div class="table-toolbar" style="flex-wrap:wrap;gap:0.75rem;">
            <div class="d-flex align-items-center gap-2 flex-wrap">
                <div class="d-flex align-items-center gap-2">
                    <label class="form-label mb-0 fw-semibold small text-muted">From</label>
                    <input type="date" class="form-control form-control-sm" id="dateFrom" style="width:160px;">
                </div>
                <div class="d-flex align-items-center gap-2">
                    <label class="form-label mb-0 fw-semibold small text-muted">To</label>
                    <input type="date" class="form-control form-control-sm" id="dateTo" style="width:160px;">
                </div>
                <button class="btn btn-sm btn-msm" id="btnFilterDates">
                    <i class="bi bi-funnel me-1"></i> Filter
                </button>
                <button class="btn btn-sm btn-outline-secondary" id="btnClearDates">
                    <i class="bi bi-x-lg me-1"></i> Clear
                </button>
            </div>
            <div class="d-flex align-items-center gap-2">
                <button class="btn btn-sm btn-outline-secondary" id="btnRefreshPayments" title="Refresh">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
            </div>
        </div>
    </div>

    <!-- ═══════ PAYMENTS TABLE ═══════ -->
    <div class="msm-card p-0 animate-in">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Payment ID</th>
                        <th>Customer</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody id="paymentsTableBody">
                    <tr>
                        <td colspan="6">
                            <div class="empty-state py-5">
                                <div class="spinner-border text-success" role="status"></div>
                                <p class="mt-2">Loading payments...</p>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

</div>

<!-- ═══════ PAYMENT DETAIL MODAL ═══════ -->
<div class="modal fade" id="paymentDetailModal" tabindex="-1" aria-labelledby="paymentDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold" id="paymentDetailModalLabel">Payment Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="paymentDetailBody">
                <div class="text-center py-4">
                    <div class="spinner-border text-success"></div>
                    <p class="mt-2 text-muted">Loading details...</p>
                </div>
            </div>
        </div>
    </div>
</div>


<script>
(function() {
    /* ─── Config ────────────────────────────────────────── */
    var JWT = '<?php echo addslashes($jwt); ?>';
    var ORDERS_URL = '<?php echo API_ADMIN_ORDERS; ?>';

    /* ─── State ─────────────────────────────────────────── */
    var allPayments = [];
    var filteredPayments = [];

    /* ─── Fetch helper ──────────────────────────────────── */
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

    /* ─── Parse date safely ─────────────────────────────── */
    function parseDate(str) {
        if (!str) return null;
        var d = new Date(str);
        return isNaN(d.getTime()) ? null : d;
    }

    function isSameMonth(dateStr) {
        var d = parseDate(dateStr);
        if (!d) return false;
        var now = new Date();
        return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
    }

    function isWithinRange(dateStr, fromStr, toStr) {
        var d = parseDate(dateStr);
        if (!d) return true;
        if (fromStr) {
            var from = parseDate(fromStr);
            if (from && d < from) return false;
        }
        if (toStr) {
            var to = parseDate(toStr);
            if (to) {
                to.setHours(23, 59, 59, 999);
                if (d > to) return false;
            }
        }
        return true;
    }

    /* ─── Stats badge color ─────────────────────────────── */
    function paymentStatusBadge(status) {
        if (status === 'Refunded') return 'bg-warning text-dark';
        return 'bg-success';
    }

    /* ─── Update stat cards ─────────────────────────────── */
    function updateStats() {
        var totalRevenue = 0;
        var monthRevenue = 0;
        var count = allPayments.length;
        var monthCount = 0;

        allPayments.forEach(function(p) {
            totalRevenue += (p.total || 0);
            if (isSameMonth(p.createdAt)) {
                monthRevenue += (p.total || 0);
                monthCount++;
            }
        });

        var avgOrder = count > 0 ? Math.round(totalRevenue / count) : 0;

        setStatText('statTotalRevenue', totalRevenue);
        setStatText('statMonthRevenue', monthRevenue);
        setStatText('statAvgOrder', avgOrder);
        setStatText('statCompletedCount', count);
    }

    function setStatText(id, val) {
        var el = document.getElementById(id);
        if (el) {
            el.textContent = val.toLocaleString();
            el.setAttribute('data-count', val);
        }
        MSM.initCounters();
    }

    /* ─── Render payments table ─────────────────────────── */
    function renderPayments() {
        var fromVal = document.getElementById('dateFrom').value;
        var toVal = document.getElementById('dateTo').value;

        filteredPayments = allPayments.filter(function(p) {
            return isWithinRange(p.createdAt, fromVal, toVal);
        });

        /* Sort by date descending */
        filteredPayments.sort(function(a, b) {
            return new Date(b.createdAt) - new Date(a.createdAt);
        });

        var tbody = document.getElementById('paymentsTableBody');
        if (!filteredPayments.length) {
            tbody.innerHTML = '<tr><td colspan="6"><div class="empty-state py-5"><i class="bi bi-credit-card-2-front"></i><p>No payments found for the selected criteria.</p></div></td></tr>';
            return;
        }

        var html = '';
        filteredPayments.forEach(function(p) {
            var oid = p._id || p.id || '';
            var shortId = '#' + oid.slice(-6);
            var customer = (p.userId && p.userId.fullName) ? p.userId.fullName : 'N/A';
            var amount = MSM.formatCurrency(p.total || 0);
            var status = 'Paid';
            if (p.status === 'Cancelled') status = 'Refunded';
            var badge = paymentStatusBadge(status);
            var date = MSM.formatDate(p.createdAt);

            html += '<tr>';
            html += '<td><span class="fw-semibold" style="font-size:0.85rem;">' + shortId + '</span></td>';
            html += '<td>';
            html += '<div class="d-flex align-items-center gap-2">';
            html += '<div class="activity-avatar-placeholder" style="width:32px;height:32px;font-size:0.7rem;background:#198754;">' + customer.charAt(0).toUpperCase() + '</div>';
            html += '<span>' + MSM.truncate(customer, 25) + '</span>';
            html += '</div></td>';
            html += '<td class="fw-semibold text-success">' + amount + '</td>';
            html += '<td><span class="badge ' + badge + ' badge-status">' + status + '</span></td>';
            html += '<td class="text-muted small">' + date + '</td>';
            html += '<td class="text-end">';
            html += '<button class="btn btn-sm btn-outline-secondary btn-view-payment" data-id="' + oid + '" title="View Details"><i class="bi bi-eye"></i></button>';
            html += '</td>';
            html += '</tr>';
        });
        tbody.innerHTML = html;

        tbody.querySelectorAll('.btn-view-payment').forEach(function(btn) {
            btn.addEventListener('click', function() { loadPaymentDetail(btn.dataset.id); });
        });
    }

    /* ─── Load all delivered orders as payments ─────────── */
    function loadPayments() {
        apiFetch(ORDERS_URL + '?status=Delivered', 'GET')
            .then(function(res) {
                allPayments = Array.isArray(res) ? res : (res.orders || res.data || []);

                /* If the backend doesn't filter, do client-side */
                if (allPayments.length && allPayments[0].status !== 'Delivered') {
                    allPayments = allPayments.filter(function(o) { return o.status === 'Delivered'; });
                }

                updateStats();
                renderPayments();
            })
            .catch(function(err) {
                console.error('Failed to load payments:', err);
                document.getElementById('paymentsTableBody').innerHTML =
                    '<tr><td colspan="6"><div class="empty-state py-5"><i class="bi bi-exclamation-triangle text-warning"></i><p>Failed to load payment data. Please try again.</p><button class="btn btn-sm btn-msm mt-2" onclick="document.getElementById(\'btnRefreshPayments\').click()"><i class="bi bi-arrow-clockwise me-1"></i> Retry</button></div></td></tr>';
            });
    }

    /* ─── Load payment detail ───────────────────────────── */
    function loadPaymentDetail(orderId) {
        var body = document.getElementById('paymentDetailBody');
        body.innerHTML = '<div class="text-center py-4"><div class="spinner-border text-success"></div><p class="mt-2 text-muted">Loading...</p></div>';

        var bsModal = bootstrap.Modal.getOrCreateInstance(document.getElementById('paymentDetailModal'));
        bsModal.show();

        apiFetch(ORDERS_URL + '/' + orderId, 'GET')
            .then(function(order) {
                renderPaymentDetail(order);
            })
            .catch(function() {
                body.innerHTML = '<div class="text-center py-4"><i class="bi bi-exclamation-triangle text-danger fs-1"></i><p class="mt-2">Failed to load payment details.</p></div>';
            });
    }

    /* ─── Render payment detail in modal ────────────────── */
    function renderPaymentDetail(order) {
        var body = document.getElementById('paymentDetailBody');
        var oid = order._id || order.id || '';
        var status = order.status || 'Delivered';
        var customer = order.userId || {};
        var delivery = order.delivery || {};
        var items = order.items || [];
        var paymentStatus = status === 'Cancelled' ? 'Refunded' : 'Paid';

        var html = '';

        /* Payment Info */
        html += '<div class="row g-3 mb-4">';
        html += '<div class="col-md-6">';
        html += '<div class="p-3 rounded" style="background:var(--msm-bg);">';
        html += '<h6 class="fw-bold mb-3"><i class="bi bi-receipt me-2"></i>Payment Information</h6>';
        html += '<div class="mb-2"><span class="text-muted small">Payment ID:</span><br><span class="fw-semibold">#' + oid.slice(-6) + '</span></div>';
        html += '<div class="mb-2"><span class="text-muted small">Full Order ID:</span><br><span class="fw-semibold" style="font-size:0.8rem;">' + oid + '</span></div>';
        html += '<div class="mb-2"><span class="text-muted small">Date:</span><br><span class="fw-semibold">' + MSM.formatDateTime(order.createdAt) + '</span></div>';
        html += '<div class="mb-2"><span class="text-muted small">Payment Status:</span><br><span class="badge ' + paymentStatusBadge(paymentStatus) + ' badge-status">' + paymentStatus + '</span></div>';
        html += '<div><span class="text-muted small">Order Status:</span><br><span class="badge bg-secondary badge-status">' + status + '</span></div>';
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
            html += '<h6 class="fw-bold mb-3"><i class="bi bi-geo-alt me-2"></i>Delivery Address</h6>';
            html += '<div class="row g-3">';
            html += '<div class="col-md-4"><span class="text-muted small">Receiver:</span><br><span class="fw-semibold">' + MSM.truncate(delivery.receiver || 'N/A', 30) + '</span></div>';
            html += '<div class="col-md-4"><span class="text-muted small">Phone:</span><br><span class="fw-semibold">' + (delivery.phone || 'N/A') + '</span></div>';
            html += '<div class="col-md-4"><span class="text-muted small">Address:</span><br><span class="fw-semibold">' + MSM.truncate(delivery.address || 'N/A', 40) + '</span></div>';
            html += '</div></div>';
        }

        /* Items */
        html += '<h6 class="fw-bold mb-3"><i class="bi bi-bag me-2"></i>Order Items</h6>';
        if (items.length) {
            html += '<div class="table-responsive"><table class="table table-sm align-middle mb-0">';
            html += '<thead class="table-light"><tr><th>Product</th><th class="text-center">Qty</th><th class="text-end">Unit Price</th><th class="text-end">Subtotal</th></tr></thead>';
            html += '<tbody>';
            var totalCheck = 0;
            items.forEach(function(item) {
                var food = item.foodstuffId || {};
                var name = food.name || item.name || 'Product';
                var img = food.image || item.image || '';
                var qty = item.quantity || 1;
                var price = item.price || 0;
                var lineTotal = qty * price;
                totalCheck += lineTotal;
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
            html += '</tbody>';
            html += '<tfoot><tr class="table-light"><td colspan="3" class="text-end fw-bold">Total</td><td class="text-end fw-bold text-success">' + MSM.formatCurrency(order.total || 0) + '</td></tr></tfoot>';
            html += '</table></div>';
        } else {
            html += '<div class="empty-state py-3"><i class="bi bi-bag-x"></i><p>No item details available.</p></div>';
        }

        /* Receipt info */
        html += '<div class="mt-4 p-3 rounded" style="background:var(--msm-bg);">';
        html += '<div class="d-flex align-items-center justify-content-between">';
        html += '<div><i class="bi bi-shield-check text-success me-2"></i><span class="fw-semibold">Payment Confirmed</span><br><span class="small text-muted">This payment was processed upon delivery completion.</span></div>';
        html += '<div class="text-end"><div class="fw-bold fs-4 text-success">' + MSM.formatCurrency(order.total || 0) + '</div><div class="small text-muted">' + CURRENCY + '</div></div>';
        html += '</div></div>';

        body.innerHTML = html;
    }

    /* ─── Event: Filter dates ───────────────────────────── */
    document.getElementById('btnFilterDates').addEventListener('click', function() { renderPayments(); });

    /* ─── Event: Clear dates ────────────────────────────── */
    document.getElementById('btnClearDates').addEventListener('click', function() {
        document.getElementById('dateFrom').value = '';
        document.getElementById('dateTo').value = '';
        renderPayments();
    });

    /* ─── Event: Refresh ────────────────────────────────── */
    document.getElementById('btnRefreshPayments').addEventListener('click', function() { loadPayments(); });

    /* ─── Init ──────────────────────────────────────────── */
    loadPayments();
})();
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
