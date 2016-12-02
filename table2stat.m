function [ s , col , hdr ] = table2stat( t , col , hdr )

md10 = 9.90;
pd10 = 10.10;

list = fieldnames(t);


%% Prepare time

counter = 0;
current_dateVect = datevec(now);
time = struct;
years = 2010:current_dateVect(1);
for yyyy = years
    for mm = 1:12
        counter = counter + 1;
        time.vect(counter,:) = [ yyyy mm 1 0 0 0 ];
    end
end
time.unix = datenum_to_unixtime( datenum(time.vect) );
time.unix_plus_one = datenum_to_unixtime(datenum([current_dateVect(1)+1 1 1 0 0 0 ]));


%% Prepare indexs

for l = 1 : length(list)
    X = list{l};
    
    index.(X).prisma = t.(X).num(:,col.(X).room_id) == 1 ;
    index.(X).verio  = t.(X).num(:,col.(X).room_id) == 19;
end
index.a.auto = strcmp(t.a.txt(:,col.a.del_by) , 'auto');
index.a.m10  = ( t.a.num(:,col.a.delay_time_day) < md10 ) & ~index.a.auto;
index.a.p10  = ( t.a.num(:,col.a.delay_time_day) > pd10 ) & ~index.a.auto;


%% Prepare cell container for indexs in the tables

names.res = {'month_idx' 'year' 'unix' 'prisma_e' 'prisma_auto' 'prisma_m10' 'prisma_p10' 'verio_e' 'verio_auto' 'verio_m10' 'verio_p10' };

nCol.res = 0;
for n = 1:length(names.res)
    nCol.res = nCol.res +1;
    col.res.( names.res {n} ) = nCol.res;
end

hdr.res = fieldnames(col.res);


%% Fill the reuslt cell

res = cell(length(time.unix),nCol.res);

s = struct;

res(:,col.res.month_idx) = num2cell(1:length(time.unix));
res(:,col.res.year) = num2cell(time.vect(:,1));
res(:,col.res.unix) = num2cell(time.unix);

s.Nm = nan(length(time.unix),nCol.res);

s.Nm(:,col.res.month_idx) = cell2mat(res(:,col.res.month_idx));
s.Nm(:,col.res.year) = cell2mat(res(:,col.res.year));
s.Nm(:,col.res.unix) = cell2mat(res(:,col.res.unix));

s.Tm = s.Nm;

for mm = 1 : length(time.unix)
    
    timeinf = time.unix(mm);
    if mm ~= length(time.unix)
        timesup = time.unix(mm+1);
    else
        timesup = time.unix_plus_one;
    end
    
    current_month_idx_e = ( t.e.num(:,col.e.start_time) >= timeinf ) & ( t.e.num(:,col.e.start_time) < timesup );
    
    res{mm,col.res.prisma_e} = find( current_month_idx_e & index.e.prisma );
    s.Nm (mm,col.res.prisma_e) = length(res{mm,col.res.prisma_e});
    s.Tm (mm,col.res.prisma_e) = sum(t.e.num( res{mm,col.res.prisma_e} , col.e.duration ) );
    
    res{mm,col.res.verio_e } = find( current_month_idx_e & index.e.verio  );
    s.Nm (mm,col.res.verio_e ) = length(res{mm,col.res.verio_e });
    s.Tm (mm,col.res.verio_e ) = sum(t.e.num( res{mm,col.res.verio_e } , col.e.duration ) );
    
    
    current_month_idx_a = ( t.a.num(:,col.a.start_time) >= timeinf ) & ( t.a.num(:,col.a.start_time) < timesup );
    
    res{mm,col.res.prisma_auto} = find( current_month_idx_a & index.a.prisma & index.a.auto );
    s.Nm (mm,col.res.prisma_auto) = length(res{mm,col.res.prisma_auto});
    s.Tm (mm,col.res.prisma_auto) = sum(t.a.num( res{mm,col.res.prisma_auto} , col.a.duration ) );
    
    res{mm,col.res.prisma_m10 } = find( current_month_idx_a & index.a.prisma & index.a.m10  );
    s.Nm (mm,col.res.prisma_m10 ) = length(res{mm,col.res.prisma_m10});
    s.Tm (mm,col.res.prisma_m10 ) = sum(t.a.num( res{mm,col.res.prisma_m10} , col.a.duration ) );
    
    res{mm,col.res.prisma_p10 } = find( current_month_idx_a & index.a.prisma & index.a.p10  );
    s.Nm (mm,col.res.prisma_p10 ) = length(res{mm,col.res.prisma_p10});
    s.Tm (mm,col.res.prisma_p10 ) = sum(t.a.num( res{mm,col.res.prisma_p10} , col.a.duration ) );
    
    res{mm,col.res.verio_auto } = find( current_month_idx_a & index.a.verio  & index.a.auto );
    s.Nm (mm,col.res.verio_auto ) = length(res{mm,col.res.verio_auto});
    s.Tm (mm,col.res.verio_auto ) = sum(t.a.num( res{mm,col.res.verio_auto} , col.a.duration ) );
    
    res{mm,col.res.verio_m10  } = find( current_month_idx_a & index.a.verio  & index.a.m10  );
    s.Nm (mm,col.res.verio_m10  ) = length(res{mm,col.res.verio_m10});
    s.Tm (mm,col.res.verio_m10  ) = sum(t.a.num( res{mm,col.res.verio_m10} , col.a.duration ) );
    
    res{mm,col.res.verio_p10  } = find( current_month_idx_a & index.a.verio  & index.a.p10  );
    s.Nm (mm,col.res.verio_p10  ) = length(res{mm,col.res.verio_p10});
    s.Tm (mm,col.res.verio_p10  ) = sum(t.a.num( res{mm,col.res.verio_p10} , col.a.duration ) );
    
end


%% Regroup per year

s.Ny = nan(length(years),nCol.res);
s.Ty = s.Ny;

count = 0;
for y = years
    count = count + 1;
    
    idx = s.Nm(:,col.res.year) == y;
    
    s.Ny(count,col.res.month_idx) = count;
    s.Ny(count,col.res.year)      = y;
    s.Ny(count,col.res.unix)      = s.Nm(find(idx,1,'first'),col.res.unix);
    
    s.Ty(count,col.res.month_idx) = s.Ny(count,col.res.month_idx);
    s.Ty(count,col.res.year)      = s.Ny(count,col.res.year);
    s.Ty(count,col.res.unix)      = s.Ny(count,col.res.unix);
    
    for c = col.res.prisma_e : col.res.verio_p10
        s.Ny(count,c) = sum( s.Nm(idx,c) );
        s.Ty(count,c) = sum( s.Tm(idx,c) );
    end
    
end


%% Rounds the values

fn = fieldnames(s);
for f = 1 : length(fn)
    
    s.(fn{f}) = round(s.(fn{f}));
    
    
end


end % function
