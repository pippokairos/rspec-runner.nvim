## RSpec Runner

This is a simple (Neo)Vim plugin that allows you to run RSpec tests from within a Rails file.

## Installation

Use your favorite plugin manager to install this plugin. For example, with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
  {
    'pippokairos/rspec-runner.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    init = function()
      local rspec_runner = require 'rspec-runner'

      vim.keymap.set('n', '<leader>rr', function()
        rspec_runner.run_file()
      end, { desc = '[R]un [R]Spec', noremap = false, silent = false })
    end,
  },
}
```

## Usage

Call the `run_file` function from within a Rails file to run the corresponding RSpec test, assuming it exists and its path follows Rails conventions.

