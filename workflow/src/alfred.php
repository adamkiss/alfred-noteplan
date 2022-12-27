<?php

namespace Adamkiss\AlfredNoteplanFTS;

use Throwable;

class Alfred {
    /**
     * Exit the process with the encoded items encoded to json
     *
     * @param array $items - array of items to return to alfred
     * @return void
     */
    static function exit(array $items)
    {
        $items = array_filter($items, fn($item) => $item);
        
        exit(json_encode(compact('items')));
    }

    /**
     * Create an Alfred item
     *
     * @param string title
     * @param string quicklookurl
     * @return array
     */
    static function item(
        string $title,
        string $uid = null,
        string $subtitle = null,
        string|array $arg = null,
        array $icon = null,
        bool $valid = true,
        string $match = null,
        string $autocomplete = null,
        string $type = 'default',
        array $mods = null,
        array $text = null,
        string $quicklookurl = null,
    ): ?array
    {
        $item = compact(
            'uid', 'title', 'subtitle',
            'arg', 'icon',
            'valid', 'match',
            'autocomplete', 'type',
            'mods',
            'text', 'quicklookurl'
        );

        return array_filter($item, fn($var) => $var);
    }

    /**
     * Return ERROR
     *
     * @param Throwable $th
     * @return void
     */
    static function error(Throwable $th)
    {
        Alfred::exit([
            Alfred::item(
                title: "Error: {$th->getMessage()}",
                arg: $th->getMessage(),
                valid: false
            )
        ]);
    }
}