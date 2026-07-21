<?php
/**
 * Inventory Management
 *
 * Tracks all foodstuff stock levels with color-coded status,
 * stock adjustment modals, low-stock alerts, and search/filter.
 */

$currentPage = 'inventory';
$pageTitle   = 'Inventory Management';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt    = session_get_jwt();
$result = api_request('GET', API_FOODSTUFFS, null, $jwt);
$foods  = ($result['body'] ?? []);

if (is_array($foods) && isset($foods['data'])) {
    $foods = $foods['data'];
} elseif (is_array($foods) && isset($foods['foodstuffs'])) {
    $foods = $foods['foodstuffs'];
}

$foods = is_array($foods) ? $foods : [];

$totalProducts  = count($foods);
$inStock        = 0;
$lowStockCount  = 0;
$outOfStock     = 0;
$lowStockItems  = [];

foreach ($foods as $food) {
    $stock = (int)($food['stock'] ?? 0);
    if ($stock <= 0) {
        $outOfStock++;
    } elseif ($stock < 10) {
        $lowStockCount++;
        $lowStockItems[] = $food;
    } else {
        $inStock++;
    }
}

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

    <!-- STAT CARDS -->
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Total Products</div>
                        <div class="stat-value" style="color:#198754;" data-count="<?php echo $totalProducts; ?>"><?php echo number_format($totalProducts); ?></div>
                    </div>
                    <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-box-seam"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0d6efd,#0b5ed7);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">In Stock</div>
                        <div class="stat-value" style="color:#0d6efd;" data-count="<?php echo $inStock; ?>"><?php echo number_format($inStock); ?></div>
                    </div>
                    <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-check-circle"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Low Stock</div>
                        <div class="stat-value" style="color:#e0a800;" data-count="<?php echo $lowStockCount; ?>"><?php echo number_format($lowStockCount); ?></div>
                        <div class="stat-change"><i class="bi bi-exclamation-triangle"></i> &lt;10 units</div>
                    </div>
                    <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-exclamation-triangle"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#dc3545,#b02a37);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Out of Stock</div>
                        <div class="stat-value" style="color:#dc3545;" data-count="<?php echo $outOfStock; ?>"><?php echo number_format($outOfStock); ?></div>
                    </div>
                    <div class="stat-icon bg-danger bg-opacity-10 text-danger"><i class="bi bi-x-circle"></i></div>
                </div>
            </div>
        </div>
    </div>

    <!-- LOW STOCK ALERTS -->
    <?php if (!empty($lowStockItems)): ?>
    <div class="alert d-flex align-items-center gap-3 mb-4 animate-in" style="background:#fff3cd;border:1px solid #ffecb5;border-radius:12px;padding:1rem 1.25rem;">
        <div style="width:40px;height:40px;border-radius:10px;background:#ffc107;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
            <i class="bi bi-exclamation-triangle" style="color:#fff;font-size:1.1rem;"></i>
        </div>
        <div class="flex-grow-1">
            <strong style="color:#664d03;">Low Stock Alert</strong>
            <div style="font-size:0.85rem;color:#664d03;opacity:0.85;">
                <?php echo count($lowStockItems); ?> product<?php echo count($lowStockItems) > 1 ? 's' : ''; ?> running low on stock.
                Items needing attention: <?php echo htmlspecialchars(implode(', ', array_map(fn($f) => $f['name'] ?? 'Unknown', array_slice($lowStockItems, 0, 5)))); ?><?php echo count($lowStockItems) > 5 ? '...' : ''; ?>
            </div>
        </div>
        <button class="btn btn-sm" style="background:#664d03;color:#fff;border-radius:8px;" onclick="document.getElementById('stockFilter').value='low';Inventory.filterByStatus('low');">
            View Items
        </button>
    </div>
    <?php endif; ?>

    <!-- INVENTORY TABLE -->
    <div class="msm-card p-0 animate-in">
        <div class="table-toolbar">
            <div class="d-flex align-items-center gap-2 flex-wrap">
                <h6 class="mb-0 fw-bold">Stock Overview</h6>
            </div>
            <div class="d-flex align-items-center gap-2 flex-wrap">
                <div class="position-relative">
                    <i class="bi bi-search" style="position:absolute;left:10px;top:50%;transform:translateY(-50%);font-size:0.8rem;color:var(--msm-muted);"></i>
                    <input type="text" class="form-control form-control-sm" id="inventorySearch" placeholder="Search products..." style="padding-left:30px;width:200px;border-radius:8px;">
                </div>
                <select class="form-select form-select-sm" id="stockFilter" style="width:150px;border-radius:8px;">
                    <option value="all">All Status</option>
                    <option value="in-stock">In Stock</option>
                    <option value="low">Low Stock</option>
                    <option value="out">Out of Stock</option>
                </select>
                <button class="btn btn-sm btn-msm" onclick="Inventory.refresh()" title="Refresh">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
            </div>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0" id="inventoryTable">
                <thead class="table-light">
                    <tr>
                        <th style="width:50px;">Image</th>
                        <th>Name</th>
                        <th>Category</th>
                        <th>Stock Level</th>
                        <th>Status</th>
                        <th>Unit</th>
                        <th style="width:100px;">Actions</th>
                    </tr>
                </thead>
                <tbody id="inventoryBody">
                    <?php if (empty($foods)): ?>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state py-5">
                                <i class="bi bi-clipboard-data"></i>
                                <p>No inventory data available.</p>
                            </div>
                        </td>
                    </tr>
                    <?php else: ?>
                        <?php foreach ($foods as $food): ?>
                        <?php
                            $stock = (int)($food['stock'] ?? 0);
                            if ($stock <= 0) {
                                $statusClass = 'out';
                                $badgeClass  = 'bg-danger';
                                $statusText  = 'Out of Stock';
                                $barClass    = 'danger';
                            } elseif ($stock < 5) {
                                $statusClass = 'low';
                                $badgeClass  = 'bg-warning text-dark';
                                $statusText  = 'Low Stock';
                                $barClass    = 'danger';
                            } elseif ($stock < 10) {
                                $statusClass = 'low';
                                $badgeClass  = 'bg-warning text-dark';
                                $statusText  = 'Low Stock';
                                $barClass    = 'warning';
                            } else {
                                $statusClass = 'in-stock';
                                $badgeClass  = 'bg-success';
                                $statusText  = 'In Stock';
                                $barClass    = 'success';
                            }
                            $pct = min(100, ($stock / 50) * 100);
                        ?>
                        <tr class="inventory-row" data-status="<?php echo $statusClass; ?>" data-name="<?php echo htmlspecialchars(strtolower($food['name'] ?? '')); ?>">
                            <td>
                                <div style="width:40px;height:40px;border-radius:10px;overflow:hidden;background:var(--msm-bg);">
                                    <?php if (!empty($food['image'])): ?>
                                        <img src="<?php echo htmlspecialchars(img_url($food['image'])); ?>" alt="" style="width:100%;height:100%;object-fit:cover;">
                                    <?php else: ?>
                                        <div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;color:var(--msm-muted);font-size:1.1rem;">
                                            <i class="bi bi-image"></i>
                                        </div>
                                    <?php endif; ?>
                                </div>
                            </td>
                            <td>
                                <div style="font-weight:600;font-size:0.88rem;"><?php echo htmlspecialchars($food['name'] ?? 'Unknown'); ?></div>
                            </td>
                            <td>
                                <span style="font-size:0.82rem;color:var(--msm-muted);"><?php echo htmlspecialchars($food['category'] ?? $food['categoryId']['name'] ?? 'N/A'); ?></span>
                            </td>
                            <td style="min-width:160px;">
                                <div class="d-flex align-items-center gap-2">
                                    <div style="flex:1;height:8px;background:var(--msm-bg);border-radius:4px;overflow:hidden;">
                                        <div style="height:100%;width:<?php echo $pct; ?>%;background:<?php echo $barClass === 'success' ? '#198754' : ($barClass === 'warning' ? '#ffc107' : '#dc3545'); ?>;border-radius:4px;transition:width 0.5s ease;"></div>
                                    </div>
                                    <span style="font-size:0.8rem;font-weight:600;min-width:30px;text-align:right;"><?php echo $stock; ?></span>
                                </div>
                            </td>
                            <td><span class="badge <?php echo $badgeClass; ?> badge-status"><?php echo $statusText; ?></span></td>
                            <td><span style="font-size:0.82rem;color:var(--msm-muted);"><?php echo htmlspecialchars($food['unit'] ?? 'kg'); ?></span></td>
                            <td>
                                <button class="btn btn-sm" style="background:var(--msm-bg);border:none;border-radius:8px;padding:4px 10px;font-size:0.8rem;" title="Adjust Stock" onclick='Inventory.adjustStock(<?php echo json_encode($food); ?>)'>
                                    <i class="bi bi-pencil-square"></i> Adjust
                                </button>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        <?php if (count($foods) > 20): ?>
        <div class="d-flex justify-content-between align-items-center px-3 py-2 border-top" style="font-size:0.82rem;color:var(--msm-muted);">
            <span>Showing <strong><?php echo count($foods); ?></strong> products</span>
        </div>
        <?php endif; ?>
    </div>

</div>

<!-- ADJUST STOCK MODAL -->
<div class="modal fade" id="adjustStockModal" tabindex="-1" aria-labelledby="adjustStockModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:16px;border:none;box-shadow:0 20px 60px rgba(0,0,0,0.15);">
            <div class="modal-header" style="border-bottom:1px solid var(--msm-border);padding:1rem 1.25rem;">
                <h6 class="modal-title fw-bold" id="adjustStockModalLabel"><i class="bi bi-pencil-square text-primary me-2"></i>Adjust Stock</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding:1.25rem;">
                <div class="d-flex align-items-center gap-3 mb-3 p-3" style="background:var(--msm-bg);border-radius:12px;">
                    <div id="adjustProductImage" style="width:48px;height:48px;border-radius:10px;overflow:hidden;background:#e9ecef;display:flex;align-items:center;justify-content:center;">
                        <i class="bi bi-image" style="color:var(--msm-muted);"></i>
                    </div>
                    <div>
                        <div style="font-weight:600;font-size:0.9rem;" id="adjustProductName">Product Name</div>
                        <div style="font-size:0.8rem;color:var(--msm-muted);" id="adjustProductCategory">Category</div>
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label" style="font-size:0.82rem;font-weight:600;">Current Stock</label>
                    <div class="d-flex align-items-center gap-2">
                        <input type="number" class="form-control" id="adjustCurrentStock" readonly style="background:var(--msm-bg);border-radius:8px;font-weight:600;">
                        <span style="font-size:0.82rem;color:var(--msm-muted);" id="adjustUnit">units</span>
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label" style="font-size:0.82rem;font-weight:600;">New Stock Level</label>
                    <input type="number" class="form-control" id="adjustNewStock" min="0" placeholder="Enter new stock value" style="border-radius:8px;">
                    <div class="form-text" style="font-size:0.75rem;">Set the new stock quantity for this product.</div>
                </div>
                <input type="hidden" id="adjustProductId">
            </div>
            <div class="modal-footer" style="border-top:1px solid var(--msm-border);padding:0.75rem 1.25rem;">
                <button type="button" class="btn btn-sm" style="background:var(--msm-bg);border:none;border-radius:8px;padding:6px 16px;" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-sm btn-msm" onclick="Inventory.saveStock()" id="saveStockBtn">
                    <i class="bi bi-check-lg me-1"></i>Save Changes
                </button>
            </div>
        </div>
    </div>
</div>

<!-- TOAST -->
<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index:9999;">
    <div id="inventoryToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-header" style="border-radius:12px 12px 0 0;">
            <i class="bi bi-check-circle-fill text-success me-2" id="toastIcon"></i>
            <strong class="me-auto" id="toastTitle">Success</strong>
            <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div class="toast-body" id="toastMessage" style="border-radius:0 0 12px 12px;font-size:0.88rem;"></div>
    </div>
</div>

<script>
var MSM_JWT = '<?php echo session_get_jwt(); ?>';

var Inventory = {
    adjustStockModal: null,

    init: function() {
        var self = this;
        self.adjustStockModal = new bootstrap.Modal(document.getElementById('adjustStockModal'));

        document.getElementById('inventorySearch').addEventListener('input', function() {
            self.filterTable();
        });
        document.getElementById('stockFilter').addEventListener('change', function() {
            self.filterByStatus(this.value);
        });
    },

    filterTable: function() {
        var query = document.getElementById('inventorySearch').value.toLowerCase();
        var statusFilter = document.getElementById('stockFilter').value;
        var rows = document.querySelectorAll('.inventory-row');

        rows.forEach(function(row) {
            var name = row.getAttribute('data-name') || '';
            var status = row.getAttribute('data-status') || '';
            var matchSearch = name.indexOf(query) !== -1;
            var matchStatus = statusFilter === 'all' || status === statusFilter;
            row.style.display = (matchSearch && matchStatus) ? '' : 'none';
        });
    },

    filterByStatus: function(status) {
        document.getElementById('stockFilter').value = status;
        this.filterTable();
    },

    adjustStock: function(food) {
        document.getElementById('adjustProductName').textContent = food.name || 'Unknown';
        document.getElementById('adjustProductCategory').textContent = food.category || food.categoryId?.name || 'N/A';
        document.getElementById('adjustCurrentStock').value = food.stock ?? 0;
        document.getElementById('adjustNewStock').value = food.stock ?? 0;
        document.getElementById('adjustProductId').value = food._id || food.id || '';
        document.getElementById('adjustUnit').textContent = food.unit || 'units';

        var imgEl = document.getElementById('adjustProductImage');
        if (food.image) {
            imgEl.innerHTML = '<img src="' + msmImgUrl(food.image) + '" style="width:100%;height:100%;object-fit:cover;">';
        } else {
            imgEl.innerHTML = '<i class="bi bi-image" style="color:var(--msm-muted);"></i>';
        }

        this.adjustStockModal.show();
        setTimeout(function() { document.getElementById('adjustNewStock').focus(); }, 300);
    },

    saveStock: function() {
        var id = document.getElementById('adjustProductId').value;
        var newStock = document.getElementById('adjustNewStock').value;
        var btn = document.getElementById('saveStockBtn');

        if (newStock === '' || parseInt(newStock) < 0) {
            this.showToast('Error', 'Please enter a valid stock value.', 'danger');
            return;
        }

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Saving...';

        var self = this;
        MSM.ajax('POST', '<?php echo admin_url("api/auth_api.php"); ?>', {
            action: 'update_stock',
            foodstuff_id: id,
            stock: parseInt(newStock),
            jwt: MSM_JWT
        }, function(res) {
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-check-lg me-1"></i>Save Changes';
            self.adjustStockModal.hide();
            self.showToast('Success', 'Stock level updated successfully.', 'success');
            setTimeout(function() { location.reload(); }, 1200);
        }, function(err) {
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-check-lg me-1"></i>Save Changes';
            self.showToast('Error', err.message || 'Failed to update stock.', 'danger');
        });
    },

    refresh: function() {
        location.reload();
    },

    showToast: function(title, message, type) {
        var toastEl = document.getElementById('inventoryToast');
        var iconEl = document.getElementById('toastIcon');
        var titleEl = document.getElementById('toastTitle');
        var msgEl = document.getElementById('toastMessage');

        titleEl.textContent = title;
        msgEl.textContent = message;
        iconEl.className = 'bi me-2 ' + (type === 'success' ? 'bi-check-circle-fill text-success' : 'bi-exclamation-circle-fill text-danger');

        var toast = new bootstrap.Toast(toastEl);
        toast.show();
    }
};

document.addEventListener('DOMContentLoaded', function() {
    Inventory.init();
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
