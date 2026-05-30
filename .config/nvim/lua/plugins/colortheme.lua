return {
  {
    "tomasiser/vim-code-dark",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("set termguicolors")
      vim.cmd("colorscheme codedark")
    end
  }
}
