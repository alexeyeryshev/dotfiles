# proprietary config
if test -f ~/.config/fish/functions/proprietary_config.fish
  proprietary_config
end

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
abbr -a gpf "git push --force-with-lease"

abbr -a tm "tmux -u"
abbr -a v "vim"
abbr -a vv "vim ~/.dotfiles/vim/vimrc.symlink"
abbr -a p "pbcopy"
abbr -a dc "docker compose"
abbr -a sizes "du -h -a | sort -k1 -rh"

abbr -a k "kubectl"
abbr -a kc "kubectx"
abbr -a gt "gt='git for-each-ref --sort=creatordate --format '\''%(refname) %(creatordate)'\'' refs/tags | sed '\''s/refs\/tags\///'\'' | tail'"


function fkill -d "Kill processes with fzf"
  eval "ps aux | grep $USER | fzf --header (ps aux | head -1) --query (commandline)" | read select

  if not test -z $select
    eval "echo -n \"$select\" | awk '{ print \$2 }'" | read pid

    if kill -0 $pid
      kill -9 $pid
    end
  end
end

function unswap
  file = $1
  echo removing $file
end

function up -d 'Travel up any number of directories'
    test -n "$argv" || set argv "1"
    set -l balloons (string repeat -n "$argv[1]" "../" 2>/dev/null) || begin
        echo "Invalid arguments '$argv'"\n"Usage: "(status function)" <levels>" >&2
        return 2
    end
    cd $balloons
end

function upp --description 'Get the path of an ancestor directory'
    test -n "$argv" || set argv 1
    set pathname $PWD/(string repeat -n "$argv[1]" ../ 2>/dev/null)
    realpath $pathname
end

function gpr
  set cmd "git add --all && git commit -am '$argv[1]' && git push"
  echo $cmd
  eval $cmd
end


function ve
    set venv_dir (find . -type d -name "*venv*" | head -n 1)
    if test -n "$venv_dir"
        source "$venv_dir/bin/activate.fish"
        echo "Activated virtual environment at $venv_dir"
    else
        echo "No virtual environment directory found."
    end
end

############### Tools ################

# activate rbenv
if test (which rbenv)
  status --is-interactive; and source (rbenv init -|psub)
end

# add brew to fish path if it's not there
fish_add_path $HOME/homebrew/bin
fish_add_path $HOME/homebrew/sbin
fish_add_path /opt/homebrew/bin

# activate uv
source $HOME/.local/bin/env.fish