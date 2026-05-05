#!/usr/bin/env bash
# =============================================================
# deploy.sh — Déploiement de l'environnement ML
#
# Étapes :
#   [1] Vérification des prérequis (Docker, Docker Compose)
#   [2] Récupération du code (git pull / git clone)
#   [3] Construction de l'image Docker
#   [4] Démarrage des services
#   [5] Résumé et URL d'accès
#
# Usage :
#   ./scripts/deploy.sh            # déploiement complet
#   ./scripts/deploy.sh --stop     # arrêt propre des services
#   ./scripts/deploy.sh --clean    # nettoyage total (image + volumes)
# =============================================================

set -euo pipefail

# ── Couleurs ─────────────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'
YELLOW='\033[1;33m'; RED='\033[0;31m'
CYAN='\033[0;36m'; NC='\033[0m'

REPO_URL="https://github.com/lucasfoucher-esgi/eval_projet_develloppement.git"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"

# ── Fonctions utilitaires ─────────────────────────────────────
ok()   { echo -e "${GREEN}  ✓ $*${NC}"; }
info() { echo -e "${BLUE}  → $*${NC}"; }
warn() { echo -e "${YELLOW}  ⚠ $*${NC}"; }
err()  { echo -e "${RED}  ✗ $*${NC}"; exit 1; }

banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        DÉPLOIEMENT ENVIRONNEMENT ML — Docker        ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ── Mode --stop ───────────────────────────────────────────────
if [[ "${1:-}" == "--stop" ]]; then
    echo -e "${YELLOW}Arrêt des services...${NC}"
    docker compose -f "$COMPOSE_FILE" down
    ok "Services arrêtés."
    exit 0
fi

# ── Mode --clean ──────────────────────────────────────────────
if [[ "${1:-}" == "--clean" ]]; then
    echo -e "${YELLOW}Nettoyage complet (conteneurs, image, volumes)...${NC}"
    docker compose -f "$COMPOSE_FILE" down --volumes --rmi local 2>/dev/null || true
    ok "Nettoyage terminé."
    exit 0
fi

# ── Déploiement complet ───────────────────────────────────────
banner

# ── [1] Vérification des prérequis ───────────────────────────
echo -e "${BLUE}[1/5] Vérification des prérequis${NC}"
echo "──────────────────────────────────────────────────"

command -v docker &>/dev/null  || err "Docker n'est pas installé. Voir https://docs.docker.com/get-docker/"
ok "Docker $(docker --version | grep -oP '\d+\.\d+\.\d+') détecté"

docker compose version &>/dev/null || err "Docker Compose v2 requis. Mettre à jour Docker Desktop ou installer le plugin."
ok "Docker Compose $(docker compose version --short) détecté"

docker info &>/dev/null || err "Le daemon Docker n'est pas démarré. Lance Docker Desktop ou : sudo systemctl start docker"
ok "Daemon Docker actif"
echo ""

# ── [2] Récupération du code ──────────────────────────────────
echo -e "${BLUE}[2/5] Récupération du code${NC}"
echo "──────────────────────────────────────────────────"

if [[ -d "$PROJECT_DIR/.git" ]]; then
    info "Dépôt déjà cloné → mise à jour (git pull)"
    git -C "$PROJECT_DIR" pull --ff-only && ok "Code à jour" || warn "git pull échoué — on continue avec le code local"
else
    info "Clonage du dépôt depuis $REPO_URL"
    git clone "$REPO_URL" "$PROJECT_DIR" || err "Échec du clonage. Vérifier l'URL et vos droits d'accès."
    ok "Dépôt cloné dans $PROJECT_DIR"
fi
echo ""

# ── [3] Construction de l'image Docker ───────────────────────
echo -e "${BLUE}[3/5] Construction de l'image Docker${NC}"
echo "──────────────────────────────────────────────────"
info "Cela peut prendre quelques minutes lors du premier build…"
docker compose -f "$COMPOSE_FILE" build --no-cache
ok "Image projet-ml:latest construite"
echo ""

# ── [4] Démarrage des services ────────────────────────────────
echo -e "${BLUE}[4/5] Démarrage des services${NC}"
echo "──────────────────────────────────────────────────"
docker compose -f "$COMPOSE_FILE" up -d
info "Attente du healthcheck JupyterLab…"

MAX_WAIT=60
WAITED=0
until curl -sf http://localhost:8888/api >/dev/null 2>&1; do
    sleep 2
    WAITED=$((WAITED + 2))
    if [[ $WAITED -ge $MAX_WAIT ]]; then
        warn "Délai dépassé — JupyterLab n'a pas répondu en ${MAX_WAIT}s."
        warn "Vérifier avec : docker logs jupyter-ml"
        break
    fi
    echo -n "."
done
echo ""
ok "JupyterLab opérationnel"
echo ""

# ── [5] Résumé ────────────────────────────────────────────────
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                   DÉPLOIEMENT OK                   ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  JupyterLab  →  http://localhost:8888               ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  Commandes utiles :                                 ║${NC}"
echo -e "${CYAN}║    Arrêt    : ./scripts/deploy.sh --stop            ║${NC}"
echo -e "${CYAN}║    Nettoyage: ./scripts/deploy.sh --clean           ║${NC}"
echo -e "${CYAN}║    Shell    : docker exec -it jupyter-ml bash       ║${NC}"
echo -e "${CYAN}║    Qualité  : docker exec jupyter-ml check_quality  ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
