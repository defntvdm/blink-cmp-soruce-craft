---@class SourceCraftSourceOpts
---@field enabled boolean
---@field base_url string
---@field token_type "Bearer" | "OAuth"
---@field token string
---@field timeout_ms number

local source = {
	---@type SourceCraftSourceOpts
	opts = {
		enabled = false,
		base_url = "https://proxy.src.yandexcloud.net/proxy",
		token_type = "Bearer",
		token = "",
		timeout_ms = 5000,
	},
}

---@param opts SourceCraftSourceOpts
function source.new(opts)
	local self = setmetatable({}, { __index = source })
	self.opts = vim.tbl_deep_extend("keep", opts, self.opts)
	return self
end

function source:get_completions(context, callback)
	local ft = vim.bo.filetype
	local kw = context.get_keyword()
	local curl = require("plenary.curl")
	local body = require("source_craft.context").SimpleSplitCode(context.bufnr, context.cursor)
	local handle = curl.post(self.opts.base_url .. "/recommend", {
		headers = {
			["User-Agent"] = "YandexCodeAssist-VSCode/" .. "0.11.21",
			["Content-Type"] = "application/json",
			["Authorization"] = self.opts.token_type .. " " .. self.opts.token,
		},
		body = vim.json.encode(body),
		callback = function(async_result)
			if async_result.exit ~= 0 then
				vim.notify("sourcecraft: curl failed", vim.log.levels.DEBUG)
				callback()
				return
			end
			if async_result.status ~= 200 then
				vim.notify("sourcecraft: status not 200", vim.log.levels.DEBUG)
				callback()
				return
			end
			local data = vim.json.decode(async_result.body)
			local items = {}
			for _, v in ipairs(data.Suggests) do
				local text = kw .. v.Text
				table.insert(items, {
					label = text,
					insertText = text,
					ft = ft,
				})
			end
			if #items == 0 then
				callback()
			end
			callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = items })
		end,
	})
	handle:wait(self.opts.timeout_ms)
end

function source:resolve(item, callback)
	item.documentation = {
		kind = "markdown",
		value = "```" .. item.ft .. "\n" .. item.insertText .. "\n```",
	}
	callback(item)
end

function source:enabled()
	return source.opts.enabled
end

return source
