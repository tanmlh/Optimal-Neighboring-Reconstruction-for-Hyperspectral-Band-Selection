%  The main function of ONR algorithm:
%  input:
%  X: d*n data matrix
%  L: (d+2) * (d+2) * d matrix that achieved in ONR_init
%  m: the number of the desired band
% output:
% band_set: vector that contains the index of the selected bands

function [band_set, S] = ONR(X, L, m)
    %% initialization
    [d, ~] = size(X); len = 100;
    S = zeros(d+2, d+2);
    S_cnt = S;

    % The ratio of the successfully reconstructed bands
    suc_rec_ratio = zeros(len, 1);
    
    %% perform a reconstruction without the limitation of tau
    for i = 2 : d
        S(d+1, i) = sum(L(d+1, i, 1:i-1));
    end
    
    for j = 3 : d
        for i = 1:j-2
            S(i, j) = sum(L(i, j, i+1:j-1));
        end
    end
    
    for i = 1 : d-1
        S(i, d+2) = sum(L(i, d+2, i+1:d));
    end
    band_set = search_band_set(S, m);
    
    %% set the upper bound of tau to the max possible reconstruction error
    l_tau = 0; [~, r_tau] = cal_rec_err(L, band_set, 0, zeros(d, 1));
    S = zeros(d+2, d+2);
    
    %% get the indexes of noisy bands
    noisy_band_id = get_noisy_band(L);
    
    %% sort all the elements of L
    ids1 = find(L <= r_tau);
    L_ele = L(ids1); 
    [L_ele, ids2] = sort(L_ele(:, 1));
    
    %% get S for each value of tau, and search the desired band set
    taus = linspace(l_tau, r_tau, len);
    last_tau = 0; l_id = 0;
    for tau_id = 1 : size(taus, 2)
        cur_tau = taus(tau_id);
        if cur_tau == 0
            continue;
        end
        % set cur_tau to the upper bound of L_ele and use binary search to find the id
        r_id = get_updated_ids(L_ele(:, 1), cur_tau);
        
        % update S using the elements of L whose values are between (last_tau, cur_tau)
        i = l_id+1:r_id;
        if size(i, 2) ~= 0      
            real_id = ids1(ids2(i));
            temp = rem(real_id, (d+2) * (d+2)); 
            temp(temp == 0) = (d+2)*(d+2);
            r = ceil(temp ./ (d+2));
            l = rem(temp, d+2); l(l == 0) = d+2;
            S_id = (r-1) .* (d+2) + l;
            
            % update S since tau has increased
            for i = 1:size(real_id, 1)
                S(S_id(i)) = S(S_id(i)) + L(real_id(i)) - last_tau;
                S_cnt(S_id(i)) = S_cnt(S_id(i)) + 1;
            end
            
            % some elements of L are now smaller than cur_tau, so update S
            for l = 1 : d-2
                for r = l+1 : d
                    S(l, r) = S(l, r) + ((r-l-1) - S_cnt(l, r)) * (cur_tau - last_tau);
                end
            end
            for r = 2 : d
                S(d+1, r) = S(d+1, r) + (r-1-S_cnt(d+1, r)) * (cur_tau - last_tau);
            end
            for l = 1 : d-1
                S(l, d+2) = S(l, d+2) + (d-l-S_cnt(l,d+2)) * (cur_tau - last_tau);
            end
            
        end
        % prepare for the next iteration
        last_tau = cur_tau;
        l_id = r_id;
        
        % search the band set using current S
        cur_band_set = search_band_set(S, m);
        suc_rec_ratio(tau_id) = cal_rec_err(L, cur_band_set, cur_tau, noisy_band_id);
        
        % if more than 95% clean bands can be well reconstructed, break
        if suc_rec_ratio(tau_id) > 0.95
            band_set = cur_band_set;
            break;
        end
    end
    
end
