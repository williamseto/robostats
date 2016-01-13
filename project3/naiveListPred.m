% Input:
% score_test: column vector of predicted score. Bigger score implies higher confidence in predicting the trajectory will succeed.  
% result_test: ground truth result of whether its trajectory would succeed
% for its corresponding environment. 

function [ ratio ] = naiveListPred( scores, results, traj_per_env, num_env, list_size )

scores_reshaped = reshape(scores', traj_per_env, num_env)';
result_reshaped = reshape(results', traj_per_env, num_env)';

[sorted_scores, indexs] = sort(scores_reshaped, 2, 'descend');

list_indices = indexs(:, 1:list_size);

ratio = evalLists(list_indices, result_reshaped);


end

