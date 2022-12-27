<?php

namespace Adamkiss\AlfredNoteplanFTS;

class NoteplanCallback {
    /**
     * Builds the Noteplan Callback URL
     *
     * @param string $method
     * @param array $params
     * @return string
     */
    private static function build(string $method = 'openNote', array $params = []): string {
        return implode('', [
            'noteplan://x-callback-url/',
                $method,
            '?',
                http_build_query(array_filter($params), encoding_type: PHP_QUERY_RFC3986)
        ]);
    }

    /**
     * Builds the Noteplan Callback for opening a note
     *
     * @param array $params
     * @return string
     */
    static function open(array $params = []): string
    {
        return self::build('openNote', $params);
    }

    /**
     * Builds the Noteplan Callback for adding a note
     *
     * @param array $params
     * @return string
     */
    static function add(string $title, ?string $folder): string
    {
        return self::build('addNote', [
            'text' => sprintf(Config::get('new_note_template'), $title),
            'openNote' => 'yes',
            'useExistingSubWindow' => 'yes',
			'folder' => $folder
        ]);
    }

	/**
	 * Calendar (daily/weekly/…) note specific open callback
	 *
	 * @param string $dateString
	 * @param boolean $sameWindow
	 * @return string
	 */
	static function openCalendar(string $dateString, bool $sameWindow = true): string
	{
		return self::open([
			'noteDate' => $dateString,
			'useExistingSubWindow' => $sameWindow ? 'yes' : 'no',
		]);
	}

	/**
	 * Note opening callback specific to regular notes
	 *
	 * @param string $filename
	 * @param boolean $sameWindow
	 * @return string
	 */
	static function openNote(string $filename, bool $sameWindow = true): string
	{
		return self::open([
			'filename' => $filename,
			'useExistingSubWindow' => $sameWindow ? 'yes' : 'no',
		]);
	}
}
