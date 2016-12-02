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


%% Prepare the figure

figure(...
    'Name'        ,'reservations + annulations',...
    'NumberTitle' ,'off'                       ,...
    'Units'       , 'Normalized'               ,...
    'Position'    , [0.05, 0.05, 0.90, 0.80]    ...
    )

ax = zeros(3,1);
ax(1) = subplot(4,1,1);
ax(2) = subplot(4,1,2:3);
ax(3) = subplot(4,1,4);

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


%% Plot reservation + totalAnnulation

axes(ax(1))
hold all

% entry
plot(ax(1),...
    timeVect,sum(table.entry.perMonth.total,2),... % Prisma + Verio
    'LineStyle',LineStyle.entry,...
    'Color',Color.Both,...
    'LineWidth',LineWidth,...
    'DisplayName','O Prisma + O Verio');

% totalAnnulation
plot(ax(1),...
    timeVect,sum(table.annulation.perMonth.total,2),... % Prisma + Verio
    'LineStyle',LineStyle.annulation,...
    'Color',Color.Both,...
    'LineWidth',LineWidth,...
    'DisplayName','X Prisma + X Verio');

ylabel('Prisma + Verio')


%%

axes(ax(2))
hold all

plot(ax(2),...
    timeVect,table.entry.perMonth.total(:,1),... % Prisma
    'LineStyle',LineStyle.entry,...
    'Color',Color.Prisma,...
    'LineWidth',LineWidth,...
    'DisplayName','O Prisma');

plot(ax(2),...
    timeVect,table.entry.perMonth.total(:,2),... % Verio
    'LineStyle',LineStyle.entry,...
    'Color',Color.Verio,...
    'LineWidth',LineWidth,...
    'DisplayName','O Verio');

plot(ax(2),...
    timeVect,table.annulation.perMonth.total(:,1),... % Prisma
    'LineStyle',LineStyle.annulation,...
    'Color',Color.Prisma,...
    'LineWidth',LineWidth,...
    'DisplayName','X Prisma');

plot(ax(2),...
    timeVect,table.annulation.perMonth.total(:,2),... % Verio
    'LineStyle',LineStyle.annulation,...
    'Color',Color.Verio,...
    'LineWidth',LineWidth,...
    'DisplayName','X Verio');

ylabel('Prisma vs. Verio')


%% Plot reservation + totalAnnulation

axes(ax(3))
hold all

% m10
plot(ax(3),...
    timeVect,sum(table.annulation.perMonth.m10,2),... % Prisma
    'LineStyle',LineStyle.entry,...
    'Color',[1 0 0],...
    'LineWidth',LineWidth,...
    'DisplayName','- 10j');

% auto
plot(ax(3),...
    timeVect,sum(table.annulation.perMonth.auto,2),... % Verio
    'LineStyle',LineStyle.entry,...
    'Color',[0 0 1],...
    'LineWidth',LineWidth,...
    'DisplayName','10j = auto');

% p10
plot(ax(3),...
    timeVect,sum(table.annulation.perMonth.p10,2),... % Prisma + Verio
    'LineStyle',LineStyle.entry,...
    'Color',[0 1 0],...
    'LineWidth',LineWidth,...
    'DisplayName','+ 10j');

ylabel('Prisma + Verio')


%% Adjustements

legend(ax(1),'Location','NorthWest')
legend(ax(2),'Location','NorthWest')
legend(ax(3),'Location','NorthWest')

set(ax(:),'XTick',1:12:timeVect(end))
set(ax(:),'XTickLabel',num2str(years))
set(ax(:),'XGrid','on')

axis(ax(:),'tight')

linkaxes(ax,'x')
