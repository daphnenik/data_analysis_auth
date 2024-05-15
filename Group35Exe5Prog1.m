% DATA ANALYSIS PROJECT - EXERCISE 5
% Dafni Nikolaidou (10546)  Nikolaos Barkas (10483)

clc; clear all; clearvars;

%Importing the excel file.
bike_data = readtable("SeoulBike.xlsx");

figure;
for i = 1 : 4
    % Season selection
    season_data = bike_data(bike_data.Seasons == i, :);
    % Extract relevant data
    RentedBikeCount = season_data.RentedBikeCount;
    Temperature = season_data.Temperature__C_; 

    % Number of unique hours
    unique_hours = unique(season_data.Hour); 

    % Loop over each unique hour
    for j = 1:length(unique_hours)
        % Extract data for the current hour
        current_hour_data = season_data(season_data.Hour == unique_hours(j), :);
    
        % Calculate Pearson correlation coefficient
        correlation_coefficients(j) = corr(current_hour_data.RentedBikeCount, current_hour_data.Temperature__C_);
    
        % Perform hypothesis test for significance
        [~, p_values(j)] = corr(current_hour_data.RentedBikeCount, current_hour_data.Temperature__C_);
    end

alpha = 0.05;
% Plot the correlation coefficients for each hour
subplot(2,2,i);
 % Plot only the significant correlations
    bar(unique_hours(p_values <= alpha), correlation_coefficients(p_values <= alpha));
    hold on;
    % Mark the non-significant correlations
    bar(unique_hours(p_values > alpha), correlation_coefficients(p_values > alpha), 'FaceColor', [0.7 0.7 0.7]);
    
    xlabel('Time of day');
    ylabel('Pearson Coefficient');
    title(['Temp & Bike correlation - Season ' num2str(i)]);
    legend('Significant correlation', 'Non significant correlation');
    hold off;
end

% Ho : There is not a significant correlation between temperature and bike
% rentals at the standard 0.05 significance level. 

% Generally, on all seasons except season 3 (summer) there is a strong correlation
% between temperature and the number of rented bikes on most hours of the
% day. This makes sense, as high temperatures indicate nice weather for
% acivities such as bike riding.

% In the case of Summer, there is a significant negative correlation in the
% middle hours of the day, pointing out the obvious fact that high
% temperatures make physical exercise like bike riding more difficult.

