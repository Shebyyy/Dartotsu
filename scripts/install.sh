set -e

OWNER='aayush2622'
REPO='Dartotsu'
APP_NAME='Dartotsu'

INSTALL_DIR="$HOME/.local/share/$APP_NAME"
LINK="$HOME/.local/bin/$APP_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"
ICON_FILE="$HOME/.local/share/icons/$APP_NAME.png"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

GRAD1='\033[38;5;30m'
GRAD2='\033[38;5;36m'
GRAD3='\033[38;5;42m'
GRAD4='\033[38;5;48m'
GRAD5='\033[38;5;51m'
GRAD6='\033[38;5;87m'

ICON_FIRE="🔥"
ICON_LIGHTNING="⚡"
ICON_STAR="⭐"
ICON_DIAMOND="💎"
ICON_BOMB="💣"
ICON_SKULL="💀"
ICON_ROBOT="🤖"
ICON_ALIEN="👽"
ICON_GHOST="👻"
ICON_MAGIC="🪄"
ICON_CRYSTAL="🔮"
ICON_SWORD="⚔️"
ICON_SHIELD="🛡️"
ICON_CROWN="👑"
ICON_COMET="☄️"
ICON_GALAXY="🌌"

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [${CYAN}%c${RESET}]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    local color=""
    if [ $percentage -lt 25 ]; then
        color="${RED}"
    elif [ $percentage -lt 50 ]; then
        color="${YELLOW}"
    elif [ $percentage -lt 75 ]; then
        color="${CYAN}"
    else
        color="${GREEN}"
    fi

    printf "\r${BOLD}${ICON_LIGHTNING} Progress: ${RESET}["
    printf "${color}%*s${RESET}" $filled | tr ' ' '█'
    printf "${GRAY}%*s${RESET}" $empty | tr ' ' '░'
    printf "] ${BOLD}${color}%d%%${RESET} ${ICON_FIRE}" $percentage
}

compare_commits() {
    local main_repo="aayush2622/Dartotsu"
    local alpha_repo="grayankit/Dartotsu-Downloader"

    echo
    echo -ne "${CYAN}${ICON_ROBOT}${RESET} ${BOLD}Initiating quantum commit analysis${RESET}"
    for i in {1..5}; do
        sleep 0.3
        echo -ne "${CYAN}.${RESET}"
    done
    echo -e " ${GREEN}${ICON_LIGHTNING}${RESET}"

    echo -e "${GREEN}${DIM}> Accessing GitHub API...${RESET}"
    sleep 0.5
    echo -e "${GREEN}${DIM}> Scanning commit trees...${RESET}"
    sleep 0.5
    echo -e "${GREEN}${DIM}> Cross-referencing SHA hashes...${RESET}"
    sleep 0.5

    local response=$(curl -s "https://api.github.com/repos/${main_repo}/commits?per_page=1")
    local main_commit=$(echo "$response" | grep '"sha"' | head -1 | cut -d'"' -f4 | cut -c1-7)
    local main_date=$(echo "$response" | grep -A 2 '"date"' | tail -1 | cut -d'"' -f4)
    local main_author=$(echo "$response" |grep '"name"' | head -1 | cut -d '"' -f 4) 

    local alpha_release=$(curl -s "https://api.github.com/repos/${alpha_repo}/releases/latest")
    local alpha_tag=$(echo "$alpha_release" | grep '"tag_name"' | cut -d '"' -f 4)
    local alpha_date=$(echo "$alpha_release" | grep '"published_at"' | cut -d '"' -f 4)

    echo
    echo -e "${BOLD}${PURPLE}╔═══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${PURPLE}║${RESET}                    ${ICON_CRYSTAL} COMMIT MATRIX ${ICON_CRYSTAL}                    ${PURPLE}${BOLD}║${RESET}"
    echo -e "${BOLD}${PURPLE}╠═══════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${BOLD}${PURPLE}║${RESET}                                                         ${PURPLE}${BOLD}║${RESET}"
    echo -e "${BOLD}${PURPLE}║${RESET} ${ICON_GALAXY} ${BOLD}MAIN REPOSITORY${RESET} ${GRAY}(${main_repo})${RESET}          ${PURPLE}${BOLD}║${RESET}"
    echo -e "${BOLD}${PURPLE}║${RESET}   ${ICON_DIAMOND} Commit SHA: ${YELLOW}${BOLD}${main_commit}${RESET}                           ${PURPLE}${BOLD}║${RESET}"
    echo -e "${BOLD}${PURPLE}║${RESET}   ${ICON_STAR} Author: ${CYAN}${main_author}${RESET}                              ${PURPLE}${BOLD}║${RESET}"
    echo -e "${BOLD}${PURPLE}║${RESET}   ${ICON_COMET} Timestamp: ${GRAY}$(date -d "$main_date" '+%Y-%m-%d %H:%M:%S UTC')${RESET}  ${PURPLE}${BOLD}║${RESET}"
    echo -e "${BOLD}${PURPLE}║${RESET}                                                         ${PURPLE}${BOLD}║${RESET}"
    echo -e "${BOLD}${PURPLE}║${RESET} ${ICON_ALIEN} ${BOLD}ALPHA REPOSITORY${RESET} ${GRAY}(${alpha_repo})${RESET} ${PURPLE}${BOLD}║${RESET}"
    echo -e "${BOLD}${PURPLE}║${RESET}   ${ICON_BOMB} Release Tag: ${PURPLE}${BOLD}${alpha_tag}${RESET}                            ${PURPLE}${BOLD}║${RESET}"
    echo -e "${BOLD}${PURPLE}║${RESET}   ${ICON_GHOST} Published: ${GRAY}$(date -d "$alpha_date" '+%Y-%m-%d %H:%M:%S UTC')${RESET}    ${PURPLE}${BOLD}║${RESET}"
    echo -e "${BOLD}${PURPLE}║${RESET}                                                         ${PURPLE}${BOLD}║${RESET}"

    if [[ "$alpha_tag" == *"$main_commit"* ]]; then
        echo -e "${BOLD}${PURPLE}║${RESET}   ${ICON_MAGIC} SYNC STATUS: ${GREEN}${BOLD}${ICON_FIRE} PERFECTLY SYNCHRONIZED ${ICON_FIRE}${RESET}   ${PURPLE}${BOLD}║${RESET}"
        echo -e "${BOLD}${PURPLE}║${RESET}   ${GREEN}${ICON_LIGHTNING} Repositories are in perfect harmony! ${ICON_LIGHTNING}${RESET}           ${PURPLE}${BOLD}║${RESET}"
    else
        echo -e "${BOLD}${PURPLE}║${RESET}   ${ICON_CRYSTAL} SYNC STATUS: ${YELLOW}${BOLD}${ICON_SWORD} DIVERGED TIMELINES ${ICON_SWORD}${RESET}     ${PURPLE}${BOLD}║${RESET}"
        echo -e "${BOLD}${PURPLE}║${RESET}   ${YELLOW}${ICON_SKULL} Alpha may contain different features ${ICON_SKULL}${RESET}            ${PURPLE}${BOLD}║${RESET}"
    fi

    echo -e "${BOLD}${PURPLE}║${RESET}                                                         ${PURPLE}${BOLD}║${RESET}"
    echo -e "${BOLD}${PURPLE}╚═══════════════════════════════════════════════════════════════╝${RESET}"
    echo

    echo -ne "${BOLD}${CYAN}Preparing alpha download in: ${RESET}"
    for i in 3 2 1; do
        echo -ne "${RED}${BOLD}$i${RESET}"
        sleep 0.8
        echo -ne "\b \b"
    done
    echo -e "${GREEN}${BOLD}GO! ${ICON_ROCKET}${RESET}"
    echo
}

type_text() {
    local text="$1"
    local delay=${2:-0.03}
    for ((i=0; i<${#text}; i++)); do
        printf "${text:$i:1}"
        sleep $delay
    done
    echo
}

show_banner() {
    clear
    echo
    for i in {1..3}; do
        echo -e "${GRAD1}════════════════════════════════════════════════════════════════════════${RESET}"
        sleep 0.05
        printf "\033[1A\033[K"
    done

    echo -e "${GRAD1}  ██████╗  █████╗ ██████╗ ████████╗ ██████╗ ████████╗███████╗██╗   ██╗${RESET}"
    echo -e "${GRAD2}  ██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗╚══██╔══╝██╔════╝██║   ██║${RESET}"
    echo -e "${GRAD3}  ██║  ██║███████║██████╔╝   ██║   ██║   ██║   ██║   ███████╗██║   ██║${RESET}"
    echo -e "${GRAD4}  ██║  ██║██╔══██║██╔══██╗   ██║   ██║   ██║   ██║   ╚════██║██║   ██║${RESET}"
    echo -e "${GRAD5}  ██████╔╝██║  ██║██║  ██║   ██║   ╚██████╔╝   ██║   ███████║╚██████╔╝${RESET}"
    echo -e "${GRAD6}  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝    ╚═╝   ╚══════╝ ╚═════╝ ${RESET}"
    echo
    echo -e "${CYAN}${BOLD}                 ${ICON_FIRE}${ICON_LIGHTNING} The Ultimate Anime & Manga Experience ${ICON_LIGHTNING}${ICON_FIRE}${RESET}"
    echo -e "${GRAY}                    ═══════════════════════════════════════${RESET}"
    echo -e "${PURPLE}${DIM}                           ${ICON_GALAXY} Powered by Dreams ${ICON_GALAXY}${RESET}"
    echo
}

section_header() {
    local title="$1"
    local icon="$2"
    echo
    echo -e "${BOLD}${BLUE}╭─────────────────────────────────────────────────────╮${RESET}"
    echo -e "${BOLD}${BLUE}│${RESET} ${icon} ${BOLD}${WHITE}${title}${RESET} ${BLUE}│${RESET}"
    echo -e "${BOLD}${BLUE}╰─────────────────────────────────────────────────────╯${RESET}"
    echo
}

success_msg() {
    local msg="$1"
    echo
    echo -e "${GREEN}${BOLD}┌─ SUCCESS! ─────────────────────────────────────────┐${RESET}"
    echo -e "${GREEN}${BOLD}│${RESET} ${ICON_SUCCESS} ${msg} ${GREEN}${BOLD}│${RESET}"
    echo -e "${GREEN}${BOLD}└────────────────────────────────────────────────────┘${RESET}"
    echo
}

error_msg() {
    local msg="$1"
    echo
    echo -e "${RED}${BOLD}┌─ ERROR! ───────────────────────────────────────────┐${RESET}"
    echo -e "${RED}${BOLD}│${RESET} ${ICON_ERROR} ${msg} ${RED}${BOLD}│${RESET}"
    echo -e "${RED}${BOLD}└────────────────────────────────────────────────────┘${RESET}"
    echo
}

info_msg() {
    local msg="$1"
    echo -e "${CYAN}${ICON_INFO}${RESET} ${msg}"
}

warn_msg() {
    local msg="$1"
    echo -e "${YELLOW}${ICON_WARNING}${RESET} ${msg}"
}

show_menu() {
    echo -e "${GRAD1}█${GRAD2}█${GRAD3}█${GRAD4}█${GRAD5}█${GRAD6}█${RESET} ${BOLD}DARTOTSU CONTROL PANEL${RESET} ${GRAD6}█${GRAD5}█${GRAD4}█${GRAD3}█${GRAD2}█${GRAD1}█${RESET}"
    echo
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}                                                     ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}  ${ICON_ROBOT} ${GREEN}${BOLD}[I]${RESET} ${ICON_DOWNLOAD} Install Dartotsu ${GRAY}(Get Started)${RESET}      ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}      ${GREEN}Deploy the ultimate anime experience${RESET}        ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}                                                     ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}  ${ICON_LIGHTNING} ${YELLOW}${BOLD}[U]${RESET} ${ICON_UPDATE} Update Dartotsu ${GRAY}(Stay Current)${RESET}     ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}      ${YELLOW}Upgrade to the latest and greatest${RESET}         ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}                                                     ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}  ${ICON_BOMB} ${RED}${BOLD}[R]${RESET} ${ICON_UNINSTALL} Remove Dartotsu ${GRAY}(Nuclear Option)${RESET}   ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}      ${RED}Complete annihilation of installation${RESET}       ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}                                                     ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}  ${ICON_GHOST} ${CYAN}${BOLD}[Q]${RESET} ${ICON_SPARKLES} Quit ${GRAY}(Escape the Matrix)${RESET}            ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}      ${CYAN}Return to the real world${RESET}                   ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}                                                     ${CYAN}${BOLD}║${RESET}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -ne "${BOLD}${WHITE}Enter the matrix${RESET} ${GRAY}(I/U/R/Q)${RESET} ${ICON_MAGIC}: "
}

version_menu() {
    echo
    for char in "V" "E" "R" "S" "I" "O" "N" " " "S" "E" "L" "E" "C" "T" "I" "O" "N"; do
        echo -ne "${BOLD}${PURPLE}$char${RESET}"
        sleep 0.05
    done
    echo
    echo

    echo -e "${BOLD}${GRAD2}╔═══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${GRAD2}║${RESET}                                                     ${GRAD2}${BOLD}║${RESET}"
    echo -e "${BOLD}${GRAD2}║${RESET}  ${ICON_CROWN} ${GREEN}${BOLD}[S]${RESET} Stable Release ${GRAY}(Battle-Tested)${RESET}         ${GRAD2}${BOLD}║${RESET}"
    echo -e "${BOLD}${GRAD2}║${RESET}      ${ICON_SHIELD} Rock solid, enterprise ready            ${GRAD2}${BOLD}║${RESET}"
    echo -e "${BOLD}${GRAD2}║${RESET}                                                     ${GRAD2}${BOLD}║${RESET}"
    echo -e "${BOLD}${GRAD2}║${RESET}  ${ICON_LIGHTNING} ${YELLOW}${BOLD}[P]${RESET} Pre-release ${GRAY}(Bleeding Edge)${RESET}          ${GRAD2}${BOLD}║${RESET}"
    echo -e "${BOLD}${GRAD2}║${RESET}      ${ICON_FIRE} Latest features, some bugs possible     ${GRAD2}${BOLD}║${RESET}"
    echo -e "${BOLD}${GRAD2}║${RESET}                                                     ${GRAD2}${BOLD}║${RESET}"
    echo -e "${BOLD}${GRAD2}║${RESET}  ${ICON_BOMB} ${PURPLE}${BOLD}[A]${RESET} Alpha Build ${GRAY}(Danger Zone!)${RESET}            ${GRAD2}${BOLD}║${RESET}"
    echo -e "${BOLD}${GRAD2}║${RESET}      ${ICON_SKULL} Experimental, use at your own risk     ${GRAD2}${BOLD}║${RESET}"
    echo -e "${BOLD}${GRAD2}║${RESET}                                                     ${GRAD2}${BOLD}║${RESET}"
    echo -e "${BOLD}${GRAD2}╚═══════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -ne "${BOLD}${WHITE}Choose your destiny${RESET} ${GRAY}(S/P/A)${RESET} ${ICON_MAGIC}: "
}

detect_shell_rc() {
  local shell_name
  shell_name=$(basename "$SHELL")
  case "$shell_name" in
    bash) echo "$HOME/.bashrc" ;;
    zsh) echo "$HOME/.zshrc" ;;
    fish) echo "$HOME/.config/fish/config.fish" ;;
    *) echo "$HOME/.profile" ;;
  esac
}

add_updater_alias() {
  local shell_rc
  shell_rc=$(detect_shell_rc)
  local alias_line="alias dartotsu-updater='bash <(curl -s https://raw.githubusercontent.com/aayush2622/Dartotsu/main/scripts/install.sh) update'"

  if grep -Fxq "$alias_line" "$shell_rc" 2>/dev/null; then
    echo -ne "${YELLOW}${ICON_WARNING}${RESET} The 'dartotsu-updater' alias already exists in your shell config file ($(basename "$shell_rc")). Would you like to remove it? [y/N]: "
    read -r remove_response
    case "$remove_response" in
      [yY][eE][sS]|[yY])
        sed -i "\|$alias_line|d" "$shell_rc"
        echo -e " ${GREEN}${ICON_SUCCESS} Alias removed from $(basename "$shell_rc")${RESET}"
        ;;
      *)
        echo -e " ${CYAN}${ICON_INFO} Keeping existing alias.${RESET}"
        ;;
    esac
  else
    echo -ne "${CYAN}${ICON_MAGIC}${RESET} Would you like to add the 'dartotsu-updater' alias to your shell config file ($(basename "$shell_rc"))? [y/N]: "
    read -r add_response
    case "$add_response" in
      [yY][eE][sS]|[yY])
        echo "$alias_line" >> "$shell_rc"
        echo -e " ${GREEN}${ICON_SUCCESS} Alias added to $(basename "$shell_rc")${RESET}"
        info_msg "You can now run '${BOLD}dartotsu-updater${RESET}' to update anytime!"
        info_msg "Run '${BOLD}source $shell_rc${RESET}' or restart your terminal to activate the alias"
        ;;
      *)
        echo -e " ${YELLOW}${ICON_WARNING} Skipped adding alias${RESET}"
        ;;
    esac
  fi
}

is_containerized() {
    [ -f /.dockerenv ] || [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]
}

check_dependencies() {
    local missing_deps=()
    local optional_deps=()

    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
    command -v unzip >/dev/null 2>&1 || missing_deps+=("unzip")
    command -v wget >/dev/null 2>&1 || missing_deps+=("wget")
    command -v mpv >/dev/null 2>&1 || missing_deps+=("mpv")

    command -v git >/dev/null 2>&1 || optional_deps+=("git")

    if command -v pkg-config >/dev/null 2>&1; then
        pkg-config --exists gtk+-3.0 2>/dev/null || missing_deps+=("gtk3")

        local has_wpe=false
        if pkg-config --exists wpe-webkit-2.0 2>/dev/null; then
            has_wpe=true
        elif pkg-config --exists wpe-webkit-1.1 2>/dev/null; then
            has_wpe=true
        elif pkg-config --exists wpe-webkit-1.0 2>/dev/null; then
            has_wpe=true
        fi

        if [ "$has_wpe" = false ]; then
            if pkg-config --exists webkit2gtk-4.1 2>/dev/null; then
                info_msg "WPE WebKit not found, but WebKit2GTK 4.1 is available (legacy support)"
            elif pkg-config --exists libwebkit2gtk-4.1-0 2>/dev/null; then
                info_msg "WPE WebKit not found, but WebKit2GTK 4.1 is available (legacy support)"
            else
                missing_deps+=("wpewebkit")
            fi
        fi

        if [ "$has_wpe" = true ]; then
            pkg-config --exists wpe-1.0 2>/dev/null || missing_deps+=("libwpe")

            local has_wpe_backend=false
            if pkg-config --exists wpe-platform-2.0 2>/dev/null; then
                has_wpe_backend=true
            elif pkg-config --exists wpebackend-fdo-1.0 2>/dev/null; then
                has_wpe_backend=true
                info_msg "Using WPEBackend-FDO (legacy) - wpe-platform-2.0 is recommended"
            fi

            if [ "$has_wpe_backend" = false ]; then
                missing_deps+=("wpebackend")
            fi
        fi

        if [ "$has_wpe" = true ]; then
            pkg-config --exists epoxy 2>/dev/null || missing_deps+=("libepoxy")
        fi

        if [ "$has_wpe" = true ]; then
            pkg-config --exists wayland-server 2>/dev/null || missing_deps+=("wayland-server")
        fi

        pkg-config --exists mpv 2>/dev/null || missing_deps+=("libmpv")

        pkg-config --exists libsecret-1 2>/dev/null || missing_deps+=("libsecret")

        pkg-config --exists libass 2>/dev/null || optional_deps+=("libass")
    else
        missing_deps+=("pkg-config" "gtk3" "wpewebkit" "libmpv" "libsecret")
    fi

    if ! command -v xdg-open >/dev/null 2>&1; then
        optional_deps+=("xdg-utils")
    fi

    if [ ! -e /dev/fuse ] && ! command -v fusermount >/dev/null 2>&1; then
        optional_deps+=("fuse")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        warn_msg "Missing required dependencies: ${missing_deps[*]}"

        if [ ${#optional_deps[@]} -ne 0 ]; then
            info_msg "Optional dependencies not found: ${optional_deps[*]}"
        fi

        echo
        if is_containerized; then
            info_msg "Container environment detected - attempting automatic installation..."
            export DEBIAN_FRONTEND=noninteractive
            install_packages "${missing_deps[@]}"
        else
            echo -e "${YELLOW}${BOLD}Would you like to install required dependencies automatically?${RESET} ${GRAY}(y/N)${RESET}: "
            read -rn 1 INSTALL_DEPS
            echo

            if [[ "${INSTALL_DEPS,,}" == "y" ]]; then
                install_packages "${missing_deps[@]}"
            else
                error_exit "Required dependencies must be installed to continue: ${missing_deps[*]}"
            fi
        fi
    elif [ ${#optional_deps[@]} -ne 0 ]; then
        info_msg "Optional dependencies not found: ${optional_deps[*]}"
        echo -e "${GRAY}These are not required but may provide additional functionality.${RESET}"
    else
        info_msg "All dependencies are satisfied!"
    fi
}

install_packages() {
    local deps=("$@")
    local install_cmd=""
    local update_cmd=""
    local distro=""

    if command -v apt >/dev/null 2>&1; then
        distro="debian"
        update_cmd="sudo apt update -y"
        install_cmd="sudo apt install -y"

        deps=("${deps[@]/webkit2gtk/libwebkit2gtk-4.1-0}")
        deps=("${deps[@]/gtk3/libgtk-3-dev}")
        deps=("${deps[@]/pkg-config/pkg-config}")
        deps=("${deps[@]/libmpv/libmpv-dev}")
        deps=("${deps[@]/libsecret/libsecret-1-dev}")
        deps=("${deps[@]/libass/libass-dev}")
        deps=("${deps[@]/xdg-utils/xdg-utils}")
        deps=("${deps[@]/fuse/fuse3}")
        deps=("${deps[@]/wpewebkit/libwpewebkit-2.0-dev}")
        deps=("${deps[@]/libwpe/libwpe-1.0-dev}")
        deps=("${deps[@]/wpebackend/wpebackend-fdo-1.0-dev}")
        deps=("${deps[@]/libepoxy/libepoxy-dev}")
        deps=("${deps[@]/wayland-server/libwayland-dev}")

    elif command -v dnf >/dev/null 2>&1; then
        distro="fedora"
        install_cmd="sudo dnf install -y"

        deps=("${deps[@]/webkit2gtk/webkit2gtk4.1-0}")
        deps=("${deps[@]/gtk3/gtk3-devel}")
        deps=("${deps[@]/pkg-config/pkgconf-devel}")
        deps=("${deps[@]/libmpv/mpv-libs-devel}")
        deps=("${deps[@]/libsecret/libsecret-devel}")
        deps=("${deps[@]/libass/libass-devel}")
        deps=("${deps[@]/xdg-utils/xdg-utils}")
        deps=("${deps[@]/fuse/fuse3}")
        deps=("${deps[@]/wpewebkit/wpewebkit-devel}")
        deps=("${deps[@]/libwpe/libwpe-devel}")
        deps=("${deps[@]/wpebackend/wpebackend-fdo-devel}")
        deps=("${deps[@]/libepoxy/libepoxy-devel}")
        deps=("${deps[@]/wayland-server/wayland-devel}")

    elif command -v pacman >/dev/null 2>&1; then
        distro="arch"
        update_cmd="sudo pacman -Sy"
        install_cmd="sudo pacman -S --noconfirm"

        deps=("${deps[@]/webkit2gtk/webkit2gtk-4.1}")
        deps=("${deps[@]/gtk3/gtk3}")
        deps=("${deps[@]/pkg-config/pkgconf}")
        deps=("${deps[@]/libmpv/mpv}")
        deps=("${deps[@]/libsecret/libsecret}")
        deps=("${deps[@]/libass/libass}")
        deps=("${deps[@]/xdg-utils/xdg-utils}")
        deps=("${deps[@]/fuse/fuse3}")
        deps=("${deps[@]/wpewebkit/wpewebkit}")
        deps=("${deps[@]/libwpe/libwpe}")
        deps=("${deps[@]/wpebackend/wpebackend-fdo}")
        deps=("${deps[@]/libepoxy/libepoxy}")
        deps=("${deps[@]/wayland-server/wayland}")

    elif command -v zypper >/dev/null 2>&1; then
        distro="opensuse"
        install_cmd="sudo zypper install -y"

        deps=("${deps[@]/webkit2gtk/webkit2gtk3-devel}")
        deps=("${deps[@]/gtk3/gtk3-devel}")
        deps=("${deps[@]/pkg-config/pkg-config}")
        deps=("${deps[@]/libmpv/libmpv-devel}")
        deps=("${deps[@]/libsecret/libsecret-devel}")
        deps=("${deps[@]/libass/libass-devel}")
        deps=("${deps[@]/xdg-utils/xdg-utils}")
        deps=("${deps[@]/fuse/fuse3}")
        deps=("${deps[@]/wpewebkit/wpewebkit-devel}")
        deps=("${deps[@]/libwpe/libwpe-devel}")
        deps=("${deps[@]/wpebackend/wpebackend-fdo-devel}")
        deps=("${deps[@]/libepoxy/libepoxy-devel}")
        deps=("${deps[@]/wayland-server/wayland-devel}")

    elif command -v brew >/dev/null 2>&1; then
        distro="macos"
        install_cmd="brew install"

        deps=("${deps[@]/webkit2gtk/}")
        deps=("${deps[@]/gtk3/gtk+3}")
        deps=("${deps[@]/pkg-config/pkg-config}")
        deps=("${deps[@]/libmpv/mpv}")
        deps=("${deps[@]/libsecret/}")
        deps=("${deps[@]/libass/libass}")
        deps=("${deps[@]/xdg-utils/}")
        deps=("${deps[@]/fuse/}")
        deps=("${deps[@]/wpewebkit/}")
        deps=("${deps[@]/libwpe/}")
        deps=("${deps[@]/wpebackend/}")
        deps=("${deps[@]/libepoxy/}")
        deps=("${deps[@]/wayland-server/}")

    else
        error_exit "No supported package manager found! Please install manually: ${deps[*]}"
    fi

    local filtered_deps=()
    for dep in "${deps[@]}"; do
        [[ -n "$dep" ]] && filtered_deps+=("$dep")
    done
    deps=("${filtered_deps[@]}")

    if [ ${#deps[@]} -eq 0 ]; then
        info_msg "No packages to install for this system."
        return 0
    fi

    info_msg "Detected system: $distro"
    info_msg "Installing packages: ${deps[*]}"

    if [ -n "$update_cmd" ]; then
        echo -ne "${CYAN}${ICON_INSTALL}${RESET} Updating package lists..."
        if eval "$update_cmd" >/dev/null 2>&1; then
            echo -e " ${GREEN}${ICON_SUCCESS}${RESET}"
        else
            echo -e " ${YELLOW}${ICON_WARNING} Update failed, continuing...${RESET}"
        fi
    fi

    echo -ne "${CYAN}${ICON_INSTALL}${RESET} Installing dependencies..."

    if eval "$install_cmd ${deps[*]}" >/dev/null 2>&1; then
        echo -e " ${GREEN}${ICON_SUCCESS} Done!${RESET}"
        info_msg "Dependencies installed successfully!"
    else
        echo -e " ${RED}${ICON_ERROR} Failed!${RESET}"

        warn_msg "Attempting to install packages individually..."
        local failed_packages=()

        for pkg in "${deps[@]}"; do
            echo -ne "  Installing $pkg..."
            if eval "$install_cmd $pkg" >/dev/null 2>&1; then
                echo -e " ${GREEN}${ICON_SUCCESS}${RESET}"
            else
                echo -e " ${RED}${ICON_ERROR}${RESET}"
                failed_packages+=("$pkg")
            fi
        done

        if [ ${#failed_packages[@]} -ne 0 ]; then
            error_exit "Failed to install: ${failed_packages[*]}. Please install manually."
        fi
    fi
}

verify_installation() {
    local critical_deps=("curl" "unzip" "wget")
    local failed_deps=()

    for dep in "${critical_deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            failed_deps+=("$dep")
        fi
    done

    if [ ${#failed_deps[@]} -ne 0 ]; then
        error_exit "Critical dependencies still missing after installation: ${failed_deps[*]}"
    fi

    if command -v pkg-config >/dev/null 2>&1; then
        local has_webview=false
        if pkg-config --exists wpe-webkit-2.0 2>/dev/null || \
           pkg-config --exists wpe-webkit-1.1 2>/dev/null || \
           pkg-config --exists wpe-webkit-1.0 2>/dev/null; then
            has_webview=true
            info_msg "WPE WebKit detected - new webview backend"
        elif pkg-config --exists webkit2gtk-4.1 2>/dev/null || \
             pkg-config --exists webkit2gtk-3.0 2>/dev/null; then
            has_webview=true
            warn_msg "Only WebKit2GTK found - consider installing WPE WebKit for better performance"
        fi

        if [ "$has_webview" = false ]; then
            warn_msg "No webview library found - the app may not display web content"
        fi

        if ! pkg-config --exists mpv 2>/dev/null; then
            warn_msg "libmpv not found - video playback will not work"
        fi
        if ! pkg-config --exists gtk+-3.0 2>/dev/null; then
            warn_msg "GTK3 not found - the app may fail to launch"
        fi
        if ! pkg-config --exists libsecret-1 2>/dev/null; then
            warn_msg "libsecret not found - credential storage may not work"
        fi
    fi

    if ! command -v mpv >/dev/null 2>&1; then
        warn_msg "mpv not found - media playback features may be limited"
    fi

    info_msg "Installation verification completed!"
}

find_linux_zip_asset() {
    local _owner="$1"
    local _repo="$2"
    local _max_pages="${3:-5}"

    info_msg "Searching for Linux build in ${BOLD}${_owner}/${_repo}${RESET} releases..."

    for _page in $(seq 1 "$_max_pages"); do
        local _api_url="https://api.github.com/repos/${_owner}/${_repo}/releases?per_page=10&page=${_page}"
        local _response
        _response=$(curl -s "$_api_url")

        if [ -z "$_response" ] || echo "$_response" | grep -q '"message"'; then
            break
        fi

        local _release_count
        _release_count=$(echo "$_response" | grep -c '"tag_name"' || true)

        if [ "$_release_count" -eq 0 ]; then
            break
        fi

        local _tags
        _tags=$(echo "$_response" | grep '"tag_name"' | cut -d '"' -f 4)

        local _linux_urls
        _linux_urls=$(echo "$_response" | grep '"browser_download_url"' | cut -d '"' -f 4 | grep -i 'linux.*\.zip\|linuxzip\|_linux_\?\.zip')

        if [ -n "$_linux_urls" ]; then
            local _found_url
            _found_url=$(echo "$_linux_urls" | head -n 1)
            local _found_tag
            _found_tag=$(echo "$_tags" | head -n 1)
            info_msg "Found Linux build in release ${BOLD}${_found_tag}${RESET}!"
            echo "$_found_url"
            return 0
        fi

        warn_msg "No Linux build found on page ${_page}, checking previous releases..."
    done

    echo ""
    return 1
}

find_asset_with_fallback() {
    local _owner="$1"
    local _repo="$2"
    local _mode="$3"
    local _asset_url=""

    case "$_mode" in
        alpha)
            _asset_url=$(find_linux_zip_asset "$_owner" "$_repo" 5)
            ;;
        latest|prerelease|"")
            local _api_url="https://api.github.com/repos/${_owner}/${_repo}/releases/latest"
            if [ "$_mode" = "prerelease" ]; then
                _api_url="https://api.github.com/repos/${_owner}/${_repo}/releases?per_page=1"
            fi

            local _response
            _response=$(curl -s "$_api_url")

            _asset_url=$(echo "$_response" | grep '"browser_download_url"' | cut -d '"' -f 4 | grep -i 'linux.*\.zip\|linuxzip\|_linux_\?\.zip' | head -n 1)

            if [ -z "$_asset_url" ]; then
                warn_msg "Latest release has no Linux build, checking previous releases..."
                _asset_url=$(find_linux_zip_asset "$_owner" "$_repo" 5)
            fi
            ;;
    esac

    echo "$_asset_url"
}

error_exit() {
    error_msg "$1"
    echo -e "${GRAY}${DIM}Press any key to exit...${RESET}"
    read -rn 1
    exit 1
}

download_with_progress() {
    local url="$1"
    local output="$2"
    local filename=$(basename "$url")

    echo -ne "${CYAN}${ICON_DOWNLOAD}${RESET} Downloading ${BOLD}${filename}${RESET}..."

    curl -sL "$url" -o "$output" &
    local curl_pid=$!
    spinner $curl_pid
    wait $curl_pid
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo -e " ${GREEN}${ICON_SUCCESS} Done!${RESET}"
    else
        echo -e " ${RED}${ICON_ERROR} Failed!${RESET}"
        return 1
    fi
}

install_app() {
    section_header "INSTALLATION PROCESS" "${ICON_INSTALL}"

    info_msg "Checking system dependencies..."
    check_dependencies
    verify_installation
    echo -e "  ${GREEN}${ICON_SUCCESS} All dependencies verified!${RESET}"
    echo

    version_menu
    read -rn 1 ANSWER
    echo

case "${ANSWER,,}" in
    p)
        SELECTED_MODE="prerelease"
        info_msg "Fetching pre-release versions..."
        ;;
    a)
        OWNER="grayankit"
        REPO="Dartotsu-Downloader"
        SELECTED_MODE="alpha"
        info_msg "Fetching alpha build..."
        echo
        compare_commits
        ;;
    s|"")
        SELECTED_MODE="latest"
        info_msg "Fetching stable release..."
        ;;
    *)
        warn_msg "Invalid selection, defaulting to stable release..."
        SELECTED_MODE="latest"
        ;;
esac

    ASSET_URL=$(find_asset_with_fallback "$OWNER" "$REPO" "$SELECTED_MODE")

    if [ -z "$ASSET_URL" ]; then
        error_exit "No Linux build found in any release! Tried latest and previous releases."
    fi

    echo
    if ! download_with_progress "$ASSET_URL" "/tmp/$APP_NAME.zip"; then
        error_exit "Download failed!"
    fi

    echo
    info_msg "Installing to ${BOLD}$INSTALL_DIR${RESET}..."

    if [ -d "$INSTALL_DIR" ]; then
        warn_msg "Existing installation detected - removing old version..."
        rm -rf "$INSTALL_DIR"
    fi

    mkdir -p "$INSTALL_DIR"

    echo -ne "${CYAN}${ICON_INSTALL}${RESET} Extracting files..."
    if unzip "/tmp/$APP_NAME.zip" -d "$INSTALL_DIR" > /dev/null 2>&1; then
        echo -e " ${GREEN}${ICON_SUCCESS} Done!${RESET}"
    else
        echo -e " ${RED}${ICON_ERROR} Failed!${RESET}"
        error_exit "Failed to extract application files!"
    fi

    APP_EXECUTABLE="$(find "$INSTALL_DIR" -type f -executable -print -quit)"
    if [ -z "$APP_EXECUTABLE" ]; then
        error_exit "No executable found in the extracted files!"
    fi

    chmod +x "$APP_EXECUTABLE"

    mkdir -p "$HOME/.local/bin"
    ln -sf "$APP_EXECUTABLE" "$LINK"

    echo -ne "${CYAN}${ICON_DOWNLOAD}${RESET} Installing icon..."
    mkdir -p "$(dirname "$ICON_FILE")"
    fallback_icon_url='https://raw.githubusercontent.com/aayush2622/Dartotsu/main/assets/images/logo.png'
    if wget -q "$fallback_icon_url" -O "$ICON_FILE" 2>/dev/null; then
        echo -e " ${GREEN}${ICON_SUCCESS} Done!${RESET}"
    else
        echo -e " ${YELLOW}${ICON_WARNING} Icon download failed (non-critical)${RESET}"
    fi

    echo -ne "${CYAN}${ICON_INSTALL}${RESET} Creating desktop entry..."
    mkdir -p "$(dirname "$DESKTOP_FILE")"
    cat > "$DESKTOP_FILE" <<EOL
[Desktop Entry]
Name=$APP_NAME
Comment=The Ultimate Anime & Manga Experience
Exec=$LINK
Icon=$ICON_FILE
Type=Application
Categories=AudioVideo;Player
MimeType=x-scheme-handler/dar;x-scheme-handler/anymex;x-scheme-handler/sugoireads;x-scheme-handler/mangayomi;
EOL
    chmod +x "$DESKTOP_FILE"

    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null
    fi
    echo -e " ${GREEN}${ICON_SUCCESS} Done!${RESET}"

    add_updater_alias

    rm -f "/tmp/$APP_NAME.zip"

    echo
    success_msg "$APP_NAME has been installed successfully!"
    info_msg "You can now launch it from your applications menu or run: ${BOLD}$APP_NAME${RESET}"

    echo
    echo -e "${GRAY}${DIM}Press any key to continue...${RESET}"
    read -rn 1
}

uninstall_app() {
    section_header "UNINSTALLATION PROCESS" "${ICON_UNINSTALL}"

    if [ ! -d "$INSTALL_DIR" ] && [ ! -L "$LINK" ]; then
        warn_msg "$APP_NAME doesn't appear to be installed!"
        echo
        echo -e "${GRAY}${DIM}Press any key to continue...${RESET}"
        read -rn 1
        return
    fi

    echo -e "${YELLOW}${BOLD}Are you sure you want to remove $APP_NAME?${RESET} ${GRAY}(y/N)${RESET}: "
    read -rn 1 CONFIRM
    echo

    if [[ "${CONFIRM,,}" != "y" ]]; then
        info_msg "Uninstallation cancelled."
        echo
        echo -e "${GRAY}${DIM}Press any key to continue...${RESET}"
        read -rn 1
        return
    fi

    echo
    info_msg "Removing $APP_NAME components..."

    [ -L "$LINK" ] && rm -f "$LINK" && echo -e "  ${GREEN}✓${RESET} Executable symlink removed"
    [ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR" && echo -e "  ${GREEN}✓${RESET} Installation directory removed"
    [ -f "$DESKTOP_FILE" ] && rm -f "$DESKTOP_FILE" && echo -e "  ${GREEN}✓${RESET} Desktop entry removed"
    [ -f "$ICON_FILE" ] && rm -f "$ICON_FILE" && echo -e "  ${GREEN}✓${RESET} Icon removed"

    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null
    fi

    echo
    success_msg "$APP_NAME has been completely removed!"

    echo
    echo -e "${GRAY}${DIM}Press any key to continue...${RESET}"
    read -rn 1
}

update_app() {
    section_header "UPDATE PROCESS" "${ICON_UPDATE}"

    if [ ! -d "$INSTALL_DIR" ] && [ ! -L "$LINK" ]; then
        warn_msg "$APP_NAME doesn't appear to be installed!"
        info_msg "Would you like to install it instead? ${GRAY}(y/N)${RESET}: "
        read -rn 1 INSTALL_INSTEAD
        echo

        if [[ "${INSTALL_INSTEAD,,}" == "y" ]]; then
            install_app
        else
            echo -e "${GRAY}${DIM}Press any key to continue...${RESET}"
            read -rn 1
        fi
        return
    fi

    info_msg "Updating $APP_NAME to the latest version..."
    echo
    install_app

    add_updater_alias
}

main_loop() {
    while true; do
        show_banner
        show_menu
        read -rn 1 ACTION
        echo

        case "${ACTION,,}" in
            i|install)
                install_app
                ;;
            u|update)
                update_app
                ;;
            r|remove|uninstall)
                uninstall_app
                ;;
            q|quit|exit)
                echo
                type_text "Thanks for using Dartotsu Installer! ${ICON_SPARKLES}" 0.05
                echo -e "${GRAY}${DIM}Goodbye!${RESET}"
                exit 0
                ;;
            *)
                echo
                warn_msg "Invalid selection! Please choose I, U, R, or Q."
                echo -e "${GRAY}${DIM}Press any key to continue...${RESET}"
                read -rn 1
                ;;
        esac
    done
}

if [ $# -gt 0 ]; then
    ACTION="$1"
    case "${ACTION,,}" in
        install)
            show_banner
            install_app
            ;;
        update)
            show_banner
            update_app
            ;;
        uninstall|remove)
            show_banner
            uninstall_app
            ;;
        *)
            show_banner
            echo -e "${RED}Usage: $0 [install|update|uninstall]${RESET}"
            echo -e "${GRAY}Or run without arguments for interactive mode.${RESET}"
            exit 1
            ;;
    esac
elif [ -t 0 ]; then
    main_loop
else
    main_loop
fi
