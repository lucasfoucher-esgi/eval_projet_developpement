#!/usr/bin/env bash
# =============================================================
# provision.sh — Provisionnement automatique de la VM Ubuntu
#
# Exécuté automatiquement par Vagrant lors du premier "vagrant up".
# Peut aussi être relancé manuellement : bash /vagrant_provision/provision.sh
#
# Étapes :
#   [1] Mise à jour système
#   [2] Installation de Git
#   [3] Installation de Docker Engine (méthode officielle)
#   [4] Configuration Docker (utilisateur vagrant dans le groupe docker)
#   [5] Clone du dépôt
#   [6] Démarrage de l'environnement ML via deploy.sh
# =============================================================

set -euo pipefail

REPO_URL="https://github.com/lucasfoucher-esgi/eval_projet_develloppement.git"
PROJECT_DIR="$HOME/eval_projet_develloppement"

# ── Couleurs ──────────────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'
YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

ok()   { echo -e "${GREEN}  ✓ $*${NC}"; }
info() { echo -e "${BLUE}  → $*${NC}"; }
warn() { echo -e "${YELLOW}  ⚠ $*${NC}"; }
err()  { echo -e "${RED}  ✗ $*${NC}"; exit 1; }

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       PROVISIONNEMENT VM — Environnement ML         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# ── [1] Mise à jour du système ────────────────────────────────
echo -e "${BLUE}[1/6] Mise à jour du système${NC}"
echo "──────────────────────────────────────────────────"
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
sudo apt-get install -y -qq \
    ca-certificates curl gnupg lsb-release \
    apt-transport-https software-properties-common
ok "Système à jour"
echo ""

# ── [2] Installation de Git ───────────────────────────────────
echo -e "${BLUE}[2/6] Installation de Git${NC}"
echo "──────────────────────────────────────────────────"
sudo apt-get install -y -qq git
ok "Git $(git --version | grep -oP '\d+\.\d+\.\d+') installé"
echo ""

# ── [3] Installation de Docker Engine ────────────────────────
echo -e "${BLUE}[3/6] Installation de Docker Engine${NC}"
echo "──────────────────────────────────────────────────"

if command -v docker &>/dev/null; then
    ok "Docker déjà installé ($(docker --version | grep -oP '\d+\.\d+\.\d+'))"
else
    info "Ajout du dépôt officiel Docker..."

    # Clé GPG officielle
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Dépôt stable
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin

    ok "Docker $(docker --version | grep -oP '\d+\.\d+\.\d+') installé"
fi
echo ""

# ── [4] Configuration Docker ──────────────────────────────────
echo -e "${BLUE}[4/6] Configuration Docker${NC}"
echo "──────────────────────────────────────────────────"

# Ajouter l'utilisateur courant au groupe docker (évite sudo)
if ! groups "$USER" | grep -q docker; then
    sudo usermod -aG docker "$USER"
    info "Utilisateur '$USER' ajouté au groupe docker"
    info "Prise en compte du groupe en cours…"
fi

# Activer et démarrer le service Docker
sudo systemctl enable docker --quiet
sudo systemctl start docker
ok "Daemon Docker actif"

# Vérification Docker Compose v2
docker compose version &>/dev/null \
    && ok "Docker Compose $(docker compose version --short) disponible" \
    || warn "Docker Compose v2 non détecté — vérifier l'installation"
echo ""

# ── [5] Clonage du dépôt ──────────────────────────────────────
echo -e "${BLUE}[5/6] Récupération du code${NC}"
echo "──────────────────────────────────────────────────"

if [[ -d "$PROJECT_DIR/.git" ]]; then
    info "Dépôt déjà présent → mise à jour"
    git -C "$PROJECT_DIR" pull --ff-only \
        && ok "Dépôt à jour" \
        || warn "git pull échoué — on continue avec le code local"
else
    info "Clonage depuis $REPO_URL"
    git clone "$REPO_URL" "$PROJECT_DIR" \
        || err "Échec du clonage. Vérifier l'URL et la connexion réseau."
    ok "Dépôt cloné dans $PROJECT_DIR"
fi

# Rendre les scripts exécutables
chmod +x "$PROJECT_DIR/deploy.sh" 2>/dev/null || true
chmod +x "$PROJECT_DIR/deploy_containerlab.sh" 2>/dev/null || true
chmod +x "$PROJECT_DIR/check_quality.sh" 2>/dev/null || true
ok "Scripts rendus exécutables"
echo ""

# ── [6] Démarrage de l'environnement ML ──────────────────────
echo -e "${BLUE}[6/6] Démarrage de l'environnement ML${NC}"
echo "──────────────────────────────────────────────────"
info "Exécution de deploy.sh dans le contexte docker…"

# newgrp n'est pas disponible en non-interactif → sg pour appliquer le groupe
sg docker -c "bash '$PROJECT_DIR/deploy.sh'" \
    || warn "deploy.sh a retourné une erreur — vérifier avec : docker logs jupyter-ml"
echo ""

# ── Résumé ────────────────────────────────────────────────────
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║             PROVISIONNEMENT TERMINÉ                 ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  JupyterLab  →  http://localhost:8888               ║${NC}"
echo -e "${CYAN}║               (port redirigé vers l'hôte)           ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  Commandes utiles dans la VM (vagrant ssh) :        ║${NC}"
echo -e "${CYAN}║    cd ~/eval_projet_develloppement                  ║${NC}"
echo -e "${CYAN}║    ./deploy.sh --stop   # arrêter JupyterLab        ║${NC}"
echo -e "${CYAN}║    ./deploy.sh --clean  # tout nettoyer             ║${NC}"
echo -e "${CYAN}║    docker exec jupyter-ml check_quality             ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
