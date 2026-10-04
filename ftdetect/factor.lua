vim.filetype.add({
    extension = { factor = "factor" },
    pattern = {
        [".*%-docs%.factor"] = "factor.factor-docs",
        ["%.factor.*%-rc"] = "factor",
        ["factor.*%-rc"] = "factor",
    },
})

-- Neovim 0.7 still defaults to Vimscript filetype detection. The Lua registry
-- is used automatically from 0.8, or with g:do_filetype_lua=1 on 0.7.
if vim.fn.has("nvim-0.8") == 0 and vim.g.do_filetype_lua ~= 1 then
    local group = vim.api.nvim_create_augroup("FactorFiletype", { clear = true })
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
        group = group,
        pattern = {"*.factor", ".factor*-rc", "factor*-rc"},
        callback = function(args)
            local ft = vim.bo[args.buf].filetype
            if ft == "" or ft == "factor" then
                vim.bo[args.buf].filetype = args.match:match("%-docs%.factor$")
                    and "factor.factor-docs" or "factor"
            end
        end,
    })
end
