<?php
/**
 * Administrator Login Screen
 * 
 * Full-page login form that communicates with login_process.php via AJAX.
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/session.php';

// Redirect if already logged in
if (session_is_logged_in()) {
    header('Location: ' . admin_url('pages/dashboard/dashboard.php'));
    exit;
}

$timeoutMsg = isset($_GET['timeout']) ? 'Your session has expired. Please log in again.' : null;
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login — <?php echo APP_NAME; ?></title>
    <link rel="icon" type="image/png" href="<?php echo asset_url('images/logo.png'); ?>">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <style>
        :root {
            --primary:   #198754;
            --primary-dk: #146c43;
            --bg:        #f4f7f5;
            --card-bg:   #ffffff;
            --text:      #212529;
            --muted:     #6c757d;
            --border:    #dee2e6;
        }

        *, *::before, *::after { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem 1rem;
        }

        .login-wrapper {
            width: 100%;
            max-width: 440px;
        }

        .login-card {
            background: var(--card-bg);
            border-radius: 16px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.06);
            padding: 2.5rem 2rem;
            border: 1px solid var(--border);
        }

        .login-logo {
            display: block;
            margin: 0 auto 1.25rem;
            width: 72px;
            height: 72px;
            object-fit: contain;
        }

        .login-title {
            text-align: center;
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text);
            margin-bottom: 0.25rem;
        }

        .login-subtitle {
            text-align: center;
            color: var(--muted);
            font-size: 0.9rem;
            margin-bottom: 1.75rem;
        }

        .form-label {
            font-weight: 500;
            font-size: 0.875rem;
            color: var(--text);
            margin-bottom: 0.35rem;
        }

        .input-group .form-control {
            border-right: 0;
        }

        .input-group .btn-outline-secondary {
            border-left: 0;
            color: var(--muted);
            background: var(--card-bg);
            border-color: var(--border);
        }

        .input-group .btn-outline-secondary:hover {
            background: #f8f9fa;
            color: var(--text);
        }

        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(25,135,84,0.15);
        }

        .remember-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.5rem;
        }

        .form-check-input:checked {
            background-color: var(--primary);
            border-color: var(--primary);
        }

        .forgot-link {
            font-size: 0.85rem;
            color: var(--primary);
            text-decoration: none;
        }
        .forgot-link:hover { text-decoration: underline; }

        .btn-login {
            width: 100%;
            padding: 0.7rem;
            font-weight: 600;
            font-size: 1rem;
            border-radius: 10px;
            background: var(--primary);
            border-color: var(--primary);
            transition: background 0.2s, transform 0.1s;
        }
        .btn-login:hover {
            background: var(--primary-dk);
            border-color: var(--primary-dk);
        }
        .btn-login:active { transform: scale(0.98); }

        .login-footer {
            text-align: center;
            margin-top: 1.5rem;
            font-size: 0.8rem;
            color: var(--muted);
        }

        /* Alert */
        .login-alert {
            display: none;
            border-radius: 10px;
            font-size: 0.875rem;
            margin-bottom: 1rem;
            padding: 0.75rem 1rem;
        }
        .login-alert.show { display: block; }
        .login-alert.danger  { background: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }
        .login-alert.success { background: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
        .login-alert.warning { background: #fff3cd; color: #664d03; border: 1px solid #ffecb5; }

        /* Spinner */
        .spinner-border-sm { width: 1rem; height: 1rem; border-width: .15em; }

        /* Timeout banner */
        .timeout-banner {
            background: #fff3cd;
            color: #664d03;
            border: 1px solid #ffecb5;
            border-radius: 10px;
            padding: 0.65rem 1rem;
            margin-bottom: 1rem;
            font-size: 0.85rem;
            text-align: center;
        }
    </style>
</head>
<body>

<div class="login-wrapper">
    <div class="login-card">

        <!-- Logo -->
        <img src="<?php echo asset_url('images/logo.png'); ?>"
             alt="<?php echo APP_NAME; ?> Logo"
             class="login-logo"
             onerror="this.style.display='none'">

        <h1 class="login-title">Admin Panel</h1>
        <p class="login-subtitle">Sign in to manage <?php echo APP_NAME; ?></p>

        <!-- Timeout message -->
        <?php if ($timeoutMsg): ?>
        <div class="timeout-banner">
            <i class="bi bi-clock-history me-1"></i><?php echo $timeoutMsg; ?>
        </div>
        <?php endif; ?>

        <!-- Error / success container -->
        <div id="loginAlert" class="login-alert" role="alert"></div>

        <!-- Login Form -->
        <form id="loginForm" novalidate>

            <!-- Email -->
            <div class="mb-3">
                <label for="email" class="form-label">Email address</label>
                <input type="email"
                       class="form-control"
                       id="email"
                       name="email"
                       placeholder="admin@myspicemarket.com"
                       autocomplete="email"
                       required>
                <div class="invalid-feedback">Please enter a valid email address.</div>
            </div>

            <!-- Password -->
            <div class="mb-3">
                <label for="password" class="form-label">Password</label>
                <div class="input-group">
                    <input type="password"
                           class="form-control"
                           id="password"
                           name="password"
                           placeholder="Enter your password"
                           autocomplete="current-password"
                           required>
                    <button class="btn btn-outline-secondary"
                            type="button"
                            id="togglePassword"
                            tabindex="-1"
                            title="Show / hide password">
                        <i class="bi bi-eye" id="toggleIcon"></i>
                    </button>
                    <div class="invalid-feedback">Password is required.</div>
                </div>
            </div>

            <!-- Remember Me & Forgot Password -->
            <div class="remember-row">
                <div class="form-check">
                    <input class="form-check-input" type="checkbox" id="rememberMe" name="remember_me">
                    <label class="form-check-label" for="rememberMe" style="font-size:0.875rem;">
                        Remember me
                    </label>
                </div>
                <a href="<?php echo admin_url('auth/forgot_password.php'); ?>" class="forgot-link">Forgot password?</a>
            </div>

            <!-- Submit -->
            <button type="submit" class="btn btn-success btn-login" id="loginBtn">
                <span id="loginBtnText">Sign In</span>
                <span id="loginBtnSpinner" class="spinner-border spinner-border-sm d-none ms-1" role="status"></span>
            </button>
        </form>

    </div><!-- /.login-card -->

    <p class="login-footer">
        &copy; <?php echo date('Y') . ' ' . APP_NAME . ' v' . APP_VERSION; ?>
    </p>
</div><!-- /.login-wrapper -->

<!-- Bootstrap JS (needed for nothing here, but kept for consistency) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
(function() {
    /* ── Elements ─────────────────────────────────────── */
    var form      = document.getElementById('loginForm');
    var email     = document.getElementById('email');
    var password  = document.getElementById('password');
    var alertBox  = document.getElementById('loginAlert');
    var loginBtn  = document.getElementById('loginBtn');
    var btnText   = document.getElementById('loginBtnText');
    var btnSpin   = document.getElementById('loginBtnSpinner');
    var toggleBtn = document.getElementById('togglePassword');
    var toggleIco = document.getElementById('toggleIcon');

    /* ── Show / hide password ─────────────────────────── */
    toggleBtn.addEventListener('click', function() {
        var isPassword = password.type === 'password';
        password.type  = isPassword ? 'text' : 'password';
        toggleIco.className = isPassword ? 'bi bi-eye-slash' : 'bi bi-eye';
    });

    /* ── Alert helper ─────────────────────────────────── */
    function showAlert(type, message) {
        alertBox.className = 'login-alert show ' + type;
        alertBox.textContent = message;
    }
    function hideAlert() {
        alertBox.className = 'login-alert';
    }

    /* ── Loading state ────────────────────────────────── */
    function setLoading(on) {
        loginBtn.disabled = on;
        btnText.textContent  = on ? 'Signing in…' : 'Sign In';
        btnSpin.classList.toggle('d-none', !on);
    }

    /* ── Client-side validation ───────────────────────── */
    function validate() {
        var valid = true;

        // Email
        if (!email.value.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim())) {
            email.classList.add('is-invalid');
            valid = false;
        } else {
            email.classList.remove('is-invalid');
        }

        // Password
        if (!password.value) {
            password.classList.add('is-invalid');
            valid = false;
        } else {
            password.classList.remove('is-invalid');
        }

        return valid;
    }

    /* ── Form submission ──────────────────────────────── */
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        hideAlert();

        if (!validate()) return;

        setLoading(true);

        var xhr = new XMLHttpRequest();
        xhr.open('POST', '<?php echo admin_url("auth/login_process.php"); ?>', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            setLoading(false);

            try {
                var res = JSON.parse(xhr.responseText);
                if (res.success) {
                    showAlert('success', 'Login successful! Redirecting…');
                    setTimeout(function() {
                        window.location.href = res.redirect || '<?php echo admin_url("pages/dashboard/dashboard.php"); ?>';
                    }, 600);
                } else {
                    showAlert('danger', res.message || 'Invalid credentials. Please try again.');
                }
            } catch (err) {
                showAlert('danger', 'An unexpected error occurred. Please try again.');
            }
        };
        xhr.onerror = function() {
            setLoading(false);
            showAlert('danger', 'Network error. Please check your connection.');
        };

        var data = 'email='    + encodeURIComponent(email.value.trim()) +
                   '&password=' + encodeURIComponent(password.value) +
                   '&remember_me=' + (document.getElementById('rememberMe').checked ? '1' : '0');

        xhr.send(data);
    });

    /* ── Clear validation on input ────────────────────── */
    email.addEventListener('input', function() { email.classList.remove('is-invalid'); hideAlert(); });
    password.addEventListener('input', function() { password.classList.remove('is-invalid'); hideAlert(); });

})();
</script>
</body>
</html>
