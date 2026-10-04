" Vim filetype plugin file
" Language: Factor (documentation)
" Maintainer: Tim Allen <screwtape@froup.com>
" Last Change: 2020 May 29

" Documentation lines can be any length of characters.
setlocal textwidth=0

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
      \ . (exists('b:undo_ftplugin') ? ' | ' : '') . 'setlocal textwidth<'
