;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here
;;
(setq doom-theme 'sanityinc-tomorrow-eighties
      doom-font (font-spec :family "Go Mono" :size 16))

(map! :map org-mode-map
      :nv "j" #'evil-next-visual-line
      :nv "k" #'evil-previous-visual-line)

;; (add-hook! org-mode (setq truncate-lines nil))
