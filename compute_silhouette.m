function s = compute_silhouette(Z, y)
    % Cálculo estándar del índice de silueta
    y = int32(y);  % o int32(labels)

    s_values = silhouette(Z, y);
    s = mean(s_values);
end
