buildar sem compressao
docker buildx bake tibiagame

docker save -o login_imagem.tar tibia-77-login:latest
docker save -o game_imagem.tar tibia-77-tibiagame:latest

ver o conteudo do index.json.

pelo hash dele.

abrir no notepad e pegar novamente um hash

depois abrir o arquivo hash e vai ter a seguinte informação
as camadas com compressao ou sem

 "layers": [
    {
      "mediaType": "application/vnd.oci.image.layer.v1.tar+gzip",
      "digest": "sha256:d544298cabd50e7c86bfef1e52b67f01db6b3a57bfecfe37a851873dee83e52a",
      "size": 29736943
    },


nesse caso ta comprimido.

