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


%% Clean invalid ID

% non-valid ID
for l = 1 : length(list)
    X = list{l};
    
    bad_ID_NaN.(X) = isnan(t.(X).num(:,1));
    t.(X).num = t.(X).num( ~bad_ID_NaN.(X) , : );
    t.(X).txt = t.(X).txt( ~bad_ID_NaN.(X) , : );
    t.(X).raw = t.(X).raw( ~bad_ID_NaN.(X) , : );
end

% MRI room (only entry)
mri_entry = or( t.e.num(:,6) == 1 , t.e.num(:,6) == 19 );
t.e.num = t.e.num( mri_entry , : );
t.e.txt = t.e.txt( mri_entry , : );
t.e.raw = t.e.raw( mri_entry , : );


%% Delete row we don't care

update_hdr = @(x) fieldnames(x);

col_to_delete.a = [1 5 6 9 13 14 15 16 17];
names.a = { 'cancel_time' 'start_time' 'end_time' 'room_id' 'timestamp'  'del_by'  'name' 'type' };

col_to_delete.e = [1 4 5 8 9 10 13 14 15 16 17 18];
names.e = { 'start_time' 'end_time' 'room_id' 'timestamp' 'name' 'type' };

for l = 1 : length(list)
    X = list{l};
    
    t.(X).num( : , col_to_delete.(X) ) = [];
    t.(X).txt( : , col_to_delete.(X) ) = [];
    t.(X).raw( : , col_to_delete.(X) ) = [];
    
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
    t.e.num = t.e.num( ~machine_unavailable , : );
    t.e.txt = t.e.txt( ~machine_unavailable , : );
    t.e.raw = t.e.raw( ~machine_unavailable , : );
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


%% Prepare month and year splitting

for l = 1: length(list)
    X = list{l};
    
    t.(X).allMonths = struct;
    
    t.(X).allMonths.vect = [];
    
    counter = 0;
    current_dateVect = datevec(now);
    for yyyy = 2010:current_dateVect(1)
        for mm = 1:12
            counter = counter + 1;
            t.(X).allMonths.vect(counter,:) = [ yyyy mm 1 0 0 0 ];
        end
    end
    
    t.(X).allMonths.vect(end-(12-(current_dateVect(2)+1)):end,:) = []; % take out the future months
    
    [years,~,month2year] = unique(t.(X).allMonths.vect(:,1));
    
    t.(X).allMonths.str = datestr(t.(X).allMonths.vect,'mmm_yyyy');
    t.(X).allMonths.unix = datenum_to_unixtime( datenum(t.(X).allMonths.vect) );
    
    
end


%% Fill months with raw data

for l = 1: length(list)
    X = list{l};
    
    for m = 1 : length(t.a.allMonths.unix) - 1
        
        currentMonth_idx = find( and( t.(X).num(:,col.(X).start_time) >= t.(X).allMonths.unix(m) , t.(X).num(:,col.(X).start_time) < t.(X).allMonths.unix(m+1) ) );
        t.(X).allMonths.data.(t.(X).allMonths.str(m,:)).idx = currentMonth_idx;
        t.(X).allMonths.data.(t.(X).allMonths.str(m,:)).num = t.(X).num(currentMonth_idx,:);
        t.(X).allMonths.data.(t.(X).allMonths.str(m,:)).txt = t.(X).txt(currentMonth_idx,:);
        t.(X).allMonths.data.(t.(X).allMonths.str(m,:)).raw = t.(X).raw(currentMonth_idx,:);
        
    end
    
end

