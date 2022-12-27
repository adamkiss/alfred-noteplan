<?php

namespace Adamkiss\AlfredNoteplanFTS;

class Config {
    private static $data = [];

    static function get(string $key): mixed
    {
        if (empty(self::$data)) self::init();

        return self::$data[$key] ?? null;
    }

    static function set(string $key, $value)
    {
        self::$data[$key] = $value;
    }

    static function init()
    {
        self::$data = [
            'root' => dirname(__DIR__),
            'noteplan_root' => getenv('user_np_root'),

			'new_note_template' => <<<MD
			---
			title: %s
			---

			MD,

			'sql_start' => '›',
			'sql_end' => '‹',
			'sql_more' => '…',
			'sql_title_tokens' => 20,
			'sql_snippet_tokens' => 5,
        ];
    }
}
