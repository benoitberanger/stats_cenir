%% Init

close all
clear all
clc


%% Load data

filename = 'grr_entry.csv';

[num,txt,raw] = xlsread(filename);


%% Preproc / cleanup

% non-valid ID
bad_ID_NaN = isnan(num(:,1));
num = num( ~bad_ID_NaN , : );
txt = txt( ~bad_ID_NaN , : );
raw = raw( ~bad_ID_NaN , : );

% MRI room
mri_entry = or( num(:,6) == 1 , num(:,6) == 19 );
num = num( mri_entry , : );
txt = txt( mri_entry , : );
raw = raw( mri_entry , : );

% Machine unavailable

% del_list1 = { ...
%     '_' ;
%     '-' ;
%     };
% for dl = 1 : length(del_list1)
%     machine_unavailable = strcmp( txt(:,11) , del_list1{dl} );
%     num = num( ~machine_unavailable , : );
%     txt = txt( ~machine_unavailable , : );
%     raw = raw( ~machine_unavailable , : );
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
%     machine_unavailable = regexpi( txt(:,11) , del_list2{dl} );
%     machine_unavailable = ~cellfun(@isempty,machine_unavailable);
%     num = num( ~machine_unavailable , : );
%     txt = txt( ~machine_unavailable , : );
%     raw = raw( ~machine_unavailable , : );
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
    machine_unavailable = strcmp( txt(:,12) , del_list3{dl} );
    num = num( ~machine_unavailable , : );
    txt = txt( ~machine_unavailable , : );
    raw = raw( ~machine_unavailable , : );
end

%%
% machine_unavailable = strcmp( txt(:,11) , '_' );
% num = num( ~machine_unavailable , : );
% txt = txt( ~machine_unavailable , : );
% raw = raw( ~machine_unavailable , : );
% machine_unavailable = strcmp( txt(:,11) , '-' );
% num = num( ~machine_unavailable , : );
% txt = txt( ~machine_unavailable , : );
% raw = raw( ~machine_unavailable , : );

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
    '_avec*'
    };

for dl = 1 : length(rep_list)
    new_list = regexprep( txt(:,11) , rep_list{dl} , '' );
    txt(:,11) = new_list;
    raw(:,11) = new_list;
end

% Invalid characters
new_list = regexprep( txt(:,11) , '-' , '_' );
txt(:,11) = new_list;
raw(:,11) = new_list;

