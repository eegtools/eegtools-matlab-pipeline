function [pmask, corr_p, lowest_p] = bst_stat_thresh(pmap)
% BST_STAT_THRESH: Threshold a maps of p-values, correcting for multiple comparisons, taking into account multiple frequencies.
%
% USAGE:  [pmask, corr_p] = bst_stat_thresh(pmap)
%
% INPUTS:
%    - pmap     : Map of p-values of any size
%
% OUTPUTS:
%    - pmask  : Logical mask (0 and 1) of the same size as the pmap. 
%               1 means over the threshold (significant); 0 means below the threshold (not significant)
%    - corr_p : Corrected p-threshold
%
% NOTES:
%    - The correction that is applied and the uncorrected p-threshold are read from 
%      Brainstorm preferences, in variable 'StatThreshOptions', usually defined through the GUI
%    - Those options can be set from a script using: bst_set('StatThreshOptions', your_structure)

% @=============================================================================
% This software is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2000-2013 Brainstorm by the University of Southern California
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPL
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@
%
% Authors: Francois Tadel, 2010

% Get current options
StatThreshOptions = bst_get('StatThreshOptions');
% Type of correction:
switch (StatThreshOptions.Correction)
    case 'none'
        % Using uncorrected threshold
        corr_p = StatThreshOptions.pThreshold;
        % Thresholded pvalues mask
        pmask = (pmap < corr_p);
        
    case 'bonferroni'
        % Control over: time&space or space only
        switch (StatThreshOptions.Control)
            case 'time_space'
                nTests = numel(pmap);
            case 'time_space_freq'
                nTests = numel(pmap);
            case 'space'
                nTests = size(pmap,1);
        end
        % Bonferroni correction: p/N
        corr_p = StatThreshOptions.pThreshold ./ nTests;
        % Thresholded pvalues mask
        pmask = (pmap < corr_p);
        
    case 'fdr'
        % Control over: time&space or space only
        switch (StatThreshOptions.Control)
            case 'time_space_freq'
                % Use all the pvalues
                corr_p = FdrThreshold(pmap, StatThreshOptions.pThreshold);
                % Thresholded pvalues mask
                pmask = (pmap < corr_p);
            case 'time_space'
                % Use all the pvalues
                corr_p = FdrThreshold(pmap, StatThreshOptions.pThreshold);
                % Thresholded pvalues mask
                pmask = (pmap < corr_p);
            case 'space'
                % Initialize mask
                pmask = false(size(pmap));
                nTime = size(pmap,2);
                nFreq = size(pmap,3);
                corr_p = zeros(1,nTime);
                % Loop for each time
                for iTime = 1:nTime
                    % Use only the pvalues for this time point
                    corr_p(iTime) = FdrThreshold(pmap(:,iTime,1), StatThreshOptions.pThreshold);
                    pmask(:,iTime,:) = (pmap(:,iTime,:) < corr_p(iTime));
                end
        end      
end
disp(sprintf('BST> Average corrected p-threshold: %g', mean(corr_p)));
end


%% ===== FDR THRESOLD =====
function corr_p = FdrThreshold(pmap, pThreshold)
    % Sort pvalues
    pmap_sorted = sort(pmap(:));
    % Number of tests
    N = length(pmap_sorted); 
    % FDR line
    fdr_line = (1:N)' ./ N .* pThreshold; 
    % Highest crossing point between sorted pvalues and FDR line
    crossing = find( pmap_sorted>fdr_line == 0, 1, 'last');
    % If the two lines cross
    if ~isempty(crossing)
        corr_p = fdr_line(crossing);
    % Else: no significant voxels
    else
        corr_p = 0;
    end
end



