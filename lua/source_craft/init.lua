local M = {}

function M.toggle()
	local source = require("source_craft.source")
	source.opts.enabled = !source.opts.enabled;
end

return M
