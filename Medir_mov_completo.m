   
function Medir_mov_completo 

%%%%%% VARIABLES GLOBALES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global Fs;                     %Frecuencia de muestreo
global duration;               %Duracion de la prueba
global tam;                    %Tamaño de bloque
global n_de_bloque;            %Indice de bloque
global n_tot_bloq_por_prueba;  %Num de bloques por prueba
global A1;                     %Objeto tarjeta NI
global fig_sujeto;             %Figura donde ploteamos el CUE
global puntero;                %Puntero que se va a desplazar

%Para calibración con CUE, duration=20s
Fs=128;
duration=20;
tam=16;

n_de_bloque=0;

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
%ANTES DE EMPEZAR, DIBUJO EL CURSOR EN EL INSTANTE INICIAL (centro)
%%%%%NV ESTE CURSOR INICIAL PUEDE SERVIR TANTO PARA LA CALIBRACION COMO
%%%%%PARA GENERAL EL MOVIMIENTO DEL CURSOR EN LA FASE DE CONTROL
    fig_sujeto = figure;
    % Dibujar un punto de dispersión en el centro
    puntero = scatter(0,0,100,'r','filled');
    
    % Definir límites de los ejes
    xlim([-10, 10]);
    ylim([-10, 10]);
    
    % Añadir etiquetas y título
    xlabel('Eje X');
    ylabel('Eje Y');
    title('Gráfico con Cursor Móvil');
    grid on;


%%%%%% 1- INICIALIZA LAS VARIABLES DE LA TARJETA %%%%%%%%%%%%%%%%%%%%%%%%

A1=analoginput('nidaq','Dev1'); %Muestreamos con tarjeta de National Instruments
set(A1,'InputType','SingleEnded','BufferingMode','auto');
%set(A1,'InputType','NonReferencedSingleEnded','BufferingMode','auto'); %Para señales con su propio GND

addchannel(A1,[0 1]);                      %Añadimos dos canales
   
set(A1,'SampleRate',Fs);                  %Frec. de muestreo
set(A1,'SamplesPerTrigger',duration*Fs);  %Numero total de muestras a adquirir.
set(A1,'SamplesAcquiredFcnCount',tam);    %Muestras adquiridas por operacion: el tamaño del bloque
 
n_tot_bloq_por_prueba=Fs*duration/tam;     %Numero de bloques que se muestrean en cada prueba

%%%NV CON ESTA INSTRUCCION LO QUE HAGO ES PREPARAR LA TARJETA DE ADQUISICION DAQ
%%%DE MANERA QUE CADA VEZ QUE LLEGA UN CONJUNTO DE MUESTRAS IGUAL A "tam",
%%%SE EJECUTA A FUNCION "Prueba_mov_completo". ESA FUNCIÓN SERÁ LA
%%%ENCARGADA DE PROCESAR LOS DATOS QUE VAN LLEGANDO
set(A1,'SamplesAcquiredFcn',{'Prueba_mov_completo',tam});

    
%%%%%% 2- EMPIEZA A MUESTREAR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   



tic;                    %Inicializo el reloj
tiempo_inicial=toc;     %Calculo el tiempo inicial;(No puedo hacer 'tiempo_inicial=tic')

start(A1);              %Lanzamos a la tarjeta la orden de muestrear y...
pause(duration+tam/Fs); %Esperamos a prueba.m

tiempo_adquisicion=toc;  %Calculamos el tiempo real que hemos tardado, que nos gustaria que fuese lo mas parecido posible a 'duration'.
delete(fig_sujeto);
delete(A1); %Liberamos memoria



