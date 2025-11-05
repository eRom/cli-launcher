#!/bin/bash
# Script: next-project-setup.sh

# Variable pointant vers le dossier template
TEMPLATE_DIR="$HOME/dev/cli-launcher/templates"

# Créer le projet Next.js
npx create-next-app@latest . --yes


# Installation de dépendences
cp "$TEMPLATE_DIR/components.json" .
npx shadcn@latest add button card sonner
echo "✓ Shadcn composants installés"

npm install clsx tailwind-merge --silent
echo "✓ Clsx et tailwind-merge installés"

npm install next-themes --silent
echo "✓ Next.js themes installés"

npm install qrcode @types/qrcode --silent
echo "✓ Qrcode installé"

npm install class-variance-authority --silent
echo "✓ Class Variance Authority installé"

npm install lucide-react --silent
echo "✓ Lucide React installé"

npm install --save-dev prettier --silent
echo "✓ Prettier installé"

npm install --save-dev @types/node --silent
echo "✓ Types Node installés"

npm install --save-dev sharp imagemin imagemin-webp imagemin-avif --silent
echo "✓ Sharp, imagemin, imagemin-webp et imagemin-avif installés"

npm install puppeteer --save-dev --silent
echo "✓ Puppeteer installé"

npm install --save-dev lighthouse chrome-launcher --silent
echo "✓ Lighthouse et chrome-launcher installés"

npm install --save-dev eslint-plugin-jsx-a11y@latest @axe-core/cli@latest --silent 
echo "✓ eslint-plugin-jsx-a11y, axe-core installés"


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
echo "✓ IA Agent and Project Idea copiés"


# Lancer Cursor
cursor .

