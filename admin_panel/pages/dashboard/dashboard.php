<?php
/**
 * Dashboard — Command Center
 *
 * Full-featured admin dashboard with stats, charts, orders, inventory,
 * customer activity, reviews, alerts, and quick actions.
 */

$currentPage = 'dashboard';
$pageTitle   = 'Dashboard';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

/* ─── Fetch dashboard data from backend ──────────────── */
$jwt  = session_get_jwt();
$dash = api_request('GET', API_ADMIN_DASHBOARD, null, $jwt);
$d    = $dash['body'] ?? [];

$totalProducts   = $d['totalProducts']   ?? 0;
$totalOrders     = $d['totalOrders']     ?? 0;
$totalCustomers  = $d['totalCustomers']  ?? 0;
$totalRevenue    = $d['totalRevenue']    ?? 0;
$revenueToday    = $d['revenueToday']    ?? 0;
$revenueMonth    = $d['revenueThisMonth'] ?? 0;
$pendingOrders   = $d['pendingOrders']   ?? 0;
$activeDeliveries= $d['activeDeliveries']?? 0;
$newCustomersToday = $d['newCustomersToday'] ?? 0;
$activeRiders    = $d['activeRiders']    ?? 0;
$totalRiders     = $d['totalRiders']     ?? 0;
$avgRating       = $d['avgRating']       ?? 0;
$catDist         = $d['categoryDistribution'] ?? [];
$topMeals        = $d['topMeals']        ?? [];
$monthlyRevenue  = $d['monthlyRevenue']  ?? [];
$recentOrders    = $d['recentOrders']    ?? [];
$lowStock        = $d['lowStock']        ?? [];
$recentReviews   = $d['recentReviews']   ?? [];
$recentCustomers = $d['recentCustomers'] ?? [];
$alerts          = $d['alerts']          ?? [];

/* ─── PHP time-ago helper ─────────────────────────────── */
function time_ago($dateStr) {
    $now = time();
    $then = is_string($dateStr) ? strtotime($dateStr) : $dateStr;
    if (!$then) return 'Just now';
    $diff = $now - $then;
    if ($diff < 60) return 'Just now';
    if ($diff < 3600) return floor($diff / 60) . 'm ago';
    if ($diff < 86400) return floor($diff / 3600) . 'h ago';
    if ($diff < 604800) return floor($diff / 86400) . 'd ago';
    return date('d M Y', $then);
}

include __DIR__ . '/../../includes/header.php';
include __DIR__ . '/../../includes/sidebar.php';
include __DIR__ . '/../../includes/loader.php';
?>

<!-- Sidebar Overlay (mobile) -->
<div class="sidebar-overlay" id="sidebarOverlay" onclick="MSM.toggleSidebar()"></div>

<div class="admin-content">

    <!-- ═══════ TOP NAVBAR ═══════ -->
    <div class="admin-navbar">
        <div class="navbar-left">
            <button class="btn btn-sm d-lg-none" onclick="MSM.toggleSidebar()" style="font-size:1.2rem;color:var(--msm-muted);">
                <i class="bi bi-list"></i>
            </button>
            <div class="navbar-brand-text">
                <span><?php echo $pageTitle; ?></span>
            </div>
        </div>

        <!-- Global Search -->
        <div class="navbar-search d-none d-md-block">
            <i class="bi bi-search search-icon"></i>
            <input type="text" class="form-control" id="globalSearch" placeholder="Search meals, customers, orders..." autocomplete="off">
            <span class="search-kbd">Ctrl+K</span>
            <div class="search-results-dropdown" id="searchResults"></div>
        </div>

        <div class="navbar-right">
            <!-- Notification Bell -->
            <div style="position:relative;">
                <button class="navbar-icon-btn" onclick="MSM.toggleDropdown('notifDropdown')" title="Notifications">
                    <i class="bi bi-bell"></i>
                    <?php if (!empty($alerts)): ?>
                        <span class="badge-dot"></span>
                    <?php endif; ?>
                </button>
                <div class="notification-dropdown" id="notifDropdown">
                    <div class="notif-header">
                        <h6>Notifications</h6>
                        <a href="<?php echo admin_url('pages/notifications/notifications.php'); ?>" class="text-decoration-none small">View All</a>
                    </div>
                    <div class="notif-list">
                        <?php if (empty($alerts)): ?>
                            <div class="notif-item">
                                <div class="notif-content">
                                    <div class="notif-title">All caught up!</div>
                                    <div class="notif-msg">No new notifications.</div>
                                </div>
                            </div>
                        <?php else: ?>
                            <?php foreach ($alerts as $i => $alert): ?>
                            <div class="notif-item <?php echo $i === 0 ? 'unread' : ''; ?>">
                                <div class="notif-icon bg-<?php echo $alert['type'] === 'danger' ? 'danger' : ($alert['type'] === 'warning' ? 'warning' : 'primary'); ?> bg-opacity-10 text-<?php echo $alert['type'] === 'danger' ? 'danger' : ($alert['type'] === 'warning' ? 'warning' : 'primary'); ?>">
                                    <i class="bi <?php echo $alert['icon']; ?>"></i>
                                </div>
                                <div class="notif-content">
                                    <div class="notif-title"><?php echo htmlspecialchars($alert['title']); ?></div>
                                    <div class="notif-msg"><?php echo htmlspecialchars($alert['message']); ?></div>
                                    <div class="notif-time">Just now</div>
                                </div>
                            </div>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </div>
                </div>
            </div>

            <!-- Profile Dropdown -->
            <div style="position:relative;">
                <img src="<?php echo htmlspecialchars($adminAvatar); ?>"
                     alt="Admin"
                     class="profile-avatar"
                     onerror="this.src='https://ui-avatars.com/api/?name=<?php echo urlencode($adminName); ?>&background=198754&color=fff&size=36'"
                     onclick="MSM.toggleDropdown('profileDropdown')">
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

    <!-- ═══════ WELCOME SECTION ═══════ -->
    <div class="welcome-section animate-in">
        <h3><span id="welcomeGreeting">Good Day</span>, <?php echo htmlspecialchars($adminName); ?> 👋</h3>
        <p>Here's what's happening with <?php echo APP_NAME; ?> today.</p>
        <div class="welcome-meta">
            <span><i class="bi bi-calendar3"></i> <?php echo date('l, d M Y'); ?></span>
            <span><i class="bi bi-geo-alt"></i> Douala, Cameroon</span>
        </div>
        <?php if ($pendingOrders > 0): ?>
        <div class="welcome-pending">
            <i class="bi bi-exclamation-circle"></i>
            You have <strong><?php echo $pendingOrders; ?></strong> order<?php echo $pendingOrders > 1 ? 's' : ''; ?> awaiting confirmation.
        </div>
        <?php endif; ?>
    </div>

    <!-- ═══════ STAT CARDS ═══════ -->
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Revenue Today</div>
                        <div class="stat-value text-success" data-count="<?php echo $revenueToday; ?>"><?php echo number_format($revenueToday); ?></div>
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
                        <div class="stat-label">Total Orders</div>
                        <div class="stat-value" style="color:#0d6efd;" data-count="<?php echo $totalOrders; ?>"><?php echo number_format($totalOrders); ?></div>
                        <div class="stat-change up"><i class="bi bi-arrow-up"></i> <?php echo $pendingOrders; ?> pending</div>
                    </div>
                    <div class="stat-icon bg-primary bg-opacity-10 text-primary">
                        <i class="bi bi-cart-check"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0dcaf0,#0aa2c0);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Customers</div>
                        <div class="stat-value" style="color:#0dcaf0;" data-count="<?php echo $totalCustomers; ?>"><?php echo number_format($totalCustomers); ?></div>
                        <div class="stat-change up"><i class="bi bi-arrow-up"></i> +<?php echo $newCustomersToday; ?> today</div>
                    </div>
                    <div class="stat-icon bg-info bg-opacity-10 text-info">
                        <i class="bi bi-people"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Products</div>
                        <div class="stat-value" style="color:#e0a800;" data-count="<?php echo $totalProducts; ?>"><?php echo number_format($totalProducts); ?></div>
                        <div class="stat-change"><i class="bi bi-box-seam"></i> meals</div>
                    </div>
                    <div class="stat-icon bg-warning bg-opacity-10 text-warning">
                        <i class="bi bi-box-seam"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Second row of stat cards -->
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Revenue Month</div>
                        <div class="stat-value" style="font-size:1.25rem;" data-count="<?php echo $revenueMonth; ?>"><?php echo number_format($revenueMonth); ?></div>
                        <div class="stat-label" style="text-transform:none;font-weight:400;">FCFA</div>
                    </div>
                    <div class="stat-icon bg-success bg-opacity-10 text-success" style="width:40px;height:40px;font-size:1rem;">
                        <i class="bi bi-graph-up-arrow"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Active Deliveries</div>
                        <div class="stat-value" style="font-size:1.25rem;color:#0d6efd;" data-count="<?php echo $activeDeliveries; ?>"><?php echo $activeDeliveries; ?></div>
                        <div class="stat-change"><i class="bi bi-truck"></i> out for delivery</div>
                    </div>
                    <div class="stat-icon bg-primary bg-opacity-10 text-primary" style="width:40px;height:40px;font-size:1rem;">
                        <i class="bi bi-truck"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Active Riders</div>
                        <div class="stat-value" style="font-size:1.25rem;" data-count="<?php echo $activeRiders; ?>"><?php echo $activeRiders; ?></div>
                        <div class="stat-change"><?php echo $totalRiders; ?> total</div>
                    </div>
                    <div class="stat-icon bg-info bg-opacity-10 text-info" style="width:40px;height:40px;font-size:1rem;">
                        <i class="bi bi-bicycle"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Avg Rating</div>
                        <div class="stat-value" style="font-size:1.25rem;color:#ffc107;">
                            <?php echo $avgRating; ?> <small style="font-size:0.7rem;color:var(--msm-muted);">/ 5</small>
                        </div>
                        <div class="stat-change"><i class="bi bi-star-fill" style="color:#ffc107;"></i> customer rating</div>
                    </div>
                    <div class="stat-icon bg-warning bg-opacity-10 text-warning" style="width:40px;height:40px;font-size:1rem;">
                        <i class="bi bi-star"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══════ ANALYTICS CHARTS ═══════ -->
    <div class="row g-4 mb-4">
        <!-- Revenue Chart -->
        <div class="col-lg-8 animate-in">
            <div class="chart-card">
                <div class="chart-header">
                    <h6>Revenue Overview</h6>
                    <div class="chart-tabs">
                        <button class="chart-tab active" data-period="year">Year</button>
                    </div>
                </div>
                <div class="chart-body">
                    <canvas id="revenueChart" height="260"></canvas>
                </div>
            </div>
        </div>

        <!-- Category Distribution -->
        <div class="col-lg-4 animate-in">
            <div class="chart-card">
                <div class="chart-header">
                    <h6>Orders by Category</h6>
                </div>
                <div class="chart-body">
                    <canvas id="categoryChart" height="260"></canvas>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══════ TOP MEALS ═══════ -->
    <?php if (!empty($topMeals)): ?>
    <div class="row g-4 mb-4">
        <div class="col-lg-6 animate-in">
            <div class="chart-card">
                <div class="chart-header">
                    <h6><i class="bi bi-trophy text-warning me-2"></i>Top Selling Meals</h6>
                </div>
                <div class="p-3">
                    <?php foreach ($topMeals as $i => $meal): ?>
                    <div class="d-flex align-items-center gap-3 mb-3 <?php echo $i < count($topMeals) - 1 ? 'pb-3 border-bottom' : ''; ?>">
                        <div style="width:28px;height:28px;border-radius:8px;background:var(--msm-bg);display:flex;align-items:center;justify-content:center;font-size:0.75rem;font-weight:700;color:var(--msm-muted);">
                            #<?php echo $i + 1; ?>
                        </div>
                        <div class="flex-grow-1">
                            <div style="font-size:0.85rem;font-weight:600;"><?php echo htmlspecialchars($meal['name'] ?? 'Unknown'); ?></div>
                            <div style="font-size:0.75rem;color:var(--msm-muted);"><?php echo $meal['totalSold'] ?? 0; ?> sold</div>
                        </div>
                        <div class="stock-progress" style="width:80px;">
                            <div class="stock-bar good" style="width:<?php echo min(100, (($meal['totalSold'] ?? 1) / max(1, $topMeals[0]['totalSold'] ?? 1)) * 100); ?>%;"></div>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>

        <!-- System Alerts -->
        <div class="col-lg-6 animate-in">
            <div class="chart-card">
                <div class="chart-header">
                    <h6><i class="bi bi-shield-exclamation text-danger me-2"></i>System Alerts</h6>
                </div>
                <div class="p-3">
                    <?php if (empty($alerts)): ?>
                        <div class="empty-state py-3">
                            <i class="bi bi-check-circle text-success"></i>
                            <p>All systems running smoothly.</p>
                        </div>
                    <?php else: ?>
                        <?php foreach ($alerts as $alert): ?>
                        <div class="alert-card alert-card-<?php echo $alert['type']; ?>">
                            <i class="bi <?php echo $alert['icon']; ?>"></i>
                            <div>
                                <strong><?php echo htmlspecialchars($alert['title']); ?></strong>
                                <div style="font-size:0.78rem;opacity:0.8;"><?php echo htmlspecialchars($alert['message']); ?></div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
    <?php endif; ?>

    <!-- ═══════ RECENT ORDERS + SIDEBAR ═══════ -->
    <div class="row g-4 mb-4">
        <!-- Recent Orders Table -->
        <div class="col-lg-8 animate-in">
            <div class="msm-card p-0">
                <div class="table-toolbar">
                    <h6 class="mb-0 fw-bold">Recent Orders</h6>
                    <div class="d-flex align-items-center gap-2">
                        <a href="<?php echo admin_url('pages/orders/orders.php'); ?>" class="btn btn-sm btn-msm">
                            View All <i class="bi bi-arrow-right ms-1"></i>
                        </a>
                    </div>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Order</th>
                                <th>Customer</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Time</th>
                            </tr>
                        </thead>
                        <tbody>
                        <?php if (empty($recentOrders)): ?>
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state py-4">
                                        <i class="bi bi-cart-x"></i>
                                        <p>No orders yet.</p>
                                    </div>
                                </td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($recentOrders as $order): ?>
                            <tr>
                                <td><span class="fw-semibold">#<?php echo substr($order['_id'] ?? $order['id'] ?? '', -6); ?></span></td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="activity-avatar-placeholder" style="width:32px;height:32px;font-size:0.7rem;background:#198754;">
                                            <?php echo strtoupper(substr($order['userId']['fullName'] ?? 'U', 0, 1)); ?>
                                        </div>
                                        <span><?php echo htmlspecialchars($order['userId']['fullName'] ?? 'N/A'); ?></span>
                                    </div>
                                </td>
                                <td class="fw-semibold"><?php echo number_format($order['total'] ?? 0); ?> <small class="text-muted">FCFA</small></td>
                                <td>
                                    <?php
                                    $status = $order['status'] ?? 'Pending';
                                    $statusMap = [
                                        'Delivered'        => 'bg-success',
                                        'Out for Delivery' => 'bg-primary',
                                        'Preparing'        => 'bg-warning text-dark',
                                        'Confirmed'        => 'bg-info text-dark',
                                        'Pending'          => 'bg-secondary',
                                        'Cancelled'        => 'bg-danger',
                                    ];
                                    ?>
                                    <span class="badge <?php echo $statusMap[$status] ?? 'bg-secondary'; ?> badge-status"><?php echo htmlspecialchars($status); ?></span>
                                </td>
                                <td class="text-muted small"><?php echo time_ago($order['createdAt'] ?? 'now'); ?></td>
                            </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Inventory + Quick Actions -->
        <div class="col-lg-4">
            <!-- Low Stock -->
            <div class="msm-card mb-4 animate-in">
                <div class="p-3 border-bottom d-flex align-items-center justify-content-between">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-exclamation-triangle text-warning me-2"></i>Low Stock</h6>
                    <?php if (!empty($lowStock)): ?>
                        <span class="badge bg-danger"><?php echo count($lowStock); ?></span>
                    <?php endif; ?>
                </div>
                <div class="p-3">
                <?php if (empty($lowStock)): ?>
                    <div class="empty-state py-2">
                        <i class="bi bi-check-circle text-success"></i>
                        <p>All stocked up.</p>
                    </div>
                <?php else: ?>
                    <?php foreach (array_slice($lowStock, 0, 6) as $item): ?>
                    <?php
                        $stock = $item['stock'] ?? 0;
                        $pct = min(100, ($stock / 10) * 100);
                        $barClass = $stock <= 2 ? 'critical' : ($stock <= 5 ? 'low' : 'good');
                    ?>
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div style="flex:1;min-width:0;">
                            <div class="d-flex justify-content-between mb-1">
                                <span style="font-size:0.82rem;font-weight:500;"><?php echo htmlspecialchars($item['name'] ?? 'Unknown'); ?></span>
                                <span class="badge bg-<?php echo $barClass === 'critical' ? 'danger' : ($barClass === 'low' ? 'warning' : 'success'); ?>" style="font-size:0.65rem;"><?php echo $stock; ?></span>
                            </div>
                            <div class="stock-progress">
                                <div class="stock-bar <?php echo $barClass; ?>" style="width:<?php echo $pct; ?>%;"></div>
                            </div>
                        </div>
                    </div>
                    <?php endforeach; ?>
                <?php endif; ?>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="msm-card animate-in">
                <div class="p-3 border-bottom">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-lightning text-warning me-2"></i>Quick Actions</h6>
                </div>
                <div class="p-3 d-grid gap-2">
                    <a href="<?php echo admin_url('pages/products/products.php'); ?>" class="quick-action-btn">
                        <i class="bi bi-plus-circle bg-success bg-opacity-10 text-success"></i>
                        Add New Meal
                    </a>
                    <a href="<?php echo admin_url('pages/orders/orders.php'); ?>" class="quick-action-btn">
                        <i class="bi bi-cart-check bg-primary bg-opacity-10 text-primary"></i>
                        Manage Orders
                    </a>
                    <a href="<?php echo admin_url('pages/promotions/promotions.php'); ?>" class="quick-action-btn">
                        <i class="bi bi-megaphone bg-warning bg-opacity-10 text-warning"></i>
                        Create Promotion
                    </a>
                    <a href="<?php echo admin_url('pages/categories/categories.php'); ?>" class="quick-action-btn">
                        <i class="bi bi-tags bg-info bg-opacity-10 text-info"></i>
                        Manage Categories
                    </a>
                    <a href="<?php echo admin_url('pages/reports/reports.php'); ?>" class="quick-action-btn">
                        <i class="bi bi-graph-up bg-danger bg-opacity-10 text-danger"></i>
                        View Reports
                    </a>
                    <a href="<?php echo admin_url('pages/admins/admins.php'); ?>" class="quick-action-btn">
                        <i class="bi bi-shield-lock bg-secondary bg-opacity-10 text-secondary"></i>
                        Manage Admins
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══════ CUSTOMER ACTIVITY + REVIEWS ═══════ -->
    <div class="row g-4 mb-4">
        <!-- Recent Customers -->
        <div class="col-lg-6 animate-in">
            <div class="chart-card">
                <div class="chart-header">
                    <h6><i class="bi bi-person-plus text-info me-2"></i>Recent Customers</h6>
                    <a href="<?php echo admin_url('pages/users/users.php'); ?>" class="text-decoration-none small">View All</a>
                </div>
                <div class="p-3">
                    <?php if (empty($recentCustomers)): ?>
                        <div class="empty-state py-2">
                            <i class="bi bi-people"></i>
                            <p>No customers yet.</p>
                        </div>
                    <?php else: ?>
                        <?php foreach ($recentCustomers as $cust): ?>
                        <div class="activity-item">
                            <div class="activity-avatar-placeholder" style="background:<?php echo ['#198754','#0d6efd','#ffc107','#dc3545','#6f42c1'][array_search($cust, $recentCustomers) % 5]; ?>;">
                                <?php echo strtoupper(substr($cust['fullName'] ?? 'U', 0, 1)); ?>
                            </div>
                            <div class="activity-content">
                                <div class="activity-title"><?php echo htmlspecialchars($cust['fullName'] ?? 'Unknown'); ?></div>
                                <div class="activity-sub"><?php echo htmlspecialchars($cust['email'] ?? ''); ?></div>
                            </div>
                            <div class="activity-time"><?php echo time_ago($cust['createdAt'] ?? 'now'); ?></div>
                        </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>
            </div>
        </div>

        <!-- Latest Reviews -->
        <div class="col-lg-6 animate-in">
            <div class="chart-card">
                <div class="chart-header">
                    <h6><i class="bi bi-star text-warning me-2"></i>Latest Reviews</h6>
                    <a href="<?php echo admin_url('pages/reviews/reviews.php'); ?>" class="text-decoration-none small">View All</a>
                </div>
                <div class="p-3">
                    <?php if (empty($recentReviews)): ?>
                        <div class="empty-state py-2">
                            <i class="bi bi-star"></i>
                            <p>No reviews yet.</p>
                        </div>
                    <?php else: ?>
                        <?php foreach ($recentReviews as $rev): ?>
                        <div class="review-item">
                            <div class="d-flex align-items-center justify-content-between">
                                <div>
                                    <span class="review-stars">
                                        <?php for ($s = 1; $s <= 5; $s++): ?>
                                            <i class="bi bi-star<?php echo $s <= ($rev['rating'] ?? 0) ? '-fill' : ''; ?>"></i>
                                        <?php endfor; ?>
                                    </span>
                                    <span style="font-size:0.8rem;font-weight:600;margin-left:0.3rem;"><?php echo htmlspecialchars($rev['mealId']['name'] ?? ''); ?></span>
                                </div>
                                <span class="activity-time"><?php echo time_ago($rev['createdAt'] ?? 'now'); ?></span>
                            </div>
                            <?php if (!empty($rev['comment'])): ?>
                            <div class="review-text"><?php echo htmlspecialchars(strlen($rev['comment'] ?? '') > 120 ? substr($rev['comment'], 0, 120) . '...' : ($rev['comment'] ?? '')); ?></div>
                            <?php endif; ?>
                            <div class="review-meta">by <?php echo htmlspecialchars($rev['userId']['fullName'] ?? 'Anonymous'); ?></div>
                        </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>

</div><!-- /.admin-content -->

<!-- ═══════ CHART INITIALIZATION ═══════ -->
<script>
(function() {
    var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var monthlyRevenue = <?php echo json_encode($monthlyRevenue); ?>;
    var catDist = <?php echo json_encode($catDist); ?>;

    /* Revenue Chart */
    var revLabels = [];
    var revData = [];
    var revMap = {};
    monthlyRevenue.forEach(function(r) { revMap[r._id] = r.revenue; });
    for (var i = 1; i <= 12; i++) {
        revLabels.push(months[i - 1]);
        revData.push(revMap[i] || 0);
    }

    var revCtx = document.getElementById('revenueChart');
    if (revCtx) {
        new Chart(revCtx, {
            type: 'line',
            data: {
                labels: revLabels,
                datasets: [{
                    label: 'Revenue (FCFA)',
                    data: revData,
                    borderColor: '#198754',
                    backgroundColor: 'rgba(25,135,84,0.08)',
                    fill: true,
                    tension: 0.4,
                    borderWidth: 2.5,
                    pointRadius: 4,
                    pointBackgroundColor: '#198754',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointHoverRadius: 6,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(0,0,0,0.04)' },
                        ticks: { font: { size: 11, family: 'Inter' }, callback: function(v) { return v >= 1000 ? (v/1000)+'k' : v; } }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { font: { size: 11, family: 'Inter' } }
                    }
                },
                interaction: { intersect: false, mode: 'index' }
            }
        });
    }

    /* Category Doughnut */
    var catCtx = document.getElementById('categoryChart');
    if (catCtx && catDist.length) {
        var catLabels = catDist.map(function(c) { return c._id || 'Other'; });
        var catData = catDist.map(function(c) { return c.count; });
        var catColors = ['#198754','#0d6efd','#ffc107','#dc3545','#6f42c1','#0dcaf0'];
        new Chart(catCtx, {
            type: 'doughnut',
            data: {
                labels: catLabels,
                datasets: [{
                    data: catData,
                    backgroundColor: catColors,
                    borderWidth: 0,
                    hoverOffset: 6,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '65%',
                plugins: {
                    legend: { position: 'bottom', labels: { font: { size: 11, family: 'Inter' }, padding: 12, usePointStyle: true, pointStyleWidth: 8 } }
                }
            }
        });
    } else if (catCtx) {
        catCtx.parentElement.innerHTML = '<div class="empty-state py-4"><i class="bi bi-pie-chart"></i><p>No category data yet.</p></div>';
    }

    /* Keyboard shortcut: Ctrl+K for search */
    document.addEventListener('keydown', function(e) {
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            var searchInput = document.getElementById('globalSearch');
            if (searchInput) searchInput.focus();
        }
    });

    /* Init search */
    MSM.initSearch('<?php echo API_ADMIN_SEARCH; ?>');
})();
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
