#!/bin/bash
set -e

ORIGINAL="$1"
MODIFICADO="$2"
PATCH_SAIDA="${3:-config.patch}"

if [ -z "$ORIGINAL" ] || [ -z "$MODIFICADO" ]; then
    echo "Uso: $0 <arquivo_original> <arquivo_modificado> [nome_do_patch.patch]"
    exit 1
fi

# O || true evita que o script pare, pois o 'diff' retorna código 1 quando encontra diferenças
diff -u "$ORIGINAL" "$MODIFICADO" > "$PATCH_SAIDA" || true

echo "Patch criado com sucesso em: $PATCH_SAIDA"