# AI Developer Bot - Proyecto de Ejemplo

Este es un proyecto de ejemplo para demostrar un flujo de trabajo automatizado con IA y GitHub Actions.

## Estructura del Proyecto

```
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI: tests, lint, static analysis
│       ├── code-review.yml      # AI Code Review automático
│       └── deploy.yml           # Deploy a staging/production
├── app/
│   └── Http/
│       └── Controllers/
│           ├── Controller.php
│           └── UserController.php
├── tests/
│   ├── Feature/
│   │   └── UserControllerTest.php
│   └── TestCase.php
├── scripts/
│   └── ai-developer.sh          # Script para la IA
├── composer.json
├── phpunit.xml
├── phpstan.neon
└── README.md
```

## Ramas (Git Flow)

```
main (protected)
  │
  ├── production
  │
staging (protected)
  │
  └── dev (protected)
      │
      └── feature/xxx (ramas de trabajo)
```

## Workflow Automatizado

### 1. La IA genera código
```bash
# Usando el script
./scripts/ai-developer.sh "Crea un controller ProductsController" "product-controller"
```

### 2. Se crea automáticamente:
- Rama desde `dev`
- Commit con el código
- Pull Request hacia `dev`

### 3. GitHub Actions ejecuta:
- ✅ CI (tests, lint, PHPStan)
- ✅ AI Code Review
- ✅ Verificación de seguridad

### 4. Vos revisás y aprobás
- Revisás los comentarios del AI
- Aprobás el PR
- Se mergea a `dev`

### 5. Deploy
- Push a `staging` → deploy automático
- Push a `production` → deploy manual

## Configuración Inicial

### 1. Variables de Entorno
Creá un archivo `.env`:
```env
GITHUB_TOKEN=ghp_xxxxx
OPENAI_API_KEY=sk-xxxxx
```

### 2. Instalar dependencias
```bash
composer install
```

### 3. Probar linting
```bash
./vendor/bin/pint --test
./vendor/bin/phpstan analyse
./vendor/bin/pest
```

## Secrets de GitHub

En **Settings → Secrets and variables → Actions**, agregar:

| Secret | Descripción |
|--------|-------------|
| `OPENAI_API_KEY` | API key de OpenAI |
| `SLACK_WEBHOOK` | Webhook de Slack (opcional) |

## Comandos Útiles

```bash
# Linting
composer lint          # Verificar code style
composer lint:fix      # Auto-fix code style

# Análisis estático
composer stan          # PHPStan

# Tests
composer test          # Ejecutar tests
composer test:coverage # Tests con coverage

# CI completo
composer ci            # Lint + Stan + Test
```

## AI Developer Bot

El script `scripts/ai-developer.sh` automatiza el flujo completo:

```bash
# Ejecutar con tu prompt
./scripts/ai-developer.sh "Tu prompt aquí" "nombre-del-feature"
```

## Estado de CI

[![CI](https://github.com/tu-usuario/tu-repo/actions/workflows/ci.yml/badge.svg)](https://github.com/tu-usuario/tu-repo/actions/workflows/ci.yml)

---

**Nota**: Este proyecto es un ejemplo. Adaptá los paths, configuraciones y scripts según tu caso de uso específico.
