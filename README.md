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
  ft = "factor",
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
  ft = "factor",
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
  
  -- Characters to escape in glob patterns
  glob_escape = vim.loop.os_uname().sysname == "Windows" and "*[]?`{$" or "*[]?`{$\\"
})
```

## Key Mappings

The plugin provides the following default key mappings:

| Key | Description |
|-----|-------------|
| `<Leader>fi` | Go to vocabulary implementation file |
| `<Leader>fd` | Go to vocabulary documentation file |
| `<Leader>ft` | Go to vocabulary tests file |
| `<Leader>fv` | Go to a vocabulary (prompts for name) |
| `<Leader>fn` | Create a new vocabulary (prompts for name) |

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
3. Additional paths configured via the `additional_vocab_roots` option

Vocabulary roots can be specified using:
- `resource:` prefix - relative to Factor installation directory
- `vocab:` prefix - search in all vocabulary roots
- Absolute paths

## Requirements

- Neovim 0.7.0 or higher
- Factor programming language (for actual code execution)

## Credits

Based on the original [factor.vim](https://github.com/factor/factor.vim) Vimscript plugin.
