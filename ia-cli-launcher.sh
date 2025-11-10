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

npm i @vercel/analytics --silent
echo "✓ @vercel/analytics installé"

npm install --save-dev @types/node --silent
echo "✓ [dev] Types Node installés"

npm install --save-dev sharp imagemin imagemin-webp imagemin-avif --silent
echo "✓ [dev] Sharp, imagemin, imagemin-webp et imagemin-avif installés"

npm install --save-dev lighthouse chrome-launcher puppeteer --silent
echo "✓ [dev] Lighthouse, chrome-launcher et puppeteer installés"

npm install --save-dev prettier prettier-plugin-tailwindcss eslint-plugin-jsx-a11y@latest @axe-core/cli@latest --silent 
echo "✓ [dev] Prettier, eslint-plugin-jsx-a11y, axe-core installés"

# Copy templates
cp -rf "$TEMPLATE_DIR/" .

# Package scripts
npm pkg set scripts.clean="rm -rf .next out dist"
npm pkg set scripts.type-check="tsc --noEmit"
npm pkg set scripts.format="prettier --write ."
npm pkg set scripts.lint="prettier --check ."
npm pkg set scripts["lint:audit"]="npx eslint . --ext .js,.jsx,.ts,.tsx --format=json > reports/eslint-a11y-report.json"
npm pkg set scripts["format:staged"]="prettier --write"
npm pkg set scripts["axe"]="npx axe http://localhost:3000 --tags wcag2a,wcag2aa,wcag21aa --save ./reports/axe.json --exit"
npm pkg set scripts["lighthouse:desktop"]="lighthouse http://localhost:3000 --preset=desktop --output=json --output-path=./reports/perf-desktop-report --chrome-flags=\"--headless\""
npm pkg set scripts["lighthouse:mobile"]="lighthouse http://localhost:3000 --preset=perf --output=json --output-path=./reports/perf-mobile-report --chrome-flags=\"--headless\""
npm pkg set scripts["postinstall"]="prisma generate"
echo "✓ Package scripts installés"

# Ignore outputs
echo ".cursor/outputs/" >> .gitignore


# Launch Cursor
cursor .

