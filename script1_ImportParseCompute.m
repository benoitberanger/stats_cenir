%% Init

close all
clear
clc


%% Import, parse, prepare

[ t , col , hdr ] = prepareTables

%% Where are we ?

% Tables are now ready to be processed to extract stats. So, we can keep
% them raw to have global stats, or we can reduce them to be related to 1
% protocole, or a group of protocols.


%% Stats

[ s , col , hdr ] = table2stat( t , col , hdr )

