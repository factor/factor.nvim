local M = {}
local buffers = {}
local group = vim.api.nvim_create_augroup("FactorFtplugin", { clear = false })

-- Return insert-mode keystrokes without editing the buffer under textlock.
-- C-G U keeps cursor movement in the same undo block.
-- Leave key notation for vim.keymap.set() to convert once, including on 0.7.
local function insert(before, after)
    return before .. after .. string.rep("<C-G>U<Left>", #after)
end

local function context()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local pair = col > 0 and line:sub(col, col + 1) or ""
    local wider = col > 1 and line:sub(col - 1, col + 2) or ""
    return pair, wider, line, col
end

local function pad_after()
    local _, _, line, col = context()
    if col < #line and line:sub(col + 1, col + 1) ~= " " then
        return insert("", " ")
    end
    return ""
end

local autopairs = {
    ["("] = function()
        local pair = context()
        return (pair ~= "()" and pad_after() or "") .. insert("(", ")")
    end,
    ["["] = function()
        local pair = context()
        return (pair ~= "==" and pair ~= "[]" and pad_after() or "") .. insert("[", "]")
    end,
    ["{"] = function() return pad_after() .. insert("{", "}") end,
    ["="] = function()
        local pair = context()
        return insert("=", (pair == "[]" or pair == "==") and "=" or "")
    end,
    ['"'] = function()
        return context() == '""' and "" or pad_after() .. insert('"', '"')
    end,
    ["<CR>"] = function()
        local pair, wider = context()
        if pair == "[]" or pair == "{}" or wider == "[  ]" or wider == "{  }" then
            return "<CR><C-O>O"
        end
        return "<CR>"
    end,
    ["<BS>"] = function()
        local pair, wider = context()
        if wider == "[  ]" or wider == "(  )" or wider == "{  }"
            or pair == '""' or pair == "==" or pair == "()" or pair == "[]" or pair == "{}" then
            return "<Del><BS>"
        end
        return "<BS>"
    end,
    ["<Space>"] = function()
        local pair, wider, line, col = context()
        if pair == "[]" or pair == "{}" or wider == "(())"
            or (col >= 4 and line:sub(col - 3, col + 1) == ":> ()") then
            return insert(" ", " ")
        elseif pair == "()" then
            return insert(" ", "-- ")
        end
        return " "
    end,
}

local function map(state, mode, lhs, rhs, opts)
    lhs = lhs:gsub("<Leader>", function() return vim.g.mapleader or "\\" end)
    -- Leave existing user and other-plugin mappings in place.
    if next(vim.fn.maparg(lhs, mode, false, true)) then
        return
    end
    opts = vim.tbl_extend("force", { buffer = state.buffer, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
    -- Older Neovim releases wrap expression callbacks in vim.keymap.set().
    local installed = vim.fn.maparg(lhs, mode, false, true)
    table.insert(state.maps, {
        mode = mode, lhs = lhs, rhs = installed.rhs, callback = installed.callback,
    })
end

function M.undo()
    local buffer = vim.api.nvim_get_current_buf()
    local state = buffers[buffer]
    if not state then return end
    for _, mapping in ipairs(state.maps) do
        local current = vim.fn.maparg(mapping.lhs, mapping.mode, false, true)
        local unchanged = mapping.callback and current.callback == mapping.callback
            or (not mapping.callback and current.rhs == mapping.rhs)
        if current.buffer == 1 and unchanged then
            vim.keymap.del(mapping.mode, mapping.lhs, { buffer = buffer })
        end
    end
    for _, id in ipairs(state.autocmds) do
        pcall(vim.api.nvim_del_autocmd, id)
    end
    buffers[buffer] = nil
end

function M.attach()
    local factor = require("factor")
    local buffer = vim.api.nvim_get_current_buf()
    local state = { buffer = buffer, maps = {}, autocmds = {} }
    buffers[buffer] = state
    if factor.config.default_mappings then
        for _, mapping in ipairs({
            { "<Leader>fi", ":FactorVocabImpl<CR>", "Go to Factor vocab implementation" },
            { "<Leader>fd", ":FactorVocabDocs<CR>", "Go to Factor vocab docs" },
            { "<Leader>ft", ":FactorVocabTests<CR>", "Go to Factor vocab tests" },
            { "<Leader>fv", ":FactorVocab ", "Go to Factor vocabulary" },
            { "<Leader>fn", ":NewFactorVocab ", "Create new Factor vocabulary" },
        }) do
            map(state, "n", mapping[1], mapping[2], { desc = mapping[3] })
        end
    end
    if factor.config.enable_autopairs then
        for lhs, rhs in pairs(autopairs) do
            map(state, "i", lhs, rhs, { expr = true })
        end
        table.insert(state.autocmds, vim.api.nvim_create_autocmd("BufWritePre", {
            group = group,
            buffer = buffer,
            callback = function()
                local view = vim.fn.winsaveview()
                vim.cmd([[silent keepjumps keeppatterns %s/ \+$//e]])
                vim.fn.winrestview(view)
            end,
        }))
    end
    table.insert(state.autocmds, vim.api.nvim_create_autocmd("BufWipeout", {
        group = group,
        buffer = buffer,
        once = true,
        callback = function() buffers[buffer] = nil end,
    }))
end

return M
