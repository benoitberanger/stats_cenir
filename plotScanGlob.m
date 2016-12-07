function plotScanGlob

%% Import, parse, prepare

[ t , col , hdr ] = prepareTables;
% list = fieldnames(t);
% vars = {'num' 'txt' 'raw'};


%% Stats

[ s , col , hdr ] = table2stat( t , col , hdr );

current_dateVect = datevec(now);
years = 2010:current_dateVect(1);


%% Add one year so the stair() function will be look better

s.Ty(end+1,:) = nan;
s.Ny(end+1,:) = nan;
% s.Tm(end+1,:) = nan;
% s.Nm(end+1,:) = nan;


%% Plot : per year

LineStyle.T = '-';
LineStyle.N = '-';

Marker.T = 'none';
Marker.N = 'none';

Color.T = [0 0 1];
Color.N = [0 0.7 0];

LineWidth = 2;


%% Years in line

figure('Name','Global, per year, time serie','NumberTitle','off')

ax = zeros(2,1);
ax(1) = subplot(2,1,1);
ax(2) = subplot(2,1,2);


axes(ax(1))
hold all
title('hours on the planning  : Prisma + Verio')

stairs(ax(1),s.Ty(:,col.res.prisma_e) + s.Ty(:,col.res.verio_e),...
    'LineStyle',LineStyle.T,...
    'Marker',Marker.T,...
    'Color',Color.T,...
    'LineWidth',LineWidth,...
    'DisplayName','hours');

% hours_available_per_year_per_machine = 48 * 5 * 9; % weeks * days * hours
% max_hours_year = hours_available_per_year_per_machine*[1 2*ones(1,length(2011:current_dateVect(1))) nan];
% stairs(ax(1),max_hours_year,...
%     'LineStyle','--',...
%     'Color','black',...
%     'LineWidth',LineWidth,...
%     'DisplayName','max');

legend(ax(1),'Location','NorthWest');

set(ax(1),'XTick',1:size(s.Ty,1)-1)
set(ax(1),'XTickLabel',num2str(s.Ty(:,col.res.year)))
set(ax(1),...
    'XGrid','on',...
    'YGrid','on',...
    'XMinorGrid','off',...
    'YMinorGrid','off',...
    'GridLineStyle',':')

axes(ax(2))
hold all
title('hours on the planning  : Prisma + Verio')

plot(ax(2),s.Tm(:,col.res.prisma_e) + s.Tm(:,col.res.verio_e),...
    'LineStyle',LineStyle.T,...
    'Marker',Marker.T,...
    'Color',Color.T,...
    'LineWidth',LineWidth,...
    'DisplayName','hours');

% hours_available_per_month_per_machine = 4 * 5 * 9; % weeks * days * hours
% max_hours_month = hours_available_per_month_per_machine*[ones(1,12) 2*ones(1,12*length(2011:current_dateVect(1))) nan];
% stairs(ax(2),max_hours_month,...
%     'LineStyle','--',...
%     'Color','black',...
%     'LineWidth',LineWidth,...
%     'DisplayName','max');

legend(ax(2),'Location','NorthWest');

set(ax(2),'XTick',1:12:s.Tm(end,col.res.month_idx))
set(ax(2),'XTickLabel',num2str(s.Ty(:,col.res.year)))
set(ax(2),...
    'XGrid','on',...
    'YGrid','on',...
    'XMinorGrid','off',...
    'YMinorGrid','off',...
    'GridLineStyle',':')

% axis(ax(:),'tight')
xlim(ax(1),[1 size(s.Ty,1)])
xlim(ax(2),[1 size(s.Tm,1)+1])
% ylim(ax(1),[ 0 hours_available_per_year_per_machine*2*1.10 ])
% ylim(ax(2),[ 0 hours_available_per_month_per_machine*2*1.10 ])


%% How many hours in total ?

fprintf('\n total hours scanned @ Trio/Prisma = %d \n',sum(s.Tm(:,col.res.prisma_e)));
fprintf('\n total hours scanned @ Verio = %d \n',sum(s.Tm(:,col.res.verio_e)));
fprintf('\n total hours scanned = %d \n',sum(s.Tm(:,col.res.prisma_e) + s.Tm(:,col.res.verio_e)));


%% Supperposed years

figure('Name','Global, per year, supperposed years','NumberTitle','off')
hold all
title('hours on the planning  : Prisma + Verio')

myColors = Jet(length(years));

all = zeros(12,1);

for y = 1 : length(years)
    
    idx = s.Tm(:,col.res.year) == years(y);
    
    currentcurve = s.Tm(idx,col.res.prisma_e) + s.Tm(idx,col.res.verio_e);
    all = all + currentcurve;
    
    plot(1:12,...
        currentcurve,...
        'LineStyle',LineStyle.T,...
        'Marker',Marker.T,...
        'Color',myColors(y,:),...
        'LineWidth',LineWidth,...
        'DisplayName',num2str(years(y)));
    
end

all = all / length(years);
plot(1:12,...
        all,...
        'LineStyle','--',...
        'Color','black',...
        'LineWidth',LineWidth,...
        'DisplayName','mean');
legend(gca,'Location','best');

axis tight
title('hours')

set(gca,'XTick',1:12)
set(gca,'XTickLabel',{'J' 'F' 'M' 'A' 'M' 'J' 'J' 'A' 'S' 'O' 'N' 'D'})
set(gca,...
    'XGrid','on',...
    'YGrid','on',...
    'XMinorGrid','off',...
    'YMinorGrid','off',...
    'GridLineStyle',':')


end % function
