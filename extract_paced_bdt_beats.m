function [beat_num_array, cycle_length_array, activation_time_array, activation_point_array, beat_start_times, beat_periods, t_wave_peak_times, t_wave_peak_array, max_depol_time_array, min_depol_time_array, max_depol_point_array, min_depol_point_array, depol_slope_array] = extract_paced_bdt_beats(wellID, time, data, bdt, spon_paced, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, stable_ave_analysis, average_waveform_time1, average_waveform_time2, plot_ave_dir, electrode_id, t_wave_shape, t_wave_duration, Stims, post_spike_hold_off, stim_spike_hold_off, est_peak_time, est_fpd, min_bp, max_bp)

    if strcmpi(beat_to_beat, 'on')
        disp(electrode_id);
        if strcmp(analyse_all_b2b, 'time_region')
            time_region_indx = find(time >= b2b_time_region1 & time <= b2b_time_region2);
            time = time(time_region_indx);
            data = data(time_region_indx);
            
            Stim_indx = find(Stims >= b2b_time_region1 & Stims <= b2b_time_region2);
            Stims = Stims(Stim_indx);
            
        end
    else
        if strcmp(stable_ave_analysis, 'time_region')
            time_region_indx = find(time >= average_waveform_time1 & time <= average_waveform_time2);
            time = time(time_region_indx);
            data = data(time_region_indx);
            
            Stim_indx = find(Stims >= b2b_time_region1 & Stims <= b2b_time_region2);
            Stims = Stims(Stim_indx);
        end
    end
    total_duration = time(end);
    
    prev_beat_indx = 1;
    beat_indx = 1;
    
    %max_beat_period = max_bp;
    %max_beat_period = 17;  %seconds
    %min_beat_period = min_bp;  %seconds
    %post_spike_hold_off = 0.2;   %seconds
    %stim_spike_hold_off = post_spike_hold_off;
    window = 5;
    
    activation_time_array = [];
    beat_num_array = [];
    cycle_length_array = [];
    beat_start_times = [];
    beat_end_times = [];
    beat_periods = [];
    t_wave_peak_times = [];
    t_wave_peak_array = [];
    max_depol_time_array = [];
    min_depol_time_array = [];
    max_depol_point_array = [];
    min_depol_point_array = [];
    activation_point_array = [];
    depol_slope_array = [];
   
    
    count = 0;
    t = 0;
    prev_activation_time = 0;
    %for t = 0:window:total_duration
    fail_beat_detection = 0;
    
    disp(Stims);
    %pause(20);
    
    %{
    if strcmp(beat_to_beat, 'on')
        figure();
        hold on;
    end
    %}
    count = 0;
    prev_stim_time = Stims(1);
    prev_activation_time = 0;
    for i = 2:length(Stims)
        if i < length(Stims) 
            stim_time = Stims(i)+0.1;
        else
            stim_time = Stims(i);
        end
        
        beat_time = time(find(time >= prev_stim_time & time <= stim_time));
        beat_data = data(find(time >= prev_stim_time & time <= stim_time));
       
        %beat_period = beat_time(end) - beat_time(1);
       
        %[activation_time, amplitude, max_depol_time, max_depol_point, min_depol_time, min_depol_point, slope] = rate_analysis(beat_time, beat_data, post_spike_hold_off, stim_spike_hold_off, spon_paced, prev_stim_time, electrode_id);
        
        [beat_num, cycle_length, activation_time, activation_point, beat_starts, beat_ps, t_wave_peak_ts, t_wave_peaks, max_depol_times, min_depol_times, max_depol_points, min_depol_points, depol_slope] = paced_bdt_beats(wellID, beat_time, beat_data, bdt, spon_paced, beat_to_beat, analyse_all_b2b, beat_time(1), beat_time(end), stable_ave_analysis, beat_time(1), beat_time(end), plot_ave_dir, electrode_id, t_wave_shape, t_wave_duration, Stims, min_bp, max_bp, post_spike_hold_off, est_peak_time, est_fpd, stim_spike_hold_off, prev_activation_time);
        %disp('stim analysed')
        count
        %{
        if isempty(beat_num)
            continue;
        end
        %}
        beat_num = beat_num+count
        count = count+length(beat_num)-1
        prev_activation_time = activation_time(end);
        %{
        if strcmp(beat_to_beat, 'on')
            [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(beat_time, beat_data, beat_to_beat, activation_time, count, spon_paced, t_wave_shape, NaN, t_wave_duration, post_spike_hold_off, est_peak_time, est_fpd, electrode_id);
            
            disp('t_wave')
            disp(count);
            disp(t_wave_peak_time)
            %if count == 0
                %figure();
            %end


            %hold off;
            %{
            plot(beat_time, beat_data);
            plot(t_wave_peak_time, t_wave_peak, 'yo');
            max_depol = beat_data(beat_time == max_depol_time);
            min_depol = beat_data(beat_time == min_depol_time);
            act_point = beat_data(beat_time == activation_time);
            plot(max_depol_time, max_depol, 'go');
            plot(min_depol_time, min_depol, 'bo');
            plot(activation_time, act_point, 'ro');
            %}
            
            t_wave_peak_times = [t_wave_peak_times; t_wave_peak_time];
            t_wave_peak_array = [t_wave_peak_array; t_wave_peak];
            %hold off;
        end
        
        %pause(10)
        act_point = beat_data(beat_time == activation_time);
        %}
        
        activation_point_array = [activation_point_array activation_point];
        activation_time_array = [activation_time_array activation_time];
        cycle_length_array = [cycle_length_array cycle_length];
        beat_num_array = [beat_num_array beat_num];
        beat_start_times = [beat_start_times beat_starts];
        %beat_end_times = [beat_end_times; beat_ends];
        beat_periods = [beat_periods beat_ps]; 
        
        max_depol_time_array = [max_depol_time_array max_depol_times];
        min_depol_time_array = [min_depol_time_array min_depol_times];
        max_depol_point_array = [max_depol_point_array max_depol_points];
        min_depol_point_array = [min_depol_point_array min_depol_points];
        depol_slope_array = [depol_slope_array depol_slope];
        t_wave_peak_times = [t_wave_peak_times t_wave_peak_ts];
        t_wave_peak_array = [t_wave_peak_array t_wave_peaks];

        %prev_activation_time = activation_time;
        %prev_beat_indx = beat_indx;
       
        prev_stim_time = Stims(i);
        count = count + 1;
        t = t + window;
    end
    disp(strcat('Total Duration = ', {' '}, string(total_duration)))
    disp(count);
    %hold off;
    
    %{
    if strcmpi(beat_to_beat, 'on')
        for i = 2:length(activation_time_array)
            disp(strcat('Beat no. ', num2str(i)))
            if i == 2
                %figure();
                %plot(time, data);
                %title('First b2b extracted beat');
                %t_wave_peak_seed = input('On inpection of the first 4 extracted beats please enter the time point to use as the estimated peak of the T-wave complex:\n');
                %t_wave_search_ratio = input('What duration of the waveforms seem to be dominated by the T-wave complex?:\n');
                figure();
            end
            beat_start = beat_start_times(i);
            %disp(length(beat_start));
            %disp(beat_start)
            %if i == length(activation_time_array)
            %    beat_end = time(end);
            %else
            beat_end = beat_end_times(i);
            %end
            beat_data = data(time >= beat_start & time <= beat_end);
            time_data = time(time >= beat_start & time <= beat_end);
            
            
            %[activation_time, amplitude, max_depol_time, min_depol_time] = rate_analysis(time_data, beat_data, post_spike_hold_off, stim_spike_hold_off, spon_paced, stim_time);
            activation_time = activation_time_array(i);
            t_wave_peak_time = t_wave_peak_times(i);
            t_wave_peak = t_wave_peak_array(i);
            max_depol_time = max_depol_time_array(i);
            min_depol_time = min_depol_time_array(i);
            max_depol = max_depol_point_array(i);
            min_depol = min_depol_point_array(i);
            
            %[t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(time_data, beat_data, beat_to_beat, activation_time_array(i), i, spon_paced, t_wave_shape, NaN, t_wave_duration, post_spike_hold_off);
            
            %figure();
            %disp(FPD)
            %subplot(ceil(length(beat_start_times)/4), 4, i-1);
            plot(time_data, beat_data);
            hold on;
            %peak_indx = find(beat_data == t_wave_peak);
            %t_wave_peak_time = time_data(peak_indx(1));
            plot(t_wave_peak_time, t_wave_peak, 'ro');
            
            act_point = beat_data(time_data == activation_time);
            plot(max_depol_time, max_depol, 'go');
            plot(min_depol_time, min_depol, 'bo');
            plot(activation_time, act_point, 'ro');
            title(strcat('t-wave peak marked for electrode ', electrode_id));
            
            disp(strcat('FPD = ', num2str(FPD(1))));
            disp(strcat('Depol amplitude = ', num2str(amplitude)))
            
            %hold off;
            %pause(15);


        end
       
    end
    
    
    figure();
    plot(beat_num_array, cycle_length_array, 'bo');
    xlabel('Beat Number');
    ylabel('Cycle Length (s)');
    title(strcat('Cycle Length per Beat', {' '}, electrode_id));
    hold off;

    figure();
    plot(beat_num_array, beat_periods, 'bo');
    xlabel('Beat Number');
    ylabel('Beat Period (s)');
    title(strcat('Beat Period per Beat', {' '}, electrode_id));
    hold off;

    figure();
    plot(cycle_length_array(1:end-1), cycle_length_array(2:end), 'bo');
    xlabel('Cycle Length Previous Beat (s)');
    ylabel('Cycle Length (s)');
    title(strcat('Cycle Length vs Previous Beat Cycle Length', {' '}, electrode_id));
    hold off;
    %pause(30);
    
    %}
    

end

