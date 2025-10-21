#!/bin/bash
# Script: next-project-setup.sh

# Variable pointant vers le dossier template
TEMPLATE_DIR="$HOME/dev/cli-launcher"

# Créer le projet Next.js
npx create-next-app@latest . --ts --tailwind --eslint --app --src-dir "@/*" --import-alias "@/*" --turbopack

# Vérifier si la création du projet a réussi
if [ $? -eq 0 ]; then
    echo "Projet Next.js créé. Copie des fichiers depuis $TEMPLATE_DIR..."

    # Copier logo.png
    if [ -f "$TEMPLATE_DIR/logo.png" ]; then
        cp "$TEMPLATE_DIR/logo.png" .
        echo "✓ logo.png copié"
    else
        echo "⚠️  $TEMPLATE_DIR/logo.png introuvable"
    fi

    # Copier PROJECT_IDEA.md
    if [ -f "$TEMPLATE_DIR/PROJECT_IDEA.md" ]; then
        cp "$TEMPLATE_DIR/PROJECT_IDEA.md" .
        echo "✓ PROJECT_IDEA.md copié"
    else
        echo "⚠️  $TEMPLATE_DIR/PROJECT_IDEA.md introuvable"
    fi

     # Copier PROJECT_IDEA.md
    if [ -f "$TEMPLATE_DIR/AGENT.md" ]; then
        cp "$TEMPLATE_DIR/AGENT.md" .
        echo "✓ AGENT.md copié"
    else
        echo "⚠️  $TEMPLATE_DIR/AGENT.md introuvable"
    fi

    echo "🎉 Configuration terminée !"
else
    echo "❌ Échec de la création du projet"
    exit 1
fi

# Installation de dépendences
cp "$TEMPLATE_DIR/components.json" .
npx shadcn@latest add button card sonner
echo "✓ Shadcn composants installés"

npm install clsx tailwind-merge
echo "✓ Clsx et tailwind-merge installés"

npm install next-themes
echo "✓ Next.js themes installés"

npm install qrcode @types/qrcode 
echo "✓ Qrcode installé"

npm install --save-dev prettier
cp "$TEMPLATE_DIR/.prettierrc.json" .
cp "$TEMPLATE_DIR/.prettierignore" .
echo "✓ Prettier installé"

npm install class-variance-authority
echo "✓ Class Variance Authority installé"

npm install lucide-react
echo "✓ Lucide React installé"

npm install --save-dev @types/node
echo "✓ Types Node installés"

npm install --save-dev sharp imagemin imagemin-webp imagemin-avif
echo "✓ Sharp, imagemin, imagemin-webp et imagemin-avif installés"

npm install puppeteer --save-dev
echo "✓ Puppeteer installé"

npm install canvas
echo "✓ Canvas installé"

npm install --save-dev lighthouse chrome-launcher
echo "✓ Lighthouse et chrome-launcher installés"

mkdir -p src/lib/
cp "$TEMPLATE_DIR/src/lib/utils.ts" src/lib/utils.ts
echo "✓ Utils.ts copié"

mkdir -p src/app/
cp "$TEMPLATE_DIR/src/app/layout.tsx" src/app/layout.tsx
echo "✓ Layout.tsx copié"

mkdir -p public/
cp "$TEMPLATE_DIR/public/manifest.json" public/manifest.json
cp "$TEMPLATE_DIR/public/og.png" public/og.png
echo "✓ Fichiers public copiés"

cp "$TEMPLATE_DIR/public/unregister-sw.html" public/unregister-sw.html
echo "✓ unregister-sw.html copié"

cp "$TEMPLATE_DIR/next.config.ts" next.config.ts
echo "✓ next.config.ts copié"

cp "$TEMPLATE_DIR/LIGHTHOUSE.md" LIGHTHOUSE.md
echo "✓ LIGHTHOUSE.md copié"

mkdir -p scripts/
cp "$TEMPLATE_DIR/scripts/generate-icons.js" scripts/generate-icons.js
cp "$TEMPLATE_DIR/scripts/generate-og-image.js" scripts/generate-og-image.js
cp "$TEMPLATE_DIR/scripts/lighthouse-test.js" scripts/lighthouse-test.js
cp "$TEMPLATE_DIR/scripts/optimize-images.js" scripts/optimize-images.js
cp "$TEMPLATE_DIR/scripts/generate-screenshots.js" scripts/generate-screenshots.js
cp "$TEMPLATE_DIR/scripts/puppeteer-config.js" scripts/puppeteer-config.js
echo "✓ Scripts copiés"

npm pkg set scripts.dev="for port in {3000..3005}; do lsof -ti:\$port | xargs kill -9 2>/dev/null; done && next dev --turbopack"
npm pkg set scripts.format="prettier --write ."
npm pkg set scripts.lint="prettier --check ."
npm pkg set scripts["format:staged"]="prettier --write"
npm pkg set scripts["icons"]="node scripts/generate-icons.js"
npm pkg set scripts["icons:watch"]="nodemon --watch logo.png --exec \"npm run icons\""
npm pkg set scripts["og:generate"]="node scripts/generate-og-image.js"
npm pkg set scripts["lighthouse"]="node scripts/lighthouse-test.js"
npm pkg set scripts["lighthouse:desktop"]="node scripts/lighthouse-test.js http://localhost:3000 desktop"
npm pkg set scripts["lighthouse:mobile"]="node scripts/lighthouse-test.js http://localhost:3000 mobile"
npm pkg set scripts["lighthouse:both"]="node scripts/lighthouse-test.js http://localhost:3000 both"
npm pkg set scripts["optimize:images"]="node scripts/optimize-images.js"
npm pkg set scripts["screenshots"]="node scripts/generate-screenshots.js"
npm pkg set scripts["pwa:setup"]="npm run screenshots && npm run optimize:images"
echo "✓ Package scripts installés"

mkdir -p .claude/commands/
cp "$TEMPLATE_DIR/commands/neo-project.md" .claude/commands/neo-project.md
cp "$TEMPLATE_DIR/commands/neo-feature.md" .claude/commands/neo-feature.md
mkdir -p .cursor/commands/
cp "$TEMPLATE_DIR/commands/neo-project.md" .cursor/commands/neo-project.md
cp "$TEMPLATE_DIR/commands/neo-feature.md" .cursor/commands/neo-feature.md
echo "✓ Fichiers commandes copiés"

cursor .
