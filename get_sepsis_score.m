function [score, label] = get_sepsis_score(data, model)
    
% take the raw data and apply the preprocessing stuff to it
%%% note - we need to split out the processing of a set of data from the
%%% processing of all the data in all the files ...

% ^ the data input to this function is stepped through a bit at a time, so
% the first call has one row of data, the second has two, etc.
% 
% how do we deal with this (as we can only currently do the data 
% preprocessing on the whole patients worth of data)?

% predict labels using the supplied model
%[ypred, yscore] = predict(model,data);
%label = ypred;

score = 0.5;
label = 1;

end
