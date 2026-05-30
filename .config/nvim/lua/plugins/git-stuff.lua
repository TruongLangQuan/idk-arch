return {
  {
    "tpope/vim-fugitive",
  },
  {
    "rbong/vim-flog",
    dependencies = { "tpope/vim-fugitive" },
    config = function()
      vim.keymap.set("n", "<C-g>h", ":Flog<CR>", { silent = true })
    end
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<C-S-g>", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    }
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()

      vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
      vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<CR>", {})
    end,
  },
}
