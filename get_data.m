function [Dataset] = get_data(dataset_name)
    %% import the dataset
    switch dataset_name
        case 'Indian_Pines'
            A = importdata('Indian_pines_corrected.mat');
            ground_truth = importdata('Indian_pines_gt.mat');
        case 'Salinas'
            A = importdata('Salinas_corrected.mat');
            ground_truth = importdata('Salinas_gt.mat');
        case 'Pavia_University'
            A = importdata('PaviaU.mat');
            ground_truth = importdata('PaviaU_gt.mat');    
        case 'KSC'
            A = importdata('KSC.mat');
            ground_truth = importdata('KSC_gt.mat');
        case 'Botswana'
            A = importdata('Botswana.mat');
            ground_truth = importdata('Botswana_gt.mat');
    end
    %% definition and initialization
    A = double(A);
    train_ratio = 0.1;
    [M, N, ~] = size(A);
    num_classes = max(max(ground_truth));
    pixel_pos = cell(1, num_classes);
    minv = min(A(:));
    maxv = max(A(:));
    A = double(A - minv) / double(maxv - minv);

    for i = 1:M
        for j = 1:N
            if ground_truth(i, j) ~= 0
                pixel_pos{ground_truth(i, j)} = [pixel_pos{ground_truth(i, j)}; [i j]];
            end
        end
    end
    
    %% generalize training samples
    train_X = []; test_X = [];
    train_labels = []; test_labels = []; test_pos = [];
    row_rank = cell(num_classes, 1);
    for i = 1:num_classes
        pos_mat = pixel_pos{i};
        row_rank{i} = randperm(size(pos_mat, 1));
        pos_mat = pos_mat(row_rank{i}, :);

        [m1, n1] = size(pos_mat);
        for j = 1 : floor(m1 * train_ratio)
            temp = A(pos_mat(j, 1), pos_mat(j, 2), :);
            train_X = [train_X temp(:)];
            train_labels = [train_labels;i];
        end
    end

    for i =  1: num_classes
        pos_mat = pixel_pos{i};
        pos_mat = pos_mat(row_rank{i}, :);
        [m1, n1] = size(pos_mat);
        for j = floor(m1 * train_ratio) + 1 : m1
            temp = A(pos_mat(j, 1), pos_mat(j, 2), :);
            test_X = [test_X temp(:)];
            test_labels = [test_labels;i];
            test_pos = [test_pos; (pos_mat(j, 2)-1) * M + pos_mat(j, 1)];
        end
    end
    train_X = train_X';
    test_X = test_X';
    
    %% Generalize the output
    X = permute(A, [3, 1, 2]);
    X = X(:, :);
    
    Dataset.train_X = train_X;
    Dataset.train_labels = train_labels;
    Dataset.test_X = test_X;
    Dataset.test_labels = test_labels;
    Dataset.test_pos = test_pos;
    Dataset.X = X; Dataset.A = A;
    Dataset.ground_truth = ground_truth;
end