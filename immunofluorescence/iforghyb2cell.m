function [T_cell, T_avg] = iforghyb2cell(cellT, cellT_avg, varargin)
% outputs cell of tables for each cell, by organizing cell of tables for
% each hyb
%
% S is the structure
% csvPath is the path to save
%
% put in optional argument to insert immuno key antibody values
%
% date: 2/21/2019

    %% Set up optional Parameters
    argsLimit = 2;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('src:iforghyb2cell:TooManyInputs', ...
            'requires at most 2 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {[], []};
    % assign defaults
    optargs(1:numvarargs) = varargin;
    % Default Value of ref image is 1
    [immunokey, cycle_Stack] = optargs{:};
    

    %% variables
    numHybs = length(cellT);
    numCells = max(cellT{1}.cellID);
    T_cell = cell(numCells, 1);
    T_avg = [];
    
    %% organize if data by hybID
    for h = 1:numHybs
        T = cellT{h}(:,:);
        % set hybID as number of hyb or as immunokey
        if isempty(immunokey)
            hybID = ones(size(cellT_avg{h},1), 1) .* h;
        else
            hybID = cell(size(cellT_avg{h},1),1);
            hybID(:,1) = immunokey(h);
        end
        if isempty(cycle_Stack)
            hybT = table(hybID);
        else
            cycle = cell(size(cellT_avg{h},1),1);
            cycle(:,1) = cycle_Stack(h);
            hybT = table(hybID, cycle);
        end
        
        hybT = cat(2, hybT, cellT_avg{h});
        T_avg = cat(1, T_avg, hybT);
        for c = 1:numCells
            
            
            % find the values for each cell and catenate to Tsub
            Tsub = T(T.cellID == c,:);

            % assign Tsub with the hybID
            if isempty(immunokey)
                hybID = ones(size(Tsub,1), 1) .* h;
            else
                hybID = cell(size(Tsub,1),1);
                hybID(:,1) = immunokey(h);
            end
            
            if isempty(cycle_Stack)
                hybT = table(hybID);
            else
                cycle = cell(size(Tsub,1),1);
                cycle(:,1) = cycle_Stack(h);
                hybT = table(hybID, cycle);
            end
            hybT = cat(2, hybT, Tsub);
            % place in cell array
            T_cell{c} = cat(1, T_cell{c}, hybT);
        end
    end
    
    % sort rows of the average table
    T_avg = sortrows(T_avg,[2 3]);
    
    % remove cellID field for each T_cell to save space
    for c = 1:numCells
        T_cell{c}.cellID = [];
    end

end