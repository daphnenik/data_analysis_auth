% DATA ANALYSIS PROJECT - EXERCISE 8
% Dafni Nikolaidou (10546)  Nikolaos Barkas (10483)

clc;
clear;
close all;

warning('off', 'all');

bike_data = readtable("SeoulBike.xlsx");
selectedColumns = {'RentedBikeCount', 'Seasons', 'Hour', 'Temperature__C_'};

% Dividing data according to the hour of day
hours = unique(bike_data.Hour);

seasonCombinationStrings = cell(1, 6);

alpha = 0.05;
zcrit = norminv(1-alpha/2);

i = 20; % selected hour
currentHourData = bike_data(bike_data.Hour == hours(i), selectedColumns);

% Dividing data by season
seasons = unique(currentHourData.Seasons);
uniqueSeasonPairs = nchoosek(seasons, 2);
    
for pairIdx = 1:size(uniqueSeasonPairs, 1)
    j = uniqueSeasonPairs(pairIdx, 1);
    k = uniqueSeasonPairs(pairIdx, 2);
    % Independed variables - Temperatures
    X1 = currentHourData.Temperature__C_(currentHourData.Seasons == j);
    X2 = currentHourData.Temperature__C_(currentHourData.Seasons == k);
    n = length(X1);
    m = length(X2);
    % Depended variables - Rented Bike count
    Y1 = currentHourData.RentedBikeCount(currentHourData.Seasons == j);
    Y2 = currentHourData.RentedBikeCount(currentHourData.Seasons == k);
 
    % Fitting linear model
    mdl1 = fitlm(X1, Y1);
    mdl2 = fitlm(X2, Y2);
    
    % Calculating R^2
    R21 = mdl1.Rsquared.Ordinary;
    R22 = mdl2.Rsquared.Ordinary;
    observedDiff = R21 - R22;
    %---------------------------------------------------------------------------   
    seasonCombinationStrings{pairIdx} = sprintf('Seasons %d vs. %d', j, k);
    %--------------------------------------------------------------------------- 
    % Combining temperature data
    X_combined = vertcat(X1, X2);

    % Combining bike data
    Y_combined = vertcat(Y1, Y2);
    
    B = 1000;  % Number of samples
    lower = floor((B+1)*alpha/2);
    up = B+1-lower;
    tailperc = [lower up]*100/B;
    rejections = 0;
    for i = 1:B
       index = randperm(n+m);
       % sampling for X1 and Y1
       Sample_X1 = X_combined(index(1:n));
       Sample_Y1 = Y_combined(index(1:n));
       Sample_X2 = X_combined(index(n+1:end));
       Sample_Y2 = Y_combined(index(n+1:end));
            
       % Fit linear models for the samples
       mdl_sample1 = fitlm(Sample_X1, Sample_Y1);
       mdl_sample2 = fitlm(Sample_X2, Sample_Y2);

       % Calculate R^2
        r2sq_sample1(i) = mdl_sample1.Rsquared.Ordinary; 
        r2sq_sample2(i) = mdl_sample2.Rsquared.Ordinary;
    end
    r2sq_diff = r2sq_sample1 - r2sq_sample2;
    r2sq_diff(B+1) = observedDiff;
    r2sq_diff_sorted = sort(r2sq_diff);
            
    % Measure the percentage of differing R^2
    for l = 1:B
        rank = find(r2sq_diff_sorted == observedDiff);
        if rank < (B+1)*alpha/2 | rank > (B+1)*(1-alpha/2)
            rejections = rejections +1 ;
        end
    end

    diff_percentage = rejections / B*100;

    % Printing results
    fprintf('Seasons %d vs. %d:\n', j, k);
    fprintf('Observed Difference in R^2: %.4f\n', observedDiff);
    fprintf('Percentage of difference: %1.2f%%\n', diff_percentage);
    fprintf('--------------------------------------------------\n');
end

% We tested and present the results for hour 20.
% The linear regression model does not fit equally well for all seasons.
% Seasons 2 and 4 are the ones the linear regression model would work for.

% A 0% difference means that there is not a significant difference of R^2
% for the standard a = 0.05, while 100% difference points to the opposite
% case, of there being a statistically important differnce between the R^2
% values.