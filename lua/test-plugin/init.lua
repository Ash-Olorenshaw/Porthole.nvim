-- Filename: floating_window.lua

-- This file defines a simple NeoVim plugin to create a floating window.

local M = {}
local extension_names = require 'test-plugin.icon_map'

function string_split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function attach_icons(items)
	local new_items = {}
	for i, item in ipairs(items) do
		if (string.find(item, ".", 1, true) or (extension_names[item] ~= nil)) then
			local sections = string_split(item, ".")
			local ext = sections[#sections]
			if (extension_names[ext] ~= nil) then
				new_items[i] = extension_names[ext].."  "..item
			elseif (extension_names[item] ~= nil) then
				new_items[i] = extension_names[item].."  "..item
			else
				new_items[i] = "󰡯  "..item
			end
		else
			new_items[i] = "󰡯  "..item
		end
	end
	return new_items
end

function list_stuff()
	local directory = vim.fn.getcwd()
	local i, t = 0, {}
	local childItems, popen = "", io.popen
    local delimiter = package.config:sub(1,1)

	if (vim.fn.executable('pwsh') == 1) then
		childItems = popen('pwsh -Command Get-ChildItem -Force -Name -Path "'..directory..'"')

	elseif (vim.fn.executable('powershell.exe') == 1) then
		childItems = popen('powershell.exe -Command Get-ChildItem -Force -Name -Path "'..directory..'"')

	elseif(delimiter == '\\') then
		childItems = popen('dir "'..directory..'" /a /b')

	elseif(delimiter == '/') then
		childItems = popen('ls -a "'..directory..'"')
	end

	for filename in childItems:lines() do
        i = i + 1
        t[i] = filename
    end
    childItems:close()
	table.insert(t, 1, tostring(directory))
    return t

end

-- Function to create a floating window
function M.create_floating_window()
    -- Get the dimensions of the current NeoVim window
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    -- Define the size of the floating window
    local win_width = math.ceil(width * 0.8)
    local win_height = math.ceil(height * 0.8)

    -- Center the window
    local row = math.ceil((height - win_height) / 2)
    local col = math.ceil((width - win_width) / 2)

    -- Create a new buffer (unlisted, scratch buffer)
    local buf = vim.api.nvim_create_buf(false, true)

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    
    -- Define window options
    local opts = {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded'
    }
    
    -- Create the floating window
    local win = vim.api.nvim_open_win(buf, true, opts)
    
    -- Set some window options
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_option(win, 'cursorcolumn', false)
    
    -- Populate the buffer with some text
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, attach_icons(list_stuff()))
	-- REMEMBER: close window with 'q'
    
    -- Set keymap to close the window with 'q'
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':bd!<CR>', { noremap = true, silent = true })
end

-- Function to register the command that calls the floating window
--function M.setup()
--    -- Create a user command to open the floating window
--    vim.api.nvim_create_user_command('FloatingWindow', function()
--        M.create_floating_window()
--    end, {})
--end

return M

