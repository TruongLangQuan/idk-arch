return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 17,
        open_mapping = [[<C-t>]], -- Ctrl+T to toggle terminal at the bottom
        direction = "horizontal",
        shade_terminals = true,
        start_in_insert = true,
        persist_size = true,
        close_on_exit = true,
      })

      -- Navigation inside and outside terminal window (VS Code style)
      function _G.set_terminal_keymaps()
        local opts = {buffer = 0}
        vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<A-Up>', [[<C-\><C-n><C-w>k]], opts)
        vim.keymap.set('t', '<A-Down>', [[<C-\><C-n><C-w>j]], opts)
      end

      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
      
      -- Alt+Up/Down in Normal Mode to switch windows
      vim.keymap.set('n', '<A-Up>', '<C-w>k', { silent = true })
      vim.keymap.set('n', '<A-Down>', '<C-w>j', { silent = true })
    end
  }
}
