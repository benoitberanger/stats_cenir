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

stats = struct;


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
                stats.(proto_name{n}).idx = p;
            end
        end
        
        % total
        stats.(proto_name{n}).total.cancel_ID = find(ic == stats.(proto_name{n}).idx );
        stats.(proto_name{n}).total.count = length(stats.(proto_name{n}).total.cancel_ID);
        stats.(proto_name{n}).total.num = num(stats.(proto_name{n}).total.cancel_ID,:);
        stats.(proto_name{n}).total.txt = txt(stats.(proto_name{n}).total.cancel_ID,:);
        stats.(proto_name{n}).total.raw = raw(stats.(proto_name{n}).total.cancel_ID,:);
        
        % manual & auto
        stats.(proto_name{n}).total.auto.cancel_ID = zeros(0);
        stats.(proto_name{n}).total.manual.cancel_ID = zeros(0);
        for c = 1 : length(stats.(proto_name{n}).total.cancel_ID)
            if strcmp( raw( stats.(proto_name{n}).total.cancel_ID(c) , 10 ) , 'auto' )
                stats.(proto_name{n}).total.auto.cancel_ID = [stats.(proto_name{n}).total.auto.cancel_ID stats.(proto_name{n}).total.cancel_ID(c)];
            else
                stats.(proto_name{n}).total.manual.cancel_ID = [stats.(proto_name{n}).total.manual.cancel_ID stats.(proto_name{n}).total.cancel_ID(c)];
            end
        end
        stats.(proto_name{n}).total.auto.count = length(stats.(proto_name{n}).total.auto.cancel_ID);
        stats.(proto_name{n}).total.auto.num = num(stats.(proto_name{n}).total.auto.cancel_ID,:);
        stats.(proto_name{n}).total.auto.txt = txt(stats.(proto_name{n}).total.auto.cancel_ID,:);
        stats.(proto_name{n}).total.auto.raw = raw(stats.(proto_name{n}).total.auto.cancel_ID,:);
        stats.(proto_name{n}).total.manual.count = length(stats.(proto_name{n}).total.manual.cancel_ID);
        stats.(proto_name{n}).total.manual.num = num(stats.(proto_name{n}).total.manual.cancel_ID,:);
        stats.(proto_name{n}).total.manual.txt = txt(stats.(proto_name{n}).total.manual.cancel_ID,:);
        stats.(proto_name{n}).total.manual.raw = raw(stats.(proto_name{n}).total.manual.cancel_ID,:);
        
        % m10 p10
        stats.(proto_name{n}).total.m10 = sum(cell2mat(stats.(proto_name{n}).total.raw(:,21)) < 9.85  );
        stats.(proto_name{n}).total.p10 = sum(cell2mat(stats.(proto_name{n}).total.raw(:,21)) > 10.15 );
        
    catch err
        
        warning(err.message)
        continue
        
    end

end

% Re-order
stats = orderfields(stats);

nameFields = fieldnames(stats);
countFileds = length(nameFields);


%% Prepare LINE print

outputLINE = cell(0,size(raw,2));
count = 1;
outputLINE(1,:) = hdr;
for n = 1 : countFileds
    
    count = count + stats.(nameFields{n}).total.count;
    
    outputLINE = [outputLINE ; stats.(nameFields{n}).total.raw ];
    
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
    output10.abcd{n,2} = stats.(nameFields{n}).total.count;
    output10.abcd{n,3} = stats.(nameFields{n}).total.m10;
    output10.abcd{n,4} = stats.(nameFields{n}).total.auto.count;
    output10.abcd{n,5} = stats.(nameFields{n}).total.p10;
    
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
% perMonth.m10 = perMonth.total;
% perMonth.auto = perMonth.total;
% perMonth.p10 = perMonth.total;

for m = 1 : size( allMonths.str , 1) - 1
    
    perMonth.total(m) = length( allMonths.data.(allMonths.str(m,:)).idx );
    
end

% plot(1:size(allMonths.str,1),perMonth.total)
% set(gca,'XTick',1:size(allMonths.str,1))
% set(gca,'XTickLabel',cellstr(allMonths.str))


%% Save

try
    delete('check_annulation.xls')
catch err
    warning(err.message)
end
% xlswrite('check_annulation',outputXLS)

