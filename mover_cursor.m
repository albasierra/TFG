function mover_cursor(cursor_handle, izquierda_derecha, arriba_abajo)
    % Obtener las coordenadas actuales del cursor
    x_actual = get(cursor_handle, 'XData');
    y_actual = get(cursor_handle, 'YData');

    % Calcular las nuevas coordenadas del cursor
    x_nuevo = x_actual + izquierda_derecha;
    y_nuevo = y_actual + arriba_abajo;

    % Actualizar la posición del cursor
    set(cursor_handle, 'XData', x_nuevo, 'YData', y_nuevo);
end