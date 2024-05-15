% DATA ANALYSIS PROJECT - EXERCISE 7
% Dafni Nikolaidou (10546)  Nikolaos Barkas (10483)

clc;
clear;
close all;
warning('off', 'all');
bike_data = readtable("SeoulBike.xlsx");
selectedColumns = {'RentedBikeCount', 'Seasons', 'Hour','Temperature__C_'};

best_models = cell(4, 24);
best_r_squared_values = zeros(4, 24);

% Iterating over seasons
for season = 1:4
    data_season = bike_data(bike_data.Seasons == season, :);
    
    % Iterating over hours
    for hour = 0:23
        data_hour = data_season(data_season.Hour == hour, :);

        % Skip the hours for which there is no data
        if isempty(data_hour)
            continue;
        end
        
        % Creating the regression models
        linear_model = fitlm(data_hour, 'RentedBikeCount ~ Temperature__C_');
        quadratic_model = fitlm(data_hour, 'RentedBikeCount ~ Temperature__C_ + Temperature__C_^2');
        cubic_model = fitlm(data_hour, 'RentedBikeCount ~ Temperature__C_ + Temperature__C_^2 + Temperature__C_^3');
        data_hour.Temperature__C_ = exp(data_hour.Temperature__C_);
        exp_model = fitlm(data_hour, 'RentedBikeCount ~ Temperature__C_');
        
        % Adjusted R-squared for each model
        r_squared_linear = linear_model.Rsquared.Adjusted;
        r_squared_quadratic = quadratic_model.Rsquared.Adjusted;
        r_squared_cubic = cubic_model.Rsquared.Adjusted;
        r_squared_exp = exp_model.Rsquared.Adjusted;
        
        % Choosing the best model based on the Adjusted R-squared value
        [~, best_model_index] = max([r_squared_linear, r_squared_quadratic, r_squared_cubic, r_squared_exp]); 
        
        if best_model_index == 1
            best_models{season, hour + 1} = 'Linear Model';
            best_r_squared_values(season, hour + 1) = r_squared_linear;
        elseif best_model_index == 2
            best_models{season, hour + 1} = 'Quadratic Model';
            best_r_squared_values(season, hour + 1) = r_squared_quadratic;
        elseif best_model_index == 3
            best_models{season, hour + 1} = 'Qubic Model';
            best_r_squared_values(season, hour + 1) = r_squared_cubic;
        else
            best_models{season, hour + 1} = 'Exponential Model';
            best_r_squared_values(season, hour + 1) = r_squared_exp;
        end
    end

results_table = table(...
    (0:23)', ...
    (best_models(season, 1:24))', ...
    (best_r_squared_values(season, 1:24))', ...
    'VariableNames', {'Hour', 'Best Model', 'Adjusted R-squared'});
disp(results_table);
disp(' ');
end

% On all seasons, a linear or qubic better fits most hours of the day.
% The hourly results also differ a lot between seasons, so a particular
% trend is not recognisable.