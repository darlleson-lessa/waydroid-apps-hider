# ***waydroid-apps-hider***

Script que monitora a criação de novos atalhos do Waydroid e os oculta automaticamente para manter o menu de apps limpo.

## Descrição
No Linux, o Waydroid gera automaticamente arquivos desktop para cada aplicativo Android instalado, o que polui o menu de aplicativos do sistema host.

Este script automatiza a organização do sistema utilizando o ***inotify-tools***. Ele monitora o diretório de aplicações do usuário em tempo real e aplica a propriedade ***NoDisplay=true*** a qualquer novo atalho do Waydroid detectado.

## Funcionamento
O script executa duas ações principais:
1. **Limpeza inicial:** Varre o diretório de aplicações e oculta todos os arquivos ***waydroid.\*.desktop*** existentes.
2. **Monitoramento ativo:** Utiliza o ***inotifywait*** para detectar a criação de novos arquivos no diretório ***~/.local/share/applications***, aplicando a correção automaticamente.

## Requisitos
Este projeto foi desenvolvido e testado no **Ubuntu 25.10**. Para o funcionamento do monitoramento, é necessário instalar o pacote ***inotify-tools***:

```bash
sudo apt update && sudo apt install inotify-tools -y
````

## Instalação e uso

1. Realize o download do script ***waydroid-apps-hider***.
2. Garanta privilégios de execução ao binário:
```bash
chmod +x waydroid-apps-hider
```
