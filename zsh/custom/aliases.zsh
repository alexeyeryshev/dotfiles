alias zs="source ~/.zshrc"

alias up="cd .."
alias up2="cd ../.."
alias up3="cd ../../.."

alias kc="kubectx"

# Git
alias ghw='gh run watch $(gh run list --limit 1 --json databaseId -u alexeyeryshev --jq ".[0].databaseId")'
alias ghpw='gh pr view'
alias gt='git for-each-ref --sort=creatordate --format '\''%(refname) %(creatordate)'\'' refs/tags | sed '\''s/refs\/tags\///'\'' | tail'
alias gcm='git commit -m'