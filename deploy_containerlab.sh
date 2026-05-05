#!/usr/bin/env bash
# =============================================================
# deploy_containerlab.sh — Déploiement du réseau SDN
#
# Prérequis :
#   - ContainerLab installé  (https://containerlab.dev)
#   - Image projet-ml:latest déjà construite via deploy.sh
#   - Exécution en sudo
#
# Usage :
#   sudo ./scripts/deploy_containerlab.sh            # déployer
#   sudo ./scripts/deploy_containerlab.sh --graph    # schéma graphique
#   sudo ./scripts/deploy_containerlab.sh --destroy  # supprimer
# =============================================================

set -euo pipefail

GREEN='\033[0;32m'; BLUE='\033[0;34m'
YELLOW='\033[1;33m'; RED='\033[0;31m'
CYAN='\033[0;36m'; NC='\033[0m'

ok()   { echo -e "${GREEN}  ✓ $*${NC}"; }
info() { echo -e "${BLUE}  → $*${NC}"; }
err()  { echo -e "${RED}  ✗ $*${NC}"; exit 1; }

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TOPO="$PROJECT_DIR/containerlab/topology.clab.yml"

# ── Vérification des prérequis ────────────────────────────────
[[ $EUID -eq 0 ]] || err "Ce script doit être exécuté avec sudo."
command -v clab &>/dev/null || err "ContainerLab n'est pas installé. Voir https://containerlab.dev/install/"

# ── Mode --destroy ────────────────────────────────────────────
if [[ "${1:-}" == "--destroy" ]]; then
    echo -e "${YELLOW}Destruction du réseau SDN...${NC}"
    clab destroy --topo "$TOPO" --cleanup
    ok "Réseau supprimé."
    exit 0
fi

# ── Mode --graph ──────────────────────────────────────────────
if [[ "${1:-}" == "--graph" ]]; then
    info "Génération du schéma graphique → http://localhost:50080"
    clab graph --topo "$TOPO"
    exit 0
fi

# ── Déploiement ───────────────────────────────────────────────
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         DÉPLOIEMENT RÉSEAU SDN — ContainerLab       ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# Vérifier que l'image ML est disponible
echo -e "${BLUE}[1/3] Vérification de l'image Docker${NC}"
echo "──────────────────────────────────────────────────"
if ! docker images | grep -q "projet-ml"; then
    err "Image projet-ml:latest introuvable. Lancer d'abord : ./scripts/deploy.sh"
fi
ok "Image projet-ml:latest présente"
echo ""

# Déployer la topologie
echo -e "${BLUE}[2/3] Déploiement de la topologie ContainerLab${NC}"
echo "──────────────────────────────────────────────────"
info "Topologie : $TOPO"
clab deploy --topo "$TOPO" --reconfigure
ok "Réseau SDN déployé"
echo ""

# Configurer les adresses IP des interfaces
echo -e "${BLUE}[3/3] Configuration des adresses IP${NC}"
echo "──────────────────────────────────────────────────"

# Backbone inter-routeurs (10.0.0.0/30)
docker exec clab-reseau-dev-ml-routeur1 ip addr add 10.0.0.1/30 dev eth0 2>/dev/null || true
docker exec clab-reseau-dev-ml-routeur2 ip addr add 10.0.0.2/30 dev eth0 2>/dev/null || true

# Côté routeur1
docker exec clab-reseau-dev-ml-routeur1 ip addr add 192.168.1.254/24 dev eth1 2>/dev/null || true
docker exec clab-reseau-dev-ml-routeur1 ip addr add 192.168.2.254/24 dev eth2 2>/dev/null || true
docker exec clab-reseau-dev-ml-routeur1 ip addr add 10.10.0.1/24    dev eth3 2>/dev/null || true

# Clients côté routeur1
docker exec clab-reseau-dev-ml-client1 ip addr add 192.168.1.1/24 dev eth0 2>/dev/null || true
docker exec clab-reseau-dev-ml-client1 ip route add default via 192.168.1.254         2>/dev/null || true
docker exec clab-reseau-dev-ml-client2 ip addr add 192.168.2.1/24 dev eth0 2>/dev/null || true
docker exec clab-reseau-dev-ml-client2 ip route add default via 192.168.2.254         2>/dev/null || true

# Côté routeur2
docker exec clab-reseau-dev-ml-routeur2 ip addr add 192.168.3.254/24 dev eth1 2>/dev/null || true
docker exec clab-reseau-dev-ml-routeur2 ip addr add 192.168.4.254/24 dev eth2 2>/dev/null || true

# Clients côté routeur2
docker exec clab-reseau-dev-ml-client3 ip addr add 192.168.3.1/24 dev eth0 2>/dev/null || true
docker exec clab-reseau-dev-ml-client3 ip route add default via 192.168.3.254         2>/dev/null || true
docker exec clab-reseau-dev-ml-client4 ip addr add 192.168.4.1/24 dev eth0 2>/dev/null || true
docker exec clab-reseau-dev-ml-client4 ip route add default via 192.168.4.254         2>/dev/null || true

# Serveur ML
docker exec clab-reseau-dev-ml-serveur-ml ip addr add 10.10.0.2/24 dev eth0 2>/dev/null || true
docker exec clab-reseau-dev-ml-serveur-ml ip route add default via 10.10.0.1           2>/dev/null || true

ok "Adresses IP configurées"
echo ""

echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              RÉSEAU SDN OPÉRATIONNEL                ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  Serveur ML   →  http://localhost:8888              ║${NC}"
echo -e "${CYAN}║  Schéma réseau→  sudo ./scripts/deploy_clab --graph ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  Tests rapides :                                    ║${NC}"
echo -e "${CYAN}║  docker exec clab-reseau-dev-ml-client1 \           ║${NC}"
echo -e "${CYAN}║         ping -c 4 192.168.3.1                      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
