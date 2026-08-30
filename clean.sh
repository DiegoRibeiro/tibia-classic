#!/bin/bash
set -e

echo "Selecione o tipo de limpeza desejado:"
echo "1) Apenas pastas extraídas (mantém os zips/rars e zera o setup)"
echo "2) Tudo dentro de 'files/' (remove zips, rars e extraídos)"
echo "3) Cancelar"
echo
read -p "Opção [1-3]: " option

clean_extracted() {
    echo "Removendo pastas extraídas..."
    rm -rf files/dennis-libraries \
           files/querymanager \
           files/realotsloginserver-master \
           files/tibiagame
    
    rm -f .setup_complete
    echo "Pastas extraídas e arquivo .setup_complete removidos com sucesso!"
}

clean_all() {
    echo "Limpando todo o conteúdo do diretório files/..."
    find files/ -mindepth 1 ! -name '.gitkeep' -delete
    
    rm -f .setup_complete
    echo "Diretório files/ limpo e .setup_complete removido!"
}

case "$option" in
    1)
        clean_extracted
        ;;
    2)
        read -p "Tem certeza que deseja apagar os arquivos compactados originais? (s/N): " confirm
        # Converte a resposta para minúscula e checa se começa com 's'
        if [[ "${confirm,,}" == "s"* ]]; then
            clean_all
        else
            echo "Operação cancelada."
        fi
        ;;
    3)
        echo "Operação cancelada."
        exit 0
        ;;
    *)
        echo "Opção inválida."
        exit 1
        ;;
esac