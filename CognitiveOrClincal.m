function [ o ] = CognitiveOrClincal


%% Import, parse, prepare

[ t , col , hdr ] = prepareTables;
list = fieldnames(t);
vars = {'num' 'txt' 'raw'};


%% Import protocol list

[ t.p , col.p , hdr.p ] = prepareProtocol;
% proto_list = t.p.txt(:,col.p.eid);

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
                if isnan(tx); tx = 0; end;
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
        
        %         % Deleta tx = nan
        %         nan_idx = cellfun(@isnan,o.(yxxxx).(C)(:,4));
        %         o.(yxxxx).(C)(nan_idx,4)=repmat({0},[sum(nan_idx) 1]);
        
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
sumup_hdr = {'année' 'clinique N' 'clinique Tps' 'cognitif N' 'cognitif Tps' 'phamaco N' 'phamaco Tps' 'methodo N' 'methodo Tps' 'anat_TMS N' 'anat_TMS Tps' 'anat_MEG N' 'anat_MEG Tps'};

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


%% Type synthesis

o.type_hdr = {'année' 'N' 'Total(h)' 'Annulé(h)' 'RatioAnnul(%)' 'Scanné(h)' '-10j(%)' 'auto(%)' '+10j(%)'};
o.type = struct;

for c = 1 : size(catList,1)
    C = catList{c};
    
    o.type.(C) = nan(length(years),length(o.type_hdr));
    
    for y = 1:length(years)
        yxxxx = sprintf('y%d',years(y));
        
        o.type.(C)(y,1) = years(y);
        o.type.(C)(y,2) = size( o.(yxxxx).(C) , 1 );
        sumTotal = sum( cell2mat(o.(yxxxx).(C)(:,2)) , 1 );
        if sumTotal>0
            o.type.(C)(y,3) = sumTotal;
        else
            o.type.(C)(y,3) = 0;
        end
        sumAnnul = sum( cell2mat(o.(yxxxx).(C)(:,3)) , 1 );
        if sumAnnul>0
            o.type.(C)(y,4) = sumAnnul;
        else
            o.type.(C)(y,4) = 0;
        end
        o.type.(C)(y,5) = round(100 * o.type.(C)(y,4)/o.type.(C)(y,3)); % if isnan(o.type.(C)(y,5)); o.type.(C)(y,5) = 0; end;
        o.type.(C)(y,6) = o.type.(C)(y,3) - o.type.(C)(y,4);
        sumM10 = sum( cell2mat(o.(yxxxx).(C)(:,5)) , 1 );
        if sumM10>0
            o.type.(C)(y,7) = round(100 * sumM10/o.type.(C)(y,4));
        else
            o.type.(C)(y,7) = 0;
        end
        sumauto = sum( cell2mat(o.(yxxxx).(C)(:,6)) , 1 );
        if sumauto>0
            o.type.(C)(y,8) = round(100 * sumauto/o.type.(C)(y,4));
        else
            o.type.(C)(y,8) = 0;
        end
        sumP10 = sum( cell2mat(o.(yxxxx).(C)(:,7)) , 1 );
        if sumP10>0
            o.type.(C)(y,9) = round(100 * sumP10/o.type.(C)(y,4));
        else
            o.type.(C)(y,9) = 0;
        end
        
    end
    
    disp(C)
    disp([o.type_hdr ; num2cell(o.type.(C))])
    
end


%% Type proportions

for y = 1:length(years)
    yxxxx = sprintf('y%d',years(y));
    totals.(yxxxx).N = 0;
    totals.(yxxxx).Total = 0;
    totals.(yxxxx).Annul = 0;
    %
    totals.(yxxxx).Scan = 0;
    totals.(yxxxx).m10 = 0;
    totals.(yxxxx).auto = 0;
    totals.(yxxxx).p10 = 0;
end

for c = 1 : size(catList,1)
    C = catList{c};
    
    for y = 1:length(years)
        yxxxx = sprintf('y%d',years(y));
        
        totals.(yxxxx).N = totals.(yxxxx).N + o.type.(C)(y,2);
        totals.(yxxxx).Total = totals.(yxxxx).Total + o.type.(C)(y,3);
        totals.(yxxxx).Annul = totals.(yxxxx).Annul + o.type.(C)(y,4);
        %
        totals.(yxxxx).Scan = totals.(yxxxx).Scan + o.type.(C)(y,6);
        sumM10 = sum( cell2mat(o.(yxxxx).(C)(:,5)) , 1 );
        if isempty(sumM10)
            sumM10 = 0;
        end
        sumauto = sum( cell2mat(o.(yxxxx).(C)(:,6)) , 1 );
        if isempty(sumauto)
            sumauto = 0;
        end
        sumP10 = sum( cell2mat(o.(yxxxx).(C)(:,7)) , 1 );
        if isempty(sumP10)
            sumP10 = 0;
        end
        totals.(yxxxx).m10 = totals.(yxxxx).m10 + sumM10;
        totals.(yxxxx).auto = totals.(yxxxx).auto + sumauto;
        totals.(yxxxx).p10 = totals.(yxxxx).p10 + sumP10;
        
    end
end

totals_arr = struct2array(totals);

o.prop_hdr = {'année' 'N(%)' 'Total(%)' 'Annulé(%)' 'Scanné(%)' '-10j(%)' 'auto(%)' '+10j(%)'};
o.prop = struct;

for c = 1 : size(catList,1)
    C = catList{c};
    
    for y = 1:length(years)
        yxxxx = sprintf('y%d',years(y));
        
        o.prop.(C)(y,1) = years(y);
        o.prop.(C)(y,2) = round(100 * o.type.(C)(y,2)/totals.(yxxxx).N );
        o.prop.(C)(y,3) = round(100 * o.type.(C)(y,3)/totals.(yxxxx).Total );
        o.prop.(C)(y,4) = round(100 * o.type.(C)(y,4)/totals.(yxxxx).Annul );
        o.prop.(C)(y,5) = round(100 * o.type.(C)(y,6)/totals.(yxxxx).Scan );
        sumM10 = sum( cell2mat(o.(yxxxx).(C)(:,5)) , 1 );
        if isempty(sumM10)
            sumM10 = 0;
        end
        o.prop.(C)(y,6) = round(100 * sumM10/totals.(yxxxx).m10 );
        sumauto = sum( cell2mat(o.(yxxxx).(C)(:,6)) , 1 );
        if isempty(sumauto)
            sumauto = 0;
        end
        o.prop.(C)(y,7) = round(100 * sumauto/totals.(yxxxx).auto );
        sumP10 = sum( cell2mat(o.(yxxxx).(C)(:,7)) , 1 );
        if isempty(sumP10)
            sumP10 = 0;
        end
        o.prop.(C)(y,8) = round(100 * sumP10/totals.(yxxxx).p10 );
        
    end
    
    disp(C)
    disp([o.prop_hdr ; num2cell(o.prop.(C))])
    
end


end % function
