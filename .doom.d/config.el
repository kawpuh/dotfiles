;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here
(setq doom-theme 'doom-gruvbox
      doom-font (font-spec :family "Go Mono" :size 16))

(map! :map +write-mode-map
      :nv "j" #'evil-next-visual-line
      :nv "k" #'evil-previous-visual-line)
