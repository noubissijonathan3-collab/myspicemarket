<?php
/**
 * Authentication Guard
 * 
 * Include this file at the TOP of every protected page:
 * 
 *   require_once __DIR__ . '/../auth/auth_check.php';
 * 
 * It verifies that a valid administrator session exists. If not, the visitor
 * is redirected to the login page and execution stops.
 */

/* ─── Bootstrap config + session ──────────────────────── */
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/api.php';
require_once __DIR__ . '/../config/constants.php';
require_once __DIR__ . '/session.php';

/* ─── Remember-me restoration ─────────────────────────── */
if (!session_is_logged_in()) {
    require_once __DIR__ . '/remember_me.php';
    remember_me_restore();
}

/* ─── Gate ────────────────────────────────────────────── */
if (!session_is_logged_in()) {
    session_set_flash(ALERT_WARNING, 'Please log in to access the admin panel.');
    header('Location: ' . admin_url('auth/login.php'));
    exit;
}

/* ─── Optional: verify JWT is still valid with backend ── */
// Uncomment the block below to enforce server-side JWT verification on every
// page load.  It adds one API call per request so it's disabled by default.
/*
require_once __DIR__ . '/../api/auth_api.php';
$profile = auth_api_verify_token();
if (!$profile) {
    session_set_flash(ALERT_WARNING, 'Your session has expired. Please log in again.');
    session_destroy_admin();
    header('Location: ' . admin_url('auth/login.php'));
    exit;
}
*/

/* ─── Expose admin name to views ──────────────────────── */
$admin = session_get_admin();
$adminName  = $admin['fullName'] ?? $admin['name'] ?? 'Administrator';
$adminEmail = $admin['email']    ?? '';
$adminAvatar = $admin['profileImage'] ?? $admin['avatar'] ?? DEFAULT_AVATAR;
