<?php
/**
 * Forgot Password Screen
 *
 * Allows administrators to request a password reset OTP via email.
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/session.php';

if (session_is_logged_in()) {
    header('Location: ' . admin_url('pages/dashboard/dashboard.php'));
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password — <?php echo APP_NAME; ?></title>
    <link rel="icon" type="image/png" href="<?php echo asset_url('images/logo.png'); ?>">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        :root { --primary: #198754; --primary-dk: #146c43; --bg: #f4f7f5; --card-bg: #ffffff; --text: #212529; --muted: #6c757d; --border: #dee2e6; }
        *, *::before, *::after { box-sizing: border-box; }
        body { margin: 0; font-family: 'Inter', sans-serif; background: var(--bg); min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 2rem 1rem; }
        .login-wrapper { width: 100%; max-width: 440px; }
        .login-card { background: var(--card-bg); border-radius: 16px; box-shadow: 0 4px 24px rgba(0,0,0,0.06); padding: 2.5rem 2rem; border: 1px solid var(--border); }
        .login-logo { display: block; margin: 0 auto 1.25rem; width: 72px; height: 72px; object-fit: contain; }
        .login-title { text-align: center; font-size: 1.5rem; font-weight: 700; color: var(--text); margin-bottom: 0.25rem; }
        .login-subtitle { text-align: center; color: var(--muted); font-size: 0.9rem; margin-bottom: 1.75rem; }
        .form-label { font-weight: 500; font-size: 0.875rem; color: var(--text); margin-bottom: 0.35rem; }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 0.2rem rgba(25,135,84,0.15); }
        .btn-login { width: 100%; padding: 0.7rem; font-weight: 600; font-size: 1rem; border-radius: 10px; background: var(--primary); border-color: var(--primary); transition: background 0.2s, transform 0.1s; }
        .btn-login:hover { background: var(--primary-dk); border-color: var(--primary-dk); }
        .btn-login:active { transform: scale(0.98); }
        .login-footer { text-align: center; margin-top: 1.5rem; font-size: 0.8rem; color: var(--muted); }
        .login-alert { display: none; border-radius: 10px; font-size: 0.875rem; margin-bottom: 1rem; padding: 0.75rem 1rem; }
        .login-alert.show { display: block; }
        .login-alert.danger { background: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }
        .login-alert.success { background: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
        .back-link { text-align: center; margin-top: 1rem; }
        .back-link a { font-size: 0.875rem; color: var(--primary); text-decoration: none; }
        .back-link a:hover { text-decoration: underline; }
        .spinner-border-sm { width: 1rem; height: 1rem; border-width: .15em; }
    </style>
</head>
<body>

<div class="login-wrapper">
    <div class="login-card">
        <img src="<?php echo asset_url('images/logo.png'); ?>" alt="<?php echo APP_NAME; ?> Logo" class="login-logo" onerror="this.style.display='none'">
        <h1 class="login-title">Forgot Password?</h1>
        <p class="login-subtitle">Enter your email address and we'll send you an OTP to reset your password.</p>

        <div id="resetAlert" class="login-alert" role="alert"></div>

        <!-- Step 1: Enter email -->
        <form id="forgotForm" novalidate>
            <div class="mb-3">
                <label for="email" class="form-label">Email address</label>
                <input type="email" class="form-control" id="email" name="email" placeholder="admin@myspicemarket.com" autocomplete="email" required>
                <div class="invalid-feedback">Please enter a valid email address.</div>
            </div>
            <button type="submit" class="btn btn-success btn-login" id="submitBtn">
                <span id="btnText">Send OTP</span>
                <span id="btnSpinner" class="spinner-border spinner-border-sm d-none ms-1" role="status"></span>
            </button>
        </form>

        <!-- Step 2: Enter OTP + new password (hidden initially) -->
        <form id="resetForm" style="display:none;" novalidate>
            <div class="mb-3">
                <label for="otp" class="form-label">OTP Code</label>
                <input type="text" class="form-control" id="otp" name="otp" placeholder="Enter the 6-digit code" maxlength="6" required>
                <div class="invalid-feedback">Please enter the OTP code.</div>
            </div>
            <div class="mb-3">
                <label for="newPassword" class="form-label">New Password</label>
                <input type="password" class="form-control" id="newPassword" name="newPassword" placeholder="Enter new password" required>
                <div class="invalid-feedback">Password must be at least 6 characters.</div>
            </div>
            <div class="mb-3">
                <label for="confirmPassword" class="form-label">Confirm Password</label>
                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" placeholder="Confirm new password" required>
                <div class="invalid-feedback">Passwords do not match.</div>
            </div>
            <button type="submit" class="btn btn-success btn-login" id="resetBtn">
                <span id="resetBtnText">Reset Password</span>
                <span id="resetBtnSpinner" class="spinner-border spinner-border-sm d-none ms-1" role="status"></span>
            </button>
        </form>

    </div>
    <div class="back-link"><a href="<?php echo admin_url('auth/login.php'); ?>"><i class="bi bi-arrow-left me-1"></i>Back to Login</a></div>
    <p class="login-footer">&copy; <?php echo date('Y') . ' ' . APP_NAME . ' v' . APP_VERSION; ?></p>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
(function() {
    var API_BASE = '<?php echo API_BASE_URL; ?>';
    var forgotForm = document.getElementById('forgotForm');
    var resetForm = document.getElementById('resetForm');
    var alertBox = document.getElementById('resetAlert');
    var resetEmail = '';

    function showAlert(type, msg) { alertBox.className = 'login-alert show ' + type; alertBox.textContent = msg; }
    function hideAlert() { alertBox.className = 'login-alert'; }

    /* Step 1: Send OTP */
    forgotForm.addEventListener('submit', function(e) {
        e.preventDefault();
        hideAlert();
        var email = document.getElementById('email').value.trim();
        if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            document.getElementById('email').classList.add('is-invalid');
            return;
        }
        document.getElementById('email').classList.remove('is-invalid');
        document.getElementById('submitBtn').disabled = true;
        document.getElementById('btnText').textContent = 'Sending...';
        document.getElementById('btnSpinner').classList.remove('d-none');

        var xhr = new XMLHttpRequest();
        xhr.open('POST', API_BASE + '/auth/forgot-password', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            document.getElementById('submitBtn').disabled = false;
            document.getElementById('btnText').textContent = 'Send OTP';
            document.getElementById('btnSpinner').classList.add('d-none');
            try {
                var res = JSON.parse(xhr.responseText);
                if (xhr.status >= 200 && xhr.status < 300) {
                    resetEmail = email;
                    showAlert('success', 'OTP sent to your email. Please check your inbox.');
                    forgotForm.style.display = 'none';
                    resetForm.style.display = 'block';
                } else {
                    showAlert('danger', res.message || 'Failed to send OTP. Please try again.');
                }
            } catch (err) {
                showAlert('danger', 'An error occurred. Please try again.');
            }
        };
        xhr.onerror = function() {
            document.getElementById('submitBtn').disabled = false;
            document.getElementById('btnText').textContent = 'Send OTP';
            document.getElementById('btnSpinner').classList.add('d-none');
            showAlert('danger', 'Network error. Please check your connection.');
        };
        xhr.send(JSON.stringify({ email: email }));
    });

    /* Step 2: Reset password */
    resetForm.addEventListener('submit', function(e) {
        e.preventDefault();
        hideAlert();
        var otp = document.getElementById('otp').value.trim();
        var newPass = document.getElementById('newPassword').value;
        var confirmPass = document.getElementById('confirmPassword').value;
        var valid = true;

        if (!otp || otp.length < 4) { document.getElementById('otp').classList.add('is-invalid'); valid = false; } else { document.getElementById('otp').classList.remove('is-invalid'); }
        if (!newPass || newPass.length < 6) { document.getElementById('newPassword').classList.add('is-invalid'); valid = false; } else { document.getElementById('newPassword').classList.remove('is-invalid'); }
        if (newPass !== confirmPass) { document.getElementById('confirmPassword').classList.add('is-invalid'); valid = false; } else { document.getElementById('confirmPassword').classList.remove('is-invalid'); }
        if (!valid) return;

        document.getElementById('resetBtn').disabled = true;
        document.getElementById('resetBtnText').textContent = 'Resetting...';
        document.getElementById('resetBtnSpinner').classList.remove('d-none');

        /* First verify OTP */
        var xhr1 = new XMLHttpRequest();
        xhr1.open('POST', API_BASE + '/auth/verify-otp', true);
        xhr1.setRequestHeader('Content-Type', 'application/json');
        xhr1.onreadystatechange = function() {
            if (xhr1.readyState !== 4) return;
            try {
                var r1 = JSON.parse(xhr1.responseText);
                if (xhr1.status >= 200 && xhr1.status < 300 && (r1.success || r1.resetVerified)) {
                    /* Then reset password */
                    var xhr2 = new XMLHttpRequest();
                    xhr2.open('POST', API_BASE + '/auth/reset-password', true);
                    xhr2.setRequestHeader('Content-Type', 'application/json');
                    xhr2.onreadystatechange = function() {
                        if (xhr2.readyState !== 4) return;
                        document.getElementById('resetBtn').disabled = false;
                        document.getElementById('resetBtnText').textContent = 'Reset Password';
                        document.getElementById('resetBtnSpinner').classList.add('d-none');
                        try {
                            var r2 = JSON.parse(xhr2.responseText);
                            if (xhr2.status >= 200 && xhr2.status < 300) {
                                showAlert('success', 'Password reset successful! Redirecting to login...');
                                setTimeout(function() { window.location.href = '<?php echo admin_url("auth/login.php"); ?>'; }, 2000);
                            } else {
                                showAlert('danger', r2.message || 'Failed to reset password.');
                            }
                        } catch (err) {
                            showAlert('danger', 'An error occurred. Please try again.');
                        }
                    };
                    xhr2.onerror = function() {
                        document.getElementById('resetBtn').disabled = false;
                        document.getElementById('resetBtnText').textContent = 'Reset Password';
                        document.getElementById('resetBtnSpinner').classList.add('d-none');
                        showAlert('danger', 'Network error.');
                    };
                    xhr2.send(JSON.stringify({ email: resetEmail, otp: otp, newPassword: newPass }));
                } else {
                    document.getElementById('resetBtn').disabled = false;
                    document.getElementById('resetBtnText').textContent = 'Reset Password';
                    document.getElementById('resetBtnSpinner').classList.add('d-none');
                    showAlert('danger', r1.message || 'Invalid OTP code.');
                }
            } catch (err) {
                document.getElementById('resetBtn').disabled = false;
                document.getElementById('resetBtnText').textContent = 'Reset Password';
                document.getElementById('resetBtnSpinner').classList.add('d-none');
                showAlert('danger', 'Verification failed. Please try again.');
            }
        };
        xhr1.onerror = function() {
            document.getElementById('resetBtn').disabled = false;
            document.getElementById('resetBtnText').textContent = 'Reset Password';
            document.getElementById('resetBtnSpinner').classList.add('d-none');
            showAlert('danger', 'Network error.');
        };
        xhr1.send(JSON.stringify({ email: resetEmail, otp: otp }));
    });

    /* Clear validation on input */
    document.querySelectorAll('#forgotForm input, #resetForm input').forEach(function(el) {
        el.addEventListener('input', function() { el.classList.remove('is-invalid'); hideAlert(); });
    });
})();
</script>
</body>
</html>
