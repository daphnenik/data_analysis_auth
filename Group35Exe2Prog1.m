% DATA ANALYSIS PROJECT - EXERCISE 2
% Dafni Nikolaidou (10546)  Nikolaos Barkas (10483)

clc;
clear;
close all;

bike_data = readtable("SeoulBike.xlsx");

season_data{1} = bike_data(bike_data.Seasons == 1, :);
season_data{2} = bike_data(bike_data.Seasons == 2, :);
season_data{3} = bike_data(bike_data.Seasons == 3, :);
season_data{4} = bike_data(bike_data.Seasons == 4, :);

sample_size = 100;

M = 100;
alpha = 0.05;

comparisons = [
    1 2;
    1 3;
    1 4;
    2 3;
    2 4;
    3 4
];

chi2_results_matrix = zeros(M,size(comparisons, 1));

for i = 1 : M
    rand_sample{1} = datasample(season_data{1}.RentedBikeCount, sample_size, 'Replace', false);
    rand_sample{2} = datasample(season_data{2}.RentedBikeCount, sample_size, 'Replace', false);
    rand_sample{3} = datasample(season_data{3}.RentedBikeCount, sample_size, 'Replace', false);
    rand_sample{4} = datasample(season_data{4}.RentedBikeCount, sample_size, 'Replace', false);    

    for pair = 1:size(comparisons, 1)
        s1_index = comparisons(pair, 1);
        s2_index = comparisons(pair, 2);
        

        % Create histograms
        edges = linspace(min([rand_sample{s1_index}; rand_sample{s2_index}]), max([rand_sample{s1_index}; rand_sample{s2_index}]), 40);
        histObserved = histcounts(rand_sample{s1_index}, edges);
        histExpected = histcounts(rand_sample{s2_index}, edges); 
        
        % Performing a X^2 test for each pair
        [h1, p_value1, chi2stat] = chi2gof((1:numel(histObserved))', 'ctrs', edges(1:end-1)', 'freq', histObserved, 'expected', histExpected);
        chi2_results_matrix(i,pair) = p_value1;
        
        %Performing two-sample Kolmogorov-Smirnov test for each pair
        [h2,p_value2] = kstest2(histObserved,histExpected);
        ks2_results_matrix(i,pair) = p_value2;
        
    end

end

% Calculating the percentage of there not being a difference between the two
% distributions

fprintf('Comparison of Distributions (Percentage of Similarity using X^2 Test)\n');
fprintf('--------------------------------------------------------\n');
for pair = 1:size(comparisons, 1)
    s1_index = comparisons(pair, 1);
    s2_index = comparisons(pair, 2);
    similarity_percentage1 = (sum(chi2_results_matrix(:,pair) > alpha) / M);
    fprintf('Season %d vs Season %d: %.2f%%\n', s1_index, s2_index, similarity_percentage1 * 100);
end
fprintf('--------------------------------------------------------\n');

fprintf('Comparison of Distributions (Percentage of Similarity using K-S Test)\n');
fprintf('--------------------------------------------------------\n');
for pair = 1:size(comparisons, 1)
    s1_index = comparisons(pair, 1);
    s2_index = comparisons(pair, 2);
    similarity_percentage2 = (sum(ks2_results_matrix(:,pair) > alpha) / M);
    fprintf('Season %d vs Season %d: %.2f%%\n', s1_index, s2_index, similarity_percentage2 * 100);
end
fprintf('--------------------------------------------------------\n');

% The X^2 goodness of fit test does not seem to work properly in our case. 
% We suspect this is caused due to the criterion of exact match between histograms being very strict. 
% After some research, we came across the Kolmogorov - Smirnov test, which tests whether two samples came from the same distribution.
% The K - S two sample test seems to work better in this exercise.
% The results indicate quite a different distribution for season 1 compared to the other seasons which seem to match with each other.

