vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {".factor*-rc", "factor*-rc"},
    callback = function()
        vim.bo.filetype = "factor"
    end
})

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*-docs.factor",
    callback = function()
        vim.bo.filetype = "factor.factor-docs"
    end
})