<?php
    
function noteplan_callback_url(string $method, array $params = []): string {
    return implode('', [
        'noteplan://x-callback-url/',
            $method,
        '?',
            http_build_query($params, encoding_type: PHP_QUERY_RFC3986)
    ]);
}