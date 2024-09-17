Input config goes into `~/.config/mpv/`, scripts go into `~/.config/mpv/scripts/`


Create alias for mpv in your zshrc (or bashrc I guess?)
```
alias mpvfilm="mpv --osd-level=1 --osd-duration=0 --script='DIR/jumping.lua' --input-conf='DIR/input.conf' --autofit=100%x100%"
```
to show the current chapter, to load the configuration and the script, and to make sure the video player fills the screen.
