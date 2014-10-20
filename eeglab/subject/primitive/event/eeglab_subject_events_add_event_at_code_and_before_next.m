function EEG = eeglab_subject_events_add_event_at_code_and_before_next(input_file_name, newev1_position_code, newev1_code, newev2_code, timebefore_newev2_code)

    % function kept for compatibility
    eeglab_subject_events_add_event_at_code_and_around_next(input_file_name, newev1_position_code, newev1_code, newev2_code, -timebefore_newev2_code)

end