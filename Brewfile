# Brewfile — packages to install on a new macOS machine.
# Apply with: brew bundle --file=~/sannonthachai/dotfiles/Brewfile
# (install.sh runs this automatically on macOS.)

# --- Taps ---
tap "hudochenkov/sshpass" # sshpass isn't in homebrew-core (password-based SSH)
tap "hashicorp/tap"     # terraform isn't in homebrew-core (BSL license)

# --- CLI formulae ---
brew "fastfetch"        # system info splash
brew "fzf"              # fuzzy finder (vim ,b /,/  +  zsh ctrl-r)
brew "htop"             # process viewer
brew "ripgrep"          # rg — used by vim ,/  and rg helpers
brew "tmux"             # terminal multiplexer
brew "telnet"           # network debug
brew "vim"              # Homebrew vim (Apple's /usr/bin/vim has broken clipboard)
brew "go"               # Go toolchain
brew "node"             # required by coc.nvim, instant-markdown-d, claude-code CLI
brew "pass"             # password-store (gpg-backed CLI password manager)
brew "hudochenkov/sshpass/sshpass" # password-based SSH automation
brew "libpq"            # Postgres client (psql) — keg-only, link with --force
brew "pandoc"           # universal document converter
brew "typst"            # markup-based typesetting

# --- DevOps / containers ---
brew "colima"           # Docker runtime on macOS (Linux VM)
brew "docker"           # docker CLI
brew "docker-compose"   # compose v2 CLI plugin
brew "kubernetes-cli"   # kubectl
brew "helm"             # Helm 3
brew "k9s"              # K8s TUI
brew "hashicorp/tap/terraform" # Terraform CLI (BSL — via hashicorp/tap)
brew "argocd"           # ArgoCD CLI (GitOps deploys)

# --- GUI apps (casks) ---
cask "google-chrome"
cask "wezterm"          # primary terminal emulator
cask "visual-studio-code"
cask "obsidian"
cask "tableplus"        # multi-DB GUI (Postgres, MySQL, Redis, SQLite, MS SQL, Mongo)
cask "insomnia"         # REST/GraphQL API client
cask "discord"
cask "microsoft-teams"
cask "openvpn-connect"  # corp VPN client
cask "ngrok"            # tunnel local ports to public URLs
