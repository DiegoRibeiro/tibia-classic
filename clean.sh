#!/bin/bash
set -e

echo "Selecione o tipo de limpeza desejado:"
echo "1) Apenas pastas extraídas em 'files/' (mantém os zips/rars e zera o setup)"
echo "2) Tudo dentro de 'files/' (remove zips, rars e extraídos)"
echo "3) Apenas o conteúdo da pasta 'data/' (mapas e dados do jogo)"
echo "4) Cancelar"
echo
read -p "Opção [1-4]: " option

clean_extracted() {
    echo "Analisando pastas extraídas em 'files/'..."

    local targets=(
        "files/dennis-libraries"
        "files/querymanager"
        "files/realotsloginserver-master"
        "files/tibiagame"
    )

    # 1. Filtra e armazena apenas os caminhos de pastas que realmente existem
    local existing_targets=()
    for target in "${targets[@]}"; do
        if [ -d "$target" ]; then
            existing_targets+=("$target")
        fi
    done

    if [ ${#existing_targets[@]} -eq 0 ]; then
        echo "Nenhuma das pastas extraídas foi encontrada para remoção."
        rm -f .setup_complete
        return 0
    fi

    # 2. Conta o total de arquivos dentro das pastas encontradas
    local total_files
    total_files=$(find "${existing_targets[@]}" -mindepth 1 | wc -l)

    if [ "$total_files" -eq 0 ]; then
        # Caso as pastas existam mas estejam vazias
        rm -rf "${existing_targets[@]}"
        rm -f .setup_complete
        echo "Pastas vazias e arquivo .setup_complete removidos com sucesso!"
        return 0
    fi

    echo "Removendo $total_files arquivos das pastas extraídas..."

    # 3. Executa a remoção com o indicador de progresso (pv) se disponível
    if command -v pv >/dev/null 2>&1; then
        find "${existing_targets[@]}" -mindepth 1 -print -delete | \
            pv -l -s "$total_files" -N "Deletando" > /dev/null
        rm -rf "${existing_targets[@]}"
    else
        rm -rf "${existing_targets[@]}"
    fi

    rm -f .setup_complete
    echo "Pastas extraídas e arquivo .setup_complete removidos com sucesso!"
}

clean_all() {
    echo "Analisando conteúdo do diretório files/..."

    if [ ! -d "files/" ]; then
        echo "Pasta 'files/' não encontrada."
        return 0
    fi

    # Conta o total de itens que serão removidos
    local total_files
    total_files=$(find files/ -mindepth 1 ! -name '.gitkeep' | wc -l)

    if [ "$total_files" -eq 0 ]; then
        echo "A pasta 'files/' já está vazia."
        rm -f .setup_complete
        return 0
    fi

    echo "Removendo $total_files arquivos..."

    if command -v pv >/dev/null 2>&1; then
        find files/ -mindepth 1 ! -name '.gitkeep' -print -delete | \
            pv -l -s "$total_files" -N "Deletando" > /dev/null
    else
        echo "Aviso: 'pv' não está instalado. Removendo sem indicador de progresso..."
        find files/ -mindepth 1 ! -name '.gitkeep' -delete
    fi

    rm -f .setup_complete
    echo "Diretório files/ limpo e .setup_complete removido!"
}

clean_data() {
    echo "Analisando arquivos em 'data/'..."

    if [ -d "data/" ]; then
        # 1. Conta o número total de itens para calcular os 100%
        local total_files
        total_files=$(find data/ -mindepth 1 ! -name '.gitkeep' | wc -l)

        if [ "$total_files" -eq 0 ]; then
            echo "A pasta 'data/' já está vazia."
            return 0
        fi

        echo "Removendo $total_files arquivos..."

        if command -v pv >/dev/null 2>&1; then
            # Sem a flag '-w', o pv expande a barra para a largura total do terminal
            find data/ -mindepth 1 ! -name '.gitkeep' -print -delete | \
                pv -l -s "$total_files" -N "Deletando" > /dev/null
        else
            find data/ -mindepth 1 ! -name '.gitkeep' -delete
        fi

        echo "Conteúdo de 'data/' removido com sucesso!"
    else
        echo "Pasta 'data/' não encontrada."
    fi
}

case "$option" in
    1)
        clean_extracted
        ;;
    2)
        read -p "Tem certeza que deseja apagar os arquivos compactados originais em 'files/'? (s/N): " confirm
        if [[ "${confirm,,}" == "s"* ]]; then
            clean_all
        else
            echo "Operação cancelada."
        fi
        ;;
    3)
        read -p "Tem certeza que deseja apagar TODOS os mapas e dados em 'data/'? (s/N): " confirm
        if [[ "${confirm,,}" == "s"* ]]; then
            clean_data
        else
            echo "Operação cancelada."
        fi
        ;;
    4)
        echo "Operação cancelada."
        exit 0
        ;;
    *)
        echo "Opção inválida."
        exit 1
        ;;
esac