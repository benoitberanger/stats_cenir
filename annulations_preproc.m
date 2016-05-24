%% Init

close all
clear all
clc


%% Load data

filename = 'grr_annulation.csv';

[num,txt,raw] = xlsread(filename);


%% Preproc / cleanup

% non-valid ID

bad_ID_NaN = isnan(num(:,1));

num = num( ~bad_ID_NaN , : );
txt = txt( ~bad_ID_NaN , : );
raw = raw( ~bad_ID_NaN , : );

take_out_list = {
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

for to = 1 : length(take_out_list)
    new_list = regexprep( txt(:,11) , take_out_list{to} , '' );
    txt(:,11) = new_list;
    raw(:,11) = new_list;
end

% Invalid characters
new_list = regexprep( txt(:,11) , '-' , '_' );
txt(:,11) = new_list;
raw(:,11) = new_list;


%% Unix time convertion

col_count = 0;
for col = [2 3 4]
    
    col_count = col_count + 1;
    %     a = cellstr( unixtime_to_datestr( num(:,col) ) )
    txt(:,size(num,2)+col_count) = cellstr( unixtime_to_datestr( num(:,col) ) );
    raw(:,size(num,2)+col_count) = cellstr( unixtime_to_datestr( num(:,col) ) );
    
end


%% +10j ?

% Fetch
cancel_time = num(:,2);
start_time = num(:,3);
day2sec = 60*60*24;

% Compute
diff_time = (start_time - cancel_time)/day2sec;

% Fill
num(:,size(txt,2)+1) = diff_time;
raw(:,size(txt,2)+1) = num2cell(diff_time);


%% Split data for each month

% firstMonth.unix = datenum_to_unixtime( datenum(2013, 6, 1) );

allMonths = struct;

allMonths.vect = [];

counter = 0;
for yyyy = 2010:2016
    for mm = 1:12
        counter = counter + 1;
        allMonths.vect(counter,:) = [ yyyy mm 1 0 0 0 ];
    end
end
% allMonths.vect(1:5,:) = []; % data base starts in june 2013
allMonths.vect(end-(12-6):end,:) = []; % data base stops in may 2016

allMonths.str = datestr(allMonths.vect,'mmm_yyyy');
allMonths.unix = datenum_to_unixtime( datenum(allMonths.vect) );


%%

for m = 1 : length(allMonths.unix) - 1 
    
    currentMonth_idx = find( and( num(:,2) >= allMonths.unix(m) , num(:,2) < allMonths.unix(m+1) ) );
    allMonths.data.(allMonths.str(m,:)).idx = currentMonth_idx;
    allMonths.data.(allMonths.str(m,:)).num = num(currentMonth_idx,:);
    allMonths.data.(allMonths.str(m,:)).txt = txt(currentMonth_idx,:);
    allMonths.data.(allMonths.str(m,:)).raw = raw(currentMonth_idx,:);
    
end


%% Save

save('annulations_data','num','txt','raw','allMonths')
