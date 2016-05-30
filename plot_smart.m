%% Init

close all
clearvars -except annulation month2year years entry
clc


%% Load: smart method

global annulation years entry

if isempty(annulation)
    load annulations_data.mat
end

if isempty(entry)
    load entry_data.mat
end


%% Prepare the figure

figure('Name','allYears','NumberTitle','off')