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
abbr -a t "tmux"
abbr -a v "vim"
abbr -a vv "vim ~/.dotfiles/vim/vimrc.symlink"
abbr -a p "pbcopy"
abbr -a dc "docker compose"
abbr -a cat "bat"
# abbr -a ll "exa"
# abbr -a ls "exa"
abbr -a l "exa"
abbr -a sizes "du -h -a | sort -k1 -rh"
# abbr -a gcam "git commit -a -m --no-edit"
abbr -a kali "docker run -ti -v (pwd):/app -w /app --name=kali --rm  --security-opt 'seccomp=unconfined' --cap-add=SYS_PTRACE kali /usr/bin/zsh"
abbr -a la "exa -la"
abbr -a gfu "git branch --set-upstream-to=origin/$(git rev-parse --abbrev-ref HEAD)"
abbr -a gprpf "git pull --rebase && git push --force-with-lease"
abbr -a gcs "gh copilot suggest"
abbr -a gce "gh copilot explain"

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

############### Tools ################

# activate rbenv
if test (which rbenv)
  status --is-interactive; and source (rbenv init -|psub)
end

# add brew to fish path if it's not there
for bindir in /usr/local/bin /opt/homebrew/bin
    if test -d $bindir; and not contains $bindir $PATH
      fish_add_path -p $bindir
      eval (brew shellenv)
    end
end
contains $HOME/.local/bin $PATH; or set PATH $HOME/.local/bin $PATH

# custom conda initialization
for conda_bin in /opt/homebrew/Caskroom/miniconda/base/bin/conda /usr/local/Caskroom/miniconda/base/bin/conda
    if test -f $conda_bin
      eval $conda_bin "shell.fish" "hook" | source
    end
end

# flutter
contains $HOME/dev/personal/flutter/flutter/bin $PATH; or set PATH $HOME/dev/personal/flutter/flutter/bin $PATH

# latest Ruby version and gems
fish_add_path /opt/homebrew/opt/ruby/bin
fish_add_path /opt/homebrew/lib/ruby/gems/3.3.0/bin