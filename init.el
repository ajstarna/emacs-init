;; https://github.crookster.org/switching-to-straight.el-from-emacs-26-builtin-package.el/
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

;;;;  Effectively replace use-package with straight-use-package
;;; https://github.com/raxod502/straight.el/blob/develop/README.md#integration-with-use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;;;;  package.el
;;; so package-list-packages includes them
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(add-hook 'prog-mode-hook 'display-line-numbers-mode) ;; line numbers
(setq column-number-mode t) ;; column numbers
(add-hook 'write-file-hooks 'delete-trailing-whitespace)


(defun maybe-delete-frame-buffer (frame)
  "When a dedicated FRAME is deleted, also kill its buffer.
A dedicated frame contains a single window whose buffer is not
displayed anywhere else."
  (let ((windows (window-list frame)))
    (when (eq 1 (length windows))
      (let ((buffer (window-buffer (car windows))))
        (when (eq 1 (length (get-buffer-window-list buffer nil t)))
          (kill-buffer buffer))))))
(add-to-list 'delete-frame-functions #'maybe-delete-frame-buffer)

(use-package material-theme
:ensure t
:config
(load-theme 'material t))

;; Rust
;; 
;; ******** Prereq: make sure to install rust-analyzer **********
;; https://rust-analyzer.github.io/manual.html#installation
;; 1) rustup component add rust-src
;; 2) rustup component add rust-analyzer
;; Rust
;;(use-package rustic)
(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  ;;(setq rustic-format-on-save t)
)


(setq-default indent-tabs-mode t)
;; width of 8 in our code base
(setq-default rust-indent-offset 8)

(use-package lsp-mode
  :commands lsp
  :custom
  ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-eldoc-render-all t) ;;; this was the doc at the bottom
  (lsp-idle-delay 0.1) ;; isn't working to make large?
  ;; enable / disable the hints as you prefer:
  (lsp-inlay-hint-enable t)
  ;; These are optional configurations. See https://emacs-lsp.github.io/lsp-mode/page/lsp-rust-analyzer/#lsp-rust-analyzer-display-chaining-hints for a full list
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints nil)
  (lsp-rust-analyzer-display-reborrow-hints nil)
  (lsp-rust-analyzer-display-parameter-hints nil) ;; trying this for compny to be happy  :(
  (lsp-rust-analyzer-closing-brace-hints t) ;; trying out
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))

;; setting this high since our node codebase has ~1100 files and asks me every time
(setq-default lsp-file-watch-threshold 3000)

;; https://github.com/emacs-lsp/lsp-pyright                                                                                               
(use-package lsp-pyright                                                                                                                  
  :ensure t                                                                                                                               
  :custom (lsp-pyright-langserver-command "pyright")                                                                                      
  :hook (python-mode . (lambda ()                                                                                                         
                          (require 'lsp-pyright)                                                                                          
                          (lsp))))  ; or lsp-deferred 

;; company and yas-snippet needed for auto complete
(use-package company
  :ensure
  :custom
  (company-idle-delay 0.5) ;; how long to wait until popup
  ;; (company-begin-commands nil) ;; uncomment to disable popup
  :bind
  (:map company-active-map
              ("C-n". company-select-next)
              ("C-p". company-select-previous)
              ("M-<". company-select-first)
              ("M->". company-select-last)))


(use-package yasnippet
  :ensure
  :config
  (yas-reload-all)
  (add-hook 'prog-mode-hook 'yas-minor-mode)
  (add-hook 'text-mode-hook 'yas-minor-mode))


(use-package counsel)

(ivy-mode)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)

;; to wrap around back to the beginning with C-n)
(setq ivy-wrap t)
(setq ivy-height 14)

;; enable this if you want `swiper' to use it
;; (setq search-default-mode #'char-fold-to-regexp)
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "<f6>") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-ag)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)

(use-package projectile
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))
;; lets projectile find file (and others) feel like ivy (was supposed to be by default but i needed this...)
(setq projectile-completion-system 'ivy)
(use-package ag) ;; for silver searcher inside projectile to work
;; Ignore certain directories in Projectile
(setq projectile-globally-ignored-directories '(".git" "target"))

;; neotree
(use-package neotree)
(setq neo-smart-open t)
(global-set-key (kbd "C-c n s") 'neotree-show)
(global-set-key (kbd "C-c n h") 'neotree-hide)
