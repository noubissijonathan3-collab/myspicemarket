<?php
/**
 * Admin Profile
 *
 * View and edit admin profile, change password, upload avatar,
 * and view account information.
 */

$currentPage = 'profile';
$pageTitle   = 'My Profile';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt     = session_get_jwt();
$profile = api_request('GET', API_AUTH_ADMIN_PROFILE, null, $jwt);
$p       = $profile['body'] ?? [];

if (isset($p['user'])) $p = $p['user'];
if (isset($p['admin'])) $p = $p['admin'];

$pFullName     = $p['fullName'] ?? $adminName;
$pEmail        = $p['email']    ?? $adminEmail;
$pPhone        = $p['phone']    ?? '';
$pAvatar       = $p['profileImage'] ?? $adminAvatar;
$pRole         = $p['role']         ?? 'admin';
$pIsVerified   = $p['isVerified']   ?? false;
$pAddress      = $p['address']      ?? '';
if (is_array($pAddress)) {
    $pAddress = implode(', ', array_filter([
        $pAddress['street'] ?? '',
        $pAddress['quarter'] ?? '',
        $pAddress['city'] ?? '',
        $pAddress['landmark'] ?? '',
    ]));
}
$pCreatedAt    = $p['createdAt']    ?? '';
$pLastLogin    = $p['lastLogin']    ?? '';
$pId           = $p['_id'] ?? $p['id'] ?? '';

$initials = '';
$nameParts = explode(' ', $pFullName);
foreach ($nameParts as $part) {
    $initials .= strtoupper(substr(trim($part), 0, 1));
}
$initials = substr($initials, 0, 2);

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

    <div class="row g-4">

        <!-- LEFT COLUMN: Profile Card -->
        <div class="col-lg-4 animate-in">
            <div class="msm-card text-center">
                <div style="padding:2rem 1.5rem 1.5rem;">
                    <!-- Avatar -->
                    <div style="position:relative;display:inline-block;margin-bottom:1rem;">
                        <div id="profileAvatarDisplay" style="width:100px;height:100px;border-radius:50%;overflow:hidden;background:linear-gradient(135deg,#198754,#0d6e3f);display:flex;align-items:center;justify-content:center;margin:0 auto;border:4px solid #fff;box-shadow:0 4px 20px rgba(0,0,0,0.1);">
                            <?php if (!empty($pAvatar) && $pAvatar !== DEFAULT_AVATAR): ?>
                                <img src="<?php echo htmlspecialchars(img_url($pAvatar)); ?>" alt="Avatar" style="width:100%;height:100%;object-fit:cover;" onerror="this.parentElement.innerHTML='<span style=\'font-size:2rem;font-weight:700;color:#fff;\'><?php echo $initials; ?></span>'">
                            <?php else: ?>
                                <span style="font-size:2rem;font-weight:700;color:#fff;"><?php echo $initials; ?></span>
                            <?php endif; ?>
                        </div>
                        <label for="avatarUpload" style="position:absolute;bottom:2px;right:2px;width:32px;height:32px;border-radius:50%;background:#fff;display:flex;align-items:center;justify-content:center;cursor:pointer;box-shadow:0 2px 8px rgba(0,0,0,0.15);border:2px solid var(--msm-bg);transition:transform 0.2s;" title="Change avatar">
                            <i class="bi bi-camera" style="font-size:0.85rem;color:var(--msm-primary);"></i>
                        </label>
                        <input type="file" id="avatarUpload" accept="image/*" style="display:none;" onchange="Profile.uploadAvatar(this)">
                    </div>

                    <h5 style="font-weight:700;margin-bottom:0.25rem;"><?php echo htmlspecialchars($pFullName); ?></h5>
                    <p style="font-size:0.85rem;color:var(--msm-muted);margin-bottom:0.5rem;"><?php echo htmlspecialchars($pEmail); ?></p>
                    <span class="badge <?php echo $pIsVerified ? 'bg-success' : 'bg-secondary'; ?> badge-status" style="font-size:0.75rem;padding:4px 12px;">
                        <i class="bi bi-<?php echo $pIsVerified ? 'check-circle-fill' : 'clock'; ?> me-1"></i>
                        <?php echo $pIsVerified ? 'Verified' : 'Unverified'; ?>
                    </span>
                </div>
                <div style="border-top:1px solid var(--msm-border);padding:1rem 1.5rem;">
                    <div class="d-flex align-items-center justify-content-center gap-2" style="font-size:0.82rem;color:var(--msm-muted);">
                        <i class="bi bi-shield-lock"></i>
                        <span>Role: <strong style="color:var(--msm-text);"><?php echo ucfirst(htmlspecialchars($pRole)); ?></strong></span>
                    </div>
                </div>
            </div>

            <!-- Account Info -->
            <div class="msm-card mt-4">
                <div class="p-3 border-bottom">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-info-circle text-info me-2"></i>Account Details</h6>
                </div>
                <div class="p-3">
                    <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                        <span style="color:var(--msm-muted);">Full Name</span>
                        <span class="fw-semibold"><?php echo htmlspecialchars($pFullName); ?></span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                        <span style="color:var(--msm-muted);">Email</span>
                        <span class="fw-semibold"><?php echo htmlspecialchars($pEmail); ?></span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                        <span style="color:var(--msm-muted);">Phone</span>
                        <span class="fw-semibold"><?php echo htmlspecialchars($pPhone ?: 'Not set'); ?></span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                        <span style="color:var(--msm-muted);">Role</span>
                        <span class="fw-semibold"><?php echo ucfirst(htmlspecialchars($pRole)); ?></span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom" style="font-size:0.85rem;">
                        <span style="color:var(--msm-muted);">Member Since</span>
                        <span class="fw-semibold"><?php echo $pCreatedAt ? date('d M Y', strtotime($pCreatedAt)) : 'N/A'; ?></span>
                    </div>
                    <div class="d-flex justify-content-between py-2" style="font-size:0.85rem;">
                        <span style="color:var(--msm-muted);">Last Login</span>
                        <span class="fw-semibold"><?php echo $pLastLogin ? date('d M Y, H:i', strtotime($pLastLogin)) : 'N/A'; ?></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- RIGHT COLUMN: Edit Forms -->
        <div class="col-lg-8 animate-in">
            <!-- Edit Profile Form -->
            <div class="msm-card">
                <div class="p-3 border-bottom">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-pencil-square text-primary me-2"></i>Edit Profile</h6>
                </div>
                <div class="p-3">
                    <form id="editProfileForm" onsubmit="Profile.saveProfile(event)">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label" style="font-size:0.82rem;font-weight:600;">Full Name</label>
                                <input type="text" class="form-control" id="editFullName" value="<?php echo htmlspecialchars($pFullName); ?>" style="border-radius:8px;" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label" style="font-size:0.82rem;font-weight:600;">Email Address</label>
                                <input type="email" class="form-control" id="editEmail" value="<?php echo htmlspecialchars($pEmail); ?>" style="border-radius:8px;" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label" style="font-size:0.82rem;font-weight:600;">Phone Number</label>
                                <input type="tel" class="form-control" id="editPhone" value="<?php echo htmlspecialchars($pPhone); ?>" style="border-radius:8px;" placeholder="+237 XXX XXX XXX">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label" style="font-size:0.82rem;font-weight:600;">Address</label>
                                <input type="text" class="form-control" id="editAddress" value="<?php echo htmlspecialchars($pAddress); ?>" style="border-radius:8px;" placeholder="Your address">
                            </div>
                        </div>
                        <div class="d-flex justify-content-end mt-3">
                            <button type="submit" class="btn btn-msm" id="saveProfileBtn" style="border-radius:8px;padding:8px 28px;font-size:0.88rem;font-weight:600;">
                                <i class="bi bi-check-lg me-1"></i>Save Profile
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Change Password Form -->
            <div class="msm-card mt-4">
                <div class="p-3 border-bottom">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-lock text-warning me-2"></i>Change Password</h6>
                </div>
                <div class="p-3">
                    <form id="changePasswordForm" onsubmit="Profile.changePassword(event)">
                        <div class="row g-3">
                            <div class="col-12">
                                <label class="form-label" style="font-size:0.82rem;font-weight:600;">Current Password</label>
                                <div class="position-relative">
                                    <input type="password" class="form-control" id="currentPassword" style="border-radius:8px;padding-right:40px;" required>
                                    <button type="button" class="btn position-absolute" style="right:4px;top:50%;transform:translateY(-50%);padding:4px 8px;" onclick="Profile.togglePassword('currentPassword', this)">
                                        <i class="bi bi-eye" style="font-size:0.9rem;color:var(--msm-muted);"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label" style="font-size:0.82rem;font-weight:600;">New Password</label>
                                <div class="position-relative">
                                    <input type="password" class="form-control" id="newPassword" style="border-radius:8px;padding-right:40px;" minlength="6" required>
                                    <button type="button" class="btn position-absolute" style="right:4px;top:50%;transform:translateY(-50%);padding:4px 8px;" onclick="Profile.togglePassword('newPassword', this)">
                                        <i class="bi bi-eye" style="font-size:0.9rem;color:var(--msm-muted);"></i>
                                    </button>
                                </div>
                                <div id="passwordStrength" class="mt-2" style="display:none;">
                                    <div style="height:4px;border-radius:2px;background:var(--msm-bg);overflow:hidden;">
                                        <div id="passwordStrengthBar" style="height:100%;width:0;border-radius:2px;transition:all 0.3s;"></div>
                                    </div>
                                    <small id="passwordStrengthText" style="font-size:0.75rem;"></small>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label" style="font-size:0.82rem;font-weight:600;">Confirm Password</label>
                                <div class="position-relative">
                                    <input type="password" class="form-control" id="confirmPassword" style="border-radius:8px;padding-right:40px;" minlength="6" required>
                                    <button type="button" class="btn position-absolute" style="right:4px;top:50%;transform:translateY(-50%);padding:4px 8px;" onclick="Profile.togglePassword('confirmPassword', this)">
                                        <i class="bi bi-eye" style="font-size:0.9rem;color:var(--msm-muted);"></i>
                                    </button>
                                </div>
                                <div id="passwordMatch" class="mt-1" style="display:none;font-size:0.75rem;"></div>
                            </div>
                        </div>
                        <div class="d-flex justify-content-end mt-3">
                            <button type="submit" class="btn btn-msm" id="changePasswordBtn" style="border-radius:8px;padding:8px 28px;font-size:0.88rem;font-weight:600;background:#ffc107;border-color:#ffc107;color:#000;">
                                <i class="bi bi-shield-lock me-1"></i>Update Password
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Danger Zone -->
            <div class="msm-card mt-4" style="border:1px solid rgba(220,53,69,0.2);">
                <div class="p-3 border-bottom" style="border-color:rgba(220,53,69,0.15) !important;">
                    <h6 class="mb-0 fw-bold" style="color:#dc3545;"><i class="bi bi-exclamation-triangle me-2"></i>Danger Zone</h6>
                </div>
                <div class="p-3 d-flex align-items-center justify-content-between">
                    <div>
                        <div style="font-size:0.88rem;font-weight:600;">Delete Account</div>
                        <div style="font-size:0.8rem;color:var(--msm-muted);">Permanently delete your admin account. This action cannot be undone.</div>
                    </div>
                    <button class="btn btn-sm" style="background:#dc3545;color:#fff;border:none;border-radius:8px;padding:6px 16px;font-size:0.82rem;" onclick="Profile.confirmDelete()">
                        <i class="bi bi-trash me-1"></i>Delete
                    </button>
                </div>
            </div>
        </div>

    </div>

</div>

<!-- TOAST -->
<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index:9999;">
    <div id="profileToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-header" style="border-radius:12px 12px 0 0;">
            <i class="bi bi-check-circle-fill text-success me-2" id="profToastIcon"></i>
            <strong class="me-auto" id="profToastTitle">Profile</strong>
            <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div class="toast-body" id="profToastMsg" style="border-radius:0 0 12px 12px;font-size:0.88rem;"></div>
    </div>
</div>

<script>
var MSM_JWT = '<?php echo session_get_jwt(); ?>';
var API_AUTH_ME = '<?php echo API_AUTH_ME; ?>';

var Profile = {
    init: function() {
        var self = this;

        document.getElementById('newPassword').addEventListener('input', function() {
            self.checkPasswordStrength(this.value);
        });
        document.getElementById('confirmPassword').addEventListener('input', function() {
            self.checkPasswordMatch();
        });
    },

    saveProfile: function(e) {
        e.preventDefault();
        var btn = document.getElementById('saveProfileBtn');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Saving...';

        var payload = {
            fullName: document.getElementById('editFullName').value.trim(),
            email: document.getElementById('editEmail').value.trim(),
            phone: document.getElementById('editPhone').value.trim(),
            address: document.getElementById('editAddress').value.trim()
        };

        var self = this;
        var xhr = new XMLHttpRequest();
        xhr.open('PUT', API_AUTH_ME, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Authorization', 'Bearer ' + MSM_JWT);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-check-lg me-1"></i>Save Profile';
            try {
                var res = JSON.parse(xhr.responseText);
                if (xhr.status >= 200 && xhr.status < 300) {
                    self.showToast('Profile updated successfully.', 'success');
                    setTimeout(function() { location.reload(); }, 1500);
                } else {
                    self.showToast(res.message || 'Failed to update profile.', 'danger');
                }
            } catch (ex) {
                self.showToast('Failed to update profile.', 'danger');
            }
        };
        xhr.onerror = function() {
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-check-lg me-1"></i>Save Profile';
            self.showToast('Network error.', 'danger');
        };
        xhr.send(JSON.stringify(payload));
    },

    changePassword: function(e) {
        e.preventDefault();

        var current = document.getElementById('currentPassword').value;
        var newPass = document.getElementById('newPassword').value;
        var confirm = document.getElementById('confirmPassword').value;

        if (newPass !== confirm) {
            this.showToast('New passwords do not match.', 'danger');
            return;
        }
        if (newPass.length < 6) {
            this.showToast('Password must be at least 6 characters.', 'danger');
            return;
        }

        var btn = document.getElementById('changePasswordBtn');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Updating...';

        var self = this;
        var xhr = new XMLHttpRequest();
        xhr.open('PUT', API_AUTH_ME, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Authorization', 'Bearer ' + MSM_JWT);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-shield-lock me-1"></i>Update Password';
            try {
                var res = JSON.parse(xhr.responseText);
                if (xhr.status >= 200 && xhr.status < 300) {
                    self.showToast('Password updated successfully.', 'success');
                    document.getElementById('changePasswordForm').reset();
                    document.getElementById('passwordStrength').style.display = 'none';
                    document.getElementById('passwordMatch').style.display = 'none';
                } else {
                    self.showToast(res.message || 'Failed to update password. Check your current password.', 'danger');
                }
            } catch (ex) {
                self.showToast('Failed to update password.', 'danger');
            }
        };
        xhr.onerror = function() {
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-shield-lock me-1"></i>Update Password';
            self.showToast('Network error.', 'danger');
        };
        xhr.send(JSON.stringify({
            currentPassword: current,
            password: newPass
        }));
    },

    uploadAvatar: function(input) {
        if (!input.files || !input.files[0]) return;
        var file = input.files[0];
        if (file.size > 5 * 1024 * 1024) {
            this.showToast('Image must be under 5MB.', 'danger');
            return;
        }

        var self = this;
        var reader = new FileReader();
        reader.onload = function(e) {
            var display = document.getElementById('profileAvatarDisplay');
            display.innerHTML = '<img src="' + e.target.result + '" style="width:100%;height:100%;object-fit:cover;">';

            var formData = new FormData();
            formData.append('profileImage', file);

            var xhr = new XMLHttpRequest();
            xhr.open('PUT', API_AUTH_ME, true);
            xhr.setRequestHeader('Authorization', 'Bearer ' + MSM_JWT);
            xhr.onreadystatechange = function() {
                if (xhr.readyState !== 4) return;
                try {
                    var res = JSON.parse(xhr.responseText);
                    if (xhr.status >= 200 && xhr.status < 300) {
                        self.showToast('Avatar updated.', 'success');
                    } else {
                        self.showToast(res.message || 'Failed to upload avatar.', 'danger');
                    }
                } catch (ex) {
                    self.showToast('Failed to upload avatar.', 'danger');
                }
            };
            xhr.send(formData);
        };
        reader.readAsDataURL(file);
    },

    togglePassword: function(inputId, btn) {
        var input = document.getElementById(inputId);
        var icon = btn.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.className = 'bi bi-eye-slash';
        } else {
            input.type = 'password';
            icon.className = 'bi bi-eye';
        }
    },

    checkPasswordStrength: function(password) {
        var wrapper = document.getElementById('passwordStrength');
        var bar = document.getElementById('passwordStrengthBar');
        var text = document.getElementById('passwordStrengthText');

        if (!password) {
            wrapper.style.display = 'none';
            return;
        }
        wrapper.style.display = 'block';

        var score = 0;
        if (password.length >= 6) score++;
        if (password.length >= 10) score++;
        if (/[A-Z]/.test(password)) score++;
        if (/[0-9]/.test(password)) score++;
        if (/[^A-Za-z0-9]/.test(password)) score++;

        var levels = [
            { width: '20%', color: '#dc3545', label: 'Very Weak' },
            { width: '40%', color: '#fd7e14', label: 'Weak' },
            { width: '60%', color: '#ffc107', label: 'Fair' },
            { width: '80%', color: '#20c997', label: 'Strong' },
            { width: '100%', color: '#198754', label: 'Very Strong' }
        ];

        var level = levels[Math.min(score, 4)];
        bar.style.width = level.width;
        bar.style.background = level.color;
        text.textContent = level.label;
        text.style.color = level.color;
    },

    checkPasswordMatch: function() {
        var newPass = document.getElementById('newPassword').value;
        var confirm = document.getElementById('confirmPassword').value;
        var matchEl = document.getElementById('passwordMatch');

        if (!confirm) {
            matchEl.style.display = 'none';
            return;
        }
        matchEl.style.display = 'block';
        if (newPass === confirm) {
            matchEl.textContent = 'Passwords match';
            matchEl.style.color = '#198754';
        } else {
            matchEl.textContent = 'Passwords do not match';
            matchEl.style.color = '#dc3545';
        }
    },

    confirmDelete: function() {
        if (confirm('Are you sure you want to delete your account? This action is irreversible and all your data will be lost.')) {
            this.showToast('Account deletion is currently disabled for security.', 'warning');
        }
    },

    showToast: function(message, type) {
        var toastEl = document.getElementById('profileToast');
        var iconEl = document.getElementById('profToastIcon');
        var titleEl = document.getElementById('profToastTitle');
        var msgEl = document.getElementById('profToastMsg');

        msgEl.textContent = message;
        iconEl.className = 'bi me-2 ' + (type === 'success' ? 'bi-check-circle-fill text-success' : (type === 'warning' ? 'bi-exclamation-circle-fill text-warning' : 'bi-exclamation-circle-fill text-danger'));
        titleEl.textContent = type === 'success' ? 'Success' : (type === 'warning' ? 'Warning' : 'Error');

        var toast = new bootstrap.Toast(toastEl);
        toast.show();
    }
};

document.addEventListener('DOMContentLoaded', function() {
    Profile.init();
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
