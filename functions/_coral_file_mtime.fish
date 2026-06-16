function _coral_file_mtime --argument-names path
    test -n "$path"; or return 1

    # Try GNU stat first: macOS/BSD stat rejects -c cleanly (empty output, so we
    # fall through), but GNU stat does NOT reject -f — it prints filesystem info
    # instead of erroring, so a BSD-first order silently captures garbage on Linux.
    set -f mtime (stat -c %Y "$path" 2>/dev/null)
    if test -z "$mtime"
        set mtime (stat -f %m "$path" 2>/dev/null)
    end

    # Guard: only accept a bare integer epoch, never stray multi-line output.
    string match -qr '^\d+$' -- "$mtime"; or return 1
    printf '%s\n' "$mtime"
end
