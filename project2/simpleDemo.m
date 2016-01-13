%% This script applies a random policy on a constant game
clc;
close; 
clear all;

%% Get the constant game
game = gameConstant();

%% Get a set of policies to try out
policies = {policyConstant(), policyRandom()};
policy_names = {'policyConstant', 'policyRandom'};

%% Run the policies on the game
figure;
hold on;
for k = 1:length(policies)
    policy = policies{k};
    game.resetGame();
    [reward, action, regret] = game.play(policy);
    fprintf('Policy: %s Reward: %.2f\n', class(policy), sum(reward));
    plot(regret);
end
legend(policy_names);