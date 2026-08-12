return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    opts = {},
  },

  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        doc = {
          max_width = math.max(80, vim.o.columns - 6),
          max_height = 100,
        },
        convert = {
          notify = true,
          mermaid = function()
            local theme = vim.o.background == "light" and "neutral" or "dark"
            return {
              "-i", "{src}", "-o", "{file}",
              "-b", "transparent", "-t", theme,
              "-s", "4", "-w", "2000",
            }
          end,
        },
      },
    },
    keys = {
      { "<leader>mz", function() Snacks.image.hover() end, desc = "Peek diagram (hover)" },
      {
        "<leader>mZ",
        function()
          Snacks.image.doc.at_cursor(function(src)
            if not src then
              return vim.notify("No image at cursor", vim.log.levels.WARN)
            end
            local dir = vim.fn.fnamemodify(src, ":h")
            local base = vim.fn.fnamemodify(src, ":t:r")
            local theme = vim.o.background == "light" and "light" or "dark"
            local pngs = vim.fn.glob(("%s/*-%s.%s.png"):format(dir, base, theme), false, true)
            if #pngs == 0 then
              return vim.notify("No rendered PNG for " .. base, vim.log.levels.WARN)
            end
            table.sort(pngs, function(a, b) return vim.fn.getftime(a) > vim.fn.getftime(b) end)
            vim.cmd("tabnew " .. vim.fn.fnameescape(pngs[1]))
          end)
        end,
        desc = "Open diagram in new tab (scrollable)",
      },
    },
  },
}
