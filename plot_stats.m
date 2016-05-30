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


%% Refs

% ref = {...
%
% 'Créneau pilote'			'B';
% 'Créneau confirmé'			'A';
% 'Coupure électrique'			'C';
% 'Maintenance matérielle'			'D';
% 'Intervention CENIR'			'F';
% 'Présentation de projet IRM'			'H';
% 'Réunion d''équipe'			'P';
% 'Spécial'			'Q';
% 'Jour de congé'			'Z';
% 'Congrés et déplacement pro'			'Y';
% 'Maladie'			'X';
% 'Fermeture exceptionnelle'			'R';
% 'Formation'			'S';
% 'Réunion'			'T';
% 'Présentation de projet MEG'			'N';
% 'Pré-réservation'			'M';
% 'Cours'			'U';
% 'Créneau indisponible'			'E';
% 'Créneau disponible'			'I';
% 'Scan Paul Castaigne'			'G';
% 'Présentation de projet EEG'			'O';
% 'Tiwi'			'J';
% 'Panne'			'AA';
% };
%
% hdr = {
%     'id';
%     'cancel_time';
%     'start_time';
%     'end_time';
%     'entry_type';
%     'repeat_id';
%     'room_id';
%     'timestamp';
%     'create_by';
%     'del_by';
%     'name';
%     'type';
%     'description';
%     'statut_entry';
%     'option_reservation';
%     'facturable';
%     'opid';
%     'cancel_time_STR';
%     'start_time_STR';
%     'end_time_STR';
%     'diff_cancel_start(d)'
%     };



colors = jet(length(years));

lw = 2;


%% Plot table.annulation.perProtocol

protoToPlot = 'IMAGEN';


% 1 year = 1 graph
if 1
    
    figure('Name',[protoToPlot ' splitted'],'NumberTitle','off')
    
    plot_count = 0;
    ax = zeros(length(years),5);
    
    allMaxes.entry = max( table.entry.perProtocol.(protoToPlot).vect(:,3) );
    allMaxes.total = max( table.annulation.perProtocol.(protoToPlot).vect(:,3) );
    allMaxes.m10 = max( table.annulation.perProtocol.(protoToPlot).vect(:,4) );
    allMaxes.auto = max( table.annulation.perProtocol.(protoToPlot).vect(:,5) );
    allMaxes.p10 = max( table.annulation.perProtocol.(protoToPlot).vect(:,6) );
    
    
    if allMaxes.entry == 0
        allMaxes.entry = 1;
    end
    if allMaxes.total == 0
        allMaxes.total = 1;
    end
    if allMaxes.m10 == 0
        allMaxes.m10 = 1;
    end
    if allMaxes.auto == 0
        allMaxes.auto = 1;
    end
    if allMaxes.p10 == 0
        allMaxes.p10 = 1;
    end
    
    for y = 1 : length(years)
        
        yearIndex = find( table.annulation.perProtocol.(protoToPlot).vect(:,1) == years(y) );
        timeVect = 1:length( yearIndex );
        
        plot_count = plot_count + 1;
        ax(y,1) = subplot(length(years),5,plot_count);
        plot(timeVect,table.entry.perProtocol.(protoToPlot).vect(yearIndex,3),'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('reservation') , end
        ylabel(sprintf('%d',years(y)))
        
        plot_count = plot_count + 1;
        ax(y,2) = subplot(length(years),5,plot_count);
        plot(timeVect,table.annulation.perProtocol.(protoToPlot).vect(yearIndex,3),'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('totalAnnulation') , end
        ylabel(sprintf('%d',years(y)))
        
        plot_count = plot_count + 1;
        ax(y,3) = subplot(length(years),5,plot_count);
        plot(timeVect,table.annulation.perProtocol.(protoToPlot).vect(yearIndex,4),'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('m10') , end
        
        plot_count = plot_count + 1;
        ax(y,4) = subplot(length(years),5,plot_count);
        plot(timeVect,table.annulation.perProtocol.(protoToPlot).vect(yearIndex,5),'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('auto') , end
        
        plot_count = plot_count + 1;
        ax(y,5) = subplot(length(years),5,plot_count);
        plot(timeVect,table.annulation.perProtocol.(protoToPlot).vect(yearIndex,6),'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('p10') , end
        
    end
    
    axis(ax(:),'tight')
    
    for y = 1 : length(years)
        ylim(ax(y,1),[0 allMaxes.entry])
        ylim(ax(y,2),[0 allMaxes.total])
        ylim(ax(y,3),[0 allMaxes.m10])
        ylim(ax(y,4),[0 allMaxes.auto])
        ylim(ax(y,5),[0 allMaxes.p10])
    end
    
    linkaxes(ax,'x')
    
end


% 1 year = 1 line

if 1
    
    
    ax = zeros(5,1);
    lgd = cell(1,1);
    
    figure('Name',protoToPlot,'NumberTitle','off')
    
    sp1 = 5 ;
    sp2 = 1 ;
    
    for y = 1 : length(years)
        
        yearIndex = find( table.annulation.perProtocol.(protoToPlot).vect(:,1) == years(y) );
        timeVect = 1:length( yearIndex );
        
        ax(1) = subplot(sp1,sp2,1);
        hold all
        plot(timeVect,table.entry.perProtocol.(protoToPlot).vect(yearIndex,3),'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('reservation') , end
        lgd{1} = [ lgd{1} ; num2str(years(y)) ];
        
        ax(2) = subplot(sp1,sp2,2);
        hold all
        plot(timeVect,table.annulation.perProtocol.(protoToPlot).vect(yearIndex,3),'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('totalAnnulation') , end
        
        ax(3) = subplot(sp1,sp2,3);
        hold all
        plot(timeVect,table.annulation.perProtocol.(protoToPlot).vect(yearIndex,4),'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('m10') , end
        
        ax(4) = subplot(sp1,sp2,4);
        hold all
        plot(timeVect,table.annulation.perProtocol.(protoToPlot).vect(yearIndex,5),'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('auto') , end
        
        ax(5) = subplot(sp1,sp2,5);
        hold all
        plot(timeVect,table.annulation.perProtocol.(protoToPlot).vect(yearIndex,6),'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('p10') , end
        
    end
    
    legend(ax(1),lgd,'Location','Best');
    
    axis(ax(:),'tight')
    
    linkaxes(ax,'x')
    
end


% 1 line = all years

if 1
    
    ax = zeros(5,1);
    
    figure('Name',[protoToPlot ' allYears'],'NumberTitle','off')
    
    
    sp1 = 5 ;
    sp2 = 1 ;
    
    timeVect = 1:size(table.annulation.allMonths.str,1);
    
    ax(1) = subplot(sp1,sp2,1);
    plot(ax(1),timeVect,table.entry.perProtocol.(protoToPlot).vect(:,3),'LineWidth',lw)
    title('reservation')
    
    ax(2) = subplot(sp1,sp2,2);
    plot(ax(2),timeVect,table.annulation.perProtocol.(protoToPlot).vect(:,3),'LineWidth',lw)
    title('totalAnnulation')
    
    ax(3) = subplot(sp1,sp2,3);
    plot(ax(3),timeVect,table.annulation.perProtocol.(protoToPlot).vect(:,4),'LineWidth',lw)
    title('m10')
    
    ax(4) = subplot(sp1,sp2,4);
    plot(ax(4),timeVect,table.annulation.perProtocol.(protoToPlot).vect(:,5),'LineWidth',lw)
    title('auto')
    
    ax(5) = subplot(sp1,sp2,5);
    plot(ax(5),timeVect,table.annulation.perProtocol.(protoToPlot).vect(:,6),'LineWidth',lw)
    title('p10')
    
    set(ax(:),'XTick',1:12:timeVect(end))
    set(ax(:),'XTickLabel',num2str(years))
    
    axis(ax(:),'tight')
    
    linkaxes(ax,'x')
    
    
end


%% Regroup per year

% max for each category
allMaxes.entry = [];
allMaxes.total = [];
allMaxes.m10 = [];
allMaxes.auto = [];
allMaxes.p10 = [];

for y = 1 : length(years)
    allMaxes.entry = [allMaxes.entry nanmax( table.entry.perYears.(sprintf('y%d',years(y))).total ) ];
    allMaxes.total = [allMaxes.total nanmax( table.annulation.perYears.(sprintf('y%d',years(y))).total ) ];
    allMaxes.m10 = [allMaxes.m10 nanmax( table.annulation.perYears.(sprintf('y%d',years(y))).m10 ) ];
    allMaxes.auto = [allMaxes.auto nanmax( table.annulation.perYears.(sprintf('y%d',years(y))).auto ) ];
    allMaxes.p10 = [allMaxes.p10 nanmax( table.annulation.perYears.(sprintf('y%d',years(y))).p10 ) ];
    
end

% 1 year = 1 graph

if 1
    
    plot_count = 0;
    ax = zeros(length(years),5);
    
    figure('Name','perYear splitted','NumberTitle','off');
    
    for y = 1 : length(years)
        
        timeVect = 1:length(table.annulation.perYears.(sprintf('y%d',years(y))).total);
        
        plot_count = plot_count + 1;
        ax(y,1) = subplot(length(years),5,plot_count);
        plot(timeVect,table.entry.perYears.(sprintf('y%d',years(y))).total,'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('reservation') , end
        ylabel(sprintf('%d',years(y)))
        
        plot_count = plot_count + 1;
        ax(y,2) = subplot(length(years),5,plot_count);
        plot(timeVect,table.annulation.perYears.(sprintf('y%d',years(y))).total,'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('totalAnnulation') , end
        
        plot_count = plot_count + 1;
        ax(y,3) = subplot(length(years),5,plot_count);
        plot(timeVect,table.annulation.perYears.(sprintf('y%d',years(y))).m10,'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('m10') , end
        
        plot_count = plot_count + 1;
        ax(y,4) = subplot(length(years),5,plot_count);
        plot(timeVect,table.annulation.perYears.(sprintf('y%d',years(y))).auto,'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('auto') , end
        
        plot_count = plot_count + 1;
        ax(y,5) = subplot(length(years),5,plot_count);
        plot(timeVect,table.annulation.perYears.(sprintf('y%d',years(y))).p10,'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('p10') , end
        
    end
    
    axis(ax(:),'tight')
    
    for y = 1 : length(years)
        ylim(ax(y,1),[0 max(allMaxes.entry)])
        ylim(ax(y,2),[0 max(allMaxes.total)])
        ylim(ax(y,3),[0 max(allMaxes.m10)])
        ylim(ax(y,4),[0 max(allMaxes.auto)])
        ylim(ax(y,5),[0 max(allMaxes.p10)])
    end
    
    linkaxes(ax,'x')
    
end


% 1 year = 1 line

if 1
    
    ax = zeros(4,1);
    lgd = cell(1,1);
    
    figure('Name','perYear','NumberTitle','off')
    
    
    sp1 = 5 ;
    sp2 = 1 ;
    
    for y = 1 : length(years)
        
        timeVect = 1:length(table.annulation.perYears.(sprintf('y%d',years(y))).total);
        
        ax(1) = subplot(sp1,sp2,1);
        hold all
        plot(ax(1),timeVect,table.entry.perYears.(sprintf('y%d',years(y))).total,'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('reservation') , end
        lgd{1} = [ lgd{1} ; num2str(years(y)) ];
        
        ax(2) = subplot(sp1,sp2,2);
        hold all
        plot(ax(2),timeVect,table.annulation.perYears.(sprintf('y%d',years(y))).total,'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('totalAnnulation') , end
        
        ax(3) = subplot(sp1,sp2,3);
        hold all
        plot(ax(3),timeVect,table.annulation.perYears.(sprintf('y%d',years(y))).m10,'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('m10') , end
        
        ax(4) = subplot(sp1,sp2,4);
        hold all
        plot(ax(4),timeVect,table.annulation.perYears.(sprintf('y%d',years(y))).auto,'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('auto') , end
        
        ax(5) = subplot(sp1,sp2,5);
        hold all
        plot(ax(5),timeVect,table.annulation.perYears.(sprintf('y%d',years(y))).p10,'LineWidth',lw,'color',colors(y,:))
        if y == 1 , title('p10') , end
        
    end
    
    legend(ax(1),lgd,'Location','Best');
    
    axis(ax(:),'tight')
    
    linkaxes(ax,'x')
    
end


%% 1 line = all years

if 1
    
    ax = zeros(5,1);
    
    figure('Name','allYears','NumberTitle','off')
    
    sp1 = 5 ;
    sp2 = 1 ;
    
    timeVect = 1:size(table.annulation.allMonths.str,1);
    
    ax(1) = subplot(sp1,sp2,1);
    plot(ax(1),timeVect,table.entry.perMonth.total,'LineWidth',lw)
    title('reservation')
    
    ax(2) = subplot(sp1,sp2,2);
    plot(ax(2),timeVect,table.annulation.perMonth.total,'LineWidth',lw)
    title('totalAnnulation')
    
    ax(3) = subplot(sp1,sp2,3);
    plot(ax(3),timeVect,table.annulation.perMonth.m10,'LineWidth',lw)
    title('m10')
    
    ax(4) = subplot(sp1,sp2,4);
    plot(ax(4),timeVect,table.annulation.perMonth.auto,'LineWidth',lw)
    title('auto')
    
    ax(5) = subplot(sp1,sp2,5);
    plot(ax(5),timeVect,table.annulation.perMonth.p10,'LineWidth',lw)
    title('p10')
    
    set(ax(:),'XTick',1:12:timeVect(end))
    set(ax(:),'XTickLabel',num2str(years))
    
    axis(ax(:),'tight')
    
    linkaxes(ax,'x')
    
    legend(ax(1),{'Prisma';'Verio'},'Location','Best')
    
end

