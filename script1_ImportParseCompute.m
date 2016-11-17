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

hdr.a = fieldnames(col.a)';
if length(hdr.a) ~= size(annulation.num,2);
    error('invalid hdr.a');
end
disp(hdr.a)

% Entry *******************************************************************

col_to_delete_e = [1 4 5 9 10 12 13 14 15 16 17 18];

entry.num( : , col_to_delete_e ) = [];
entry.txt( : , col_to_delete_e ) = [];
entry.raw( : , col_to_delete_e ) = [];

nCol.e = 0;

names.e = { 'start_time' 'end_time' 'room_id' 'timestamp' 'name' 'type' };
for ne = 1:length(names.e)
    nCol.e = nCol.e +1;
    col.e.(names.e{ne}) = nCol.e;
end

hdr.e = fieldnames(col.e)';
if length(hdr.e) ~= size(entry.num,2);
    error('invalid hdr.e');
end
disp(hdr.e)


%%

