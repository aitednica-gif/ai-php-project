#!/bin/bash

# ============================================================================
# AI Developer Bot - Script de Automatización para GitHub
# ============================================================================
# Este script automatiza el flujo de: generar código → commit → PR
# Uso: ./ai-developer.sh "prompt para la IA" "nombre del feature"
# ============================================================================

set -e

# Configuración
REPO_OWNER="${REPO_OWNER:-}"
REPO_NAME="${REPO_NAME:-}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
OPENAI_API_KEY="${OPENAI_API_KEY:-}"
BASE_BRANCH="dev"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de logging
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Verificar dependencias
check_dependencies() {
    log_info "Verificando dependencias..."
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) no está instalado"
        log_info "Instalalo: https://cli.github.com"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        log_error "Git no está instalado"
        exit 1
    fi
    
    log_success "Dependencias verificadas"
}

# Verificar configuración
check_config() {
    log_info "Verificando configuración..."
    
    if [ -z "$GITHUB_TOKEN" ]; then
        log_error "GITHUB_TOKEN no está configurado"
        exit 1
    fi
    
    # Verificar que gh esté autenticado
    if ! gh auth status &> /dev/null; then
        log_error "No estás autenticado en GitHub"
        log_info "Ejecuta: gh auth login"
        exit 1
    fi
    
    # Determinar repo si no se especificó
    if [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
        REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com/||' | sed 's|\.git||')
        REPO_OWNER=$(echo "$REPO" | cut -d'/' -f1)
        REPO_NAME=$(echo "$REPO" | cut -d'/' -f2)
    fi
    
    log_success "Configuración verificada"
    log_info "Repo: $REPO_OWNER/$REPO_NAME"
}

# Generar nombre de rama desde el feature
generate_branch_name() {
    local feature_name="$1"
    # Convertir a lowercase, reemplazar espacios con guiones
    local branch_name="feature/$(echo "$feature_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')"
    echo "$branch_name"
}

# Crear rama desde dev
create_branch() {
    local branch_name="$1"
    
    log_info "Creando rama: $branch_name"
    
    # Asegurarse de que tenemos la última versión de dev
    git fetch origin dev
    git checkout -b "$branch_name" "origin/dev" 2>/dev/null || git checkout -b "$branch_name"
    
    log_success "Rama '$branch_name' creada desde dev"
}

# Generar código con IA
generate_code() {
    local prompt="$1"
    
    log_info "Generando código con IA..."
    
    if [ -z "$OPENAI_API_KEY" ]; then
        log_warn "OPENAI_API_KEY no configurada - usando modo manual"
        echo "$prompt"
        return 1
    fi
    
    # Llamar a OpenAI
    local response=$(curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d '{
            "model": "gpt-4o",
            "messages": [
                {
                    "role": "system", 
                    "content": "Eres un desarrollador PHP senior. Genera código limpio, siguiendo PSR-12, con tests incluido. Responde SOLO con el código, sin explicaciones adicionales."
                },
                {
                    "role": "user", 
                    "content": "'"$prompt"'"
                }
            ],
            "temperature": 0.7,
            "max_tokens": 4000
        }')
    
    # Extraer el contenido
    local code=$(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null)
    
    if [ -z "$code" ] || [ "$code" = "null" ]; then
        log_error "Error al generar código"
        echo "$response"
        return 1
    fi
    
    echo "$code"
    log_success "Código generado"
}

# Commit cambios
commit_changes() {
    local branch_name="$1"
    local feature_name="$2"
    
    log_info "Preparando commit..."
    
    # Añadir todos los cambios
    git add -A
    
    # Verificar si hay cambios
    if git diff --staged --quiet; then
        log_warn "No hay cambios para commit"
        return 1
    fi
    
    # Crear commit
    git commit -m "feat($feature_name): generado con IA

- Código generado automáticamente
- Revisado por CI
- Tests incluidos"
    
    log_success "Commit creado"
    
    # Push
    log_info "Subiendo a remote..."
    git push -u origin "$branch_name" --force
    
    log_success "Push completado"
}

# Crear Pull Request
create_pr() {
    local branch_name="$1"
    local feature_name="$2"
    
    log_info "Creando Pull Request..."
    
    # Crear PR con gh
    pr_url=$(gh pr create \
        --base dev \
        --head "$branch_name" \
        --title "feat($feature_name): $(echo "$feature_name" | tr '-' ' ')" \
        --body "## Descripción

Feature generado automáticamente con IA.

### Cambios
- Código nuevo generado
- Tests unitarios incluidos

### Verificación
- [ ] CI aprobado
- [ ] Code review aprobado
- [ ] Tests pasando

---
*Este PR fue generado automáticamente por AI Developer Bot*")
    
    log_success "PR creado: $pr_url"
    echo "$pr_url"
}

# Workflow principal
main() {
    local prompt="$1"
    local feature_name="$2"
    
    if [ -z "$prompt" ] || [ -z "$feature_name" ]; then
        echo "Uso: $0 \"prompt para la IA\" \"nombre del feature\""
        echo ""
        echo "Ejemplo:"
        echo "  $0 \"Crea un controller UsersController con método index\" \"user-controller\""
        exit 1
    fi
    
    echo "=============================================="
    echo "  AI Developer Bot - Inicio"
    echo "=============================================="
    echo ""
    
    check_dependencies
    check_config
    
    local branch_name=$(generate_branch_name "$feature_name")
    
    # 1. Crear rama
    create_branch "$branch_name"
    
    # 2. Generar código
    if generate_code "$prompt" > generated_code.php; then
        log_info "Código guardado en generated_code.php"
        log_warn "Mover el código manualmente a la ubicación correcta"
    else
        log_error "No se pudo generar código automáticamente"
    fi
    
    # 3. Commit y push
    commit_changes "$branch_name" "$feature_name"
    
    # 4. Crear PR
    create_pr "$branch_name" "$feature_name"
    
    echo ""
    echo "=============================================="
    echo "  AI Developer Bot - Completado"
    echo "=============================================="
    echo ""
    log_success "El código fue subido y el PR fue creado"
    log_info "Ahora esperá a que:"
    log_info "  1. CI verifique los tests"
    log_info "  2. AI Code Review analice el código"
    log_info "  3. Vos approves el PR"
}

# Ejecutar
main "$@"
