
local M = {}

function M.declare_colours()
	vim.api.nvim_set_hl(0, 'Porthole-LightPurple', { fg = '#C796E8' })
	vim.api.nvim_set_hl(0, 'Porthole-DarkPurple', { fg = '#8755AA' })
	vim.api.nvim_set_hl(0, 'Porthole-LightBlue', { fg = '#A1E9F4' })
	vim.api.nvim_set_hl(0, 'Porthole-Blue', { fg = '#49C3D8' })
	vim.api.nvim_set_hl(0, 'Porthole-LightRed', { fg = '#FF795D' })
	vim.api.nvim_set_hl(0, 'Porthole-DarkGreen', { fg = '#549E43' })
	vim.api.nvim_set_hl(0, 'Porthole-Orange', { fg = '#FC981E' })
	vim.api.nvim_set_hl(0, 'Porthole-LightYellow', { fg = '#F9F484' })
	vim.api.nvim_set_hl(0, 'Porthole-Violet', { fg = '#C28AF7' })
	vim.api.nvim_set_hl(0, 'Porthole-Green', { fg = '#71D159' })
	vim.api.nvim_set_hl(0, 'Porthole-DarkBlue', { fg = '#459CA8' })
	vim.api.nvim_set_hl(0, 'Porthole-LightGrey', { fg = '#CECECE' })
	vim.api.nvim_set_hl(0, 'Porthole-DarkGrey', { fg = '#969696' })
	vim.api.nvim_set_hl(0, 'Porthole-Red', { fg = '#E84A2E' })
	vim.api.nvim_set_hl(0, 'Porthole-LightGreen', { fg = '#9FE58E' })
	vim.api.nvim_set_hl(0, 'Porthole-LightOrange', { fg = '#FFAC4F' })
end


function M.table_concat(t1, t2)
    for i = 1,#t2 do
        t1[#t1 + 1] = t2[i]
    end

    return t1
end

function M.string_split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
	  table.insert(t, str)
	end
	return t
end

return M
