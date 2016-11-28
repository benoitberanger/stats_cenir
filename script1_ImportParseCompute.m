%% Init

close all
clear
clc

md10 = 9.90;
pd10 = 10.10;

t = struct;


%% Load data

% Annulation **************************************************************

filename_a = 'grr_annulation.csv';

% [t.a.num,t.a.txt,t.a.raw] = xlsread(filename);

%             3;   1265102843; 1265277600; 1265281200; 0;   0;   1;   2013-06-24 15:23:41; KEVIN.NIGAUD; KEVIN.NIGAUD; Protocole PredictPGRN; A;   1 sujet; -;   -1;  0;   NULL
pattern_a = {'%d' '%d'        '%d'        '%d'        '%d' '%d' '%d' '%s'                 '%s'          '%s'          '%s'                   '%s' '%s'     '%s' '%s' '%d' '%s'};
[t.a.num,t.a.txt,t.a.raw] = importCSV( filename_a, pattern_a );


% Entry *******************************************************************

filename_e = 'grr_entry.csv';

% [t.e.num,t.e.txt,t.e.raw] = xlsread(filename);

%             24;  1168846200;  1168849800; 2;   2;   1;    2009-03-18 13:40:24; KEVIN.NIGAUD;      ; KEVIN.NIGAUD;   Coupure de courant; C;                   ; -;   -1;      ; 0;    0
%             34;  1168851600;  1168873200; 0;   0;   1;    2009-03-18 13:40:24; ADMINISTRATEUR;    ; ADMINISTRATEUR; Installation ASL;   F;   Installation du ; -;   -1;      ; 0;    0
pattern_e = {'%d' '%d'         '%d'        '%d' '%d' '%d' '%s'                  '%s'          '%s'   '%s'            '%s'                '%s' '%s'              '%s' '%s' '%s'  '%d' '%d' };
[t.e.num,t.e.txt,t.e.raw] = importCSV( filename_e, pattern_e );


list = {'a','e'};
vars = {'num' 'txt' 'raw'};

%% Clean invalid ID

% non-valid ID
for l = 1 : length(list)
    X = list{l};
    
    bad_ID_NaN.(X) = isnan(t.(X).num(:,1));
    
    for v = 1 : length(vars)
        V = vars{v};
        
        t.(X).(V) = t.(X).(V)( ~bad_ID_NaN.(X) , : );
        
    end
    
end

% MRI room (only entry)

mri_entry = or( t.e.num(:,6) == 1 , t.e.num(:,6) == 19 );

for v = 1 : length(vars)
    V = vars{v};
    
    t.e.(V) = t.e.(V)( mri_entry , : );
    
end


%% Delete row we don't care

update_hdr = @(x) fieldnames(x);

col_to_delete.a = [1 5 6 9 13 14 15 16 17];
names.a = { 'cancel_time' 'start_time' 'end_time' 'room_id' 'timestamp'  'del_by'  'name' 'type' };

col_to_delete.e = [1 4 5 8 9 10 13 14 15 16 17 18];
names.e = { 'start_time' 'end_time' 'room_id' 'timestamp' 'name' 'type' };

for l = 1 : length(list)
    X = list{l};
    
    for v = 1 : length(vars)
        V = vars{v};
        
        t.(X).(V)( : , col_to_delete.(X) ) = [];
        
    end
    
    nCol.(X) = 0;
    
    for n = 1:length(names.(X))
        nCol.(X) = nCol.(X) +1;
        col.(X).( names.(X) {n} ) = nCol.(X);
    end
    
    hdr.(X) = update_hdr(col.(X));
    if length(hdr.(X)) ~= size(t.(X).num,2);
        error('invalid hdr.%s',X);
    end
    
    
end


%% Only count scans in entry

type_noscan = { ...
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

for tns = 1 : length(type_noscan)
    machine_unavailable = strcmp( t.e.txt(:,col.e.type) , type_noscan{tns} );
    for v = 1 : length(vars)
        V = vars{v};
        
        t.e.(V) = t.e.(V)( ~machine_unavailable , : );
        
    end
end


%% Clean the 'name' column to have just the name of the protocol

to_clean = {
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

for tc = 1 : length(to_clean)
    
    new_list_proto_a = regexprep( t.a.txt(:,col.a.name) , to_clean{tc} , '' );
    t.a.txt(:,col.a.name) = new_list_proto_a;
    t.a.raw(:,col.a.name) = new_list_proto_a;
    
    new_list_proto_e = regexprep( t.e.txt(:,col.e.name) , to_clean{tc} , '' );
    t.e.txt(:,col.e.name) = new_list_proto_e;
    t.e.raw(:,col.e.name) = new_list_proto_e;
    
end

% Invalid characters

new_list_ic_a = regexprep( t.a.txt(:,col.a.name) , '-' , '_' );
t.a.txt(:,col.a.name) = new_list_ic_a;
t.a.raw(:,col.a.name) = new_list_ic_a;

new_list_ic_e = regexprep( t.e.txt(:,col.e.name) , '-' , '_' );
t.e.txt(:,col.e.name) = new_list_ic_e;
t.e.raw(:,col.e.name) = new_list_ic_e;


%% Apply time offcet
% Don't know why, but the unix time on the table is 2h in advance.

offcet = 3600*2; % 2 hours

where_a = {'cancel_time' 'start_time' 'end_time'};

for c = 1 : length(where_a)
    timeVect =  t.a.num(:,col.a.(where_a{c}));
    t.a.num(:,col.a.(where_a{c})) = t.a.num(:,col.a.(where_a{c})) + offcet;
    t.a.raw(:,col.a.(where_a{c})) = num2cell( t.a.num(:,col.a.(where_a{c})) );
end

where_e = {'start_time' 'end_time'};

for c = 1 : length(where_e)
    timeVect =  t.a.num(:,col.e.(where_e{c}));
    t.e.num(:,col.e.(where_e{c})) = t.e.num(:,col.e.(where_e{c})) + offcet;
    t.e.raw(:,col.e.(where_e{c})) = num2cell( t.e.num(:,col.e.(where_e{c})) );
end


%% Conversion of unix time stamp into string (mostly for diagnostic)


% Annulation **************************************************************

convert_a = {'cancel' 'start' 'end'};
for c = 1 : length(convert_a)
    col.a.([convert_a{c} '_time_str']) = length(hdr.a)+1; hdr.a = update_hdr(col.a);
    new_timestap_a = cellstr( unixtime_to_datestr( t.a.num(:,col.a.([convert_a{c} '_time'])) ) );
    t.a.txt(:,col.a.([convert_a{c} '_time_str'])) = new_timestap_a;
    t.a.raw(:,col.a.([convert_a{c} '_time_str'])) = new_timestap_a;
    t.a.num(:,col.a.([convert_a{c} '_time_str'])) = nan(size(new_timestap_a));
end

% Entry *******************************************************************

convert_e = {'start' 'end'};
for c = 1 : length(convert_e)
    col.e.([convert_e{c} '_time_str']) = length(hdr.e)+1; hdr.e = update_hdr(col.e);
    new_timestap_e = cellstr( unixtime_to_datestr( t.e.num(:,col.e.([convert_e{c} '_time'])) ) );
    t.e.txt(:,col.e.([convert_e{c} '_time_str'])) = new_timestap_e;
    t.e.raw(:,col.e.([convert_e{c} '_time_str'])) = new_timestap_e;
    t.e.num(:,col.e.([convert_e{c} '_time_str'])) = nan(size(new_timestap_e));
end


%% Annulation : Delay between cancel_ and start_time ?

% Fetch
cancel_time = t.a.num(:,col.a.cancel_time);
start_time  = t.a.num(:,col.a.start_time);

day2sec = 60*60*24;

% Compute
diff_time = (start_time - cancel_time)/day2sec;

% Fill
col.a.delay_time_day = length(hdr.a)+1; hdr.a = update_hdr(col.a);
t.a.num(:,col.a.delay_time_day) = diff_time;
t.a.txt(:,col.a.delay_time_day) = cell(size(diff_time));
t.a.raw(:,col.a.delay_time_day) = num2cell(diff_time);


%% Duration of the slot in hours

% Annulation **************************************************************

start_time  = t.a.num(:,col.a.start_time);
end_time  = t.a.num(:,col.a.end_time);
diff_time = (end_time - start_time)/3600; % in hours

col.a.duration = length(hdr.a)+1; hdr.a = update_hdr(col.a);
t.a.num(:,col.a.duration) = diff_time;
t.a.txt(:,col.a.duration) = cell(size(diff_time));
t.a.raw(:,col.a.duration) = num2cell(diff_time);

% Entry *******************************************************************

start_time  = t.e.num(:,col.e.start_time);
end_time  = t.e.num(:,col.e.end_time);
diff_time = (end_time - start_time)/3600; % in hours

col.e.duration = length(hdr.e)+1; hdr.e = update_hdr(col.e);
t.e.num(:,col.e.duration) = diff_time;
t.e.txt(:,col.e.duration) = cell(size(diff_time));
t.e.raw(:,col.e.duration) = num2cell(diff_time);


%% Prepare year splitting

s = struct;

current_dateVect = datevec(now);
years = 2010:current_dateVect(1) + 1;

counter = 0;
for yyyy = years
    counter = counter + 1;
    s.vect(counter,:) = [ yyyy 1 1 0 0 0]; % year month day hh mm ss
end

s.str = datestr(s.vect,'yyyy');
s.unix = datenum_to_unixtime( datenum(s.vect) );



%% Prepare month splitting


for y = 1 : size(s.str,1) - 1
    year = ['y' s.str(y,:)];
    
    counter = 0;
    
    for m = 1:12
        counter = counter + 1;
        s.year.(year).vect(counter,:) = [ s.vect(y,1) m 1 0 0 0]; % year month day hh mm ss
    end
    
    s.year.(year).str = datestr(s.year.(year).vect,'mmm');
    s.year.(year).unix = datenum_to_unixtime( datenum(s.year.(year).vect) );
    
end


%% To make easy split, we need indxes for machines, m10, auto, p10, ...

index = struct;

machine = {'prisma' 'verio'};

for l = 1 : length(list)
    X = list{l};
    
    index.(X).prisma = t.(X).num(:,col.(X).room_id) == 1 ;
    index.(X).verio  = t.(X).num(:,col.(X).room_id) == 19;
    % already cleaned the table to only take PRISMA and VERIO into account
    
    
    s.table.(X).N = size(t.(X).num,1);
    s.table.(X).t = round(sum(t.(X).num( : , col.(X).duration )));
    
    for m = 1 : length(machine)
        M = machine{m};
        
        s.table.(X).machine.(M).N = sum(index.(X).(M));
        s.table.(X).machine.(M).t = round(sum(t.(X).num( index.(X).(M) , col.(X).duration )));
        
    end
    
end

index.a.auto = strcmp(t.a.txt(:,col.a.del_by) , 'auto');
index.a.m10  = ( t.a.num(:,col.a.delay_time_day) < md10 ) & ~index.a.auto;
index.a.p10  = ( t.a.num(:,col.a.delay_time_day) > pd10 ) & ~index.a.auto;

category = {'m10' 'auto' 'p10'};

for c = 1 : length(category)
    C = category{c} ;
    
    s.table.a.(C).N = sum(index.a.(C));
    s.table.a.(C).t = round(sum(t.a.num( index.a.(C) , col.a.duration )));
    
    for m = 1 : length(machine)
        M = machine{m};
        
        s.table.a.(C).machine.(M).N = sum(index.a.(M) & index.a.(C));
        s.table.a.(C).machine.(M).t = round(sum(t.a.num( index.a.(M) & index.a.(C) , col.a.duration )));
        
    end
end


%% Split data into years : indxes in entry and annulation


for y = 1 : size(s.str,1) - 1
    year = ['y' s.str(y,:)];
    
    for l = 1 : length(list)
        X = list{l};
        
        s.year.(year).table.(X).idx = find( and( t.(X).num(:,col.(X).start_time) >= s.unix(y) , t.(X).num(:,col.(X).start_time) < s.unix(y+1) ) );
        s.year.(year).table.(X).N = length(s.year.(year).table.(X).idx);
        s.year.(year).table.(X).t = sum( t.(X).num( s.year.(year).table.(X).idx , col.(X).duration ) );
        
        for m = 1:12
            month = s.year.(year).str(m,:);
            if m==12
                s.year.(year).month.(month).table.(X).idx = find( and( t.(X).num(:,col.(X).start_time) >= s.year.(year).unix(m) , t.(X).num(:,col.(X).start_time) < s.unix(y+1) ) );
            else
                s.year.(year).month.(month).table.(X).idx = find( and( t.(X).num(:,col.(X).start_time) >= s.year.(year).unix(m) , t.(X).num(:,col.(X).start_time) < s.year.(year).unix(m+1) ) );
            end
            s.year.(year).month.(month).table.(X).N = length(s.year.(year).month.(month).table.(X).idx);
            s.year.(year).month.(month).table.(X).t = sum( t.(X).num( s.year.(year).month.(month).table.(X).idx , col.(X).duration ) );
        end
        
    end
    
    %     s.year.(year).table.(X).a_m10.idx = s.year.(year).table.(X).idx
    
    
end


%% Count N protocoles and t time for each epoch (years and month) of each categorie from each machine





return


%%

category = {'m10' 'auto' 'p10' 'total'};
machine = {'prisma' 'verio' 'both'};
index = {'N' 't'};

perMonth = struct;

% Fill the months
for m = 1 : size( t.a.allMonths.str , 1) - 1
    month = t.a.allMonths.str(m,:);
    
    % Entry ***************************************************************
    
    
    PRISMA_idx.e = t.e.allMonths.data.(month).num(:,col.e.room_id) == 1;
    VERIO_idx .e = t.e.allMonths.data.(month).num(:,col.e.room_id) == 19;
    
    for v = 1 : length(vars)
        V = vars{v};
        perMonth.(month).e.prisma.(V) = t.e.allMonths.data.(month).(V)(PRISMA_idx.e,:);
        perMonth.(month).e.verio .(V) = t.e.allMonths.data.(month).(V)(VERIO_idx .e,:);
        perMonth.(month).e.both  .(V) = t.e.allMonths.data.(month).(V)(PRISMA_idx.e | VERIO_idx.e,:);
    end
    
    perMonth.(month).e.prisma.N = length(perMonth.(month).e.prisma.num);
    perMonth.(month).e.prisma.t = sum   (perMonth.(month).e.prisma.num(:,col.e.duration));
    
    perMonth.(month).e.verio .N = length(perMonth.(month).e.verio.num);
    perMonth.(month).e.verio .t = sum   (perMonth.(month).e.verio.num(:,col.e.duration));
    
    perMonth.(month).e.both  .N = perMonth.(month).e.prisma.N + perMonth.(month).e.verio.N;
    perMonth.(month).e.both  .t = perMonth.(month).e.prisma.t + perMonth.(month).e.verio.t;
    
    
    % Annulation **********************************************************
    
    PRISMA_idx.a = t.a.allMonths.data.(month).num(:,col.a.room_id) == 1;
    VERIO_idx .a = t.a.allMonths.data.(month).num(:,col.a.room_id) == 19;
    
    auto_idx = strcmp(t.a.allMonths.data.(month).txt(:,col.a.del_by) , 'auto');
    m10_idx  = ( t.a.allMonths.data.(month).num(:,col.a.delay_time_day) < md10 ) & ~auto_idx;
    p10_idx  = ( t.a.allMonths.data.(month).num(:,col.a.delay_time_day) > pd10 ) & ~auto_idx;
    
    for v = 1 : length(vars)
        V = vars{v};
        
        perMonth.(month).a_total.prisma.(V) = t.a.allMonths.data.(month).(V)( PRISMA_idx.a                           ,:);
        perMonth.(month).a_total.verio .(V) = t.a.allMonths.data.(month).(V)( VERIO_idx .a                           ,:);
        perMonth.(month).a_total.both  .(V) = t.a.allMonths.data.(month).(V)( PRISMA_idx.a | VERIO_idx.a             ,:);
        
        perMonth.(month).a_m10  .prisma.(V) = t.a.allMonths.data.(month).(V)( PRISMA_idx.a                & m10_idx  ,:);
        perMonth.(month).a_m10  .verio .(V) = t.a.allMonths.data.(month).(V)( VERIO_idx .a                & m10_idx  ,:);
        perMonth.(month).a_m10  .both  .(V) = t.a.allMonths.data.(month).(V)((PRISMA_idx.a | VERIO_idx.a) & m10_idx  ,:);
        
        perMonth.(month).a_auto .prisma.(V) = t.a.allMonths.data.(month).(V)( PRISMA_idx.a                & auto_idx ,:);
        perMonth.(month).a_auto .verio .(V) = t.a.allMonths.data.(month).(V)( VERIO_idx .a                & auto_idx ,:);
        perMonth.(month).a_auto .both  .(V) = t.a.allMonths.data.(month).(V)((PRISMA_idx.a | VERIO_idx.a) & auto_idx ,:);
        
        perMonth.(month).a_p10  .prisma.(V) = t.a.allMonths.data.(month).(V)( PRISMA_idx.a                & p10_idx  ,:);
        perMonth.(month).a_p10  .verio .(V) = t.a.allMonths.data.(month).(V)( VERIO_idx .a                & p10_idx  ,:);
        perMonth.(month).a_p10  .both  .(V) = t.a.allMonths.data.(month).(V)((PRISMA_idx.a | VERIO_idx.a) & p10_idx  ,:);
        
    end
    
    for c = 1 : length(category)
        categ = ['a_' category{c}];
        
        perMonth.(month).(categ).prisma.N = length(perMonth.(month).(categ).prisma.num);
        perMonth.(month).(categ).prisma.t = sum   (perMonth.(month).(categ).prisma.num(:,col.e.duration));
        
        perMonth.(month).(categ).verio .N = length(perMonth.(month).(categ).verio.num);
        perMonth.(month).(categ).verio .t = sum   (perMonth.(month).(categ).verio.num(:,col.e.duration));
        
        perMonth.(month).(categ).both  .N = perMonth.(month).(categ).prisma.N + perMonth.(month).(categ).verio.N;
        perMonth.(month).(categ).both  .t = perMonth.(month).(categ).prisma.t + perMonth.(month).(categ).verio.t;
        
    end
    
end


%%

disp('... DONE')
