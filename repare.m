function B = repare(B)
    %repara una base para que sea ortonormal
    n = size(B,1);
    dot_product = dot(B(1:(n-1), 1), B(1:(n-1), 2));    

    B(n, 2) = -dot_product / B(n, 1);
    B(n-1,3) = dot(B((1:n-2),1) , B((1:n-2),3)) * B(n,2) - dot(B((1:n-2),2) , B((1:n-2),3)) * B(n,1);
    B(n-1,3) =  B(n-1,3)/ (B(n-1,2)*B(n,1) - B(n-1,1) * B(n,2));
    B(n,3) = - dot(B(1:n-1,2), B(1:n-1,3)) / B(n,2);

    for j = 1:3
        B(:, j) = B(:, j) / norm(B(:, j));
    end
end