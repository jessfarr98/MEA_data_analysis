function [beat_num_array, cycle_length_array, activation_time_array, activation_point_array, beat_start_times, beat_start_volts, beat_periods, t_wave_peak_times, t_wave_peak_array, max_depol_time_array, min_depol_time_array, max_depol_point_array, min_depol_point_array, depol_slope_array, warning_array, filtered_time, filtered_data, t_wave_wavelet_array, t_wave_polynomial_degree_array] = extract_selected_spon_beats(wellID, time, data, bdt, spon_paced, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, stable_ave_analysis, average_waveform_time1, average_waveform_time2, plot_ave_dir, electrode_id, t_wave_shape, t_wave_duration, Stims, min_bp, max_bp, post_spike_hold_off, est_peak_time, est_fpd, filter_intensity, negative_skip, reanalysed_post_spike)

    
    %{
    if ~isnan(reanalysed_post_spike)
        new_start_indx = find(time >= time(1)+reanalysed_post_spike);
        new_start_indx = new_start_indx(1);
        time = time(new_start_indx:end);
        data = data(new_start_indx:end);
        
        
    end
    %}
    if strcmpi(beat_to_beat, 'on')
        %%disp(electrode_id);
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
    
    max_beat_period = max_bp;
    %max_beat_period = 17;  %seconds
    min_beat_period = min_bp;  %seconds
    %post_spike_hold_off = 0.1;   %seconds
    stim_spike_hold_off = 0.002;
    %window = 5;
    window = min_bp;
    
    activation_time_array = [];
    beat_num_array = [];
    cycle_length_array = [];
    beat_start_times = [];
    beat_end_times = [];
    beat_periods = [];
    t_wave_peak_times = [];
    beat_start_volts= [];
    t_wave_peak_array = [];
    max_depol_time_array = [];
    min_depol_time_array = [];
    max_depol_point_array = [];
    min_depol_point_array = [];
    activation_point_array = [];
    depol_slope_array = [];
    warning_array = [];
    filtered_time = [];
    filtered_data  = [];
    t_wave_wavelet_array = [];
    t_wave_polynomial_degree_array = [];
    
   
    
    count = 0;
    t = 0;
    prev_activation_time = 0;
    %for t = 0:window:total_duration
    fail_beat_detection = 0;
    
    %%%disp(Stims);
    %pause(20);
    orig_post_spike_hold_off = post_spike_hold_off;
    orig_est_peak_time = est_peak_time;
    iterations = 0;
    
    average_fpd = 0;
    average_beat_period = 0;
    while(1)
       %%%disp(t+window)
       %Use the beat detection threshold to determine the regions that need
       %to be analysed
       post_spike_hold_off = orig_post_spike_hold_off;
       est_peak_time = orig_est_peak_time;
       warning = '';
       iterations = iterations +1;
      
       %{
       if ~isempty(beat_periods)
           average_beat_period = mean(average_beat_period);
       end
       
       
       if (time(prev_beat_indx)+average_beat_period) > total_duration
           break;
       end  
       %}
       
       if iterations == 1000
           break;
       end
       
       
       %Take segments of data from each window to search for the next beat 
       if beat_indx == 1
       %if t == 0
           wind_indx = find(time >= time(1) & time <= total_duration);  
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
          
           if min_beat_period <= post_spike_hold_off
               hold_off_period = post_spike_hold_off*2;
           else
               hold_off_period = min_beat_period;
           end
           post_spike_hold_off_time = t_ime(1)+hold_off_period;
           
           pshot_indx = find(t_ime >= post_spike_hold_off_time);
           pshot_indx_offset = pshot_indx(1);

           if bdt > 0
               beat_indx = find(d_ata(pshot_indx) >= bdt);
               %beat_indx_orig = beat_indx;
               beat_indx = beat_indx(1)+wind_indx(1)+pshot_indx_offset-2;
               
               if beat_indx > length(time)
                  beat_indx = length(time); 
               end
               
           else
               beat_indx = find(d_ata(pshot_indx) <= bdt);
               
               %{
               if strcmp(negative_skip, 'yes')
                   if count == 0
                       data = data(beat_indx(1)+wind_indx(1):end);
                       time = time(beat_indx(1)+wind_indx(1):end);
                       count = count+1;
                       continue
                   end
               end
               %}
               beat_indx = beat_indx(1)+wind_indx(1)+pshot_indx_offset-2;
               
               if beat_indx > length(time)
                  beat_indx = length(time); 
               end
               
           end


       catch
           %Update the beat detection threshold
           %beat_indx
           
           window_duration = t_ime(end)-t_ime(1);
           
           %disp(beat_indx_orig)
           bdt = bdt*0.8;
           if isalmost(bdt, 0, 1E-10)
               %%disp('end of recording')
               break
           end
           
           % If fails on the first iteration, set the beat index to be back to the first point
           if prev_beat_indx == 1
               beat_indx = 1;
           else
               beat_indx = prev_beat_indx;
           end

           t = t - window;
           continue;
       end
       
       % Between 10 and 12 seconds 2 beats are being picked up as one
       
       beat_time = time(prev_beat_indx:beat_indx);
       beat_data = data(prev_beat_indx:beat_indx);
       
       
       % Trim and then scale and set back to time zero for each beat
       % Start small degrees of freedom [1-100], polyfits keep trying and do a survey of error plots, do the optimisation curve thing minimised error analysis 
       % Try training and test sets too. Separate the whole datasets so use 80% of the beat signals as the 20%
       
       try
          beat_period = beat_time(end) - beat_time(1);
       catch
          beat_indx = prev_beat_indx;
          continue;
       end
       
       %%%disp(strcat('Beat period = ', num2str(beat_period)));
       %%%disp(strcat('Beat start time = ', num2str(beat_time(1))));
       %%%disp(strcat('Beat end time = ', num2str(beat_time(end))));
       
       if beat_period > max_beat_period
       %Check there is only one beat period.
          disp('bdt has been reduced due to beat period being too long')
          %%disp(bdt)
          
          %if prev_beat_indx ~= 1
          beat_indx = prev_beat_indx;
          bdt = bdt*0.8;
          %window = window*1.5;
          if beat_time(end)+window > total_duration
               break;
          end
          if isalmost(bdt, 0, 1E-5)
             %%disp('end of recording')
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

           if beat_time(end) == time(end)
               
               disp('end cut off')
           else
               fail_beat_detection = fail_beat_detection+1;

               if fail_beat_detection >= 10
                   break;
               end
               disp('bdt has been increased due to beat period being too short')

               %%disp(bdt)
               %%disp(fail_beat_detection)

               if prev_beat_indx ~= 1
                   beat_indx = prev_beat_indx;
                   bdt = bdt*1.5;

                   %%%disp(beat_time(end))
                   %%%disp(window)
                   %%%disp(total_duration)
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
       end
       fail_beat_detection = 0;
       
       if strcmp(spon_paced, 'paced')
           if count == 0
               stim_time = 0;
           elseif count > length(Stims)
              stim_time = beat_time(1);
           else
              stim_time = Stims(count);
           end
       else
           stim_time = 'N/A';
       end
       
       % inclde end of previous beat if BDT is negative to include upward
       % stroke of depol spike
       if bdt < 0
           %if strcmp(negative_skip, 'yes')
               
               new_beat_start_indx = find(time >= beat_time(1)-post_spike_hold_off);
               new_beat_end_indx = find(time >= beat_time(end));
               new_beat_start_indx = new_beat_start_indx(1);
               new_beat_end_indx = new_beat_end_indx(1);

               beat_time = time(new_beat_start_indx:new_beat_end_indx);
               beat_data = data(new_beat_start_indx:new_beat_end_indx);

               est_peak_time = est_peak_time+post_spike_hold_off;
               post_spike_hold_off = post_spike_hold_off*2;
           %{ 
           else
               if count > 0
                   new_beat_start_indx = find(time >= beat_time(1)-post_spike_hold_off);
                   new_beat_end_indx = find(time >= beat_time(end));
                   new_beat_start_indx = new_beat_start_indx(1);
                   new_beat_end_indx = new_beat_end_indx(1);

                   beat_time = time(new_beat_start_indx:new_beat_end_indx);
                   beat_data = data(new_beat_start_indx:new_beat_end_indx);

                   est_peak_time = est_peak_time+post_spike_hold_off;
                   post_spike_hold_off = post_spike_hold_off*2;
               end

           end    
           %}
       end
       
       %{
       if count == 0
           % Skip this beat as it is analysing the end of a beat as a beat.
           % Determined by having a small depol amplitude
           bdt_ratio = bdt/max(data);
           
           if bdt > 0 
               if max(beat_data(1:floor(0.3*length(beat_data)))) < bdt

                   truncate_data_indx = find(time >= beat_time(end));
                   truncate_data_indx = truncate_data_indx(1);
                   time = time(truncate_data_indx:end);
                   data = data(truncate_data_indx:end);

                   continue
               end
           else
               if min(beat_data(1:floor(0.3*length(beat_data)))) > bdt
                    
                   if beat_time(end)-post_spike_hold_off > time(1)
                       truncate_data_indx = find(time >= beat_time(end)-post_spike_hold_off);
                   else
                       
                      truncate_data_indx = find(time >= beat_time(end));
                   end
                   truncate_data_indx = truncate_data_indx(1);
                   time = time(truncate_data_indx:end);
                   data = data(truncate_data_indx:end);

                   continue
               end
               
           end
           
       end
       %}
       
       if strcmp(spon_paced, 'paced bdt')
           if count == 1
               [activation_time, amplitude, max_depol_time, max_depol_point, indx_max_depol_point, min_depol_time, min_depol_point, indx_min_depol_point, slope, warning, pshot_indx_offset, depol_polynomial, depol_filtered_time] = rate_analysis(beat_time, beat_data, post_spike_hold_off, stim_spike_hold_off, 'paced', stim_time, electrode_id, filter_intensity, warning);
           
           else
               [activation_time, amplitude, max_depol_time, max_depol_point, indx_max_depol_point, min_depol_time, min_depol_point, indx_min_depol_point, slope, warning, pshot_indx_offset, depol_polynomial, depol_filtered_time] = rate_analysis(beat_time, beat_data, post_spike_hold_off, stim_spike_hold_off, 'spon', stim_time, electrode_id, filter_intensity, warning);
           
               
           end
       else
           [activation_time, amplitude, max_depol_time, max_depol_point, indx_max_depol_point, min_depol_time, min_depol_point, indx_min_depol_point, slope, warning, pshot_indx_offset, depol_polynomial, depol_filtered_time] = rate_analysis(beat_time, beat_data, post_spike_hold_off, stim_spike_hold_off, spon_paced, stim_time, electrode_id, filter_intensity, warning);
       
       end
       
       
       if strcmp(beat_to_beat, 'on')
           [t_wave_peak_time, t_wave_peak, FPD, warning, t_wave_indx_start, t_wave_indx_end, polynomial_time, polynomial, wavelet_family, poly_degree] = t_wave_complex_analysis(beat_time, beat_data, beat_to_beat, activation_time, count, spon_paced, t_wave_shape, NaN, t_wave_duration, post_spike_hold_off, est_peak_time, est_fpd, electrode_id, filter_intensity, warning);

           %if count == 0
               %figure();
           %end

           %{
           hold off;
           figure();
           hold on;
           plot(beat_time, beat_data);
           plot(t_wave_peak_time, t_wave_peak, 'yo');
           max_depol = beat_data(beat_time == max_depol_time);
           min_depol = beat_data(beat_time == min_depol_time);
           
           plot(max_depol_time, max_depol, 'go');
           plot(min_depol_time, min_depol, 'bo');
           plot(activation_time, act_point, 'ro');
           hold off;
           %}
           %pause(10)
           
           t_wave_peak_times = [t_wave_peak_times t_wave_peak_time];
           t_wave_peak_array = [t_wave_peak_array t_wave_peak];
       end
       
       %if ~strcmp(filter_intensity, 'none')
           if strcmp(filter_intensity, 'low')
              filtration_rate = 5;
          elseif strcmp(filter_intensity, 'medium')
              filtration_rate = 10;
          else
              filtration_rate = 20;
           end
          
           [dr, dc] = size(beat_data);
           [tr, tc] = size(beat_time);
           
           [ptr, ptc] = size(polynomial_time);
           [pr, pc] = size(polynomial);
           
           if indx_min_depol_point < indx_max_depol_point
               
               
               if tc == 1
                   if ptr == 1
                       polynomial_time = reshape(polynomial_time, [ptc, ptr]);

                   end
                   
                   %filtered_time = [filtered_time; nan; beat_time(1:filtration_rate:indx_min_depol_point); beat_time(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1); beat_time(indx_max_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial_time];
                   filtered_time = [filtered_time; nan; depol_filtered_time; nan; polynomial_time];
               
               else
                   if ptc == 1
                       polynomial_time = reshape(polynomial_time, [ptc, ptr]);

                   end
                   
                   %filtered_time = [filtered_time nan beat_time(1:filtration_rate:indx_min_depol_point) beat_time(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1) beat_time(indx_max_depol_point:filtration_rate:pshot_indx_offset) nan polynomial_time];
                   filtered_time = [filtered_time nan depol_filtered_time nan polynomial_time];
               
               end 
               
               
               if dc == 1
                   if pr == 1
                       polynomial = reshape(polynomial, [pc, pr]);

                   end
                   %filtered_data  = [filtered_data; nan; beat_data(1:filtration_rate:indx_min_depol_point); beat_data(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1); beat_data(indx_max_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial];
                   filtered_data  = [filtered_data; nan; depol_polynomial; nan; polynomial];
               
               else
                   if pc == 1
                       polynomial = reshape(polynomial, [pc, pr]);

                   end
                   %filtered_data  = [filtered_data nan beat_data(1:filtration_rate:indx_min_depol_point) beat_data(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1) beat_data(indx_max_depol_point:filtration_rate:pshot_indx_offset) nan polynomial];
                   filtered_data  = [filtered_data nan depol_polynomial nan polynomial];
               
               end
           
           else
               if tc == 1
                   if ptr == 1
                       polynomial_time = reshape(polynomial_time, [ptc, ptr]);

                   end
                   %filtered_time = [filtered_time; nan; beat_time(1:filtration_rate:indx_max_depol_point); beat_time(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1); beat_time(indx_min_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial_time];
                   filtered_time = [filtered_time; nan; depol_filtered_time; nan; polynomial_time];
               
               else
                   if ptc == 1
                       polynomial_time = reshape(polynomial_time, [ptc, ptr]);

                   end
                   %filtered_time = [filtered_time nan beat_time(1:filtration_rate:indx_max_depol_point) beat_time(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1) beat_time(indx_min_depol_point:filtration_rate:pshot_indx_offset) nan polynomial_time];
                   filtered_time = [filtered_time nan depol_filtered_time nan polynomial_time];
               
               end
               
               if dc == 1
                   if pr == 1
                       polynomial = reshape(polynomial, [pc, pr]);

                   end
                   %filtered_data  = [filtered_data; nan; beat_data(1:filtration_rate:indx_max_depol_point); beat_data(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1); beat_data(indx_min_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial];
                   filtered_data  = [filtered_data; nan; depol_polynomial; nan; polynomial];
               
               else
                   if pc == 1
                       polynomial = reshape(polynomial, [pc, pr]);

                   end
                   %filtered_data  = [filtered_data nan beat_data(1:filtration_rate:indx_max_depol_point) beat_data(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1) beat_data(indx_min_depol_point:filtration_rate:pshot_indx_offset) nan polynomial];
                   filtered_data  = [filtered_data nan depol_polynomial nan polynomial];
               
                   
               end
           
               
           end
       %{
       else
           [dr, dc] = size(beat_data);
           [tr, tc] = size(beat_time);

           [ptr, ptc] = size(polynomial_time);
           [pr, pc] = size(polynomial);
           if tc == 1
               if ptr == 1
                   polynomial_time = reshape(polynomial_time, [ptc, ptr]);

               end
               filtered_time = [filtered_time; nan; polynomial_time];

           else
               if ptc == 1
                   polynomial_time = reshape(polynomial_time, [ptc, ptr]);

               end
               filtered_time = [filtered_time nan polynomial_time];

           end 

           if dc == 1
               if pr == 1
                   polynomial = reshape(polynomial, [pc, pr]);

               end
               filtered_data  = [filtered_data; nan; polynomial];

           else
               if pc == 1
                   polynomial = reshape(polynomial, [pc, pr]);

               end
               filtered_data  = [filtered_data nan polynomial];
           end


       end
       %}
       t_wave_wavelet_array = [t_wave_wavelet_array {wavelet_family}];
       t_wave_polynomial_degree_array = [t_wave_polynomial_degree_array poly_degree];
       
       act_point_indx = find(beat_time == activation_time);
       act_point_indx = act_point_indx(1);
       act_point = beat_data(act_point_indx);
       
       if bdt < 0
          %if strcmp(negative_skip, 'yes')
              new_beat_start_indx = find(beat_time >= beat_time(1)+(post_spike_hold_off/2));
              new_beat_start_indx = new_beat_start_indx(1);
              beat_time = beat_time(new_beat_start_indx:end);
              beat_data = beat_data(new_beat_start_indx:end);
          %{
          else
              if count > 0
                  new_beat_start_indx = find(beat_time >= beat_time(1)+(post_spike_hold_off/2));
                  new_beat_start_indx = new_beat_start_indx(1);
                  beat_time = beat_time(new_beat_start_indx:end);
                  beat_data = beat_data(new_beat_start_indx:end);
              end
          end
          %}
       end
       
       
       
       activation_point_array = [activation_point_array act_point];
       activation_time_array = [activation_time_array activation_time];
       cycle_length_array = [cycle_length_array (activation_time-prev_activation_time)];
       beat_num_array = [beat_num_array count];
       beat_start_times = [beat_start_times beat_time(1)];
       beat_start_volts = [beat_start_volts beat_data(1)];
       beat_end_times = [beat_end_times beat_time(end)];
       beat_periods = [beat_periods beat_period]; 
       
       max_depol_time_array = [max_depol_time_array max_depol_time];
       min_depol_time_array = [min_depol_time_array min_depol_time];
       max_depol_point_array = [max_depol_point_array max_depol_point];
       min_depol_point_array = [min_depol_point_array min_depol_point];
       depol_slope_array = [depol_slope_array slope];
       warning_array = [warning_array {warning}];
       t_wave_wavelet_array = [t_wave_wavelet_array {wavelet_family}];
       t_wave_polynomial_degree_array = [t_wave_polynomial_degree_array poly_degree];


       prev_activation_time = activation_time;
       prev_beat_indx = beat_indx;
       count = count + 1;
       t = t + window;
    end
    
    %%%disp(strcat('Total Duration = ', {' '}, string(total_duration)))
    %%%disp(count);
    

    %{
    if strcmpi(beat_to_beat, 'on')
        for i = 2:length(activation_time_array)
            %%disp(strcat('Beat no. ', num2str(i)))
            if i == 2
                %figure();
                %plot(time, data);
                %title('First b2b extracted beat');
                %t_wave_peak_seed = input('On inpection of the first 4 extracted beats please enter the time point to use as the estimated peak of the T-wave complex:\n');
                %t_wave_search_ratio = input('What duration of the waveforms seem to be dominated by the T-wave complex?:\n');
                figure();
            end
            beat_start = beat_start_times(i);
            %%%disp(length(beat_start));
            %%%disp(beat_start)
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
            %%%disp(FPD)
            %subplot(ceil(length(beat_start_times)/4), 4, i-1);
            plot(time_data, beat_data);
            hold on;
            %peak_indx = find(beat_data == t_wave_peak);
            %t_wave_peak_time = time_data(peak_indx(1));
            plot(t_wave_peak_time, t_wave_peak, 'ro');
            %max_depol = beat_data(time_data == max_depol_time);
            %%%disp(min_depol_time)
            %min_depol = beat_data(time_data == min_depol_time);
            act_point = beat_data(time_data == activation_time);
            plot(max_depol_time, max_depol, 'go');
            plot(min_depol_time, min_depol, 'bo');
            plot(activation_time, act_point, 'ro');
            title(strcat('t-wave peak marked for electrode ', electrode_id));
            
            %%disp(strcat('FPD = ', num2str(FPD(1))));
            %%disp(strcat('Depol amplitude = ', num2str(amplitude)))
            
            %hold off;
            %pause(15);


        end
       
    end
    %}
    
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
    
    

end


