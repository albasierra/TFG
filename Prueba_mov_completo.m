function Prueba_mov_completo(obj, event, tambloque)
 
%'obj' y 'event' son parametros que rellena Matlab, pues
%esta funcion se usa como 'SamplesAcquiredAction' de la
%tarjeta. El programa que define dicha funcion es el Medir.m
%'tambloque' es el 'tam' con que se llama la funcion 'SamplesAcquiredAction'
 
%%%%%% VARIABLES GLOBALES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
global Fs;                     %Frecuencia de muestreo
global duration;               %Duracion de la prueba
global n_de_bloque;            %Indice de bloque
global n_tot_bloq_por_prueba;  %Num de bloques por prueba
global puntero;                %Puntero que se va a desplazar
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%Las variables 'persistent' son locales dentro de la funcion que las declara pero su valor se conserva entre llamada y llamada que se haga a esa funcion
persistent muestratotal1; %%NV LAS MUESTRAS QUE VAN LLEGANDO POR CADA CANAL SE ALMACENAN EN ESTAS VARIABLES "muestratotal1" Y "muestratotal2" (2 CANALES EN ESTE CASO)
persistent muestratotal2;
persistent n_de_bloque_tot;
 
%%%%%% 0 - COMPROBACIONES INICIALES %%%%%%

if isempty(n_de_bloque), 
    n_de_bloque=0;
end;
 
if isempty(n_de_bloque_tot),%Se hace la primera vez que se llama a Prueba(una vez por ensayo)
    n_de_bloque_tot=0;  %La uso para llevar la cuenta de todas las ventanas de un ensayo    
    muestratotal1=0;
    muestratotal2=0;
end;
 
%%%%%% 1 - SACAMOS MUESTRAS DE LA TARJETA %%%%%% 
 
[d,t] = getdata(obj,tambloque); %Guarda en 'd' las 'tambloque' muestras y en 't' el eje de tiempos
 
 
 
%%%%%% 2 - PROCESAMOS LAS MUESTRAS DE CADA BLOQUE %%%%%%
 
signal_1=d(:,1); %Canal UNO
signal_2=d(:,2); %Canal DOS
 
mov_horizontal(signal_1,puntero);
mov_vertical(signal_2,puntero);
 
 
%%%%%% 3 - ALMACENAMOS LA MUESTRAS %%%%%%
 
%En muestra1, muestra2 y tiempo voy añadiendo el bloque de tambloque muestras que me dan cada vez que se llama este programa.
 
%tiempoi = toc; %Me indica el instante de tiempo en que adquiero el bloque de muestras (coincide con tiempo1)
 
inicio = n_de_bloque*tambloque + 1;  %Es la posicion de la 1ª muestra a almacenar
 
muestra1(inicio : inicio + tambloque-1)= d(:,2); %muestra1 es el canal 1
muestra2(inicio : inicio + tambloque-1)= d(:,1); %muestra2 es el canal 2
tiempo(inicio : inicio + tambloque-1)= t;
 
%En muestratotal almaceno todas las muestras de todo el ensayo (durante un
%ensayo se hacen varias pruebas)
inicio_ensayo = n_de_bloque_tot * tambloque + 1;
 
muestratotal1(inicio_ensayo : inicio_ensayo + tambloque-1)= d(:,1); %muestra1 es el canal 1
muestratotal2(inicio_ensayo : inicio_ensayo + tambloque-1)= d(:,2); %muestra2 es el canal 2
tiempototal(inicio_ensayo : inicio_ensayo + tambloque-1)=t;
 
%Una vez captado un bloque, incremento el indice para el siguiente bloque:
 
n_de_bloque = n_de_bloque + 1;   %%%CADA "tam" BLOQUE, SE INVREMENTA ESTA VARIABLE. EN ESTE CASO, DADA SEGUNDO
n_de_bloque_tot = n_de_bloque_tot+1;
 
n_tot_bloq_por_prueba= duration * Fs/tambloque;
 

%%%%%% 4 - GUARDAMOS LOS RESULTADOS %%%%%%

%  Una vez que 'n_de_bloque' es igual al numero de bloques a adquirir por cada prueba,lo reseteo. Cuando acabe una prueba, habré guardado 'duration' sg (standar=7sg) usando ventanas de tambloque muestras(=10msg a Fs=130Hz(standar)), así que en total tendré: nºtotal de bloques = duration * Fs/tambloque = {standar} = 7 * 130/13
 
if n_de_bloque == n_tot_bloq_por_prueba, %Cuando se han capturado todos los bloques de una prueba,
    
    save('resultados_canal1.mat','muestratotal1');
    save('resultados_canal2.mat','muestratotal2'); %Grabo el ensayo completo.
    
    n_de_bloque=0; %Inicializo la variable n_de_bloque.
    
end;



