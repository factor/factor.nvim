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

vim.b.undo_ftplugin = "setlocal expandtab< tabstop< shiftwidth< softtabstop<"
    .. " textwidth< colorcolumn< comments< commentstring< iskeyword<"
    .. " | unlet! b:match_words"
    .. [[ | execute "lua require('factor.ftplugin').undo()"]]

require("factor.ftplugin").attach()
