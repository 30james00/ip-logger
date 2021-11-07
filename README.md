# LABORATORIUM PROGRAMOWANIA W CHMURACH OBLICZENIOWYCH

## Zadanie 1

3. (max. 20%)  
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