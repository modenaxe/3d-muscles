%__________________________________________________________________________
% Author: Luca Modenese, July 2014
% email: l.modenese@griffith.edu.au
%__________________________________________________________________________
%
% Function that allows to retrieve the value of a specified variable whose
% name is specified in var_name
%
% INPUTS
% struct:   is a structure with fields 'colheaders', the headers, and 'data'
%           that is a matrix of data.
% var_name: the name of the variable to extract
%
% OUTPUTS
% var_value: the column of the matrix correspondent to the header specified
%               in input.
%
%
% modified 29/6/2016
% made changes to ensure that only one variable will be extracted!
% it also ensure extraction of 3D data by taking the 3rd dimension!
% includes modifications implemented in getValueColumnForHeader3D.m


function var_value = getValueColumnForHeader(struct, var_name)%, varargin)

% bug scoperto da Giuliano 11/07/2017
if (iscell(var_name)) && isequal(size(var_name,1),1)
    var_name = var_name{1};
end

% initializing allows better control outside the function
var_value = [];

% gets the index of the desired variable name in the colheaders of the
% structure from where it will be extracted
var_index = strcmp(struct.colheaders, var_name);%june 2016: strcmp instead of strncmp ensures unique correspondance

if sum(var_index) == 0
    % changed from error to warning so the output is the empty set
    warning(['getValueColumnForHeader.m','. No header in structure is matching the name ''',var_name,'''.'])
else
    % check that there is only one column with that label
    if sum(var_index) >1
        display(['getValueColumnForHeader.m',' WARNING: Multiple columns have been identified in summary with label ', var_name]);
        pause
    end
    
    % my choice was to automatically extract the third dimension of a set
    % using the 2D column headers indices
    if ndims(struct.data)==3
        var_value = struct.data(:,var_index,:);
    else
        var_value = struct.data(:,var_index);
    end
    
    % HERE IS AN ALTERNATIVE USING VARARGIN
%     % maybe this could be better handled 
%     if isempty(varargin)
%         var_value = struct.data(:,var_index);
%     elseif strcmp(varargin{1},'3D')==1
%         display('Extracting 3D data.')
%         % uses the index to retrieve the column of values for that variable.
%         var_value = struct.data(:,var_index,:);
%     end
end

end
