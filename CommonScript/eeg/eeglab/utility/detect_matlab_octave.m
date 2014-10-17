%% function  [config] = detect_matlab_octave()
% detect if the sw is operatin in octave or matlab; if in matlab it detects if the signal processig toolbox is installed
% output:
% config.whichsw          = 'octave' | 'matlab';
% config.exist_spt        = true |false 
%
function  [config] = detect_matlab_octave()   
    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;    

    if isOctave
        % install and load the required packages
        pkg -verbose install -forge signal
        pkg -verbose install -forge statistics
        pkg load signal
        pkg load statistics
        config.exist_spt        = true;
    else
        config.whichsw          = 'matlab';
        toolboxName             = 'Signal Processing Toolbox';
        v                       = ver;
        config.exist_spt        = any(strcmp(toolboxName, {v.Name})) == 1;
    end
end