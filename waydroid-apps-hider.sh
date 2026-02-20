#!/bin/bash

# Script de monitoramento e padronização de Arquivos desktop do Waydroid
#
# Explicação do funcionamento:
# - Monitora "$HOME/.local/share/applications"
# - Corrige arquivos waydroid.*.desktop já existentes
# - Remove qualquer chave "NoDisplay" com o valor "false" e o altera para o valor "true" ou adiciona, caso não haja a chave "NoDisplay"
# - Observa o diretório em tempo real e aplica a correção automaticamente

# Diretório de monitoramento
WATCH_DIR="$HOME/.local/share/applications"

# Função: update_nodisplay
# Objetivo: Remove a linha com a chave "NoDisplay" com o valor "false", adiciona a chave "NoDisplay" com valor "true" e limpa arquivos com chaves "NoDisplay" duplicadas.
update_nodisplay() {
    local desktop_file="$1"
    local desktop_name
    desktop_name=$(basename "$desktop_file")

    # Verifica se há exatamente uma ocorrência de "NoDisplay=true" e nenhuma de "NoDisplay=false"
    local nodisplay_count
    nodisplay_count=$(grep -c "^NoDisplay=true" "$desktop_file")

    if [ "$nodisplay_count" -eq 1 ] && ! grep -q "^NoDisplay=false" "$desktop_file"; then
        return 0
    fi

    # Validação de Segurança: Verifica se existe a seção [Desktop Entry] e se há um Name= dentro dela
    if ! sed -n '/^\[Desktop Entry\]/,/^\[/p' "$desktop_file" | grep -q "^Name="; then
        echo "ERRO: O arquivo '$desktop_name' não possui a chave 'Name' dentro da seção [Desktop Entry]. Operação cancelada." >&2
        return 1
    fi

    # Remove todas as linhas que definem a chave "NoDisplay" para evitar duplicatas
    sed -i '/^NoDisplay=/d' "$desktop_file"

    # Inserção da chave "NoDisplay" com valor "true" logo após a primeira chave "Name" dentro de [Desktop Entry]
    sed -i '/^\[Desktop Entry\]/,/^\[/ s/^Name=.*/&\nNoDisplay=true/' "$desktop_file"
    
    echo "Corrigido: $desktop_name"
}

echo "Iniciando o processo de monitoramento..."

# Corrige arquivos waydroid.*.desktop que já existem no diretório
for f in "$WATCH_DIR"/waydroid.*.desktop; do
    update_nodisplay "$f"
done

# Monitoramento em tempo real do diretório usando inotify-tools
inotifywait -m -e create -e moved_to -e close_write --format '%f' "$WATCH_DIR" | while read NEWFILE; do
    # Seleciona somente arquivos que seguem o padrão waydroid.*.desktop
    if [[ "$NEWFILE" =~ ^waydroid\..*\.desktop$ ]]; then
        update_nodisplay "$WATCH_DIR/$NEWFILE"
    fi
done
