set -g fish_greeting

pokemon-colorscripts --no-title -r -b

echo It is (date '+%T') and the system is up for (uptime -p | string replace -r '^up ' '')
if status is-interactive
    starship init fish | source
end

# List Directory
alias l='eza -lh  --icons=auto' # long list
alias ls='eza -1   --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree

# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
abbr mkdir 'mkdir -p'

# alias for my easiness
alias q="exit"
alias n="nvim"
alias x="clear"

# Folders
alias work="cd Stuff/idk"
alias dsa="cd /home/om/Stuff/prac/DSA/"
alias ai="cd ai/ && bun ai"

# git alias cause why not
alias lg="lazygit"
alias addall='git add .'
alias branch='git branch'
alias checkout='git checkout'
alias clone='git clone'
alias commit='git commit -m'
alias fetch='git fetch'
alias pull='git pull origin'
alias push='git push origin'
alias tag='git tag'
alias newtag='git tag -a'
alias sw="git switch"

# paru
alias i="paru -S"
alias u="paru -Syu"
alias r="paru -R"
alias R="paru -Rns"
alias s="paru -Slq | fzf --multi --preview 'paru -Sii {1}' --preview-window=down:75% | xargs -ro paru -S"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

fish_add_path /home/om/.spicetify

# Created by `pipx` on 2025-04-15 18:45:56
set PATH $PATH /home/om/.local/bin

set -x WLR_DRM_DEVICES /dev/dri/card0
set -x LIBVA_DRIVER_NAME iHD
set -x DRI_PRIME 0
set -x WLR_RENDERER vulkan
set -x WLR_NO_HARDWARE_CURSORS 1

function nvo
    env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia $argv
end

function lfcd
    # Start lf in the background
    lf $argv &

    # Save PID
    set -l lf_pid $last_pid

    # Give lf a moment to start
    sleep 0.1

    # Start ctpv in server mode
    ctpv -s -r &

    # Wait for lf to exit
    wait $lf_pid

    # Kill ctpv when lf closes
    pkill -TERM -f ctpv
end

zoxide init fish | source

# opencode
fish_add_path /home/om/.opencode/bin
