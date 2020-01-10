%% EEG = proj_fieldtrip_subject_preprocessing(project, subj_name,mode)
%
% function to preprocess already imported data. it has 2 modes:

% 1) preprocess EEGLab data (supposed to be already preprocessed and epoched
% 2) preprocess raw data (without a previous processing of EEGLab)
%
% in case 1) data are only converted in a format suitable for next analysis
% in fieldtrip
%
% in case 2 data are preprocessed by applying
%
% SUBSAMPLING
% DISCARD TAIL ELECTRODES
% CHANNELS TRANSFORMATION
% INTERPOLATION
% RE-REFERENCE
% SPECIFIC FILTERING
%

function FT_EEG = proj_fieldtrip_subject_import(project, varargin)

% % % % % subj_name is a string or a cell array of strings denoting name(s) of
% % % % % subject(s) to be processed
% % % % 
% % % % % mode 1: preprocess EEGLab data
% % % % 
% % % % % construct the file name from project, subj_name, and cycling for all conditions (i.e. epoched file of the selected subject)
% % % % 
% % % % epochs_path         = project.paths.output_epochs;
% % % % condition_names     = project.epoching.condition_names;
% % % % import_out_suffix   = project.import.output_suffix;
% % % % 
% % % % % load each epochs EEGLab file set file (subject and condition) and convert
% % % % % it in a fieldtrip format
% % % % 
% % % % for subj=1:length(subj_name_list)
% % % %     for cond=1:length(condition_names)
% % % %         setname=[project.import.original_data_prefix subj_name_list{subj} project.import.original_data_suffix import_out_suffix project.epoching.input_suffix '_'  condition_names{cond} '.set'];
% % % %         cfg.dataset=fullfile(epochs_path,setname,'');
% % % %         cfg.method='trial';
% % % %         [FT_EEG] = ft_preprocessing(cfg);
% % % %         save([outputdir filesep subjectdata.subjectnr '_preproc_dataM'],'dataM','-V7.3')
% % % %         
% % % %     end
% % % %     
% % % % end


%% EEG = proj_eeglab_subject_add_factor(project, varargin)
%
%%
% function EEG = proj_eeglab_subject_add_factor(project, varargin)
close all
if sum(ismember({project.study.factors.factor},'condition'))
    disp('the factor name condition is reserved by eeglab: please change name e.g. to cond')
    return
end

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
    add_factor_list = project.study.factors;
    % ----------------------------------------------------------------------------------------------------------------------------
    if not(isempty(add_factor_list))
        for nc=2%:project.epoching.numcond
            cond_name                               = project.epoching.condition_names{nc};
            input_file_name                         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', cond_name, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
            [input_path,input_name_noext,input_ext] = fileparts(input_file_name);
            
            if exist(input_file_name, 'file')

                cfg.dataset=fullfile(input_file_name,'');
                cfg.method='trial';
                cfg.layout='biosemi64.lay';
                [FT_EEG] = ft_preprocessing(cfg);
                save([project.paths.field_trip_output_epochs filesep subj_name,'_',cond_name ],'FT_EEG','-V7.3');
                
               
                % use ft_timelockanalysis to compute the ERPs 
cfg = [];
% cfg.trials = find(data_clean.trialinfo==1);
cfg.layout='biosemi64.lay';
task1 = ft_timelockanalysis(cfg, FT_EEG);

cfg = [];
cfg.layout='biosemi64.lay';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
cfg.showlabels  = 'yes';
figure;
ft_multiplotER(cfg, task1)


mri =ft_read_mri('/home/campus/work/work-matlab/matlab_toolbox/Subject01/Subject01.mri');
% disp(mri)
% mri = ft_determine_coordsys(mri, 'interactive', 'no');
% mri.coordsys = 'spm';

% % segment the MRI
% cfg = [];
% % cfg.method = 'fiducial'
% cfg.output = {'brain' 'skull' 'scalp'};
%     atlas = ft_read_atlas('/home/campus/work/work-matlab/matlab_toolbox/fieldtrip/template/atlas/afni/TTatlas+tlrc.HEAD');

% segmentedmri = ft_volumesegment(cfg, mri);
% disp(mri)
% 
% 
% cfg           = [];
% cfg.output    = {'brain','skull','scalp'};
% segmentedmri  = ft_volumesegment(cfg, mri);
% 
% % save segmentedmri segmentedmri
% 
% disp(segmentedmri)


load('/home/campus/work/work-matlab/matlab_toolbox/segmentedmri.mat')

cfg=[];
cfg.tissue={'brain','skull','scalp'};
cfg.numvertices = [3000 2000 1000];
bnd=ft_prepare_mesh(cfg,segmentedmri);



% Create a volume conduction model using 'dipoli', 'openmeeg', or 'bemcp'.
% Dipoli
cfg        = [];
cfg.method ='dipoli'; % You can also specify 'openmeeg', 'bemcp', or another method.
vol        = ft_prepare_headmodel(cfg, bnd);


% % % % % % load /home/campus/work/work-matlab/matlab_toolbox/fieldtrip/template/headmodel/standard_mri.mat
% % % % % cfg = [];
% % % % % cfg.method = 'fiducial'
% % % % % cfg.method ='dipoli'; % dipoli only works under linux
% % % % % hdm = ft_prepare_headmodel(cfg, segmentedmri);
% % % % % 
elec = ft_read_sens('/home/campus/work/work-matlab/matlab_toolbox/fieldtrip/template/electrode/standard_1020.elc');
hdm = ft_convert_units(hdm, elec.unit);
% % % % % 
% % % % % % elec = ft_read_sens('/home/campus/work/work-matlab/matlab_toolbox/fieldtrip/template/layout/biosemi64.lay');
% % % % % % vol  = ft_read_vol('headmodel/standard_vol.mat');
% % % % % 
% % % % % %   vol.r = [86 88 92 100];
% % % % % %   vol.o = [0 0 40];
% % % % % %   figure, ft_plot_vol(vol)
% % % % % % ft_plot_vol([],vol);
% % % % % % 
% dipole fitting
cfg = [];
% cfg.layout='biosemi64.lay';
cfg.vol = vol;
cfg.elec = elec;
cfg.model = 'regional';
cfg.numdipoles = 2;
cfg.latency = [0.050 0.090]; %n100
cfg.gridsearch = 'yes';
cfg.resolution = 20; % mm
cfg.nonlinear = 'yes';
cfg.symmetry = 'x';
source = ft_dipolefitting(cfg, task1);


% plot first dipole position on mni
cfg = [];
cfg.method = 'ortho';
cfg.location = source.dip.pos(2,:);
figure; ft_sourceplot(cfg, mri);


% % % % % 
% % % % % 
% % % % % % cfg.channel   = {'O1', 'O2'};        % read all MEG channels except MLP31 and MLO12
% % % % % % cfg.demean    = 'yes';                              % do baseline correction with the complete trial

cfg              = [];
cfg.layout='biosemi64.lay';
cfg.output       = 'pow';
% cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 4:1:32;                         % analysis 2 to 30 Hz in steps of 2 Hz 
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.2;   % length of time window = 0.5 sec
cfg.toi          = -0.2:0.005:0.7;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
cfg.pad          = 64;

TFRhann = ft_freqanalysis(cfg, FT_EEG);




cfg = [];
cfg.layout='biosemi64.lay';
% cfg.baseline     = [-0.2 0]; 
% cfg.baselinetype = 'absolute'; 
% cfg.zlim         = [-3e-27 3e-27];	        
cfg.showlabels   = 'yes';	
% cfg.layout       = 'CTF151_helmet.mat';
figure 
ft_multiplotTFR(cfg, TFRhann);
% 
% 
% 
% cfg.ylim         = [15 20];
% cfg.marker       = 'on';
% figure 
% ft_topoplotTFR(cfg, TFRhann);


% EEG             = pop_loadset(input_file_name);
% 
%                [header,dat,evt] = eeglab2fieldtrip( EEG, 'preprocessing', 'none' );
                
            else
                disp(['error: condition file name (' input_name_noext ') not found!!!! exiting .....']);
                %                 return;
            end
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






% % function to preprocess already imported and filtered data
%     input_file_name         = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix '.set']);
%     [path,name_noext,ext]   = fileparts(input_file_name);
%     EEG                     = pop_loadset(input_file_name);
%
%     eeg_channels_list       = project.eegdata.eeg_channels_list;
%     eog_channels_list       = project.eegdata.eog_channels_list;
%     emg_channels_list       = project.eegdata.emg_channels_list;
%
%     ff1_eeg=project.preproc.ff1_eeg; ff2_eeg=project.preproc.ff2_eeg;
%     ff1_eog=project.preproc.ff1_eog; ff2_eog=project.preproc.ff2_eog;
%     ff1_emg=project.preproc.ff1_emg; ff2_emg=project.preproc.ff2_emg;
%
%     output_suffix           = project.import.output_suffix;
%     output_path             = project.paths.input_epochs;
%
%     %===============================================================================================
%     % check if SUBSAMPLING
%     %===============================================================================================
%     if (EEG.srate > project.eegdata.fs)
%         disp(['subsampling to ' num2str(project.eegdata.fs)]);
%         EEG = pop_resample( EEG, project.eegdata.fs);
%         EEG = eeg_checkset( EEG );
%     end
%
%     %===============================================================================================
%     % CHANNELS TRANSFORMATION
%     %===============================================================================================
%     num_ch2transform = length(project.import.ch2transform);
%
%     if num_ch2transform
%
%         initial_ch_num      = EEG.nbchan;
%         num_mono            = 0;
%         num_poly            = 0;
%         num_disc            = 0;
%         num_new_ch          = 0;
%         new_label           = {};
%         new_data            = [];
%         ch2discard          = [];
%
%         for nb=1:num_ch2transform
%             transf = project.import.ch2transform(nb);
%             if ~isempty(transf.new_label)
%                 ... new ch
%                 num_new_ch = num_new_ch + 1;
%                 new_label   = [new_label transf.new_label];
%                 if isempty(transf.ch2)
%                     ... monopolar
%                     ch2discard              = [ch2discard transf.ch1];
%                     new_data(num_new_ch,:)  = EEG.data(transf.ch1,:);
%                     num_mono                = num_mono + 1;
%                 else
%                     ... bipolar
%                     ch2discard              = [ch2discard transf.ch1 transf.ch2];
%                     new_data(num_new_ch,:)  = EEG.data(transf.ch1,:)-EEG.data(transf.ch2,:);
%                     num_poly                = num_poly + 1;
%                 end
%             else
%                 ... ch 2 discard
%                 ch2discard = [ch2discard transf.ch1];
%                 num_disc        = num_disc + 1;
%             end
%         end
%
%         for nb=1:num_new_ch
%             EEG.data((EEG.nbchan+nb),:) = new_data(nb, :);
%             if ~isempty(EEG.chanlocs)
%                 EEG.chanlocs(EEG.nbchan+nb).labels  = new_label{nb};
%             end;
%         end
%         EEG             = eeg_checkset(EEG);
%         EEG             = pop_select(EEG, 'nochannel', ch2discard); ... remove the polych and all the remaining ch up to list end
%         EEG             = eeg_checkset(EEG);
%
%         num_ch          = initial_ch_num - length(ch2discard) + num_new_ch;
%         num_discarded   = length(ch2discard) - num_new_ch;
%
%         if num_ch ~= project.eegdata.nch
%            disp(['Error in channels number manipulation: expected ' num2str(project.eegdata.nch) ', calculated ' num_ch]);
%         else
%             disp('--------------------------------------------------------------------------');
%             disp(['starting number of electrodes:' num2str(initial_ch_num)]);
%             disp([num2str(num_disc) ' channels will be discarded']);
%             disp([num2str(num_poly*2) ' polygraphic channels will be trasformed in ' num2str(num_poly) ' poly channels and appended at the end']);
%             disp([num2str(num_mono) ' monographic channels were appended at the end']);
%             disp(['final number of channels will be:' num2str(project.eegdata.nch)]);
%             disp('--------------------------------------------------------------------------');
%         end
%     end
%
%     %===============================================================================================
%     % INTERPOLATION
%     %===============================================================================================
%     for ns=1:length(project.subjects.data)
%         if (strcmp(project.subjects.data(ns).name, subj_name))
%             ch2interpolate=project.subjects.data(ns).bad_ch;
%         end
%     end
%
%     if ~isempty(ch2interpolate)
%         tchanint        = length(ch2interpolate);
%         channels_list   = {EEG.chanlocs.labels};
%         for nchint=1:tchanint;
%             match_int(nchint,:) = strcmpi(channels_list,ch2interpolate(nchint));
%         end
%         intvec          = find(sum(match_int,1)>0);
%         interpolation   = intvec;
%         disp(['interpolating channels ' ch2interpolate])
%         EEG             = pop_interp(EEG, [interpolation], 'spherical');
%         EEG             = eeg_checkset( EEG );
%     end
%
%     %===============================================================================================
%     % RE-REFERENCE
%     %===============================================================================================
%     ... if left blank => do nothing, if project.import.reference_channels{1} = 'CAR' => apply CAR, else ...
%     if ~isempty(project.import.reference_channels)
%         reference=[];
%         if ~strcmp(project.import.reference_channels{1}, 'CAR')
%
%             tchanref        = length(project.import.reference_channels);
%             channels_list   = {EEG.chanlocs.labels};
%             for nchref=1:tchanref;
%                 ll                  = length(project.import.reference_channels{nchref});
%                 match_ref(nchref,:) = strncmp(channels_list, project.import.reference_channels(nchref), ll);
%             end
%             refvec      = find(sum(match_ref,1)>0);
%             reference   = refvec;
%         end
%
%         if isempty(project.eegdata.no_eeg_channels_list)
%            EEG = pop_reref(EEG, [reference], 'keepref', 'on');
%         else
%            EEG = pop_reref(EEG, [reference], 'exclude', project.eegdata.no_eeg_channels_list, 'keepref', 'on');
%         end
%
%         EEG = eeg_checkset( EEG );
%     end
%
%     %===============================================================================================
%     % SPECIFIC FILTERING
%     %===============================================================================================
%
%     % filter for EEG channels
%     EEG = proj_eeglab_subject_filter(EEG, project,'eeg','bandpass');
%     EEG = eeg_checkset( EEG );
%
%     % filter for EOG channels
%     if ~isempty(eog_channels_list)
%         EEG = proj_eeglab_subject_filter(EEG, project,'eog','bandpass');
%         EEG = eeg_checkset( EEG );
%     end
%     % filter for EMG channels
%     if ~isempty(emg_channels_list)
%         EEG = proj_eeglab_subject_filter(EEG, project,'emg','bandpass');
%         EEG = eeg_checkset( EEG );
%     end
%
%
%     %===============================================================================================
%     % EVENT SELECTING
%     %===============================================================================================
%     % convert events type to string
%     for ev=1:size(EEG.event,2)
%         EEG.event(ev).type=num2str(EEG.event(ev).type);
%     end
%
% %     if ~isempty(EEG.event)
% %         if iscell(project.import.valid_marker)
% %             % cell array containing markers' code to import
% %             selstim=[];
% %             selstim0=[];
% %
% %             selstim = ismember({EEG.event.type}, project.import.valid_marker);
% %             EEG.event=EEG.event(selstim);
% %         else
% %             % is a string with values 'stimuli', 'responses', 'all'
% %             evecode={EEG.event.code};
% %             switch project.import.valid_marker
% %                 case 'stimuli'
% %                     selstim=strncmp(evecode,'S',2);
% %                 case 'responses'
% %                     selstim2=strncmp(evecode,'R',2);
% %                 case 'all'
% %                     selstim1=strncmp(evecode,'S',2);
% %                     selstim2=strncmp(evecode,'R',2);
% %                     selstim=selstim1|selstim2;
% %             end
% %             EEG.event=EEG.event(selstim);
% %         end
% %         EEG = eeg_checkset( EEG );
% %     end
%
%     %===============================================================================================
%     % SAVE
%     %===============================================================================================
%     EEG = pop_saveset( EEG, 'filename', name_noext,'filepath',project.paths.input_epochs);
% end
%
% % ====================================================================================================
% % ====================================================================================================
% % CHANGE LOG
% % ====================================================================================================
% % ====================================================================================================
% % 23/9/2014
% % completely redesigned the channel transformation section. a proper structure has been introduced, allowing user to select discarded channels
% % and how to treat bipolar and monopolar channels
% % 16/9/2014
% % referencing exclude channels according to items in project.eegdata.no_eeg_channels_list
% % added channels manipulation info
% % poly data are not appended, but substitute data in the proper channel
% % remove channels at the end of the ch tail. for those setup using recording several polygraphic but using only part of them (e.g as with biosemi)
% % 30/1/2014
% % first version of the new project structure