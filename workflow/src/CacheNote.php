<?php

namespace Adamkiss\AlfredNoteplanFTS;

use DateTime;

class CacheNote {

    /** @var array[string]string Internal Noteplan Data */
    private array $data = [];

    /** @var string Relative path */
    public $path = '';
    /** @var string Note Title */
    public $title = '';
    /** @var string Note content */
    public $content = '';
    /** @var int Note type */
    public $type = CacheNote::TYPE_UNSET;

    const TYPE_UNSET     = -1;
    const TYPE_NOTE      = 1;
    const TYPE_DAILY     = 11;
    const TYPE_WEEKLY    = 12;
    const TYPE_MONTHLY   = 13;
    const TYPE_QUARTERLY = 14;
    const TYPE_YEARLY    = 15;

    /**
     * Create a Noteplan metadata table record
     *
     * <code>
     * $data = [
     *  'filename' => 'folder/filename.md', // Full path relative to Calendar or Notes folder
     *  'content' => "---\ntitle: The title\n---", // Content of the note
     *  'modified' => 1672116893000, // current timestamp * 1000
     *  'note_type' => 0, // note_type: 0 for calendar, 1 for note, …
     * ];
     * </code>
     *
     * @param array[string]string $data
     */
    public function __construct(array $data) {
		// It's not 100% that $data['note_type'] will be autocase to int
		$data['note_type'] = intval($data['note_type']);

        $this->data = $data;
        $this->pathinfo = pathinfo($data['filename']);

        // PARSE NOTE NOTES
        if ($data['note_type'] === 1) {
            $this->type = CacheNote::TYPE_NOTE;
            $content = trim($data['content']);

            // Note uses frontmatter and we matched a title
            if (
                str_starts_with($content, '---')
                && preg_match('/---.*?title\:\s*?(.*?)\n.*?---/is', $content, $matches)
            ) {
                $this->title = trim($matches[1]); // 0 is the whole match
                $this->content = simplifyContent($content);

            // We got a markdown header
            } else if (preg_match('/^#\s*(.*)(?:\n|\s---)/', $content, $matches)) {
                $this->title = trim($matches[1]);
                $this->content = simplifyContent($content);
            } else {

            // No clue. Let's use filename
                $this->title = $this->pathinfo['filename'];
                $this->content = simplifyContent($content);
            }

        // PARSE CALENDAR NOTES
        } else {
            $fn = $data['filename'];

            // @todo Make the "format" function accept user defined formatting
            if (preg_match('/^(?P<ymd>\d{8})\./', $fn, $m)) {
                $this->type = CacheNote::TYPE_DAILY;
                $this->title = DateTime::createFromFormat('Ymd', $m['ymd'])->format('d.m.Y');
            } else if (preg_match('/^(\d{4})\./', $fn, $m)) {
                $this->type = CacheNote::TYPE_YEARLY;
                $this->title = sprintf('Year %d', $m[0]);
            } else if (preg_match('/^(\d{4})-W(\d{2})\./', $fn, $m)) {
                $this->type = CacheNote::TYPE_WEEKLY;
                $this->title = sprintf('%d Week %d', $m[0], $m[1]);
            } else if (preg_match('/^(\d{4})-Q(\d)\./', $fn, $m)) {
                $this->type = CacheNote::TYPE_QUARTERLY;
                $this->title = sprintf('%d Quarter #%d', $m[0], $m[1]);
            } else {
                $this->type = CacheNote::TYPE_MONTHLY;
                preg_match('/^(\d{4})-(\d+)\./', $fn, $m);
                // @todo ? IntlFormatter?
                $this->title = sprintf('%d Month %d', $m[0], $m[1]);
            }

            $this->content = simplifyContent(trim($data['content']));
        }
    }

    /**
     * Get a key from the original noteplan array
     *
     * @param string $key
     * @return mixed
     */
    public function get(string $key): mixed
    {
        return $this->data[$key];
    }

    public function getTypeString(): string
    {
        return match($this->type) {
            CacheNote::TYPE_UNSET     => 'this-shouldnt-happen',
            CacheNote::TYPE_NOTE      => 'note',
            CacheNote::TYPE_DAILY     => 'daily',
            CacheNote::TYPE_WEEKLY    => 'weekly',
            CacheNote::TYPE_MONTHLY   => 'monthly',
            CacheNote::TYPE_QUARTERLY => 'quarterly',
            CacheNote::TYPE_YEARLY    => 'yearly'
        };
    }
}
