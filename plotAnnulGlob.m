function plotAnnulGlob


%% Import, parse, prepare

[ t , col , hdr ] = prepareTables;
list = fieldnames(t);
vars = {'num' 'txt' 'raw'};


%% Stats

[ s , col , hdr ] = table2stat( t , col , hdr );

current_dateVect = datevec(now);
% years = 2010:current_dateVect(1);


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


% Years in line

figure('Name','Global, per year, time serie','NumberTitle','off')

ax = zeros(2,1);
ax(1) = subplot(2,1,1);
ax(2) = subplot(2,1,2);


axes(ax(1))
hold all
stairs(ax(1),s.Ty(:,col.res.prisma_e) + s.Ty(:,col.res.verio_e),...
    'LineStyle',LineStyle.T,...
    'Marker',Marker.T,...
    'Color',Color.T,...
    'LineWidth',LineWidth,...
    'DisplayName','hours');

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
plot(ax(2),s.Tm(:,col.res.prisma_e) + s.Tm(:,col.res.verio_e),...
    'LineStyle',LineStyle.T,...
    'Marker',Marker.T,...
    'Color',Color.T,...
    'LineWidth',LineWidth,...
    'DisplayName','hours');

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

end % function
