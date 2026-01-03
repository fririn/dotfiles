require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

function Linemode:size_and_perm()
	local size = self._file:size()
	local perm = self._file.cha:perm()
	return string.format("%s %s", size and ya.readable_size(size) or "-", perm or "-")
end

th.git = th.git or {}
th.git.modified_sign = "*"
th.git.modified = ui.Style():fg("red"):blink()

th.git.added_sign = "+"
th.git.added = ui.Style():fg("red"):bold():blink()

th.git.untracked_sign = "?"
th.git.untracked = ui.Style():fg("blue"):dim():blink()

th.git.ignored_sign = "-"
th.git.ignored = ui.Style():fg("gray"):dim()

th.git.deleted_sign = "x"
th.git.deleted = ui.Style():fg("gray"):dim()

th.git.updated_sign = "U"
th.git.updated = ui.Style():fg("red"):bold()

th.git.unchanged_sign = "="
th.git.unchanged = ui.Style():fg("green"):dim()
require("git"):setup()
