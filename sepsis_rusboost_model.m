clear
clc

% load the data
sepsis = load('C:\Users\lilwa\Documents\physionet\Data\setB_Data_Edited.csv');
Y = sepsis(:,end);
sepsis(:,end) = [];

% examine the data
tabulate(Y)

% partition the data - using half to fit the classifier and half to
% validate the results (it seems like cvpartition creates partitions that
% mimic the original structure of the data)
rng(10,'twister')
part = cvpartition(Y,'Holdout',0.3);
istrain = training(part);
istest = test(part);

% normalise the data to have zero mean and unit variance
sepsis_mean = mean(sepsis(istrain,:));
sepsis_std = std(sepsis(istrain,:));
sepsis = (sepsis - sepsis_mean) ./ sepsis_std;

% we will use deep trees with the maximum number of decision splits set as
% equal to the number of observations in the training data
N = sum(istrain);
t = templateTree('MaxNumSplits',N);
tic
rus_model = fitcensemble(sepsis(istrain,:),Y(istrain), ...
'Method','RUSBoost','NumLearningCycles',1000, ...
'Learners',t,'LearnRate',0.1,'nprint',100);
toc

% i cannot get a sensible result out of the score transforms so i will use
% a monotonic transform to convert to probabilities

% inspect the relationship between classification error and number of trees
% in the ensemble
figure(1);
plot(loss(rus_model,sepsis(istest,:),Y(istest),'mode','cumulative'));
grid on;
xlabel('Number of trees');
ylabel('Test classification error');

% show the resulting loss value from the entire ensemble
fprintf('Entire ensemble loss value = %3.2f\r\n', ...
    loss(rus_model,sepsis(istest,:),Y(istest)))

% make some predictions
[ypred, yscore] = predict(rus_model,sepsis(istest,:));

% convert scores to probabilities using a monotonic transform (i.e. diving
% the score value by the sum of the scores)
yprob = yscore ./ sum(yscore, 2);

% get the confusion matrix
figure(2);
plotconfusion(Y(istest)', ypred')

% plot the roc curve and calculate auc
figure(3);
plotroc(Y(istest)', yscore(:,2)')
[x,y,t,auc] = perfcurve(Y(istest)', yscore(:,2)', 1);

% show the testing auc value 
fprintf('AUC = %3.2f\r\n', auc*100)

%
% now compact the tree and remove learners
% 

% compact
rus_model_compact = compact(rus_model);

% create one tree with 600 learners and one with 400
rus_model_600 = removeLearners(rus_model_compact,[600:1000]);
rus_model_400 = removeLearners(rus_model_compact,[400:1000]);

% show the resulting loss values from the reduced ensembles
fprintf(['loss value (600 learners) = %3.2f, ' ...
    'loss value (400 leaners) = %3.2f\r\n'], ...
    loss(rus_model_600,sepsis(istest,:),Y(istest)), ...
    loss(rus_model_400,sepsis(istest,:),Y(istest)))