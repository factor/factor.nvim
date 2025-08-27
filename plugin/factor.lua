local factor = require("factor")

vim.keymap.set("n", "<Leader>fi", factor.go_to_factor_vocab_impl, { silent = true, desc = "Go to Factor vocab implementation" })
vim.keymap.set("n", "<Leader>fd", factor.go_to_factor_vocab_docs, { silent = true, desc = "Go to Factor vocab docs" })
vim.keymap.set("n", "<Leader>ft", factor.go_to_factor_vocab_tests, { silent = true, desc = "Go to Factor vocab tests" })
vim.keymap.set("n", "<Leader>fv", ":FactorVocab ", { desc = "Go to Factor vocabulary" })
vim.keymap.set("n", "<Leader>fn", ":NewFactorVocab ", { desc = "Create new Factor vocabulary" })

vim.api.nvim_create_user_command("FactorVocab", function(opts)
    factor.go_to_vocab(opts.count > 0 and opts.count or 1, opts.bang and "edit!" or "edit", opts.args)
end, {
    nargs = 1,
    bang = true,
    range = 1,
    complete = factor.complete_vocab_glob,
    desc = "Go to Factor vocabulary"
})

vim.api.nvim_create_user_command("NewFactorVocab", function(opts)
    factor.make_vocab(opts.count > 0 and opts.count or 1, opts.bang and "edit!" or "edit", opts.args)
end, {
    nargs = 1,
    bang = true,
    range = 1,
    complete = factor.complete_vocab_glob,
    desc = "Create new Factor vocabulary"
})

vim.api.nvim_create_user_command("FactorVocabImpl", function()
    factor.go_to_factor_vocab_impl()
end, {
    bar = true,
    desc = "Go to Factor vocab implementation"
})

vim.api.nvim_create_user_command("FactorVocabDocs", function()
    factor.go_to_factor_vocab_docs()
end, {
    bar = true,
    desc = "Go to Factor vocab docs"
})

vim.api.nvim_create_user_command("FactorVocabTests", function()
    factor.go_to_factor_vocab_tests()
end, {
    bar = true,
    desc = "Go to Factor vocab tests"
})