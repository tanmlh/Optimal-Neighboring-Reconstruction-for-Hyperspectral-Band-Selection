%% definition
classifier_names = {'KNN', 'SVM'};
dataset_names = {'Indian_Pines', 'Pavia_University', 'Salinas', 'KSC', 'Botswana'};
method_names = {'All-Bands', 'UBS', 'ONR'};

svm_para = {'-c 10000.000000 -g 0.500000 -m 500 -t 2 -q',...
    '-c 100 -g 4 -m 500 -t 2 -q',...
    '-c 100 -g 16 -m 500 -t 2 -q',...
    '-c 10000.000000 -g 16.000000 -m 500 -t 2 -q',...
    '-c 10000 -g 0.5 -m 500 -t 2 -q',...
    }; % parameters to run svm tuned on each of the five datasets

%% input parameters
updated_method_ids = 1:3; % ids of band selection method that you want to perform
update_classifier_ids = {[1], [1 2], [1 2], [1 2], [1 2]}; % which classifier(s) you want to use in each dataset
K = 30; delta = 3;
x = delta : delta : K; % number of the selected bands
num_repe = 1; % repetitive experiments to reduce the randomness of choosing training samples
plot_method_ids = [1, 2, 3];
plot_classfier_id = 1;

%% initialization

C_cnt = size(classifier_names, 2);
M_cnt = size(method_names, 2);
D_cnt = size(dataset_names, 2);

if ~exist('Methods')
    Methods = cell(1, 1);
    for i = 1 : size(method_names, 2)
        Methods{1, i} = get_method_struct(method_names{i}, dataset_names, classifier_names, K / delta);
    end
end

%% band Selection for each dataset
for dataset_id = [3, 4, 5]
    %% load data
    Dataset = get_data(dataset_names{dataset_id});
    Dataset.svm_para = svm_para{1, dataset_id};
    A = Dataset.A; X = Dataset.X;
    [M, N, d] = size(A);
    
    %% preprocess
    ONR_L = ONR_init(X');

    %% calculate the band set for each method
    Methods{1, 1}.band_set{dataset_id, 1} = 1:d;
    cnt = 1;
    for j = x
        Methods{1, 2}.band_set{dataset_id, cnt} = floor(linspace(1, d, j));        
        Methods{1, 3}.band_set{dataset_id, cnt} = ONR(X, ONR_L, j);
        cnt = cnt+1;
    end

    %% test accuracy
    
    % Initialization
    for i = updated_method_ids
        for classifier_id = update_classifier_ids{dataset_id}
            for j = 1 : size(x, 2)
                Methods{1, i}.accu(dataset_id, classifier_id, j) = 0;
            end
        end
    end
    
    for ite = 1 : num_repe
      % refresh the training and testing samples
        if ite > 1
            Dataset = get_data(dataset_names{dataset_id});
            Dataset.svm_para = svm_para{1, dataset_id};
        end
        for classifier_id = update_classifier_ids{dataset_id}
            %% calculate the accuracy without band selection
            if find(updated_method_ids == 1)
                cur_accu = test_bs_accu(Methods{1, 1}.band_set{dataset_id, 1}, Dataset, classifier_names{classifier_id});
                Methods{1, 1}.accu(dataset_id, classifier_id, 1) = ...
                    Methods{1, 1}.accu(dataset_id, classifier_id, 1) + cur_accu.OA;
                for j = 2 : size(x, 2)
                    Methods{1, 1}.accu(dataset_id, classifier_id, j) = Methods{1, 1}.accu(dataset_id, classifier_id, 1);
                end
            end
            
            %% calculate accuracy of each band selection method
            for j = updated_method_ids
                if j == 1 
                    continue 
                end
                cnt = 1;
                for k = x
                    cur_accu = test_bs_accu(Methods{1, j}.band_set{dataset_id, cnt}, Dataset, classifier_names{classifier_id});
                    Methods{1, j}.accu(dataset_id, classifier_id, cnt) = ...
                        Methods{1, j}.accu(dataset_id, classifier_id, cnt) + cur_accu.OA;
                    str = fprintf('ite: %d\t%s----%s----%s----%f\n', ite, dataset_names{dataset_id}, classifier_names{classifier_id}, method_names{j}, Methods{1, j}.accu(dataset_id, classifier_id, cnt) / ite);
                    cnt = cnt + 1;
                end 
                fprintf('\n');
            end 
        end
    end
    
    %% calculate the mean accuracy over different iterations
    for classifier_id = update_classifier_ids{dataset_id}
        for j = updated_method_ids
            Methods{1, j}.accu(dataset_id, classifier_id, :) = ...
                Methods{1, j}.accu(dataset_id, classifier_id, :) / num_repe;
        end
    end
 end

%% plot the result
plot_method(Methods(plot_method_ids), x, classifier_names, plot_classfier_id, method_names(plot_method_ids), dataset_id, 1);

%% get a struct of a band selection method
function [method_struct] = get_method_struct(method_name, dataset_names, classifier_names, band_num_cnt)
    method_struct.method_name = method_name;
    dataset_cnt = size(dataset_names, 2);
    classifier_cnt = size(classifier_names, 2);
    
    method_struct.band_set = cell(dataset_cnt, band_num_cnt); % K / delta
    method_struct.band_set_corr = cell(dataset_cnt, band_num_cnt);
    method_struct.accu = zeros(dataset_cnt, classifier_cnt, band_num_cnt);

end