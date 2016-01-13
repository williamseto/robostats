function [ learners ] = conSeqOpt( features, results, k , feat_update)

traj_per_env = 30;
num_env = size(results, 1) / traj_per_env;

aux_results = results; %for training

lists = zeros(num_env, k);
learners = cell(1, k);

results_reshaped = reshape(results', traj_per_env, num_env)';

%for feature update
if feat_update == 1
    features = [features, zeros(size(features,1), 1)];
end

for i=1:k
    %train learner i
    model = features \ aux_results;
    scores = features * model;
    
    scores_reshaped = reshape(scores', traj_per_env, num_env)';
    %append best trajectory for each env to lists
    [~, idx] = max(scores_reshaped, [], 2);
    lists(:,i) = idx;
    %for each env, update labels as marginal benefit
    
    for j=1:num_env
        %if action is successful, all other actions have marginal benefit 0
        if aux_results(sub2ind([30, num_env], idx(j), j)) == 1
            start = (j-1)*30+1;
            aux_results(start:start+29) = 0;
        end

        %feature update
        if feat_update == 1
            features(sub2ind([30, num_env], idx(j), j), 19) = 1;
        end
    end
    
    
    
    %ratio = evalLists(lists(:, 1:i), results_reshaped)
    learners{i} = model;
end



end

