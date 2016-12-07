function [ o ] = CognitiveOrClincal


%% Import, parse, prepare

[ t , col , hdr ] = prepareTables;
list = fieldnames(t);
vars = {'num' 'txt' 'raw'};


%% Import protocol list

[ t.p , col.p , hdr.p ] = prepareProtocol;
proto_list = t.p.txt(:,col.p.eid);

repList = {
    '1' 'clinique'
    '2' 'cognitif'
    '3' 'pharmaco'
    '4' 'methodo'
    '5' 'anat-TMS'
    '6' 'anat-MEG'
    'anat-TMS' 'anat_TMS'
    'anat-MEG' 'anat_MEG'
    };

for r = 1 : size(repList,1)
    t.p.raw(:,col.p.type) = regexprep( t.p.raw(:,col.p.type) , repList{r,1} , repList{r,2} );
end


%% Fetch data for each proto

current_dateVect = datevec(now);
years = 2010:current_dateVect(1);

hdr.o = {'protocol' 'total' 'annul' 'tx' 'm10' 'auto' 'p10'};

catList = {
    'clinique'
    'cognitif'
    'pharmaco'
    'methodo'
    'anat_TMS'
    'anat_MEG'
    };

for c = 1 : size(catList,1)
    C = catList{c};
    
    cat_idx = strcmp(t.p.raw(:,col.p.type),C);
    proto_list     = t.p.txt(cat_idx,col.p.eid     );
    proto_list_alt = t.p.txt(cat_idx,col.p.code_alt);
    
    for y = 1 : length(years)
        yxxxx = sprintf('y%d',years(y));
        o.(yxxxx).(C) = cell(length(proto_list),length(hdr.o));
    end
    
    for p = 1 : length(proto_list)
        
        proto_name_nm  = proto_list    {p};
        proto_name_alt = proto_list_alt{p};
        
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
            
            if scan ~= 0
                
                annul = sum( s_proto.Ty( y , [col.res.prisma_auto col.res.prisma_m10 col.res.prisma_p10 col.res.verio_auto col.res.verio_m10 col.res.verio_p10 ] ) );
                tx = 100 * annul/(scan + annul);
                tx = round(tx);
                m10 = sum( s_proto.Ty( y , [col.res.prisma_m10 col.res.verio_m10] ) );
                auto = sum( s_proto.Ty( y , [col.res.prisma_auto col.res.verio_auto] ) );
                p10 = sum( s_proto.Ty( y , [col.res.prisma_p10 col.res.verio_p10] ) );
                
                o.(yxxxx).(C){p,1} = proto_name_nm;
                o.(yxxxx).(C)(p,2:end) = num2cell([scan+annul annul tx m10 auto p10]);
                
            end
            
        end
        
    end
    
    
    % Clean & re-organize
    for y = 1 : length(years)
        yxxxx = sprintf('y%d',years(y));
        
        % Delete empty lines
        empty_idx = cellfun(@isempty,o.(yxxxx).(C)(:,1));
        o.(yxxxx).(C)(empty_idx,:)=[];
        
        % Deleta tx = nan
        nan_idx = cellfun(@isnan,o.(yxxxx).(C)(:,4));
        o.(yxxxx).(C)(nan_idx,4)=repmat({0},[sum(nan_idx) 1]);
        
        cols = size(o.(yxxxx).(C),2);
        for r = 1 : cols-1
            % Sorty by : demand=2, cancel=3, ratio=4; ...
            [~,IX] = sort(cell2mat(o.(yxxxx).(C)(:,r+1)),'descend');
            o.(yxxxx).(C)( : , [1:cols] + cols*(r-1) ) = o.(yxxxx).(C)(IX,1:cols);
        end
        
        
    end
    
    
end

o.header = { 'protocol' 'total (h)' 'annul (h)' 'tx (%)' '-10j' 'auto' '+10j' };
o.order_by = { 'total (h)' 'annul (h)' 'tx (%)' '-10j' 'auto' '+10j' };


%% Sumup

sumup = nan(length(years),size(catList,1)*2);
sumup_hdr = {'année' 'clinique N' 'clinique Tps' 'cognitif N' 'cognitif Tps' 'phamaco N' 'phamaco Tps' 'methodo N' 'methodo Tps' 'anat_TMS N' 'anat_MEG Tps' 'anat_TMS N' 'anat_MEG Tps'};

for c = 1 : size(catList,1)
    C = catList{c};
    
    for y = 1:size(s_proto.Ty,1)
        yxxxx = sprintf('y%d',years(y));
        
        sumup(y,2*c-1) = size(o.(yxxxx).(C),1);
        sumup(y,2*c) = sum( cell2mat(o.(yxxxx).(C)(:,2)) );
        
    end
    
end

o.sumup =[ sumup_hdr ; num2cell([years' sumup]) ];

disp( o.sumup )


end % function
