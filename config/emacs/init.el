(add-hook 'before-save-hook #'whitespace-cleanup)

(setq-default sentence-end-double-space nil)

(global-subword-mode 1)

(setq scroll-conservatively 1000)

(setq-default initial-major-mode 'text-mode)

(setq-default indent-tabs-mode nil)
(add-hook 'prog-mode-hook (lambda () (setq indent-tabs-mode nil)))

(setq epg-pinentry-mode 'loopback)

(setq backup-directory-alist `(("." . ,(expand-file-name ".tmp/backups/"
                                                         user-emacs-directory))))

(setq-default custom-file (expand-file-name ".custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(setq delete-by-moving-to-trash t)

(setq-default initial-scratch-message nil)

(if (version<= emacs-version "28")
    (defalias 'yes-or-no-p 'y-or-n-p)
  (setopt use-short-answers t))

(global-auto-revert-mode 1)

(setq undo-limit 100000000
      auto-save-default t)

(setq window-combination-resize t)

(setq user-full-name       "Matthew Hinton"
      user-real-login-name "Matthew Hinton"
      user-login-name      "matthew"
      user-mail-address    "mttwhtn@gmail.com")

(setq visible-bell t)

(setq x-stretch-cursor t)

(with-eval-after-load 'mule-util
  (setq truncate-string-ellipsis "…"))

(add-to-list 'default-frame-alist '(alpha-background . 0.9))

(defvar wyvernh/default-font-size 105)
(defvar wyvernh/default-font-name "Fira Code")
(defun my/set-font ()
  (when (find-font (font-spec :name wyvernh/default-font-name))
    (set-face-attribute 'default nil
                        :font wyvernh/default-font-name
                        :height wyvernh/default-font-size)))
(my/set-font)
(add-hook 'server-after-make-frame-hook #'my/set-font)

;  (use-package solaire-mode
;    :defer t
;    :init (solaire-global-mode +1))

(add-to-list 'custom-theme-load-path "~/.config/emacs")
;  (require 'tomorrow-night-paradise-theme)
  (load-theme 'tomorrow-night-paradise t)

;(use-package rainbow-delimiters
;  :defer t
;  :hook (prog-mode . rainbow-delimiters-mode))
