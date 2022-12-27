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
            'noteplan_root' => getenv('USER_NP_ROOT') ?: '/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp', // @todo remove after testing
        ];
    }
}