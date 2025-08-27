local M = {}

local path_sep = vim.loop.os_uname().sysname == "Windows" and "\\" or "/"
local path_sep_pattern = vim.loop.os_uname().sysname == "Windows" and "[\\\\]+" or "/+"

M.config = {
    resource_path = vim.fn.expand("~/factor/"),
    default_vocab_roots = {
        "resource:core",
        "resource:basis",
        "resource:extra",
        "resource:work"
    },
    additional_vocab_roots = nil,
    vocab_roots = nil,
    glob_escape = vim.loop.os_uname().sysname == "Windows" and "*[]?`{$" or "*[]?`{$\\",
    new_vocab_root = function()
        return "resource:work"
    end,
    enable_autopairs = false
}

local function remove_last_path_sep(path)
    return path:gsub(path_sep_pattern .. "$", "")
end

local function ensure_last_path_sep(path)
    if path:match(path_sep_pattern .. "$") then
        return path
    else
        return path .. path_sep
    end
end

local function glob(pattern, nosuf, alllinks)
    nosuf = nosuf or false
    alllinks = alllinks or false
    local results = vim.fn.glob(pattern, nosuf, true, alllinks)
    return type(results) == "table" and results or {results}
end

function M.get_vocab_roots()
    if M.config.vocab_roots then
        return M.config.vocab_roots
    end
    
    if not M.config.additional_vocab_roots then
        local factor_roots_file = vim.fn.expand("~/.factor-roots")
        local ok, lines = pcall(vim.fn.readfile, factor_roots_file)
        if ok then
            M.config.additional_vocab_roots = vim.tbl_map(remove_last_path_sep, 
                vim.tbl_filter(function(v) return v ~= "" end, lines))
        else
            M.config.additional_vocab_roots = {}
        end
    end
    
    local all_roots = vim.list_extend(
        vim.deepcopy(M.config.default_vocab_roots),
        M.config.additional_vocab_roots
    )
    M.config.vocab_roots = vim.tbl_map(remove_last_path_sep, all_roots)
    return M.config.vocab_roots
end

function M.expand_vocab_roots(vocab_roots)
    local expanded_vocab_roots = {}
    
    for _, vocab_root in ipairs(vocab_roots) do
        if vocab_root:match("^vocab:") then
            local expanded_vocab_roots_len = #expanded_vocab_roots
            for i = 1, expanded_vocab_roots_len do
                table.insert(expanded_vocab_roots,
                    ensure_last_path_sep(expanded_vocab_roots[i]) .. vocab_root:sub(7))
            end
        else
            if vocab_root:match("^resource:") then
                table.insert(expanded_vocab_roots,
                    M.config.resource_path .. vocab_root:sub(10))
            else
                table.insert(expanded_vocab_roots, vocab_root)
            end
        end
    end
    
    return expanded_vocab_roots
end

function M.detect_parent_vocab_roots(vocab_roots, fname, expr, nosuf, alllinks)
    local parent_vocab_roots = {}
    local expanded_vocab_roots = {}
    
    for _, expanded_vocab_root in ipairs(M.expand_vocab_roots(vocab_roots)) do
        expanded_vocab_roots[vim.fn.fnamemodify(expanded_vocab_root, ":p")] = true
    end
    
    local current_path = vim.fn.fnamemodify(fname, ":p")
    while current_path ~= "" do
        local current_path_glob = ensure_last_path_sep(vim.fn.escape(current_path, M.config.glob_escape))
        local paths = glob(current_path_glob .. expr, nosuf, alllinks)
        
        for _, path in ipairs(paths) do
            path = vim.fn.fnamemodify(path, ":p")
            if expanded_vocab_roots[path] then
                table.insert(parent_vocab_roots, path)
            end
        end
        
        current_path = current_path == "/" and "" or vim.fn.fnamemodify(current_path, ":h")
    end
    
    return parent_vocab_roots
end

function M.glob_factor(expr, vocab, trailing_dir_sep, output, nosuf, alllinks)
    vocab = vocab or false
    trailing_dir_sep = trailing_dir_sep or 0
    output = output or 0
    nosuf = nosuf or false
    alllinks = alllinks or false
    
    local expr_str = vocab and ("vocab:" .. expr:gsub("%.", path_sep)) or expr
    local found = {}
    
    if expr_str:match("^resource:") then
        for _, path_root in ipairs(glob(vim.fn.escape(M.config.resource_path, M.config.glob_escape), true, true)) do
            path_root = vim.fn.fnamemodify(path_root, ":p")
            for _, path in ipairs(glob(vim.fn.escape(path_root, M.config.glob_escape) .. expr_str:sub(10), nosuf, alllinks)) do
                if trailing_dir_sep == 1 then
                    path = vim.fn.fnamemodify(path, ":p")
                elseif trailing_dir_sep == 2 then
                    path = remove_last_path_sep(vim.fn.fnamemodify(path, ":p"))
                end
                
                if output == 0 then
                    path = "resource:" .. path:sub(#path_root + 1)
                end
                found[path] = true
            end
        end
    elseif expr_str:match("^vocab:") then
        local expanded_vocab_roots = M.expand_vocab_roots(M.get_vocab_roots())
        for _, vocab_root in ipairs(expanded_vocab_roots) do
            for _, path_root in ipairs(glob(vim.fn.escape(vocab_root, M.config.glob_escape), true, true)) do
                path_root = vim.fn.fnamemodify(path_root, ":p")
                for _, path in ipairs(glob(vim.fn.escape(path_root, M.config.glob_escape) .. expr_str:sub(7), nosuf, alllinks)) do
                    if trailing_dir_sep == 1 then
                        path = vim.fn.fnamemodify(path, ":p")
                    elseif trailing_dir_sep == 2 then
                        path = remove_last_path_sep(vim.fn.fnamemodify(path, ":p"))
                    end
                    
                    if output == 0 then
                        path = "vocab:" .. path:sub(#path_root + 1)
                    elseif output == 1 then
                        -- keep path as is
                    else
                        path = path:sub(#path_root + 1):gsub(path_sep_pattern, ".")
                    end
                    found[path] = true
                end
            end
        end
    else
        if expr_str:match("^%%[resource]%*") then found["resource:"] = true end
        if expr_str:match("^%%[vocab]%*") then found["vocab:"] = true end
        
        for _, expr_path in ipairs(glob(expr_str, true, true)) do
            expr_path = vim.fn.fnamemodify(expr_path, ":p")
            for _, vocab_root in ipairs(M.get_vocab_roots()) do
                if vocab_root:match("^resource:") or vocab_root:match("^vocab:") then
                    goto continue
                end
                
                for _, path_root in ipairs(glob(vim.fn.escape(vocab_root, M.config.glob_escape), true, true)) do
                    path_root = vim.fn.fnamemodify(path_root, ":p")
                    if expr_path:sub(1, #path_root) ~= path_root then
                        break
                    end
                    
                    for _, path in ipairs(glob(vim.fn.escape(path_root, M.config.glob_escape) .. expr_str:sub(#path_root + 1), nosuf, alllinks)) do
                        if trailing_dir_sep == 1 then
                            path = vim.fn.fnamemodify(path, ":p")
                        elseif trailing_dir_sep == 2 then
                            path = remove_last_path_sep(vim.fn.fnamemodify(path, ":p"))
                        end
                        
                        if output == 0 then
                            path = path:sub(#path_root + 1)
                        elseif output == 1 then
                            -- keep path as is
                        else
                            path = path:sub(#path_root + 1):gsub(path_sep_pattern, ".")
                        end
                        found[path] = true
                    end
                end
                
                ::continue::
            end
        end
    end
    
    local result = vim.tbl_keys(found)
    table.sort(result)
    return result
end

function M.complete_glob(arg_lead, cmd_line, cursor_pos)
    return M.glob_factor(arg_lead .. "*", false, 1)
end

function M.complete_vocab_glob(arg_lead, cmd_line, cursor_pos)
    return M.glob_factor(arg_lead .. "*.", true, 2, 2)
end

function M.go_to_vocab(count, cmd, vocab)
    local vocab_glob = "vocab:" .. vocab:gsub("%.", path_sep) .. path_sep .. vocab:match("[^.]*$") .. ".factor"
    local vocab_files = M.glob_factor(vocab_glob, false, 2, 1)
    local vocab_file = vocab_files[count] or nil
    
    if not vocab_file then
        vim.api.nvim_err_writeln("Factor: Can't find vocabulary " .. vocab .. " in vocabulary roots")
        return
    end
    
    vim.cmd(cmd .. " " .. vim.fn.fnameescape(vocab_file))
end

function M.make_vocab(count, cmd, vocab)
    local new_vocab_root = M.config.new_vocab_root()
    local vocab_dirs = M.glob_factor(new_vocab_root, false, 1, 1)
    local vocab_dir = vocab_dirs[count] or nil
    
    if not vocab_dir then
        vim.api.nvim_err_writeln("Factor: Can't find new vocabulary root " .. vim.inspect(new_vocab_root) .. " in vocabulary roots")
        return
    end
    
    vocab_dir = vim.fn.fnamemodify(vocab_dir .. vocab:gsub("%.", path_sep), ":~")
    local vocab_file = vocab_dir .. path_sep .. vim.fn.fnamemodify(vocab_dir, ":t") .. ".factor"
    
    vim.fn.mkdir(vocab_dir, "p")
    vim.cmd(cmd .. " " .. vim.fn.fnameescape(vocab_file))
end

function M.get_factor_file_base()
    local filename = vim.fn.expand("%:r")
    filename = filename:gsub("%-docs", "")
    filename = filename:gsub("%-tests", "")
    return filename
end

function M.go_to_factor_vocab_impl()
    vim.cmd("edit " .. vim.fn.fnameescape(M.get_factor_file_base() .. ".factor"))
end

function M.go_to_factor_vocab_docs()
    vim.cmd("edit " .. vim.fn.fnameescape(M.get_factor_file_base() .. "-docs.factor"))
end

function M.go_to_factor_vocab_tests()
    vim.cmd("edit " .. vim.fn.fnameescape(M.get_factor_file_base() .. "-tests.factor"))
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M