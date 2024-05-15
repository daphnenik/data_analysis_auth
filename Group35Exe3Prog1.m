% DATA ANALYSIS PROJECT - EXERCISE 3
% Dafni Nikolaidou (10546)  Nikolaos Barkas (10483)

clc; close all; clearvars;
figure(1);
figure(2);
%Importing the excel file.
bike_data = readtable("SeoulBike.xlsx");

for season = 1:4
    season_data = bike_data(bike_data.Seasons == season, :);
    % Convert the 'Date' column to datetime type
    season_data.Date = datetime(season_data.Date, 'InputFormat', 'dd-MMM-yy', 'Format', 'dd-MMM-yy');
    
    % Get unique dates
    uniqueDates = unique(season_data.Date);
    
    % Cell array to store separated data for each date
    separatedData = cell(length(uniqueDates), 1);
    
    for i = 1:length(uniqueDates)
        currentDate = uniqueDates(i);
        dataForDate = season_data(season_data.Date == currentDate, :);
        % Check if the data has exactly 24 rows (hours)
        if size(dataForDate, 1) == 24
            separatedData{i} = dataForDate;
        end
    end
    % Remove empty cells (cells with fewer than 24 rows)
    separatedData = separatedData(~cellfun('isempty', separatedData));
    
    RBC = [];
    
    for i = 1 : length(separatedData)
        for j = 1 : 24
            datahour(i,j) = separatedData{i}.RentedBikeCount(separatedData{i}.Hour == j-1);
        end   
    end
    
    for k = 1 : 24
        for l = 1 : 24
            % Extract RBC values for each hour pair
            RBC1 = mean(datahour(:, k));
            RBC2 = mean(datahour(:, l));
            newRBC(k, l) = RBC1 - RBC2;
            
            % Perform t-test for each hour pair
            [h, p] = ttest(datahour(:, k) - datahour(:, l), 0, 'Alpha', 0.05);
            meantest(k, l) = h;
        end
    end

    % Display results in subplots
    figure(1);
    subplot(2, 2, season);
    % Mean difference color map
    colormap(jet);
    imagesc(newRBC);
    colorbar;
    title('Mean difference color map - Season ',season);
    figure(2);
    % Test result color map
    subplot(2, 2, season);
    colormap(jet);
    imagesc(meantest);
    colorbar;
    title('h-value color map- Season ',season);
end

% The color maps are symmetrical due to the double hour pairings. The
% results can be viewed on either the upper or lower diagonal part of each
% map.

% In the mean difference color map it is easily observed that the major
% differences are in the hour pairs of the early hours (1 - 10) with those
% of the night (16 - 24). Obviously the closer the hours are to each other,
% the smallest the mean difference is.

% In the h-value color map that serves as a visual display of acceptance or rejection
% of the null hypothesis (zero mean difference) we can observe that 
% besides the (x,x) pairs of hours (where the mean difference is obviously zero), 
% the h = 0 values are rather rare and are mainly clustered in the pairings of 
% neighboring hours.

% Generally, the results dont change much with season, with the maps of
% season 3 appearing slightly different compared to the rest.