import os
from urllib.request import urlopen

if os.path.exists(config.configdir / "theme.py"):
    import theme
    theme.setup(c, 'latte', True)

config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')

c.tabs.last_close = "close"
c.content.javascript.clipboard = "access"

c.url.searchengines = {
    'DEFAULT':  'https://google.com/search?hl=en&q={}',
    'yt': 'https://www.youtube.com/results?search_query={}'
}
c.url.start_pages = "https://google.com"
c.url.default_page = "https://google.com"
c.tabs.padding = {'top': 8, 'bottom': 8, 'left': 16, 'right': 16}
c.tabs.width = '7%'
c.tabs.indicator.width = 0
c.statusbar.padding = {"bottom": 4, "left": 4, "right": 4, "top": 2}
c.fonts.statusbar = "14pt monospace"
c.url.open_base_url = True

c.input.insert_mode.auto_load = True
c.window.transparent = True

c.aliases = {"q": "close",
             "qa": "quit",
             "w": "session-save",
             "wq": "quit --save",
             "wqa": "quit --save",
             "mpv": "spawn --detach mpv {url}"}

config.load_autoconfig(False)
