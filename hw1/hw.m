
N = 3;

T = 100;

eta = 0.5;

time = 1:1:T;

%3.3

[regret, loss] = wma(N, T, eta, 1);
figure;
plot(time, regret, time, loss);
legend('regret', 'loss', 'Location', 'northwest')
title('WMA: Stochastic Nature')

[regret, loss] = wma(N, T, eta, 2);
figure;
plot(time, regret, time, loss);
legend('regret', 'loss', 'Location', 'northwest')
title('WMA: Deterministic Nature')

[regret, loss] = wma(N, T, eta, 3);
figure;
plot(time, regret, time, loss);
legend('regret', 'loss', 'Location', 'northwest')
title('WMA: Adversarial Nature')


%3.4

etas = [0.1 0.2 0.4];

figure;
for i = 1:3  
    [regret, loss] = rwma(N, T, etas(i), 1);
    plot(time, regret, time, loss);
    hold on;
end
legend('regret: eta=0.1', 'loss: eta=0.1', ...
       'regret: eta=0.2', 'loss: eta=0.2', ...
       'regret: eta=0.4', 'loss: eta=0.4', 'Location', 'northwest');
title('RWMA: Stochastic Nature');
   

figure;
for i = 1:3  
    [regret, loss] = rwma(N, T, etas(i), 2);
    plot(time, regret, time, loss);
    hold on;
end
legend('regret: eta=0.1', 'loss: eta=0.1', ...
       'regret: eta=0.2', 'loss: eta=0.2', ...
       'regret: eta=0.4', 'loss: eta=0.4', 'Location', 'northwest')
title('RWMA: Deterministic Nature')


figure;
for i = 1:3  
    [regret, loss] = rwma(N, T, etas(i), 3);
    plot(time, regret, time, loss);
    hold on;
end
legend('regret: eta=0.1', 'loss: eta=0.1', ...
       'regret: eta=0.2', 'loss: eta=0.2', ...
       'regret: eta=0.4', 'loss: eta=0.4', 'Location', 'northwest')
title('RWMA: Adversarial Nature')


%3.5
N = 6;

figure;
for i = 1:3  
    [regret, loss] = wma(N, T, etas(i), 2);
    plot(time, regret, time, loss);
    hold on;
end
legend('regret: eta=0.1', 'loss: eta=0.1', ...
       'regret: eta=0.2', 'loss: eta=0.2', ...
       'regret: eta=0.4', 'loss: eta=0.4', 'Location', 'northwest')
title('WMA: Deterministic Nature')

figure;
for i = 1:3  
    [regret, loss] = rwma(N, T, etas(i), 2);
    plot(time, regret, time, loss);
    hold on;
end
legend('regret: eta=0.1', 'loss: eta=0.1', ...
       'regret: eta=0.2', 'loss: eta=0.2', ...
       'regret: eta=0.4', 'loss: eta=0.4', 'Location', 'northwest')
title('RWMA: Deterministic Nature')

