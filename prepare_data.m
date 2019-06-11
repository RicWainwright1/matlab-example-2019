function all_data = prepare_data(directory)

% get a list of all files in the folder with the desired file name pattern
file_pattern = fullfile(directory, '*.psv');
the_files = dir(file_pattern);

% get an empty array to store the data in (we should ideally preallocate
% this array for speed ... but we don't know how many data points we will
% have in each file)
all_data = [];

% set the variables of interest
vars = {'HR','O2Sat','Temp','SBP','MAP','DBP','Resp','PaCO2','BUN', ...
        'Calcium','Creatinine','Glucose','Magnesium','Potassium', ...
        'TroponinI','Hct','Hgb','PTT','WBC','Platelets','Age','Gender', ...
        'SepsisLabel'};
    
% these are the columns where we have a reasonable amount of data - the
% other columns have too much missing data (e.g. for some of patients there
% are no values for the other variables - no idea how you deal with 
% completely lacking data!)

% iterate over all the files
for k = 1 : length(the_files)
    
    % get the file name
    baseFileName = the_files(k).name;
    fullFileName = fullfile(directory, baseFileName);
    fprintf(1, 'now reading %s\n', fullFileName);
    
    % read the file (first into a table, then filter by columns of interest
    % and then get the raw data as a matrix)
    table_data = readtable(fullFileName, ...
        'Delimiter', '|', 'FileType', 'text');
    raw_data = table_data(:,vars).Variables;
    
    % process the data
    
    % linearly interpolate nans, the forward and back fill
    data = fillmissing(raw_data, 'linear');
    data = fillmissing(data, 'previous');
    data = fillmissing(data, 'next');
     
    % grow the all_data array
    all_data = [all_data; data];
    
end
