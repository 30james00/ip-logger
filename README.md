# LABORATORIUM PROGRAMOWANIA W CHMURACH OBLICZENIOWYCH

## Zadanie 1

### 3. (max. 20%)  
Należy podać polecenia niezbędne do:  
a. zbudowania opracowanego obrazu kontenera  
`docker build --tag local/z1 .`  
b. uruchomienia kontenera na podstawie zbudowanego obrazu  
`docker run -d --rm -p 5100:8080 --name z1 local/z1`  
c. sposobu uzyskania informacji, które wygenerował serwer w trakcie uruchamiana kontenera
(patrz: punkt 1a)  
`docker container logs z1`  
d. sprawdzenia, ile warstw posiada zbudowany obraz  
`docker history local/z1`

### 4.
Budowanie obrazu z repozytorium na GitHub:  
`docker build --tag local/z1 https://github.com/30james00/ip-logger.git`

Umieszczanie obrazu na DockerHub:  
1. Tworzę repozytorium na hub.docker.com
2. Zmieniam tag obrazu
`docker tag local/z1 30james00/z1`  
3. Loguje się za pomocą Docker ID za pomocą wcześniej stworzonego tokenu  
`docker login -u 30james00` 
4. Wysyłam obraz na repozytorium  
`docker push 30james00/z1`

## Część dodatkowa

### 1.
a. na bazie tego tego obrazu należy uruchomić rejestr w taki sposób by był on dostępny na porcie 6677.  
`docker run -d -p 6677:5000 --name registry registry`  
b. należy pobrać obraz ubuntu w najnowszej wersji a następnie, zmienić jego nazwę i wgrać doutworzonego, prywatnego rejestru.  
`docker pull ubuntu:latest`  
`docker tag ubuntu localhost:6677/ubuntu`  
`docker push localhost:6677/ubuntu`

### 2.
1. Tworzę plik hasła z przykładowym użytkownikiem  
`mkdir auth`  
`docker run --entrypoint htpasswd httpd -Bbn testuser testpassword > auth/htpasswd`
2. Uruchamiam rejestr z kontrolą dostępu  
`docker run -d -p 6677:5000 --name registry -v "$(pwd)"/auth:/auth -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd registry`
3. Logowanie z użyciem wcześniej utworzonego konta  
`docker login localhost:6677`
4. Testowe umieszczenie obrazu w rejestrze  
`docker push localhost:6677/ubuntu`
