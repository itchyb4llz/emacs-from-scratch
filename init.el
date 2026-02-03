;; -*- lexical-binding: t; -*-

;; STARTUP PERFORMANCE -----------------------
;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s seconds with %d garbage collections."
                     (emacs-init-time "%.2f")
                     gcs-done)))

;; NATIVE COMPILATION -----------------------
;; Silence compiler warnings as they can be pretty disruptive
(setq native-comp-async-report-warnings-errors nil)

;; PACKAGE MANAGEMENT -----------------------
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; KEEP .emacs.d CLEAN -----------------------
;; Change the user-emacs-directory to keep unwanted things out of ~/.emacs.d
(setq user-emacs-directory (expand-file-name "~/.cache/emacs/")
      url-history-file (expand-file-name "url/history" user-emacs-directory))

(setq make-backup-files nil)

(use-package no-littering
  :straight t)

;; Keep customization settings in a temporary file (thanks Ambrevar!)
(setq custom-file
      (if (boundp 'server-socket-dir)
          (expand-file-name "custom.el" server-socket-dir)
        (expand-file-name (format "emacs-custom-%s.el" (user-uid)) temporary-file-directory)))
(load custom-file t)

;; DEFAULT CODING SYSTEM -----------------------
(set-default-coding-systems 'utf-8)

;; KEYBOARD BINDINGS -----------------------
;; ESC Cancels All
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Rebind C-u
(global-set-key (kbd "C-M-u") 'universal-argument)

;; Let's Be Evil
(use-package undo-tree
  :init
  (setq undo-tree-auto-save-history nil)
  (global-undo-tree-mode 1))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-tree)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  ;; Disable arrow keys in normal and visual modes, they are bad!
  (defun jd/dont-arrow-me-bro ()
    (interactive)
    (message "Arrow keys are bad, you know?"))

  (define-key evil-normal-state-map (kbd "<left>") 'jd/dont-arrow-me-bro)
  (define-key evil-normal-state-map (kbd "<right>") 'jd/dont-arrow-me-bro)
  (define-key evil-normal-state-map (kbd "<down>") 'jd/dont-arrow-me-bro)
  (define-key evil-normal-state-map (kbd "<up>") 'jd/dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<left>") 'jd/dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<right>") 'jd/dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<down>") 'jd/dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<up>") 'jd/dont-arrow-me-bro)
  
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :straight t
  :after evil
  :init
  (evil-collection-init))

;; KEYBINDING PANEL (which-key) -----------------------
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; SIMPLIFY LEADER BINDINGS -----------------------
(use-package general
  :config
  (general-create-definer jd/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC"))

;; USER INTERFACE -----------------------
;; Thanks, but no thanks
(setq inhibit-startup-message t)

(scroll-bar-mode -1) ; Disable visible scrollbar
(tool-bar-mode -1)   ; Disable the toolbar
(tooltip-mode -1)    ; Disable tooltips
(set-fringe-mode 10) ; Give some breathing room
(menu-bar-mode -1)   ; Disable the menu bar

;; Disable wrapping
(setq-default truncate-lines t)

;; Set up the visible bell
(setq visible-bell t)

;; Highlight the current line
(global-hl-line-mode 1)

;; Improve scrolling
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time
(setq use-dialog-box nil) ;; Disable dialog boxes since they weren't working in Mac OSX

;; Set frame transparency and windows
;; (set-frame-parameter (selected-frame) 'alpha '(80 . 80))
;; (add-to-list 'default-frame-alist '(alpha . (80 . 80)))

;; NOTE: Remove the comments below to set emacs to fullscreen
;; (set-frame-parameter (selected-frame) 'fullscreen 'maximized)
;; (add-to-list 'default-frame-alist '(fullscreen . maximized))

;; NOTE: Add comment (;;) below to use the fullscreen above
(add-to-list 'default-frame-alist '(width  . 100))
(add-to-list 'default-frame-alist '(height . 56))


;; Enable line numbers and customize their format
(column-number-mode)

;; Enable line numbers for some modes
(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

;; Override some modes which derive from the above
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Don't warn for large files (shows up when launching videos)
(setq large-file-warning-threshold nil)

;; Don't warn for following symlinked files
(setq vc-follow-symlinks t)

;; Don't warn when advice is added for functions
(setq ad-redefinition-action 'accept)

(use-package doom-themes
  :straight t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t
	      doom-themes-enable-italic t)
  (load-theme 'doom-tokyo-night t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-one") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification
  (doom-themes-org-config))


;; FONT -----------------------
(defvar jd/default-font-size 110)
(set-face-attribute 'default nil :font "Agave Nerd Font" :weight 'medium :height jd/default-font-size)
(set-face-attribute 'fixed-pitch nil :font "Agave Nerd Font" :weight 'medium :height jd/default-font-size)
(set-face-attribute 'variable-pitch nil :font "Agave Nerd Font" :height jd/default-font-size)

;; Emojis in buffers
(use-package emojify
  :hook (erc-mode . emojify-mode)
  :commands emojify-mode)

;; MODE LINE -----------------------
(setq display-time-format "%l:%M %p %b %y"
      display-time-default-load-average nil)

;; Enable Mode Diminishing
(use-package diminish)

;; Doom Modeline
;; You must run (all-the-icons-install-fonts) one time after
;; installing this package!

(use-package all-the-icons)

(use-package minions
  :hook (doom-modeline-mode . minions-mode))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  ;; :hook (after-init . doom-modeline-init)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 3)
  (doom-modeline-lsp t)
  (doom-modeline-github nil)
  (doom-modeline-minor-modes t)
  (doom-modeline-persp-name nil)
  ;;(doom-modeline-buffer-file-name-style 'truncate-except-project)
  (doom-modeline-major-mode-icon nil)
  :custom-face
  (mode-line ((t (:height 0.85))))
  (mode-line-inactive ((t (:height 0.85)))))

;; AUTO-REVERTING CHANGED FILES -----------------------
;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)

;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)

;; UI TOGGLES -----------------------
(jd/leader-keys
  "."   '(find-file :which-key "find file")
  "RET" '(list-bookmarks :which-key "show bookmarks")

  "b"   '(:ignore t :which-key "buffer")
  "bb"  '(switch-to-buffer :which-key "show buffer")
  "bi"  '(ibuffer :which-key "show ibuffer")
  "bk"  '(kill-this-buffer :which-key "kill buffer")
  "bm"  '(bookmark-set :which-key "set bookmark")

  "c"   '(:ignore t :which-key "code")
  ;; "cc"  '(compile :which-key "compile code")
  "ct"  '(org-babel-tangle :which-key "write code blocks")

  "f"   '(:ignore t :which-key "file")
  "fR"  '(delete-file :which-key "delete file")

  "i"   '(:ignore t :which-key "insert")
  "ii"  '(org-id-get-create :which-key "org ID")

  "g"   '(:ignore t :which-key "magit")
  "gc"  '(magit-commit :which-key "commit")
  "gg"  '(magit :which-key "show status")
  "gp"  '(magit-pull-from-upstream :which-key "pull")
  "gP"  '(magit-push-current-to-upstream :which-key "push")
  "gi"  '(magit-init :which-key "git init")

  "oi"  '(org-toggle-inline-images :which-key "display images in org-mode")
  "ol"  '(display-line-numbers-mode :which-key "display line numbers")
  "on"  '(jd/search-org-files :which-key "show notes")
  "op"  '(org-present :which-key "org-mode presentation")
  "ot"  '(vterm :which-key "launch vterm")
  "ou"  '(org-roam-db-sync :which-key "org-roam db sync")
  "oa"  '(org-agenda :which-key "org agenda")
  
  "t" '(:ignore t :which-key "toggles")
  "tw" 'whitespace-mode
  "tt" '(counsel-load-theme :which-key "choose theme"))

;; HIGHLIGHT MATCHING BRACES -----------------------
(use-package paren
  :config
  (set-face-attribute 'show-paren-match-expression nil :background "#363e4a"))

;; EDITING CONFIGURATIONS -----------------------
;; Tab Widths
(setq-default tab-width 2)
(setq-default evil-shift-width tab-width)

;; Use spaces instead of tabs for indentation
(setq-default indent-tabs-mode nil)

;; Commenting Lines
(use-package evil-nerd-commenter
	:bind ("M-/" . evilnc-comment-or-uncomment-lines))

;; Automatically clean whitespace
(use-package ws-butler
	:hook ((text-mode . ws-butler-mode)
				 (prog-mode . ws-butler-mode)))

;; STATEFUL KEYMAPS WITH HYDRA
(use-package hydra
	:defer 1)

;; BETTER COMPLETIONS WITH IVY -----------------------
(use-package ivy
	:diminish
	:bind (("C-s" . swiper)
				 :map ivy-minibuffer-map
				 ("TAB" . ivy-alt-done)
				 ("C-f" . ivy-alt-done)
				 ("C-l" . ivy-alt-done)
				 ("C-j" . ivy-next-line)
				 ("C-k" . ivy-previous-line)
				 :map ivy-switch-buffer-map
				 ("C-k" . ivy-previous-line)
				 ("C-l" . ivy-done)
				 ("C-d" . ivy-switch-buffer-kill)
				 :map ivy-reverse-i-search-map
				 ("C-k" . ivy-previous-line)
				 ("C-d" . ivy-reverse-i-search-kill))
	:init
	(ivy-mode 1)
	:config
	(setq ivy-use-virtual-buffers t)
	(setq ivy-wrap t)
	(setq ivy-count-format "(%d/%d) ")
	(setq enable-recursive-minibuffers t)

	;; Use different regex strategies per completion command
  (push '(completion-at-point . ivy--regex-fuzzy) ivy-re-builders-alist) ;; This doesn't seem to work...
  (push '(swiper . ivy--regex-ignore-order) ivy-re-builders-alist)
  (push '(counsel-M-x . ivy--regex-ignore-order) ivy-re-builders-alist)

	(setf (alist-get 'counsel-projectile-ag ivy-height-alist) 15)
  (setf (alist-get 'counsel-projectile-rg ivy-height-alist) 15)
  (setf (alist-get 'swiper ivy-height-alist) 15)
  (setf (alist-get 'counsel-switch-buffer ivy-height-alist) 7))

(use-package ivy-hydra
	:defer t
	:after hydra)

(use-package ivy-rich
  :init
  (ivy-rich-mode 1)
  :after counsel
  :config
  (setq ivy-format-function #'ivy-format-function-line)
  (setq ivy-rich-display-transformers-list
        (plist-put ivy-rich-display-transformers-list
                   'ivy-switch-buffer
                   '(:columns
                     ((ivy-rich-candidate (:width 40))
                      (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right)); return the buffer indicators
                      (ivy-rich-switch-buffer-major-mode (:width 12 :face warning))          ; return the major mode info
                      (ivy-rich-switch-buffer-project (:width 15 :face success))             ; return project name using `projectile'
                      (ivy-rich-switch-buffer-path (:width (lambda (x) (ivy-rich-switch-buffer-shorten-path x (ivy-rich-minibuffer-width 0.3))))))  ; return file path relative to project root or `default-directory' if project is nil
                     :predicate
                     (lambda (cand)
                       (if-let ((buffer (get-buffer cand)))
                           ;; Don't mess with EXWM buffers
                           (with-current-buffer buffer
                             (not (derived-mode-p 'exwm-mode)))))))))

(use-package counsel
  :demand t
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         ;; ("C-M-j" . counsel-switch-buffer)
         ("C-M-l" . counsel-imenu)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^

(use-package flx  ;; Improves sorting for fuzzy-matched results
  :after ivy
  :defer t
  :init
  (setq ivy-flx-limit 10000))

(use-package wgrep)

(use-package ivy-posframe
  :disabled
  :custom
  (ivy-posframe-width      115)
  (ivy-posframe-min-width  115)
  (ivy-posframe-height     10)
  (ivy-posframe-min-height 10)
  :config
  (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center)))
  (setq ivy-posframe-parameters '((parent-frame . nil)
                                  (left-fringe . 8)
                                  (right-fringe . 8)))
  (ivy-posframe-mode 1))

(use-package prescient
  :after counsel
  :config
  (prescient-persist-mode 1))

(use-package ivy-prescient
  :after prescient
  :config
  (ivy-prescient-mode 1))

(jd/leader-keys
  "r"   '(ivy-resume :which-key "ivy resume")
  "f"   '(:ignore t :which-key "files")
  "ff"  '(counsel-find-file :which-key "open file")
  "C-f" 'counsel-find-file
  "fr"  '(counsel-recentf :which-key "recent files")
  "fR"  '(revert-buffer :which-key "revert file")
  "fj"  '(counsel-file-jump :which-key "jump to file"))

;; COMPLETION SYSTEM -----------------------
;; Trying this as an alternative to Ivy and Counsel

;; Preserve Minibuffer History with savehist-mode
(use-package savehist
  :config
  (setq history-length 25)
  (savehist-mode 1))

;; Completions with Vertico
(defun jd/minibuffer-backward-kill (arg)
  "When minibuffer is completing a file name delete up to parent
folder, otherwise delete a word"
  (interactive "p")
  (if minibuffer-completing-file-name
      ;; Borrowed from https://github.com/raxod502/selectrum/issues/498#issuecomment-803283608
      (if (string-match-p "/." (minibuffer-contents))
          (zap-up-to-char (- arg) ?/)
        (delete-minibuffer-contents))
    (backward-kill-word arg)))

(use-package vertico
  :straight '(vertico :host github
                      :repo "minad/vertico"
                      :branch "main")
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("C-f" . vertico-exit)
              :map minibuffer-local-map
              ("M-h" . jd/minibuffer-backward-kill))
  :custom
  (vertico-cycle t)
  :custom-face
  (vertico-current ((t (:background "#3a3f5a"))))
  :init
  (vertico-mode))

;; Completions in Regions with Corfu
(use-package corfu
  :straight '(corfu :host github
                    :repo "minad/corfu")
  :bind (:map corfu-map
              ("C-j" . corfu-next)
              ("C-k" . corfu-previous)
              ("C-f" . corfu-insert))
  :custom
  (corfu-cycle t)
  :config
  (corfu-global-mode))

;; Improved Candidate Filtering with Orderless
(use-package orderless
  :straight t
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion))))))

;; Consult Commands
(defun jd/get-project-root ()
  (when (fboundp 'projectile-project-root)
    (projectile-project-root)))

(use-package consult
  :straight t
  :demand t
  :bind (("C-s" . consult-line)
         ("C-M-l" . consult-imenu)
         ("C-M-j" . persp-switch-to-buffer*)
         :map minibuffer-local-map
         ("C-r" . consult-history))
  :custom
  (consult-project-root-function #'jd/get-project-root)
  (completion-in-region-function #'consult-completion-in-region))

;; Completion Annotations with Marginalia
(use-package marginalia
  :after vertico
  :straight t
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

;; WINDOW MANAGEMENT -----------------------
(use-package default-text-scale
  :defer 1
  :config
  (default-text-scale-mode))

;; Set Margins for Modes
(defun jd/org-mode-visual-fill ()
  (setq visual-fill-column-width 145
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :defer t
  :hook (org-mode . jd/org-mode-visual-fill))

;; FILE BROWSING -----------------------
;; Dired
(use-package all-the-icons-dired)

(use-package dired
  :straight nil
  :defer 1
  :commands (dired dired-jump)
  :config
  (setq dired-listing-switches "-agho --group-directories-first"
        dired-omit-files "^\\.[^.].*"
        dired-omit-verbose nil
        dired-hide-details-hide-symlink-targets nil
        delete-by-moving-to-trash t)

  (autoload 'dired-omit-mode "dired-x")

  (add-hook 'dired-load-hook
            (lambda ()
              (interactive)
              (dired-collapse)))

  (add-hook 'dired-mode-hook
            (lambda ()
              (interactive)
              (dired-omit-mode 1)
              (dired-hide-details-mode 1)
              (all-the-icons-dired-mode 1)
              (hl-line-mode 1)))

  (use-package dired-rainbow
    :defer 2
    :config
    (dired-rainbow-define-chmod directory "#6cb2eb" "d.*")
    (dired-rainbow-define html "#eb5286" ("css" "less" "sass" "scss" "htm" "html" "jhtm" "mht" "eml" "mustache" "xhtml"))
    (dired-rainbow-define xml "#f2d024" ("xml" "xsd" "xsl" "xslt" "wsdl" "bib" "json" "msg" "pgn" "rss" "yaml" "yml" "rdata"))
    (dired-rainbow-define document "#9561e2" ("docm" "doc" "docx" "odb" "odt" "pdb" "pdf" "ps" "rtf" "djvu" "epub" "odp" "ppt" "pptx"))
    (dired-rainbow-define markdown "#ffed4a" ("org" "etx" "info" "markdown" "md" "mkd" "nfo" "pod" "rst" "tex" "textfile" "txt"))
    (dired-rainbow-define database "#6574cd" ("xlsx" "xls" "csv" "accdb" "db" "mdb" "sqlite" "nc"))
    (dired-rainbow-define media "#de751f" ("mp3" "mp4" "mkv" "MP3" "MP4" "avi" "mpeg" "mpg" "flv" "ogg" "mov" "mid" "midi" "wav" "aiff" "flac"))
    (dired-rainbow-define image "#f66d9b" ("tiff" "tif" "cdr" "gif" "ico" "jpeg" "jpg" "png" "psd" "eps" "svg"))
    (dired-rainbow-define log "#c17d11" ("log"))
    (dired-rainbow-define shell "#f6993f" ("awk" "bash" "bat" "sed" "sh" "zsh" "vim"))
    (dired-rainbow-define interpreted "#38c172" ("py" "ipynb" "rb" "pl" "t" "msql" "mysql" "pgsql" "sql" "r" "clj" "cljs" "scala" "js"))
    (dired-rainbow-define compiled "#4dc0b5" ("asm" "cl" "lisp" "el" "c" "h" "c++" "h++" "hpp" "hxx" "m" "cc" "cs" "cp" "cpp" "go" "f" "for" "ftn" "f90" "f95" "f03" "f08" "s" "rs" "hi" "hs" "pyc" ".java"))
    (dired-rainbow-define executable "#8cc4ff" ("exe" "msi"))
    (dired-rainbow-define compressed "#51d88a" ("7z" "zip" "bz2" "tgz" "txz" "gz" "xz" "z" "Z" "jar" "war" "ear" "rar" "sar" "xpi" "apk" "xz" "tar"))
    (dired-rainbow-define packaged "#faad63" ("deb" "rpm" "apk" "jad" "jar" "cab" "pak" "pk3" "vdf" "vpk" "bsp"))
    (dired-rainbow-define encrypted "#ffed4a" ("gpg" "pgp" "asc" "bfe" "enc" "signature" "sig" "p12" "pem"))
    (dired-rainbow-define fonts "#6cb2eb" ("afm" "fon" "fnt" "pfb" "pfm" "ttf" "otf"))
    (dired-rainbow-define partition "#e3342f" ("dmg" "iso" "bin" "nrg" "qcow" "toast" "vcd" "vmdk" "bak"))
    (dired-rainbow-define vc "#0074d9" ("git" "gitignore" "gitattributes" "gitmodules"))
    (dired-rainbow-define-chmod executable-unix "#38c172" "-.*x.*"))

  (use-package dired-single
    :defer t)

  (use-package dired-ranger
    :defer t)

  (use-package dired-collapse
    :defer t)

  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "H" 'dired-omit-mode
    "l" 'dired-single-buffer
    "y" 'dired-ranger-copy
    "X" 'dired-ranger-move
    "p" 'dired-ranger-paste))

;; Opening Files Externally
(use-package openwith
  :config
  (setq openwith-associations
        (list
         (list (openwith-make-extension-regexp
                '("mpg" "mpeg" "mp3" "mp4"
                  "avi" "wmv" "wav" "mov" "flv"
                  "ogm" "ogg" "mkv"))
               "mpv"
               '(file))
         (list (openwith-make-extension-regexp
                '("xbm" "pbm" "pgm" "ppm" "pnm"
                  "png" "gif" "bmp" "tif" "jpeg" "jpg"))
               "sxiv"
               '(file))
         (list (openwith-make-extension-regexp
                '("pdf"))
               "zathura"
               '(file)))))

;; ORG MODE -----------------------
;; Org Configuration

;; TODO: Mode this to another section
(setq-default fill-column 125)

;; Turn on indentation and auto-fill mode for Org files
(defun jd/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (setq evil-auto-indent nil)
  (diminish org-indent-mode))

;; (global-set-key (kbd "C-c o") (lambda () (interactive) (find-file "~/org/tasks/agenda.org")))
(global-set-key (kbd "C-c t") (lambda () (interactive) (find-file "~/org/tasks.org")))

(use-package org
  :defer t
  :hook (org-mode . jd/org-mode-setup)
  :config
  (setq org-ellipsis "..."
        ;; org-ellipsis " ▾"
        org-hide-emphasis-markers t
        org-src-fontify-natively t
        org-fontify-quote-and-verse-blocks t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 2
        org-hide-block-startup nil
        org-src-preserve-indentation nil
        org-startup-folded 'overview
        org-cycle-separator-lines 2)
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-agenda-start-on-weekday 0)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "START(s)" "NEXT(n)" "|" "DONE(d!)")
          (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(r)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (defun jd/org-agenda-format-project (txt)
    "Append the PROJECT property of the task to the agenda item."
    (let ((proj (org-entry-get (get-text-property 0 'org-hd-marker txt) "PROJECT")))
      (if proj
          (concat txt " (" proj ")")
        txt)))


  (setq org-agenda-files '("~/org/tasks.org"
                           "~/org/inbox.org"
                           "~/org/projects.org"))

  (setq org-agenda-prefix-format
        '((todo . "  %?-12t %s")    ;; leave default formatting
          (agenda . " %?-12t %s")))

  ;; Use `org-agenda-finalize-hook` to post-process the agenda and append PROJECT
  (add-hook 'org-agenda-finalize-hook
            (lambda ()
              (save-excursion
                (goto-char (point-min))
                (while (not (eobp))
                  (let ((txt (thing-at-point 'line t)))
                    (when (string-match-p "TODO" txt)
                      (let ((proj (get-text-property (point) 'org-hd-marker)))
                        (when proj
                          (let ((p (org-entry-get proj "PROJECT")))
                            (when p
                              (beginning-of-line)
                              (end-of-line)
                              (insert " (" p ")")))))))
                  (forward-line 1)))))

  (setq org-agenda-custom-commands
        '(("d" "Daily Agenda + Tasks with Project"
           ((agenda ""
                    ((org-agenda-span 1)
                     (org-agenda-overriding-header "Today's Schedule")))
            (alltodo ""
                     ((org-agenda-overriding-header "Tasks")
                      (org-agenda-files '("~/org/tasks.org"))))))))


(setq org-modules
      '(org-crypt
        org-habit
        org-bookmark))

(setq org-refile-targets '((nil :maxlevel . 1)
                           (org-agenda-files :maxlevel . 1)))

(setq org-outline-path-complete-in-steps nil)
(setq org-refile-use-outline-path t)

(evil-define-key '(normal insert visual) org-mode-map (kbd "C-j") 'org-next-visible-heading)
(evil-define-key '(normal insert visual) org-mode-map (kbd "C-k") 'org-previous-visible-heading)

(evil-define-key '(normal insert visual) org-mode-map (kbd "M-j") 'org-metadown)
(evil-define-key '(normal insert visual) org-mode-map (kbd "M-k") 'org-metaup)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)))

(push '("conf-unix" . conf-unix) org-src-lang-modes)

;; Fonts and Bullets
;; (use-package org-superstar
;;   :after org
;;   :hook (org-mode . org-superstar-mode)
;;   :custom
;;   (org-superstar-remove-leading-stars t)
;;   (org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●")))

;; Increase the size of various headings
(set-face-attribute 'org-document-title nil :font "Agave Nerd Font" :weight 'bold :height 1.0)
(dolist (face '((org-level-1 . 1.0)
                (org-level-2 . 1.0)
                (org-level-3 . 1.0)
                (org-level-4 . 1.0)
                (org-level-5 . 1.0)
                (org-level-6 . 1.0)
                (org-level-7 . 1.0)
                (org-level-8 . 1.0)))
  (set-face-attribute (car face) nil :font "Agave Nerd Font" :weight 'medium :height (cdr face)))

;; Make sure org-indent face is available
(require 'org-indent)

;; Ensure that anything that should be fixed-pitch in Org files appears that way
(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-table nil  :inherit 'fixed-pitch)
(set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

;; Get rid of the background on column views
(set-face-attribute 'org-column nil :background nil)
(set-face-attribute 'org-column-title nil :background nil)

;; Block Templates
;; This is needed as of Org 9.2
(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("src" . "src"))
(add-to-list 'org-structure-template-alist '("sh" . "src sh"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("ts" . "src typescript"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))
(add-to-list 'org-structure-template-alist '("json" . "src json"))

;; Searching
(defun jd/search-org-files ()
  (interactive)
  (counsel-rg "" "~/org" nil "Search: "))

;; Bindings
(use-package evil-org
  :after org
  :hook ((org-mode . evil-org-mode)
         (org-agenda-mode . evil-org-mode)
         (evil-org-mode . (lambda () (evil-org-set-key-theme '(navigation todo insert textobjects additional)))))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)))

;; PRESENTATIONS -----------------------

;; org-present
(defun jd/org-present-prepare-slide ()
  (org-overview)
  (org-show-entry)
  (org-show-children))

(defun jd/org-present-hook ()
  (setq-local face-remapping-alist '((default (:height 1.5) variable-pitch)
                                     (header-line (:height 4.5) variable-pitch)
                                     (org-code (:height 1.5) org-code)
                                     (org-verbatim (:height 1.5) org-verbatim)
                                     (org-block (:height 1.5) org-block)
                                     (org-block-begin-line (:height 0.7) org-block)))
  (setq header-line-format " ")
  (org-display-inline-images)
  (jd/org-present-prepare-slide))

(defun jd/org-present-quit-hook ()
  (setq-local face-remapping-alist '((default variable-pitch default)))
  (setq header-line-format nil)
  (org-present-small)
  (org-remove-inline-images))

(defun jd/org-present-prev ()
  (interactive)
  (org-present-prev)
  (jd/org-present-prepare-slide))

(defun jd/org-present-next ()
  (interactive)
  (org-present-next)
  (jd/org-present-prepare-slide))

(use-package org-present
  :bind (:map org-present-mode-keymap
              ("C-c C-j" . jd/org-present-next)
              ("C-c C-k" . jd/org-present-prev))
  :hook ((org-present-mode . jd/org-present-hook)
         (org-present-mode-quit . jd/org-present-quit-hook)))

;; ORG ROAM -----------------------
(use-package org-roam
  :straight t
  :custom
  (org-roam-directory "~/org/notes/")
  (org-roam-completion-everywhere t)
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :if-new (file+head "${slug}.org" "#+title: ${title}\n#+author: Jaj Dollesin\n#+date: %U\n\n")
      :unnarrowed t)))
  (org-roam-dailies-directory "~/org/journal/")
  (org-roam-dailies-capture-templates
   '(("d" "default" entry "* %<%I:%M %p>: %?"
      :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n\n"))))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         :map org-mode-map
         ("C-M-i" . completion-at-point)
         :map org-roam-dailies-map
         ("Y" . org-roam-dailies-capture-yesterday)
         ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies)
  (org-roam-db-autosync-enable))

;; LSP
(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

(use-package lsp-ui :commands lsp-ui-mode)

;; Deft
(use-package deft
  :commands (deft)
  :config (setq deft-directory "~/org"
                deft-recursive t
                deft-extensions '("md" "org")))

(use-package org-appear
  :hook (org-mode . org-appear-mode))

;; Git
;; Magit
(use-package magit
  :bind ("C-M-;" . magit-status)
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Flycheck
(use-package flycheck
  :defer t
  :hook (lsp-mode . flycheck-mode))

;; Snippets
(use-package yasnippet
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

;; Smart Parens
(use-package smartparens
  :hook (prog-mode . smartparens-mode))

;; Rainbow Delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Rainbow Mode
(use-package rainbow-mode
  :defer t
  :hook (org-mode
         emacs-lisp-mode
         web-mode
         typescript-mode
         js2-mode))

;; TERMINAL -----------------------
;; vterm
(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

;;; init.el ends here
