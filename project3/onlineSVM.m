function [ ratio ] = onlineSVM( data , class1, class2)

%cut data so we only have 2 classes
cut_data = data((data(:,5) == class1 | data(:,5) == class2), :);
%set class1 to be +1
cut_data((cut_data(:,5) == class1), 5) = 1;
%set class2 to be -1
cut_data((cut_data(:,5) == class2), 5) = -1;

w = zeros(1, 10);
lambda = 0.1;
t = 1;
eta = 0.5;

num_samples = size(cut_data, 1);
cut_data = cut_data(randperm(num_samples), :);

num_correct = 0;

%get rest of data since we want to visualize entire scene
rest_of_data = data((data(:,5) ~= class1 & data(:,5) ~= class2), :);

pc = [cut_data(:,1:3) ; rest_of_data(:, 1:3)];
pc = [pc,  zeros(89821, 3)];    %add color for plotting, default black

for i=1:num_samples
    alpha = eta / (t^0.5);
    
    y = cut_data(i, 5); 
    f = cut_data(i, 6:end);
    
    %check prediction
    if y*w*f' > 0
        num_correct = num_correct + 1;
    end
    
    %for plotting
    label = sign(w*f');
    if label == 1
        pc(i, 4:6) = [0 1 0];
    else
        pc(i, 4:6) = [0 0 1];
    end
    
    %update
    if y*w*f' < 1
        w = w - alpha*(lambda/t*w - y*f);
    else
        w = w - alpha*(lambda/t*w);
    end
    
    t = t + 1;
    
end

ratio = num_correct / num_samples;

fprintf('%d vs. %d; ratio: %f\n', class1, class2, ratio);

figure;
showPointCloud(pc(:,1:3), pc(:,4:6));

end

