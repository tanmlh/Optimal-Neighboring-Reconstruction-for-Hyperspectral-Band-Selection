function L = faster_ONR_init(Y)
    [n, d] = size(Y);
    
    %% The l2 norm of each band is normalized to 1
    Y = Y ./ repmat(sum(Y.^2, 1).^0.5, [n, 1]);
    Sigma = Y'*Y;
    [V, Eigen] = eig(Sigma);
    
    %% Transfer Y to X to reduce the data dimension
    X = Eigen .^ 0.5 * V';
    
    %% Delta(l, r, 1:4) are the four elements of ([X_l X_r]^T[X_l X_r])^-1
    Delta = zeros(d, d, 4);
    for l = 1 : d
        for r = 1 : d
            temp = Sigma(l,l) * Sigma(r,r) - Sigma(l,r)^2;
            Delta(l,r,1) = Sigma(r,r)/temp;
            Delta(l,r,2) = -Sigma(l,r)/temp;
            Delta(l,r,3) = -Sigma(l,r)/temp;
            Delta(l,r,4) = Sigma(l,l)/temp;
        end
    end
   
    %% Allocate for the loss produced by C(L, 3) times of reconstruction.
    L = inf(d+2, d+2, d);
    
    %% Pre-process the loss of each interval.
    for l = 1 : d
        for r = l + 2 : d
            j = l+1:r-1;

            temp_1 = Sigma(l,j) .* (Sigma(l,j) * Delta(l,r,1) + Sigma(r,j) * Delta(l,r,3));
            temp_2 = Sigma(r,j) .* (Sigma(l,j) * Delta(l,r,2) + Sigma(r,j) * Delta(l,r,4));
            L(l,r,j) = 1 - temp_1 - temp_2;
            L(l,r,j) = L(l,r,j).^.5;

        end
    end
    

    %% Reconstruct the first r-1 bands using X_r
    for r = 2 : d
        j = r-1;
        Xj = X(:, j);
        ej = norm(Xj - Sigma(r,j) * X(:, r));
        L(d+1, r, j) = ej;
        
        k = 1:j-1;
        ek = ej^2 - 2*Sigma(r,k) .* (Sigma(r,k) - Sigma(r,j))...
            + ((Sigma(r,k) - Sigma(r,j))).^2;
        ek = ek .^ 0.5;
        L(d+1, r, k) = ek; 
        
        % Equivalent formula:
        % for k = 1 : j-1
        %    ek = ej^2 + Sigma(k,k) - Sigma(j,j) ...
        %        - 2*Sigma(r,k) / Sigma(r,r)^0.5 * (Sigma(r,k) - Sigma(r,j))...
        %        + Sigma(r,r) * ((Sigma(r,k) - Sigma(r,j)) / Sigma(r,r)^0.5)^2;
        %    ek = ek ^ 0.5;
        %    L(d+1, r, k) = ek; 
        % end
    end
    
    %% Reconstruct the last d-l bands using X_l for each possible l
    for l = 1 : d-1
        j = l+1;
        Xj = X(:, j);
        ej = norm(Xj - Sigma(l,j) * X(:, l));
        L(l, d+2, j) = ej;
        
        k = j+1:d;
        ek = ej*ej - 2 * Sigma(l,k) .* (Sigma(l,k) - Sigma(l,j))...
            + ((Sigma(l,k) - Sigma(l,j))) .^ 2;
        ek = ek .^ 0.5;
        L(l, d+2, k) = ek; 
        
        % Equivalent formula:
        % for k = j + 1 : d
        %    ek = ej^2 + Sigma(k,k) - Sigma(j,j) ...
        %        - 2*Sigma(l,k) / Sigma(l,l)^0.5 * (Sigma(l,k) - Sigma(l,j))...
        %        + Sigma(l,l) * ((Sigma(l,k) - Sigma(l,j)) / Sigma(l,l)^0.5)^2;
        %    ek = ek ^ 0.5;
        %    L(l, d+2, k) = ek; 
        % end
    end
end