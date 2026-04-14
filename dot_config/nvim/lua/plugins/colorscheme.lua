return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        mason = true,
        snacks = { enabled = true },
        treesitter = true,
        which_key = true,
        native_lsp = { enabled = true, inlay_hints = { background = true } },
        dap = true,
        dap_ui = true,
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin-mocha" },
  },
}
