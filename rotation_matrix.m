function R = rotation_matrix(angle)
    % Esta función genera una matriz de rotación para un ángulo dado
    % y un eje seleccionado aleatoriamente.
    axes = ['x', 'y', 'z'];

    axis = axes(randi(3));
    
    switch axis
        case 'x'
            R = [1, 0, 0;
                 0, cos(angle), -sin(angle);
                 0, sin(angle), cos(angle)];
        case 'y'
            R = [cos(angle), 0, sin(angle);
                 0, 1, 0;
                 -sin(angle), 0, cos(angle)];
        case 'z'
            R = [cos(angle), -sin(angle), 0;
                 sin(angle), cos(angle), 0;
                 0, 0, 1];
        otherwise
            error('Eje de rotación desconocido.');
    end
end
