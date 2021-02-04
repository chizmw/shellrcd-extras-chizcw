precmd() { if [ -n "$TMUX" ] ; then tmux rename-window "$(basename $PWD)"; fi; }
