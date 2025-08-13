local M = {}

function M.toggle()
	local source = require("source_craft.source")
	source.opts.enabled = not source.opts.enabled
	if source.opts.enabled then
		vim.notify("SourceCraft enabled")
	else
		vim.notify("SourceCraft disabled")
	end
end

function M.setup()
	vim.api.nvim_create_user_command("SourceCraftToggle", M.toggle, {})
end

return M
