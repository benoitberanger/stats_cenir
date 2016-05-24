function [ unixtime ] = datenum_to_unixtime( datenumeric )
unixtime = floor(86400 * (datenumeric - 719529 )); % datenum('01-Jan-1970')
end
