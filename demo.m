%% load data
A = double(importdata('Indian_pines_corrected.mat'));
X = permute(A, [3, 1, 2]);

%% normalization
X = X(:, :);
minv = min(X(:)); maxv = max(X(:));
X = (X - minv) / (maxv - minv);

%% run
k = 30; % Number of bands
ONR_L = ONR_init(X');
band_set = ONR(X, ONR_L, k)