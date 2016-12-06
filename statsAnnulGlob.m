function [ o ] = statsAnnulGlob


%% Import, parse, prepare

[ t , col , hdr ] = prepareTables;
list = fieldnames(t);
vars = {'num' 'txt' 'raw'};


%% Import protocol list

[ t.p , col.p , hdr.p ] = prepareProtocol;
proto_list = t.p.txt(:,col.p.eid);


%% Fetch data for each proto

current_dateVect = datevec(now);
years = 2010:current_dateVect(1);

hdr.o = {'protocol' 'total' 'annul' 'tx' 'm10' 'auto' 'p10'};

for y = 1 : length(years)
    yxxxx = sprintf('y%d',years(y));
    o.(yxxxx) = cell(size(t.p.num,1),length(hdr.o));
end

for p = 1 : length(proto_list)
    
    proto_name_nm  = t.p.txt{p,col.p.eid     };
    proto_name_alt = t.p.txt{p,col.p.code_alt};
    
    for l = 1 : length(list)
        X = list{l};
        
        % Where is the current protocole ?
        idx_nm = strcmpi( t.(X).txt(:,col.(X).name) ,proto_name_nm);
        idx_alt = strcmpi( t.(X).txt(:,col.(X).name) ,proto_name_alt);
        
        % Here is the indx of the current protocol
        idx.(X) = idx_nm | idx_alt;
        
        % We only compute stats over the indexes of the current protocol
        for v = 1 : length(vars)
            V = vars{v};
            
            t_proto.(X).(V) = t.(X).(V)(idx.(X),:);
            
        end
        
    end
    
    % Stats process
    [ s_proto , col , hdr ] = table2stat( t_proto , col , hdr );
    
    for y = 1:size(s_proto.Ty,1)
        yxxxx = sprintf('y%d',years(y));
        
        % Stats like in the php
        scan = sum( s_proto.Ty( y , [col.res.prisma_e col.res.verio_e ] ) );
        annul = sum( s_proto.Ty( y , [col.res.prisma_auto col.res.prisma_m10 col.res.prisma_p10 col.res.verio_auto col.res.verio_m10 col.res.verio_p10 ] ) );
        tx = 100 * annul/(scan + annul);
        tx = round(tx);
        m10 = sum( s_proto.Ty( y , [col.res.prisma_m10 col.res.verio_m10] ) );
        auto = sum( s_proto.Ty( y , [col.res.prisma_auto col.res.verio_auto] ) );
        p10 = sum( s_proto.Ty( y , [col.res.prisma_p10 col.res.verio_p10] ) );
        
        o.(yxxxx){p,1} = proto_name_nm;
        o.(yxxxx)(p,2:end) = num2cell([scan+annul annul tx m10 auto p10]);
        
    end
    
end


%% Clean & re-organize

for y = 1 : length(years)
    yxxxx = sprintf('y%d',years(y));
    
    % Deleta tx = nan
    nan_idx = cellfun(@isnan,o.(yxxxx)(:,4));
    o.(yxxxx)(nan_idx,4)=repmat({0},[sum(nan_idx) 1]);
    
    cols = size(o.(yxxxx),2);
    for r = 1 : cols-1
        % Sorty by : demand=2, cancel=3, ratio=4; ...
        [~,IX] = sort(cell2mat(o.(yxxxx)(:,r+1)),'descend');
        o.(yxxxx)( : , [1:cols] + cols*(r-1) ) = o.(yxxxx)(IX,1:cols);
    end
    
    
end

o.header = {'protocol' 'total (h)' 'annul (h)' 'tx (%)'};
o.order_by = { 'total (h)' , 'annul (h)' , 'tx (%)'};


end % function
