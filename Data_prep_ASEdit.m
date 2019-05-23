% specify the folder where the files live
myFolder = './training_data/';

% get a list of all files in the folder with the desired file name pattern
filePattern = fullfile(myFolder, '*.psv');
theFiles = dir(filePattern);

% iterate over all the files
for k = 1 : length(theFiles)
    
    % get the file name
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(myFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    % read the file (first into a table and then get the raw data as a
    % matrix)
    table_data = readtable(fullFileName, 'Delimiter', '|', 'FileType', 'text');
    raw_data = table_data.Variables;
    
    % Now do whatever you want with this file name,
    cols = [1:7,13,16,18,20,22,24,26,28:32,34:36];
    processed_data = raw_data(:, cols);
    
    % process the data
    % linearly interpolate nans
    sepsis_final = fillmissing(processed_data, 'linear');
    sepsis1 = fillmissing(sepsis_final, 'previous');
    sepsis2 = fillmissing(sepsis1, 'next');
    
end