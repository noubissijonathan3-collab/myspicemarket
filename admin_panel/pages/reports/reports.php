<?php
/**
 * Reports & Analytics
 *
 * Full analytics dashboard with revenue charts, order distribution,
 * date range filtering, and export capabilities.
 */

$currentPage = 'reports';
$pageTitle   = 'Reports & Analytics';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt    = session_get_jwt();
$result = api_request('GET', API_ADMIN_REPORTS, null, $jwt);
$r      = $result['body'] ?? [];

$totalRevenue    = $r['totalRevenue']    ?? 0;
$totalOrders     = $r['totalOrders']     ?? 0;
$avgOrderValue   = $r['avgOrderValue']   ?? 0;
$activeCustomers = $r['activeCustomers'] ?? 0;
$monthlyRevenue  = $r['monthlyRevenue']  ?? [];
$orderStatusDist = $r['orderStatusDistribution'] ?? [];
$monthlyComparison = $r['monthlyComparison'] ?? [];

$prevMonthRevenue  = $r['prevMonthRevenue']  ?? 0;
$prevMonthOrders   = $r['prevMonthOrders']   ?? 0;
$revenueGrowth     = $prevMonthRevenue > 0 ? round((($totalRevenue - $prevMonthRevenue) / $prevMonthRevenue) * 100, 1) : 0;
$ordersGrowth      = $prevMonthOrders > 0 ? round((($totalOrders - $prevMonthOrders) / $prevMonthOrders) * 100, 1) : 0;

include __DIR__ . '/../../includes/header.php';
include __DIR__ . '/../../includes/sidebar.php';
include __DIR__ . '/../../includes/loader.php';
?>

<div class="sidebar-overlay" id="sidebarOverlay" onclick="MSM.toggleSidebar()"></div>

<div class="admin-content">

    <!-- TOP NAVBAR -->
    <div class="admin-navbar">
        <div class="navbar-left">
            <button class="btn btn-sm d-lg-none" onclick="MSM.toggleSidebar()" style="font-size:1.2rem;color:var(--msm-muted);">
                <i class="bi bi-list"></i>
            </button>
            <div class="navbar-brand-text"><span><?php echo $pageTitle; ?></span></div>
        </div>
        <div class="navbar-right">
            <div style="position:relative;">
                <button class="navbar-icon-btn" onclick="MSM.toggleDropdown('notifDropdown')" title="Notifications"><i class="bi bi-bell"></i></button>
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

    <!-- DATE FILTER & EXPORT -->
    <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4 animate-in">
        <div class="d-flex align-items-center gap-2 flex-wrap">
            <div class="d-flex align-items-center gap-2">
                <label style="font-size:0.82rem;font-weight:600;color:var(--msm-muted);white-space:nowrap;">From</label>
                <input type="date" class="form-control form-control-sm" id="dateFrom" style="border-radius:8px;width:160px;">
            </div>
            <div class="d-flex align-items-center gap-2">
                <label style="font-size:0.82rem;font-weight:600;color:var(--msm-muted);white-space:nowrap;">To</label>
                <input type="date" class="form-control form-control-sm" id="dateTo" style="border-radius:8px;width:160px;">
            </div>
            <button class="btn btn-sm btn-msm" onclick="Reports.filterByDate()" style="border-radius:8px;">
                <i class="bi bi-funnel me-1"></i>Apply
            </button>
            <button class="btn btn-sm" style="background:var(--msm-bg);border:none;border-radius:8px;padding:6px 12px;font-size:0.82rem;" onclick="Reports.resetDates()">
                Reset
            </button>
        </div>
        <div class="d-flex align-items-center gap-2">
            <button class="btn btn-sm" style="background:var(--msm-bg);border:none;border-radius:8px;padding:6px 14px;font-size:0.82rem;" onclick="Reports.exportCSV()">
                <i class="bi bi-filetype-csv me-1"></i>Export CSV
            </button>
            <button class="btn btn-sm" style="background:var(--msm-bg);border:none;border-radius:8px;padding:6px 14px;font-size:0.82rem;" onclick="window.print()">
                <i class="bi bi-printer me-1"></i>Print
            </button>
        </div>
    </div>

    <!-- STAT CARDS -->
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Total Revenue</div>
                        <div class="stat-value" style="color:#198754;font-size:1.3rem;" data-count="<?php echo $totalRevenue; ?>"><?php echo number_format($totalRevenue); ?></div>
                        <div class="stat-change <?php echo $revenueGrowth >= 0 ? 'up' : 'down'; ?>">
                            <i class="bi bi-arrow-<?php echo $revenueGrowth >= 0 ? 'up' : 'down'; ?>"></i> <?php echo abs($revenueGrowth); ?>% vs last month
                        </div>
                    </div>
                    <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-currency-exchange"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0d6efd,#0b5ed7);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Total Orders</div>
                        <div class="stat-value" style="color:#0d6efd;font-size:1.3rem;" data-count="<?php echo $totalOrders; ?>"><?php echo number_format($totalOrders); ?></div>
                        <div class="stat-change <?php echo $ordersGrowth >= 0 ? 'up' : 'down'; ?>">
                            <i class="bi bi-arrow-<?php echo $ordersGrowth >= 0 ? 'up' : 'down'; ?>"></i> <?php echo abs($ordersGrowth); ?>% vs last month
                        </div>
                    </div>
                    <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-cart-check"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#6f42c1,#5a32a3);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Avg Order Value</div>
                        <div class="stat-value" style="color:#6f42c1;font-size:1.3rem;" data-count="<?php echo $avgOrderValue; ?>"><?php echo number_format($avgOrderValue); ?></div>
                        <div class="stat-label" style="text-transform:none;font-weight:400;">FCFA per order</div>
                    </div>
                    <div class="stat-icon bg-purple bg-opacity-10" style="background:rgba(111,66,193,0.1);color:#6f42c1;"><i class="bi bi-receipt"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0dcaf0,#0aa2c0);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Active Customers</div>
                        <div class="stat-value" style="color:#0aa2c0;font-size:1.3rem;" data-count="<?php echo $activeCustomers; ?>"><?php echo number_format($activeCustomers); ?></div>
                        <div class="stat-label" style="text-transform:none;font-weight:400;">with orders</div>
                    </div>
                    <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="bi bi-people"></i></div>
                </div>
            </div>
        </div>
    </div>

    <!-- CHARTS ROW -->
    <div class="row g-4 mb-4">
        <!-- Revenue Chart -->
        <div class="col-lg-8 animate-in">
            <div class="chart-card">
                <div class="chart-header">
                    <h6><i class="bi bi-graph-up-arrow text-success me-2"></i>Revenue Overview</h6>
                    <div class="chart-tabs">
                        <button class="chart-tab active" data-period="monthly" onclick="Reports.switchRevenueTab(this)">Monthly</button>
                        <button class="chart-tab" data-period="quarterly" onclick="Reports.switchRevenueTab(this)">Quarterly</button>
                    </div>
                </div>
                <div class="chart-body">
                    <canvas id="revenueChart" height="280"></canvas>
                </div>
            </div>
        </div>

        <!-- Order Status Doughnut -->
        <div class="col-lg-4 animate-in">
            <div class="chart-card">
                <div class="chart-header">
                    <h6><i class="bi bi-pie-chart text-primary me-2"></i>Order Status</h6>
                </div>
                <div class="chart-body">
                    <canvas id="orderStatusChart" height="280"></canvas>
                </div>
                <?php if (!empty($orderStatusDist)): ?>
                <div class="px-3 pb-3">
                    <?php foreach ($orderStatusDist as $item): ?>
                    <?php
                        $label = $item['_id'] ?? 'Unknown';
                        $count = $item['count'] ?? 0;
                        $totalForPct = max(1, $totalOrders);
                        $pct = round(($count / $totalForPct) * 100);
                    ?>
                    <div class="d-flex align-items-center justify-content-between py-1" style="font-size:0.82rem;border-bottom:1px solid var(--msm-bg);">
                        <span class="d-flex align-items-center gap-2">
                            <span style="width:8px;height:8px;border-radius:50%;background:<?php
                                $colors = ['Delivered'=>'#198754','Confirmed'=>'#0dcaf0','Preparing'=>'#ffc107','Pending'=>'#6c757d','Cancelled'=>'#dc3545','Out for Delivery'=>'#0d6efd'];
                                echo $colors[$label] ?? '#6c757d';
                            ?>;"></span>
                            <?php echo htmlspecialchars($label); ?>
                        </span>
                        <span><strong><?php echo number_format($count); ?></strong> <span class="text-muted">(<?php echo $pct; ?>%)</span></span>
                    </div>
                    <?php endforeach; ?>
                </div>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <!-- MONTHLY COMPARISON -->
    <?php if (!empty($monthlyComparison)): ?>
    <div class="row g-4 mb-4">
        <div class="col-12 animate-in">
            <div class="chart-card">
                <div class="chart-header">
                    <h6><i class="bi bi-bar-chart text-warning me-2"></i>Monthly Comparison</h6>
                </div>
                <div class="chart-body">
                    <canvas id="monthlyComparisonChart" height="240"></canvas>
                </div>
            </div>
        </div>
    </div>
    <?php endif; ?>

    <!-- REVENUE BREAKDOWN TABLE -->
    <div class="row g-4 mb-4">
        <div class="col-lg-7 animate-in">
            <div class="msm-card p-0">
                <div class="table-toolbar">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-calendar-month text-primary me-2"></i>Monthly Revenue Breakdown</h6>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Month</th>
                                <th>Revenue (FCFA)</th>
                                <th>Trend</th>
                            </tr>
                        </thead>
                        <tbody>
                        <?php
                        $months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                        $revMap = [];
                        foreach ($monthlyRevenue as $mr) {
                            $revMap[$mr['_id'] ?? 0] = $mr['revenue'] ?? 0;
                        }
                        $maxRev = max(array_values($revMap) ?: [1]);
                        for ($i = 1; $i <= 12; $i++):
                            $rev = $revMap[$i] ?? 0;
                            $barW = $maxRev > 0 ? round(($rev / $maxRev) * 100) : 0;
                        ?>
                        <tr>
                            <td style="font-weight:600;font-size:0.85rem;"><?php echo $months[$i - 1]; ?></td>
                            <td>
                                <div class="d-flex align-items-center gap-3">
                                    <span style="font-size:0.85rem;font-weight:600;min-width:90px;"><?php echo number_format($rev); ?></span>
                                    <div style="flex:1;height:8px;background:var(--msm-bg);border-radius:4px;overflow:hidden;max-width:200px;">
                                        <div style="height:100%;width:<?php echo $barW; ?>%;background:#198754;border-radius:4px;"></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span style="font-size:0.78rem;color:var(--msm-muted);"><?php echo number_format($rev); ?> FCFA</span>
                            </td>
                        </tr>
                        <?php endfor; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- INSIGHTS PANEL -->
        <div class="col-lg-5 animate-in">
            <div class="msm-card">
                <div class="p-3 border-bottom">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-lightbulb text-warning me-2"></i>Key Insights</h6>
                </div>
                <div class="p-3">
                    <div class="d-flex align-items-start gap-3 mb-3 pb-3 border-bottom">
                        <div style="width:36px;height:36px;border-radius:10px;background:rgba(25,135,84,0.1);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                            <i class="bi bi-graph-up-arrow" style="color:#198754;font-size:0.9rem;"></i>
                        </div>
                        <div>
                            <div style="font-size:0.85rem;font-weight:600;">Revenue Trend</div>
                            <div style="font-size:0.8rem;color:var(--msm-muted);">
                                <?php echo $revenueGrowth >= 0 ? 'Revenue is growing by ' . abs($revenueGrowth) . '% compared to last month.' : 'Revenue decreased by ' . abs($revenueGrowth) . '% from last month.'; ?>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex align-items-start gap-3 mb-3 pb-3 border-bottom">
                        <div style="width:36px;height:36px;border-radius:10px;background:rgba(13,110,253,0.1);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                            <i class="bi bi-cart-check" style="color:#0d6efd;font-size:0.9rem;"></i>
                        </div>
                        <div>
                            <div style="font-size:0.85rem;font-weight:600;">Order Volume</div>
                            <div style="font-size:0.8rem;color:var(--msm-muted);">
                                <?php echo $ordersGrowth >= 0 ? 'Orders increased by ' . abs($ordersGrowth) . '% this month.' : 'Order volume decreased by ' . abs($ordersGrowth) . '%.'; ?>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex align-items-start gap-3 mb-3 pb-3 border-bottom">
                        <div style="width:36px;height:36px;border-radius:10px;background:rgba(111,66,193,0.1);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                            <i class="bi bi-receipt" style="color:#6f42c1;font-size:0.9rem;"></i>
                        </div>
                        <div>
                            <div style="font-size:0.85rem;font-weight:600;">Average Order</div>
                            <div style="font-size:0.8rem;color:var(--msm-muted);">
                                Customers spend an average of <?php echo number_format($avgOrderValue); ?> FCFA per order.
                            </div>
                        </div>
                    </div>
                    <div class="d-flex align-items-start gap-3">
                        <div style="width:36px;height:36px;border-radius:10px;background:rgba(13,202,240,0.1);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                            <i class="bi bi-people" style="color:#0aa2c0;font-size:0.9rem;"></i>
                        </div>
                        <div>
                            <div style="font-size:0.85rem;font-weight:600;">Customer Base</div>
                            <div style="font-size:0.8rem;color:var(--msm-muted);">
                                <?php echo number_format($activeCustomers); ?> active customer<?php echo $activeCustomers !== 1 ? 's' : ''; ?> with recorded orders.
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>

<!-- TOAST -->
<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index:9999;">
    <div id="reportToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-header">
            <i class="bi bi-check-circle-fill text-success me-2" id="rptToastIcon"></i>
            <strong class="me-auto" id="rptToastTitle">Report</strong>
            <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div class="toast-body" id="rptToastMsg"></div>
    </div>
</div>

<script>
var MSM_JWT = '<?php echo session_get_jwt(); ?>';

var Reports = {
    revenueChart: null,
    statusChart: null,
    comparisonChart: null,

    data: {
        monthlyRevenue: <?php echo json_encode($monthlyRevenue); ?>,
        orderStatusDist: <?php echo json_encode($orderStatusDist); ?>,
        monthlyComparison: <?php echo json_encode($monthlyComparison); ?>,
        totalRevenue: <?php echo $totalRevenue; ?>,
        totalOrders: <?php echo $totalOrders; ?>
    },

    init: function() {
        this.renderRevenueChart('monthly');
        this.renderStatusChart();
        if (this.data.monthlyComparison.length) {
            this.renderComparisonChart();
        }
        var today = new Date();
        var firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        document.getElementById('dateTo').value = today.toISOString().split('T')[0];
        document.getElementById('dateFrom').value = firstDay.toISOString().split('T')[0];
    },

    renderRevenueChart: function(mode) {
        var ctx = document.getElementById('revenueChart');
        if (!ctx) return;
        if (this.revenueChart) this.revenueChart.destroy();

        var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        var revMap = {};
        this.data.monthlyRevenue.forEach(function(r) { revMap[r._id] = r.revenue; });

        var labels, data;
        if (mode === 'quarterly') {
            labels = ['Q1','Q2','Q3','Q4'];
            data = [
                (revMap[1]||0)+(revMap[2]||0)+(revMap[3]||0),
                (revMap[4]||0)+(revMap[5]||0)+(revMap[6]||0),
                (revMap[7]||0)+(revMap[8]||0)+(revMap[9]||0),
                (revMap[10]||0)+(revMap[11]||0)+(revMap[12]||0)
            ];
        } else {
            labels = months;
            data = [];
            for (var i = 1; i <= 12; i++) data.push(revMap[i] || 0);
        }

        this.revenueChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Revenue (FCFA)',
                    data: data,
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
    },

    renderStatusChart: function() {
        var ctx = document.getElementById('orderStatusChart');
        if (!ctx) return;
        if (this.statusChart) this.statusChart.destroy();

        var dist = this.data.orderStatusDist;
        if (!dist.length) {
            ctx.parentElement.innerHTML = '<div class="empty-state py-4"><i class="bi bi-pie-chart"></i><p>No order data yet.</p></div>';
            return;
        }

        var labels = dist.map(function(d) { return d._id || 'Other'; });
        var counts = dist.map(function(d) { return d.count; });
        var colors = ['#198754','#0dcaf0','#ffc107','#6c757d','#dc3545','#0d6efd','#6f42c1'];

        this.statusChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    data: counts,
                    backgroundColor: colors.slice(0, labels.length),
                    borderWidth: 0,
                    hoverOffset: 6,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '65%',
                plugins: {
                    legend: { display: false }
                }
            }
        });
    },

    renderComparisonChart: function() {
        var ctx = document.getElementById('monthlyComparisonChart');
        if (!ctx) return;
        if (this.comparisonChart) this.comparisonChart.destroy();

        var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        var comp = this.data.monthlyComparison;
        var revCurrent = [], revPrev = [];
        var revCurrMap = {}, revPrevMap = {};

        comp.forEach(function(c) {
            if (c.current !== undefined) {
                (Array.isArray(c.current) ? c.current : [c]).forEach(function(m) {
                    revCurrMap[m._id || m.month] = m.revenue || 0;
                });
            }
        });

        this.data.monthlyRevenue.forEach(function(r) { revCurrMap[r._id] = r.revenue; });

        for (var i = 1; i <= 12; i++) {
            revCurrent.push(revCurrMap[i] || 0);
            revPrev.push(revPrevMap[i] || 0);
        }

        this.comparisonChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: months,
                datasets: [{
                    label: 'This Year',
                    data: revCurrent,
                    backgroundColor: 'rgba(25,135,84,0.7)',
                    borderRadius: 6,
                    barPercentage: 0.6,
                },{
                    label: 'Previous Period',
                    data: revPrev,
                    backgroundColor: 'rgba(108,117,125,0.3)',
                    borderRadius: 6,
                    barPercentage: 0.6,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'top', labels: { font: { size: 11, family: 'Inter' }, usePointStyle: true, pointStyleWidth: 8 } }
                },
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
                }
            }
        });
    },

    switchRevenueTab: function(btn) {
        document.querySelectorAll('.chart-tabs .chart-tab').forEach(function(t) { t.classList.remove('active'); });
        btn.classList.add('active');
        this.renderRevenueChart(btn.getAttribute('data-period'));
    },

    filterByDate: function() {
        var from = document.getElementById('dateFrom').value;
        var to = document.getElementById('dateTo').value;
        if (!from || !to) {
            this.showToast('Please select both dates.', 'warning');
            return;
        }
        var self = this;
        MSM.apiGet('<?php echo API_ADMIN_REPORTS; ?>?from=' + from + '&to=' + to, function(res) {
            if (res && (res.totalRevenue !== undefined || res.monthlyRevenue)) {
                self.data.monthlyRevenue = res.monthlyRevenue || [];
                self.data.orderStatusDist = res.orderStatusDistribution || [];
                self.data.totalRevenue = res.totalRevenue || 0;
                self.data.totalOrders = res.totalOrders || 0;
                self.renderRevenueChart('monthly');
                self.renderStatusChart();
                self.showToast('Report filtered for selected date range.', 'success');
            }
        }, function() {
            self.showToast('Failed to filter report data.', 'danger');
        });
    },

    resetDates: function() {
        location.reload();
    },

    exportCSV: function() {
        var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        var revMap = {};
        this.data.monthlyRevenue.forEach(function(r) { revMap[r._id] = r.revenue; });

        var csv = 'Month,Revenue (FCFA)\n';
        for (var i = 1; i <= 12; i++) {
            csv += months[i-1] + ',' + (revMap[i] || 0) + '\n';
        }

        var blob = new Blob([csv], { type: 'text/csv' });
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.download = 'spicemarket-reports-' + new Date().toISOString().split('T')[0] + '.csv';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        setTimeout(function() { URL.revokeObjectURL(url); }, 100);
        this.showToast('CSV exported successfully.', 'success');
    },

    showToast: function(message, type) {
        var toastEl = document.getElementById('reportToast');
        var iconEl = document.getElementById('rptToastIcon');
        var titleEl = document.getElementById('rptToastTitle');
        var msgEl = document.getElementById('rptToastMsg');

        msgEl.textContent = message;
        iconEl.className = 'bi me-2 ' + (type === 'success' ? 'bi-check-circle-fill text-success' : 'bi-exclamation-circle-fill text-warning');
        titleEl.textContent = type === 'success' ? 'Success' : 'Notice';

        var toast = new bootstrap.Toast(toastEl);
        toast.show();
    }
};

document.addEventListener('DOMContentLoaded', function() {
    Reports.init();
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
