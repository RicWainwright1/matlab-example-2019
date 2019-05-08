clear
clc

% load the data
sepsis = readtable('C:/Users/lilwa/Desktop/Matlab_Sepsis/p00001.csv');
Y = sepsis(:,end);
sepsis(:,end) = [];

% filter columns of interest
% these are the columns we want to keep.
cols = [1:7,13,16,18,20,22,24,26,28:32,34:36];
processed_data = sepsis(:, cols);

% examine the data
%tabulate(Y)

% process the data

% linearly interpolate nans
sepsis_final = fillmissing(processed_data, 'linear');
sepsis1 = fillmissing(sepsis_final, 'previous');
sepsis2 = fillmissing(sepsis1, 'next');