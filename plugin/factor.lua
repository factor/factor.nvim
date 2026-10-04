if vim.g.loaded_factor then
    return
end
vim.g.loaded_factor = true

local function complete(...)
    return require("factor").complete_vocab_glob(...)
end

vim.api.nvim_create_user_command("FactorVocab", function(opts)
    require("factor").go_to_vocab(opts.count, opts.bang and "edit!" or "edit", opts.args)
end, {
    nargs = 1, bang = true, bar = true, count = 1,
    complete = complete, desc = "Go to Factor vocabulary",
})

vim.api.nvim_create_user_command("NewFactorVocab", function(opts)
    require("factor").make_vocab(opts.count, opts.bang and "edit!" or "edit", opts.args)
end, {
    nargs = 1, bang = true, bar = true, count = 1,
    complete = complete, desc = "Create new Factor vocabulary",
})

for name, method in pairs({
    FactorVocabImpl = "go_to_factor_vocab_impl",
    FactorVocabDocs = "go_to_factor_vocab_docs",
    FactorVocabTests = "go_to_factor_vocab_tests",
}) do
    vim.api.nvim_create_user_command(name, function()
        require("factor")[method]()
    end, { bar = true, desc = "Go to Factor vocabulary file" })
end
