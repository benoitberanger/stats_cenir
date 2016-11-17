%% Init

close all
clear
clc

md10 = 9.90;
pd10 = 10.10;


%% Load data

% Annulation **************************************************************

filename_a = 'grr_annulation.csv';

% [annulation.num,annulation.txt,annulation.raw] = xlsread(filename);

%           3;  1265102843; 1265277600; 1265281200; 0;   0;   1;   2013-06-24 15:23:41; KEVIN.NIGAUD; KEVIN.NIGAUD; Protocole PredictPGRN; A;   1 sujet; -;   -1;  0;   NULL
pattern_a = {'%d' '%d'        '%d'        '%d'        '%d' '%d' '%d' '%s'                 '%s'          '%s'          '%s'                   '%s' '%s'     '%s' '%s' '%d' '%s'};
[annulation.num,annulation.txt,annulation.raw] = importCSV( filename_a, pattern_a );


% Entry *******************************************************************

filename_e = 'grr_entry.csv';

% [entry.num,entry.txt,entry.raw] = xlsread(filename);

%          24;  1168846200;  1168849800; 2;   2;   1;    2009-03-18 13:40:24; KEVIN.NIGAUD;      ; KEVIN.NIGAUD;   Coupure de courant; C;                   ; -;   -1;      ; 0;    0
%          34;  1168851600;  1168873200; 0;   0;   1;    2009-03-18 13:40:24; ADMINISTRATEUR;    ; ADMINISTRATEUR; Installation ASL;   F;   Installation du ; -;   -1;      ; 0;    0
pattern_e = {'%d' '%d'         '%d'        '%d' '%d' '%d' '%s'                  '%s'          '%s'   '%s'            '%s'                '%s' '%s'              '%s' '%s' '%s'  '%d' '%d' };
[entry.num,entry.txt,entry.raw] = importCSV( filename_e, pattern_e );


%% Clean invalid ID

% Annulation **************************************************************

% non-valid ID
bad_ID_NaN_a = isnan(annulation.num(:,1));
annulation.num = annulation.num( ~bad_ID_NaN_a , : );
annulation.txt = annulation.txt( ~bad_ID_NaN_a , : );
annulation.raw = annulation.raw( ~bad_ID_NaN_a , : );

% Entry *******************************************************************

% non-valid ID
bad_ID_NaN_e = isnan(entry.num(:,1));
entry.num = entry.num( ~bad_ID_NaN_e , : );
entry.txt = entry.txt( ~bad_ID_NaN_e , : );
entry.raw = entry.raw( ~bad_ID_NaN_e , : );

% MRI room (only entry)
mri_entry = or( entry.num(:,6) == 1 , entry.num(:,6) == 19 );
entry.num = entry.num( mri_entry , : );
entry.txt = entry.txt( mri_entry , : );
entry.raw = entry.raw( mri_entry , : );


%% Delete row we don't care

update_hdr = @(x) fieldnames(x);

% Annulation **************************************************************

col_to_delete_a = [1 5 6 9 13 14 15 16 17];
annulation.num( : , col_to_delete_a ) = [];
annulation.txt( : , col_to_delete_a ) = [];
annulation.raw( : , col_to_delete_a ) = [];

nCol.a = 0;
names.a = { 'cancel_time' 'start_time' 'end_time' 'room_id' 'timestamp'  'del_by'  'name' 'type' };
for na = 1:length(names.a)
    nCol.a = nCol.a +1;
    col.a.(names.a{na}) = nCol.a;
end

% col.a.cancel_time = 2;
% col.a.start_time  = 3;
% col.a.end_time    = 4;
% col.a.room_id     = 7;
% col.a.timestamp     = 7;
% col.a.del_by     = 7;
% col.a.name     = 7;
% col.a.name     = 7;


hdr.a = update_hdr(col.a);
if length(hdr.a) ~= size(annulation.num,2);
    error('invalid hdr.a');
end


% Entry *******************************************************************

col_to_delete_e = [1 4 5 8 9 10 13 14 15 16 17 18];

entry.num( : , col_to_delete_e ) = [];
entry.txt( : , col_to_delete_e ) = [];
entry.raw( : , col_to_delete_e ) = [];

nCol.e = 0;

names.e = { 'start_time' 'end_time' 'room_id' 'timestamp' 'name' 'type' };
for ne = 1:length(names.e)
    nCol.e = nCol.e +1;
    col.e.(names.e{ne}) = nCol.e;
end

hdr.e = update_hdr(col.e);
if length(hdr.e) ~= size(entry.num,2);
    error('invalid hdr.e');
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
    machine_unavailable = strcmp( entry.txt(:,col.e.type) , type_noscan{tns} );
    entry.num = entry.num( ~machine_unavailable , : );
    entry.txt = entry.txt( ~machine_unavailable , : );
    entry.raw = entry.raw( ~machine_unavailable , : );
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
    
    new_list_proto_a = regexprep( annulation.txt(:,col.a.name) , to_clean{tc} , '' );
    annulation.txt(:,col.a.name) = new_list_proto_a;
    annulation.raw(:,col.a.name) = new_list_proto_a;
    
    new_list_proto_e = regexprep( entry.txt(:,col.e.name) , to_clean{tc} , '' );
    entry.txt(:,col.e.name) = new_list_proto_e;
    entry.raw(:,col.e.name) = new_list_proto_e;
    
end

% Invalid characters

new_list_ic_a = regexprep( annulation.txt(:,col.a.name) , '-' , '_' );
annulation.txt(:,col.a.name) = new_list_ic_a;
annulation.raw(:,col.a.name) = new_list_ic_a;

new_list_ic_e = regexprep( entry.txt(:,col.e.name) , '-' , '_' );
entry.txt(:,col.e.name) = new_list_ic_e;
entry.raw(:,col.e.name) = new_list_ic_e;


%% Conversion of unix time stamp into string (mostly for diagnostic)

% Annulation **************************************************************

convert_a = {'cancel' 'start' 'end'};

for c = 1 : length(convert_a)
    col.a.([convert_a{c} '_time_str']) = length(hdr.a)+1; hdr.a = update_hdr(col.a);
    new_timestap_a = cellstr( unixtime_to_datestr( annulation.num(:,col.a.([convert_a{c} '_time'])) ) );
    annulation.txt(:,col.a.([convert_a{c} '_time_str'])) = new_timestap_a;
    annulation.raw(:,col.a.([convert_a{c} '_time_str'])) = new_timestap_a;
end


% Entry *******************************************************************

convert_e = {'start' 'end'};

for c = 1 : length(convert_e)
    col.e.([convert_e{c} '_time_str']) = length(hdr.e)+1; hdr.e = update_hdr(col.e);
    new_timestap_e = cellstr( unixtime_to_datestr( entry.num(:,col.e.([convert_e{c} '_time'])) ) );
    entry.txt(:,col.e.([convert_e{c} '_time_str'])) = new_timestap_e;
    entry.raw(:,col.e.([convert_e{c} '_time_str'])) = new_timestap_e;
end


%% 














