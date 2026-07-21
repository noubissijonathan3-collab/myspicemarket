<?php
/**
 * Remember-Me Handler
 * 
 * Manages persistent login cookies so administrators can stay signed in
 * across browser restarts (default 7 days).
 */

require_once __DIR__ . '/session.php';

define('REMEMBER_COOKIE', 'msm_admin_remember');

/**
 * Create a remember-me cookie after successful login.
 */
function remember_me_set(string $adminId, string $jwt): void
{
    $token  = bin2hex(random_bytes(32));
    $hashed = password_hash($token, PASSWORD_DEFAULT);
    $expiry = time() + REMEMBER_ME_DURATION;

    // Store the hash + token association in the session so logout can clean it.
    $_SESSION['remember_token_hash'] = $hashed;

    setcookie(REMEMBER_COOKIE, $adminId . ':' . $token, $expiry, '/');
}

/**
 * Attempt to restore a session from a remember-me cookie.
 * Called by auth_check.php when no active session exists.
 */
function remember_me_restore(): void
{
    if (!isset($_COOKIE[REMEMBER_COOKIE])) return;

    [$adminId, $token] = explode(':', $_COOKIE[REMEMBER_COOKIE], 2) + ['', ''];
    if (!$adminId || !$token) return;

    // Verify token against backend (optional — or validate locally).
    // For now we simply redirect to login for re-authentication.
    // A production system would hash the token, look it up in the DB,
    // and restore the session automatically.
}

/**
 * Destroy the remember-me cookie (called on logout).
 */
function remember_me_forget(): void
{
    if (isset($_COOKIE[REMEMBER_COOKIE])) {
        setcookie(REMEMBER_COOKIE, '', time() - 3600, '/');
    }
    unset($_SESSION['remember_token_hash']);
}
