clc;
close; 
clear all;


%% 3.1.1
game = gameConstant();
policy = policyGWM();
[~, action, regret] = game.play(policy);
figure;
plot(regret);
title('GWM Regret for Constant Game');
figure;
plot(action);
title('GWM actions for Constant Game');

%% 3.2.1
game = gameConstant();
policy = policyEXP3();
[~, action, regret] = game.play(policy);
figure;
plot(regret);
title('EXP3 Regret for Constant Game');
figure;
plot(action);
title('EXP3 actions for Constant Game');

%% 3.3.2
game = gameGaussian(10, 10000);
policy = policyEXP3();
[reward, ~, regret] = game.play(policy);
figure;
plot(regret);
title('EXP3 Regret for Gaussian Game');



%% 4.3.1
game = gameConstant();
policy = policyUCB();
[~, action, regret] = game.play(policy);
figure;
plot(regret);
title('UCB Regret for Constant Game');
figure;
plot(action);
title('UCB actions for Constant Game');
figure;
hold on;
plot(policy.upperConfidences(1, :));
plot(policy.upperConfidences(2, :));
legend('action 1', 'action 2');
title('Upper confidence bounds for each action');

%% 4.4.1
game = gameGaussian(10, 10000);

% Get a set of policies to try out
policies = {policyEXP3(), policyUCB()};
policy_names = {'policyEXP3', 'policyUCB'};

% Run the policies on the game
figure;
hold on;
for k = 1:length(policies)
    policy = policies{k};
    game.resetGame();
    [reward, ~, regret] = game.play(policy);
    plot(regret);
end
legend(policy_names);
title('UCB vs EXP3 Regret for Gaussian game');

%% 4.5.1
game = gameAdversarial();
policy = policyUCB();
[~, action, regret] = game.play(policy);
figure;
plot(regret);
title('UCB Regret for Adversarial Game');
figure;
plot(action);
title('UCB actions for Adversarial Game');

game = gameAdversarial();
policy = policyEXP3();
[~, action, regret] = game.play(policy);
figure;
plot(regret);
title('EXP3 Regret for Adversarial Game');
figure;
plot(action);
title('EXP3 actions for Adversarial Game');

%% 5.2.1
load([pwd '\data\univLatencies.mat']);
game = gameLookupTable(univ_latencies, 1);

% Get a set of policies to try out
policies = {policyEXP3(), policyUCB()};
policy_names = {'policyEXP3', 'policyUCB'};

% Run the policies on the game
figure;
hold on;
for k = 1:length(policies)
    policy = policies{k};
    game.resetGame();
    [reward, action, regret] = game.play(policy);
    plot(regret);
end
legend(policy_names, 'location', 'northwest');
title('UCB vs EXP3 Regret for university latency dataset');

%% 5.3.1
load([pwd '\data\plannerPerformance.mat']);
game = gameLookupTable(planner_performance, 1);

% Get a set of policies to try out
policies = {policyEXP3(), policyUCB()};
policy_names = {'policyEXP3', 'policyUCB'};

% Run the policies on the game
figure;
hold on;
for k = 1:length(policies)
    policy = policies{k};
    game.resetGame();
    [reward, action, regret] = game.play(policy);
    plot(regret);
end
legend(policy_names, 'location', 'northwest');
title('UCB vs EXP3 Regret for planner performance dataset');
