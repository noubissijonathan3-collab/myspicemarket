<?php
$currentPage = 'favorites';
$pageTitle   = 'Favorites';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt     = session_get_jwt();
$favData = api_request('GET', API_ADMIN_FAVORITES, null, $jwt);
$fav     = $favData['body'] ?? [];

$totalFavorites   = $fav['totalFavorites'] ?? 0;
$uniqueCustomers  = $fav['uniqueCustomers'] ?? 0;
$avgPerCustomer   = $fav['avgPerCustomer'] ?? 0;
$topItem          = $fav['topItem'] ?? null;
$favItems         = $fav['items'] ?? [];
$recentFavorites  = $fav['recentFavorites'] ?? [];

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
<div class="sidebar-overlay" id="sidebarOverlay" onclick="MSM.toggleSidebar()"></div>

<div class="admin-content">
    <div class="admin-navbar">
        <div class="navbar-left">
            <button class="btn btn-sm d-lg-none" onclick="MSM.toggleSidebar()" style="font-size:1.2rem;color:var(--msm-muted);"><i class="bi bi-list"></i></button>
            <div class="navbar-brand-text"><span>Favorites</span></div>
        </div>
        <div class="navbar-search d-none d-md-block">
            <i class="bi bi-search search-icon"></i>
            <input type="text" class="form-control" id="globalSearch" placeholder="Search meals, customers, orders..." autocomplete="off">
            <span class="search-kbd">Ctrl+K</span>
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

    <div class="welcome-section animate-in d-flex align-items-center justify-content-between">
        <div>
            <h3><i class="bi bi-heart text-danger me-2"></i>Favorites Overview</h3>
            <p>Track and analyze customer favorites, wishlists, and saved items.</p>
        </div>
        <div>
            <button class="btn btn-sm btn-msm-outline me-2" onclick="refreshData()"><i class="bi bi-arrow-clockwise me-1"></i>Refresh</button>
            <button class="btn btn-sm btn-msm" onclick="exportCsv()"><i class="bi bi-download me-1"></i>Export</button>
        </div>
    </div>

    <div class="row g-3 mb-4" id="favoritesStats">
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#dc3545,#b02a37);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Total Favorites</div>
                        <div class="stat-value" style="color:#dc3545;" id="statTotalFav"><?php echo number_format($totalFavorites); ?></div>
                    </div>
                    <div class="stat-icon bg-danger bg-opacity-10 text-danger"><i class="bi bi-heart"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Top Favorited Item</div>
                        <div class="stat-value" style="color:#e0a800;font-size:1rem;" id="statTopItem"><?php echo htmlspecialchars($topItem['name'] ?? '—'); ?></div>
                        <div class="stat-change" id="statTopItemCount"><?php if ($topItem): ?><i class="bi bi-heart text-danger me-1"></i><?php echo number_format($topItem['favorites']); ?><?php endif; ?></div>
                    </div>
                    <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-trophy"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0d6efd,#0b5ed7);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Customers with Favorites</div>
                        <div class="stat-value" style="color:#0d6efd;" id="statFavCustomers"><?php echo number_format($uniqueCustomers); ?></div>
                    </div>
                    <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-people"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0dcaf0,#0aa2c0);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Avg. Favorites per Customer</div>
                        <div class="stat-value" style="color:#0dcaf0;font-size:1.2rem;" id="statAvgPerCustomer"><?php echo number_format($avgPerCustomer, 1); ?></div>
                    </div>
                    <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="bi bi-bar-chart"></i></div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-lg-7 animate-in">
            <div class="msm-card h-100">
                <div class="p-3 border-bottom d-flex align-items-center justify-content-between">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-bar-chart-fill me-2"></i>Most Favorited Items</h6>
                    <select class="form-select form-select-sm" style="width:auto;" id="favPeriod" onchange="renderPlaceholderChart()">
                        <option value="all">All Time</option>
                        <option value="month">This Month</option>
                        <option value="week">This Week</option>
                    </select>
                </div>
                <div class="p-3" id="favoritesChartSection" style="height:260px;">
                    <canvas id="favoritesChart" height="220"></canvas>
                </div>
            </div>
        </div>
        <div class="col-lg-5 animate-in">
            <div class="msm-card h-100">
                <div class="p-3 border-bottom">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-lightning me-2 text-warning"></i>Popular Items</h6>
                </div>
                <div style="padding:0;" id="favoritesList">
                    <div class="empty-state py-4">
                        <i class="bi bi-heart"></i>
                        <p>Loading favorites data...</p>
                        <div class="spinner-border spinner-border-sm text-success mt-2" role="status"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-12 animate-in">
            <div class="msm-card">
                <div class="p-3 border-bottom d-flex align-items-center justify-content-between">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-grid-3x3 me-2"></i>All Favorited Items</h6>
                    <div class="d-flex align-items-center gap-2">
                        <input type="text" class="form-control form-control-sm" id="favTableSearch" placeholder="Search items..." style="width:160px;" onkeyup="filterFavTable()">
                    </div>
                </div>
                <div class="table-responsive">
                    <table class="table msm-table align-middle mb-0" id="favTable">
                        <thead class="table-light">
                            <tr>
                                <th>Item</th>
                                <th>Category</th>
                                <th>Favorites</th>
                                <th>Unique Customers</th>
                                <th>Popularity</th>
                                <th>Last Added</th>
                            </tr>
                        </thead>
                        <tbody id="favTableBody">
                            <tr>
                                <td colspan="6">
                                    <div class="empty-state py-4">
                                        <i class="bi bi-heart"></i>
                                        <p>Connecting to backend...</p>
                                        <div class="spinner-border text-success mt-2" role="status"></div>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-12 animate-in">
            <div class="msm-card">
                <div class="p-3 border-bottom d-flex align-items-center justify-content-between">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-clock-history me-2"></i>Recent Favorites Activity</h6>
                </div>
                <div id="recentFavActivity" style="max-height:400px;overflow-y:auto;">
                    <?php if (empty($recentFavorites)): ?>
                    <div class="empty-state py-4">
                        <i class="bi bi-heart"></i>
                        <p>No recent favorites activity.</p>
                        <p class="small text-muted">When customers favorite meals, activity will appear here.</p>
                    </div>
                    <?php else: ?>
                    <?php foreach ($recentFavorites as $rf): ?>
                    <div class="activity-item">
                        <div class="activity-avatar-placeholder" style="width:36px;height:36px;font-size:0.75rem;background:#dc3545;">
                            <i class="bi bi-heart"></i>
                        </div>
                        <div class="activity-content">
                            <div class="activity-title"><?php echo htmlspecialchars($rf['userName']); ?> favorited a meal</div>
                            <div class="activity-sub" style="font-size:0.78rem;"><?php echo htmlspecialchars($rf['mealName']); ?></div>
                        </div>
                        <div class="activity-time"><?php echo time_ago(strtotime($rf['createdAt'])); ?></div>
                    </div>
                    <?php endforeach; ?>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3" id="favToastContainer" style="z-index:9999;"></div>

<script>
var MSM_JWT = '<?php echo session_get_jwt(); ?>';
var favData = <?php echo json_encode($favItems); ?>;
var recentFavs = <?php echo json_encode($recentFavorites); ?>;

function showToast(msg, type) {
    type = type||'success'; var bg = type==='danger'?'bg-danger':type==='warning'?'bg-warning text-dark':'bg-success'; var c = document.getElementById('favToastContainer'); var el = document.createElement('div');
    el.className = 'toast align-items-center text-white border-0 '+bg;
    el.setAttribute('role','alert');
    el.innerHTML = '<div class="d-flex"><div class="toast-body"><i class="bi bi-'+ (type==='danger'?'x-circle':type==='warning'?'exclamation-circle':'check-circle') +' me-2"></i>'+ msg +'</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>';
    c.appendChild(el);
    var t = new bootstrap.Toast(el,{autohide:true,delay:4000}); t.show(); el.addEventListener('hidden.bs.toast',function(){el.remove();});
}

function escapeHtml(s) {
    if (!s) return ''; var d = document.createElement('div'); d.appendChild(document.createTextNode(s)); return d.innerHTML;
}

function loadData() {
    renderFavList(favData);
    renderFavTable(favData);
    renderChart();
}

function renderFavList(items) {
    var container = document.getElementById('favoritesList');
    if (!items || items.length === 0) {
        container.innerHTML = '<div class="empty-state py-4"><i class="bi bi-heart"></i><p>No favorites yet.</p><p class="small text-muted">When customers favorite meals, they will appear here.</p></div>';
        return;
    }
    var max = items[0] ? items[0].favorites : 1;
    var h = '';
    items.forEach(function(item, i) {
        var pct = max > 0 ? Math.round((item.favorites / max) * 100) : 0;
        var medal = '';
        if (i === 0) medal = '<span class="badge bg-warning text-dark" style="font-size:0.6rem;">#1</span>';
        else if (i <= 3) medal = '<span class="badge bg-secondary" style="font-size:0.6rem;">#' + (i + 1) + '</span>';
        h += '<div style="padding:0.65rem 1.25rem;" class="' + (i < items.length - 1 ? 'border-bottom' : '') + '">';
        h += '<div class="d-flex align-items-center gap-2 mb-1">';
        h += medal;
        h += '<span style="font-weight:500;font-size:0.82rem;flex:1;">' + escapeHtml(item.name) + '</span>';
        h += '<span style="font-weight:600;font-size:0.8rem;color:var(--msm-primary);">' + item.favorites + ' <small style="font-weight:400;color:var(--msm-muted);font-size:0.65rem;">hearts</small></span>';
        h += '</div>';
        h += '<div class="stock-progress" style="height:5px;"><div class="stock-bar good" style="width:' + pct + '%;"></div></div>';
        h += '</div>';
    });
    container.innerHTML = h;
}

function renderFavTable(items) {
    var tbody = document.getElementById('favTableBody');
    if (!items || items.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6"><div class="empty-state py-4"><i class="bi bi-heart"></i><p>No favorites data available.</p></div></td></tr>';
        return;
    }
    var max = items[0] ? items[0].favorites : 1;
    var h = '';
    items.forEach(function(item) {
        var favs = item.favorites || 0;
        var custs = (item.customers || []).length || 0;
        var pct = max > 0 ? Math.round((favs / max) * 100) : 0;
        var barClass = pct >= 70 ? 'good' : (pct >= 40 ? 'low' : 'critical');
        var lastAdd = item.lastAdded ? MSM.formatDate(item.lastAdded) : '—';

        h += '<tr>';
        h += '<td><div style="font-weight:500;font-size:0.85rem;">' + escapeHtml(item.name) + '</div></td>';
        h += '<td style="font-size:0.82rem;color:var(--msm-muted);">' + escapeHtml(item.category) + '</td>';
        h += '<td><strong>' + favs.toLocaleString() + '</strong></td>';
        h += '<td>' + custs.toLocaleString() + '</td>';
        h += '<td><div class="d-flex align-items-center gap-2"><div class="stock-progress" style="width:60px;"><div class="stock-bar ' + barClass + '" style="width:' + pct + '%;"></div></div><span style="font-size:0.75rem;color:var(--msm-muted);">' + pct + '%</span></div></td>';
        h += '<td style="font-size:0.78rem;color:var(--msm-muted);">' + lastAdd + '</td>';
        h += '</tr>';
    });
    tbody.innerHTML = h;
}

function filterFavTable() {
    var q = (document.getElementById('favTableSearch').value || '').toLowerCase();
    var filtered = favData.filter(function(item) {
        return item.name.toLowerCase().indexOf(q) !== -1 || item.category.toLowerCase().indexOf(q) !== -1;
    });
    if (filtered.length === 0) {
        document.getElementById('favTableBody').innerHTML = '<tr><td colspan="6"><div class="empty-state py-3"><p>No matches.</p></div></td></tr>';
    } else {
        renderFavTable(filtered);
    }
}

function renderChart() {
    var canvas = document.getElementById('favoritesChart');
    if (!canvas) return;
    var ctx = canvas.getContext('2d');

    if (window._favChart) { window._favChart.destroy(); window._favChart = null; }

    var topItems = favData.slice(0, 10);
    var names = topItems.map(function(i) { return i.name; });
    var vals = topItems.map(function(i) { return i.favorites; });

    if (typeof Chart === 'undefined') {
        canvas.parentElement.innerHTML = '<div class="empty-state py-4"><i class="bi bi-bar-chart"></i><p>Chart.js not loaded.</p></div>';
        return;
    }

    if (topItems.length === 0) {
        canvas.parentElement.innerHTML = '<div class="empty-state py-4"><i class="bi bi-bar-chart"></i><p>No favorites data to chart.</p></div>';
        return;
    }

    try {
        window._favChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: names,
                datasets: [{
                    label: 'Favorites',
                    data: vals,
                    backgroundColor: ['#dc3545', '#198754', '#ffc107', '#0d6efd', '#0dcaf0', '#6f42c1', '#dc3545', '#198754', '#ffc107', '#0d6efd'],
                    borderRadius: 6,
                    borderSkipped: false,
                    barPercentage: 0.6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: { callbacks: { label: function(t) { return t.raw + ' favorites'; } } }
                },
                scales: {
                    y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.04)' }, ticks: { font: {family:'Inter',size:10} } },
                    x: { grid: { display: false }, ticks: { font: {family:'Inter',size:9}, maxRotation: 45 } }
                }
            }
        });
    } catch(e) {}
}

function exportCsv() {
    if (!favData || favData.length === 0) { showToast('No data to export.', 'warning'); return; }
    var csv = 'Item,Category,Favorites,Unique Customers\n';
    favData.forEach(function(i) { csv += '"'+i.name+'","'+i.category+'",'+i.favorites+','+(i.customers||[]).length+'\n'; });
    var blob = new Blob([csv], {type:'text/csv'});
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'favorites_data.csv';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    setTimeout(function() { URL.revokeObjectURL(a.href); }, 100);
    showToast('CSV exported.');
}

function refreshData() {
    location.reload();
}

document.addEventListener('DOMContentLoaded', function() {
    loadData();
    MSM.initSearch('<?php echo API_ADMIN_SEARCH; ?>');
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
