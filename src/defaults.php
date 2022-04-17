<?php

/**
 * Default config file
 */
return [
    /**
     * The root noteplan folder, absolute path
     * You can find it via Preferences → Sync → [Active method] → Open Local Database Folder
     */
    'noteplan_root' => '',

    /**
     * The default noteplan extension
     */
    'noteplan_extension' => 'md',

    /**
     * Folders inside the Noteplan root to scan
     * I don't think these are user configurable
     */
    'noteplan_folder_calendar' => 'Calendar',
    'noteplan_folder_notes' => 'Notes',

    /**
     * The default calendar format
     */
    'calendar_title_format' => 'd.m.Y',

    /**
     * Content cleaning function - receives an array of note properties
     * might be set to null to disable
     * 
     * @param array $note
     * @return array
     */
    'precache_modify_content' => function(string $content) {
        // remove markdown headers
        $content = preg_replace('/^#*?\s*?$/m', '', $content);
        // remove bullets & quotes
        $content = preg_replace('/^\s*?[\*>-]\s*?/m', '', $content);
        // remove tasks
        $content = preg_replace('/^\s*?[*-]?\s*?\[.?\]\s*?/m', '', $content);
        // remove markdown styling
        $content = preg_replace('/[*_]/m', '', $content);
        // remove markdown hr
        $content = preg_replace('/^\s*?\-{3,}\s*?$/m', '', $content);
        // collapse whitespace
        $content = preg_replace('/\s+/', ' ', $content);
        
        return $content;
    },

    /**
     * SQLite snippet options
     * I have no idea what the "size" does _exactly_, this was trial and error
     * 
     * @link https://www.sqlite.org/fts5.html#the_snippet_function
     */
    'snippet_match_start' => '›',
    'snippet_match_end' => '‹',
    'snippet_match_ellipsis' => '…',
    'snippet_title_tokens' => 20,
    'snippet_body_tokens' => 5,
];