-- works only with vscode
local ide_info = {
	Ide = "vscode",
	IdeVersion = "1.102.0",
	PluginFamily = "vscode",
	PluginVersion = "0.11.21",
}

local M = {}

-- 8k symbols max
local function prev_fragment(bufn, cursor)
	local lines = vim.api.nvim_buf_get_lines(bufn, 0, cursor[1], false)
	local count = cursor[2] - 1
	local first_line = cursor[1]
	while count < 8000 and first_line > 1 do
		first_line = first_line - 1
		count = count + string.len(lines[first_line]) + 1
	end
	if count >= 8000 then
		first_line = first_line + 1
	end
	local text = string.sub(lines[cursor[1]], 0, cursor[2])
	if first_line < cursor[1] then
		text = table.concat(lines, "\n", first_line, cursor[1] - 2) .. "\n" .. text
	end
	return {
		Text = text,
		Start = {
			Ln = first_line,
			Col = 1,
		},
		End = {
			Ln = cursor[1],
			Col = cursor[2],
		},
	}
end

-- 1k symbols max
local function next_fragment(bufn, cursor)
	local lines = vim.api.nvim_buf_get_lines(bufn, cursor[1] - 1, -1, false)
	local idx = 1
	local text = { string.sub(lines[idx], cursor[2] + 1) }
	local size = #text[1] + 1
	idx = idx + 1
	while idx <= #lines do
		if size + #lines[idx] + 1 > 1024 then
			break
		end
		size = size + #lines[idx] + 1
		text[#text + 1] = lines[idx]
		idx = idx + 1
	end
	return {
		Text = table.concat(text, "\n"),
		Start = {
			Ln = cursor[1],
			Col = cursor[2],
		},
		End = {
			Ln = cursor[1] + idx - 1,
			Col = #lines[1],
		},
	}
end

function M.SimpleSplitCode(bufn, cursor)
	return {
		RequestId = "2968591165ea434281140a94e78fbd2a",
		IdeInfo = ide_info,
		ContextCreateType = 1,
		Files = {
			{
				Path = vim.fn.bufname(bufn),
				Fragments = {
					prev_fragment(bufn, cursor),
					next_fragment(bufn, cursor),
				},
				Cursor = {
					Ln = cursor[1],
					Col = cursor[2],
				},
			},
		},
	}
end

return M
