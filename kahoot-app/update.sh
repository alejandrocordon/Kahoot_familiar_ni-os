#!/usr/bin/env bash
# =============================================================
#  update.sh — Actualiza y reinicia Kahoot Familiar
#  Uso:  ./update.sh
#        ./update.sh --no-pull    (solo rebuild, sin git pull)
#        ./update.sh --status     (solo muestra estado)
# =============================================================

set -euo pipefail

# ── Colores ────────────────────────────────────────────────────
RED='\033[0;31m';  GREEN='\033[0;32m';  YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m';   BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "${GREEN}  ✓ $*${NC}"; }
info() { echo -e "${CYAN}  ▶ $*${NC}"; }
warn() { echo -e "${YELLOW}  ⚠ $*${NC}"; }
err()  { echo -e "${RED}  ✗ $*${NC}"; exit 1; }

# ── Ruta del proyecto (siempre relativa al script) ─────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── Banner ─────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║   🎮  Kahoot Familiar — Actualización   ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${NC}"
echo -e "${BOLD}  Dir: ${NC}${SCRIPT_DIR}"
echo ""

# ── Modo --status: solo muestra estado ────────────────────────
if [[ "${1:-}" == "--status" ]]; then
  info "Estado del contenedor:"
  docker compose ps 2>/dev/null || warn "Docker no accesible"
  echo ""
  _get_ip && echo -e "  ${BOLD}URL:${NC} http://${LOCAL_IP:-localhost}:8080"
  exit 0
fi

# ── 1. Comprobar Docker ────────────────────────────────────────
info "Comprobando Docker..."
if ! docker info > /dev/null 2>&1; then
  err "Docker no está corriendo. Inícialo e intenta de nuevo."
fi
ok "Docker activo"

# ── 2. Git pull (omitir con --no-pull) ────────────────────────
if [[ "${1:-}" != "--no-pull" ]]; then
  echo ""
  info "Comprobando actualizaciones en Git..."

  if ! git remote -v | grep -q origin; then
    warn "No hay remote 'origin' configurado — saltando git pull"
  else
    git fetch origin --quiet 2>/dev/null || warn "No se pudo contactar con origin"

    LOCAL=$(git rev-parse HEAD 2>/dev/null || echo "")
    REMOTE=$(git rev-parse "@{u}" 2>/dev/null || echo "")

    if [[ -z "$REMOTE" ]]; then
      warn "Rama sin upstream — saltando git pull"
    elif [[ "$LOCAL" == "$REMOTE" ]]; then
      ok "Ya tienes la versión más reciente ($(git rev-parse --short HEAD))"
    else
      echo -e "${BLUE}  Cambios nuevos:${NC}"
      git log HEAD..@{u} --oneline --no-merges | sed 's/^/    /'
      git pull --quiet
      ok "Actualizado a $(git rev-parse --short HEAD)"
    fi
  fi
fi

# ── 3. Rebuild + reinicio ──────────────────────────────────────
echo ""
info "Parando contenedor anterior..."
docker compose down --remove-orphans --timeout 10 2>/dev/null || true
ok "Contenedor parado"

echo ""
info "Reconstruyendo imagen Docker..."
docker compose build --quiet
ok "Imagen construida"

echo ""
info "Iniciando contenedor..."
docker compose up -d
ok "Contenedor arriba"

# ── 4. Health-check ───────────────────────────────────────────
echo ""
info "Esperando respuesta del servidor..."
MAX_WAIT=30; WAITED=0
until curl -sf http://localhost:8080 > /dev/null 2>&1; do
  sleep 1; WAITED=$((WAITED+1))
  if [[ $WAITED -ge $MAX_WAIT ]]; then
    warn "El servidor tardó más de ${MAX_WAIT}s — revisa los logs:"
    echo "    docker compose logs -f"
    break
  fi
done
[[ $WAITED -lt $MAX_WAIT ]] && ok "Servidor respondiendo (${WAITED}s)"

# ── 5. IP local ───────────────────────────────────────────────
_get_local_ip() {
  # macOS
  if command -v ipconfig &>/dev/null; then
    IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || "")
  fi
  # Linux / Raspberry Pi
  if [[ -z "${IP:-}" ]] && command -v hostname &>/dev/null; then
    IP=$(hostname -I 2>/dev/null | awk '{print $1}' || "")
  fi
  echo "${IP:-}"
}

LOCAL_IP=$(_get_local_ip)

# ── 6. Resumen final ──────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}══════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}  ✅  ¡Kahoot Familiar listo!${NC}"
echo -e "${BOLD}${GREEN}══════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Este equipo:${NC}  http://localhost:8080"
[[ -n "$LOCAL_IP" && "$LOCAL_IP" != "127.0.0.1" ]] && \
  echo -e "  ${BOLD}Red local:${NC}    http://${LOCAL_IP}:8080  ← tablets y móviles"
echo ""
echo -e "  ${BOLD}Comandos útiles:${NC}"
echo -e "    docker compose logs -f      # ver logs en tiempo real"
echo -e "    docker compose ps           # estado del contenedor"
echo -e "    docker compose down         # parar"
echo -e "    ./update.sh --no-pull       # rebuild sin git pull"
echo -e "    ./update.sh --status        # ver estado actual"
echo ""
