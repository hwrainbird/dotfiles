return {
  "epwalsh/obsidian.nvim",
  version = "*", -- Use latest release
  ft = "markdown",
  event = { "BufReadPre *.md", "BufNewFile *.md" },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",

    -- see below for full list of optional dependencies 👇
  },
  config = function()
    -- Ensure nvim-cmp is available for obsidian completion
    local has_cmp = pcall(require, "cmp")

    require("obsidian").setup({
      -- A list of workspace names, paths, and configuration overrides.
      -- If you use the Obsidian app, the 'path' of a workspace should generally be
      -- your vault root (where the `.obsidian` folder is located).
      -- When obsidian.nvim is loaded by your plugin manager, it will automatically set
      -- the workspace to the first workspace in the list whose `path` is a parent of the
      -- current markdown file being edited.
      workspaces = {
        {
          path = "/Users/knack/notes",
        },
        {
          path = "/Users/knack/clients",
        },
        {
          name = "global",
          path = function()
            -- Return the directory of the current file
            return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
          end,
          overrides = {
            notes_subdir = vim.NIL, -- disable subdirectory for global workspace
          },
        },
      },

      -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
      completion = {
        -- Set to false to disable completion.
        nvim_cmp = has_cmp,
        -- Trigger completion at 2 chars.
        min_chars = 2,
      },

      -- Daily note configuration to match bin/note command
      daily_notes = {
        folder = "daily",
        date_format = "%a %b %eth %Y", -- Format: Sat Nov 29th 2025
        alias_format = "%B %-d, %Y",
        default_tags = { "daily" },
        template = "reference/Daily Note Template.md",
      },

      -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
      -- way then set 'mappings = {}'.
      mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        -- Toggle check-boxes.
        ["<leader>ch"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
        -- Smart action depending on context, either follow link or toggle checkbox.
        ["<cr>"] = {
          action = function()
            return require("obsidian").util.smart_action()
          end,
          opts = { buffer = true, expr = true },
        },
      },

      -- Where to put new notes. Valid options are
      --  * "current_dir" - put new notes in same directory as the current buffer.
      --  * "notes_subdir" - put new notes in the default notes subdirectory.
      new_notes_location = "notes_subdir",

      -- Optional, customize how note IDs are generated given an optional title.
      ---@param title string|?
      ---@return string
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        local suffix = ""
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          -- If title is nil, just add 4 random uppercase letters to the suffix.
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. "-" .. suffix
      end,

      -- Optional, customize how note file names are generated given the ID, target directory, and title.
      ---@param spec { id: string, dir: obsidian.Path, title: string|? }
      ---@return string|obsidian.Path The full path to the new note.
      note_path_func = function(spec)
        -- This is equivalent to the default behavior.
        local path = spec.dir / tostring(spec.id)
        return path:with_suffix(".md")
      end,

      -- Optional, customize how wiki links are formatted. You can set this to one of:
      --  * "use_alias_only", e.g. '[[Foo Bar]]'
      --  * "prepend_note_id", e.g. '[[foo-bar|Foo Bar]]'
      --  * "prepend_note_path", e.g. '[[foo-bar.md|Foo Bar]]'
      --  * "use_path_only", e.g. '[[foo-bar.md]]'
      -- Or you can set it to a function that takes a table of options and returns a string, like this:
      wiki_link_func = function(opts)
        return require("obsidian.util").wiki_link_id_prefix(opts)
      end,

      -- Optional, customize how markdown links are formatted.
      markdown_link_func = function(opts)
        return require("obsidian.util").markdown_link(opts)
      end,

      -- Either 'wiki' or 'markdown'.
      preferred_link_style = "markdown",

      -- Optional, boolean or a function that takes a filename and returns a boolean.
      -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
      disable_frontmatter = false,

      -- Optional, alternatively you can customize the frontmatter data.
      ---@return table
      note_frontmatter_func = function(note)
        -- Add the title of the note as an alias.
        if note.title then
          note:add_alias(note.title)
        end

        local out = { id = note.id, aliases = note.aliases, tags = note.tags }

        -- `note.metadata` contains any manually added fields in the frontmatter.
        -- So here we just make sure those fields are kept in the frontmatter.
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end

        return out
      end,

      -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
      -- URL it will be ignored but you can customize this behavior here.
      ---@param url string
      follow_url_func = function(url)
        -- Open the URL in the default web browser (cross-platform)
        if vim.fn.has("mac") == 1 then
          vim.fn.jobstart({ "open", url })
        elseif vim.fn.has("unix") == 1 then
          vim.fn.jobstart({ "xdg-open", url })
        elseif vim.fn.has("win32") == 1 then
          vim.cmd(':silent exec "!start ' .. url .. '"')
        end
      end,

      -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
      -- file it will be ignored but you can customize this behavior here.
      ---@param img string
      follow_img_func = function(img)
        -- Open image with default viewer (cross-platform)
        if vim.fn.has("mac") == 1 then
          vim.fn.jobstart({ "qlmanage", "-p", img })
        elseif vim.fn.has("unix") == 1 then
          vim.fn.jobstart({ "xdg-open", img })
        elseif vim.fn.has("win32") == 1 then
          vim.cmd(':silent exec "!start ' .. img .. '"')
        end
      end,

      -- Optional, set to true if you use the Obsidian Advanced URI plugin.
      -- https://github.com/Vinzent03/obsidian-advanced-uri
      use_advanced_uri = false,

      -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
      open_app_foreground = false,

      -- Disable picker for now to avoid telescope errors
      -- picker = {
      --   name = "telescope.nvim",
      -- },

      -- Optional, sort search results by "path", "modified", "accessed", or "created".
      -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
      -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
      sort_by = "modified",
      sort_reversed = true,

      -- Set the maximum number of lines to read from notes on disk when performing certain searches.
      search_max_lines = 1000,

      -- Optional, determines how certain commands open notes. The valid options are:
      -- 1. "current" (the default) - to always open in the current window
      -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
      -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
      open_notes_in = "current",

      -- Optional, define your own callbacks to further customize behavior.
      callbacks = {
        -- Runs at the end of `require("obsidian").setup()`.
        ---@param client obsidian.Client
        post_setup = function(client) end,

        -- Runs anytime you enter the buffer for a note.
        ---@param client obsidian.Client
        ---@param note obsidian.Note
        enter_note = function(client, note)
          -- Set conceallevel for obsidian UI features
          vim.opt_local.conceallevel = 2
          vim.opt_local.concealcursor = "nc" -- Hide concealed text in normal and command mode only
          -- Force UI refresh
          if client.ui then
            client.ui:refresh(0)
          end
        end,

        -- Runs anytime you leave the buffer for a note.
        ---@param client obsidian.Client
        ---@param note obsidian.Note
        leave_note = function(client, note) end,

        -- Runs right before writing the buffer for a note.
        ---@param client obsidian.Client
        ---@param note obsidian.Note
        pre_write_note = function(client, note) end,

        -- Runs anytime the workspace is set/changed.
        ---@param client obsidian.Client
        ---@param workspace obsidian.Workspace
        post_set_workspace = function(client, workspace) end,
      },

      -- Optional, configure additional syntax highlighting / extmarks.
      -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
      ui = {
        enable = true, -- set to false to disable all additional syntax features
        update_debounce = 200, -- update delay after a text change (in milliseconds)
        max_file_length = 5000, -- disable UI features for files with more than this many lines
        -- Define how various check-boxes are displayed
        checkboxes = {
          [" "] = { char = "☐", hl_group = "ObsidianTodo" },
          ["x"] = { char = "✓", hl_group = "ObsidianDone" },
          [">"] = { char = "▶", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "~", hl_group = "ObsidianTilde" },
          ["!"] = { char = "!!", hl_group = "ObsidianImportant" },
        },
        -- Use bullet marks for non-checkbox lists.
        bullets = { char = "•", hl_group = "ObsidianBullet" },
        external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" }, -- nf-md-open_in_new
        reference_text = { hl_group = "ObsidianRefText" },
        highlight_text = { hl_group = "ObsidianHighlightText" },
        tags = { hl_group = "ObsidianTag" },
        block_ids = { hl_group = "ObsidianBlockID" },
        hl_groups = {
          -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
          ObsidianTodo = { bold = true, fg = "#f78c6c" },
          ObsidianDone = { bold = true, fg = "#89ddff" },
          ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
          ObsidianTilde = { bold = true, fg = "#ff5370" },
          ObsidianImportant = { bold = true, fg = "#d73128" },
          ObsidianBullet = { bold = true, fg = "#89ddff" },
          ObsidianRefText = { underline = true, fg = "#c792ea" },
          ObsidianExtLinkIcon = { fg = "#c792ea" },
          ObsidianTag = { italic = true, fg = "#89ddff" },
          ObsidianBlockID = { italic = true, fg = "#89ddff" },
          ObsidianHighlightText = { bg = "#75662e" },
        },
      },

      -- Specify how to handle attachments.
      attachments = {
        -- The default folder to place images in via `:ObsidianPasteImg`.
        -- If this is a relative path it will be interpreted as relative to the vault root.
        -- You can always override this per image by passing a full path to the command instead of just a filename.
        img_folder = "assets/imgs", -- This is the default

        -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
        ---@return string
        img_name_func = function()
          -- Prefix image names with timestamp.
          return string.format("%s-", os.time())
        end,

        -- A function that determines the text to insert in the note when pasting an image.
        -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
        -- This is the default implementation.
        ---@param client obsidian.Client
        ---@param path obsidian.Path the absolute path to the image file
        ---@return string
        img_text_func = function(client, path)
          path = client:vault_relative_path(path) or path
          return string.format("![%s](%s)", path.name, path)
        end,
      },
    })

    -- Ensure markdown files have proper conceallevel for checkbox rendering
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = "nc" -- Hide concealed text in normal and command mode only
      end,
    })
  end,
}
