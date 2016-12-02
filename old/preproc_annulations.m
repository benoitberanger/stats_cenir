%% Init

close all
clear
clc

md10 = 9.90;
pd10 = 10.10;


%% Load data

filename = 'grr_annulation.csv';

% [annulation.num,annulation.txt,annulation.raw] = xlsread(filename);

%           3;  1265102843; 1265277600; 1265281200; 0;   0;   1;   2013-06-24 15:23:41; KEVIN.NIGAUD; KEVIN.NIGAUD; Protocole PredictPGRN; A;   1 sujet; -;   -1;  0;   NULL
pattern = {'%d' '%d'        '%d'        '%d'        '%d' '%d' '%d' '%s'                 '%s'          '%s'          '%s'                   '%s' '%s'     '%s' '%s' '%d' '%s'};
[annulation.num,annulation.txt,annulation.raw] = importCSV( filename, pattern );


%% Preproc / cleanup

% non-valid ID

bad_ID_NaN = isnan(annulation.num(:,1));

annulation.num = annulation.num( ~bad_ID_NaN , : );
annulation.txt = annulation.txt( ~bad_ID_NaN , : );
annulation.raw = annulation.raw( ~bad_ID_NaN , : );

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
    '_avec.*';
    };

for to = 1 : length(take_out_list)
    new_list = regexprep( annulation.txt(:,11) , take_out_list{to} , '' );
    annulation.txt(:,11) = new_list;
    annulation.raw(:,11) = new_list;
end

% Invalid characters
new_list = regexprep( annulation.txt(:,11) , '-' , '_' );
annulation.txt(:,11) = new_list;
annulation.raw(:,11) = new_list;


%% Unix time convertion

col_count = 0;
for col = [2 3 4]
    
    col_count = col_count + 1;
    %     a = cellstr( unixtime_to_datestr( annulation.num(:,col) ) )
    annulation.txt(:,size(annulation.num,2)+col_count) = cellstr( unixtime_to_datestr( annulation.num(:,col) ) );
    annulation.raw(:,size(annulation.num,2)+col_count) = cellstr( unixtime_to_datestr( annulation.num(:,col) ) );
    
end


%% +10j ?

% Fetch
cancel_time = annulation.num(:,2);
start_time = annulation.num(:,3);
day2sec = 60*60*24;

% Compute
diff_time = (start_time - cancel_time)/day2sec;

% Fill
annulation.num(:,size(annulation.txt,2)+1) = diff_time;
annulation.raw(:,size(annulation.txt,2)+1) = num2cell(diff_time);


%% Prepare months containers

% firstMonth.unix = dateannulation.num_to_unixtime( dateannulation.num(2013, 6, 1) );

annulation.allMonths = struct;

annulation.allMonths.vect = [];

counter = 0;
current_dateVect = datevec(now);
for yyyy = 2010:current_dateVect(1)
    for mm = 1:12
        counter = counter + 1;
        annulation.allMonths.vect(counter,:) = [ yyyy mm 1 0 0 0 ];
    end
end

annulation.allMonths.vect(end-(12-(current_dateVect(2)+1)):end,:) = []; % take out the future months

[years,~,month2year] = unique(annulation.allMonths.vect(:,1));

annulation.allMonths.str = datestr(annulation.allMonths.vect,'mmm_yyyy');
annulation.allMonths.unix = datenum_to_unixtime( datenum(annulation.allMonths.vect) );


%% Fill months with raw data

for m = 1 : length(annulation.allMonths.unix) - 1
    
    currentMonth_idx = find( and( annulation.num(:,2) >= annulation.allMonths.unix(m) , annulation.num(:,2) < annulation.allMonths.unix(m+1) ) );
    annulation.allMonths.data.(annulation.allMonths.str(m,:)).idx = currentMonth_idx;
    annulation.allMonths.data.(annulation.allMonths.str(m,:)).num = annulation.num(currentMonth_idx,:);
    annulation.allMonths.data.(annulation.allMonths.str(m,:)).txt = annulation.txt(currentMonth_idx,:);
    annulation.allMonths.data.(annulation.allMonths.str(m,:)).raw = annulation.raw(currentMonth_idx,:);
    
end


%% Split data for each month

annulation.perMonth.total = nan( size( annulation.allMonths.str , 1) , 2 );
annulation.perMonth.m10 = annulation.perMonth.total;
annulation.perMonth.auto = annulation.perMonth.total;
annulation.perMonth.p10 = annulation.perMonth.total;

for m = 1 : size( annulation.allMonths.str , 1) - 1
    
    % Prisma
    
    PRISMA_idx = annulation.allMonths.data.(annulation.allMonths.str(m,:)).num(:,7) == 1;
    
    annulation.perMonth.total(m,1) = length( annulation.allMonths.data.(annulation.allMonths.str(m,:)).idx(PRISMA_idx) );
    annulation.perMonth.m10(m,1) = sum(cell2mat(annulation.allMonths.data.(annulation.allMonths.str(m,:)).raw(PRISMA_idx,21)) < md10  );
    
    auto_idx = strcmp(annulation.allMonths.data.(annulation.allMonths.str(m,:)).raw(PRISMA_idx,10),'auto');
    annulation.perMonth.auto(m,1) = sum(auto_idx);
    
    annulation.perMonth.p10(m,1) = sum(cell2mat(annulation.allMonths.data.(annulation.allMonths.str(m,:)).raw(PRISMA_idx,21)) > pd10  );
    
    % Verio
    
    VERIO_idx = annulation.allMonths.data.(annulation.allMonths.str(m,:)).num(:,7) == 19;
    
    annulation.perMonth.total(m,2) = length( annulation.allMonths.data.(annulation.allMonths.str(m,:)).idx(VERIO_idx) );
    annulation.perMonth.m10(m,2) = sum(cell2mat(annulation.allMonths.data.(annulation.allMonths.str(m,:)).raw(VERIO_idx,21)) < md10  );
    
    auto_idx = strcmp(annulation.allMonths.data.(annulation.allMonths.str(m,:)).raw(VERIO_idx,10),'auto');
    annulation.perMonth.auto(m,2) = sum(auto_idx);
    
    annulation.perMonth.p10(m,2) = sum(cell2mat(annulation.allMonths.data.(annulation.allMonths.str(m,:)).raw(VERIO_idx,21)) > pd10  );
    
end


%% Split data for each year

annulation.perYears = struct;
for y = 1 : length(years)
    annulation.perYears.(sprintf('y%d',years(y))).total = annulation.perMonth.total(month2year == y,:);
    annulation.perYears.(sprintf('y%d',years(y))).m10 = annulation.perMonth.m10(month2year == y,:);
    annulation.perYears.(sprintf('y%d',years(y))).auto = annulation.perMonth.auto(month2year == y,:);
    annulation.perYears.(sprintf('y%d',years(y))).p10 = annulation.perMonth.p10(month2year == y,:);
end


%% Fetch protocole

[protoName,~,protoName2annulation] = unique_stable(annulation.txt(:,11));

annulation.perProtocol = struct;


%% Split data for protocol


for n = 1 : length(protoName)
    
    try
        
        for p = 1 : length(protoName)
            if regexp(protoName{p},protoName{n})
                annulation.perProtocol.(protoName{n}).idx = p;
            end
        end
        
        % total
        annulation.perProtocol.(protoName{n}).total.cancel_ID = find(protoName2annulation == annulation.perProtocol.(protoName{n}).idx );
        annulation.perProtocol.(protoName{n}).total.count = length(annulation.perProtocol.(protoName{n}).total.cancel_ID);
        annulation.perProtocol.(protoName{n}).total.num = annulation.num(annulation.perProtocol.(protoName{n}).total.cancel_ID,:);
        annulation.perProtocol.(protoName{n}).total.txt = annulation.txt(annulation.perProtocol.(protoName{n}).total.cancel_ID,:);
        annulation.perProtocol.(protoName{n}).total.raw = annulation.raw(annulation.perProtocol.(protoName{n}).total.cancel_ID,:);
        
        % manual & auto
        annulation.perProtocol.(protoName{n}).total.auto.cancel_ID = zeros(0);
        annulation.perProtocol.(protoName{n}).total.manual.cancel_ID = zeros(0);
        for c = 1 : length(annulation.perProtocol.(protoName{n}).total.cancel_ID)
            if strcmp( annulation.raw( annulation.perProtocol.(protoName{n}).total.cancel_ID(c) , 10 ) , 'auto' )
                annulation.perProtocol.(protoName{n}).total.auto.cancel_ID = [annulation.perProtocol.(protoName{n}).total.auto.cancel_ID annulation.perProtocol.(protoName{n}).total.cancel_ID(c)];
            else
                annulation.perProtocol.(protoName{n}).total.manual.cancel_ID = [annulation.perProtocol.(protoName{n}).total.manual.cancel_ID annulation.perProtocol.(protoName{n}).total.cancel_ID(c)];
            end
        end
        annulation.perProtocol.(protoName{n}).total.auto.count = length(annulation.perProtocol.(protoName{n}).total.auto.cancel_ID);
        annulation.perProtocol.(protoName{n}).total.auto.num = annulation.num(annulation.perProtocol.(protoName{n}).total.auto.cancel_ID,:);
        annulation.perProtocol.(protoName{n}).total.auto.txt = annulation.txt(annulation.perProtocol.(protoName{n}).total.auto.cancel_ID,:);
        annulation.perProtocol.(protoName{n}).total.auto.raw = annulation.raw(annulation.perProtocol.(protoName{n}).total.auto.cancel_ID,:);
        annulation.perProtocol.(protoName{n}).total.manual.count = length(annulation.perProtocol.(protoName{n}).total.manual.cancel_ID);
        annulation.perProtocol.(protoName{n}).total.manual.num = annulation.num(annulation.perProtocol.(protoName{n}).total.manual.cancel_ID,:);
        annulation.perProtocol.(protoName{n}).total.manual.txt = annulation.txt(annulation.perProtocol.(protoName{n}).total.manual.cancel_ID,:);
        annulation.perProtocol.(protoName{n}).total.manual.raw = annulation.raw(annulation.perProtocol.(protoName{n}).total.manual.cancel_ID,:);
        
        % m10 p10
        annulation.perProtocol.(protoName{n}).total.m10 = sum(cell2mat(annulation.perProtocol.(protoName{n}).total.raw(:,21)) < md10  );
        annulation.perProtocol.(protoName{n}).total.p10 = sum(cell2mat(annulation.perProtocol.(protoName{n}).total.raw(:,21)) > pd10 );
        
    catch err
        
        warning(err.message)
        continue
        
    end
    
end

% Re-order
annulation.perProtocol = orderfields(annulation.perProtocol);

nameFields = fieldnames(annulation.perProtocol);
countFileds = length(nameFields);


%% Prepare annulation.ranking p10 auto m10

annulation.ranking = struct;
annulation.ranking.hdr = {'proto','total','m10','auto','p10'};

% Alphabetical order
annulation.ranking.abcd = cell(countFileds,5);
for n = 1 : countFileds
    
    annulation.ranking.abcd{n,1} = nameFields{n};
    annulation.ranking.abcd{n,2} = annulation.perProtocol.(nameFields{n}).total.count;
    annulation.ranking.abcd{n,3} = annulation.perProtocol.(nameFields{n}).total.m10;
    annulation.ranking.abcd{n,4} = annulation.perProtocol.(nameFields{n}).total.auto.count;
    annulation.ranking.abcd{n,5} = annulation.perProtocol.(nameFields{n}).total.p10;
    
end

% Total order
[~,totalOrder] = sort( cell2mat( annulation.ranking.abcd(:,2) ) );
totalOrder = flipud(totalOrder);
annulation.ranking.total = annulation.ranking.abcd(totalOrder,:);

% m10 order
[~,m10Order] = sort( cell2mat( annulation.ranking.abcd(:,3) ) );
m10Order = flipud(m10Order);
annulation.ranking.m10 = annulation.ranking.abcd(m10Order,:);

% auto order
[~,autoOrder] = sort( cell2mat( annulation.ranking.abcd(:,4) ) );
autoOrder = flipud(autoOrder);
annulation.ranking.auto = annulation.ranking.abcd(autoOrder,:);

% p10 order
[~,p10Order] = sort( cell2mat( annulation.ranking.abcd(:,5) ) );
p10Order = flipud(p10Order);
annulation.ranking.p10 = annulation.ranking.abcd(p10Order,:);


%% Split data for each protocol using month

for n = 1 : countFileds
    
    annulation.perProtocol.(nameFields{n}).vect = annulation.allMonths.vect(:,1:2);
    
    for m = 1 : length(annulation.allMonths.unix) - 1
        
        protoInMonth = find( strcmp(annulation.allMonths.data.(annulation.allMonths.str(m,:)).txt(:,11),nameFields{n}) );
        
        annulation.perProtocol.(nameFields{n}).vect(m,3) = length( protoInMonth );
        annulation.perProtocol.(nameFields{n}).vect(m,4) = sum( annulation.allMonths.data.(annulation.allMonths.str(m,:)).num(protoInMonth,21) < md10  );
        annulation.perProtocol.(nameFields{n}).vect(m,5) = sum( strcmp( annulation.allMonths.data.(annulation.allMonths.str(m,:)).raw(protoInMonth,10) , 'auto' ) );
        annulation.perProtocol.(nameFields{n}).vect(m,6) = sum( annulation.allMonths.data.(annulation.allMonths.str(m,:)).num(protoInMonth,21) > pd10  );
        
        
    end
    
end



%% Save

save('data_annulation','annulation','md10','pd10','years','month2year')
