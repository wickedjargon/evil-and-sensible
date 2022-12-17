;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; starting our engines...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(package-initialize)

(unless (assoc-default "melpa" package-archives)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

(setq package-list '(use-package markdown-mode gcmh))

(unless (assoc-default "melpa" package-archives)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

(setq package-list '(use-package gcmh))

(unless package-archive-contents
  (package-refresh-contents))
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(gcmh-mode 1) ;; reduce garbage collection interference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; general config:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tool-bar-mode -1)                                      ;; no tool bar
(scroll-bar-mode -1)                                    ;; no scroll bar
(setq inhibit-startup-message t)                        ;; no splash screen
(setq use-short-answers t)                              ;; just type `y`, not `yes`
(setq mode-require-final-newline nil)                   ;; don't add a newline at the bottom of the file
(menu-bar-mode -1)                                      ;; no menu bar
(setq auto-save-file-name-transforms                    ;;  (save auto save data
      '((".*" "~/.config/emacs/auto-save-list/" t)))    ;;  in a separate directory)
(setq backup-directory-alist                            ;; (save backup files
      '(("." . "~/.config/emacs/backups")))             ;; in a separate directory)
(blink-cursor-mode -1)                                  ;; don't blink my cursor
(global-auto-revert-mode +1)                            ;; auto revert files and buffers
(add-hook 'dired-mode-hook #'auto-revert-mode)          ;; revert dired buffers, but not buffer list buffers
(delete-selection-mode +1)                              ;; delete selction when hitting backspace on region
(set-default 'truncate-lines t)                         ;; don't wrap my text
(add-hook 'prog-mode-hook #'hs-minor-mode)              ;; let me toggle shrink and expand code blocks 
(setq custom-file (locate-user-emacs-file "custom.el")) ;; separate custom.el file
(when (file-exists-p custom-file) (load custom-file))   ;; when it exists, load it
(setq initial-scratch-message "")                       ;; no message on scratch buffer
(setq auth-source-save-behavior nil)                    ;; don't prompt to save auth info in home dir
(setq-default indent-tabs-mode nil)                     ;; I prefer spaces instead of tabs
(setq-default tab-width 4)                              ;; I prefer a tab length of 4, not 8
(setq dired-listing-switches                            ;; I prefer to have dired
      "-aBhl  --group-directories-first")               ;; group my directories
(setq disabled-command-function nil)                    ;; enable all disabled commands

;; don't show `active processes exist` warning:
(defadvice save-buffers-kill-emacs (around no-query-kill-emacs activate)
  (cl-letf (((symbol-function #'process-list) (lambda ())))
    ad-do-it))

;; prevent active process when closing a shell like vterm or eshell:
(setq kill-buffer-query-functions (delq 'process-kill-buffer-query-function kill-buffer-query-functions))

;; I prefer a full screen new buffer, not a split screen:
(setq display-buffer-base-action '((display-buffer-reuse-window display-buffer-same-window)))

;; show startup time on launch
(defun display-startup-echo-area-message ()
  (message "(emacs-init-time) -> %s" (emacs-init-time)))

;; open .pl files in prolog-mode
(autoload 'prolog-mode "prolog" "" t)
(add-to-list 'auto-mode-alist '("\\.pl\\'" . prolog-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; use-package setup:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'use-package)

(use-package doom-modeline
  :ensure t
  :custom ((doom-modeline-height 16))
  :init (doom-modeline-mode 1))

(use-package yasnippet
  :ensure t)

(use-package yasnippet-snippets 
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'yas-minor-mode)
  )

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init)
  )

(setq evil-undo-system 'undo-fu)
(setq evil-want-integration t)
(setq evil-want-keybinding nil)

(use-package evil
  :defer t
  :ensure t
  :init
  (setq evil-undo-system 'undo-fu)
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-fine-undo t)
  (setq evil-search-wrap nil)
  (setq evil-kill-on-visual-paste nil)
  ;; hitting C-n and C-p doesn't work for the company-mode pop-up
  ;; after using C-h. The code below resolves this issue
  (with-eval-after-load 'evil
    (with-eval-after-load 'company
      (define-key evil-insert-state-map (kbd "C-n") nil)
      (define-key evil-insert-state-map (kbd "C-p") nil)
      (evil-define-key nil company-active-map (kbd "C-n") #'company-select-next)
      (evil-define-key nil company-active-map (kbd "C-p") #'company-select-previous)))
  :config
  (evil-mode 1)
  )

(use-package undo-fu
  :defer t
  :ensure t)

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode +1))

(use-package expand-region
  :defer t
  :ensure t
  )

(use-package vterm
  :defer t
  :ensure t)

(use-package terminal-here
  :defer t
  :ensure t
  :init
  (setq terminal-here-linux-terminal-command 'st)
  )

(use-package so-long
  :defer t
  :ensure t
  :init
  (global-so-long-mode +1))

(use-package company
  :defer t
  :ensure t
  :init
  (global-company-mode)
  )

(use-package restart-emacs
  :defer t
  :ensure t
  )

(use-package windsize
  :defer t
  :ensure t
  )

(use-package crux
  :defer t
  :ensure t
  )

(use-package emmet-mode
  :defer t
  :ensure t
  :init (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'html-mode-hook (lambda () (emmet-mode 1)))
  )

(use-package markdown-mode
  :ensure t
  :defer t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

(use-package mw-thesaurus
  :ensure t
  :defer t
  )

(use-package gh-md
  :ensure t
  :defer t
  )

(use-package go-mode
  :ensure t
  :defer t
  )

(use-package ivy
  :defer t
  :ensure t
  :config
  (setq ivy-initial-inputs-alist nil)
  (setq ivy-on-del-error-function #'ignore)
  :init
  (ivy-mode)
  )

(use-package counsel
  :defer t
  :ensure t
  :init
  (setq ivy-initial-inputs-alist nil)
  )

(use-package projectile
  :ensure t
  :init
  (setq projectile-project-root-files '("manage.py" ".git/"))
  (setq projectile-ignored-projects '("~/"))
  (projectile-mode +1)
  )

(use-package marginalia
  :defer t
  :ensure t
  :init
  (marginalia-mode))

(use-package emojify
  :defer t
  :ensure t
  :init
  (setq emojify-display-style 'unicode)
  (setq emojify-emoji-styles '(unicode))
  )

(use-package dired
  :ensure nil
  :config
  (add-hook 'dired-mode-hook
            (lambda ()
              (dired-hide-details-mode)))
  )

(use-package switch-window
  :ensure t
  :defer t
  )

(use-package rainbow-mode
  :ensure t
  :defer t
  )

(use-package modus-themes
  :ensure t
  :init
  (modus-themes-load-themes)
  :config
  (modus-themes-load-vivendi)
  )

(use-package ivy-prescient
  :ensure t
  :defer t
  :config
  (ivy-prescient-mode))

(use-package magit
  :ensure t
  :defer t
  )

(use-package auto-package-update
  :ensure t
  :config
  (setq auto-package-update-delete-old-versions t
        auto-package-update-interval 30)
  (auto-package-update-maybe))

(use-package smex
  :ensure t
  )

(use-package diff-hl
  :ensure t
  :init
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  :config
  (global-diff-hl-mode)
  )