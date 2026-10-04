# Neovim support for Factor

A Neovim plugin for the [Factor programming
language](https://factorcode.org/), providing vocabulary navigation, syntax
highlighting, and auto-pairing support.

## Features

- **Vocabulary Navigation**: Quickly navigate between Factor vocabularies and their related files (implementation, docs, tests)
- **Syntax Highlighting**: Full syntax highlighting for Factor code
- **Auto-pairing**: Smart bracket, quote, and parenthesis pairing (optional)
- **File Type Detection**: Automatic detection of Factor files and proper filetype setting
- **Vocabulary Roots**: Support for multiple vocabulary roots including custom paths

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "factor/factor.nvim",
  ft = { "factor", "factor.factor-docs" },
  config = function()
    require("factor").setup({
      -- Configuration options (see below)
    })
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "factor/factor.nvim",
  ft = { "factor", "factor.factor-docs" },
  config = function()
    require("factor").setup({
      -- Configuration options (see below)
    })
  end
}
```

## Configuration

The plugin can be configured by calling the setup function:

```lua
require("factor").setup({
  -- Path to your Factor installation (default: ~/factor/)
  resource_path = vim.fn.expand("~/factor/"),
  
  -- Default vocabulary roots
  default_vocab_roots = {
    "resource:core",
    "resource:basis", 
    "resource:extra",
    "resource:work"
  },
  
  -- Additional vocabulary roots (can also be set in ~/.factor-roots)
  additional_vocab_roots = nil,
  
  -- Function to determine the root for new vocabularies
  new_vocab_root = function()
    return "resource:work"
  end,
  
  -- Enable smart auto-pairing of brackets, quotes, etc.
  enable_autopairs = false,

  -- Install buffer-local navigation mappings in Factor buffers
  default_mappings = true,
  
  -- Characters to escape in glob patterns
  glob_escape = vim.loop.os_uname().sysname == "Windows" and "*[]?`{$" or "*[]?`{$\\"
})
```

## Key Mappings

The plugin provides the following buffer-local mappings in Factor files.
Existing mappings take precedence. Set `default_mappings = false` to disable
these defaults and use commands or your own mappings.

| Key | Description |
|-----|-------------|
| `<Leader>fi` | Go to vocabulary implementation file |
| `<Leader>fd` | Go to vocabulary documentation file |
| `<Leader>ft` | Go to vocabulary tests file |
| `<Leader>fv` | Start `:FactorVocab` on the command line |
| `<Leader>fn` | Start `:NewFactorVocab` on the command line |

## Commands

| Command | Description |
|---------|-------------|
| `:FactorVocab <name>` | Navigate to a vocabulary by name |
| `:NewFactorVocab <name>` | Create a new vocabulary |
| `:FactorVocabImpl` | Go to the implementation file of the current vocabulary |
| `:FactorVocabDocs` | Go to the documentation file of the current vocabulary |
| `:FactorVocabTests` | Go to the tests file of the current vocabulary |

## Auto-pairing

When `enable_autopairs` is set to `true`, the plugin provides intelligent auto-pairing:

- `[` → `[]` with cursor in between
- `(` → `()` with cursor in between
- `{` → `{}` with cursor in between
- `"` → `""` with cursor in between
- `[` + `=` → `[=|=]` for literal arrays
- `(` + `Space` → `( -- )` for stack effects
- Pressing `Space` inside brackets adds padding: `[]` → `[ | ]`
- Pressing `Enter` inside brackets creates a multi-line block
- `Backspace` intelligently removes paired characters

Existing insert mappings take precedence. Auto-pairing also removes trailing
spaces before saving Factor buffers. Mappings and options are cleaned up when
a buffer changes filetype.

## File Structure

The plugin recognizes the following Factor file conventions:

- `*.factor` - Factor source files
- `*-docs.factor` - Documentation files
- `*-tests.factor` - Test files
- `.factor-rc`, `factor-rc` - Factor RC files
- `~/.factor-roots` - File containing additional vocabulary roots

## Vocabulary Roots

The plugin searches for vocabularies in the following locations:

1. Standard Factor directories (`core`, `basis`, `extra`, `work`) under your Factor installation
2. Custom paths defined in `~/.factor-roots` (one path per line)
3. An explicit `additional_vocab_roots` list overrides `~/.factor-roots`

Vocabulary roots can be specified using:
- `resource:` prefix - relative to Factor installation directory
- `vocab:` prefix - search in all vocabulary roots
- Absolute paths

`resource_path` accepts paths with or without a trailing separator. Calling
`setup()` invalidates cached vocabulary roots. Configure mapping and pairing
options before opening Factor files; reload a buffer's filetype to apply those
options to an existing buffer.

See `:help factor.txt` for commands, counts, and configuration details.

## Regenerating syntax definitions

From this directory, run the Factor language executable:

```sh
factor syntax/factor/generated.factor > syntax/factor/generated.vim
```

Use its full path if your system also has the Unix `factor` utility.

## Development

Run the headless regression tests with Neovim:

```sh
sh tests/run.sh
# Or select a particular executable:
NVIM=/path/to/nvim sh tests/run.sh
```

CI runs the suite on Neovim 0.7.0 and 0.12.5.

## Requirements

- Neovim 0.7.0 or higher
- Factor programming language (only for regenerating syntax definitions)

## Credits

Based on the original [factor.vim](https://github.com/factor/factor.vim) Vimscript plugin.
