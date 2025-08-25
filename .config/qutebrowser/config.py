import os
import subprocess
from urllib.request import urlopen

config.load_autoconfig()

def get_theme_from_dconf():
    try:
        result = subprocess.run(
            ['dconf', 'read', '/org/gnome/desktop/interface/color-scheme'],
            capture_output=True,
            text=True,
            check=True
        )

        # Remove quotes and whitespace
        scheme = result.stdout.strip().strip("'\"")

        # Map dconf values to theme names
        if scheme == "prefer-dark":
            return 'dark'
        elif scheme == "prefer-light":
            return 'light'
        else:  # default or empty
            return 'light'  # default to dark theme

    except (subprocess.CalledProcessError, FileNotFoundError):
        # If dconf is not available or command fails, default to mocha
        return 'light'

if os.path.exists(config.configdir / "theme.py"):
    import theme
    if get_theme_from_dconf() == 'dark':
        theme.setup(c, 'mocha', True)
        c.colors.webpage.preferred_color_scheme = 'dark'
    else:
        theme.setup(c, 'latte', True)
        c.colors.webpage.preferred_color_scheme = 'light'

config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')
config.bind('<Ctrl-V>', 'mode-leave', mode='passthrough')
config.bind('<Ctrl-W>', 'rl-backward-kill-word', mode='command')

c.tabs.last_close = "close"
c.content.javascript.clipboard = "access"

c.url.searchengines = {
    'DEFAULT':  'https://google.com/search?hl=en&q={}',
    'yt': 'https://www.youtube.com/results?search_query={}',
    'wiki': 'https://en.wikipedia.org/w/index.php?search={}',
    'gh': 'https://www.github.com/search?q={}&type=repositories'
}
c.url.start_pages = c.url.default_page = "https://web.tabliss.io"
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
             "mpv": "spawn --detach mpv {url}",
             "dm": "set colors.webpage.darkmode.enabled"
             "dc": "download-clear"}

c.content.javascript.log_message.excludes = \
{"userscript:_qute_stylesheet": ["*Refused to apply inline style because it violates the following Content Security Policy directive: *"],
 "userscript:_qute_js": ["Uncaught TypeError: Cannot read properties of undefined (reading 'length')"]}
c.hints.chars = "asdfghjklqwertyuiopzxcvbnm"
c.hints.scatter = False

