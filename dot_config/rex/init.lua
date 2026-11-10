-- Rex configuration, migrated from Herdr (~/.config/herdr/config.toml)
-- and Ghostty (~/.config/ghostty/config).

-- Herdr: prefix ctrl+a. Let programs that use ctrl+a themselves still receive it.
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- Herdr: workspaces
rex.bind("ctrl+a>shift+j", "session.next")
rex.bind("ctrl+a>shift+k", "session.previous")

-- Herdr: switch_tab = "prefix+1..9"
rex.bind("ctrl+a>1", "client.tab.goto", { index = 1 })
rex.bind("ctrl+a>2", "client.tab.goto", { index = 2 })
rex.bind("ctrl+a>3", "client.tab.goto", { index = 3 })
rex.bind("ctrl+a>4", "client.tab.goto", { index = 4 })
rex.bind("ctrl+a>5", "client.tab.goto", { index = 5 })
rex.bind("ctrl+a>6", "client.tab.goto", { index = 6 })
rex.bind("ctrl+a>7", "client.tab.goto", { index = 7 })
rex.bind("ctrl+a>8", "client.tab.goto", { index = 8 })
rex.bind("ctrl+a>9", "client.tab.goto", { index = 9 })

-- Ghostty: create splits
rex.bind("shift+cmd+h", "pane.split", { direction = "left" })
rex.bind("shift+cmd+j", "pane.split", { direction = "down" })
rex.bind("shift+cmd+k", "pane.split", { direction = "up" })
rex.bind("shift+cmd+l", "pane.split", { direction = "right" })

-- Ghostty: move between splits (cmd+h is a macOS key; cmd+k keeps Rex's session picker)
rex.bind("cmd+j", "pane.focus", { direction = "down" })
rex.bind("cmd+l", "pane.focus", { direction = "right" })

-- Ghostty: misc
rex.bind("shift+cmd+e", "pane.balance")
rex.bind("shift+cmd+f", "pane.zoom")
rex.bind("shift+cmd+,", "client.config.reload")

-- Ghostty: tabs
rex.bind("shift+cmd+w", "client.tab.close")
rex.bind("shift+cmd+left", "client.tab.previous")
rex.bind("shift+cmd+right", "client.tab.next")
