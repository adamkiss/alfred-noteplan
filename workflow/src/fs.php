<?php

define('FRONTMATTER_REGEX', '/---.*?title\:\s*?(.*?)\n.*?---/is');
define('MARKDOWN_TITLE_REGEX', '/^#\s*(.*)(?:\n|\s---)/');

function fs_relative_to_noteplan_root(string $path, array $config): string {
    return str_replace($config['noteplan_root'] . '/', '', $path);
}

function fs_relative_to_noteplan_notes(string $path, array $config): string {
    return str_replace($config['noteplan_root'] . '/Notes/', '', $path);
}

function fs_read_directory($folder, array $config): array {
    $notes = [];

    if (is_string($folder)) {
        // we're starting out
        $dir = new DirectoryIterator($config['noteplan_root'] . '/' . $config["noteplan_folder_$folder"]);
    } else {
        // we're recursing
        $dir = new DirectoryIterator($folder->getPathname());
    }
    
    foreach($dir as $file) {
        if ($file->isDot()) { continue; }

        // Recurse into subfolders
        if ($file->isDir() && $file->getFilename() !== '@Trash') {
            $notes = array_merge($notes, fs_read_directory($file, $config));
        }

        // Only process files with the correct extension
        if ($file->getExtension() !== $config['noteplan_extension']) { continue; }

        // Read the note
        $notes []= fs_read_note($config, $file);
    }

    return $notes;
}

function fs_read_note(array $config, SplFileInfo $file): array {
    $contents = file_get_contents($file->getPathname());
    if (!mb_strlen($contents)) { return []; }

    // @note This is a bit brittle - if there's any whitespace at the beginning
    // it'll fail to match the title.
    $hasFrontmatter = $contents[0] !== '#';

    if ($hasFrontmatter) {
        $title = trim(preg_match(FRONTMATTER_REGEX, $contents, $matches)
            ? $matches[1]
            : '');
        $content = trim(preg_replace(FRONTMATTER_REGEX, '', $contents));
    } else {
        $title = trim(preg_match(MARKDOWN_TITLE_REGEX, $contents, $matches)
            ? $matches[1]
            : '');
        $content = trim(preg_replace(MARKDOWN_TITLE_REGEX, '', $contents));
    }

    if (! is_null($config['precache_modify_content'])) {
        $content = call_user_func($config['precache_modify_content'], $content);
    }

    return [
        'file' => fs_relative_to_noteplan_root($file->getPathname(), $config),
        'title' => $title,
        'body' => $content,
    ];
}

function fs_list_folders(mixed $folder, array $config): array {
    $folders = [];

    if (is_string($folder)) {
        // we're starting out
        $dir = new DirectoryIterator($config['noteplan_root'] . '/' . $config["noteplan_folder_$folder"]);
    } else {
        // we're recursing
        $dir = new DirectoryIterator($folder->getPathname());
    }

    foreach ($dir as $file) {
        if ($file->isDot()) { continue; }
        if (!$file->isDir()) { continue; }

        // Ignore special folders
        if (str_starts_with($file->getFilename(), '@')) {continue;}
        // Ignore attachments folders
        if (str_ends_with($file->getFilename(), '_attachments')) {continue;}

        // Recurse into subfolders
        $folders = array_merge($folders, fs_list_folders($file, $config));

        $folders [fs_relative_to_noteplan_notes($file->getPathname(), $config)] = $file->getFilename();
    }

    return $folders;
}