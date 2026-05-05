#!/usr/bin/env bash
# =============================================================
# check_quality.sh — Analyse qualité du code (3 outils)
#
# Les 3 outils couvrent 3 dimensions distinctes et complémentaires :
#   Pylint  → style & erreurs statiques  (score /10)
#   Bandit  → sécurité du code           (vulnérabilités)
#   Radon   → complexité & maintenabilité (métriques)
#
# Usage : check_quality [fichier_ou_dossier]
#         Par défaut : analyse tout /workspace/libs/
# =============================================================

set -euo pipefail

TARGET="${1:-/workspace/libs}"
REPORT_DIR="/workspace/quality_reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

GREEN='\033[0;32m'; BLUE='\033[0;34m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

mkdir -p "$REPORT_DIR"

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           ANALYSE QUALITÉ DU CODE PYTHON            ║${NC}"
echo -e "${CYAN}║  Cible : $TARGET${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# ── 1. Pylint — Style & erreurs statiques ────────────────────
echo -e "${BLUE}[1/3] PYLINT — Style, erreurs et bonnes pratiques${NC}"
echo -e "${YELLOW}      → Objectif : détecter les bugs et mauvaises pratiques${NC}"
echo "──────────────────────────────────────────────────"
pylint "$TARGET" \
    --rcfile=/workspace/.pylintrc \
    --output-format=colorized \
    2>&1 | tee "$REPORT_DIR/pylint_${TIMESTAMP}.txt" || true
echo ""

# ── 2. Bandit — Sécurité ─────────────────────────────────────
echo -e "${BLUE}[2/3] BANDIT — Analyse de sécurité${NC}"
echo -e "${YELLOW}      → Objectif : repérer les vulnérabilités connues${NC}"
echo "──────────────────────────────────────────────────"
bandit -r "$TARGET" \
    --configfile /workspace/bandit.yaml \
    --format text \
    2>&1 | tee "$REPORT_DIR/bandit_${TIMESTAMP}.txt" || true
echo ""

# ── 3. Radon — Complexité & maintenabilité ───────────────────
echo -e "${BLUE}[3/3] RADON — Complexité cyclomatique & maintenabilité${NC}"
echo -e "${YELLOW}      → Objectif : mesurer la lisibilité et la testabilité${NC}"
echo "──────────────────────────────────────────────────"

echo -e "${YELLOW}→ Complexité cyclomatique (A=simple … F=critique) :${NC}"
radon cc "$TARGET" --min B --show-complexity --average \
    2>&1 | tee "$REPORT_DIR/radon_cc_${TIMESTAMP}.txt" || true

echo ""
echo -e "${YELLOW}→ Indice de maintenabilité (A=excellent … C=à améliorer) :${NC}"
radon mi "$TARGET" --show \
    2>&1 | tee "$REPORT_DIR/radon_mi_${TIMESTAMP}.txt" || true
echo ""

echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Rapports sauvegardés dans : $REPORT_DIR  ${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
