if vim.b.did_ftplugin then
    return
end
vim.b.did_ftplugin = 1

vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.textwidth = 64
vim.opt_local.colorcolumn = "+1"
vim.opt_local.comments = "b:!,f:#!"
vim.opt_local.commentstring = "! %s"
vim.opt_local.iskeyword = "33-126,128-255"

vim.b.match_words = "\\<<PRIVATE\\>:\\<PRIVATE>\\>"

local factor = require("factor")

if factor.config.enable_autopairs then
    local function remove_trailing_spaces()
        local save_view = vim.fn.winsaveview()
        vim.cmd([[%s/ \+$//e]])
        vim.fn.winrestview(save_view)
    end
    
    vim.api.nvim_create_autocmd("BufWrite", {
        buffer = 0,
        callback = remove_trailing_spaces
    })
    
    local function insert(before, after)
        local pos = vim.api.nvim_win_get_cursor(0)
        local line = vim.api.nvim_get_current_line()
        local new_line = line:sub(1, pos[2]) .. before .. after .. line:sub(pos[2] + 1)
        vim.api.nvim_set_current_line(new_line)
        vim.api.nvim_win_set_cursor(0, {pos[1], pos[2] + #before})
    end
    
    local function pad_after()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        if col < #line and line:sub(col + 1, col + 1) ~= " " then
            insert("", " ")
        end
    end
    
    local function context()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        return line:sub(math.max(1, col - 1), col)
    end
    
    local function wider_context()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        return line:sub(math.max(1, col - 2), col + 1)
    end
    
    local function open_parenthesis()
        local ctx = context()
        if ctx ~= "()" then
            pad_after()
        end
        insert("(", ")")
    end
    
    local function open_bracket()
        local ctx = context()
        if ctx ~= "==" and ctx ~= "[]" then
            pad_after()
        end
        insert("[", "]")
    end
    
    local function open_brace()
        pad_after()
        insert("{", "}")
    end
    
    local function equal()
        local ctx = context()
        if ctx == "[]" or ctx == "==" then
            insert("=", "=")
        else
            insert("=", "")
        end
    end
    
    local function quote()
        local ctx = context()
        if ctx == '""' then
            return ""
        else
            pad_after()
            insert('"', '"')
        end
    end
    
    local function return_key()
        local ctx = context()
        local wider = wider_context()
        if ctx == "[]" or ctx == "{}" or wider == "[  ]" or wider == "{  }" then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR><C-O>O", true, false, true), "n", false)
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
        end
    end
    
    local function backspace()
        local ctx = context()
        local wider = wider_context()
        if wider == "[  ]" or wider == "(  )" or wider == "{  }" or
           ctx == '""' or ctx == "==" or ctx == "()" or ctx == "[]" or ctx == "{}" then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Del><BS>", true, false, true), "n", false)
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", false)
        end
    end
    
    local function space()
        local ctx = context()
        local wider = wider_context()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        
        if ctx == "[]" or ctx == "{}" or wider == "(())" or
           line:sub(math.max(1, col - 4), col) == ":> ()" then
            insert(" ", " ")
        elseif ctx == "()" then
            insert(" ", "-- ")
        else
            insert(" ", "")
        end
    end
    
    vim.keymap.set("i", "(", open_parenthesis, { buffer = true })
    vim.keymap.set("i", "[", open_bracket, { buffer = true })
    vim.keymap.set("i", "{", open_brace, { buffer = true })
    vim.keymap.set("i", "=", equal, { buffer = true })
    vim.keymap.set("i", '"', quote, { buffer = true })
    vim.keymap.set("i", "<CR>", return_key, { buffer = true })
    vim.keymap.set("i", "<BS>", backspace, { buffer = true })
    vim.keymap.set("i", "<Space>", space, { buffer = true })
end