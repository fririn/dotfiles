-- Set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Default in Neovim 0.10+, but harmless to keep for older versions
vim.opt.termguicolors = true

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Setting options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 15

-- Sync clipboard between OS and Neovim.
-- This allows you to Ctrl+V outside and 'p' inside, or 'y' inside and Ctrl+V outside.
-- If you enable this, you likely don't need the <leader>y mappings below.
-- vim.opt.clipboard = "unnamedplus"

-- Basic Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("i", "kj", "<Esc>")

vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+yg')
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>yy", '"+yy')

vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Move to right split" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Move to split below" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Move to split above" })

vim.keymap.set("n", "<S-h>", ":bprev<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>q", function()
	require("mini.bufremove").delete(0, false)
end, { desc = "Delete Buffer" })

-- :q closes current buffer, or quits nvim if it's the last one
vim.cmd(
	[[cnoreabbrev <expr> q (getcmdtype() == ':' && getcmdline() == 'q') ? (len(getbufinfo({'buflisted': 1})) > 1 ? 'bd' : 'q') : 'q']]
)

-- wrap word into ' or "
vim.keymap.set("n", '<leader>"', 'ciw""<Esc>P', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>'", "ciw''<Esc>P", { noremap = true, silent = true })

-- Basic Autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Force transparency + brighten dim UI elements on every theme change
vim.api.nvim_create_autocmd("ColorScheme", {
	desc = "Transparency and brighter line numbers/split border",
	group = vim.api.nvim_create_augroup("bright-ui-elements", { clear = true }),
	callback = function()
		-- Transparency (works for any theme)
		vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
		vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE", ctermbg = "NONE" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", ctermbg = "NONE" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE", ctermbg = "NONE" })
		-- Brighter line numbers and split border
		vim.api.nvim_set_hl(0, "LineNr", { fg = "#6b7280" })
		vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#6b7280" })
		vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#6b7280" })
		vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#e8a24a", bold = true })
		vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#4a5568" })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Disable Treesitter in Telescope prompt buffers",
	group = vim.api.nvim_create_augroup("telescope-prompt-no-treesitter", { clear = true }),
	pattern = "TelescopePrompt",
	callback = function(event)
		pcall(vim.treesitter.stop, event.buf)
	end,
})

-- Install `lazy.nvim` plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Configure and install plugins
require("lazy").setup({
	-- Which Key
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		opts = {
			delay = 0,
			icons = {
				mappings = vim.g.have_nerd_font,
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
				},
			},
			spec = {
				{ "<leader>c", group = "[C]ode", mode = { "n", "x" } },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>gh", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "echasnovski/mini.icons" },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					layout_strategy = "horizontal", -- "horizontal" | "vertical" | "flex" | "cursor" | "center" | "bottom_pane"
					layout_config = {
						horizontal = {
							width = 0.95,
							height = 0.95,
							preview_width = 0.7, -- preview takes 60% of the picker width
							preview_cutoff = 80, -- hide preview if terminal < 80 cols wide
						},
						vertical = {
							width = 0.95,
							height = 0.95,
							preview_height = 0.7,
						},
					},
					preview = {
						treesitter = false,
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })
			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })

			-- open a Telescope picker over `git log -<flag> <query>`
			local function git_log_search(flag, prompt_label, desc_flag)
				vim.ui.input({ prompt = "git log -" .. flag .. ": " }, function(query)
					if not query or query == "" then
						return
					end

					local pickers = require("telescope.pickers")
					local finders = require("telescope.finders")
					local conf = require("telescope.config").values
					local previewers = require("telescope.previewers")
					local actions = require("telescope.actions")
					local action_state = require("telescope.actions.state")

					-- derive web base URL from git remote (SSH or HTTPS, GitLab or GitHub)
					local remote = (vim.fn.systemlist({ "git", "remote", "get-url", "origin" })[1] or "")
					local web_base = remote
						:gsub("^git@([^:]+):", "https://%1/") -- SSH → HTTPS
						:gsub("%.git$", "") -- strip .git suffix
					local commit_path = web_base:find("gitlab", 1, true) and "/-/commit/" or "/commit/"

					local raw = vim.fn.systemlist({
						"git",
						"log",
						"--format=%H\t%ad\t%an\t%s",
						"--date=short",
						"-" .. flag,
						query,
					})

					if vim.v.shell_error ~= 0 or #raw == 0 then
						vim.notify("git log -" .. flag .. " '" .. query .. "': no commits found", vim.log.levels.INFO)
						return
					end

					local entries = {}
					for _, line in ipairs(raw) do
						local hash, date, author, subject = line:match("^([^\t]+)\t([^\t]+)\t([^\t]+)\t(.*)$")
						if hash then
							table.insert(entries, {
								hash = hash,
								short = hash:sub(1, 8),
								date = date,
								author = author,
								subject = subject,
							})
						end
					end

					pickers
						.new({
							layout_strategy = "vertical", -- "horizontal" | "vertical" | "flex" | "cursor" | "center" | "bottom_pane"
							layout_config = {
								horizontal = {
									width = 0.95,
									height = 0.95,
									preview_width = 0.7, -- preview takes 60% of the picker width
									preview_cutoff = 80, -- hide preview if terminal < 80 cols wide
								},
								vertical = {
									width = 0.95,
									height = 0.95,
									preview_height = 0.7,
								},
							},
						}, {
							prompt_title = "git log -" .. flag .. " '" .. query .. "'",
							finder = finders.new_table({
								results = entries,
								entry_maker = function(e)
									local display = string.format(
										"%s  %s  %-20s  %s",
										e.short,
										e.date,
										e.author:sub(1, 20),
										e.subject
									)
									return {
										value = e.hash,
										display = display,
										ordinal = e.date .. " " .. e.author .. " " .. e.subject,
									}
								end,
							}),
							previewer = previewers.new_buffer_previewer({
								title = "Patch",
								define_preview = function(self, entry)
									local lines = vim.fn.systemlist({ "git", "show", "--stat", "-p", entry.value })
									vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
									vim.bo[self.state.bufnr].filetype = "diff"
								end,
							}),
							sorter = conf.generic_sorter({}),
							attach_mappings = function(prompt_bufnr)
								actions.select_default:replace(function()
									actions.close(prompt_bufnr)
									local entry = action_state.get_selected_entry()
									if entry then
										local url = web_base .. commit_path .. entry.value
										vim.ui.open(url)
									end
								end)
								return true
							end,
						})
						:find()
				end)
			end

			-- <leader>sS  →  git log -S (pickaxe: commits that change the count of a string)
			vim.keymap.set("n", "<leader>sS", function()
				git_log_search("S", "git log -S", "S")
			end, { desc = "[S]earch git log -[S] pickaxe (string)" })

			-- <leader>sG  →  git log -G (regex match in patch text)
			vim.keymap.set("n", "<leader>sG", function()
				git_log_search("G", "git log -G", "G")
			end, { desc = "[S]earch git log -[G] pickaxe (regex)" })
		end,
	},

	-- LSP Plugins
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		config = true,
	},
	{
		"folke/trouble.nvim",
		dependencies = { "echasnovski/mini.icons" },
		opts = {},
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
		},
	},
	{
		"MagicDuck/grug-far.nvim",
		config = function()
			require("grug-far").setup({
				keymaps = {
					replace = { n = "<localleader>r" },
					close = { n = "<localleader>q" },
					help = { n = "<localleader>h" },
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "✘",
						[vim.diagnostic.severity.WARN] = "▲",
						[vim.diagnostic.severity.HINT] = "⚑",
						[vim.diagnostic.severity.INFO] = "»",
					},
				},
				virtual_text = { prefix = "●" },
			})
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			local capabilities = require("blink.cmp").get_lsp_capabilities()

			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
						},
					},
				},
				terraformls = {},
				tflint = {},
				ts_ls = {},
				pyright = {},
				cssls = {},
				html = {},
				jsonls = {},
			}

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	{
		"stevearc/oil.nvim",
		opts = {
			columns = {
				"icon",
				"permissions",
			},
		},
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				return {
					timeout_ms = 500,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
			},
		},
	},

	{ -- Autocompletion (blink.cmp — faster, built-in ghost text & signature help)
		"saghen/blink.cmp",
		version = "*",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
			},
		},
		opts = {
			keymap = {
				preset = "default",
				["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
				["<CR>"] = { "accept", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			snippets = { preset = "luasnip" },
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "lazydev" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
				},
			},
			completion = {
				ghost_text = { enabled = true },
			},
			signature = { enabled = true },
		},
	},

	-- Themes (loaded on demand, themery handles activation + persistence)
	{ "bluz71/vim-moonfly-colors", name = "moonfly", lazy = true },
	{ "miikanissi/modus-themes.nvim", lazy = true },
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("tokyonight")
		end,
		opts = {
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},

	{
		"zaldih/themery.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			themes = {
				{
					name = "Moonfly",
					colorscheme = "moonfly",
					before = [[vim.g.moonflyTransparent = true; vim.g.moonflyNormalFloat = true]],
				},
				{ name = "Modus Operandi", colorscheme = "modus_operandi" },
				{ name = "Modus Vivendi", colorscheme = "modus_vivendi" },
				{ name = "Tokyo Night", colorscheme = "tokyonight" },
				{ name = "Tokyo Night Storm", colorscheme = "tokyonight-storm" },
				{ name = "Tokyo Night Day", colorscheme = "tokyonight-day" },
			},
			livePreview = true,
		},
		keys = {
			{ "<leader>tt", "<cmd>Themery<CR>", desc = "[T]oggle [T]heme picker" },
		},
	},

	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{ -- Better f/t/s navigation with jump labels
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash Jump",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
		},
	},

	{ -- Inline color swatches for hex/rgb/hsl/tailwind
		"brenoprata10/nvim-highlight-colors",
		opts = {
			render = "background",
			enable_tailwind = true,
		},
	},

	{ -- Symbols outline sidebar (like VS Code's Outline panel)
		"stevearc/aerial.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
		opts = {},
		keys = {
			{ "<leader>a", "<cmd>AerialToggle!<CR>", desc = "Toggle Symbols Outline" },
		},
	},

	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			require("mini.icons").setup()
			require("mini.icons").mock_nvim_web_devicons()
			require("mini.comment").setup()
			require("mini.tabline").setup()
			require("mini.bufremove").setup()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		branch = "master",
		main = "nvim-treesitter.configs",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"css",
				"diff",
				"html",
				"javascript",
				"json",
				"lua",
				"luadoc",
				"markdown",
				"python",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			},
			auto_install = true,
			highlight = {
				enable = true,
				disable = function(_, bufnr)
					return vim.bo[bufnr].buftype == "prompt" or vim.bo[bufnr].filetype == "TelescopePrompt"
				end,
			},
			indent = { enable = true },
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]m"] = "@function.outer",
						["]]"] = "@class.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[["] = "@class.outer",
					},
				},
			},
		},
	},

	{ import = "kickstart.plugins" },
	{ import = "custom.plugins" },
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
