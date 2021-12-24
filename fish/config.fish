# proprietary config
proprietary_config

# mix emacs and vim keybindings
fish_hybrid_key_bindings

# add fzf keybindings
fzf_key_bindings

set -g theme_date_format +"%d-%m-%Y %H:%M:%S"
set -g theme_display_date no
# configure bobthefish for huge git repos
set -g theme_display_git_dirty no
set -g theme_display_git_untracked no
set -g theme_display_git_ahead_verbose no
set -g theme_display_git_dirty_verbose no
set -g theme_display_git_stashed_verbose no
set -g theme_display_git_master_branch no
# disable renv and venv strings
set -g theme_display_ruby yes
set -g theme_display_virtualenv yes
# cursor on a new line
set -g theme_newline_cursor yes

# abbr
abbr -a gu "git add -A && git commit -a -m 'update' && git push"
abbr -a gpf "git push --force"
abbr -a gpr "gpr"
abbr -a l "ll -a"
abbr -a t "tmux"
abbr -a v "vim"
abbr -a vv "vim ~/.dotfiles/vim/vimrc.symlink"
abbr -a p "pbcopy"
abbr -a dc "docker compose"
# abbr -a gcam "git commit -a -m --no-edit"

# functions
function fkill
  set pid (ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if test "x$pid" != "x"
    xargs kill $pid
  end
end

function unswap
  file = $1
  echo removing $file
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /usr/local/Caskroom/miniconda/base/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

# activate rbenv
status --is-interactive; and source (rbenv init -|psub)

# Rust
set PATH $HOME/.cargo/bin $PATH

# Poetry (Python dependency management tool)
set PATH /Users/alexey_eryshev/.local/bin $PATH

# Set vim for fish
set -gx EDITOR code

