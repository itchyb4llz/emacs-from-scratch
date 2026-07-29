# Web Dev IDE Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add LSP, tree-sitter major modes, formatting, project management, snippets, and misc file-type support to `init.el` so Emacs functions as a full IDE for a Next.js/TypeScript/Tailwind/Prisma/Drizzle/tRPC/pnpm stack.

**Architecture:** All changes append new `;; SECTION -----` blocks to the existing single-file `init.el` (matching its established convention), plus three small in-place edits to remove dead `projectile` references. `lsp-mode` drives code intelligence with `corfu` (existing) for completion UI and `flycheck` (new) for diagnostics. `treesit-auto` installs and activates Emacs 30's native tree-sitter major modes. `apheleia` formats on save via each project's local Prettier. `project.el` (built-in) replaces the never-installed `projectile` references.

**Tech Stack:** Emacs 30.2, straight.el + use-package, evil-mode, general.el leader keys, corfu/vertico/consult (existing completion stack).

## Global Constraints

- Every new package is declared with `use-package <name> :straight t`, matching every existing package declaration in `init.el`. Built-in libraries (`project`) use `:straight nil`.
- Do not install `eglot`, `projectile`, or `company` — the design explicitly supersedes them with `lsp-mode`, `project.el`, and `corfu` respectively.
- New leader-key bindings follow the exact existing pattern: `jd/leader-keys` calls with `"<prefix>" '(:ignore t :which-key "...")` for a new prefix, then `"<prefix><letter>" '(command :which-key "...")` entries — see `init.el:256-295` for the reference style.
- Unless a task says otherwise, new sections are inserted immediately above the file's literal final line, which reads exactly `;;; init.el ends here`. This is a stable anchor regardless of what earlier tasks already appended.
- No manual global npm/pnpm installs are required for LSP servers — `lsp-mode` downloads `typescript-language-server` and `tailwindcss-language-server` itself on first use via its built-in npm-based installer. `npm` must be on PATH (already true via mise on this machine).
- Every task's verification step runs `emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" -l /home/jd/.config/emacs/init.el --eval "..."` — this is confirmed to load cleanly today and is the integration-test mechanism for this single-file config (there is no separate test suite; Elisp unit tests don't fit a use-package-heavy config like this one). First run of a task that adds a new package may take longer than usual while straight.el clones it.
- Prisma (`.prisma` files) gets `conf-mode` only — no LSP, no tree-sitter grammar exists for it. This is an accepted, documented gap, not something to work around.

---

### Task 1: Tree-sitter major modes

**Files:**
- Modify: `init.el` (insert new section before the final line)

**Interfaces:**
- Produces: `tsx-ts-mode`, `typescript-ts-mode`, `js-ts-mode`, `css-ts-mode`, `json-ts-mode` become the active major modes for their respective file extensions. Later tasks (3, 4, 5) hook into these mode names directly.

- [ ] **Step 1: Confirm current (wrong) behavior**

```bash
mkdir -p /tmp/web-ide-check && cd /tmp/web-ide-check
echo 'const x: number = 1;' > sample.ts
echo 'export default function Foo() { return <div>hi</div>; }' > sample.tsx
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(with-current-buffer (find-file-noselect \"/tmp/web-ide-check/sample.tsx\") (princ major-mode))"
```

Expected: prints `fundamental-mode` (no mode is currently registered for `.tsx`).

- [ ] **Step 2: Add the treesit-auto section**

Use the Edit tool to replace the literal final line of `init.el`:

Old string:
```elisp
;;; init.el ends here
```

New string:
```elisp
;; LANGUAGE MODES (TREE-SITTER) -----------------------
(use-package treesit-auto
  :straight t
  :custom
  ;; 'always instead of the package default 'prompt -- grammar installs
  ;; happen without a blocking y-or-n-p, which matters when init.el is
  ;; loaded non-interactively (e.g. --batch checks).
  (treesit-auto-install 'always)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;;; init.el ends here
```

- [ ] **Step 3: Verify the fix**

```bash
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(with-current-buffer (find-file-noselect \"/tmp/web-ide-check/sample.ts\") (princ (format \"ts:%S \" major-mode)))" \
  --eval "(with-current-buffer (find-file-noselect \"/tmp/web-ide-check/sample.tsx\") (princ (format \"tsx:%S \" major-mode)))"
```

Expected: `ts:typescript-ts-mode tsx:tsx-ts-mode` (may take a minute the first time while grammars compile — this is expected, not an error).

- [ ] **Step 4: Commit**

```bash
git add init.el
git commit -m "feat: add tree-sitter major modes via treesit-auto"
```

---

### Task 2: Project management (project.el)

**Files:**
- Modify: `init.el:353-354` (remove dead `counsel-projectile-*` height-alist entries)
- Modify: `init.el:375` (remove dead `ivy-rich-switch-buffer-project` column)
- Modify: `init.el:499-501` (fix `jd/get-project-root` to use `project.el` instead of a nonexistent `projectile`)
- Modify: `init.el` (insert new "PROJECT MANAGEMENT" section before the final line)

**Interfaces:**
- Consumes: `jd/leader-keys` (existing definer from `init.el:119-122`)
- Produces: `jd/get-project-root` now returns a real project root path (or nil outside a project) — already consumed by the existing `consult` block at `init.el:503-513` via `consult-project-root-function`, no change needed there.

- [ ] **Step 1: Confirm current (wrong) behavior**

```bash
mkdir -p /tmp/web-ide-check && cd /tmp/web-ide-check && git init -q
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(let ((default-directory \"/tmp/web-ide-check/\")) (princ (format \"%S\" (jd/get-project-root))))"
```

Expected: prints `nil` even though `/tmp/web-ide-check` is a real git repo — `jd/get-project-root` is dead code today because `projectile` was never installed.

- [ ] **Step 2: Remove the dead counsel-projectile height-alist entries**

Old string (in the `ivy` use-package `:config` block):
```elisp
	(setf (alist-get 'counsel-projectile-ag ivy-height-alist) 15)
  (setf (alist-get 'counsel-projectile-rg ivy-height-alist) 15)
  (setf (alist-get 'swiper ivy-height-alist) 15)
```

New string:
```elisp
	(setf (alist-get 'swiper ivy-height-alist) 15)
```

- [ ] **Step 3: Remove the dead ivy-rich project column**

Old string:
```elisp
                     ((ivy-rich-candidate (:width 40))
                      (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right)); return the buffer indicators
                      (ivy-rich-switch-buffer-major-mode (:width 12 :face warning))          ; return the major mode info
                      (ivy-rich-switch-buffer-project (:width 15 :face success))             ; return project name using `projectile'
                      (ivy-rich-switch-buffer-path (:width (lambda (x) (ivy-rich-switch-buffer-shorten-path x (ivy-rich-minibuffer-width 0.3))))))  ; return file path relative to project root or `default-directory' if project is nil
```

New string:
```elisp
                     ((ivy-rich-candidate (:width 40))
                      (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right)); return the buffer indicators
                      (ivy-rich-switch-buffer-major-mode (:width 12 :face warning))          ; return the major mode info
                      (ivy-rich-switch-buffer-path (:width (lambda (x) (ivy-rich-switch-buffer-shorten-path x (ivy-rich-minibuffer-width 0.3))))))  ; return file path relative to project root or `default-directory' if project is nil
```

- [ ] **Step 4: Fix jd/get-project-root**

Old string:
```elisp
(defun jd/get-project-root ()
  (when (fboundp 'projectile-project-root)
    (projectile-project-root)))
```

New string:
```elisp
(defun jd/get-project-root ()
  (when-let ((proj (project-current)))
    (project-root proj)))
```

- [ ] **Step 5: Add the PROJECT MANAGEMENT section with SPC p keybindings**

Old string:
```elisp
;;; init.el ends here
```

New string:
```elisp
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

;;; init.el ends here
```

- [ ] **Step 6: Verify the fix**

```bash
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(let ((default-directory \"/tmp/web-ide-check/\")) (princ (format \"root:%S \" (jd/get-project-root))))" \
  --eval "(with-temp-buffer (evil-normal-state) (princ (format \"bound:%S\" (and (key-binding (kbd \"SPC p p\")) t))))"
```

Expected: `root:"/tmp/web-ide-check/" bound:t`

- [ ] **Step 7: Confirm no `projectile` references remain**

```bash
grep -ni projectile /home/jd/.config/emacs/init.el
```

Expected: no output (grep exits 1).

- [ ] **Step 8: Commit**

```bash
git add init.el
git commit -m "feat: replace dangling projectile references with project.el"
```

---

### Task 3: LSP (lsp-mode + lsp-ui + flycheck)

**Files:**
- Modify: `init.el` (insert new "LSP" section before the final line)

**Interfaces:**
- Consumes: `typescript-ts-mode`, `tsx-ts-mode`, `js-ts-mode`, `css-ts-mode`, `json-ts-mode` (from Task 1); `jd/leader-keys` (existing)
- Produces: `SPC c f/a/r/d/e/E` and `SPC l i/r/s` keybindings. `apheleia-format-buffer` is referenced by the `SPC c f` binding here but implemented in Task 4 — it will be a `void-function` reference until Task 4 lands; this is acceptable since the binding is only invoked interactively by the user, never during batch loading, so it does not break the load-time verification in this task.

- [ ] **Step 1: Confirm current (wrong) behavior**

```bash
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(with-temp-buffer (evil-normal-state) (princ (format \"flycheck:%S bound:%S\" (bound-and-true-p global-flycheck-mode) (and (key-binding (kbd \"SPC c a\")) t))))"
```

Expected: `flycheck:nil bound:nil`

- [ ] **Step 2: Add the LSP section**

Old string:
```elisp
;;; init.el ends here
```

New string:
```elisp
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
  :config
  ;; lsp-mode's built-in language-id table already covers the -ts-mode
  ;; variants as of this vendored version, but these entries are added
  ;; explicitly so client activation doesn't silently regress on upgrade.
  (add-to-list 'lsp-language-id-configuration '(typescript-ts-mode . "typescript"))
  (add-to-list 'lsp-language-id-configuration '(tsx-ts-mode . "typescriptreact"))
  (add-to-list 'lsp-language-id-configuration '(js-ts-mode . "javascript"))
  (add-to-list 'lsp-language-id-configuration '(css-ts-mode . "css"))
  (add-to-list 'lsp-language-id-configuration '(json-ts-mode . "json"))

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
    "ls" '(lsp-ui-doc-glance :which-key "lsp doc")))

(use-package lsp-ui
  :straight t
  :commands lsp-ui-mode
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-sideline-enable t)
  (lsp-ui-doc-enable t))

;;; init.el ends here
```

- [ ] **Step 3: Verify the fix**

```bash
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(princ (format \"flycheck:%S \" (bound-and-true-p global-flycheck-mode)))" \
  --eval "(princ (format \"hook:%S \" (and (memq 'jd/lsp-deferred tsx-ts-mode-hook) t)))" \
  --eval "(with-temp-buffer (evil-normal-state) (princ (format \"ca:%S cd:%S li:%S\" (and (key-binding (kbd \"SPC c a\")) t) (and (key-binding (kbd \"SPC c d\")) t) (and (key-binding (kbd \"SPC l i\")) t))))"
```

Expected: `flycheck:t hook:t ca:t cd:t li:t`

- [ ] **Step 4: Commit**

```bash
git add init.el
git commit -m "feat: add lsp-mode, lsp-ui, and flycheck for code intelligence"
```

---

### Task 4: Formatting (apheleia)

**Files:**
- Modify: `init.el` (insert new "FORMATTING" section before the final line)

**Interfaces:**
- Consumes: `typescript-ts-mode`, `tsx-ts-mode`, `js-ts-mode`, `css-ts-mode`, `json-ts-mode` (from Task 1)
- Produces: `apheleia-format-buffer` (already referenced by the `SPC c f` binding added in Task 3 — this task makes that reference resolve to a real function).

- [ ] **Step 1: Confirm current (wrong) behavior**

```bash
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(princ (format \"%S\" (and (boundp 'apheleia-mode-alist) (alist-get 'tsx-ts-mode apheleia-mode-alist))))"
```

Expected: `nil` (apheleia isn't installed yet).

- [ ] **Step 2: Add the FORMATTING section**

Old string:
```elisp
;;; init.el ends here
```

New string:
```elisp
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

;;; init.el ends here
```

- [ ] **Step 3: Verify the fix**

```bash
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(princ (format \"mode-alist:%S global:%S\" (alist-get 'tsx-ts-mode apheleia-mode-alist) (bound-and-true-p apheleia-global-mode)))"
```

Expected: `mode-alist:(prettier) global:t`

- [ ] **Step 4: Commit**

```bash
git add init.el
git commit -m "feat: add apheleia for prettier formatting on save"
```

---

### Task 5: Snippets (yasnippet)

**Files:**
- Modify: `init.el` (insert new "SNIPPETS" section before the final line)

**Interfaces:**
- Produces: `yas-minor-mode` active in all `prog-mode`-derived buffers, including the tree-sitter modes from Task 1 (they all derive from `prog-mode`).

- [ ] **Step 1: Confirm current (wrong) behavior**

```bash
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(with-temp-buffer (typescript-ts-mode) (princ (format \"%S\" (bound-and-true-p yas-minor-mode))))"
```

Expected: `nil`

- [ ] **Step 2: Add the SNIPPETS section**

Old string:
```elisp
;;; init.el ends here
```

New string:
```elisp
;; SNIPPETS -----------------------
(use-package yasnippet
  :straight t
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package yasnippet-snippets
  :straight t
  :after yasnippet)

;;; init.el ends here
```

- [ ] **Step 3: Verify the fix**

```bash
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(with-temp-buffer (typescript-ts-mode) (princ (format \"%S\" (bound-and-true-p yas-minor-mode))))"
```

Expected: `t`

- [ ] **Step 4: Commit**

```bash
git add init.el
git commit -m "feat: add yasnippet for snippet expansion"
```

---

### Task 6: Misc file types (dotenv, editorconfig, markdown, sql, prisma)

**Files:**
- Modify: `init.el` (insert new "MISC FILE TYPES" section before the final line)

**Interfaces:**
- Produces: `dotenv-mode` for `.env*`, `gfm-mode` for `.md`, `sql-mode` for `.sql`, `conf-mode` for `.prisma`, `editorconfig-mode` active globally.

- [ ] **Step 1: Confirm current (wrong) behavior**

```bash
mkdir -p /tmp/web-ide-check && cd /tmp/web-ide-check
touch .env sample.md sample.prisma
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(with-current-buffer (find-file-noselect \"/tmp/web-ide-check/.env\") (princ (format \"env:%S \" major-mode)))" \
  --eval "(with-current-buffer (find-file-noselect \"/tmp/web-ide-check/sample.md\") (princ (format \"md:%S \" major-mode)))" \
  --eval "(with-current-buffer (find-file-noselect \"/tmp/web-ide-check/sample.prisma\") (princ (format \"prisma:%S \" major-mode)))" \
  --eval "(princ (format \"econfig:%S\" (bound-and-true-p editorconfig-mode)))"
```

Expected: `env:fundamental-mode md:fundamental-mode prisma:fundamental-mode econfig:nil`

- [ ] **Step 2: Add the MISC FILE TYPES section**

Old string:
```elisp
;;; init.el ends here
```

New string:
```elisp
;; MISC FILE TYPES -----------------------
(use-package dotenv-mode
  :straight t
  :mode ("\\.env\\..*\\'" "\\.env\\'"))

(use-package editorconfig
  :straight t
  :config
  (editorconfig-mode 1))

(use-package markdown-mode
  :straight t
  :mode ("\\.md\\'" . gfm-mode))

(add-to-list 'auto-mode-alist '("\\.sql\\'" . sql-mode))

;; Prisma schema files -- no maintained tree-sitter grammar or MELPA major
;; mode exists as of this writing; conf-mode gives basic comment/string
;; highlighting until a real mode shows up.
(add-to-list 'auto-mode-alist '("\\.prisma\\'" . conf-mode))

;;; init.el ends here
```

- [ ] **Step 3: Verify the fix**

```bash
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el \
  --eval "(with-current-buffer (find-file-noselect \"/tmp/web-ide-check/.env\") (princ (format \"env:%S \" major-mode)))" \
  --eval "(with-current-buffer (find-file-noselect \"/tmp/web-ide-check/sample.md\") (princ (format \"md:%S \" major-mode)))" \
  --eval "(with-current-buffer (find-file-noselect \"/tmp/web-ide-check/sample.prisma\") (princ (format \"prisma:%S \" major-mode)))" \
  --eval "(princ (format \"econfig:%S\" (bound-and-true-p editorconfig-mode)))"
```

Expected: `env:dotenv-mode md:gfm-mode prisma:conf-mode econfig:t`

- [ ] **Step 4: Commit**

```bash
git add init.el
git commit -m "feat: add dotenv, editorconfig, markdown, sql, and prisma file support"
```

---

### Task 7: Full-config smoke test

**Files:**
- None modified — this task only verifies the cumulative result of Tasks 1-6.

**Interfaces:**
- Consumes: everything produced by Tasks 1-6.

- [ ] **Step 1: Verify init.el loads with zero errors or warnings on stderr**

```bash
emacs --batch --eval "(setq user-emacs-directory \"/home/jd/.config/emacs/\")" \
  -l /home/jd/.config/emacs/init.el --eval "(message \"LOADED-OK\")" 2>/tmp/web-ide-check/stderr.log
cat /tmp/web-ide-check/stderr.log
```

Expected: last line is `LOADED-OK`; no lines containing `Error`, `error:`, or `Warning` beyond the usual native-comp/startup-time message.

- [ ] **Step 2: Verify no dangling projectile references and no eglot/company/projectile packages were introduced**

```bash
grep -ni "projectile\|(use-package eglot\|(use-package company" /home/jd/.config/emacs/init.el
```

Expected: no output (grep exits 1).

- [ ] **Step 3: Clean up the scratch test directory**

```bash
rm -rf /tmp/web-ide-check
```

- [ ] **Step 4: Commit (only if any fixups were needed in prior steps)**

If Steps 1-2 required any corrections to `init.el`, stage and commit them:

```bash
git add init.el
git commit -m "fix: resolve issues found in full-config smoke test"
```

If no corrections were needed, skip this step — there is nothing to commit.
