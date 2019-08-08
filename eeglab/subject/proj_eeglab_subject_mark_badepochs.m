%% EEG = proj_eeglab_subject_mark_badepochs(project, varargin)
%
%%
function EEG = proj_eeglab_subject_mark_badepochs(project, varargin)



if not(isfield(project.epoching, 'custom_suffix') )
    project.epoching.custom_suffix = '';
end

if not(isfield(project.epoching, 'custom_input_folder') )
    project.epoching.custom_input_folder = '';
end

custom_suffix = project.epoching.custom_suffix;
custom_input_folder     = project.epoching.custom_input_folder;


list_select_subjects    = project.subjects.list;
get_filename_step       = 'add_factor';
% custom_suffix           = '';
% custom_input_folder     = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'get_filename_step',    ...
                'custom_input_folder',  ...
                'custom_suffix' ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
numsubj = length(list_select_subjects);
% -------------------------------------------------------------------------------------------------------------------------------------

for subj=1:numsubj
    subj_name       = list_select_subjects{subj};
    
    eeg_input_path  = project.paths.output_epochs;
    % ----------------------------------------------------------------------------------------------------------------------------
    for nc=1:project.epoching.numcond
        cond_name                               = project.epoching.condition_names{nc};
        input_file_name                         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', cond_name, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
        [input_path,input_name_noext,input_ext] = fileparts(input_file_name);
        
        if exist(input_file_name, 'file')            
            EEG             = pop_loadset(input_file_name);  
            %%          superpose rejections of a EEG dataset
            EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);            
            %%          pop_eegthresh() - reject artifacts by detecting outlier values.  This has
            %                     long been a standard method for selecting data to reject.
            %                     Applied either for electrode data or component activations.
            %   Usage:
            %     >> pop_eegthresh( INEEG, typerej); % pop-up interactive window
            %     >> [EEG Indexes] = pop_eegthresh( INEEG, typerej, elec_comp, lowthresh, ...
            %                  upthresh, starttime, endtime, superpose, reject);
            %
            %
            %   Inputs:
            %     INEEG      - input EEG dataset
            %     typerej    - type of rejection (0 = independent components; 1 = raw
            %                data). Default is 1. For independent components, before
            %                thresholding the activations are normalized (to have std. dev. 1).
            %     elec_comp  - [e1 e2 ...] electrode|component numbers to take
            %                into consideration for rejection
            %     lowthresh  - lower threshold limit (in uV|std. dev. For components, the
            %                threshold(s) are in std. dev.). Can be an array if more than one
            %                electrode|component number is given in elec_comp (above).
            %                If fewer values than the number of electrodes|components, the
            %                last value is used for the remaining electrodes|components.
            %     upthresh   - upper threshold limit (in uV|std dev) (see lowthresh above)
            %     starttime  - rejection window start time(s) in seconds (see lowthresh above)
            %     endtime    - rejection window end time(s) in seconds (see lowthresh)
            %     superpose  - [0|1] 0=do not superpose rejection markings on previous
            %                rejection marks stored in the dataset: 1=show both current and
            %                previously marked rejections using different colors. {Default: 0}.
            %     reject     - [1|0] 0=do not actually reject the marked trials (but store the
            %                marks: 1=immediately reject marked trials. {Default: 1}.
            elec_comp = 1:project.eegdata.nch_eeg;
%             project.mark_badepochs.eegthresh.lowthresh = -25;
%             project.mark_badepochs.eegthresh.upthresh  = 25;
            starttime = EEG.xmin;
            endtime   = EEG.xmax;
            EEG = pop_eegthresh(EEG,1,elec_comp ,...
                project.mark_badepochs.eegthresh.lowthresh,...
                project.mark_badepochs.eegthresh.upthresh,...
                starttime,endtime,2,0);
            %%
            %     >> OUTEEG = pop_rejtrend( INEEG, typerej, elec_comp, ...
            %                  winsize, maxslope, minR, superpose, reject,calldisp);
            %   Command line inputs:
            %     INEEG      - input EEG dataset
            %     typerej    - [1|0] data to reject on: 0 = component activations;
            %                  1 = electrode data. {Default: 1}.
            %     elec_comp  - [e1 e2 ...] electrode|component number(s) to take into
            %                  consideration during rejection
            %     winsize    - (integer) number of consecutive points
            %                  to use in detecing linear trends
            %     maxslope   - maximal absolute slope of the linear trend to allow in the data
            %     minR       - minimal linear regression R-square value to allow in the data
            %                  (= coefficient of determination, between 0 and 1)
            %     superpose  - [0|1] 0 = Do not superpose marks on previous marks
            %                  stored in the dataset; 1 = Show both types of marks using
            %                  different colors. {Default: 0}
            %     reject     - [1|0] 0 = Do not reject marked trials but store the
            %                  labels; 1 = Reject marked trials. {Default: 1}
            %     calldisp   - [0|1] 1 = Open scroll window indicating rejected trials
            %                  0 = Do not open scroll window.  {Default: 1}
            
            winsize   = EEG.pnts;
%             project.mark_badepochs.rejtrend.maxslope  = 50;
%             project.mark_badepochs.rejtrend.minR      = 0.3;
            EEG = pop_rejtrend(EEG,1,elec_comp ,winsize,...
                project.mark_badepochs.rejtrend.maxslope,...
                project.mark_badepochs.rejtrend.minR,2,0);
            
            %%  >> pop_jointprob( INEEG, typerej) % pop-up interative window mode
            %     >> [OUTEEG, locthresh, globthresh, nrej] = ...
            %  		= pop_jointprob( INEEG, typerej, elec_comp, ...
            %                     locthresh, globthresh, superpose, reject, vistype);
            % Inputs:
            %     INEEG      - input dataset
            %     typerej    - [1|0] data to reject on (0 = component activations;
            %                1 = electrode data). {Default: 1 = electrode data}.
            %     elec_comp  - [n1 n2 ...] electrode|component number(s) to take into
            %                consideration for rejection
            %     locthresh  - activity probability limit(s) (in std. dev.) See "Single-
            %                channel limit(s)" above.
            %     globthresh - global limit(s) (all activities grouped) (in std. dev.)
            %     superpose  - [0|1] 0 = Do not superpose rejection marks on previously
            %                marks stored in the dataset: 1 = Show both current and
            %                previous marks using different colors. {Default: 0}.
            %     reject     - 0 = do not reject marked trials (but store the marks:
            %                1 = reject marked trials {Default: 1}.
            %     vistype    - Visualization type. [0] calls rejstatepoch() and [1] calls
            %                eegplot() default is [0].When added to the command line
            %                call it will not display the plots if the option 'plotflag'
            %                is not set.
            %   topcommand   - [] Deprecated argument , keep to ensure backward compatibility
            %   plotflag     - [1,0] [1]Turns plots 'on' from command line, [0] off.
            %                (Note for developers: When called from command line
            %                it will make 'calldisp = plotflag') {Default: 0}
%             project.mark_badepochs.jointprob.locthresh  = 5;
%             project.mark_badepochs.jointprob.globthresh = 5;
            EEG = pop_jointprob(EEG,1,elec_comp,...
                project.mark_badepochs.jointprob.locthresh,...
                project.mark_badepochs.jointprob.globthresh,...
                0,0,0,[],0);
            
            %% [OUTEEG, locthresh, globthresh, nrej] = ...
            %  		= pop_rejkurt( INEEG, typerej, elec_comp, ...
            %                     locthresh, globthresh, superpose, reject, vistype);
            %  Inputs:
            %     INEEG      - Input dataset
            %     typerej    - Type of rejection (0 = independent components; 1 = eeg
            %                data). Default is 1. For independent components, before
            %                thresholding, the activity is normalized for each
            %                component.
            %     elec_comp  - [e1 e2 ...] electrodes (number) to take into
            %                consideration for rejection.
            %     locthresh  - Activity kurtosis limit in terms of standard-dev.
            %     globthresh - Global limit (for all channel). Same unit as above.
            %     superpose  - [0] do not superpose pre-labelling with previous
            %                pre-labelling (stored in the dataset). [1] consider
            %                both pre-labelling (using different colors). Default is [0].
            %     reject     - [0] do not reject labelled trials (but still
            %                store the labels. [1] reject labelled trials.
            %                Default is [1].
            %     vistype    - Visualization type. [0] calls rejstatepoch() and [1] calls
            %                eegplot() default is [0].When added to the command line
            %                call it will not display the plots if the option 'plotflag'
            %                is not set.
            %     topcommand - [] Deprecated argument , keep to ensure backward compatibility
            %     plotflag   - [1,0] [1]Turns plots 'on' from command line, [0] off.
            %                (Note for developers: When called from command line
            %                it will make 'calldisp = plotflag') {Default: 0}
            
%             project.mark_badepochs.rejkurt.locthresh  = 5;
%             project.mark_badepochs.rejkurt.globthresh = 5;
            
            EEG = pop_rejkurt(EEG,1,elec_comp ,...
                project.mark_badepochs.rejkurt.locthresh,...
                project.mark_badepochs.rejkurt.globthresh,...
                0,0,0,[],0);
            %% [OUTEEG, Indices] = pop_rejspec( INEEG, typerej, 'key', val, ...);
            %             Command line inputs:
            %     INEEG      - input dataset
            %     typerej    - [1|0] data to reject on (0 = component activations; 1 =
            %                  electrode data). {Default is 1}.
            %
            %   Optional arguments.
            %     'elecrange'     - [e1 e2 ...] array of indices of electrode|component
            %                       number(s) to take into consideration during rejection.
            %     'threshold'     - [lower upper] threshold limit(s) in dB.
            %     'freqlimits'    - [lower upper] frequency limit(s) in Hz.
            %     'method'        - ['fft'|'multitaper'] method to compute spectrum.
            %     'specdata'      - [array] precomputed spectral data.
            %     'eegplotcom'    - [string] EEGPLOT command to execute when pressing the
            %                       reject button (see 'command' input of EEGPLOT).
            %     'eegplotreject' - [0|1] 0 = Do not reject marked trials (but store the
            %                       marks. 1 = Reject marked trials. {Default: 1}.
            %     'eegplotplotallrej' - [0|1] 0 = Do not superpose rejection marks on previous
            %                       marks stored in the dataset. 1 = Show both previous and
            %                       current marks using different colors. {Default: 0}.
%             project.mark_badepochs.rejspec.threshold   = [-25 25];
%             project.mark_badepochs.rejspec.freqlimits  = [0 50];
            EEG = pop_rejspec( EEG, 1,'elecrange',elec_comp ,...
                'method','multitaper',...
                'threshold',project.mark_badepochs.rejspec.threshold ,...
                'freqlimits',project.mark_badepochs.rejspec.freqlimits ,...
                'eegplotcom','set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''mantrial''), ''string'', num2str(sum(EEG.reject.rejmanual)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''threshtrial''), ''string'', num2str(sum(EEG.reject.rejthresh)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''freqtrial''), ''string'', num2str(sum(EEG.reject.rejfreq)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''consttrial''), ''string'', num2str(sum(EEG.reject.rejconst)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''enttrial''), ''string'', num2str(sum(EEG.reject.rejjp)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''kurttrial''), ''string'', num2str(sum(EEG.reject.rejkurt)));','eegplotplotallrej',2,'eegplotreject',0);
            %%
            EEG = eeg_checkset( EEG );
            %%
            
            EEG = pop_saveset( EEG, 'filename',[input_name_noext, input_ext],'filepath',input_path);
            
        else
            disp(['error: condition file name (' input_name_noext ') not found!!!! exiting .....']);
            %                 return;
        end
    end
end

end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name


