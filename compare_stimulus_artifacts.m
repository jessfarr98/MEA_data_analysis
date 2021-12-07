function compare_stimulus_artifacts(raw_file, art_elim_file, directory)

    RawFileData = AxisFile(raw_file);
    
    ArtElimFileData = AxisFile(art_elim_file);
    
    RawData = RawFileData.DataSets.LoadData;

    ArtElimData = ArtElimFileData.DataSets.LoadData;
    
    RawStims = sort([RawFileData.StimulationEvents(:).EventTime]);
    AEStims = sort([ArtElimFileData.StimulationEvents(:).EventTime]);
    disp(RawStims)    

    shape_data = size(RawData);
    
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);
    
    
    num_well_rows = 1;
    num_well_cols = 2;
    num_electrode_rows = 4;
    num_electrode_cols = 4;
    
    count = 1;
    well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    
    %mkdir(fullfile('Compare Stimulus Eliminated', 'Compare paced paced SP 600us(001))'))
    %mkdir(fullfile('Compare Stimulus Eliminated', directory))
    
    for w_r = 1:num_well_rows
        for w_c = 2:num_well_cols
           wellID = strcat(well_dictionary(w_r), '_0', string(w_c));
           disp(wellID)
           for e_r = 1:num_electrode_rows
              for e_c = 1:num_electrode_cols
                 %if (e_r == 2 && e_c == 3 && w_r == 1 && w_c == 7)
                     
                     RawWellData = RawData{w_r, w_c, e_r, e_c};
                     ArtElimWellData = ArtElimData{w_r, w_c, e_r, e_c};
                     
                     %RawStimData = RawStims{w_r, w_c, e_r, e_c};
                     %AEStimData = AEStims{w_r, w_c, e_r, e_c};
                     
                     %disp(RawStimData);
                     if (strcmp(class(RawWellData),'Waveform') && strcmp(class(ArtElimWellData),'Waveform'))
                         %if ~empty(WellRawData)
                         disp('raw type')
                         disp(class(RawWellData))
                         disp('art elim type')
                         disp(class(ArtElimWellData))
                         electrode_id = strcat(wellID, '_', string(e_r), '_', string(e_c));
                         disp(electrode_id)
                         [raw_time, raw_data] = RawWellData.GetTimeVoltageVector;
                         [AE_time, AE_data] = ArtElimWellData.GetTimeVoltageVector;
                         
                         

                         len = length(raw_time);
                         plot_ratio = floor(len/10);



                         fig = figure();
                         %set(fig ,'Visible', 'off');
                         plot(raw_time, raw_data);
                         hold on;
                         plot(AE_time, AE_data);
                         xlabel('Time');
                         ylabel('Voltage');
                         title(strcat(directory, {' '}, 'Plot of Extracted Data-sets'));
                         legend('raw', 'artifact eliminated')
                         %print(fullfile('Compare Stimulus Eliminated', 'Compare paced paced SP 600us(001))', electrode_id), '-dbitmap', '-r0');
                         hold off;


                         bdt = 1.2e-3;
                         [raw_beat_num_array, raw_cycle_length_array, raw_activation_time_array, raw_beat_start_times, raw_beat_periods, raw_depol_array, raw_FPD_array, raw_T_wave_times] = extract_beats(wellID, raw_time, raw_data, bdt, 'paced', 'on', 'all', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', electrode_id, RawStims);
                         %[AE_beat_num_array, AE_cycle_length_array, AE_activation_time_array, AE_beat_start_times, AE_beat_periods, AE_depol_array, AE_FPD_array, AE_T_wave_times] = extract_beats(wellID, AE_time, AE_data, bdt, 'paced', 'on', 'all', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', electrode_id, AEStims);

                         %compare_raw_elim_beats(raw_data, raw_time, AE_data, AE_time, raw_beat_num_array, raw_cycle_length_array, raw_activation_time_array, raw_beat_start_times, raw_beat_periods, raw_depol_array, raw_FPD_array, raw_T_wave_times, RawStims, AE_beat_num_array, AE_cycle_length_array, AE_activation_time_array, AE_beat_start_times, AE_beat_periods, AE_depol_array, AE_FPD_array, AE_T_wave_times, AEStims, fullfile('Compare Stimulus Eliminated', 'Compare paced paced SP 600us(001))', electrode_id), directory, electrode_id)
                         compare_raw_elim_beats(raw_data, raw_time, [], [], raw_beat_num_array, raw_cycle_length_array, raw_activation_time_array, raw_beat_start_times, raw_beat_periods, raw_depol_array, raw_FPD_array, raw_T_wave_times, RawStims, [], [], [], [], [], [], [], [], [], fullfile('Compare Stimulus Eliminated', 'Compare paced paced SP 600us(001))', electrode_id), directory, electrode_id)
        


                         %pause(20)
                         count = count + 1;
                     %end
                 end
              end
           end
        end
    end



end

function compare_raw_elim_beats(raw_data, raw_time, AE_data, AE_time, raw_beat_num_array, raw_cycle_length_array, raw_activation_time_array, raw_beat_start_times, raw_beat_periods, raw_depol_array, raw_FPD_array, raw_T_wave_times, RawStims, AE_beat_num_array, AE_cycle_length_array, AE_activation_time_array, AE_beat_start_times, AE_beat_periods, AE_depol_array, AE_FPD_array, AE_T_wave_times, AEStims, save_plot, protocol, electrode_id)
    
    num_raw_beats = length(raw_beat_num_array);
    num_AE_beats = length(AE_beat_num_array);
    
    disp(num_raw_beats)
    disp(num_AE_beats)
    disp(length(raw_cycle_length_array))
    disp(length(AE_cycle_length_array))
    
    disp(length(raw_FPD_array))
    disp(length(AE_FPD_array))
    
    %go through longest set of 
    
    %{
    figure();
    plot(raw_cycle_length_array(1:num_AE_beats), AE_cycle_length_array, 'o')
    title('AE vs raw')
    %}
    
    figure();
    plot(raw_beat_num_array, raw_activation_time_array, 'bo');
    %hold on;
    %plot(AE_beat_num_array, AE_activation_time_array, 'ro');
    title(strcat('Activation Times per num beats for ', {' '}, protocol, {' '}, electrode_id))
    %legend('raw', 'artifact eliminated')
    %hold off;
    
    %{
    figure();
    plot(raw_beat_num_array, raw_beat_periods, 'bo');
    hold on;
    plot(AE_beat_num_array, AE_beat_periods, 'ro');
    title(strcat('Beat Start Times per num beats for ', {' '}, protocol, {' '}, electrode_id))
    legend('raw', 'artifact eliminated')
    hold off;
    
    figure();
    plot(linspace(1, length(raw_T_wave_times), length(raw_T_wave_times)), raw_T_wave_times, 'bo');
    hold on;
    plot(linspace(1, length(AE_T_wave_times), length(AE_T_wave_times)), AE_T_wave_times, 'ro');
    title(strcat('T-wave peak time per num beats for ', {' '}, protocol, {' '}, electrode_id))
    legend('raw', 'artifact eliminated')
    hold off;

    figure();
    plot(linspace(1, length(raw_FPD_array), length(raw_FPD_array)), raw_FPD_array, 'bo');
    hold on;
    plot(linspace(1, length(AE_FPD_array), length(AE_FPD_array)), AE_FPD_array, 'ro');
    title(strcat('FPD per num beats for ', {' '}, protocol, {' '}, electrode_id))
    legend('raw', 'artifact eliminated')
    hold off;
    
    figure();
    plot(raw_beat_num_array, raw_depol_array, 'bo');
    hold on;
    plot(AE_beat_num_array, AE_depol_array, 'ro');
    title(strcat('Depol. Spike Amplitudes per num beats for ', {' '}, protocol, {' '}, electrode_id))
    legend('raw', 'artifact eliminated')
    hold off;
    
    %}
    
    
    figure();
    %prev_beat_time = raw_activation_time_array(1);
    prev_beat_time = raw_beat_start_times(1);
    for raw_beat = 2:num_raw_beats
        act_time = raw_activation_time_array(raw_beat);
        act_signal = raw_data(find(raw_time == act_time));
        beat_time = raw_beat_start_times(raw_beat);
        %disp()
        plot_stim = 1;
        try
            beat_stim_time = RawStims(raw_beat);
            beat_data = raw_data(find(raw_time == prev_beat_time): find(raw_time == beat_time));
            base_line_voltage = beat_data(1);
        catch
            plot_stim = 0;
        end
        raw_plots = plot(raw_time(find(raw_time == prev_beat_time):find(raw_time == beat_time)), raw_data(find(raw_time == prev_beat_time): find(raw_time == beat_time)), 'r');
        hold on;
        plot(act_time, act_signal, 'ro')
        %{
        if plot_stim == 1
           plot(beat_stim_time, base_line_voltage, 'ko'); 
        end
        %}
        prev_beat_time = beat_time;            
    end
    
    %legend('raw')

    % offset the AE times so start at first raw activation time
    %{
    prev_beat_time = AE_beat_start_times(1);
    %AE_time = AE_time + raw_activation_time_array(2);

    %prev_beat_time = AE_activation_time_array(1);
    for AE_beat = 2:num_AE_beats
        beat_time = AE_beat_start_times(AE_beat);
        orig_act_time = AE_activation_time_array(AE_beat);
        act_signal = AE_data(find(AE_time == orig_act_time));
        %act_time = act_time + (raw_beat_start_times(2)-AE_beat_start_times(2));
        %act_time = act_time +(raw_beat_start_times(AE_beat)-AE_beat_start_times(AE_beat));
        act_time = orig_act_time +(raw_activation_time_array(AE_beat)-AE_activation_time_array(AE_beat));
        plot_stim = 1;
        try
            beat_stim_time = AEStims(AE_beat)+(raw_activation_time_array(AE_beat)-AE_activation_time_array(AE_beat));
            beat_data = AE_data(find(AE_time == prev_beat_time): find(AE_time == beat_time));
            base_line_voltage = beat_data(1);
        catch
            plot_stim = 0;
        end
       
        %plot_AE_time = AE_time(find(AE_time == prev_beat_time):find(AE_time == beat_time));
        plot_AE_time = AE_time(find(AE_time == prev_beat_time):find(AE_time == beat_time)) + (raw_activation_time_array(AE_beat)-AE_activation_time_array(AE_beat));
        %plot_AE_data = AE_data(find(AE_time == prev_beat_time):find(AE_time == beat_time)) + (raw_activation_time_array(AE_beat)-AE_activation_time_array(AE_beat));
        %act_time = plot_AE_time(find(plot_AE_data == act_signal));
        %act_time = act_time(1);
        
        %act_signal = plot_AE_data(find(plot_AE_time == act_time));
        %plot_AE_time = AE_time(find(AE_time == prev_beat_time):find(AE_time == beat_time)) + (raw_beat_start_times(AE_beat)-AE_beat_start_times(AE_beat));
        AE_plots = plot(plot_AE_time, AE_data(find(AE_time == prev_beat_time): find(AE_time == beat_time)), 'b');
        hold on;
        plot(act_time, act_signal, 'bo')
        %{
        if plot_stim == 1
            plot(beat_stim_time, base_line_voltage, 'go')
        end
        %}
        %pause(10);
        
        prev_beat_time = beat_time;            
    end
    
    legend([raw_plots, AE_plots], 'raw', 'artifact eliminated')
    %}
    title(strcat(electrode_id, {' '}, 'Aligned signals for extracted beat start times for raw vs artifact eliminated', {' '}, protocol))
    %legend('raw', 'artifact eliminated');
    %print(save_plot, '-dbitmap', '-r0');
    hold off;
        
        
        
    
    %{
    start
    for raw_beats = 1:num_raw_beats
        
        
    end
    
    if num_raw_beats > num_AE_beats
        for beat = 1:num_AE_beats
            if raw_cycle_length_array(beat) > AE_cycle_length_array(beat)
                
                
            else
                
                
            end
            
        end
        
    end
    
    %}
   



end

function [beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods, depol_array, FPD_array, T_wave_peak_times] = extract_beats(wellID, time, data, bdt, spon_paced, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, stable_ave_analysis, average_waveform_time1, average_waveform_time2, plot_ave_dir, electrode_id, stim_times)

    if strcmpi(beat_to_beat, 'on')
        disp(electrode_id);
        if strcmp(analyse_all_b2b, 'time_region')
            time_region_indx = find(time >= b2b_time_region1 & time <= b2b_time_region2);
            time = time(time_region_indx);
            data = data(time_region_indx);
            
        end
    else
        if strcmp(stable_ave_analysis, 'time_region')
            time_region_indx = find(time >= average_waveform_time1 & time <= average_waveform_time2);
            time = time(time_region_indx);
            data = data(time_region_indx);
        end
    end
    total_duration = time(end);
    
    prev_beat_indx = 1;
    beat_indx = 1;
    
    max_beat_period = 4;
    %max_beat_period = 17;  %seconds
    min_beat_period = 0.2;  %seconds
    post_spike_hold_off = 0.1;   %seconds
    stim_spike_hold_off = 0.002;
    window = 1;
    
    activation_time_array = [];
    beat_num_array = [];
    cycle_length_array = [];
    beat_start_times = [];
    beat_end_times = [];
    beat_periods = [];
    depol_array = [];
    FPD_array = [];
    T_wave_peak_times = [];
    
    count = 0;
    t = 0;
    prev_activation_time = 0;
    %for t = 0:window:total_duration
    fail_beat_detection = 0;
    while(1)
       %disp(t+window)
       %Use the beat detection threshold to determine the regions that need
       %to be analysed
       
       if (time(prev_beat_indx)+window) > total_duration
           break;
       end           
           
       %Take segments of data from each window to search for the next beat 
       if beat_indx == 1
       %if t == 0
           wind_indx = find(time >= 0 & time <= total_duration);  
          %wind_indx = find(time >= 0 & time <= window);  
          %wind_indx = find(time >= t & time <= t+window);
       else
          wind_indx = find(time >= time(prev_beat_indx) & time <= total_duration); 
          %wind_indx = find(time >= time(prev_beat_indx) & time <= (time(prev_beat_indx)+window)); 
          %wind_indx = find(time >= t & time <= t+window);
       end
       
       t_ime = time(wind_indx);
       d_ata = data(wind_indx);

       try 
           post_spike_hold_off_time = t_ime(1)+post_spike_hold_off;
           pshot_indx = find(t_ime >= post_spike_hold_off_time);
           pshot_indx_offset = pshot_indx(1);
                      
           beat_indx = find(d_ata(pshot_indx) >= bdt);
           beat_indx = beat_indx(1)+wind_indx(1)-1+pshot_indx_offset;

       catch
           %Update the beat detection threshold
           bdt = bdt*0.8;
           if isalmost(bdt, 0, 1E-10)
               disp('end of recording')
               break
           end
           
           % If fails on the first iteration, set the beat index to be back to the first point
           if prev_beat_indx == 1
               beat_indx = 1;
           else
               beat_indx = prev_beat_indx;
           end
           %{
           threshold_data = zeros(size(time(prev_beat_indx:end)));
           threshold_data(:) = bdt;
           disp('fail beat detection, continue')
           figure();
           plot(time(prev_beat_indx:end), data(prev_beat_indx:end));
           hold on;
           plot(time(prev_beat_indx:end), threshold_data);
           hold off;
           %pause(10)
           %}
           t = t - window;
           continue;
       end
       
       %% Between 10 and 12 seconds 2 beats are being picked up as one
       
       beat_time = time(prev_beat_indx:beat_indx);
       beat_data = data(prev_beat_indx:beat_indx);
       
       %% Trim and then scale and set back to time zero for each beat
       %% Start small degrees of freedom [1-100], polyfits keep trying and do a survey of error plots, do the optimisation curve thing minimised error analysis 
       %% Try training and test sets too. Separate the whole datasets so use 80% of the beat signals as the 20%
       
       try
          beat_period = beat_time(end) - beat_time(1);
       catch
          beat_indx = prev_beat_indx;
          continue;
       end
       
       disp(strcat('Beat period = ', num2str(beat_period)));
       disp(strcat('Beat start time = ', num2str(beat_time(1))));
       disp(strcat('Beat end time = ', num2str(beat_time(end))));
       
       if beat_period > max_beat_period
       %Check there is only one beat period.
          disp('bdt has been reduced due to beat period being too long')
          disp(bdt)
          
          %if prev_beat_indx ~= 1
          beat_indx = prev_beat_indx;
          bdt = bdt/2;
          %window = window*1.5;
          if beat_time(end)+window > total_duration
               break;
          end
          if isalmost(bdt, 0, 1E-5)
             disp('end of recording')
             break
          end
          %else
              %prev_beat_indx = beat_indx;
              %prev_beat_indx = 1
          %end
          t = t - window;
          continue;
       end
       
       if beat_period < min_beat_period
           fail_beat_detection = fail_beat_detection+1;
           
           if fail_beat_detection >= 10
               break;
           end
           disp('bdt has been increased due to beat period being too short')
           
           disp(bdt)
           disp(fail_beat_detection)
           %{
           threshold_data = zeros(size(beat_time));
           threshold_data(:) = bdt;
           figure();
           plot(beat_time, beat_data);
           hold on;
           plot(beat_time, threshold_data);
           xlabel('Time (secs)')
           ylabel('Voltage (V)')
           title('Extracted Beat');
           pause(3)
           %}
           if prev_beat_indx ~= 1
               beat_indx = prev_beat_indx;
               bdt = bdt*5;
               
               disp(beat_time(end))
               disp(window)
               disp(total_duration)
               if beat_time(end)+window > total_duration
                   break;
               end
           else
               %Generally the first bit of the recording is short so assume this is time 0
               prev_beat_indx = beat_indx;
           end
           t = t - window;
           continue;
       end
       fail_beat_detection = 0;
       
       if count == 0
          stim_time = 0;
       elseif count > length(stim_times)
           stim_time = beat_time(1);
       else
          stim_time = stim_times(count);
       end
       [activation_time, amplitude, max_depol_time, min_depol_time] = rate_analysis(beat_time, beat_data, post_spike_hold_off, stim_spike_hold_off, spon_paced, stim_time);
       
       activation_time_array = [activation_time_array; activation_time];
       cycle_length_array = [cycle_length_array; (activation_time-prev_activation_time)];
       beat_num_array = [beat_num_array; count];
       beat_start_times = [beat_start_times; beat_time(1)];
       beat_end_times = [beat_end_times; beat_time(end)];
       beat_periods = [beat_periods; beat_period];
       depol_array = [depol_array; amplitude];
       
       %{
       if strcmp(beat_to_beat, 'on')
          
           if count == 1
               figure();
               hold on;
               plot(beat_time, beat_data)
               %[t_wave_peak, ~] = t_wave_complex_analysis(beat_time, beat_data, beat_to_beat, activation_time, count, spon_paced);
               %FPD = t_wave_peak - activation_time;
               %disp(strcat('FPD = ', num2str(FPD)));
           elseif count >=1 && count < 4
               %FPD = (t_wave_peak+beat_time(1)) - activation_time;
               %disp(strcat('FPD = ', num2str(FPD)));
               plot(beat_time, beat_data)
           elseif count == 4
               plot(beat_time, beat_data)
               title('first 4 extracted beats')
               hold off;
           
               
               while(1)
                   mono_up_down = 'down';
                   %mono_up_down = input('Would you characterise the T-waves for this well as monophasic upwards or downwards?: (up,down)\n', 's');
                   if strcmpi(mono_up_down, 'up')
                       break;
                   elseif strcmpi(mono_up_down, 'down')
                       break;
                   end
               end
           end
       end
       %}
       mono_up_down = 'down';
       %pause(3);
       
       %{
       threshold_data = zeros(size(beat_time));
       threshold_data(:) = bdt;
       
       figure();
       plot(beat_time, beat_data);
       hold on;
       plot(beat_time, threshold_data);
       xlabel('Time (secs)')
       ylabel('Voltage (V)')
       title('Extracted Beat');
       pause(5);
       %}
             

       prev_activation_time = activation_time;
       prev_beat_indx = beat_indx;
       count = count + 1;
       t = t + window;
    end
    disp(strcat('Total Duration = ', {' '}, string(total_duration)))
    disp(count);
    
    
    if strcmpi(beat_to_beat, 'on')
        for i = 2:length(activation_time_array)
            disp(strcat('Beat no. ', num2str(i)))
            if i == 2
                %figure();
                %plot(time, data);
                %title('First b2b extracted beat');
                %t_wave_peak_seed = input('On inpection of the first 4 extracted beats please enter the time point to use as the estimated peak of the T-wave complex:\n');
                %t_wave_search_ratio = input('What duration of the waveforms seem to be dominated by the T-wave complex?:\n');
                t_wave_search_ratio = 0.2;
                %figure();
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
            if count == 0
               stim_time = 0;
            elseif count > length(stim_times)
               stim_time = beat_time(1);
            else
               stim_time = stim_times(i);
            end
            [activation_time, amplitude, max_depol_time, min_depol_time] = rate_analysis(time_data, beat_data, post_spike_hold_off, stim_spike_hold_off, spon_paced, stim_time);
       
            [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(time_data, beat_data, beat_to_beat, activation_time_array(i), i, spon_paced, mono_up_down, NaN, t_wave_search_ratio, post_spike_hold_off);
            FPD_array = [FPD_array; FPD];
            T_wave_peak_times = [T_wave_peak_times; t_wave_peak_time];
            
            %{
            %figure();
            %disp(FPD)
            %subplot(ceil(length(beat_start_times)/4), 4, i-1);
            plot(time_data, beat_data);
            hold on;
            %peak_indx = find(beat_data == t_wave_peak);
            %t_wave_peak_time = time_data(peak_indx(1));
            plot(t_wave_peak_time, t_wave_peak, 'ro');
            max_depol = beat_data(time_data == max_depol_time);
            %disp(min_depol_time)
            min_depol = beat_data(time_data == min_depol_time);
            act_point = beat_data(time_data == activation_time);
            plot(max_depol_time, max_depol, 'ro');
            plot(min_depol_time, min_depol, 'ro');
            plot(activation_time, act_point, 'ro');
            title(strcat('t-wave peak marked for electrode ', electrode_id));
            %}
            disp(strcat('FPD = ', num2str(FPD(1))));
            disp(strcat('Depol amplitude = ', num2str(amplitude)))
            
            %hold off;
            %pause(15);


        end
       
    end
    
    %{
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
    
    %Find most stable beat periods
    
end

function [activation_time, amplitude, max_depol_time, min_depol_time] = rate_analysis(time, data, post_spike_hold_off, stim_spike_hold_off, spon_paced, stim_time)

    % propagation maps:
    % sort the first act time per electrode per well and then calc
    % delta_time between each 
    % Can use diff prop patterns - see statistic compiler. Some are more
    % common than others. Not default, need to be turned on. 

    post_spike_hold_off_time = time(1)+post_spike_hold_off;
    pshot_indx = find(time >= post_spike_hold_off_time);
    pshot_indx_offset = pshot_indx(1);
    disp('start')
    disp(time(1))
    disp('end')
    disp(time(end))
    disp('stim')
    disp(stim_time)
    if strcmp(spon_paced, 'spon')
        depol_complex_time = time(1:pshot_indx_offset);
        depol_complex_data = data(1:pshot_indx_offset);
    elseif strcmp(spon_paced, 'paced')
        start_time_indx = find(time >= stim_time+stim_spike_hold_off);
        try
            depol_complex_time = time(start_time_indx(1):pshot_indx_offset);
            depol_complex_data = data(start_time_indx(1):pshot_indx_offset);
            disp('length')
            disp(length(depol_complex_time))
            if length(depol_complex_time) < 1
                disp('need all data for max dv/dt')
                depol_complex_time = time;
                depol_complex_data = data;
            end
        catch 
            disp('catch')
            depol_complex_time = time(1:pshot_indx_offset);
            depol_complex_data = data(1:pshot_indx_offset);
            disp('length')
            disp(length(depol_complex_time))
            if length(depol_complex_time) < 1
                disp('need all data for max dv/dt')
                depol_complex_time = time;
                depol_complex_data = data;
            end
        end
        
    end
    depol_complex_data_derivative = gradient(depol_complex_data);
    %depol_complex_data_derivative = gradient(depol_complex_data_derivative);
    
    activation_time_indx = find(depol_complex_data_derivative == min(depol_complex_data_derivative));
    
    max_depol_point = max(depol_complex_data);
    max_depol_time = time(find(depol_complex_data == max_depol_point));
    
    min_depol_point = min(depol_complex_data);
    min_depol_time = time(find(depol_complex_data == min_depol_point));
    
    
    if length(min_depol_time) > 1
        min_depol_time = min_depol_time(1);
        
    end
    if length(max_depol_time) > 1
        max_depol_time = max_depol_time(1);
        
    end
    
    amplitude = max_depol_time - min_depol_time;
    
    %% To further refine the region to isolate the depol complex, perfrom std analysis
    
    try
        activation_time = depol_complex_time(activation_time_indx(1));
    catch
        %disp(time)
        %disp(depol_complex_time)
        error('wtf')
    end
    
    %{
    figure()
    hold on;
    plot(depol_complex_time, depol_complex_data);
    %plot(depol_complex_time, depol_complex_data_derivative);
    plot(max_depol_time, max_depol_point, 'ro');
    plot(min_depol_time, min_depol_point, 'ro');
    plot(depol_complex_time(activation_time_indx(1)), depol_complex_data(activation_time_indx(1)), 'ro')
    xlabel('Time (secs)')
    ylabel('Voltage (V)')
    title('Extracted Depol. Complex');
    hold off;
    %pause(5);
    %}
    
    
    
    %% TO DO calculate max amplitude
    
   
end

function [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(time, data, beat_to_beat, activation_time, beat_no, spon_paced, mono_up_down, t_wave_peak, t_wave_search_duration, post_spike_holdoff)
    
    if strcmpi(beat_to_beat, 'off')
        t_wave_peak_time = input('On inpection of the waveform please enter the time point to use as the peak of the T-wave complex (seconds):\n');
        t_wave_peak = data(time == t_wave_peak_time);
    else
        %{
        %if strcmp(spon_paced, 'paced')
            if beat_no == 1
                %figure();
                %plot(time, data);
                %title('First b2b extracted beat');
                t_wave_peak = input('On inpection of the first 4 extracted beats please enter the time point to use as the estimated peak of the T-wave complex:\n');
            end
        %elseif strcmp(spon_paced, 'spon')
            %disp('beat to beat spontaneous data requires automated T-wave analysis')
            %t_wave_peak = NaN;
            %return;
        %end
        %}
        %t_wave_search_duration = (time(end)-time(1))*t_wave_search_ratio;
        if strcmp(mono_up_down, 'up')
            t_wave_indx = find(time >= time(1)+post_spike_holdoff & time <= time(1)+post_spike_holdoff+(t_wave_search_duration));
            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);
            t_wave_peak = max(t_wave_data);
            t_wave_peak_time = t_wave_time(t_wave_data == t_wave_peak);
        elseif strcmp(mono_up_down, 'down')            
            t_wave_indx = find(time >= time(1)+post_spike_holdoff & time <= time(1)+post_spike_holdoff+(t_wave_search_duration));
            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);
            t_wave_peak = min(t_wave_data);
            t_wave_peak_time = t_wave_time(t_wave_data == t_wave_peak);
            %t_wave_peak = t_wave_peak(1);
        end  
    end
    
    %disp(activation_time)
    %disp(t_wave_peak_time)
    FPD = t_wave_peak_time - activation_time;
    


end