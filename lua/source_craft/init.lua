local M = {}

function M.toggle()
	local source = require("source_craft.source")
	source.opts.enabled = not source.opts.enabled
end

function M.setup()
	vim.api.nvim_create_user_command("SourceCraftToggle", M.toggle, {})
end

return M
