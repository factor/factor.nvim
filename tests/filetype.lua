return function(root, equal)
    local factor = require("factor")
    factor.setup({enable_autopairs = true, default_mappings = true})
    vim.g.mapleader = ","

    local sequence = 0
    local function fresh(name)
        sequence = sequence + 1
        vim.cmd("enew!")
        vim.cmd("file " .. vim.fn.fnameescape(root .. "/" .. sequence .. "-" .. name))
        vim.cmd("setfiletype factor")
    end

    local function type_keys(input)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input, true, false, true), "xt", false)
    end

    for _, case in ipairs({
        {"i[=<Esc>", "[==]"},
        {"i( <Esc>", "( -- )"},
        {"i[ <Esc>", "[  ]"},
        {"i{ <Esc>", "{  }"},
        {'i""<Esc>', '""'},
        {"i[<BS><Esc>", ""},
        {"i[ <BS><BS><Esc>", ""},
        {"iα[=<Esc>", "α[==]"},
        {"i:> ( <Esc>", ":> (  )"},
        {"iabc<BS><Esc>", "ab"},
    }) do
        fresh("pairs.factor")
        type_keys(case[1])
        equal(case[2], vim.api.nvim_get_current_line(), "typing " .. case[1])
    end
    fresh("pairs.factor")
    vim.api.nvim_set_current_line("if")
    type_keys("i[<Esc>")
    equal("[] if", vim.api.nvim_get_current_line(), "pad before existing word")
    fresh("pairs.factor")
    type_keys("i[<CR>word<Esc>")
    equal({"[", "    word", "]"}, vim.api.nvim_buf_get_lines(0, 0, -1, false), "multiline quotation")
    fresh("pairs.factor")
    type_keys("i[=word<Esc>u")
    equal("", vim.api.nvim_get_current_line(), "pair insertion stays in one undo block")

    fresh("cleanup.factor")
    equal(1, vim.fn.maparg(",fi", "n", false, true).buffer, "buffer-local defaults")
    equal(1, vim.fn.maparg("[", "i", false, true).expr, "expression pairs")
    local buffer = vim.api.nvim_get_current_buf()
    equal(1, #vim.api.nvim_get_autocmds({event = "BufWritePre", buffer = buffer}))
    vim.g.mapleader = ";"
    vim.cmd("setlocal filetype=text")
    equal({}, vim.fn.maparg(",fi", "n", false, true), "cleanup uses original leader")
    equal({}, vim.fn.maparg("[", "i", false, true), "remove pair mappings")
    equal(0, #vim.api.nvim_get_autocmds({event = "BufWritePre", buffer = buffer}))
    equal(vim.go.textwidth, vim.bo.textwidth, "restore formatting")
    equal(vim.go.iskeyword, vim.bo.iskeyword, "restore word characters")
    equal(nil, vim.b.match_words)
    vim.cmd("setlocal filetype=factor")
    equal(1, vim.fn.maparg("[", "i", false, true).expr, "reattach after filetype change")
    equal(1, #vim.api.nvim_get_autocmds({event = "BufWritePre", buffer = buffer}))
    vim.api.nvim_set_current_line("hello   ")
    vim.cmd("write")
    equal("hello", vim.fn.readfile(vim.fn.expand("%:p"))[1], "trim whitespace on save")

    factor.setup({enable_autopairs = false, default_mappings = false})
    fresh("disabled.factor")
    equal({}, vim.fn.maparg(";fi", "n", false, true), "disable defaults")
    equal({}, vim.fn.maparg("[", "i", false, true), "pairs opt in")
    factor.setup({enable_autopairs = true, default_mappings = true})
    vim.keymap.set("n", ";fi", ":echo 'user'<CR>")
    vim.keymap.set("i", "[", "user")
    fresh("user.factor")
    equal(0, vim.fn.maparg(";fi", "n", false, true).buffer, "preserve user navigation map")
    equal("user", vim.fn.maparg("[", "i", false, true).rhs, "preserve user pair map")
    vim.cmd("setlocal filetype=text")
    equal("user", vim.fn.maparg("[", "i", false, true).rhs)
    vim.keymap.del("n", ";fi")
    vim.keymap.del("i", "[")

    fresh("replacement.factor")
    vim.keymap.set("i", "[", "replacement", {buffer = true})
    vim.keymap.set("n", ";fi", ":echo 'replacement'<CR>", {buffer = true})
    vim.cmd("setlocal filetype=text")
    equal("replacement", vim.fn.maparg("[", "i", false, true).rhs, "preserve later user mapping")
    equal(1, vim.fn.maparg(";fi", "n", false, true).buffer)

    for name, filetype in pairs({
        ["detect.factor"] = "factor",
        ["detect-docs.factor"] = "factor.factor-docs",
        ["detect-tests.factor"] = "factor",
        [".factor-rc"] = "factor",
        ["factor-custom-rc"] = "factor",
    }) do
        vim.cmd("edit " .. vim.fn.fnameescape(root .. "/" .. name))
        equal(filetype, vim.bo.filetype, "detect " .. name)
        equal(filetype == "factor.factor-docs" and 0 or 64, vim.bo.textwidth, "documentation formatting")
        vim.cmd("setlocal filetype=text")
        equal(vim.go.textwidth, vim.bo.textwidth, "undo documentation formatting")
    end

    vim.cmd("enew!")
    equal({}, vim.fn.maparg(";fi", "n", false, true), "no global defaults")
    local resources = vim.api.nvim_get_autocmds({group = "FactorFtplugin"})
    fresh("wipe.factor")
    vim.cmd("bwipeout!")
    equal(#resources, #vim.api.nvim_get_autocmds({group = "FactorFtplugin"}), "release buffer autocmds")
end
