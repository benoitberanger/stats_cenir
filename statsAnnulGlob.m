% function statsAnnulGlob


close all
clear
clc



%% Import, parse, prepare

[ t , col , hdr ] = prepareTables;
list = fieldnames(t);
vars = {'num' 'txt' 'raw'};


%% Import protocol list

[ t.p , col.p , hdr.p ] = prepareProtocol;
proto_list = t.p.txt(:,col.p.eid);


%% Fetch data for each proto

hdr.o = {'protocol' 'total' 'annul' 'tx'};
o = cell(size(t.p.num,1),length(hdr.o));


for p = 1 : length(proto_list)
    
    proto_name_nm  = t.p.txt{p,col.p.eid     };
    proto_name_alt = t.p.txt{p,col.p.code_alt};
    
    for l = 1 : length(list)
        X = list{l};
        
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
    
    scan = sum( s_proto.Ty( end , [col.res.prisma_e col.res.verio_e ] ) );
    annul = sum( s_proto.Ty( end , [col.res.prisma_auto col.res.prisma_m10 col.res.prisma_p10 col.res.verio_auto col.res.verio_m10 col.res.verio_p10 ] ) );
    tx = 100 * annul/(scan + annul);
    tx = round(tx);
    
    o{p,1} = proto_name_nm;
    o(p,2:end) = num2cell([scan+annul annul tx]);
    
end

% Deleta tx = nan
nan_idx = cellfun(@isnan,o(:,end));
o(nan_idx,end)=repmat({''},[sum(nan_idx) 1]);

[B,IX] = sort(cell2mat(o(:,2)),'descend');


o = o(IX,:);

% end % function

