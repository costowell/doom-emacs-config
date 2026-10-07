;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

;;(setq doom-theme 'doom-dark+)
(setq doom-theme 'doom-1337)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Tank/org")

;; Projects
(setq projectile-project-search-path '(("~/Tank/Code/" . 3) ("~/Tank/School/Current" . 3)))

;; LSP Stuff
(setq read-process-output-max (* 1024 2024))
(setq lsp-idle-delay 0.025)

;; Shell
(setq shell-file-name "fish")

;; Keybinds
(after! vterm
  ;; Disable Alt+number keys to prevent workspace switching conflicts
  (dolist (num (number-sequence 0 9))
    (let ((key (format "M-%d" num)))
      (define-key vterm-mode-map (kbd key) nil))))

;; Window navigation with Alt + h/j/k/l
(use-package bind-key
  :ensure t
  :config
  (bind-key* "M-h" 'windmove-left)
  (bind-key* "M-j" 'windmove-down)
  (bind-key* "M-k" 'windmove-up)
  (bind-key* "M-l" 'windmove-right))

(setq-hook! '(go-mode-hook go-ts-mode-hook)
  tab-width 4
  go-ts-mode-indent-offset 4
  evil-shift-width 4)

;; Typst
;; Doom's indent-var autodetection looks for `typst-indent-offset', so
;; `typst-ts-indent-offset' (and thus tab-width) has to be set by hand.
(setq-hook! 'typst-ts-mode-hook
  typst-ts-indent-offset 2
  tab-width 2
  evil-shift-width 2)

(use-package! typst-ts-mode
  ;; Autoloads are disabled for this package (see packages.el), so the entry
  ;; points have to be declared here.
  :mode "\\.typ\\'"
  :commands (typst-ts-mode typst-ts-watch-mode typst-ts-mc-install-grammar)
  :init
  ;; There's no non-tree-sitter typst mode to fall back to, so this only
  ;; registers the grammar recipe. Install it with `M-x
  ;; treesit-install-language-grammar RET typst'. The repo is the typst-ts-mode
  ;; maintainer's fork (what the package itself installs); bump :commit to pick
  ;; up grammar fixes.
  (set-tree-sitter! nil 'typst-ts-mode
    '((typst :url "https://github.com/Ziqi-Yang/tree-sitter-typst"
       :rev "master"
       :commit "46cf4ded12ee974a70bf8457263b67ad7ee0379d")))
  ;; Fontify ```lang ... ``` raw blocks with that language's own grammar.
  (setq typst-ts-enable-raw-blocks-highlight t)
  :config
  ;; tinymist; lsp-mode already maps typst-ts-mode -> "typst" and autoloads
  ;; `lsp-typst', so no manual require is needed (unlike lsp-sml above).
  (add-hook 'typst-ts-mode-local-vars-hook #'lsp! 'append)

  ;; HACK: `typst-ts-compile-options'/`typst-ts-common-options' are lists now,
  ;;   but `typst-ts-set-compile-command' still interpolates them with %s, so
  ;;   `compile-command' (what `SPC c c' runs) ends up as "typst compile x.typ
  ;;   nil". `typst-ts-compile' builds its own command, so it isn't affected.
  ;; REVIEW: Drop this once upstream fixes that format string.
  (defadvice! +typst-ts-fix-compile-command-a (&rest _)
    :after #'typst-ts-set-compile-command
    (when-let* ((target (typst-ts-compile-get-target-file-argument)))
      (setq-local compile-command
                  (string-join (append (list typst-ts-compile-executable-location
                                             "compile"
                                             (shell-quote-argument target))
                                       typst-ts-common-options
                                       typst-ts-compile-options)
                               " "))))

  (map! :localleader
        :map typst-ts-mode-map
        "c" #'typst-ts-compile
        "C" #'typst-ts-compile-and-preview
        "p" #'typst-ts-preview
        "w" #'typst-ts-watch-mode
        "m" #'typst-ts-main-file-ask
        "o" #'typst-ts-mc-open-at-point
        "l" #'typst-ts-mc-insert-link
        "'" #'typst-ts-edit-indirect))

(after! lsp-mode
  ;; tinymist embeds typstyle, so format-on-save goes through the LSP formatter
  ;; (apheleia falls back to the typstyle binary when tinymist isn't running).
  (setq lsp-typst-formatter-mode "typstyle"
        lsp-typst-formatter-indent-size 2
        lsp-typst-formatter-print-width 100
        lsp-typst-lint-enabled t))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
