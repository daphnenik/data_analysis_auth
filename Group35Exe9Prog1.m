% DATA ANALYSIS PROJECT - EXERCISE 9
% Dafni Nikolaidou (10546)  Nikolaos Barkas (10483)

clc; close all; clearvars;
%Importing the excel file.
bike_data = readtable("SeoulBike.xlsx");
filteredData = bike_data(bike_data.Holiday == 0 & bike_data.Seasons == 2, :);

% Initialize arrays for predictions and R^2
predictions1a = zeros(20, 24);
predictions1b = zeros(20, 24);
real_yall = zeros(20, 24);
AdjRsq1a = zeros(24,1);
AdjRsq1b = zeros(24,1);


% Step 1: Full Model (Model 1)
for hour = 1:24
    % Select data for the current hour
    hourData = filteredData(filteredData.Hour == hour-1, :);
    real_y = hourData.RentedBikeCount(end-19:end);
    real_yall(:, hour) = real_y;
    trainingData = hourData(1:end - 20, :);
    X = trainingData(:, {'Temperature__C_', 'Humidity___', 'Rainfall_mm_', 'Visibility_10m_', 'WindSpeed_m_s_', 'Snowfall_cm_', 'SolarRadiation_MJ_m2_', 'DewPointTemperature__C_'});
    y = trainingData.RentedBikeCount; 
    y = array2table(y);
    trainingmatrix = [X,y];
    
    % Train Full Regression model
    fullModel = fitlm(trainingmatrix, 'y ~ Temperature__C_ + Humidity___ + Rainfall_mm_ + Visibility_10m_ + WindSpeed_m_s_ + Snowfall_cm_ + SolarRadiation_MJ_m2_ + DewPointTemperature__C_');

    % Step 2: Prediction
    prediction_data =  hourData(end-19:end,:);
    X_pred = prediction_data{:, {'Temperature__C_', 'Humidity___', 'Rainfall_mm_', 'Visibility_10m_', 'WindSpeed_m_s_', 'Snowfall_cm_', 'SolarRadiation_MJ_m2_', 'DewPointTemperature__C_'}};
    predPredictors = array2table(X_pred, 'VariableNames', {'Temperature__C_', 'Humidity___', 'Rainfall_mm_', 'Visibility_10m_', 'WindSpeed_m_s_', 'Snowfall_cm_', 'SolarRadiation_MJ_m2_', 'DewPointTemperature__C_'});
    fullmodelpredict = predict(fullModel, predPredictors);
    predictions1a(:, hour) = fullmodelpredict;
    AdjRsq1a(hour,1) = fullModel.Rsquared.Adjusted;
end

% Step 3: Stepwise Model (Model 1b)
for hour = 1:24
    % Select data for the current hour
    hourData = filteredData(filteredData.Hour == hour-1, :);
    real_y = hourData.RentedBikeCount(end-19:end);
    real_yall(:, hour) = real_y;
    trainingData = hourData(1:end - 20, :);
    X = trainingData(:, {'Temperature__C_', 'Humidity___', 'Rainfall_mm_', 'Visibility_10m_', 'WindSpeed_m_s_', 'Snowfall_cm_', 'SolarRadiation_MJ_m2_', 'DewPointTemperature__C_'});
    y = trainingData.RentedBikeCount; 
    y = array2table(y);
    trainingmatrix = [X,y];
   
    % Train Stepwise Regression Model 
    stepwiseModel = stepwiselm(trainingmatrix, 'y ~ Temperature__C_ + Humidity___ + Rainfall_mm_ + Visibility_10m_ + WindSpeed_m_s_ + Snowfall_cm_ + SolarRadiation_MJ_m2_ + DewPointTemperature__C_'); 

    % Step 4: Prediction
    prediction_data =  hourData(end-19:end,:);
    X_pred = prediction_data{:, {'Temperature__C_', 'Humidity___', 'Rainfall_mm_', 'Visibility_10m_', 'WindSpeed_m_s_', 'Snowfall_cm_', 'SolarRadiation_MJ_m2_', 'DewPointTemperature__C_'}};
    predPredictors = array2table(X_pred, 'VariableNames', {'Temperature__C_', 'Humidity___', 'Rainfall_mm_', 'Visibility_10m_', 'WindSpeed_m_s_', 'Snowfall_cm_', 'SolarRadiation_MJ_m2_', 'DewPointTemperature__C_'});
    stepwisepredict = predict(stepwiseModel,predPredictors);
    predictions1b(:, hour) = stepwisepredict;  
    AdjRsq1b(hour,1) = stepwiseModel.Rsquared.Adjusted;
end

% Step 5: Plotting
figure;

% Set a threshold for extreme values
lower_threshold = -500;
upper_threshold = 3500;

% Plotting Real vs Predicted values for Model 1a
subplot(2, 2, 1);
real_yall_clipped = max(min(real_yall, upper_threshold), lower_threshold);
predictions1a_clipped = max(min(predictions1a, upper_threshold), lower_threshold);
plot(1:numel(real_yall_clipped), real_yall_clipped(:), '-o', 'DisplayName', 'Real Values');
hold on;
plot(1:numel(predictions1a_clipped), predictions1a_clipped(:), '-o', 'DisplayName', 'Predicted Values');
xlabel('Observation');
ylabel('Rented Bike Count');
title('Model 1a: Real vs Predicted (Capped between -500 and 3500)');
legend('Real Values', 'Predicted Values');
hold off;

% Plotting Real vs Predicted values for Model 1b
subplot(2, 2, 2);
real_yall_clipped = max(min(real_yall, upper_threshold), lower_threshold);
predictions1b_clipped = max(min(predictions1b, upper_threshold), lower_threshold);
plot(1:numel(real_yall_clipped), real_yall_clipped(:), '-o', 'DisplayName', 'Real Values');
hold on;
plot(1:numel(predictions1b_clipped), predictions1b_clipped(:), '-o', 'DisplayName', 'Predicted Values');
xlabel('Observation');
ylabel('Rented Bike Count');
title('Model 1b: Real vs Predicted (Capped between -500 and 3500)');
legend('Real Values', 'Predicted Values');
hold off;

% Calculate standardized residuals
residuals1a = (real_yall(:) - predictions1a(:)) ./ std(predictions1a(:));
residuals1b = (real_yall(:) - predictions1b(:)) ./ std(predictions1b(:));

% Plotting standardized residuals for Model 1a
subplot(2, 2, 3);
plot(1:length(residuals1a), residuals1a, 'o');
xlabel('Observation');
ylabel('Standardized Residuals');
title('Model 1a: Standardized Residuals');

% Plotting standardized residuals for Model 1b
subplot(2, 2, 4);
plot(1:length(residuals1b), residuals1b, 'o');
xlabel('Observation');
ylabel('Standardized Residuals');
title('Model 1b: Standardized Residuals');

set(gcf, 'Position', [100, 100, 1200, 800]);
hold off;

% Step 6: Model 2
trainingdata2 = filteredData(1:end - 20*24, :);
real_yall2 = filteredData.RentedBikeCount(end-20*24-1:end);
X2 = trainingdata2(:, {'Temperature__C_', 'Humidity___', 'Rainfall_mm_', 'Visibility_10m_', 'WindSpeed_m_s_', 'Snowfall_cm_', 'SolarRadiation_MJ_m2_', 'DewPointTemperature__C_'});
y2 = trainingdata2.RentedBikeCount;
y2 = array2table(y2);
trainingmatrix2 = [X2,y2];

fullmodel2 = fitlm(trainingmatrix2, 'y2 ~ Temperature__C_ + Humidity___ + Rainfall_mm_ + Visibility_10m_ + WindSpeed_m_s_ + Snowfall_cm_ + SolarRadiation_MJ_m2_ + DewPointTemperature__C_');
stepwiseModel2 = stepwiselm(trainingmatrix2, 'y2 ~ Temperature__C_ + Humidity___ + Rainfall_mm_ + Visibility_10m_ + WindSpeed_m_s_ + Snowfall_cm_ + SolarRadiation_MJ_m2_ + DewPointTemperature__C_'); 

 % Step 7: Prediction
prediction_data =  filteredData(end-20*24-1:end,:);
X_pred = prediction_data{:, {'Temperature__C_', 'Humidity___', 'Rainfall_mm_', 'Visibility_10m_', 'WindSpeed_m_s_', 'Snowfall_cm_', 'SolarRadiation_MJ_m2_', 'DewPointTemperature__C_'}};
predPredictors = array2table(X_pred, 'VariableNames', {'Temperature__C_', 'Humidity___', 'Rainfall_mm_', 'Visibility_10m_', 'WindSpeed_m_s_', 'Snowfall_cm_', 'SolarRadiation_MJ_m2_', 'DewPointTemperature__C_'});
fullmodelpredict2 = predict(fullmodel2, predPredictors);
stepwisepredict2 = predict(stepwiseModel2,predPredictors);

Rsquared2a = fullmodel2.Rsquared.Adjusted;
Rsquared2b = stepwiseModel2.Rsquared.Adjusted;

% Plotting Real vs Predicted values for Model 2a
figure;
subplot(2, 2, 1);
plot(1:numel(real_yall2), real_yall2(:), '-o', 'DisplayName', 'Real Values');
hold on;
plot(1:numel(fullmodelpredict2), fullmodelpredict2(:), '-o', 'DisplayName', 'Predicted Values');
xlabel('Observation');
ylabel('Rented Bike Count');
title('Model 2a: Real vs Predicted');
legend('Real Values', 'Predicted Values');
hold off;

% Plotting Real vs Predicted values for Model 2b
subplot(2, 2, 2);
plot(1:numel(real_yall2), real_yall2(:), '-o', 'DisplayName', 'Real Values');
hold on;
plot(1:numel(stepwisepredict2), stepwisepredict2(:), '-o', 'DisplayName', 'Predicted Values');
xlabel('Observation');
ylabel('Rented Bike Count');
title('Model 2b: Real vs Predicted');
legend('Real Values', 'Predicted Values');
hold off;

% Calculate standardized residuals
residuals1a = (real_yall2(:) - fullmodelpredict2(:)) ./ std(fullmodelpredict2(:));
residuals1b = (real_yall2(:) - stepwisepredict2(:)) ./ std(stepwisepredict2(:));

% Plotting standardized residuals for Model 2a
subplot(2, 2, 3);
plot(1:length(fullmodelpredict2), residuals1a, 'o');
xlabel('Observation');
ylabel('Standardized Residuals');
title('Model 2a: Standardized Residuals');

% Plotting standardized residuals for Model 2b
subplot(2, 2, 4);
plot(1:length(stepwisepredict2), residuals1b, 'o');
xlabel('Observation');

ylabel('Standardized Residuals');
title('Model 2b: Standardized Residuals');

set(gcf, 'Position', [100, 100, 1200, 800]);
hold off;

fprintf('The adjusted R^2 values for model 1a are: \n');
disp(AdjRsq1a);
fprintf('The adjusted R^2 values for model 1b are: \n');
disp(AdjRsq1b);
fprintf('The adjusted R^2 values for model 2a are: %s.\n', Rsquared2a);
fprintf('The adjusted R^2 values for model 2b are: %s.\n', Rsquared2b);

% Season 2 has been chosen to present the results.
% Values have been capped at -500 and 3500 to prevent extremes from 
% distorting the diagrams.

% Model 1 seems to provide a significantly better fit for the data than
% model 2, something shown both in the diagrams of real vs predicted values 
% and the standardized residuals, which in the case of model 1 are equally
% spread around zero with smaller variation and fewer extreme values. 

% Stepwise regression provides a better fit both in model 1 and 2 as shown
% by the spread of the standardized residuals. However the difference is
% more noticable in model 2 where there are significantly less standardized residual values
% exceeding the limits of (-2,2). The difference is also shown in the
% real vs predicted values diagrams, especially in the case of model 2
% where it becomes clear immediately that Stepwise is better.