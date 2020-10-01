function savesegtif(PathName, pos, cellnum, date, varargin)
    
    numvarargs = length(varargin);
    if numvarargs>1
        error('src:detectdots:TooManyInputs', ...
            'requires at most 1 optional inputs');
    end

    optargs = {''};
    optargs(1:numvarargs) = varargin;
    
    % Default Value of ref image is 1
    [naming] = optargs{:};
    
    addpath('C:\Users\Long Cai - 1\Desktop\Fiji.app\scripts');
    Miji;
    path_to_fish = ['path=[' PathName '\Pos' num2str(pos) '\alignedcorrected-Pos' num2str(pos) '.tif' ']'];
    MIJ.run('Open...', path_to_fish);
    MIJ.run('Split Channels')
    MIJ.createImage('Nuclearseg',int32(bwperim(cellnum>0)),true);
    MIJ.run('Merge Channels...', ['c1=C1-alignedcorrected-Pos' num2str(pos) '.tif c2=C2-alignedcorrected-Pos' num2str(pos) '.tif c3=Nuclearseg create']);
    MIJ.run('Save', ['save=[' PathName '\Pos' num2str(pos) '\alignedcorrected-Pos' num2str(pos) '_nucSeg' naming '-' num2str(date) '.tif' ']']);
    MIJ.run('Close All');
    
end