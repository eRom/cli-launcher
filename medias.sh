#!/usr/bin/env bash
set -euo pipefail

# Répertoire du projet (défini par rapport à scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(realpath "$SCRIPT_DIR/..")"
TEMPLATE_LOGO="$PROJECT_DIR/logo.png"
OUTPUT_DIR="$PROJECT_DIR/public"

# Vérifier que le logo existe
if [[ ! -f "$TEMPLATE_LOGO" ]]; then
  echo "❌ Fichier logo non trouvé : $TEMPLATE_LOGO"
  exit 1
fi

# Liste des tailles à générer (format : largeurxhauteur:nom_fichier)
declare -A ICON_SIZES=(
  ["180x180"]="apple-touch-icon.png"
  ["16x16"]="favicon-16x16.png"
  ["32x32"]="favicon-32x32.png"
  ["192x192"]="icon-192.png"
  ["512x512"]="icon-512.png"
  ["192x192"]="icon.png"
)

echo "Génération des icônes depuis $TEMPLATE_LOGO vers $OUTPUT_DIR..."

# Créer le dossier public s'il n'existe pas
mkdir -p "$OUTPUT_DIR"

# Boucle de génération
for size in "${!ICON_SIZES[@]}"; do
  filename="${ICON_SIZES[$size]}"
  width="${size%x*}"
  height="${size#*x}"
  outpath="$OUTPUT_DIR/$filename"

  echo " - $filename (${width}×${height})"
  sips -z "$height" "$width" "$TEMPLATE_LOGO" --out "$outpath"
done

# Génération du favicon .ico à partir du PNG 32×32
ICO_SRC="$OUTPUT_DIR/favicon-32x32.png"
ICO_OUT="$OUTPUT_DIR/favicon.ico"

if [[ -f "$ICO_SRC" ]]; then
  echo " - favicon.ico"
  sips -s format ico "$ICO_SRC" --out "$ICO_OUT"
else
  echo "⚠️  Source ICO manquante : $ICO_SRC"
fi

echo "✅ Icônes générées avec succès !"
