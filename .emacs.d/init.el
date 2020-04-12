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
    (evil-define-key 'visual global-map "gS" 'evil-Surround-region)))
					;
;; load custom-set-variables
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
