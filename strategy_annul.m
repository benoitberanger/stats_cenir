%% Init

close all
clearvars -except annulation month2year years entry
clc


%% Load: smart method

global annulation years entry

if isempty(annulation)
    load data_annulation.mat
end

if isempty(entry)
    load data_entry.mat
end

table.annulation = annulation;
table.entry = entry;


%% fetch data

timeVect = 13:size(table.annulation.allMonths.str,1);

data = struct;

data.m10.curve = sum(table.annulation.perMonth.m10,2);
data.m10.curve(1:12) = [];
data.m10.curve(end) = [];
data.auto.curve = sum(table.annulation.perMonth.auto,2);
data.auto.curve(1:12) = [];
data.auto.curve(end) = [];
data.p10.curve = sum(table.annulation.perMonth.auto,2);
data.p10.curve(1:12) = [];
data.p10.curve(end) = [];

data.annul.soft.curve = data.m10.curve;
data.annul.soft.curveMean = mean(data.annul.soft.curve);
data.annul.soft.curveIncome = data.annul.soft.curve * 30;
data.annul.soft.totalIncome = sum(data.annul.soft.curveIncome);
data.annul.soft.monthIncomeMean = round(mean(data.annul.soft.curveIncome));
data.annul.soft.yearIncomeMean = data.annul.soft.monthIncomeMean*12;
data.annul.soft

data.annul.hard.curve = data.m10.curve + data.auto.curve;
data.annul.hard.curveMean = mean(data.annul.hard.curve);
data.annul.hard.curveIncome = data.annul.hard.curve * 150;
data.annul.hard.totalIncome = sum(data.annul.hard.curveIncome);
data.annul.hard.monthIncomeMean = round(mean(data.annul.hard.curveIncome));
data.annul.hard.yearIncomeMean = data.annul.hard.monthIncomeMean*12;
data.annul.hard

%%


%% General parameters



% figure(...
%     'Name'        ,'strat_annul',...
%     'NumberTitle' ,'off'                       ,...
%     'Units'       , 'Normalized'               ,...
%     'Position'    , [0.05, 0.05, 0.90, 0.80]    ...
%     )
% 
% plot(timeVect,);

