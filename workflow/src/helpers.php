<?php

use Adamkiss\AlfredNoteplanFTS\Config;

if (! function_exists('config')) {
    function config(string $key, mixed $value = null): mixed
    {
        $key = strtolower($key);

        if (is_null($value)) {
            return Config::get($key);
        }

        Config::set($key, $value);
    }
}

if (! function_exists('simplifyContent')) {
    /**
     * Cleans up original noteplan note content for a better fts matching
     *
     * @param string $content
     * @return string
     */
    function simplifyContent(string $content): string
    {
        // remove markdown headers
        $content = preg_replace('/^#*\s*?/m', '', $content);
        // remove markdown hr
        $content = preg_replace('/^\s*?\-{3,}\s*?$/m', '', $content);
        // remove bullets & quotes
        $content = preg_replace('/^\s*?[\*>-]\s*?/m', '', $content);
        // remove tasks
        $content = preg_replace('/^\s*?[*-]?\s*?\[.?\]\s*?/m', '', $content);
        // remove markdown styling
        $content = preg_replace('/[*_]/m', '', $content);
        // collapse whitespace
        $content = preg_replace('/\s+/', ' ', $content);
        // trim
        $content = trim($content);

        return $content;
    }
}