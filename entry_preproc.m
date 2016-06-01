%% Init

close all
clear all
clc


%% Load data

filename = 'grr_entry.csv';

[entry.num,entry.txt,entry.raw] = xlsread(filename);


%% Preproc / cleanup

% non-valid ID
bad_ID_NaN = isnan(entry.num(:,1));
entry.num = entry.num( ~bad_ID_NaN , : );
entry.txt = entry.txt( ~bad_ID_NaN , : );
entry.raw = entry.raw( ~bad_ID_NaN , : );

% MRI room
mri_entry = or( entry.num(:,6) == 1 , entry.num(:,6) == 19 );
entry.num = entry.num( mri_entry , : );
entry.txt = entry.txt( mri_entry , : );
entry.raw = entry.raw( mri_entry , : );

% Machine unavailable

% del_list1 = { ...
%     '_' ;
%     '-' ;
%     };
% for dl = 1 : length(del_list1)
%     machine_unavailable = strcmp( entry.txt(:,11) , del_list1{dl} );
%     entry.num = entry.num( ~machine_unavailable , : );
%     entry.txt = entry.txt( ~machine_unavailable , : );
%     entry.raw = entry.raw( ~machine_unavailable , : );
% end

% del_list2 = { ...
%     'Intervention' ;
%     'Formation' ;
%     'Installation';
%     'Maintenance';
%     'Modifications';
%     'Ménage';
%     'Réunion';
%     'Test';
%     'Panne';
%     'Visite';
%     'Coupure';
%     'Menage';
%     'Coupure';
%     'Remplissage';
%     'Férié';
%     };
% for dl = 1 : length(del_list2)
%     machine_unavailable = regexpi( entry.txt(:,11) , del_list2{dl} );
%     machine_unavailable = ~cellfun(@isempty,machine_unavailable);
%     entry.num = entry.num( ~machine_unavailable , : );
%     entry.txt = entry.txt( ~machine_unavailable , : );
%     entry.raw = entry.raw( ~machine_unavailable , : );
% end

del_list3 = { ...
    'C' ;
    'D' ;
    'F' ;
    'D' ;
    'F' ;
    'H' ;
    'R' ;
    'E' ;
    'AA' ;
    };
for dl = 1 : length(del_list3)
    machine_unavailable = strcmp( entry.txt(:,12) , del_list3{dl} );
    entry.num = entry.num( ~machine_unavailable , : );
    entry.txt = entry.txt( ~machine_unavailable , : );
    entry.raw = entry.raw( ~machine_unavailable , : );
end


% machine_unavailable = strcmp( entry.txt(:,11) , '_' );
% entry.num = entry.num( ~machine_unavailable , : );
% entry.txt = entry.txt( ~machine_unavailable , : );
% entry.raw = entry.raw( ~machine_unavailable , : );
% machine_unavailable = strcmp( entry.txt(:,11) , '-' );
% entry.num = entry.num( ~machine_unavailable , : );
% entry.txt = entry.txt( ~machine_unavailable , : );
% entry.raw = entry.raw( ~machine_unavailable , : );

rep_list = {
    'Protocole ';
    'Pilote ';
    ' ';
    'pilote';
    'protocole';
    'prototocle';
    'protocle';
    'Protocle';
    'Proctole';
    'Proctocole';
    'Prototocle';
    '(.*';
    '_avec.*';
    };

for dl = 1 : length(rep_list)
    new_list = regexprep( entry.txt(:,11) , rep_list{dl} , '' );
    entry.txt(:,11) = new_list;
    entry.raw(:,11) = new_list;
end

% Invalid characters
new_list = regexprep( entry.txt(:,11) , '-' , '_' );
entry.txt(:,11) = new_list;
entry.raw(:,11) = new_list;


%% Unix time convertion

col_count = 0;
for col = [2 3]
    
    col_count = col_count + 1;
    %     a = cellstr( unixtime_to_datestr( entry.num(:,col) ) )
    entry.txt(:,size(entry.num,2)+col_count) = cellstr( unixtime_to_datestr( entry.num(:,col) ) );
    entry.raw(:,size(entry.num,2)+col_count) = cellstr( unixtime_to_datestr( entry.num(:,col) ) );
    
end


%% Prepare months containers

% firstMonth.unix = dateentry.num_to_unixtime( dateentry.num(2013, 6, 1) );

entry.allMonths = struct;

entry.allMonths.vect = [];

counter = 0;
for yyyy = 2010:2016
    for mm = 1:12
        counter = counter + 1;
        entry.allMonths.vect(counter,:) = [ yyyy mm 1 0 0 0 ];
    end
end
% entry.allMonths.vect(1:5,:) = []; % data base starts in june 2013
entry.allMonths.vect(end-(12-7):end,:) = []; % data base stops in june 2016

[years,~,month2year] = unique(entry.allMonths.vect(:,1));

entry.allMonths.str = datestr(entry.allMonths.vect,'mmm_yyyy');
entry.allMonths.unix = datenum_to_unixtime( datenum(entry.allMonths.vect) );


%% Fill months with raw data

for m = 1 : length(entry.allMonths.unix) - 1
    
    currentMonth_idx = find( and( entry.num(:,2) >= entry.allMonths.unix(m) , entry.num(:,2) < entry.allMonths.unix(m+1) ) );
    entry.allMonths.data.(entry.allMonths.str(m,:)).idx = currentMonth_idx;
    entry.allMonths.data.(entry.allMonths.str(m,:)).num = entry.num(currentMonth_idx,:);
    entry.allMonths.data.(entry.allMonths.str(m,:)).txt = entry.txt(currentMonth_idx,:);
    entry.allMonths.data.(entry.allMonths.str(m,:)).raw = entry.raw(currentMonth_idx,:);
    
end


%% Split data for each month

entry.perMonth.total = nan( size( entry.allMonths.str , 1) , 2 );

for m = 1 : size( entry.allMonths.str , 1) - 1
    
    PRISMA_idx = entry.allMonths.data.(entry.allMonths.str(m,:)).num(:,6) == 1;
    entry.perMonth.total(m,1) = length( entry.allMonths.data.(entry.allMonths.str(m,:)).idx(PRISMA_idx) );
    
    VERIO_idx = entry.allMonths.data.(entry.allMonths.str(m,:)).num(:,6) == 19;
    entry.perMonth.total(m,2) = length( entry.allMonths.data.(entry.allMonths.str(m,:)).idx(VERIO_idx) );
    
end


%% Split data for each year

entry.perYears = struct;
for y = 1 : length(years)
    entry.perYears.(sprintf('y%d',years(y))).total = sum(entry.perMonth.total(month2year == y,:),2);
end


%% Fetch protocole

[protoName,~,protoName2entry] = unique_stable(entry.txt(:,11));

entry.perProtocol = struct;


%% Split data for protocol


for n = 1 : length(protoName)
    
    try
        
        for p = 1 : length(protoName)
            if regexp(protoName{p},protoName{n})
                entry.perProtocol.(protoName{n}).idx = p;
            end
        end
        
        % total
        entry.perProtocol.(protoName{n}).total.cancel_ID = find(protoName2entry == entry.perProtocol.(protoName{n}).idx );
        entry.perProtocol.(protoName{n}).total.count = length(entry.perProtocol.(protoName{n}).total.cancel_ID);
        entry.perProtocol.(protoName{n}).total.num = entry.num(entry.perProtocol.(protoName{n}).total.cancel_ID,:);
        entry.perProtocol.(protoName{n}).total.txt = entry.txt(entry.perProtocol.(protoName{n}).total.cancel_ID,:);
        entry.perProtocol.(protoName{n}).total.raw = entry.raw(entry.perProtocol.(protoName{n}).total.cancel_ID,:);
        
    catch err
        
        warning(err.message)
        continue
        
    end
    
end

% Re-order
entry.perProtocol = orderfields(entry.perProtocol);

nameFields = fieldnames(entry.perProtocol);
countFileds = length(nameFields);


%% Prepare entry.ranking p10 auto m10

entry.ranking = struct;
entry.ranking.hdr = {'proto','total'};

% Alphabetical order
entry.ranking.abcd = cell(countFileds,2);
for n = 1 : countFileds
    
    entry.ranking.abcd{n,1} = nameFields{n};
    entry.ranking.abcd{n,2} = entry.perProtocol.(nameFields{n}).total.count;
    
end

% Total order
[~,totalOrder] = sort( cell2mat( entry.ranking.abcd(:,2) ) );
totalOrder = flipud(totalOrder);
entry.ranking.total = entry.ranking.abcd(totalOrder,:);


%% Split data for each protocol using month

for n = 1 : countFileds
    
    entry.perProtocol.(nameFields{n}).vect = entry.allMonths.vect(:,1:2);
    
    for m = 1 : length(entry.allMonths.unix) - 1
        
        protoInMonth = find( strcmp(entry.allMonths.data.(entry.allMonths.str(m,:)).txt(:,11),nameFields{n}) );
        
        entry.perProtocol.(nameFields{n}).vect(m,3) = length( protoInMonth );

    end
    
end


%% Save

save('entry_data','entry','years','month2year')

