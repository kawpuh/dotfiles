local iron = require('iron')

iron.core.add_repl_definitions {
	python = {
		mycustom = {
			command = {"python3"}
		}
	},
	clojure = {
		lein_connect = {
			command = {"lein", "repl", ":connect"}
		}
	},
	iron.core.set_config {
		preferred = {
			python = "ipython3",
			clojure = "lein"
		}
	}
}
