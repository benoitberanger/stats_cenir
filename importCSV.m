function [ num, txt, raw ] = importCSV( filename, pattern )
% IMPORTCSV will importe CSV file, make some corrections due to phpMyAdmin
% converter, then generate 3 array, for convinient use.


%% Open

fileID = fopen(filename, 'r');
str = fread(fileID, '*char')';
fclose('all');


%% Reverse bulshit introduced by the CSV generator on phpMyAdmin SQL

% Some lines are splitted because of the intruction of CRLF in the middle
% of the line.

to_delete = {
    '\r\n'
    '<b>'
    '</b>'
    '<br>'
    '<br />'
    '"'
};
for del = 1 : length(to_delete)
str = regexprep(str,to_delete{del},'');
end


%% Parse each rows of the CSV file

C = ...
    textscan(str,cell2mat(pattern),...
    'Delimiter',';',...
    'EndOfLine','\n');

fprintf('total lignes counted in the file : %d \n',length(regexp(str,'\n')))
fprintf('lignes parsed in the file : \n')
disp(C)


%% Export 3 array for more convinient processing

num = nan(length(C{1}),length(C));
txt = cell(size(num));
raw = cell(size(num));
for i = 1 : length(C)
    
    curr = C{i};
    idx = 1:length(curr);
    
    if isnumeric(curr)
        num(idx,i) = curr;
        raw(idx,i) = num2cell( curr );
    end
    
    if iscell(curr)
        txt(idx,i) = curr;
        raw(idx,i) = curr;
    end
    
end


end % function
