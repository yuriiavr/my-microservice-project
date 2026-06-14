#!/usr/bin/env bash
#
# install_dev_tools.sh
# Автоматичне встановлення Docker, Docker Compose, Python (3.9+) та Django.
# Призначено для Ubuntu / Debian. Скрипт ідемпотентний: перед встановленням
# перевіряє, чи інструмент уже присутній у системі.
#
set -euo pipefail

# --- Кольори та хелпери для виводу --------------------------------------------
log()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$1"; }
ok()   { printf '\033[1;32m[ OK ]\033[0m  %s\n' "$1"; }
warn() { printf '\033[1;33m[WARN]\033[0m  %s\n' "$1"; }
err()  { printf '\033[1;31m[FAIL]\033[0m  %s\n' "$1" >&2; }

# Виконати команду з root-правами (через sudo, якщо ми не root).
SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        err "Потрібні root-права або встановлений sudo."
        exit 1
    fi
fi

# Чи доступна команда у системі?
has() { command -v "$1" >/dev/null 2>&1; }

# --- Перевірка ОС -------------------------------------------------------------
if ! has apt-get; then
    err "Скрипт розрахований на Ubuntu/Debian (потрібен apt-get)."
    exit 1
fi

# --- Оновлення індексу пакетів (один раз) -------------------------------------
log "Оновлення індексу пакетів apt..."
$SUDO apt-get update -y

# --- Базові залежності --------------------------------------------------------
log "Перевірка базових залежностей (curl, ca-certificates, gnupg)..."
$SUDO apt-get install -y ca-certificates curl gnupg lsb-release

# --- Docker -------------------------------------------------------------------
install_docker() {
    if has docker; then
        ok "Docker уже встановлено: $(docker --version)"
        return
    fi

    log "Встановлення Docker..."
    local keyring="/etc/apt/keyrings/docker.gpg"
    $SUDO install -m 0755 -d /etc/apt/keyrings

    # Визначаємо дистрибутив (ubuntu або debian).
    local distro
    distro="$(. /etc/os-release && echo "$ID")"

    if [[ ! -f "$keyring" ]]; then
        curl -fsSL "https://download.docker.com/linux/${distro}/gpg" \
            | $SUDO gpg --dearmor -o "$keyring"
        $SUDO chmod a+r "$keyring"
    fi

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=${keyring}] \
https://download.docker.com/linux/${distro} \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        | $SUDO tee /etc/apt/sources.list.d/docker.list >/dev/null

    $SUDO apt-get update -y
    $SUDO apt-get install -y \
        docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin

    $SUDO systemctl enable docker >/dev/null 2>&1 || true
    $SUDO systemctl start docker  >/dev/null 2>&1 || true
    ok "Docker встановлено: $(docker --version)"
}

# --- Docker Compose -----------------------------------------------------------
install_docker_compose() {
    # Сучасний Docker постачає Compose як плагін: `docker compose`.
    if docker compose version >/dev/null 2>&1; then
        ok "Docker Compose (плагін) уже встановлено: $(docker compose version | head -n1)"
        return
    fi
    if has docker-compose; then
        ok "Docker Compose (standalone) уже встановлено: $(docker-compose --version)"
        return
    fi

    log "Встановлення Docker Compose (плагін)..."
    $SUDO apt-get install -y docker-compose-plugin
    if docker compose version >/dev/null 2>&1; then
        ok "Docker Compose встановлено: $(docker compose version | head -n1)"
    else
        warn "Не вдалося підтвердити плагін, встановлюю standalone docker-compose..."
        $SUDO apt-get install -y docker-compose
        ok "Docker Compose встановлено: $(docker-compose --version)"
    fi
}

# --- Python 3.9+ --------------------------------------------------------------
# Чи задовольняє наявний python3 вимогу 3.9+?
python_ok() {
    has python3 || return 1
    python3 - <<'PY'
import sys
sys.exit(0 if sys.version_info >= (3, 9) else 1)
PY
}

install_python() {
    if python_ok; then
        ok "Python уже встановлено: $(python3 --version)"
    else
        log "Встановлення Python 3 (3.9+)..."
        $SUDO apt-get install -y python3 python3-pip python3-venv
        if ! python_ok; then
            err "Встановлена версія Python нижча за 3.9: $(python3 --version 2>&1)"
            exit 1
        fi
        ok "Python встановлено: $(python3 --version)"
    fi

    # pip потрібен для встановлення Django.
    if ! has pip3 && ! python3 -m pip --version >/dev/null 2>&1; then
        log "Встановлення pip..."
        $SUDO apt-get install -y python3-pip
    fi
    ok "pip доступний: $(python3 -m pip --version)"
}

# --- Django -------------------------------------------------------------------
install_django() {
    if python3 -m django --version >/dev/null 2>&1; then
        ok "Django уже встановлено: $(python3 -m django --version)"
        return
    fi

    log "Встановлення Django через pip..."
    # --break-system-packages потрібен на нових Debian/Ubuntu (PEP 668);
    # прапорець ігнорується, якщо середовище його не вимагає.
    if ! python3 -m pip install --user Django 2>/dev/null; then
        python3 -m pip install --user --break-system-packages Django
    fi
    ok "Django встановлено: $(python3 -m django --version)"
}

# --- Головний сценарій --------------------------------------------------------
main() {
    log "Початок встановлення інструментів розробки..."
    install_docker
    install_docker_compose
    install_python
    install_django

    echo
    ok "Готово! Підсумок встановлених версій:"
    has docker          && printf '  • %s\n' "$(docker --version)"
    docker compose version >/dev/null 2>&1 \
        && printf '  • Docker Compose %s\n' "$(docker compose version --short 2>/dev/null)"
    has python3         && printf '  • %s\n' "$(python3 --version)"
    python3 -m django --version >/dev/null 2>&1 \
        && printf '  • Django %s\n' "$(python3 -m django --version)"

    warn "Щоб користуватися docker без sudo, виконайте: 'sudo usermod -aG docker \$USER' і перезайдіть у систему."
}

main "$@"
