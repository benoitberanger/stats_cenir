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

table.annulation = annulation;
table.entry = entry;


%% Prepare the figure

figure(...
    'Name'        ,'reservations + annulations',...
    'NumberTitle' ,'off'                       ,...
    'Units'       , 'Normalized'               ,...
    'Position'    , [0.05, 0.05, 0.90, 0.80]    ...
    )

ax = zeros(2,1);
ax(1) = subplot(2,1,1);
ax(2) = subplot(2,1,2);

timeVect = 1:size(table.annulation.allMonths.str,1);

LineStyle.entry = '-';
LineStyle.annulation = ':';

% LineStyle.total = ':';
% LineStyle.m10 = ':';
% LineStyle.auto = ':';
% LineStyle.p10 = ':';

Color.Prisma = [0 0 1];
Color.Verio = [0 1 0];
Color.Both = [1 0 0];

LineWidth = 2;

lgd_1 = {};
lgd_2 = {};

%% Plot reservation + totalAnnulation

ax(1) = subplot(2,1,1);
hold all

% entry

plot(ax(1),...
    timeVect,table.entry.perMonth.total(:,1),... % Prisma
    'LineStyle',LineStyle.entry,...
    'Color',Color.Prisma,...
    'LineWidth',LineWidth);
lgd_1 = [ lgd_1 ; 'O Prisma' ];

plot(ax(1),...
    timeVect,table.entry.perMonth.total(:,2),... % Verio
    'LineStyle',LineStyle.entry,...
    'Color',Color.Verio,...
    'LineWidth',LineWidth);
lgd_1 = [ lgd_1 ; 'O Verio' ];

plot(ax(1),...
    timeVect,sum(table.entry.perMonth.total,2),... % Prisma + Verio
    'LineStyle',LineStyle.entry,...
    'Color',Color.Both,...
    'LineWidth',LineWidth);
lgd_1 = [ lgd_1 ; 'O Prisma + O Verio' ];

% totalAnnulation

plot(ax(1),...
    timeVect,table.annulation.perMonth.total(:,1),... % Prisma
    'LineStyle',LineStyle.annulation,...
    'Color',Color.Prisma,...
    'LineWidth',LineWidth);
lgd_1 = [ lgd_1 ; 'X Prisma' ];

plot(ax(1),...
    timeVect,table.annulation.perMonth.total(:,2),... % Verio
    'LineStyle',LineStyle.annulation,...
    'Color',Color.Verio,...
    'LineWidth',LineWidth);
lgd_1 = [ lgd_1 ; 'X Verio' ];

plot(ax(1),...
    timeVect,sum(table.annulation.perMonth.total,2),... % Prisma + Verio
    'LineStyle',LineStyle.annulation,...
    'Color',Color.Both,...
    'LineWidth',LineWidth);
lgd_1 = [ lgd_1 ; 'X Prisma + X Verio' ];

%% Plot reservation + totalAnnulation

ax(2) = subplot(2,1,2);
hold all

% m10
plot(ax(2),...
    timeVect,sum(table.annulation.perMonth.m10,2),... % Prisma
    'LineStyle',LineStyle.entry,...
    'Color',[1 0 0],...
    'LineWidth',LineWidth);
lgd_2 = [ lgd_2 ; '- 10j' ];

% auto
plot(ax(2),...
    timeVect,sum(table.annulation.perMonth.auto,2),... % Verio
    'LineStyle',LineStyle.entry,...
    'Color',[0 0 1],...
    'LineWidth',LineWidth);
lgd_2 = [ lgd_2 ; 'auto = 10j' ];

% p10
plot(ax(2),...
    timeVect,sum(table.annulation.perMonth.p10,2),... % Prisma + Verio
    'LineStyle',LineStyle.entry,...
    'Color',[0 1 0],...
    'LineWidth',LineWidth);
lgd_2 = [ lgd_2 ; '+ 10j' ];



%% Adjustements

legend(ax(1),lgd_1,'Location','NorthWest')
legend(ax(2),lgd_2,'Location','NorthWest')

set(ax(:),'XTick',1:12:timeVect(end))
set(ax(:),'XTickLabel',num2str(years))
set(ax(:),'XGrid','on')

axis(ax(:),'tight')

linkaxes(ax,'x')

