function res = eeglab_check_tw_compliancy(ca_intervals, times_vector)

    len         = length(ca_intervals);
    min_times   = min(times_vector);
    max_times   = max(times_vector);
    
    for t=1:len
        tw = ca_intervals{t};
        if tw(1) < min_times
            disp(['ERROR: minimum of design times window ' num2str(t) ' (' num2str(tw(1)) ') is lower than investigated time (' num2str(min_times) ')']);
            res = 0;
            return;
        elseif tw(2) > max_times
            disp(['ERROR: maximum of design times window ' num2str(t) ' (' num2str(tw(2)) ') is higher than investigated time (' num2str(max_times) ')']);
            res = 0;
            return;
        end
    end
    res = 1;
end