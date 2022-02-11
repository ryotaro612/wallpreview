;;; package --- Summary
;;; Commentary:
;;; Code:
(require 'image-dired)
(defgroup wallpreview-mode nil
  "Set wallpapers with image-dired."
  :prefix "wallpreview-mode-"
  :group 'wallpreview-mode)

(defcustom wallpreview-mode-wallpaper-cmd
  'wallpreview-mode-sway-bg
  "A function that takes a filename and return 
the command that sets the image to wallpaper."
  :type 'function
  )

(defcustom wallpreview-mode-wallpaper-directory
  "~/Pictures"
  "Wallpapers directory."
  :type 'directory)

(defun wallpreview-mode-sway-bg (wallpaper-path)
  (concat "swaymsg output \"*\" bg \""
	  (shell-quote-argument wallpaper-path)
	  "\" fill"))

(defun wallpreview-mode-set-wallpaper (&optional arg)
  "Set a background image."
  (interactive "fBackground image: ")
  (let ((wallpaper-path (or arg (image-dired-original-file-name))))
    (call-process-shell-command
     (concat (apply wallpreview-mode-wallpaper-cmd (list wallpaper-path)) "&")
     nil 0)))

(defun wallpreview-mode-wallpaper-set
    (a)
  (wallpreview-mode-wallpaper-set-fn a))

(defun wallpreview-mode-set-wallpaper-after (&rest arg)
  "Use walpreview-set-wallpaper. This function is an after adivce for image-dired-[forward, backward]-image, image-dired-[previous, next]-line."
  (wallpreview-mode-set-wallpaper))

(defun wallpreview-mode-image-dired-track-thumbnail ()
  "Sync the pointer in the image-dired-thumbnail buffer with "
  (interactive)
  (image-dired-track-thumbnail))

(defun wallpreview-mode-enable ()
  (image-dired wallpreview-mode-wallpaper-directory)
  (advice-add 'image-dired-forward-image :after #'wallpreview-mode-set-wallpaper-after)
  (advice-add 'image-dired-backward-image :after #'wallpreview-mode-set-wallpaper-after)
  (advice-add 'image-dired-previous-line :after #'wallpreview-mode-set-wallpaper-after)
  (advice-add 'image-dired-next-line :after #'wallpreview-mode-set-wallpaper-after))

(defun wallpreview-mode-disable ()
  (advice-remove 'image-dired-forward-image #'wallpreview-mode-set-wallpaper-after)
  (advice-remove 'image-dired-backward-image #'wallpreview-mode-set-wallpaper-after)
  (advice-remove 'image-dired-previous-line #'wallpreview-mode-set-wallpaper-after)
  (advice-remove 'image-dired-next-line #'wallpreview-mode-set-wallpaper-after))

(define-minor-mode wallpreview-mode
  "Preview wallpapers in Image-dired mode."
  nil ; Initial value, nil for disabled
  :lighter "  wallpreview"
  (if wallpreview-mode
      (wallpreview-mode-enable)
    (wallpreview-mode-disable)))

(provide 'wallpreview-mode)

