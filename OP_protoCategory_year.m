% function [ o ] = OP_protoCategory_year

clear
clc

%% Import OP list

op = prepareOP;

% Only keep the payed ones

fc = strcmp(op(:,4),'5');
op = op(fc,:);

%%

op_list_proto = op(:,3);
res = regexp(op_list_proto,'\w{2}_CENIR_IH_([a-zA-Z0-9-_]+)_\w\d{2}_(\d{4})','tokens');
cant_find_proto_name = cellfun(@isempty,res);

unknown_op = op_list_proto(cant_find_proto_name)

op(cant_find_proto_name,:) = [];
res(cant_find_proto_name) = [];

N = length(res);

h = {'proto' 'year' 'amount'};
proto = cell(N,4);

for i = 1 : N
    
    proto{i,1} = res{i}{1}{1};
    proto{i,2} = str2double(res{i}{1}{2});
    proto{i,3} = str2double(op{i,11});
    
end % i


%% Import protocol list

[ t.p , col.p , hdr.p ] = prepareProtocol;
% proto_list = t.p.txt(:,col.p.eid);

repList = {
    '1'        'clinique'
    '2'        'cognitif'
    '3'        'pharmaco'
    '4'        'methodo'
    '5'        'anat-TMS'
    '6'        'anat-MEG'
    'anat-TMS' 'anat_TMS'
    'anat-MEG' 'anat_MEG'
    };

for r = 1 : size(repList,1)
    t.p.raw(:,col.p.type) = regexprep( t.p.raw(:,col.p.type) , repList{r,1} , repList{r,2} );
end


%% Fetch protocol category

for i = 1 : N
    
    res = regexp( t.p.raw(:,col.p.eid) , proto{i,1} );
    where = find(~cellfun(@isempty,res));
    
    if ~isempty(where)
        type = t.p.raw{where(1),col.p.type};
        if ~isempty(type)
            proto{i,4} = type;
        end
    end
    
end % i

% Clean proto wihtout type
proto( cellfun(@isempty,proto(:,4)) , :) = [];


%% Split by year

current_dateVect = datevec(now);
years = 2010:current_dateVect(1);

out = nan(length(years),4);
for y = 1 : length(years)
        yxxxx = sprintf('y%d',years(y));
        
        year_idx = cell2mat(proto(:,2)) == years(y);
        
        clinique_idx = strcmp(proto(:,4),'clinique');
        cognitif_idx = strcmp(proto(:,4),'cognitif');
        pharmaco_idx = strcmp(proto(:,4),'pharmaco');
        methodo_idx  = strcmp(proto(:,4),'methodo');
        anatTMS_idx  = strcmp(proto(:,4),'anat_TMS');
        anatMEG_idx  = strcmp(proto(:,4),'anat_MEG');
        
        out(y,1) = sum(year_idx & clinique_idx);
        out(y,2) = round(sum(cell2mat(proto( year_idx & clinique_idx , 3 ))));
        
        out(y,3) = sum(year_idx & cognitif_idx);
        out(y,4) = round(sum(cell2mat(proto( year_idx & cognitif_idx , 3 ))));
        
        out(y,5) = sum(year_idx & pharmaco_idx);
        out(y,6) = round(sum(cell2mat(proto( year_idx & pharmaco_idx , 3 ))));
        
        out(y,7) = sum(year_idx & methodo_idx);
        out(y,8) = round(sum(cell2mat(proto( year_idx & methodo_idx , 3 ))));
        
        out(y,9) = sum(year_idx & anatTMS_idx);
        out(y,10) = round(sum(cell2mat(proto( year_idx & anatTMS_idx , 3 ))));
        
        out(y,11) = sum(year_idx & anatMEG_idx);
        out(y,12) = round(sum(cell2mat(proto( year_idx & anatMEG_idx , 3 ))));
        
        out(y,13) = sum( out( y , 1:2:11 ) );
        out(y,14) = sum( out( y , 2:2:12 ) );
        
end % y

out

% end % function