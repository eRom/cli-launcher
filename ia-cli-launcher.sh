#!/bin/bash
# Script: next-project-setup.sh

# Variable pointant vers le dossier template
TEMPLATE_DIR="$HOME/dev/cli-launcher/templates"

# Créer le projet Next.js
npx create-next-app@latest . --yes --silent
echo "✓ Projet Next.js créé"

# Installation de dépendences
cp "$TEMPLATE_DIR/components.json" .
npx shadcn@latest add button card sonner --silent
echo "✓ Shadcn composants installés"

npm install clsx tailwind-merge lucide-react next-themes class-variance-authority --silent
echo "✓ clsx, tailwind-merge, lucide-react, next-themes et class-variance-authority installés"

npm install qrcode @types/qrcode --silent
echo "✓ QRcode installé"

npm install --save-dev @types/node --silent
echo "✓ [dev] Types Node installés"

npm install --save-dev sharp imagemin imagemin-webp imagemin-avif --silent
echo "✓ [dev] Sharp, imagemin, imagemin-webp et imagemin-avif installés"

npm install --save-dev lighthouse chrome-launcher puppeteer --silent
echo "✓ [dev] Lighthouse, chrome-launcher et puppeteer installés"

npm install --save-dev prettier eslint-plugin-jsx-a11y@latest @axe-core/cli@latest --silent 
echo "✓ [dev] Prettier, eslint-plugin-jsx-a11y, axe-core installés"


# Copier les fichiers de configuration
mkdir -p reports/

cp "$TEMPLATE_DIR/eslint.config.mjs" .
cp "$TEMPLATE_DIR/.prettierrc.json" .
cp "$TEMPLATE_DIR/.prettierignore" .
cp "$TEMPLATE_DIR/next.config.ts" .

mkdir -p src/lib/
cp "$TEMPLATE_DIR/src/lib/utils.ts" src/lib/utils.ts
echo "✓ Utils.ts copié"

mkdir -p src/app/
cp "$TEMPLATE_DIR/src/app/layout.tsx" src/app/layout.tsx
echo "✓ Layout.tsx copié"

mkdir -p public/
cp -r "$TEMPLATE_DIR/public/" ./public/
echo "✓ Fichiers public copiés"

mkdir -p scripts/
cp -r "$TEMPLATE_DIR/scripts/" ./scripts/
echo "✓ Scripts copiés"

mkdir -p .cursor/commands/
cp -r "$TEMPLATE_DIR/commands/" .cursor/commands/
echo "✓ Fichiers commandes copiés"

mkdir -p .cursor/rules/
cp -r "$TEMPLATE_DIR/rules/" .cursor/rules/ 
echo "✓ Fichiers rules copiés"

cp "$TEMPLATE_DIR/AGENT.md" AGENT.md
cp "$TEMPLATE_DIR/PROJECT_IDEA.md" PROJECT_IDEA.md
echo "✓ Agent and Project Idea copiés"

#axe http://localhost:3000/programme --tags wcag2a,wcag2aa,wcag21aa --save axe-reports/axe-programme.json --exit

npm pkg set scripts.kill="for port in {3000..3002}; do lsof -ti:$port | xargs kill -9 2>/dev/null; done"
npm pkg set scripts.dev="npm run kill && next dev --turbopack"
npm pkg set scripts.format="prettier --write ."
npm pkg set scripts.lint="prettier --check ."
npm pkg set scripts["lint:audit"]="npx eslint . --ext .js,.jsx,.ts,.tsx --format=json > reports/eslint-a11y-report.json"
npm pkg set scripts["format:staged"]="prettier --write"
npm pkg set scripts["axe"]="npx axe http://localhost:3000 --tags wcag2a,wcag2aa,wcag21aa --save ./reports/axe.json --exit"

echo "✓ Package scripts installés"

cursor .

