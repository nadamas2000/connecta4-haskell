# Quatre en ratlla

Aquest programa s'executa amb 4 (i només 4) paramàmetres.
A l'hora d'execurar el programa passarem els paràmetres de:
    - Número de files (major que 3)
    - Número de columnes (major que 3)
    - Jugador que inicia (1:Jugador, 2:CPU)
    - Estratègies de la CPU (1:Random, 2:Greedy, 3:Smart)
    
Un joc estàndard de 6x7 començant el jugador i estratègia
greedy es pot execurar com:

```bash
> joc 6 7 1 2
```

El joc començarà quan es vegi a la pantalla els missatges
informatius i el tauler vuit tal que així:

```bash
Comienza el juego:
     - Tu símbolo es X y la CPU tiene el símbolo O.
     - Los espacios vacíos se representan por un punto.
     - Las columnas están numeradas para facilitar el seguimiento.
     
El nivel de IA es Greedy
1  2  3  4  5
.  .  .  .  .
.  .  .  .  .
.  .  .  .  .
.  .  .  .  .
 
 Escoge una columna: 

```

el joc acaba quan un dels dos (jugador/CPU) guanya o acaba
la partida en empat.

```bash
 CPU escoje la columna 6
1  2  3  4  5  6  7
.  .  .  .  .  .  .
.  .  .  .  .  .  .
O  .  .  .  .  .  .
X  X  .  .  .  .  .
X  O  .  .  .  .  .
X  X  X  O  O  O  O
 
Has perdido
```


Lamentablement la estratègia `smart` no ha acaba de funcionar
pero la idea plantejada era fer un arbre de posibles moviments
i recollir els que resultaven més ventatjosos (amb més victories)
    
    
    
## Codi

El codi està dividit en les següents seccions:
    - Params Config: Que s'encarrega de verifiar els parametres.
    - Pantalla: Que està destinat a mostrar els taulers.
    - Prueba Ganador: Que verifica si hi ha guanyador.
    - Utiles Matriz de Juego: Presenta diverses funcions generals
            sobre la matriu.
    - Movimientos: Que s'encarrega d'ejectuar el moviment d'un jugador.
    - IA : On es troba tota la lògica de la CPU.
    - Turnos: On es troba l'execució dels torns de cada jugador.
    - Inicio: On es troben les funcions d'inicialització.
