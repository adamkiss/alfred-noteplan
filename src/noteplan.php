<?php
    
function noteplan_callback_url(string $method, array $params = []): string {
    return 'noteplan://x-callback-url/' . $method . '?' . http_build_query($params);
}