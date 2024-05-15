% DATA ANALYSIS PROJECT - EXERCISE 1
% Dafni Nikolaidou (10546)  Nikolaos Barkas (10483)

clc; clear all; clearvars;

%Importing the excel file
bike_data = readtable("SeoulBike.xlsx");

% Season selection
prompt = 'Choose season (Type 1, 2, 3 ή 4): ';
epoxh = input(prompt);
switch epoxh
    case 1 % Winter
        season_data = bike_data(bike_data.Seasons == 1, :);
    case 2 % Spring
        season_data = bike_data(bike_data.Seasons == 2, :);
    case 3 % Summer
        season_data = bike_data(bike_data.Seasons == 3, :);
    case 4 % Autumn
        season_data = bike_data(bike_data.Seasons == 4, :);
end

% Extract data of each season
RentedBikes = season_data.RentedBikeCount;

% Testing for several distributions
pd(1) = fitdist(RentedBikes, 'Normal');
pd(2) = fitdist(RentedBikes, 'Exponential');
pd(3) = fitdist(RentedBikes, 'Kernel');
pd(4) = fitdist(RentedBikes, 'Lognormal');
pd(5) = fitdist(RentedBikes, 'Poisson');
pd(6) = fitdist(RentedBikes, 'Nakagami');
pd(7) = fitdist(RentedBikes, 'Gamma');
pd(8) = fitdist(RentedBikes, 'Rician');
pd(9) = fitdist(RentedBikes, 'Rayleigh');
pd(10) = fitdist(RentedBikes, 'InverseGaussian');
pd(11) = fitdist(RentedBikes, 'Kernel');


figure;

for i = 1:11
    % Chi-squared goodness-of-fit test
    [~, p(i)] = chi2gof(RentedBikes, 'CDF', pd(i),'Alpha',0.05);
end

[best_p,idx] = max(p);
fprintf('The optimal distribution is %s.\n',pd(1, idx).DistributionName);

% Plot the histogram and the fitted distribution
histogram(RentedBikes, 'Normalization', 'pdf');
hold on;
x = linspace(min(RentedBikes), max(RentedBikes), 1000);
y = pdf(pd(idx), x);
plot(x, y, 'LineWidth', 2);
hold off;

% The best fitting distribution is chosen based on the
% p-value, with the best distribution being the one with the highest p-value. 
% The Kernel distribution proves to be the most adequate on all 4 Seasons.
