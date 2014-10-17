% read input .set file, swap the two hemispheres.

function EEG = eeglab_subject_swap_electrodes(input_file_name, output_file_name)    

    [input_path,input_name_noext,input_ext] = fileparts(input_file_name);
    [output_path,output_name_noext,output_ext] = fileparts(output_file_name);
    
    
    EEG = pop_loadset(input_file_name);
    pnts=EEG.pnts;
    tempvector=zeros(1,pnts);
    for ch=1:EEG.nbchan
       el=EEG.chanlocs(ch).labels; 
       lastchar=el(length(el));
       if ( lastchar ~= 'z')
          n_lastchar=str2num(lastchar);
          if (n_lastchar/2 ~= round(n_lastchar/2))       % is odd
            % get opposite electrode  
            label_without_lastchar=el(1:end-1);
            opposite_el_num=n_lastchar+1;
            opposite_el_label=[label_without_lastchar num2str(opposite_el_num)];
            opposite_el_index=find(strcmp({EEG.chanlocs.labels},{opposite_el_label}));
            
            % swap data vectors
            tempvector=EEG.data(ch,:);
            EEG.data(ch,:)=EEG.data(opposite_el_index,:);
            EEG.data(opposite_el_index,:)=tempvector(:);
          end
       end
    end
    disp(['=========>> swapping subject ' input_name_noext]);
    
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',output_name_noext, 'filepath', output_path);
end