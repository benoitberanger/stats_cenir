%% Init

close all
clear all
clc


%% Load

load annulations_data.mat


%% Refs

ref = {...
    
'Créneau pilote'			'B';
'Créneau confirmé'			'A';
'Coupure électrique'			'C';
'Maintenance matérielle'			'D';
'Intervention CENIR'			'F';
'Présentation de projet IRM'			'H';
'Réunion d''équipe'			'P';
'Spécial'			'Q';
'Jour de congé'			'Z';
'Congrés et déplacement pro'			'Y';
'Maladie'			'X';
'Fermeture exceptionnelle'			'R';
'Formation'			'S';
'Réunion'			'T';
'Présentation de projet MEG'			'N';
'Pré-réservation'			'M';
'Cours'			'U';
'Créneau indisponible'			'E';
'Créneau disponible'			'I';
'Scan Paul Castaigne'			'G';
'Présentation de projet EEG'			'O';
'Tiwi'			'J';
'Panne'			'AA';
};

hdr = {
    'id';
    'cancel_time';
    'start_time';
    'end_time';
    'entry_type';
    'repeat_id';
    'room_id';
    'timestamp';
    'create_by';
    'del_by';
    'name';
    'type';
    'description';
    'statut_entry';
    'option_reservation';
    'facturable';
    'opid';
    'cancel_time_STR';
    'start_time_STR';
    'end_time_STR';
    'diff_cancel_start(d)'
    };

%% Fetch protocole

[C,ia,ic] = unique(txt(:,11),'stable');

perProtocol = struct;


%% Make stats

proto_name = C;

% proto_name = {...
%     'ADODEP';
%     'APPAL';
%     'IMAGEN';
%     'FIMP2';
%     'ICEBERG';
%     'IDH1';
%     'INSIGHT';
%     'PIVOINE';
%     'QUIT_COC';
%     'REV_HD';
%     'TRIHEP3';
%     'VASCOD';
%     };

for n = 1 : length(proto_name)
    
    try
        
        for p = 1 : length(C)
            if regexp(C{p},proto_name{n})
                perProtocol.(proto_name{n}).idx = p;
            end
        end
        
        % total
        perProtocol.(proto_name{n}).total.cancel_ID = find(ic == perProtocol.(proto_name{n}).idx );
        perProtocol.(proto_name{n}).total.count = length(perProtocol.(proto_name{n}).total.cancel_ID);
        perProtocol.(proto_name{n}).total.num = num(perProtocol.(proto_name{n}).total.cancel_ID,:);
        perProtocol.(proto_name{n}).total.txt = txt(perProtocol.(proto_name{n}).total.cancel_ID,:);
        perProtocol.(proto_name{n}).total.raw = raw(perProtocol.(proto_name{n}).total.cancel_ID,:);
        
        % manual & auto
        perProtocol.(proto_name{n}).total.auto.cancel_ID = zeros(0);
        perProtocol.(proto_name{n}).total.manual.cancel_ID = zeros(0);
        for c = 1 : length(perProtocol.(proto_name{n}).total.cancel_ID)
            if strcmp( raw( perProtocol.(proto_name{n}).total.cancel_ID(c) , 10 ) , 'auto' )
                perProtocol.(proto_name{n}).total.auto.cancel_ID = [perProtocol.(proto_name{n}).total.auto.cancel_ID perProtocol.(proto_name{n}).total.cancel_ID(c)];
            else
                perProtocol.(proto_name{n}).total.manual.cancel_ID = [perProtocol.(proto_name{n}).total.manual.cancel_ID perProtocol.(proto_name{n}).total.cancel_ID(c)];
            end
        end
        perProtocol.(proto_name{n}).total.auto.count = length(perProtocol.(proto_name{n}).total.auto.cancel_ID);
        perProtocol.(proto_name{n}).total.auto.num = num(perProtocol.(proto_name{n}).total.auto.cancel_ID,:);
        perProtocol.(proto_name{n}).total.auto.txt = txt(perProtocol.(proto_name{n}).total.auto.cancel_ID,:);
        perProtocol.(proto_name{n}).total.auto.raw = raw(perProtocol.(proto_name{n}).total.auto.cancel_ID,:);
        perProtocol.(proto_name{n}).total.manual.count = length(perProtocol.(proto_name{n}).total.manual.cancel_ID);
        perProtocol.(proto_name{n}).total.manual.num = num(perProtocol.(proto_name{n}).total.manual.cancel_ID,:);
        perProtocol.(proto_name{n}).total.manual.txt = txt(perProtocol.(proto_name{n}).total.manual.cancel_ID,:);
        perProtocol.(proto_name{n}).total.manual.raw = raw(perProtocol.(proto_name{n}).total.manual.cancel_ID,:);
        
        % m10 p10
        perProtocol.(proto_name{n}).total.m10 = sum(cell2mat(perProtocol.(proto_name{n}).total.raw(:,21)) < 9.85  );
        perProtocol.(proto_name{n}).total.p10 = sum(cell2mat(perProtocol.(proto_name{n}).total.raw(:,21)) > 10.15 );
        
    catch err
        
        warning(err.message)
        continue
        
    end

end

% Re-order
perProtocol = orderfields(perProtocol);

nameFields = fieldnames(perProtocol);
countFileds = length(nameFields);


%% Prepare LINE print

outputLINE = cell(0,size(raw,2));
count = 1;
outputLINE(1,:) = hdr;
for n = 1 : countFileds
    
    count = count + perProtocol.(nameFields{n}).total.count;
    
    outputLINE = [outputLINE ; perProtocol.(nameFields{n}).total.raw ];
    
end

% Take out useless rows
outputXLS = outputLINE(:,[ 10 11 18 19 21]);


%% Prepare p10 auto m10 

output10= struct;
output10.hdr = {'proto','total','m10','auto','p10'};

% Alphabetical order
output10.abcd = cell(countFileds,5);
for n = 1 : countFileds
    
    output10.abcd{n,1} = nameFields{n};
    output10.abcd{n,2} = perProtocol.(nameFields{n}).total.count;
    output10.abcd{n,3} = perProtocol.(nameFields{n}).total.m10;
    output10.abcd{n,4} = perProtocol.(nameFields{n}).total.auto.count;
    output10.abcd{n,5} = perProtocol.(nameFields{n}).total.p10;
    
end

% Total order
[~,totalOrder] = sort( cell2mat( output10.abcd(:,2) ) );
totalOrder = flipud(totalOrder);
output10.total = output10.abcd(totalOrder,:);

% m10 order
[~,m10Order] = sort( cell2mat( output10.abcd(:,3) ) );
m10Order = flipud(m10Order);
output10.m10 = output10.abcd(m10Order,:);

% auto order
[~,autoOrder] = sort( cell2mat( output10.abcd(:,4) ) );
autoOrder = flipud(autoOrder);
output10.auto = output10.abcd(autoOrder,:);

% p10 order
[~,p10Order] = sort( cell2mat( output10.abcd(:,5) ) );
p10Order = flipud(p10Order);
output10.p10 = output10.abcd(p10Order,:);


%% Split data for each month

perMonth.total = nan( size( allMonths.str , 1) , 1 );
perMonth.m10 = perMonth.total;
perMonth.auto = perMonth.total;
perMonth.p10 = perMonth.total;

for m = 1 : size( allMonths.str , 1) - 1
    
    perMonth.total(m) = length( allMonths.data.(allMonths.str(m,:)).idx );
    perMonth.m10(m) = sum(cell2mat(allMonths.data.(allMonths.str(m,:)).raw(:,21)) < 9.85  );
    
    auto_idx = strcmp(allMonths.data.(allMonths.str(m,:)).raw(:,10),'auto');
    perMonth.auto(m) = sum(auto_idx);
    
    perMonth.p10(m) = sum(cell2mat(allMonths.data.(allMonths.str(m,:)).raw(:,21)) > 10.15  );
    
end


%% Plot perMonths

% timeVect = 1:size(allMonths.str,1);
% 
% ax(1) = subplot(4,1,1);
% plot(timeVect,perMonth.total)
% 
% ax(2) = subplot(4,1,2);
% plot(timeVect,perMonth.m10)
% 
% ax(3) = subplot(4,1,3);
% plot(timeVect,perMonth.auto)
% 
% ax(4) = subplot(4,1,4);
% plot(timeVect,perMonth.p10)
% 
% % set(ax,'XTick',timeVect)
% % xticklabel = get(ax,'XTickLabel');
% % xticklabel = cellstr(xticklabel{1,:});
% % str = cellstr(allMonths.str);
% % set(ax(end),'XTickLabel', str( str2double( xticklabel ) ) )
% 
% linkaxes(ax,'x')


%% Regroup per year

[years,~,month2year] = unique(allMonths.vect(:,1));

perYears = struct;
for y = 1 : length(years)
    perYears.(sprintf('y%d',years(y))).total = perMonth.total(month2year == y);
    perYears.(sprintf('y%d',years(y))).m10 = perMonth.m10(month2year == y);
    perYears.(sprintf('y%d',years(y))).auto = perMonth.auto(month2year == y);
    perYears.(sprintf('y%d',years(y))).p10 = perMonth.p10(month2year == y);
end

% max for each category
allMaxes.total = [];
allMaxes.m10 = [];
allMaxes.auto = [];
allMaxes.p10 = [];

for y = 1 : length(years)
    
    allMaxes.total = [allMaxes.total nanmax( perYears.(sprintf('y%d',years(y))).total ) ];
    allMaxes.m10 = [allMaxes.m10 nanmax( perYears.(sprintf('y%d',years(y))).m10 ) ];
    allMaxes.auto = [allMaxes.auto nanmax( perYears.(sprintf('y%d',years(y))).auto ) ];
    allMaxes.p10 = [allMaxes.p10 nanmax( perYears.(sprintf('y%d',years(y))).p10 ) ];
    
end

%% Plot perYears

plot_count = 0;
for y = 1 : length(years)
    
    timeVect = 1:length(perYears.(sprintf('y%d',years(y))).total);
    
    plot_count = plot_count + 1;
    ax(y,1) = subplot(length(years),4,plot_count);
    plot(timeVect,perYears.(sprintf('y%d',years(y))).total)
%     ylim([0 max(allMaxes.total)])
    if y == 1 , title('total') , end
    ylabel(sprintf('%d',years(y)))
    
    plot_count = plot_count + 1;
    ax(y,2) = subplot(length(years),4,plot_count);
    plot(timeVect,perYears.(sprintf('y%d',years(y))).m10)
%     ylim([0 max(allMaxes.m10)])
    if y == 1 , title('m10') , end
    
    plot_count = plot_count + 1;
    ax(y,3) = subplot(length(years),4,plot_count);
    plot(timeVect,perYears.(sprintf('y%d',years(y))).auto)
%     ylim([0 max(allMaxes.auto)])
    if y == 1 , title('auto') , end
    
    plot_count = plot_count + 1;
    ax(y,4) = subplot(length(years),4,plot_count);
    plot(timeVect,perYears.(sprintf('y%d',years(y))).p10)
%     ylim([0 max(allMaxes.p10)])
    if y == 1 , title('p10') , end
    
end

axis(ax(:),'tight')

for y = 1 : length(years)
    
    ylim(ax(y,1),[0 max(allMaxes.total)])
    ylim(ax(y,2),[0 max(allMaxes.m10)])
    ylim(ax(y,3),[0 max(allMaxes.auto)])
    ylim(ax(y,4),[0 max(allMaxes.p10)]) 
    
end

linkaxes(ax,'x')


%% Save

try
    delete('check_annulation.xls')
catch err
    warning(err.message)
end
% xlswrite('check_annulation',outputXLS)

