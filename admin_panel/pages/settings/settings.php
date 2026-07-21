<?php
/**
 * System Settings
 *
 * Admin panel configuration: general settings, notifications,
 * and maintenance mode. Loads current settings from the API
 * and saves via PUT request.
 */

$currentPage = 'settings';
$pageTitle   = 'Settings';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt      = session_get_jwt();
$result   = api_request('GET', API_ADMIN_SETTINGS, null, $jwt);
$settings = $result['body'] ?? [];

$deliveryFee   = $settings['deliveryFee'] ?? 1500;
$currency      = $settings['currency']    ?? 'FCFA';
$tax           = $settings['tax']         ?? 0;
$appName       = $settings['appName']     ?? APP_NAME;
$currencyCode  = $settings['currencyCode'] ?? 'XAF';

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

    <!-- SETTINGS FORM -->
    <form id="settingsForm" onsubmit="Settings.save(event)">
        <div class="row g-4">

            <!-- GENERAL SETTINGS -->
            <div class="col-lg-8 animate-in">
                <div class="msm-card">
                    <div class="p-3 border-bottom">
                        <h6 class="mb-0 fw-bold"><i class="bi bi-gear text-primary me-2"></i>General Settings</h6>
                    </div>
                    <div class="p-3">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label" style="font-size:0.82rem;font-weight:600;">Application Name</label>
                                <input type="text" class="form-control" id="appName" value="<?php echo htmlspecialchars($appName); ?>" style="border-radius:8px;" required>
                                <div class="form-text">The display name shown in the admin panel and customer app.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label" style="font-size:0.82rem;font-weight:600;">Currency</label>
                                <select class="form-select" id="currency" style="border-radius:8px;">
                                    <option value="FCFA" <?php echo $currency === 'FCFA' ? 'selected' : ''; ?>>FCFA (CFA Franc)</option>
                                    <option value="USD" <?php echo $currency === 'USD' ? 'selected' : ''; ?>>USD (US Dollar)</option>
                                    <option value="EUR" <?php echo $currency === 'EUR' ? 'selected' : ''; ?>>EUR (Euro)</option>
                                    <option value="NGN" <?php echo $currency === 'NGN' ? 'selected' : ''; ?>>NGN (Naira)</option>
                                </select>
                                <div class="form-text">Currency used for all price displays.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label" style="font-size:0.82rem;font-weight:600;">Delivery Fee</label>
                                <div class="input-group" style="border-radius:8px;overflow:hidden;">
                                    <input type="number" class="form-control" id="deliveryFee" value="<?php echo htmlspecialchars($deliveryFee); ?>" min="0" step="50" style="border-radius:8px 0 0 8px;" required>
                                    <span class="input-group-text" style="background:var(--msm-bg);border:none;font-size:0.82rem;font-weight:600;"><?php echo htmlspecialchars($currency); ?></span>
                                </div>
                                <div class="form-text">Default delivery charge applied to every order.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label" style="font-size:0.82rem;font-weight:600;">Tax Rate</label>
                                <div class="input-group" style="border-radius:8px;overflow:hidden;">
                                    <input type="number" class="form-control" id="taxRate" value="<?php echo htmlspecialchars($tax); ?>" min="0" max="100" step="0.5" style="border-radius:8px 0 0 8px;" required>
                                    <span class="input-group-text" style="background:var(--msm-bg);border:none;font-size:0.82rem;font-weight:600;">%</span>
                                </div>
                                <div class="form-text">Tax percentage applied to orders (0 for no tax).</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- NOTIFICATIONS SETTINGS -->
                <div class="msm-card mt-4">
                    <div class="p-3 border-bottom">
                        <h6 class="mb-0 fw-bold"><i class="bi bi-bell text-warning me-2"></i>Notifications</h6>
                    </div>
                    <div class="p-3">
                        <div class="d-flex align-items-center justify-content-between py-3 border-bottom">
                            <div>
                                <div style="font-size:0.88rem;font-weight:600;">Email Notifications</div>
                                <div style="font-size:0.8rem;color:var(--msm-muted);">Send email alerts for new orders, low stock, and system events.</div>
                            </div>
                            <div class="form-check form-switch mb-0">
                                <input class="form-check-input" type="checkbox" id="emailNotifications" checked style="cursor:pointer;">
                            </div>
                        </div>
                        <div class="d-flex align-items-center justify-content-between py-3 border-bottom">
                            <div>
                                <div style="font-size:0.88rem;font-weight:600;">Low Stock Alerts</div>
                                <div style="font-size:0.8rem;color:var(--msm-muted);">Get notified when product stock drops below threshold.</div>
                            </div>
                            <div class="form-check form-switch mb-0">
                                <input class="form-check-input" type="checkbox" id="lowStockAlerts" checked style="cursor:pointer;">
                            </div>
                        </div>
                        <div class="d-flex align-items-center justify-content-between py-3">
                            <div>
                                <div style="font-size:0.88rem;font-weight:600;">Order Status Updates</div>
                                <div style="font-size:0.8rem;color:var(--msm-muted);">Notify customers when their order status changes.</div>
                            </div>
                            <div class="form-check form-switch mb-0">
                                <input class="form-check-input" type="checkbox" id="orderStatusNotifs" checked style="cursor:pointer;">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- MAINTENANCE SETTINGS -->
                <div class="msm-card mt-4">
                    <div class="p-3 border-bottom">
                        <h6 class="mb-0 fw-bold"><i class="bi bi-tools text-danger me-2"></i>Maintenance</h6>
                    </div>
                    <div class="p-3">
                        <div class="d-flex align-items-center justify-content-between py-3">
                            <div>
                                <div style="font-size:0.88rem;font-weight:600;">Maintenance Mode</div>
                                <div style="font-size:0.8rem;color:var(--msm-muted);">Temporarily disable customer access to the app while performing updates.</div>
                            </div>
                            <div class="form-check form-switch mb-0">
                                <input class="form-check-input" type="checkbox" id="maintenanceMode" style="cursor:pointer;">
                            </div>
                        </div>
                        <div id="maintenanceWarning" class="alert alert-danger d-none mb-0 mt-2" style="border-radius:10px;font-size:0.85rem;">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i>
                            <strong>Warning:</strong> Enabling maintenance mode will prevent customers from placing orders. Only admin users will have access.
                        </div>
                    </div>
                </div>

                <!-- SAVE BUTTON -->
                <div class="d-flex justify-content-end gap-2 mt-4 mb-4">
                    <button type="button" class="btn" style="background:var(--msm-bg);border:none;border-radius:10px;padding:8px 24px;font-size:0.88rem;font-weight:600;" onclick="location.reload();">
                        <i class="bi bi-arrow-counterclockwise me-1"></i>Reset
                    </button>
                    <button type="submit" class="btn btn-msm" id="saveSettingsBtn" style="border-radius:10px;padding:8px 32px;font-size:0.88rem;font-weight:600;">
                        <i class="bi bi-check-lg me-1"></i>Save Settings
                    </button>
                </div>
            </div>

            <!-- SIDEBAR INFO -->
            <div class="col-lg-4 animate-in">
                <!-- Current Config Summary -->
                <div class="msm-card mb-4">
                    <div class="p-3 border-bottom">
                        <h6 class="mb-0 fw-bold"><i class="bi bi-info-circle text-info me-2"></i>Current Configuration</h6>
                    </div>
                    <div class="p-3">
                        <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                            <span style="color:var(--msm-muted);">App Name</span>
                            <span class="fw-semibold" id="summaryAppName"><?php echo htmlspecialchars($appName); ?></span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                            <span style="color:var(--msm-muted);">Currency</span>
                            <span class="fw-semibold" id="summaryCurrency"><?php echo htmlspecialchars($currency); ?></span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                            <span style="color:var(--msm-muted);">Delivery Fee</span>
                            <span class="fw-semibold" id="summaryFee"><?php echo number_format($deliveryFee); ?> FCFA</span>
                        </div>
                        <div class="d-flex justify-content-between py-2" style="font-size:0.85rem;">
                            <span style="color:var(--msm-muted);">Tax Rate</span>
                            <span class="fw-semibold" id="summaryTax"><?php echo htmlspecialchars($tax); ?>%</span>
                        </div>
                    </div>
                </div>

                <!-- System Info -->
                <div class="msm-card">
                    <div class="p-3 border-bottom">
                        <h6 class="mb-0 fw-bold"><i class="bi bi-pc-display text-secondary me-2"></i>System Info</h6>
                    </div>
                    <div class="p-3">
                        <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                            <span style="color:var(--msm-muted);">Admin Panel</span>
                            <span class="fw-semibold">v<?php echo APP_VERSION; ?></span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                            <span style="color:var(--msm-muted);">Backend</span>
                            <span class="fw-semibold">Node.js</span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                            <span style="color:var(--msm-muted);">API Status</span>
                            <span class="fw-semibold" style="color:#198754;" id="apiStatus">
                                <i class="bi bi-circle-fill" style="font-size:0.5rem;vertical-align:middle;"></i> Connected
                            </span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                            <span style="color:var(--msm-muted);">Environment</span>
                            <span class="fw-semibold"><?php echo ucfirst(APP_ENV); ?></span>
                        </div>
                        <div class="d-flex justify-content-between py-2" style="font-size:0.85rem;">
                            <span style="color:var(--msm-muted);">Timezone</span>
                            <span class="fw-semibold">Africa/Douala</span>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </form>

</div>

<!-- TOAST -->
<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index:9999;">
    <div id="settingsToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-header" style="border-radius:12px 12px 0 0;">
            <i class="bi bi-check-circle-fill text-success me-2" id="setToastIcon"></i>
            <strong class="me-auto" id="setToastTitle">Settings</strong>
            <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div class="toast-body" id="setToastMsg" style="border-radius:0 0 12px 12px;font-size:0.88rem;"></div>
    </div>
</div>

<script>
var MSM_JWT = '<?php echo session_get_jwt(); ?>';

var Settings = {
    init: function() {
        var self = this;

        document.getElementById('maintenanceMode').addEventListener('change', function() {
            var warning = document.getElementById('maintenanceWarning');
            if (this.checked) {
                warning.classList.remove('d-none');
            } else {
                warning.classList.add('d-none');
            }
        });

        ['appName','currency','deliveryFee','taxRate'].forEach(function(id) {
            var el = document.getElementById(id);
            if (el) {
                el.addEventListener('input', function() { self.updateSummary(); });
                el.addEventListener('change', function() { self.updateSummary(); });
            }
        });

        this.pingApi();
    },

    updateSummary: function() {
        var appName = document.getElementById('appName').value;
        var currency = document.getElementById('currency').value;
        var fee = document.getElementById('deliveryFee').value;
        var tax = document.getElementById('taxRate').value;

        document.getElementById('summaryAppName').textContent = appName || '<?php echo APP_NAME; ?>';
        document.getElementById('summaryCurrency').textContent = currency;
        document.getElementById('summaryFee').textContent = MSM.formatCurrency(parseFloat(fee) || 0);
        document.getElementById('summaryTax').textContent = tax + '%';
    },

    save: function(e) {
        e.preventDefault();

        var btn = document.getElementById('saveSettingsBtn');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Saving...';

        var payload = {
            appName: document.getElementById('appName').value,
            currency: document.getElementById('currency').value,
            deliveryFee: parseFloat(document.getElementById('deliveryFee').value) || 0,
            tax: parseFloat(document.getElementById('taxRate').value) || 0,
            emailNotifications: document.getElementById('emailNotifications').checked,
            lowStockAlerts: document.getElementById('lowStockAlerts').checked,
            orderStatusNotifications: document.getElementById('orderStatusNotifs').checked,
            maintenanceMode: document.getElementById('maintenanceMode').checked
        };

        var self = this;
        var xhr = new XMLHttpRequest();
        xhr.open('PUT', '<?php echo API_ADMIN_SETTINGS; ?>', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Authorization', 'Bearer ' + MSM_JWT);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-check-lg me-1"></i>Save Settings';

            try {
                var res = JSON.parse(xhr.responseText);
                if (xhr.status >= 200 && xhr.status < 300) {
                    self.showToast('Settings saved successfully.', 'success');
                    self.updateSummary();
                } else {
                    self.showToast(res.message || 'Failed to save settings.', 'danger');
                }
            } catch (ex) {
                self.showToast('Failed to save settings.', 'danger');
            }
        };
        xhr.onerror = function() {
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-check-lg me-1"></i>Save Settings';
            self.showToast('Network error. Please try again.', 'danger');
        };
        xhr.send(JSON.stringify(payload));
    },

    pingApi: function() {
        var statusEl = document.getElementById('apiStatus');
        MSM.apiGet('<?php echo API_ADMIN_SETTINGS; ?>', function() {
            statusEl.innerHTML = '<i class="bi bi-circle-fill" style="font-size:0.5rem;vertical-align:middle;"></i> Connected';
            statusEl.style.color = '#198754';
        }, function() {
            statusEl.innerHTML = '<i class="bi bi-circle-fill" style="font-size:0.5rem;vertical-align:middle;"></i> Disconnected';
            statusEl.style.color = '#dc3545';
        });
    },

    showToast: function(message, type) {
        var toastEl = document.getElementById('settingsToast');
        var iconEl = document.getElementById('setToastIcon');
        var titleEl = document.getElementById('setToastTitle');
        var msgEl = document.getElementById('setToastMsg');

        msgEl.textContent = message;
        iconEl.className = 'bi me-2 ' + (type === 'success' ? 'bi-check-circle-fill text-success' : 'bi-exclamation-circle-fill text-danger');
        titleEl.textContent = type === 'success' ? 'Success' : 'Error';

        var toast = new bootstrap.Toast(toastEl);
        toast.show();
    }
};

document.addEventListener('DOMContentLoaded', function() {
    Settings.init();
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
