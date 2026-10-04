return function(root, equal)
    local factor = require("factor")
    local install = root .. "/factor install"
    local work = install .. "/work"
    local other = root .. "/other"
    vim.fn.mkdir(work .. "/foo/bar", "p")
    vim.fn.mkdir(other .. "/foo/bar", "p")
    vim.fn.writefile({"IN: foo.bar"}, work .. "/foo/bar/bar.factor")
    vim.fn.writefile({"IN: foo.bar"}, other .. "/foo/bar/bar.factor")

    factor.setup({resource_path = install, default_vocab_roots = {"resource:work"},
        additional_vocab_roots = {}})
    equal({work}, factor.expand_vocab_roots(factor.get_vocab_roots()), "join resource paths")
    equal({work .. "/foo/bar/bar.factor"}, factor.glob_factor("vocab:foo/bar/bar.factor", false, 2, 1))
    equal({"foo.bar"}, factor.complete_vocab_glob("foo.b"), "vocabulary completion")
    factor.go_to_vocab(1, "edit", "foo.bar")
    equal(work .. "/foo/bar/bar.factor", vim.fn.expand("%:p"), "navigate to vocabulary")
    factor.make_vocab(1, "edit", "new.child")
    equal(work .. "/new/child/child.factor", vim.fn.expand("%:p"), "create vocabulary")
    equal(1, vim.fn.isdirectory(work .. "/new/child"))

    factor.setup({default_vocab_roots = {other}})
    equal({other}, factor.get_vocab_roots(), "invalidate root cache")
    factor.setup({additional_vocab_roots = {work}})
    equal({other, work}, factor.get_vocab_roots(), "update additional roots")
    local matches = factor.glob_factor("vocab:foo/bar/bar.factor", false, 2, 1)
    vim.cmd("2FactorVocab foo.bar | let g:factor_command_bar = 1")
    equal(matches[2], vim.fn.expand("%:p"), "command count")
    equal(1, vim.g.factor_command_bar, "command separator")
    vim.cmd("NewFactorVocab new.command")
    equal(work .. "/new/command/command.factor", vim.fn.expand("%:p"), "new vocabulary command")
    factor.setup({vocab_roots = {work}})
    equal({work}, factor.get_vocab_roots(), "explicit roots")
    factor.setup({default_vocab_roots = {"/"}, additional_vocab_roots = {}})
    equal({"/"}, factor.get_vocab_roots(), "preserve filesystem root")
    factor.setup({default_vocab_roots = {work}, additional_vocab_roots = {}})

    local directory = root .. "/my-docs-project-tests"
    vim.fn.mkdir(directory, "p")
    for _, suffix in ipairs({"", "-docs", "-tests"}) do
        vim.cmd("edit " .. vim.fn.fnameescape(directory .. "/foo" .. suffix .. ".factor"))
        equal(directory .. "/foo", factor.get_factor_file_base(), "strip filename suffix only")
    end
    vim.cmd("edit " .. vim.fn.fnameescape(directory .. "/foo-docstring.factor"))
    equal(directory .. "/foo-docstring", factor.get_factor_file_base())
    factor.go_to_factor_vocab_docs()
    equal(directory .. "/foo-docstring-docs.factor", vim.fn.expand("%:p"))
    factor.go_to_factor_vocab_tests()
    equal(directory .. "/foo-docstring-tests.factor", vim.fn.expand("%:p"))
    factor.go_to_factor_vocab_impl()
    equal(directory .. "/foo-docstring.factor", vim.fn.expand("%:p"))

    equal({"resource:"}, factor.complete_glob("r"), "resource prefix")
    equal({"vocab:"}, factor.complete_glob("v"), "vocab prefix")
    equal({"resource:", "vocab:"}, factor.complete_glob(""), "empty prefix")
    equal({}, factor.complete_glob("unrelated"))
end
