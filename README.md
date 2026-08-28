# Tibia Classic

## Instalação do WSL no Windows

O projeto utiliza WSL 2 (Windows Subsystem for Linux) para executar o ambiente Linux no Windows.

1. Instalar o WSL

Abra o PowerShell como Administrador e execute:

wsl --install

Esse comando instala o WSL 2 e, por padrão, a distribuição Ubuntu.

Após a instalação, reinicie o computador.

2. Configurar o Ubuntu

Depois de reiniciar, abra o Ubuntu pelo menu Iniciar.

Na primeira execução, o Ubuntu solicitará:

Nome de usuário Linux
Senha Linux

Esses dados são usados somente dentro do ambiente Linux.

3. Verificar a instalação

No PowerShell, execute:

wsl -l -v

O resultado deve ser semelhante a:

  NAME      STATE     VERSION
* Ubuntu    Stopped   2

O valor 2 na coluna VERSION indica que o Ubuntu está utilizando WSL 2.

Também é possível verificar a versão do WSL instalado com:

wsl --version
4. Atualizar o Ubuntu

Abra o Ubuntu e execute:

sudo apt update
sudo apt upgrade -y
Documentação oficial

Para mais informações, consulte a documentação oficial da Microsoft:

https://learn.microsoft.com/pt-br/windows/wsl/install

## instalar o docker no wsl usando os comandos.
https://docs.docker.com/engine/install/ubuntu/

## extrair os arquivos desse link e colocar na pasta files
https://www.mediafire.com/file/yg73thyiv6iveu0/RealTibia77Files.zip/file

## Init
./start.sh

## Shutdown
./stop.sh

## Test character
191140
309E6093CAEF

## Limpar o docker
docker system prune -a
docker volume prune -a

## Verificar quanto o docker esta utilizado
docker system df
