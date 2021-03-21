;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here
(setq doom-theme 'gruvbox-dark-soft
      doom-font (font-spec :family "Go Mono" :size 13))

(map! :map org-mode-map
      :nv "j" #'evil-next-visual-line
      :nv "k" #'evil-previous-visual-line)

(map! :map evil-surround-mode-map
      :v "s" #'evil-surround-region)

(add-hook! 'c++-mode-hook 
  (lambda ()
    (push '(?< . ("<" . ">")) evil-surround-pairs-alist)))

(after! lispy (lispy-set-key-theme '(special c-digits)))
