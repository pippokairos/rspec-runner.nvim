local M = {}

local Job = require("plenary.job")

---@param test_file string
---@return integer, integer
local function create_floating_window(test_file)
	local buffer = vim.api.nvim_create_buf(false, true)
	local title = "RSpec: " .. test_file
	local width = vim.o.columns
	local height = vim.o.lines
	local win_width = math.ceil(width * 0.8)
	local win_height = math.ceil(height * 0.8)
	local row = math.floor((height - win_height) / 2)
	local col = math.floor((width - win_width) / 2)

	local window = vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
		title = title,
		title_pos = "center",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "double",
	})

	vim.api.nvim_buf_set_keymap(buffer, "n", "q", ":close<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_option_value("filetype", "rspec", {})

	return buffer, window
end

---@param buffer integer
---@param output string
---@return nil
local function schedule_output(buffer, output)
	vim.schedule(function()
		vim.api.nvim_buf_set_lines(buffer, -1, -1, false, { output })
		vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(buffer), 0 })
	end)
end

function M.run_file()
	local current_file = vim.api.nvim_buf_get_name(0)
	local test_file = M._find_test_file(current_file)

	if test_file then
		local bundle_path = vim.trim(vim.fn.system("which bundle"))
		if bundle_path == "" then
			print("Bundle not found")
			return
		end

		local buffer, _ = create_floating_window(test_file)

		Job:new({
			command = bundle_path,
			args = { "exec", "rspec", test_file },
			env = {
				PATH = vim.env.PATH,
				GEM_HOME = os.getenv("GEM_HOME") or "",
				RBENV_ROOT = os.getenv("RBENV_ROOT") or "",
			},
			on_stdout = function(_, data)
				if data and data ~= "" then
					schedule_output(buffer, data)
				end
			end,
			on_stderr = function(_, data)
				if data and data ~= "" then
					schedule_output(buffer, data)
				end
			end,
			on_exit = function(job, return_val)
				vim.schedule(function()
					if return_val == 0 then
						vim.api.nvim_buf_set_lines(
							buffer,
							0,
							-1,
							false,
							vim.split(table.concat(job:result(), "\n"), "\n")
						)
					else
						vim.api.nvim_buf_set_lines(
							buffer,
							0,
							-1,
							false,
							vim.split(table.concat(job:stderr_result(), "\n"), "\n")
						)
					end
				end)
			end,
		}):start()
	end
end

---@param file string
---@return string?
function M._find_test_file(file)
	local test_file = file:gsub("app", "spec"):gsub(".rb", "_spec.rb")

	if vim.fn.filereadable(test_file) ~= 1 then
		print("Test file not found: " .. test_file)
		return
	end

	return test_file
end

return M
