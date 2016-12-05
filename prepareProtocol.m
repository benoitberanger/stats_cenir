function [ tp , colp , hdrp ] = prepareProtocol


%% Load data

filename_p = 'gg_etude.csv';

%           ABBY    ABE4869g    19    -1    15   10     0    pharmaco  Genentech  NeuroRx  2012-03-07 15:50:28   2012-09-20 17:52:31  FREDERICK  ADMINISTRATEUR
pattern_p = {'%s'    '%s'        '%d'  '%d'  '%d' '%d'   '%d' '%s'      '%s'       '%s'     '%s'                  '%s'                 '%s'       '%s' };

[t.p.num,t.p.txt,t.p.raw] = importCSV( filename_p , pattern_p );

vars = {'num' 'txt' 'raw'};
X = 'p';


%% Keep only MRI proto


% MRI room (only entry)

mri_entry = or( t.p.num(:,3) == 1 , t.p.num(:,3) == 19 );

for v = 1 : length(vars)
    V = vars{v};
    
    t.p.(V) = t.p.(V)( mri_entry , : );
    
end


%% Delete row we don't care


col_to_delete.p = [12 13 14];
names.p = { 'eid' 'code_alt' 'rid' 'statut' 'nj_automail' 'nj_autodel' 'cren_trouve' 'type' 'labo' 'presta_ext' 'cre_date' };

for v = 1 : length(vars)
    V = vars{v};
    
    t.(X).(V)( : , col_to_delete.(X) ) = [];
    
end

nCol.(X) = 0;

for n = 1:length(names.(X))
    nCol.(X) = nCol.(X) +1;
    col.(X).( names.(X) {n} ) = nCol.(X);
end

hdr.(X) = fieldnames(col.(X));
if length(hdr.(X)) ~= size(t.(X).num,2);
    error('invalid hdr.%s',X);
end


%% Output

tp = t.p;
colp = col.p;
hdrp = hdr.p;


end
