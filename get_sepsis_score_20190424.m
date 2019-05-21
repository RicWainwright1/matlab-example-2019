% get_sepsis_score.m
%
% function to read in a zip file of inputs, and create an output zip file
% with predicted probability of sepsis and a predicted sepsis label
%
% arguments:
%
%   input_zip_file  - zip file containing our input data
%   output_zip_file - filename for the zipped up outputs
%
% author: alex shenfield & richard wainwright
% date:   05/04/2019
% 
function get_sepsis_score(input_zip_file, output_zip_file)

% get input files
input_files = sort(unzip(input_zip_file, 'tmp_inputs'));
j = 1;
for i = 1 : length(input_files)
    if exist(input_files{j}, 'file') ~= 2
        input_files(j) = [];
    else
        j = j + 1;
    end
end

% make temporary output directory
mkdir('tmp_outputs');

% generate scores
n = length(input_files);
for i = 1:n
    
    % read data
    input_file = input_files{i};
    data = read_challenge_data(input_file);
    
    % make predictions
    [scores, labels] = compute_sepsis_score(data);
    
    % write results
    file_name = strsplit(input_file, filesep);
    output_file = ['tmp_outputs' filesep file_name{end}];
    
    fid = fopen(output_file, 'wt');
    fprintf(fid, 'PredictedProbability|PredictedLabel\n');
    fclose(fid);
    dlmwrite(output_file, [scores labels], 'delimiter', '|', '-append');
end

% perform clean-up
zip(output_zip_file, 'tmp_outputs');
rmdir('tmp_outputs','s');
rmdir('tmp_inputs','s');

end

% actually run the model and compute the scores and predicted labels
function [scores, labels] = compute_sepsis_score(data)

% process the data

% filter columns of interest
cols = [1:7,13,16,18,20,22,24,26,28:32,34:36];
processed_data = data(:, cols);

% linearly interpolate nans

sepsis_1 = fillmissing(processed_data, 'linear');
sepsis_2 = fillmissing(sepsis_1, 'previous');
processed_data_final = fillmissing(sepsis_2, 'next');
% load the model and predict

% load the model
load('rus_model_100.mat', 'rus_model_100');

% use the model to predict on the loaded data
[ypred, yscore] = predict(rus_model_100, processed_data_final);

% output the model predictions

% convert scores to probabilities using a monotonic transform (i.e. diving
% the score value by the sum of the scores)
yprob = yscore ./ sum(yscore, 2);

% set the outputs
scores = yprob(:,2);
labels = ypred;
end

% load the data
function data = read_challenge_data(filename)

% open the file and split based on pipes
f = fopen(filename, 'rt');
try
    l = fgetl(f);
    column_names = strsplit(l, '|');
    data = dlmread(filename, '|', 1, 0);
catch ex
    fclose(f);
    rethrow(ex);
end

% close the file once we're done
fclose(f);

% ignore SepsisLabel column if present
if strcmp(column_names(end), 'SepsisLabel')
    column_names = column_names(1:end-1);
    data = data(:,1:end-1);
end

end
