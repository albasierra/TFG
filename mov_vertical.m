function mov_vertical (vertical,cursor_handle)

%% Constantes
min_ancho_pulso = 10;
max_espacio_entre_movs = 150;
limit = 2;

%% Variables persistentes 
persistent estado_actual;
persistent cont_pos;
persistent cont_neg;
persistent cont_cero;
persistent cont_inicial;
persistent valor_ant;
persistent instantes_movimientos_arriba;
persistent instantes_movimientos_abajo;

%% Inicialización de las variables que lo necesitan
if isempty(estado_actual)
    estado_actual = 'nuevo_mov';
end

if isempty(cont_inicial)
    cont_inicial = 0;
end

if isempty(valor_ant)
    valor_ant = 0;
end

if isempty(instantes_movimientos_arriba)
    instantes_movimientos_arriba = [];
end

if isempty(instantes_movimientos_abajo)
    instantes_movimientos_abajo = [];
end

%% Limpiar los datos del vector vertical
vector_vertical = zeros(size(vertical)); % Inicializar el vector limpiado

for i = 1:length(vertical)
    if vertical(i) >= limit
        vector_vertical(i) = 1;
    elseif vertical(i) <= -limit
        vector_vertical(i) = -1;
    else
        vector_vertical(i) = 0;
    end
end


%% Bucle Principal
for i = 1:length(vertical)
    valor = vector_vertical(i);
    % Lógica de la máquina de estados
    switch estado_actual
        case 'nuevo_mov'
            %disp('Estamos en el estado inicial.');
            % Acciones asociadas al estado
            cont_pos = 0;
            cont_neg = 0;
            cont_cero = 0;
            % Transición al siguiente estado
            %Se añade la condición de que se cuenten un minimo de veces 
            %valor inicial para evitar pequeñas interferencias al inicio de
            %un movimiento nuevo
            if(valor == 1 && valor_ant == 1 && cont_inicial>= min_espacio_entre_pulsos) 
                cont_inicial = 0;
                estado_actual = 'positivo';
            elseif(valor == -1 && valor_ant == -1 && cont_inicial>= min_espacio_entre_pulsos)
                estado_actual = 'negativo';
                cont_inicial = 0;
            elseif(valor == 0) 
                estado_actual = 'nuevo_mov';
            else
                cont_inicial = cont_inicial+1;
                estado_actual = 'nuevo_mov';
            end;
            
        case 'positivo'
            %disp('Estamos en el estado positivo.');
            % Acciones asociadas al estado
            cont_pos=cont_pos+1;
            % Transición al siguiente estado 
            if(valor == 1) 
                estado_actual = 'positivo';
            elseif(valor == -1)
                estado_actual = 'negativo';
            elseif (cont_neg>=min_ancho_pulso &&  cont_pos>=min_ancho_pulso)
                %disp('Movimiento a la arriba.');
                mover_cursor(cursor_handle,0,1);
                instantes_movimientos_arriba(end+1) = i;
                % Transición al siguiente estado 
                estado_actual = 'nuevo_mov'; 
            elseif (cont_cero>=5 && valor_ant ~= 1)
                estado_actual = 'nuevo_mov';
            else
                estado_actual = 'cero';                
            end;
            
        case 'negativo'
            %disp('Estamos en el estado negativo.');
            % Acciones asociadas al estado
            cont_neg=cont_neg+1;
            % Transición al siguiente estado 
            if(valor == 1) 
                estado_actual = 'positivo';
            elseif(valor == -1)
                estado_actual = 'negativo';
            elseif (cont_neg>=min_ancho_pulso &&  cont_pos>=min_ancho_pulso)
                %disp('Movimiento a la abajo.');
                mover_cursor(cursor_handle,0,-1);
                instantes_movimientos_abajo(end+1) = i;
                % Transición al siguiente estado 
                estado_actual = 'nuevo_mov'; 
            elseif (cont_cero>=5 && valor_ant ~= -1)
                estado_actual = 'nuevo_mov';
            else
                estado_actual = 'cero';                
            end;
        case 'cero'
            %disp('Estamos en el estado cero.');
            % Acciones asociadas al estado
            cont_cero = cont_cero +1;
            % Transición al siguiente estado 
            if(valor == 1) 
                estado_actual = 'positivo';
            elseif(valor == -1)
                estado_actual = 'negativo';
             % El hecho de comprobar qie el valor anterior fuese 0 es para
             % evitar volver al inicio por un valor 0 obtenido en medio de
             % un pulso
            elseif (cont_cero>=max_espacio_entre_movs && valor_ant == 0)
                 estado_actual = 'nuevo_mov';
            else
                estado_actual = 'cero';                
            end;
        otherwise
            disp('Estado no reconocido.');
            break; % Salimos del bucle si el estado no es reconocido
    end
    
    valor_ant = valor;
end

