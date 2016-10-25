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



%% prepare the curves

for y = 1 : length(years)
    
    table.annulation.perYears.(sprintf('y%d',years(y))).mean.total = ...
        nanmean(table.annulation.perYears.(sprintf('y%d',years(y))).total);
    table.annulation.perYears.(sprintf('y%d',years(y))).mean.m10 = ...
        nanmean(table.annulation.perYears.(sprintf('y%d',years(y))).m10);
    table.annulation.perYears.(sprintf('y%d',years(y))).mean.auto = ...
        nanmean(table.annulation.perYears.(sprintf('y%d',years(y))).auto);
    table.annulation.perYears.(sprintf('y%d',years(y))).mean.p10 = ...
        nanmean(table.annulation.perYears.(sprintf('y%d',years(y))).p10);
    
    table.entry.perYears.(sprintf('y%d',years(y))).mean.total = ...
        nanmean(table.entry.perYears.(sprintf('y%d',years(y))).total);
    
end

year.scan = nan(length(years),2);
year.total = nan(length(years),2);
year.m10 = nan(length(years),2);
year.auto = nan(length(years),2);
year.p10 = nan(length(years),2);

for y = 1 : length(years)
    
    year.scan(y,:) = table.entry.perYears.(sprintf('y%d',years(y))).mean.total;
    year.total(y,:) = table.annulation.perYears.(sprintf('y%d',years(y))).mean.total;
    year.m10(y,:) = table.annulation.perYears.(sprintf('y%d',years(y))).mean.m10;
    year.auto(y,:) = table.annulation.perYears.(sprintf('y%d',years(y))).mean.auto;
    year.p10(y,:) = table.annulation.perYears.(sprintf('y%d',years(y))).mean.p10;
    
end

month.scan = table.entry.perMonth.total;
month.total = table.annulation.perMonth.total;
month.m10 = table.annulation.perMonth.m10;
month.auto = table.annulation.perMonth.auto;
month.p10= table.annulation.perMonth.p10;
  
    
%% General parameters

timeVectYEARS = 1 : length(years);
timeVectMONTHS = 1 : size(month.scan,1);

LineStyle.pv = '-';
LineStyle.p = '-';
LineStyle.v = '-';

Marker.pv = 'none';
Marker.p = 'none';
Marker.v = 'none';

Color.pv = [1 0 0];
Color.p = [0 0 1];
Color.v = [0 0.7 0];

LineWidth = 2;


%% Plot

figure(...
    'Name'        ,'Annul (%) per year',...
    'NumberTitle' ,'off'                       ,...
    'Units'       , 'Normalized'               ,...
    'Position'    , [0.05, 0.05, 0.90, 0.80]    ...
    )

ax = zeros(2,1);
ax(1) = subplot(2,1,1);
ax(2) = subplot(2,1,2);

axes(ax(1))
hold all

ratioPV = 100*(sum(year.m10,2)+sum(year.auto,2))./...
    (sum(year.scan,2) + sum(year.m10,2)+sum(year.auto,2));
plot(ax(1),...
    timeVectYEARS,ratioPV,... % Prisma + Verio
    'LineStyle',LineStyle.pv,...
    'Marker',Marker.pv,...
    'Color',Color.pv,...
    'LineWidth',LineWidth,...
    'DisplayName','Prisma + Verio');

ratioP = 100*(year.m10(:,1)+year.auto(:,1))./...
    (year.scan(:,1) + year.m10(:,1)+year.auto(:,1));
plot(ax(1),...
    timeVectYEARS,ratioP,... % Prisma
    'LineStyle',LineStyle.p,...
    'Marker',Marker.p,...
    'Color',Color.p,...
    'LineWidth',LineWidth,...
    'DisplayName','Prisma');

ratioV = 100*(year.m10(:,2)+year.auto(:,2))./...
    (year.scan(:,2) + year.m10(:,2)+year.auto(:,2));
plot(ax(1),...
    timeVectYEARS,ratioV,... % Verio
    'LineStyle',LineStyle.v,...
    'Marker',Marker.v,...
    'Color',Color.v,...
    'LineWidth',LineWidth,...
    'DisplayName','Verio');
ylabel(ax(1),'100*( -10j + auto ) / ( Scan + -10j + auto )')


axes(ax(2))
hold all

ratioPV = 100*(sum(month.m10,2)+sum(month.auto,2))./...
    (sum(month.scan,2) + sum(month.m10,2)+sum(month.auto,2));
plot(ax(2),...
    timeVectMONTHS,ratioPV,... % Prisma + Verio
    'LineStyle',LineStyle.pv,...
    'Marker',Marker.pv,...
    'Color',Color.pv,...
    'LineWidth',LineWidth,...
    'DisplayName','Prisma + Verio');

ratioP = 100*(month.m10(:,1)+month.auto(:,1))./...
    (month.scan(:,1) + month.m10(:,1)+month.auto(:,1));
plot(ax(2),...
    timeVectMONTHS,ratioP,... % Prisma
    'LineStyle',LineStyle.p,...
    'Marker',Marker.p,...
    'Color',Color.p,...
    'LineWidth',LineWidth,...
    'DisplayName','Prisma');

ratioV = 100*(month.m10(:,2)+month.auto(:,2))./...
    (month.scan(:,2) + month.m10(:,2)+month.auto(:,2));
plot(ax(2),...
    timeVectMONTHS,ratioV,... % Verio
    'LineStyle',LineStyle.v,...
    'Marker',Marker.v,...
    'Color',Color.v,...
    'LineWidth',LineWidth,...
    'DisplayName','Verio');
ylabel(ax(2),'100*( -10j + auto ) / ( Scan + -10j + auto )')


% Adjustements

legend(ax(1),'Location','SouthWest')
% legend(ax(2),'Location','Best')

set(ax(1),'XTickLabel',1:length(years))
set(ax(2),'XTick',1:12:timeVectMONTHS(end))
set(ax(:),'XTickLabel',num2str(years))

set(ax(:),...
    'XGrid','on',...
    'YGrid','on',...
    'XMinorGrid','off',...
    'YMinorGrid','off',...
    'GridLineStyle',':')

pos = get(ax(:),'Position');

axis(ax(:),'tight')

xlim(ax(1),[1 length(years)+ mod((length(timeVectMONTHS)-1)/12,1)])
% ylim(ax(1),ylim(ax(2)))

% linkaxes(ax,'x')
