-- LazyVim's keymaps load first. Put user overrides below.
-- Leader is <Space>. Press <Space> and wait to browse via which-key.

-- One-chord window navigation (vs. default <C-w>h/j/k/l two-chord).
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
