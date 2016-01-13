function [ ratio ] = newListPred( learners, features, results, list_size, feat_update)

traj_per_env = 30;
num_env = size(results, 1) / traj_per_env;

lists = zeros(num_env, list_size);

%for feature update
if feat_update == 1
    features = [features, zeros(size(features,1), 1)];
end


for i=1:list_size
    scores = features * learners{i};
    scores_reshaped = reshape(scores', traj_per_env, num_env)';
    [~, idx] = max(scores_reshaped, [], 2);
    lists(:,i) = idx;
   
end

result_reshaped = reshape(results', traj_per_env, num_env)';
ratio = evalLists(lists, result_reshaped);


end

