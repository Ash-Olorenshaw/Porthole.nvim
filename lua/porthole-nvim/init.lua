-- Porthole.nvim
-- Provides a little popup filetree to easily get a small but quick idea of the project overview.
-- created by Ash Olorenshaw

local M = {}
local extension_names = require 'porthole-nvim.icon_map'
local utils = require 'porthole-nvim.utils'
local declare_colours, string_split, table_concat = utils.declare_colours, utils.string_split, utils.table_concat

local config = {
	width_ratio = 0.2,
	height_ratio = 0.2,
	quit_key = 'q',
	reload_key = 'r',
	action_key = '<CR>',
	use_icons = true
}

local current_dir = vim.fn.getcwd()
local system_delimiter = package.config:sub(1,1)
local window = nil
local buffer = nil


declare_colours()

function up_dir()
	local dir_parts = string_split(current_dir, system_delimiter)
	if (#dir_parts > 1) then
		local relevant_items = table.move(dir_parts, 1, #dir_parts - 1, 1, {})
		print(vim.inspect(relevant_items))
		current_dir = table.concat(relevant_items, system_delimiter)
	elseif (system_delimiter == '/') then
		current_dir = '/'
	end

	print(vim.inspect(current_dir))
	generate_buffer()
end

function move_object(file_name)
	local win_width = math.ceil(vim.o.columns * 0.5)
    local win_height = math.ceil(vim.o.lines * 0.1)
    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    
    local opts = {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = vim.o.lines / 2,
        col = vim.o.columns / 2,
        style = 'minimal',
        border = 'single'
    }
    
    win = vim.api.nvim_open_win(buf, true, opts)
    
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_option(win, 'cursorcolumn', false)
	vim.api.nvim_win_set_option(win, 'winblend', 10)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {file_name})

    vim.keymap.set('n', config.reload_key, function() issue_move_command(file_name) end, { noremap = true, silent = true })
end

function cursor_interact(dirs, files, interaction_type)
	y, x = unpack(vim.api.nvim_win_get_cursor(0))
	if (y == 2) then
		up_dir()
	elseif (1 < y and y <= #dirs + 2) then
		if (interaction_type == "move") then
			move_object(dirs[y - 2])
		else
			-- go inside dir
			current_dir = current_dir..system_delimiter..dirs[y - 2]
			generate_buffer()
		end
	elseif (y > #dirs + 2) then
		if (type == "move") then
			move_object(files[y - #dirs - 2])
		else
			-- edit file
			vim.cmd("execute \"normal \\<C-w>p\" | :edit "..current_dir..system_delimiter..files[y - #dirs - 2])
		end
	end
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

				if (not directories) then
					new_items[i] = "󰡯 "..item
					new_colours[i] = "blank"
				else
					new_items[i] = " "..item
					new_colours[i] = "dir"
				end
			end
		else

			if (not directories) then
				new_items[i] = "󰡯 "..item
				new_colours[i] = "blank"
			else
				new_items[i] = " "..item
				new_colours[i] = "dir"
			end
		end
	end

	if (config.use_icons) then
		return new_items, new_colours
	else
		return items, new_colours
	end
end

function list_stuff(directories)
	local i, t = 0, {}
	local childItems, popen = "", io.popen

	if (vim.fn.executable('dotnet') == 1) then
		-- if we can, run the DotNet F# program - Lister
		local dir_parts = string_split(debug.getinfo(1).source:sub(2), "/")
		local relevant_items = table.move(dir_parts, 1, #dir_parts - 1, 1, {})
		local plug_dir = table.concat(relevant_items, system_delimiter)

		if (directories) then
			childItems = popen('dotnet "'..plug_dir..system_delimiter..'Lister/Lister.dll'..'" "'..current_dir..'" -d')
		else
			childItems = popen('dotnet "'..plug_dir..system_delimiter..'Lister/Lister.dll'..'" "'..current_dir..'" -f')
		end
	else
		if (vim.fn.executable('pwsh') == 1) then
			if (directories) then
				childItems = popen('pwsh -Command Get-ChildItem -Force -Name -Directory -Path "'..current_dir..'"')
			else
				childItems = popen('pwsh -Command Get-ChildItem -Force -Name -File -Path "'..current_dir..'"')
			end

		elseif (vim.fn.executable('powershell.exe') == 1) then
			if (directories) then
				childItems = popen('powershell.exe -Command Get-ChildItem -Force -Name -Directory -Path "'..current_dir..'"')
			else
				childItems = popen('powershell.exe -Command Get-ChildItem -Force -Name -File -Path "'..current_dir..'"')
			end

		elseif(system_delimiter == '\\') then
			if (directories) then
				childItems = popen('dir "'..current_dir..'" /ad /b')
			else
				childItems = popen('dir "'..current_dir..'" /a-d /b')
			end

		elseif(system_delimiter == '/') then
			if (directories) then
				childItems = popen('find . "'..current_dir..'" -maxdepth 1 -type d')
			else
				childItems = popen('find . "'..current_dir..'" -maxdepth 1 -not -type d')
			end
		end
	end

	for filename in childItems:lines() do
        i = i + 1
        t[i] = filename
    end

    childItems:close()
    return t

end

function generate_buffer()
	if not (buffer and vim.api.nvim_buf_is_valid(buffer)) then
		print("Error - unable to generate buffer for window. Buffer does not exist.")
		return
	end

	-- function to generate the output
    vim.api.nvim_buf_set_option(buffer, 'modifiable', true)
	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {})
	vim.api.nvim_buf_clear_namespace(buffer, -1, 0, -1)
	local dirs, files = list_stuff(true, system_delimiter, current_dir), list_stuff(false, system_delimiter, current_dir)

	local dirs_icons, dir_cols = attach_icons(dirs, true)
	local files_icons, file_cols = attach_icons(files, false)
	local output, output_cols = table_concat(dirs_icons, files_icons), table_concat(dir_cols, file_cols)

	-- show current path and up dir button
	table.insert(output, 1, "..")
	table.insert(output, 1, current_dir)
	table.insert(output_cols, 1, "blank")
	table.insert(output_cols, 1, "Porthole-LightPurple")


    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, output)
	
	for i, val in ipairs(output) do
		if (output_cols[i] ~= "blank") then
			if (i == 1) then
				vim.api.nvim_buf_add_highlight(buffer, -1, output_cols[i], i - 1, 0, -1)
			elseif (output_cols[i] == "dir") then
				vim.api.nvim_buf_add_highlight(buffer, -1, "Porthole-LightYellow", i - 1, 0, -1)
			else
				if (config.use_icons) then
					vim.api.nvim_buf_add_highlight(buffer, -1, output_cols[i], i - 1, 0, 3)
				else
					vim.api.nvim_buf_add_highlight(buffer, -1, output_cols[i], i - 1, 0, -1)
				end
			end
		end
	end

    vim.keymap.set('n', config.action_key, function() cursor_interact(dirs, files, "interact") end, { noremap = true, silent = true, buffer = true })
    vim.keymap.set('n', 'm', function() cursor_interact(dirs, files, "move") end, { noremap = true, silent = true, buffer = true })

    vim.api.nvim_buf_set_option(buffer, 'modifiable', false)
end

function create_small_popup(content)
end

function M.create_floating_window()
	if window and vim.api.nvim_win_is_valid(window) then
    	vim.api.nvim_set_current_win(window)
    	return
	end

    local win_width = math.ceil(vim.o.columns * config.width_ratio)
    local win_height = math.ceil(vim.o.lines * config.height_ratio)

    -- Create a new buffer (unlisted, scratch buffer)
    buffer = vim.api.nvim_create_buf(false, true)

    -- Set options
    vim.api.nvim_buf_set_option(buffer, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buffer, 'bufhidden', 'wipe')
    
    local opts = {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = vim.o.lines - win_height,
        col = 0,
        style = 'minimal',
        border = 'single'
    }
    
	-- make window
    window = vim.api.nvim_open_win(buffer, true, opts)
    
    -- Set some window options
    vim.api.nvim_win_set_option(window, 'wrap', false)
    vim.api.nvim_win_set_option(window, 'cursorline', true)
    vim.api.nvim_win_set_option(window, 'cursorcolumn', false)
	vim.api.nvim_win_set_option(window, 'winblend', 10)
    
	generate_buffer()

    vim.api.nvim_buf_set_keymap(buffer, 'n', config.quit_key, ':bd!<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', config.reload_key, function() generate_buffer() end, { noremap = true, silent = true })
end

function issue_move_command(current_item) 
	local future_item = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]

	if (vim.fn.executable('pwsh') == 1) then
		childItems = popen('pwsh -Command Move-Item "'..current_item..'" "'..future_item..'"')

	elseif (vim.fn.executable('powershell.exe') == 1) then
		childItems = popen('powershell.exe -Command Move-Item "'..current_item..'" "'..future_item..'"')

	elseif(system_delimiter == '\\') then
			childItems = popen('move "'..current_item..'" "'..future_item..'"')

	elseif(system_delimiter == '/') then
		childItems = popen('mv "'..current_item..'" "'..future_item..'"')
	end
end

function M.setup(user_config)
	config = vim.tbl_deep_extend('force', config, user_config or {})
end

return M

