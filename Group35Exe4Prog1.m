% DATA ANALYSIS PROJECT - EXERCISE 4
% Dafni Nikolaidou (10546)  Nikolaos Barkas (10483)

clc;
clear;
close all;

bike_data = readtable("SeoulBike.xlsx");

selectedColumns = {'RentedBikeCount', 'Seasons', 'Hour'};

% Dividing data according to the hour of day.
hours = unique(bike_data.Hour);

confidenceIntervals = zeros(length(hours), 2, 6);

% Season combination representation
seasonCombinationStrings = cell(1, 6);

for i = 1:length(hours)
    % Data filtration for a specific hour of day
    currentHourData = bike_data(bike_data.Hour == hours(i), selectedColumns);
    
    % Dividing data by season
    seasons = unique(currentHourData.Seasons);
    
    % Bootstrap for median difference for unique season combinations
    uniqueSeasonPairs = nchoosek(seasons, 2);
    
    for pairIdx = 1:size(uniqueSeasonPairs, 1)
        j = uniqueSeasonPairs(pairIdx, 1);
        k = uniqueSeasonPairs(pairIdx, 2);
        
        data1 = currentHourData.RentedBikeCount(currentHourData.Seasons == j);
        data2 = currentHourData.RentedBikeCount(currentHourData.Seasons == k);
        
        % Bootstrap
        alpha = 0.05;
        b = 1000;
        low = floor((b+1)*alpha/2);
        up = b-low;
        tailperc = [low up]*100/b;
        bootsample1 = bootstrp(b, @median, data1);
        bootsample2 = bootstrp(b, @median, data2);
        bootstrapDiffs = bootsample1 - bootsample2;
        
        % Confidence Interval calculation
        bootDiffs_sorted = sort(bootstrapDiffs);
        
        confidenceIntervals(i, :, pairIdx) = prctile(bootDiffs_sorted, tailperc);
        % confidenceIntervals(i, :, pairIdx) = confidenceIntervals(i, :, pairIdx)/1*10^-3;
        
        seasonCombinationStrings{pairIdx} = sprintf('Seasons %d vs. %d', j, k);
    end
end

% Plotting the confidence intervals - Showing statistical importance
figure;
for i = 1:size(uniqueSeasonPairs, 1)
    subplot(2, 3, i);
    hold on;
    for j = 1:length(hours)
        line([hours(j), hours(j)], [confidenceIntervals(j, 1, i), confidenceIntervals(j, 2, i)], 'Color', 'b');
    end
    hold off;
    title(seasonCombinationStrings{i});
    xlabel('Hour of the Day');
    ylabel('Difference in Median');
    ylim([min(confidenceIntervals(:))-1, max(confidenceIntervals(:))+1]);
    grid on;
    if any(confidenceIntervals(:, 1, i) > 0) || any(confidenceIntervals(:, 2, i) < 0)
        line([0 24], [0 0], 'Color', 'k', 'LineStyle', '--');
    end
end

% NOTE: If the value zero is included in a CI it means there is no
% statistically important difference in the median difference of that
% season pair

% Generally there is a stastically significant difference in the median
% rental bike count in the comparisons of season 1 with the rest. 

% The inclusion of zero in the CI's of the other comparisons points in the other direction:
% That there is no stastically important difference of median in the pairings of
% season 2, 3 and 4 for certain hours of the day.

% The hours where there is no significant in bike rental count between
% seasons are as follow: 
% For the Season 2 - Season 3 pair, hours 11:00 - 17:00
% For the Season 2 - Season 4 pair, hours 12:00, 14:00 - 15:00, 17:00 - 22:00
% For the Season 3 - Season 4 pair, hours 7:00 - 12:00, 15:00 - 18:00
