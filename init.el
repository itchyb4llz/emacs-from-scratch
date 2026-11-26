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
(setq package-enable-at-startup nil)
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

;; SMALL QUALITY-OF-LIFE DEFAULTS -----------------------
(setq use-short-answers t)          ; y/n instead of yes/no everywhere
(save-place-mode 1)                 ; reopen files where you left off
(use-package recentf                ; needed by `consult-recent-file' (SPC f r)
  :straight nil
  :config
  (setq recentf-max-saved-items 300)
  (recentf-mode 1))

;; KEYBOARD BINDINGS -----------------------
;; ESC Cancels All
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Rebind C-u
(global-set-key (kbd "C-M-u") 'universal-argument)

;; Let's Be Evil
;; Undo: Emacs' built-in `undo-redo' replaces undo-tree (slow on big buffers,
;; known to corrupt history). vundo gives the same visual tree on demand.
(use-package vundo
  :straight t
  :commands vundo
  :custom
  (vundo-glyph-alist vundo-unicode-symbols))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
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

  (evil-set-initial-state 'messages-buffer-mode 'normal))

(use-package evil-collection
  :straight t
  :after evil
  :init
  (evil-collection-init))

;; KEYBINDING PANEL (which-key) -----------------------
;; Built into Emacs since 30 -- no need to download it.
(use-package which-key
  :straight nil
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
(pixel-scroll-precision-mode 1) ;; smooth touchpad/mouse scrolling (and over inline images)

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
(setq display-line-numbers-type 'relative)

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

;; OMARCHY THEME SYNC -----------------------
;; Maps the active omarchy theme (~/.local/state/omarchy/current/theme.name) to
;; the closest doom-themes theme, and watches for omarchy theme switches to
;; reload live.
(require 'filenotify)

(defvar jd/omarchy-current-dir (expand-file-name "~/.local/state/omarchy/current"))
(defvar jd/omarchy-theme-name-file (expand-file-name "theme.name" jd/omarchy-current-dir))

(defvar jd/omarchy-doom-theme-alist
  '(("catppuccin" . (catppuccin . mocha))
    ("catppuccin-latte" . (catppuccin . latte))
    ("ethereal" . doom-moonlight)
    ("everforest" . doom-pine)
    ("flexoki-light" . doom-flatwhite)
    ("gruvbox" . doom-gruvbox)
    ("hackerman" . doom-1337)
    ("kanagawa" . doom-old-hope)
    ("last-horizon" . doom-miramare)
    ("lumon" . doom-ir-black)
    ("lupine" . doom-bluloco-light)
    ("matte-black" . doom-plain-dark)
    ("miasma" . doom-badger)
    ("nord" . doom-nord)
    ("osaka-jade" . doom-city-lights)
    ("retro-82" . doom-outrun-electric)
    ("ristretto" . doom-monokai-ristretto)
    ("rose-pine" . doom-fairy-floss)
    ("solitude" . doom-plain-dark)
    ("tokyo-night" . doom-tokyo-night)
    ("vantablack" . doom-homage-black)
    ("white" . doom-homage-white))
  "Best-effort mapping from omarchy theme names to Emacs themes.
Each value is either a theme symbol, or (THEME . FLAVOR) for themes like
catppuccin that ship several variants under one theme name. doom-themes has
no exact match for every omarchy theme, so entries pick the closest
palette/mood rather than requiring a literal name match.")

(defvar jd/omarchy-loaded-theme nil
  "Theme spec last loaded via omarchy sync, to skip redundant reloads.")

(defvar jd/omarchy-theme-watch-timer nil)

(defun jd/omarchy-theme-name ()
  "Return the active omarchy theme name, or nil if unreadable."
  (when (file-readable-p jd/omarchy-theme-name-file)
    (with-temp-buffer
      (insert-file-contents jd/omarchy-theme-name-file)
      (string-trim (buffer-string)))))

(defun jd/omarchy-load-theme ()
  "Load the theme mapped from the current omarchy theme, if changed."
  (let* ((spec (or (cdr (assoc (jd/omarchy-theme-name) jd/omarchy-doom-theme-alist))
                   'doom-one))
         (theme (if (consp spec) (car spec) spec)))
    (unless (equal spec jd/omarchy-loaded-theme)
      ;; catppuccin reads `catppuccin-flavor' when its theme file is loaded.
      (when (and (consp spec) (eq theme 'catppuccin))
        (setq catppuccin-flavor (cdr spec)))
      (mapc #'disable-theme custom-enabled-themes)
      (load-theme theme t)
      (setq jd/omarchy-loaded-theme spec))))

(defun jd/omarchy-theme-watch-callback (_event)
  "Debounce omarchy `current' dir events, then reload the mapped theme.
`omarchy theme set' swaps a symlink and rewrites theme.name in quick
succession, firing several fs-notify events per switch."
  (when jd/omarchy-theme-watch-timer
    (cancel-timer jd/omarchy-theme-watch-timer))
  (setq jd/omarchy-theme-watch-timer
        (run-at-time 0.1 nil #'jd/omarchy-load-theme)))

;; ORG BLOCK STYLING -----------------------
;; Code blocks are "cards": a tinted background with invisible padding (a
;; :box in the block's own color, so code never sits flush against the edge),
;; a quiet header line showing the language, and no visible #+end_ line.
;; Quote/verse blocks read as prose instead of code: no slab, normal text
;; color, italic, framed only by org-modern-indent's left bracket.
;; Every color is theme-dependent, so this re-runs after each theme load
;; (manual or omarchy-synced).
(defface jd/org-src-lang '((t :weight bold))
  "Face for the language name on a #+begin_src line.")

(defface jd/org-quote-mark '((t :height 1.6))
  "Face for the opening quote mark shown on #+begin_quote lines.")

(defface jd/org-quote-delimiter '((t))
  "Face for #+begin_quote/#+end_quote lines: clears the block background.")

(defun jd/org-blocks-style-refresh (&rest _)
  "Restyle org code and quote block faces for the current theme."
  (when (facep 'org-block)
    (let* ((bg (face-background 'default nil t))
           (block-bg (or (face-background 'org-block nil t) bg))
           (muted (or (face-foreground 'font-lock-comment-face nil t)
                      (face-foreground 'shadow nil t)))
           (accent (or (face-foreground 'font-lock-keyword-face nil t)
                       (face-foreground 'default nil t))))
      ;; Code cards
      (dolist (face '(org-block org-block-begin-line org-block-end-line))
        (set-face-attribute face nil
                            :background block-bg :extend t
                            :box (list :line-width '(8 . 2) :color block-bg)))
      (dolist (face '(org-block-begin-line org-block-end-line))
        (set-face-attribute face nil :foreground muted :slant 'normal
                            :underline nil :overline nil
                            :inherit 'fixed-pitch :height 0.85))
      (set-face-attribute 'jd/org-src-lang nil :foreground accent)
      (set-face-attribute 'jd/org-quote-mark nil :foreground accent)
      ;; Quotes: prose, not code
      (set-face-attribute 'jd/org-quote-delimiter nil
                          :background bg :box nil :extend t)
      (dolist (face '(org-quote org-verse))
        (when (facep face)
          (set-face-attribute face nil
                              :inherit 'variable-pitch :background 'unspecified
                              :foreground 'unspecified :box nil :extend nil
                              :slant 'italic))))))
(advice-add 'load-theme :after #'jd/org-blocks-style-refresh)

;; CHECKED CHECKBOX FADE -----------------------
;; Text of a checked [X] item is drawn at reduced "opacity". Emacs has no real
;; text alpha, so the foreground is blended toward the background instead --
;; recomputed after every theme load so it stays correct with omarchy sync.
(defvar jd/org-checkbox-done-opacity 0.4
  "How visible checked checkbox text is: 1.0 = normal, 0.0 = invisible.")

(defface jd/org-checkbox-done-text '((t :inherit shadow))
  "Face for the text of checked org checkbox items.")

(defun jd/org-checkbox-fade-refresh (&rest _)
  "Blend checked-item text toward the background by `jd/org-checkbox-done-opacity'."
  (require 'color)
  (let ((fg (jd/color-rgb (face-foreground 'default nil t)))
        (bg (jd/color-rgb (face-background 'default nil t))))
    (when (and fg bg)
      (set-face-attribute 'jd/org-checkbox-done-text nil
                          :inherit 'unspecified
                          :foreground (apply #'color-rgb-to-hex
                                             (append (color-blend fg bg jd/org-checkbox-done-opacity)
                                                     '(2)))))))

(defun jd/color-rgb (color)
  "COLOR as a list of 0.0-1.0 floats, or nil. Parses #hex exactly (the
display-based `color-name-to-rgb' snaps to a palette on terminals/daemons)."
  (when (stringp color)
    (if-let* ((vals (color-values-from-color-spec color)))
        (mapcar (lambda (v) (/ v 65535.0)) vals)
      (color-name-to-rgb color))))
(advice-add 'load-theme :after #'jd/org-checkbox-fade-refresh)

;; Official catppuccin theme (https://github.com/catppuccin/emacs). Installed
;; before doom-themes so it's on `custom-theme-load-path' when the omarchy
;; sync below loads it. Flavors: mocha, macchiato, frappe, latte -- switch
;; manually with (setq catppuccin-flavor 'frappe) (catppuccin-reload).
(use-package catppuccin-theme
  :straight t
  :defer t)

(use-package doom-themes
  :straight t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t
	      doom-themes-enable-italic t)
  (jd/omarchy-load-theme)
  (when (file-directory-p jd/omarchy-current-dir)
    (file-notify-add-watch jd/omarchy-current-dir '(change)
                            #'jd/omarchy-theme-watch-callback))

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification
  (doom-themes-org-config))


;; FONT -----------------------
(defvar jd/default-font-size 90)
(set-face-attribute 'default nil :font "JetBrains Mono Nerd Font" :weight 'medium :height jd/default-font-size)
(set-face-attribute 'fixed-pitch nil :font "JetBrains Mono Nerd Font" :weight 'medium :height jd/default-font-size)
(set-face-attribute 'variable-pitch nil :font "JetBrains Mono Nerd Font" :height jd/default-font-size)

;; ICONS -----------------------
;; nerd-icons replaces all-the-icons: it draws from the Nerd Font you already
;; use (no separate icon-font install step), and doom-modeline already uses it.
(use-package nerd-icons
  :straight t
  :custom
  (nerd-icons-font-family "JetBrains Mono Nerd Font"))

;; MODE LINE -----------------------
(setq display-time-format "%l:%M %p %b %y"
      display-time-default-load-average nil)

;; Enable Mode Diminishing
(use-package diminish)

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

;; LEADER KEY MAP -----------------------
;; Mnemonic: b=buffer c=code f=file g=git h=help n=NOTES o=org/agenda
;; p=project t=toggle x=capture. Press SPC and wait -- which-key lists all.
(jd/leader-keys
  "."   '(find-file :which-key "find file")
  ","   '(consult-buffer :which-key "switch buffer")
  "/"   '(consult-ripgrep :which-key "search (project)")
  "RET" '(consult-bookmark :which-key "bookmarks")
  "u"   '(vundo :which-key "undo tree")
  "x"   '(org-capture :which-key "capture")

  "b"   '(:ignore t :which-key "buffer")
  "bb"  '(consult-buffer :which-key "switch buffer")
  "bd"  '(kill-current-buffer :which-key "kill buffer")
  "bi"  '(ibuffer :which-key "ibuffer")
  "bm"  '(bookmark-set :which-key "set bookmark")

  "c"   '(:ignore t :which-key "code")
  "ct"  '(org-babel-tangle :which-key "tangle code blocks")

  "f"   '(:ignore t :which-key "file")
  "ff"  '(find-file :which-key "open file")
  "fr"  '(consult-recent-file :which-key "recent files")
  "fj"  '(consult-fd :which-key "jump to file (fd)")
  "fR"  '(revert-buffer :which-key "revert file")
  "fD"  '(delete-file :which-key "delete file")
  "fp"  '(jd/open-config :which-key "open emacs config")

  "g"   '(:ignore t :which-key "magit")
  "gc"  '(magit-commit :which-key "commit")
  "gg"  '(magit :which-key "show status")
  "gp"  '(magit-pull-from-upstream :which-key "pull")
  "gP"  '(magit-push-current-to-upstream :which-key "push")
  "gi"  '(magit-init :which-key "git init")

  "h"   '(:ignore t :which-key "help")
  "hf"  '(helpful-callable :which-key "describe function")
  "hv"  '(helpful-variable :which-key "describe variable")
  "hk"  '(helpful-key :which-key "describe key")
  "hp"  '(helpful-at-point :which-key "describe thing at point")
  "hi"  '(consult-info :which-key "search manuals")

  "i"   '(:ignore t :which-key "insert")
  "ii"  '(org-id-get-create :which-key "org ID")

  ;; NOTES -- your second brain (org-roam).
  "n"   '(:ignore t :which-key "notes")
  "nf"  '(org-roam-node-find :which-key "find / create note")
  "ni"  '(org-roam-node-insert :which-key "link to note")
  "nn"  '(org-roam-capture :which-key "new note (templates)")
  "nl"  '(org-roam-buffer-toggle :which-key "backlinks panel")
  "nb"  '(consult-org-roam-backlinks :which-key "jump to backlink")
  "ns"  '(consult-org-roam-search :which-key "full-text search notes")
  "nq"  '(jd/org-ql-search-all :which-key "query notes & tasks")
  "nr"  '(org-roam-refile :which-key "move heading into a note")
  "nt"  '(org-roam-tag-add :which-key "add tag")
  "na"  '(org-roam-alias-add :which-key "add alias")
  "nu"  '(org-roam-db-sync :which-key "re-index notes")
  "nd"  '(:ignore t :which-key "daily journal")
  "ndt" '(org-roam-dailies-goto-today :which-key "today")
  "ndc" '(org-roam-dailies-capture-today :which-key "write in today")
  "ndy" '(org-roam-dailies-goto-yesterday :which-key "yesterday")
  "ndd" '(org-roam-dailies-goto-date :which-key "pick a date")
  "ndp" '(org-roam-dailies-goto-previous-note :which-key "previous day")
  "ndn" '(org-roam-dailies-goto-next-note :which-key "next day")

  "o"   '(:ignore t :which-key "org")
  "oa"  '(org-agenda :which-key "agenda menu")
  "oo"  '(jd/org-dashboard :which-key "dashboard (today)")
  "or"  '(org-refile :which-key "refile heading")
  "oA"  '(org-archive-subtree :which-key "archive heading")
  "oi"  '(org-toggle-inline-images :which-key "display images in org-mode")
  "ol"  '(display-line-numbers-mode :which-key "display line numbers")
  "on"  '(jd/search-org-files :which-key "grep all of ~/org")
  "op"  '(org-present :which-key "org-mode presentation")
  "ot"  '(jd/vterm-toggle :which-key "toggle vterm (bottom)")
  "od"  '(org-download-clipboard :which-key "paste image from clipboard")
  "oT"  '(org-transclusion-mode :which-key "toggle transclusion")
  "of"  '(:ignore t :which-key "open file")
  "ofi" '(jd/org-open-inbox :which-key "inbox.org")
  "oft" '(jd/org-open-tasks :which-key "tasks.org")
  "ofs" '(jd/org-open-start-here :which-key "start-here.org (guide)")

  "oc"  '(:ignore t :which-key "clock")
  "oci" '(org-clock-in :which-key "clock in")
  "oco" '(org-clock-out :which-key "clock out")
  "ocg" '(org-clock-goto :which-key "clock goto")
  "ocr" '(org-clock-report :which-key "clock report")

  "t"   '(:ignore t :which-key "toggles")
  "tw"  'whitespace-mode
  "ts"  '(jinx-mode :which-key "spell check")
  "tt"  '(consult-theme :which-key "choose theme"))

(defun jd/open-config ()
  "Open this init.el."
  (interactive)
  (find-file user-init-file))

;; HIGHLIGHT MATCHING BRACES -----------------------
(use-package paren
  :straight nil
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

;; Better *Help* buffers: source code, references and examples inline.
(use-package helpful
  :straight t
  :commands (helpful-callable helpful-variable helpful-key helpful-at-point)
  :bind (([remap describe-function] . helpful-callable)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-key]      . helpful-key)
         ([remap describe-command]  . helpful-command)))

;; Spell checking that is fast enough to leave on while you write. Needs a
;; dictionary: `sudo pacman -S hunspell-en_us' -- activates once one exists.
(use-package jinx
  :straight t
  :if (or (file-directory-p "/usr/share/hunspell")
          (file-directory-p "/usr/share/myspell/dicts"))
  :hook (org-mode . jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))

;; COMPLETION SYSTEM -----------------------
;; One stack, all by the same family of small packages that build on Emacs'
;; own completion API: vertico (UI) + orderless (matching) + marginalia
;; (annotations) + consult (commands) + embark (actions) + corfu/cape
;; (in-buffer popups). The old ivy/counsel stack is gone -- both were loaded
;; at the same time before and fought over the minibuffer.

;; Preserve Minibuffer History with savehist-mode
(use-package savehist
  :straight nil
  :config
  (setq history-length 100)
  (savehist-mode 1))

(use-package wgrep)   ; edit ripgrep results in place (embark-export, then C-c C-p)

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
  (setq enable-recursive-minibuffers t)
  (vertico-mode))

;; Completions in Regions with Corfu
(use-package corfu
  :straight '(corfu :host github
                    :repo "minad/corfu")
  :demand t
  :bind (:map corfu-map
              ("C-j" . corfu-next)
              ("C-k" . corfu-previous)
              ("C-f" . corfu-insert))
  :custom
  (corfu-cycle t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  :config
  (global-corfu-mode)
  (corfu-history-mode 1)            ; most-used candidates float to the top
  (corfu-popupinfo-mode 1)          ; docs popup next to the candidate
  (add-to-list 'savehist-additional-variables 'corfu-history)
  ;; Pop up automatically while coding, but NOT while writing prose in org --
  ;; there you trigger it yourself with C-M-i (or type [[ for note links).
  (add-hook 'prog-mode-hook (lambda () (setq-local corfu-auto t))))

;; Extra completion sources for corfu: file paths and words from open buffers.
(use-package cape
  :straight t
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90))

(use-package nerd-icons-corfu
  :straight t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Improved Candidate Filtering with Orderless
(use-package orderless
  :straight t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion))))))

(use-package consult
  :straight t
  :demand t
  :bind (("C-s" . consult-line)
         ("C-M-l" . consult-imenu)
         ("C-M-j" . consult-buffer)
         ("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)
         :map minibuffer-local-map
         ("C-r" . consult-history))
  :custom
  (completion-in-region-function #'consult-completion-in-region)
  :config
  ;; Preview themes/files/buffers only when asked (M-.), not on every keystroke
  (consult-customize
   consult-theme :preview-key '(:debounce 0.4 any)
   consult-ripgrep consult-recent-file consult-bookmark consult-buffer
   :preview-key "M-."))

;; Completion Annotations with Marginalia
(use-package marginalia
  :after vertico
  :straight t
  :init
  (marginalia-mode))

(use-package nerd-icons-completion
  :straight t
  :after marginalia
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config
  (nerd-icons-completion-mode))

;; Embark: "right-click" for anything in the minibuffer or under point.
;; C-. on a candidate/link/file/heading shows every action you can take on it.
;; In a search (SPC /, SPC n s) press C-. then E to export results into a
;; buffer you can edit with wgrep.
(use-package embark
  :straight t
  :commands (embark-act embark-dwim embark-prefix-help-command)
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  (general-define-key :states '(normal insert visual emacs motion)
                      "C-." #'embark-act
                      "C-;" #'embark-dwim)
  (general-define-key :keymaps 'minibuffer-local-map
                      "C-." #'embark-act
                      "C-;" #'embark-dwim))

(use-package embark-consult
  :straight t
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

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
(use-package nerd-icons-dired
  :straight t
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package dired
  :straight nil
  :defer 1
  :commands (dired dired-jump)
  :config
  (setq dired-listing-switches "-agho --group-directories-first"
        dired-omit-files "^\\.[^.].*"
        dired-omit-verbose nil
        dired-hide-details-hide-symlink-targets nil
        dired-dwim-target t
        delete-by-moving-to-trash t)

  (autoload 'dired-omit-mode "dired-x")

  (add-hook 'dired-mode-hook
            (lambda ()
              (interactive)
              (dired-omit-mode 1)
              (dired-hide-details-mode 1)
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
    :hook (dired-mode . dired-collapse-mode))

  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "H" 'dired-omit-mode
    "l" 'dired-single-buffer
    "y" 'dired-ranger-copy
    "X" 'dired-ranger-move
    "p" 'dired-ranger-paste))

;; Opening Files Externally
;; Images now open inside Emacs (it renders them natively, and that's where
;; your notes are). Video goes to mpv, PDFs to your desktop's default viewer.
(use-package openwith
  :config
  (setq openwith-associations
        (list
         (list (openwith-make-extension-regexp
                '("mpg" "mpeg" "mp3" "mp4"
                  "avi" "wmv" "wav" "mov" "flv"
                  "ogm" "ogg" "mkv" "webm"))
               "mpv"
               '(file))
         (list (openwith-make-extension-regexp
                '("pdf"))
               "xdg-open"
               '(file))))
  (openwith-mode 1))

;; ORG MODE -----------------------
;; Directory layout (created fresh in ~/org):
;;
;;   ~/org/start-here.org   the guide to this whole workflow -- read it first
;;   ~/org/inbox.org        everything lands here first (SPC x i)
;;   ~/org/tasks.org        Projects / Tasks / Calendar / Habits
;;   ~/org/notes/           permanent notes, one file per idea (org-roam)
;;   ~/org/journal/         one file per day (org-roam dailies)
;;   ~/org/archive/         finished work, moved out of the way (SPC o A)
;;
;; Only inbox.org and tasks.org feed the agenda; notes and journal are your
;; knowledge base and are reached through org-roam (SPC n ...).
(setq org-directory (expand-file-name "~/org/"))
(defvar jd/org-inbox-file (expand-file-name "inbox.org" org-directory))
(defvar jd/org-tasks-file (expand-file-name "tasks.org" org-directory))
(defvar jd/org-start-file (expand-file-name "start-here.org" org-directory))

(defun jd/org-open-inbox () (interactive) (find-file jd/org-inbox-file))
(defun jd/org-open-tasks () (interactive) (find-file jd/org-tasks-file))
(defun jd/org-open-start-here () (interactive) (find-file jd/org-start-file))

(defun jd/org-dashboard ()
  "Open the daily dashboard agenda directly."
  (interactive)
  (org-agenda nil "d"))

(defun jd/search-org-files ()
  "Ripgrep through every file in `org-directory'."
  (interactive)
  (consult-ripgrep org-directory))

;; TODO: Mode this to another section
(setq-default fill-column 125)

;; Turn on indentation and auto-fill mode for Org files
(defun jd/org-hl-line-range ()
  "Current-line range for `hl-line-mode' that skips the TODO keyword.
Emacs overlays always override a text-property face for the same
attribute, so without this, `global-hl-line-mode's overlay would blot
out the solid backgrounds set in `org-todo-keyword-faces' whenever
point is on that headline."
  (let ((eol (line-end-position))
        (kw-end (and (let ((case-fold-search nil))
                       (save-excursion
                         (goto-char (line-beginning-position))
                         (looking-at org-todo-line-regexp)))
                     (match-end 2))))
    (cons (or kw-end (line-beginning-position)) eol)))

(defun jd/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (setq evil-auto-indent nil)
  (setq-local hl-line-range-function #'jd/org-hl-line-range)
  (diminish org-indent-mode))

;; KEEP NOTES INDENTED UNDER THEIR HEADINGS -----------------------
;; org-roam sometimes opens a note in the background with org-mode's hooks
;; suppressed; visiting it later reuses that buffer, so org-indent never
;; turns on and body text and blocks sit at the far left (and wrapping,
;; org-modern etc. are missing too). When such a buffer is shown, run the
;; hooks org-roam held back, so it ends up exactly like a normally opened
;; note. Buffers that were set up normally always have org-indent on, so
;; they are never touched.
(defun jd/org-ensure-indent (&optional frame)
  "Finish setting up shown org buffers that skipped their mode hooks."
  (dolist (win (window-list frame 'no-mini))
    (with-current-buffer (window-buffer win)
      (when (and buffer-file-name
                 (derived-mode-p 'org-mode)
                 (not (bound-and-true-p org-indent-mode)))
        (if delayed-mode-hooks
            (run-mode-hooks)          ; point and folding stay as they are
          (org-indent-mode 1)
          (when (fboundp 'org-modern-indent-mode)
            (org-modern-indent-mode 1)))))))
(add-hook 'window-buffer-change-functions #'jd/org-ensure-indent)

;; AUTOSAVE NOTES -----------------------
;; Org buffers save themselves after 5 idle seconds, so you never lose a
;; thought. Limited to org files on purpose: code buffers still save only when
;; you say so (saving code triggers the prettier formatter).
(setq auto-save-visited-interval 5
      auto-save-visited-predicate (lambda () (derived-mode-p 'org-mode)))
(auto-save-visited-mode 1)

;; JOURNAL PROMPTS -----------------------
;; Morning questions — one per ISO day-of-week
(defvar my/stoic-morning-questions
  '((1 . "What today lies within my power, and what must I simply accept?")
    (2 . "Which virtue — courage, justice, temperance, wisdom — needs my attention today?")
    (3 . "What difficulty do I expect today, and how can I turn it to my advantage?")
    (4 . "If I imagine my life ending tonight, how would that change how I show up today?")
    (5 . "What would it look like to welcome whatever happens today, rather than resist it?")
    (6 . "What burden — grudge, regret, expectation — can I set down before the day begins?")
    (7 . "What pattern from this past week do I want to interrupt or reinforce going forward?")))

;; Evening questions — one per ISO day-of-week
(defvar my/stoic-evening-questions
  '((1 . "Where did I act from judgment today, and where did I simply react?")
    (2 . "Did I live out the virtue I chose this morning? What tested it?")
    (3 . "Looking back, did the obstacle I faced turn out smaller or larger than I feared?")
    (4 . "If today had been my last, would I be at peace with how I spent it?")
    (5 . "Was there a moment today I fought against something I couldn't change?")
    (6 . "What did I release today that I'm better off without?")
    (7 . "What is the one lesson from this week I don't want to have to learn again?")))

(defun my/stoic-question (list)
  "Return today's question from LIST based on ISO day-of-week."
  (let ((day (string-to-number (format-time-string "%u"))))
    (cdr (assoc day list))))

(defun my/stoic-morning-question ()
  (my/stoic-question my/stoic-morning-questions))

(defun my/stoic-evening-question ()
  (my/stoic-question my/stoic-evening-questions))

;; Declarative keyword syntax for org-capture-templates -- loaded before org
;; itself since org's :config below builds org-capture-templates with it.
(use-package doct
  :demand t)

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
        org-startup-folded 'show3levels
        org-cycle-separator-lines 2
        org-startup-with-inline-images t
        org-image-actual-width '(600))
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-agenda-start-on-weekday 0)

  ;; CLOCKING -- see where your time actually goes. Persist across restarts,
  ;; and auto-flip a clocked-in task to IN-PROGRESS.
  (setq org-clock-persist t)
  (setq org-clock-in-switch-to-state "IN-PROGRESS")
  (setq org-clock-out-remove-zero-time-clocks t)
  (org-clock-persistence-insinuate)

  ;; Tasks use the first sequence. Projects (level-2 headings under
  ;; "* Projects" in tasks.org, tagged :project:) use the second.
  (setq org-todo-keywords
        '((sequence
           "TODO(t)"
           "NEXT(n)"
           "IN-PROGRESS(i)"
           "WAIT(w@/!)"
           "REVIEW(v)"
           "|"
           "DONE(d!)"
           "CANCELLED(c@)")

          (sequence
           "BACKLOG(b)"
           "PLANNED(p)"
           "READY(r)"
           "ACTIVE(a)"
           "HOLD(h@)"
           "|"
           "COMPLETED(m!)")))

  ;; Colors for the TODO keywords above (Tokyo Night palette)
  ;; Solid background + dark text so org-modern's keyword "badge" is filled in,
  ;; not just an empty box outline. :distant-foreground kicks in when an
  ;; overlay (global-hl-line-mode, region, etc.) covers the badge with its own
  ;; background -- set to the theme's normal foreground so a hovered/current
  ;; line just reads as plain text instead of a distracting colored badge.
  (setq org-todo-keyword-faces
        '(("TODO"        . (:background "#f7768e" :foreground "#1a1b26" :distant-foreground "#c0caf5" :weight bold))
          ("NEXT"        . (:background "#7aa2f7" :foreground "#1a1b26" :distant-foreground "#c0caf5" :weight bold))
          ("IN-PROGRESS" . (:background "#e0af68" :foreground "#1a1b26" :distant-foreground "#c0caf5" :weight bold))
          ("WAIT"        . (:background "#bb9af7" :foreground "#1a1b26" :distant-foreground "#c0caf5" :weight bold))
          ("REVIEW"      . (:background "#2ac3de" :foreground "#1a1b26" :distant-foreground "#c0caf5" :weight bold))
          ("DONE"        . (:background "#9ece6a" :foreground "#1a1b26" :distant-foreground "#c0caf5" :weight bold))
          ("CANCELLED"   . (:background "#414868" :foreground "#565f89" :distant-foreground "#c0caf5" :weight bold :strike-through t))
          ("BACKLOG"     . (:background "#414868" :foreground "#c0caf5" :distant-foreground "#c0caf5" :weight bold))
          ("PLANNED"     . (:background "#7dcfff" :foreground "#1a1b26" :distant-foreground "#c0caf5" :weight bold))
          ("READY"       . (:background "#e0af68" :foreground "#1a1b26" :distant-foreground "#c0caf5" :weight bold))
          ("ACTIVE"      . (:background "#7aa2f7" :foreground "#1a1b26" :distant-foreground "#c0caf5" :weight bold))
          ("HOLD"        . (:background "#bb9af7" :foreground "#1a1b26" :distant-foreground "#c0caf5" :weight bold))
          ("COMPLETED"   . (:background "#9ece6a" :foreground "#1a1b26" :distant-foreground "#c0caf5" :weight bold))))

  (setq org-agenda-files (list jd/org-inbox-file jd/org-tasks-file))

  (setq org-agenda-prefix-format
        '((todo . "  %?-12t %s")    ;; leave default formatting
          (agenda . " %?-12t %s")))

  ;; A project is "stuck" when it has no NEXT/IN-PROGRESS action under it.
  (setq org-stuck-projects
        '("+project+LEVEL=2-TODO=\"COMPLETED\"-TODO=\"HOLD\"" ("NEXT" "IN-PROGRESS") nil ""))
  (setq org-tags-exclude-from-inheritance '("project" "crypt"))

  (setq org-agenda-custom-commands
        `(("d" "Dashboard"
           ((agenda ""
                    ((org-agenda-span 1)
                     (org-agenda-start-on-weekday nil)
                     (org-agenda-sorting-strategy
                      '(time-up deadline-up priority-down))
                     (org-deadline-warning-days 3)
                     (org-agenda-overriding-header
                      "TODAY\n")))
            (tags "LEVEL=1"
                  ((org-agenda-files (list ,jd/org-inbox-file))
                   (org-agenda-overriding-header
                    "\nINBOX — process me (SPC o r to refile)\n")))
            (todo "NEXT|IN-PROGRESS"
                  ((org-agenda-overriding-header
                    "\nIN FLIGHT — Next & In Progress\n")
                   (org-agenda-sorting-strategy '(priority-down deadline-up))))
            (todo "TODO"
                  ((org-agenda-files (list ,jd/org-tasks-file))
                   (org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'scheduled 'deadline))
                   (org-agenda-sorting-strategy '(priority-down effort-up))
                   (org-agenda-max-entries 8)
                   (org-agenda-overriding-header
                    "\nUNSCHEDULED — Priority Pool (top 8)\n")))
            (todo "WAIT"
                  ((org-agenda-overriding-header
                    "\nWAITING ON SOMEONE\n")))))

          ("w" "Week Ahead"
           ((agenda ""
                    ((org-agenda-span 7)
                     (org-agenda-start-on-weekday nil)
                     (org-agenda-sorting-strategy '(deadline-up priority-down))
                     (org-agenda-overriding-header
                      "NEXT 7 DAYS\n")))
            (todo "NEXT"
                  ((org-agenda-overriding-header
                    "\nNEXT Actions across all projects\n")))))

          ("o" "Overdue & At Risk"
           ((agenda ""
                    ((org-agenda-span 1)
                     (org-agenda-use-time-grid nil)
                     (org-agenda-entry-types '(:deadline :scheduled))
                     (org-deadline-warning-days 3)
                     (org-agenda-sorting-strategy '(deadline-up priority-down))
                     (org-agenda-overriding-header
                      "OVERDUE + DUE IN 3 DAYS\n")))))

          ("p" "By Project"
           ((alltodo ""
                     ((org-agenda-overriding-header "")
                      (org-super-agenda-groups
                       '((:name "In Flight" :todo ("NEXT" "IN-PROGRESS"))
                         (:name "Waiting / Review" :todo ("WAIT" "REVIEW"))
                         (:name "Inbox (unsorted)" :file-path "inbox\\.org")
                         (:auto-parent t)))))))

          ("r" "Weekly Review"
           ((agenda ""
                    ((org-agenda-span 7)
                     (org-agenda-start-day "-6d")
                     (org-agenda-start-on-weekday nil)
                     (org-agenda-overriding-header
                      "LAST 7 DAYS — what got done / clocked\n")))
            (tags "LEVEL=1"
                  ((org-agenda-files (list ,jd/org-inbox-file))
                   (org-agenda-overriding-header
                    "\nINBOX — get this to zero\n")))
            (stuck ""
                   ((org-agenda-overriding-header
                     "\nSTUCK PROJECTS — give each a NEXT action\n")))
            (todo "WAIT|HOLD"
                  ((org-agenda-overriding-header
                    "\nWAITING / ON HOLD — still true?\n"))))
           ((org-agenda-start-with-log-mode t)
            (org-agenda-log-mode-items '(closed clock state))
            (org-agenda-archives-mode t)))))

  ;; org-bookmark was dropped: it isn't part of current Org and threw an
  ;; error at every startup.
  (setq org-modules
        '(org-crypt
          org-habit))

  ;; Encrypt any heading tagged :crypt: with gpg on save (symmetric -- you
  ;; pick a passphrase). Decrypt with M-x org-decrypt-entry. For passwords,
  ;; private journal entries, etc..
  (require 'org-crypt)
  (setq org-crypt-key nil)
  (org-crypt-use-before-save-magic)

  ;; Finished subtrees go to ~/org/archive/<file>_archive, out of the agenda.
  (setq org-archive-location (concat org-directory "archive/%s_archive::"))

  (setq org-refile-targets '((nil :maxlevel . 3)
                             (org-agenda-files :maxlevel . 3)))

  (setq org-refile-use-outline-path 'file)
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  (setq org-outline-path-complete-in-steps nil)

  ;; Capture templates -- SPC x, then a key. Everything is fast to file and
  ;; asks as little as possible; sorting happens later from the inbox.
  (setq org-capture-templates
        (doct `(("Inbox (anything)" :keys "i"
                 :file ,jd/org-inbox-file
                 :template "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%i"
                 :empty-lines-after 1)
                ("Inbox + link to here" :keys "l"
                 :file ,jd/org-inbox-file
                 :template "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n%i"
                 :empty-lines-after 1)
                ("Task (scheduled)" :keys "t"
                 :file ,jd/org-tasks-file
                 :headline "Tasks"
                 :template "* TODO %^{Task}\nSCHEDULED: %^{Scheduled}t\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?")
                ("Deadline" :keys "d"
                 :file ,jd/org-tasks-file
                 :headline "Tasks"
                 :template "* TODO %^{Task}\nDEADLINE: %^{Deadline}t\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?")
                ("Event / appointment" :keys "e"
                 :file ,jd/org-tasks-file
                 :headline "Calendar"
                 :template "* %^{Event}\n%^{When}T\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?")
                ("Project" :keys "p"
                 :file ,jd/org-tasks-file
                 :headline "Projects"
                 :template "* PLANNED %^{Project} [/] :project:\n:PROPERTIES:\n:CREATED: %U\n:END:\n%^{Why does this matter / what does done look like?}\n** NEXT %^{First concrete step}"))))

  (evil-define-key '(normal insert visual) org-mode-map (kbd "C-j") 'org-next-visible-heading)
  (evil-define-key '(normal insert visual) org-mode-map (kbd "C-k") 'org-previous-visible-heading)

  (evil-define-key '(normal insert visual) org-mode-map (kbd "M-j") 'org-metadown)
  (evil-define-key '(normal insert visual) org-mode-map (kbd "M-k") 'org-metaup)

  ;; "t" (evil-org's todo keytheme) still cycles/prompts through every TODO
  ;; state. RET is an extra shortcut that only ever marks the heading DONE,
  ;; on a link it opens the link, and otherwise behaves like normal RET.
  (defun jd/org-return-or-todo-done ()
    (interactive)
    (cond ((org-in-regexp org-link-any-re) (org-open-at-point))
          ((org-at-heading-p) (org-todo "DONE"))
          (t (call-interactively 'evil-ret))))
  (evil-define-key 'normal org-mode-map (kbd "RET") 'jd/org-return-or-todo-done)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)
     (js . t)
     (sql . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes)

  ;; Increase the size of various headings
  (set-face-attribute 'org-document-title nil :font "JetBrains Mono Nerd Font" :weight 'bold :height 1.0)
  (dolist (face '((org-level-1 . 1.0)
                  (org-level-2 . 1.0)
                  (org-level-3 . 1.0)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.0)
                  (org-level-6 . 1.0)
                  (org-level-7 . 1.0)
                  (org-level-8 . 1.0)))
    (set-face-attribute (car face) nil :font "JetBrains Mono Nerd Font" :weight 'medium :height (cdr face)))

  ;; Make sure org-indent face is available
  (require 'org-indent)

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground 'unspecified :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)
  (jd/org-blocks-style-refresh)

  ;; Highlight the language on #+begin_src lines, and drop the code-card
  ;; background from quote/verse delimiter lines (org gives every block's
  ;; begin/end line the same face, so quotes need this override).
  (font-lock-add-keywords
   'org-mode
   '(("^[ \t]*#\\+\\(?:begin\\|BEGIN\\)_\\(?:src\\|SRC\\)[ \t]+\\([^ \t\n]+\\)"
      (1 'jd/org-src-lang prepend))
     ("^[ \t]*#\\+\\(?:begin\\|BEGIN\\|end\\|END\\)_\\(?:quote\\|QUOTE\\|verse\\|VERSE\\)\\b.*\n?"
      (0 'jd/org-quote-delimiter prepend)))
   t)

  ;; The org-modern checked-box glyph (a checkmark inside a small box) doesn't
  ;; render legibly at normal text size in some fonts. Fade the item's text
  ;; instead (see `jd/org-checkbox-done-text') so "done" is obvious regardless
  ;; of how the box glyph itself looks.
  (font-lock-add-keywords
   'org-mode
   '(("^[ \t]*\\(?:[-+*]\\|[0-9]+[.)]\\)[ \t]+\\[X\\][ \t]+\\(.*\\)$"
      (1 'jd/org-checkbox-done-text append))))

  ;; Get rid of the background on column views
  (set-face-attribute 'org-column nil :background 'unspecified)
  (set-face-attribute 'org-column-title nil :background 'unspecified)

  ;; Block Templates
  ;; This is needed as of Org 9.2
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("src" . "src"))

  ;; Bindings
  (use-package evil-org
    :after org
    :hook ((org-mode . evil-org-mode)
           (org-agenda-mode . evil-org-mode)
           (evil-org-mode . (lambda () (evil-org-set-key-theme '(navigation todo insert textobjects additional)))))
    :config
    (require 'evil-org-agenda)
    (evil-org-agenda-set-keys)))

;; Reveal emphasis markers/links only while point is on them -- pairs with
;; org-hide-emphasis-markers t above, which otherwise hides them permanently.
(use-package org-appear
  :after org
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autoemphasis t)
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t))

;; PRETTY ORG (like Doom Emacs' org +pretty) -----------------------
(use-package org-modern
  :straight t
  :after org
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :custom
  ;; Headers/stars stay exactly as-is (visible by default) -- don't hide or replace them
  (org-modern-star nil)
  (org-modern-hide-stars nil)
  ;; valign handles table alignment instead -- the two aren't compatible together
  (org-modern-table nil)
  ;; org-modern-indent draws block brackets instead. org-modern only skips its
  ;; own fringe border when org-indent is already on, but org-modern-mode
  ;; starts first -- so the border's line-prefix would overwrite the block's
  ;; indentation whenever a new or edited block is re-highlighted.
  (org-modern-block-fringe nil)
  (org-modern-todo-faces org-todo-keyword-faces)
  ;; Block delimiters: a code icon before the language, an opening quote
  ;; mark for quotes, and blank #+end_ lines (they become bottom padding;
  ;; org-modern-indent's ╰ still marks where the block ends).
  (org-modern-block-name
   `(("src"     "\uf121 " "")
     ("quote"   ,(propertize "❝" 'face 'jd/org-quote-mark) "")
     ("verse"   ,(propertize "❝" 'face 'jd/org-quote-mark) "")
     ("example" "\uf15c example" "")
     (t . t))))

;; org-modern hides its own source-block fringe styling once org-indent-mode
;; is on (which jd/org-mode-setup always enables) -- this restores it.
(use-package org-modern-indent
  :straight (org-modern-indent :type git :host github :repo "jdtsmith/org-modern-indent")
  :after org
  :hook (org-mode . org-modern-indent-mode)
  :config
  ;; By default the ╭│╰ bracket takes the last column of the heading's
  ;; indentation, so blocks start one column left of the body text. Give it
  ;; one extra column so the bracket lines up with the paragraphs and the
  ;; block's content sits just inside it.
  ;; (The package writes `omi/' as shorthand for `org-modern-indent-'.)
  ;; The package measures the indent from the line's current prefix -- which
  ;; may be the bracket prefix it drew itself, or missing on a block you
  ;; just typed. Compute it from the heading level instead (exactly what
  ;; org-indent gives body text), so blocks land in the same place no
  ;; matter when or how often they're redrawn.
  (defun jd/omi-align-with-body (args)
    "Draw block brackets in the body-text column of the enclosing heading."
    (pcase-let ((`(,beg ,end ,beg0 ,end0 ,org-indent ,real-indent) args))
      (let* ((level (save-excursion (goto-char beg) (or (org-current-level) 0)))
             (body (if (and (> level 0) (boundp 'org-indent--text-line-prefixes)
                            (< level (length org-indent--text-line-prefixes)))
                       (length (aref org-indent--text-line-prefixes level))
                     0)))
        (if (and (> body 0) (= real-indent 0))
            (list beg end beg0 end0 (1+ body) real-indent)
          args))))
  (advice-add 'org-modern-indent--draw-block :filter-args #'jd/omi-align-with-body))

;; Pixel-perfect table alignment under variable-pitch-mode, which
;; jd/org-mode-setup turns on for every org buffer.
(use-package valign
  :after org
  :hook (org-mode . valign-mode)
  :custom
  (valign-fancy-bar t))

;; PRESENTATIONS -----------------------
;; org-present
(defun jd/org-present-prepare-slide ()
  (org-overview)
  (org-fold-show-entry)
  (org-fold-show-children))

(defun jd/org-present-hook ()
  (setq-local face-remapping-alist '((default (:height 1.5) variable-pitch)
                                     (header-line (:height 4.5) variable-pitch)
                                     (org-code (:height 1.5) org-code)
                                     (org-verbatim (:height 1.5) org-verbatim)
                                     ;; Blocks scale with the slide text too
                                     (org-block (:height 1.5) org-block)
                                     (org-block-begin-line (:height 1.3) org-block-begin-line)
                                     (org-block-end-line (:height 1.3) org-block-end-line)
                                     (org-quote (:height 1.5) org-quote)
                                     (org-verse (:height 1.5) org-verse)
                                     (org-modern-block-name (:height 1.3) org-modern-block-name)
                                     (org-modern-indent-bracket-line (:height 1.5) org-modern-indent-bracket-line)))
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

;; ORG ROAM (your notes) -----------------------
;; One small file per idea in ~/org/notes/, linked by stable IDs, so renaming
;; or moving a note never breaks a link. The backlinks panel (SPC n l) is
;; every note that links here, across your whole archive.
(use-package org-roam
  :straight t
  :custom
  (org-roam-directory (file-truename org-directory))
  (org-roam-dailies-directory "journal/")
  ;; Only suggest note links after typing [[ (or C-M-i), not on every word.
  (org-roam-completion-everywhere nil)
  (org-roam-node-display-template
   (concat "${title:*} " (propertize "${tags:30}" 'face 'org-tag)))

  (org-roam-capture-templates
   '(("d" "Note" plain
      "%?"
      :target (file+head "notes/${slug}.org"
                         "#+title: ${title}\n#+created: %U\n#+filetags:\n\n")
      :unnarrowed t)

     ("r" "Reference (book / article / video / course)" plain
      "* Summary\n%?\n\n* Key ideas\n\n* My thoughts\n"
      :target (file+head "notes/${slug}.org"
                         ":PROPERTIES:\n:AUTHOR: %^{Author}\n:SOURCE: %^{Link or ISBN}\n:STATUS: %^{Status|reading|done|to-read}\n:END:\n#+title: ${title}\n#+created: %U\n#+filetags: :reference:\n\n")
      :unnarrowed t)

     ("t" "Topic hub (index of related notes)" plain
      "* Notes\n%?\n\n* Open questions\n"
      :target (file+head "notes/${slug}.org"
                         "#+title: ${title}\n#+created: %U\n#+filetags: :hub:\n\n")
      :unnarrowed t)))

  ;; Daily journal -- SPC n d c, then pick one. File: ~/org/journal/YYYY-MM-DD.org
  (org-roam-dailies-capture-templates
   (let ((head "#+title: %<%Y-%m-%d %A>\n#+filetags: :journal:\n"))
     `(("d" "Log entry" entry
        "* %<%I:%M %p> %?"
        :target (file+head "%<%Y-%m-%d>.org" ,head))
       ("m" "Morning reflection" entry
        "* Morning reflection — %<%I:%M %p>\n/%(my/stoic-morning-question)/\n\n%?"
        :target (file+head "%<%Y-%m-%d>.org" ,head))
       ("e" "Evening reflection" entry
        "* Evening reflection — %<%I:%M %p>\n/%(my/stoic-evening-question)/\n\n%?"
        :target (file+head "%<%Y-%m-%d>.org" ,head)))))

  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         :map org-mode-map
         ("C-M-i" . completion-at-point)
         :map org-roam-dailies-map
         ("Y" . org-roam-dailies-capture-yesterday)
         ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies)
  (dolist (dir '("notes" "journal" "archive"))
    (make-directory (expand-file-name dir org-roam-directory) t))
  (org-roam-db-autosync-mode 1))

;; Live-preview while picking notes, plus full-text search & backlink jumping
;; through consult (SPC n s, SPC n b).
(use-package consult-org-roam
  :straight t
  :after org-roam
  :diminish consult-org-roam-mode
  :custom
  (consult-org-roam-grep-func #'consult-ripgrep)
  (consult-org-roam-buffer-narrow-key ?r)
  :config
  (consult-org-roam-mode 1)
  (consult-customize
   org-roam-node-find org-roam-node-insert
   :preview-key "M-."))

;; QUERIES (saved views over plain text) -----------------------
;; org-ql searches every heading in ~/org by todo state, tag, property, date,
;; text... SPC n q prompts for a query, e.g.:
;;   todo:NEXT                       all next actions
;;   tags:reference property:STATUS=reading   books you're reading
;;   todo: deadline:to=7             anything due in the next week
;;   closed:on=-7 ...                done in the last week
;;   "some words" tags:idea          ideas mentioning some words
;; In the results buffer press `v' to save it as a named view.
(use-package org-ql
  :straight t
  :after org
  :commands (org-ql-search org-ql-view))

(defun jd/org-ql-search-all (query)
  "Run org-ql QUERY over every org file under `org-directory'."
  (interactive (list (read-string "org-ql query: " nil 'jd/org-ql-history)))
  (org-ql-search (directory-files-recursively org-directory "\\.org\\'") query))

;; AGENDA GROUPING -----------------------
;; Lets agenda views declare `org-super-agenda-groups' to auto-bucket entries
;; (e.g. by parent project, tag, or todo state) -- used by "By Project" (p).
(use-package org-super-agenda
  :after org-agenda
  :config
  (org-super-agenda-mode))

;; IMAGES -----------------------
;; Drag-and-drop / clipboard-paste images straight into org files as links.
(use-package org-download
  :after org
  :hook ((dired-mode . org-download-enable)
         (org-mode . org-download-enable))
  :custom
  (org-download-method 'directory)
  (org-download-image-dir "./images")
  (org-download-heading-lvl nil)
  (org-download-timestamp "%Y%m%d-%H%M%S_"))

;; TRANSCLUSION -----------------------
;; Embed a live copy of a heading/section from one org file inside another
;; without duplicating the text.
(use-package org-transclusion
  :after org)

;; DEVELOPMENT -----------------------
;; Git
;; Magit
(use-package magit
  :bind ("C-M-;" . magit-status)
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Diff Indicators in the Fringe (like gitsigns.nvim)
(use-package diff-hl
  :straight t
  :hook ((magit-post-refresh . diff-hl-magit-post-refresh)
         (dired-mode . diff-hl-dired-mode))
  :init
  (global-diff-hl-mode 1)
  ;; Update the markers as you type, not just on save
  (diff-hl-flydiff-mode 1))

;; Smart Parens
(use-package smartparens
  :hook (prog-mode . smartparens-mode))

;; TERMINAL -----------------------
;; vterm
(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

(defun jd/vterm--dock-below (buf)
  "Show BUF in a window docked to the bottom of the frame, not a full-frame split."
  (let ((window (split-window (frame-root-window)
                              (- (max 12 (/ (frame-height) 3)))
                              'below)))
    (set-window-buffer window buf)
    (select-window window)))

(defun jd/vterm-toggle ()
  "Toggle a vterm terminal docked in a small window at the bottom of the frame.
Like a popup terminal buffer instead of vterm taking over the whole view."
  (interactive)
  (let* ((buf (get-buffer "*vterm*"))
         (win (and buf (get-buffer-window buf))))
    (cond
     (win (delete-window win))
     (buf (jd/vterm--dock-below buf))
     (t (jd/vterm--dock-below (save-window-excursion (vterm) (current-buffer)))))))

;; LANGUAGE MODES (TREE-SITTER) -----------------------
(use-package treesit-auto
  :straight t
  :custom
  ;; t (not the package default 'prompt) -- grammar installs happen without
  ;; a blocking y-or-n-p, which matters when init.el is loaded
  ;; non-interactively (e.g. --batch checks). 'always is NOT a valid value
  ;; for this defcustom (only t/nil/'prompt are) and silently no-ops if used.
  (treesit-auto-install t)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; PROJECT MANAGEMENT -----------------------
(use-package project
  :straight nil
  :config
  (jd/leader-keys
    "p"  '(:ignore t :which-key "project")
    "pp" '(project-switch-project :which-key "switch project")
    "pf" '(project-find-file :which-key "find file in project")
    "ps" '(consult-ripgrep :which-key "search in project")
    "pk" '(project-kill-buffers :which-key "kill project buffers")))

;; LSP -----------------------
(use-package flycheck
  :straight t
  :init (global-flycheck-mode))

(defun jd/lsp-deferred ()
  (lsp-deferred))

(use-package lsp-mode
  :straight t
  :commands (lsp lsp-deferred)
  :hook ((typescript-ts-mode . jd/lsp-deferred)
         (tsx-ts-mode . jd/lsp-deferred)
         (js-ts-mode . jd/lsp-deferred)
         (css-ts-mode . jd/lsp-deferred)
         (json-ts-mode . jd/lsp-deferred))
  :custom
  ;; Let corfu drive completion-at-point instead of pulling in company.
  (lsp-completion-provider :none)
  (lsp-diagnostics-provider :flycheck)
  (lsp-eslint-package-manager "pnpm")
  :init
  (jd/leader-keys
    "cf" '(apheleia-format-buffer :which-key "format buffer")
    "ca" '(lsp-execute-code-action :which-key "code action")
    "cr" '(lsp-rename :which-key "rename symbol")
    "cd" '(lsp-find-definition :which-key "go to definition")
    "ce" '(flycheck-next-error :which-key "next error")
    "cE" '(flycheck-previous-error :which-key "previous error")

    "l"  '(:ignore t :which-key "lsp")
    "li" '(lsp-inlay-hints-mode :which-key "toggle inlay hints")
    "lr" '(lsp-workspace-restart :which-key "restart lsp")
    "ls" '(lsp-ui-doc-glance :which-key "lsp doc"))
  :config
  ;; lsp-mode's built-in language-id table already covers the -ts-mode
  ;; variants as of this vendored version, but these entries are added
  ;; explicitly so client activation doesn't silently regress on upgrade.
  (add-to-list 'lsp-language-id-configuration '(typescript-ts-mode . "typescript"))
  (add-to-list 'lsp-language-id-configuration '(tsx-ts-mode . "typescriptreact"))
  (add-to-list 'lsp-language-id-configuration '(js-ts-mode . "javascript"))
  (add-to-list 'lsp-language-id-configuration '(css-ts-mode . "css"))
  (add-to-list 'lsp-language-id-configuration '(json-ts-mode . "json")))

(use-package lsp-ui
  :straight t
  :commands lsp-ui-mode
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-sideline-enable t)
  (lsp-ui-doc-enable t))

;; FORMATTING -----------------------
(use-package apheleia
  :straight t
  :config
  ;; apheleia already ships a 'prettier formatter definition that resolves
  ;; each project's local node_modules/.bin/prettier first -- these lines
  ;; only map the tree-sitter mode names onto that existing formatter.
  (dolist (mode '(typescript-ts-mode tsx-ts-mode js-ts-mode css-ts-mode json-ts-mode))
    (setf (alist-get mode apheleia-mode-alist) '(prettier)))
  (apheleia-global-mode 1))

;; SNIPPETS -----------------------
(use-package yasnippet
  :straight t
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package yasnippet-snippets
  :straight t
  :after yasnippet)

;; MISC FILE TYPES -----------------------
(use-package dotenv-mode
  :straight t
  :mode ("\\.env\\..*\\'" "\\.env\\'"))

;; Built into Emacs since 30.
(use-package editorconfig
  :straight nil
  :config
  (editorconfig-mode 1))

(use-package markdown-mode
  :straight t
  :mode ("\\.md\\'" . gfm-mode))

(add-to-list 'auto-mode-alist '("\\.sql\\'" . sql-mode))
(add-to-list 'auto-mode-alist '("\\.[cm]js\\'" . js-ts-mode))

;; Prisma schema files -- no maintained tree-sitter grammar or MELPA major
;; mode exists as of this writing; conf-mode gives basic comment/string
;; highlighting until a real mode shows up.
(add-to-list 'auto-mode-alist '("\\.prisma\\'" . conf-mode))

;;; init.el ends here
