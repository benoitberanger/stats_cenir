function [ op_raw ] = prepareOP


%% Load data

filename_op = 'gg_op.csv';

% %               2093; f; OP_CENIR_IH_AGENT10_F02_2018_152 ; 5; 2018-04-05 14:26:11; NULL; 2018-05-09; 300; 0   ; 0  ; 6180 ; 20; 21; 20.4   ; ICM; 6  ; 718; 0;   ; ICM_FC79012018; 2018-05-09; S.900.DMRF; 663838; DELPHINE; 2018-04-05 14:25:39; SOPHIE  ; 2018-05-09 14:20:00
% %               2207; f; OP_CENIR_IH_MINO_AMN_F01_2018_255; 1; 2018-07-02 14:07:20; NULL; NULL      ; 0  ; 1000; 0  ; 11165; 20; 11; 20.0333; ICM; 152; 634; 0;   ;               ; NULL      ;           ; 7a72ce; DELPHINE; 2018-07-02 14:07:17; DELPHINE; 2018-07-02 14:07:20
% pattern_op = {'%d    %s %s                                 %d %s                   %s    %s          %f    %f    %f  %f     %f  %d  %f       %s   %d   %d   %d %s  %s              %s          %s          %s      %s        %s                   %s        %s         '};
% 
% [t.o.num,t.o.txt,t.o.raw] = importCSV( filename_op , pattern_op );
% 
% vars = {'num' 'txt' 'raw'};
% X = 'p';


%% Open

fileID = fopen(filename_op, 'r');
str = fread(fileID, '*char')';
fclose(fileID);


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

allLines = regexp(str,'\n','split')';

all = regexp(allLines,'\;','split');

op_raw = cell(length(all),30);
for l = 1 : length(all)
    op_raw(l,1:length(all{l})) = all{l};
end

op_raw = op_raw(:,1:15);

end % function
