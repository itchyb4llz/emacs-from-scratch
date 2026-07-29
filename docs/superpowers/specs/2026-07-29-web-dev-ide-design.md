# Web Dev IDE Design

## Goal

Turn this Emacs config into a primary IDE for a web development stack of Next.js,
TypeScript, Tailwind CSS, Drizzle, Prisma, PostgreSQL, tRPC, Node, and pnpm.

Today the config (`init.el`) has evil-mode, doom-themes/modeline, ivy/counsel and
vertico/corfu/consult completion, magit, vterm, and a heavy org-mode setup — but
zero language tooling: no LSP client, no tree-sitter major modes, no formatter
integration, no real project management (only dangling, never-installed
`projectile` references), and no snippets. This spec covers adding that tooling.

Explicitly out of scope for this pass (deferred until requested): in-Emacs
database client, DAP/debugger integration, in-Emacs REST/API client.

## 1. LSP Architecture (lsp-mode)

`lsp-mode` + `lsp-ui` is the code-intelligence backbone, chosen over `eglot` for
its richer built-in client ecosystem (dedicated Tailwind and ESLint clients,
`lsp-ui` sideline/doc UI) — wired into the existing UI stack rather than
replacing it:

- **Completion**: `lsp-completion-provider` set to `:none` so lsp-mode registers
  completions as a `completion-at-point-function` instead of pulling in
  `company`. The existing **corfu** setup picks these up automatically — no new
  completion frontend.
- **Diagnostics**: `flycheck` (new dependency) as `lsp-diagnostics-provider` —
  lsp-mode's native pairing, richer than flymake. `lsp-ui-sideline` shows
  diagnostic text inline; `lsp-ui-doc` shows hover documentation popups.
- **Servers activated per file type**:
  - `typescript-language-server` — TS/TSX/JS/JSX: types, refactors, go-to-def
  - `tailwindcss-language-server` — class name completion/hover, via lsp-mode's
    built-in `lsp-tailwindcss` client
  - ESLint diagnostics via lsp-mode's built-in `lsp-eslint` client (distinct
    from type errors — lint rules, not types)
  - JSON/CSS/HTML via the built-in servers from `vscode-langservers-extracted`
- **Server binaries**: lsp-mode manages its own copies of `typescript-language-server`
  and `tailwindcss-language-server` via its built-in npm-based installer
  (`M-x lsp-install-server`, or an automatic prompt the first time a client
  activates and its server isn't found) — confirmed by reading the vendored
  source in `straight/repos/lsp-mode/clients/lsp-javascript.el` (`:server-id
  'ts-ls`, `:download-server-fn` using `lsp-dependency` with `:npm`) and
  `clients/lsp-tailwindcss.el`. No manual global `pnpm add -g` install is
  needed; the only external requirement is `npm` itself being on PATH (already
  true here via mise). JSON/CSS/HTML support and ESLint diagnostics come from
  lsp-mode's bundled clients the same way — no manual setup for any of them.
- **Known gap**: Prisma's language server has no clean standalone npm package
  usable outside the VSCode extension. `.prisma` files get tree-sitter syntax
  highlighting only (see section 2), no LSP features. This is accepted as a
  gap, not worked around.

## 2. Tree-sitter Major Modes

Emacs 30's native tree-sitter `-ts-mode` variants replace the old regex-based
major modes and are what lsp-mode/flycheck should target.

- **`treesit-auto`** (new dependency) handles grammar installation and
  `auto-mode-alist` remapping automatically — opening a `.tsx` file for the
  first time installs the TSX grammar and switches into `tsx-ts-mode`, no
  manual `treesit-install-language-grammar` calls needed.
- **Mode coverage**:
  | Extension | Mode |
  |---|---|
  | `.ts` | `typescript-ts-mode` |
  | `.tsx` | `tsx-ts-mode` |
  | `.js` / `.jsx` | `js-ts-mode` (grammar handles JSX) |
  | `.css` | `css-ts-mode` |
  | `.json` | `json-ts-mode` |
  | `.yml` / `.yaml` | `yaml-ts-mode` |
  | `.sql` | `sql-mode` (built-in, no tree-sitter grammar needed) |
  | `.prisma` | community `prisma-mode`/`prisma-ts-mode` if a usable MELPA package exists at implementation time; otherwise `conf-mode` fallback for basic highlighting |

## 3. Formatting (Prettier via apheleia)

`apheleia` (new dependency) runs formatters asynchronously on save without
moving point or blocking the editor.

- Shells out to each project's **local** `node_modules/.bin/prettier`, never a
  global install, so formatting always matches the repo's actual Prettier
  version/config (including `prettier-plugin-tailwindcss` class sorting, if
  present). If a project has no local prettier, apheleia skips formatting
  rather than falling back to a mismatched global one.
- Hooked to `typescript-ts-mode`, `tsx-ts-mode`, `js-ts-mode`, `css-ts-mode`,
  `json-ts-mode` via `apheleia-mode`.
- Independent of ESLint diagnostics (section 1) — Prettier formats, ESLint
  lints; they run separately, matching normal Next.js repo conventions.

## 4. Project Management (built-in `project.el`)

- Replaces the dangling, never-installed `projectile` references currently in
  `init.el`: the `counsel-projectile-ag`/`counsel-projectile-rg` height-alist
  entries (`init.el:353-354`), the `jd/get-project-root` `fboundp` check
  (`init.el:500-501`), and the `ivy-rich-switch-buffer-project` column
  (`init.el:375`).
- `consult` (already configured) integrates directly with `project.el`:
  `jd/get-project-root` becomes a thin wrapper around `project-root`, so
  `consult-line`/`consult-ripgrep`/etc scope correctly to the current project
  with no extra glue package.
- New leader-key bindings under a `SPC p` "project" prefix:
  - `pp` — switch project (`project-switch-project`)
  - `pf` — find file in project (`project-find-file`)
  - `ps` — search in project (`consult-ripgrep`)
  - `pk` — kill project buffers (`project-kill-buffers`)

## 5. Snippets & Misc File Types

- **`yasnippet`** + **`yasnippet-snippets`** (new dependencies), enabled
  globally via `prog-mode-hook`, for boilerplate expansion (React components,
  TS interfaces, etc).
- **`dotenv-mode`** (new dependency) for `.env`/`.env.local`/`.env.example` —
  common across Next.js/Prisma/Drizzle projects for values like `DATABASE_URL`.
- **`editorconfig`** (new dependency) so per-project `.editorconfig` files
  (indent style/width) are respected automatically, overriding the config's
  hardcoded global `tab-width 2` where a project specifies otherwise.
- **`markdown-mode`** (new dependency) for README/docs files.

## 6. Keybindings Summary

Following the existing `SPC <letter>` leader-key style:

- `SPC p` — project (new prefix; section 4)
- `SPC c` — extends the existing "code" prefix:
  - `cf` — format buffer now (manual trigger, on top of format-on-save)
  - `ca` — LSP code actions
  - `cr` — rename symbol
  - `cd` — go to definition
  - `ce` / `cE` — next/previous flycheck error
- `SPC l` — new "lsp" prefix for less-frequent actions:
  - `li` — toggle inlay hints (inline parameter/type hints)
  - `lr` — restart lsp workspace
  - `ls` — toggle lsp-ui doc

## New Dependencies

`lsp-mode`, `lsp-ui`, `flycheck`, `treesit-auto`, `apheleia`, `yasnippet`,
`yasnippet-snippets`, `dotenv-mode`, `editorconfig`, `markdown-mode` — all via
`straight.el`/`use-package`, matching the existing config's package-management
approach. No external non-Emacs setup step is required; lsp-mode downloads its
own server binaries on first use (see section 1).
