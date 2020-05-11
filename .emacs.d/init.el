;; disable ui elements
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq inhibit-splash-screen t)

(server-start)

;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(package-initialize)
(package-refresh-contents)

;; install use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;; evil configuration
(use-package evil
  :ensure t
  :defer .1
  :init
  (setq evil-want-keybinding nil) ;; required for evil-collection
  :config
  (evil-mode)
  (evil-set-leader 'normal " ")
  (use-package evil-collection
    :after evil
    :ensure t
    :config
    (evil-collection-init))
  (use-package evil-commentary
    :ensure t
    :bind (:map evil-normal-state-map
		("gc" . evil-commentary)))
  ;; (use-package evil-goggles
  ;;   :ensure t
  ;;   :config
  ;;   (evil-goggles-use-diff-faces)
  ;;   (evil-goggles-mode))
  (use-package evil-surround
    :ensure t
    :commands
    (evil-surround-edit
     evil-Surround-edit
     evil-surround-region
     evil-Surround-region)
    :init
    (evil-define-key 'operator global-map "s" 'evil-surround-edit)
    (evil-define-key 'operator global-map "S" 'evil-Surround-edit)
    (evil-define-key 'visual global-map "S" 'evil-surround-region)
    (evil-define-key 'visual global-map "s" 'evil-surround-region)
    (evil-define-key 'visual global-map "gS" 'evil-Surround-region))

  (use-package evil-lion
    :ensure t
    :config
    (evil-lion-mode))

  ;; other evil config
  (evil-define-key 'normal global-map (kbd "<leader>fc") 
		   (lambda () (interactive) (find-file "~/.emacs.d/init.el"))))

;; treemacs
(use-package treemacs
  :after evil
  :ensure t
  :defer t
  :commands
  (treemacs)
  :init
  (evil-define-key 'normal global-map (kbd "<leader>ft") 'treemacs))

(use-package cider
  :ensure t
  :after evil
  :defer t
  :commands
  (cider-jack-in
   cider-eval-region
   cider-eval-buffer)
  :init
  (evil-define-key 'normal global-map (kbd "<leader>rr") 'cider-jack-in)
  (evil-define-key 'visual global-map (kbd " er") 'cider-eval-region))

;; load custom-set-variables
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
