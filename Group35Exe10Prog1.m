% DATA ANALYSIS PROJECT - EXERCISE 10
% Dafni Nikolaidou (10546)  Nikolaos Barkas (10483)

clc; clear all; clearvars;

% Importing the excel file.
bike_data = readtable("SeoulBike.xlsx");
bike_data = bike_data(bike_data.Holiday == 0, :);
season_data = bike_data(bike_data.Seasons == 4, :); %Change season here

% Set maximum lag (maximum hours of delay)
max_p = 10; 
d = 5; % dimension reduction

% Initialize matrices to store results
r2LASSO = zeros(24, max_p);
r2OLS = zeros(24, max_p);

% Train model for each season, hour of the day and different lag values
for hour = 0:23
    hourdata = season_data(season_data.Hour == hour, :);
    for p = 1 : max_p
        % Create lagged variables for predictors
        Lagged_X = hourdata{:, {'Temperature__C_', 'Humidity___', 'Rainfall_mm_', 'Visibility_10m_', 'WindSpeed_m_s_', 'Snowfall_cm_', 'SolarRadiation_MJ_m2_', 'DewPointTemperature__C_'}};
        Lagged_X = lagmatrix(Lagged_X, p);
        
        % Response variable (Bikes) for the current hour
        y = hourdata.RentedBikeCount;
        
        % Exclude rows with NaN values
        valid_rows = all(~isnan(Lagged_X), 2);
        Lagged_X = Lagged_X(valid_rows, :);
        y = y(valid_rows);
        
        n = length(Lagged_X);
        mux = mean(Lagged_X);
        xc = Lagged_X - repmat(mux,n,1);
        muy = mean(y);
        yc = y - muy;
        [u,sigma,v] = svd(xc,'econ');

        % LASSO Model
        [bL,fitinfo] = lasso(xc,yc);
        lambda = 0.5;
        [lmin, ilmin] = min(abs(fitinfo.Lambda - lambda));
        bLASSO = bL(:,ilmin);
        bLASSO = [muy - mux*bLASSO; bLASSO];
        yLASSO = [ones(n,1) Lagged_X] * bLASSO;
        resLASSO = y - yLASSO;
        RSS_LASSO = sum(resLASSO.^2);
        TSS = sum((y-muy).^2);
        r2LASSO(hour + 1, p) = 1 - RSS_LASSO/TSS;

        % Principal Least Squares - PLS Model
        [Xl,Yl,Xscores,Yscores,bPLS] = plsregress(Lagged_X,y,d);
        yPLS = [ones(n,1) Lagged_X]*bPLS;
        resPLS = y - yPLS;
        RSS_PLS = sum(resPLS.^2);
        r2PLS(hour + 1, p) = 1 - RSS_PLS/TSS;
    end
end

% Plot the results
figure;

subplot(2, 1, 1);
imagesc(r2LASSO);
colorbar;
title('Adjusted R-squared - LASSO Model');
xlabel('Lag');
ylabel('Hour of the Day');
xticks(1:max_p);
yticks(1:24);
axis xy;

subplot(2, 1, 2);
imagesc(r2PLS);
colorbar;
title('Adjusted R-squared - PLS Model');
xlabel('Lag');
ylabel('Hour of the Day');
xticks(1:max_p);
yticks(1:24);
axis xy;

% Generally there are some hours of the day,usually later ones,for which 
% the amount of rented bikes can be predicted from meteorogical indicators
% of previous hours.

% Season 1: The LASSO and PLS model have similar performance. The models
% are most efficient for predicted rented bikes on hours 11-16 with lag 1,
% while the maximum lag that gives relatively good prediction for only a
% few hours (11,20,23) is 4.

% Season 2: In this case, the LASSO model seems to work for more hours of
% the day and also gives better results for bigger lag values (up to 8)
% on some hours. The best fit comes from the LASSO model for hours 19-21 
% and lag 1.

% Season 3: Both the LASSO and PLS model produce good fitting results for
% hours 11-18 and work for a maximum lag of 6, with the best fit resulting
% from lag 1.

% Season 4: The LASSO and PLS model have similar performance. The models
% are most efficient for predicted rented bikes on hours 1 and 20-24. The
% best fit in this case is for the maximum lag of 9.