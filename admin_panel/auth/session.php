<?php
/**
 * Session Management
 * 
 * Handles session initialization, timeout detection, ID regeneration,
 * and all helper functions that other files use to read/write session data.
 */

if (session_status() === PHP_SESSION_NONE) {

    /* ─── Secure session cookie params ─────────────────── */
    ini_set('session.cookie_httponly', 1);
    ini_set('session.cookie_secure',   0);   // set to 1 in production (HTTPS)
    ini_set('session.use_strict_mode', 1);
    ini_set('session.use_only_cookies', 1);
    ini_set('session.gc_maxlifetime',   SESSION_LIFETIME);

    session_name('MSM_ADMIN_SESSION');
    session_start();
}

/* ─── Regenerate ID on first load (prevent fixation) ──── */
if (!isset($_SESSION['_initiated'])) {
    session_regenerate_id(true);
    $_SESSION['_initiated'] = true;
}

/* ─── Timeout check ───────────────────────────────────── */
if (isset($_SESSION['last_activity'])) {
    $elapsed = time() - $_SESSION['last_activity'];
    if ($elapsed > SESSION_INACTIVITY) {
        session_unset();
        session_destroy();
        header('Location: ' . admin_url('auth/login.php?timeout=1'));
        exit;
    }
}
$_SESSION['last_activity'] = time();

/* ═══════════════════════════════════════════════════════
   Helper functions
   ═══════════════════════════════════════════════════════ */

function session_set_admin(array $adminData, string $jwt): void
{
    $_SESSION['admin']       = $adminData;
    $_SESSION['jwt']         = $jwt;
    $_SESSION['logged_in']   = true;
    $_SESSION['login_time']  = time();
    $_SESSION['last_activity'] = time();
}

function session_get_admin(): ?array
{
    return $_SESSION['admin'] ?? null;
}

function session_get_jwt(): ?string
{
    return $_SESSION['jwt'] ?? null;
}

function session_is_logged_in(): bool
{
    return !empty($_SESSION['logged_in']) && !empty($_SESSION['jwt']);
}

function session_destroy_admin(): void
{
    $_SESSION = [];

    if (ini_get('session.use_cookies')) {
        $p = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000,
            $p['path'], $p['domain'], $p['secure'], $p['httponly']
        );
    }

    session_destroy();
}

function session_set_flash(string $key, string $message): void
{
    $_SESSION['flash'][$key] = $message;
}

function session_get_flash(string $key): ?string
{
    if (isset($_SESSION['flash'][$key])) {
        $msg = $_SESSION['flash'][$key];
        unset($_SESSION['flash'][$key]);
        return $msg;
    }
    return null;
}
