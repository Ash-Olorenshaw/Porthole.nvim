-- Porthole.nvim
-- created by Ash Olorenshaw

local M = {}
local extension_names = require 'test-plugin.icon_map'

function TableConcat(t1, t2)
    for i = 1,#t2 do
        t1[#t1 + 1] = t2[i]
    end

    return t1
end

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

function declare_colours()
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

function attach_icons(items, directories)
	local new_items, new_colours = {}, {}

	for i, item in ipairs(items) do
		if (string.find(item, ".", 1, true) or (extension_names[item] ~= nil)) then
			local sections = string_split(item, ".")
			local ext = sections[#sections]
			if (extension_names[ext] ~= nil) then
				new_items[i] = extension_names[ext][1].." "..item
				new_colours[i] = extension_names[ext][2]
			elseif (extension_names[item] ~= nil) then
				new_items[i] = extension_names[item][1].." "..item
				new_colours[i] = extension_names[item][2]
			else
				new_colours[i] = "blank"

				if (not directories) then
					new_items[i] = "󰡯 "..item
				else
					new_items[i] = " "..item
				end
			end
		else
			new_colours[i] = "blank"

			if (not directories) then
				new_items[i] = "󰡯 "..item
			else
				new_items[i] = " "..item
			end
		end
	end
	return new_items, new_colours
end

function list_stuff(directories)
	local directory = vim.fn.getcwd()
	local i, t = 0, {}
	local childItems, popen = "", io.popen
    local system_delimiter = package.config:sub(1,1)

	if (vim.fn.executable('pwsh') == 1) then
		if (directories) then
			childItems = popen('pwsh -Command Get-ChildItem -Force -Name -Directory -Path "'..directory..'"')
		else
			childItems = popen('pwsh -Command Get-ChildItem -Force -Name -File -Path "'..directory..'"')
		end

	elseif (vim.fn.executable('powershell.exe') == 1) then
		if (directories) then
			childItems = popen('powershell.exe -Command Get-ChildItem -Force -Name -Directory -Path "'..directory..'"')
		else
			childItems = popen('powershell.exe -Command Get-ChildItem -Force -Name -File -Path "'..directory..'"')
		end

	elseif(system_delimiter == '\\') then
		if (directories) then
			childItems = popen('dir "'..directory..'" /ad /b')
		else
			childItems = popen('dir "'..directory..'" /a-d /b')
		end

	elseif(system_delimiter == '/') then
		if (directories) then
			childItems = popen('find . "'..directory..'" -maxdepth 1 -type d')
		else
			childItems = popen('find . "'..directory..'" -maxdepth 1 -not -type d')
		end
	end

	for filename in childItems:lines() do
        i = i + 1
        t[i] = filename
    end

    childItems:close()
	--table.insert(t, 1, tostring(directory))
    return t

end

-- Function to create a floating window
function M.create_floating_window()
    -- Define the size of the floating window
    local win_width = math.ceil(vim.o.columns * 0.2)
    local win_height = math.ceil(vim.o.lines * 0.2)

    -- Create a new buffer (unlisted, scratch buffer)
    local buf = vim.api.nvim_create_buf(false, true)

    -- Set buffer options
	-- vim.api.nvim_win_set_option(win, 'winblend', 10)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    
    -- Define window options
    local opts = {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = vim.o.lines - win_height,
        col = 0,
        style = 'minimal',
        border = 'single'
    }
    
    -- Create the floating window
    local win = vim.api.nvim_open_win(buf, true, opts)
    
    -- Set some window options
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_option(win, 'cursorcolumn', false)
    
    -- Populate the buffer with some text
	local dirs, dir_cols = attach_icons(list_stuff(true), true)
	local files, file_cols = attach_icons(list_stuff(false), false)
	local output, output_cols = TableConcat(dirs, files), TableConcat(dir_cols, file_cols)
	--print(vim.inspect(output))
	--print(vim.inspect(output_cols))

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
	
	declare_colours()
	for i, val in ipairs(output) do
	--	print(vim.inspect(output_cols[i]))
		if (output_cols[i] ~= "blank") then
			vim.api.nvim_buf_add_highlight(buf, -1, output_cols[i], i - 1, 0, -1)
		end
	end
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

