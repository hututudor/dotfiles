;; melpa setup
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("stable-melpa" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
 
;; window setup
(add-hook 'window-setup-hook 'toggle-frame-maximized t)
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)

(menu-bar-mode 0) ;; hide menu
(tool-bar-mode 0) ;; hide toolbar
(scroll-bar-mode 0) ;; hide OS scrollbar
(global-display-line-numbers-mode 1) ;; show line numbers
(column-number-mode 1) ;; show columns in modeline
(blink-cursor-mode 0) ;; do not blink cursor
(delete-selection-mode 1) ;; auto delete when pasting in a selection
(electric-pair-mode 1) ;; auto-close parens and brackets
(hl-line-mode 1) ;; highlight current line

;; custom key binds
(global-unset-key "\C-z")
(global-unset-key "\C-x\C-z")

(keymap-global-set "C-x C-b" 'ibuffer)
(keymap-global-set "C-c c" 'compile)

(keymap-global-set "C-c r" 'recentf-open)

;; duplicate line
(defun tudor/duplicate-line ()
  "Duplicate current line."
  (interactive)
  (let ((column (- (point) (point-at-bol)))
        (line (let ((s (thing-at-point 'line t)))
                (if s (string-remove-suffix "\n" s) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))

(global-set-key (kbd "C-,") 'tudor/duplicate-line)

;; clean files
(setq make-backup-files nil)
(setq create-lockfiles nil)
(setq auto-save-list-file-prefix "~/.emacs.d/autosave/")
(setq auto-save-file-name-transforms `((".*" "~/.emacs.d/autosave/" t)))

;; prefer y-n instead of yes-no answers
(setopt use-short-answers t)

;; use-package setup
(require 'use-package)
(setq use-package-always-ensure t)
(use-package diminish)

;; theme and font setup
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-tokyo-night t)
  (doom-themes-org-config))

(cond
 ((eq system-type 'darwin)
  (set-frame-font "Jetbrains Mono 14" nil t))
 ((eq system-type 'gnu/linux)
  (set-frame-font "Jetbrains Mono NL 11" nil t))
 ((eq system-type 'windows-nt)
  (set-frame-font "Jetbrains Mono NL 11" nil t)))

;; setup packages
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; ivy + swiper
(use-package swiper
  :diminish
  :bind (("C-s" . swiper)))

 (use-package ivy
  :diminish
  :config
  (ivy-mode 1))

 (use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 ("C-x C-r" . counsel-recentf)))

 (use-package ivy-rich
  :init
  (ivy-rich-mode 1))

 (use-package flycheck
  :init
  (global-flycheck-mode))

 ;; QOL improvements
 (use-package move-text
  :bind (("M-n" . move-text-down)
	 ("M-p" . move-text-up)))

 (move-text-default-bindings)

 (use-package exec-path-from-shell
  :init (when (memq window-system '(mac ns x))
	  (exec-path-from-shell-initialize)))

 ;; rainbow-delimiters
 (use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

 ;; which-key
 (use-package which-key
  :diminish which-key-mode
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 1))

 ;; no-littering
 (use-package no-littering)

 ;; projectile
 (use-package projectile
  :defer t
  :diminish projectile-mode
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/projects")
    (setq projectile-project-search-path '("~/projects")))
  (setq projectile-switch-project-action #'projectile-dired))

 (use-package counsel-projectile
  :config (counsel-projectile-mode))

 ;; magit
 (use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

 ;; org mode
(use-package org)
(require 'ox-md)

 (use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

 ;; lsp + company mode
 (defun tudor/lsp-format-on-save ()
  (interactive)
  (print "hello world"))

(add-hook 'before-save-hook #'tudor/lsp-format-on-save)

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))

  (use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
	 ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

;; prog modes
(use-package typescript-mode
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))

(use-package js2-mode
  :hook (js2-mode . lsp-deferred)
  :init (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode)))

(use-package web-mode
  :hook (web-mode . lsp-deferred))

(add-hook 'c-mode-hook 'lsp-deferred)
(add-hook 'c++-mode-hook 'lsp-deferred)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("9ab9441566f7c3b059a205a7c5fad32a58422c2695815436d8cc087860b8c2e5" "296f12a58b5bc587fdf08995a84cb8cdec74b83b794fddaad012e520c411ddf1" "3325e2c49c8cc81a8cc94b0d57f1975e6562858db5de840b03338529c64f58d1" "21055a064d6d673f666baaed35a69519841134829982cbbb76960575f43424db" default))
 '(package-selected-packages
   '(ox-md flycheck doom-themes no-littering c-mode exec-path-from-shell js2-mode web-mode move-text company-box company lsp-mode org-bullets magit counsel-projectile ayu-theme typescript-mode projectile diminish counsel ivy-rich which-key rainbow-delimiters swiper ivy)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
