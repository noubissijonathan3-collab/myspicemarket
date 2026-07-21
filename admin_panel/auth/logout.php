<?php
/**
 * Logout
 * 
 * Destroys the administrator session, clears remember-me cookies,
 * and redirects to the login page.
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/session.php';

/* ─── Clear remember-me cookie ────────────────────────── */
if (isset($_COOKIE['msm_admin_remember'])) {
    setcookie('msm_admin_remember', '', time() - 3600, '/');
}

/* ─── Destroy session ─────────────────────────────────── */
session_destroy_admin();

/* ─── Redirect to login ───────────────────────────────── */
header('Location: ' . admin_url('auth/login.php'));
exit;
