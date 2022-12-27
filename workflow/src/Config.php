<?php

namespace Adamkiss\NoteplanFTS;

class Config extends Obj {
    static $singleton = null;

    static function instance()
    {
        if (is_null(self::$singleton)) {
            self::$singleton = new Config();
        }

        return self::$singleton;
    }

    public function __construct() {
        // Workflow root directory
        $this->root = dirname(__DIR__);

        // Noteplan root
        $this->np_root = getenv('USER_NP_ROOT') ?: '~/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp';
    }
}

if (! function_exists('config')) {
    function config(string $key, mixed $value = null): mixed
    {
        $key = strtolower($key);

        if (is_null($value)) {
            return Config::instance()->{$key};
        }

        $instance = Config::instance();
        $instance->{$key} = $value;
        return $instance;
    }
}