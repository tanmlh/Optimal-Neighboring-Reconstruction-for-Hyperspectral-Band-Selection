%% Use Dynamic Programming to find the optimal combination of band.
function [band_set] = search_band_set(S, m)
    [d, ~] = size(S); d = d - 2;
    D = inf(d+1, m+1);
    Q = zeros(d+1, m+1);
    band_set = zeros(1, m);
        %% Initialize
        D(1:d, 1) = S(d+1, 1:d);
        
        %% Search
        for j = 2 : m
            for i = j : d
                for k = i - 1 : -1 : j - 1
                    if D(k, j-1) + S(k, i) < D(i, j)
                        D(i, j) = D(k, j-1) + S(k, i);
                        Q(i, j) = k;
                    end
                end
            end
        end

        for i = m : d
            if D(d+1, m+1) > D(i, m) + S(i, d+2)
               D(d+1, m+1) = D(i, m) + S(i, d+2);
               Q(d+1, m+1) = i;
            end
        end

        %% Get the band subset
        band_set(m+1) = d + 1;
        for j = m : -1 : 1
            band_set(j) = Q(band_set(j+1), j+1);
        end
        band_set = band_set(1 : m);
end

