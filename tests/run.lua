local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")

local function equal(expected, actual, message)
    assert(vim.deep_equal(expected, actual), (message or "values differ")
        .. "\nexpected: " .. vim.inspect(expected) .. "\nactual: " .. vim.inspect(actual))
end

local ok, err = xpcall(function()
    equal(nil, package.loaded.factor, "defer loading Lua module")
    vim.cmd("runtime plugin/factor.lua")
    equal(nil, package.loaded.factor, "idempotent command registration")
    dofile("tests/navigation.lua")(root, equal)
    dofile("tests/filetype.lua")(root, equal)
end, debug.traceback)

vim.fn.delete(root, "rf")
if not ok then
    vim.api.nvim_err_writeln(err)
    vim.cmd("cquit 1")
else
    print("Factor tests passed")
    vim.cmd("qa!")
end
