<?php
/**
 * Auth API Helper
 * 
 * Centralises every cURL call that the authentication layer (and later other
 * modules) makes to the Node.js backend.  Returns decoded JSON or null on
 * failure so callers can react gracefully.
 */

require_once __DIR__ . '/../config/api.php';

/**
 * Generic request builder.
 *
 * @param  string      $method   GET|POST|PUT|DELETE
 * @param  string      $endpoint Full URL
 * @param  array|null  $body     JSON-encodable payload
 * @param  string|null $jwt      Bearer token (optional)
 * @return array|null  ['status' => int, 'body' => mixed] or null on cURL error
 */
function api_request(string $method, string $endpoint, ?array $body = null, ?string $jwt = null): ?array
{
    $ch = curl_init();

    $headers = ['Content-Type: application/json', 'Accept: application/json'];
    if ($jwt) {
        $headers[] = 'Authorization: Bearer ' . $jwt;
    }

    curl_setopt_array($ch, [
        CURLOPT_URL            => $endpoint,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT        => 30,
        CURLOPT_HTTPHEADER     => $headers,
        CURLOPT_SSL_VERIFYPEER => false,
    ]);

    switch (strtoupper($method)) {
        case 'POST':
            curl_setopt($ch, CURLOPT_POST, true);
            if ($body !== null) curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
            break;
        case 'PUT':
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PUT');
            if ($body !== null) curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
            break;
        case 'DELETE':
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
            break;
        default: // GET
            break;
    }

    $response = curl_exec($ch);

    if (curl_errno($ch)) {
        error_log('API cURL error: ' . curl_error($ch) . ' — ' . $endpoint);
        curl_close($ch);
        return null;
    }

    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return [
        'status' => $httpCode,
        'body'   => json_decode($response, true),
    ];
}

/* ═══════════════════════════════════════════════════════
   Auth-specific helpers
   ═══════════════════════════════════════════════════════ */

/**
 * Attempt admin login.
 *
 * @return array|null  Decoded response body or null on error
 */
function auth_api_login(string $email, string $password): ?array
{
    $result = api_request('POST', API_AUTH_ADMIN_LOGIN, [
        'email'    => $email,
        'password' => $password,
    ]);

    return $result['body'] ?? null;
}

/**
 * Fetch the admin profile for the currently-authenticated token.
 */
function auth_api_profile(string $jwt): ?array
{
    $result = api_request('GET', API_AUTH_ADMIN_PROFILE, null, $jwt);
    return $result['body'] ?? null;
}

/**
 * Verify that a JWT is still valid (lightweight check).
 */
function auth_api_verify_token(string $jwt): ?array
{
    return auth_api_profile($jwt);
}
