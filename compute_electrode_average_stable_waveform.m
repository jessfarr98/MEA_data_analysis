
function [average_waveform_duration, average_waveform, min_stdev, artificial_time_space, electrode_data] = compute_electrode_average_stable_waveform(beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods, time, data, average_waveform_duration, electrode_data, electrode_count, electrode_id, plot_ave_dir, wellID, post_spike_hold_off, stim_spike_hold_off, spon_paced, beat_to_beat, t_wave_shape, t_wave_duration, est_peak_time, est_fpd, filter_intensity)
    
    % Chnage to using a time frame and then calc percentage 
    %window = floor(size(beat_num_array)*0.25);
    %window = window(1);
    
    total_duration = time(end);
    %window = floor((total_duration/median(cycle_length_array)) / (average_waveform_duration/median(cycle_length_array)))
    %window = round(average_waveform_duration/median(cycle_length_array))
    window = round(average_waveform_duration/median(beat_periods));
    
    
    size_bna = size(beat_num_array);
    size_bna = size_bna(2);
    if window > size_bna
        input_string = sprintf('Error: the window size used to extract the average waveform is larger than the number of beats that were extracted. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a shorter duration (secs):', average_waveform_duration, median(beat_periods));
        
        while(1)
            
            average_waveform_duration = input(input_string);
            window = round(average_waveform_duration/median(beat_periods));
            if window <= size_bna && window >1
                break;
            else
                if window <= 1
                    input_string = sprintf('Error: the window size used to extract the average waveform is less than or equal to 1. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a longer duration (secs):', average_waveform_duration, median(beat_periods));
                else
                    input_string = sprintf('Error: the window size used to extract the average waveform is larger than the number of beats that were extracted. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a shorter duration (secs):', average_waveform_duration, median(beat_periods));
                    
                end
            end
        end
    end
    
    
    if window <= 1
        input_string = sprintf('Error: the window size used to extract the average waveform is less than or equal to 1. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a longer duration (secs):', average_waveform_duration, median(beat_periods));
        while(1)
            average_waveform_duration = input(input_string);
            window = round(average_waveform_duration/median(beat_periods));
            if window <= size_bna && window >1
                break;
            else
                if window <= 1
                    input_string = sprintf('Error: the window size used to extract the average waveform is less than or equal to 1. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a longer duration (secs):', average_waveform_duration, median(beat_periods));
                else
                    input_string = sprintf('Error: the window size used to extract the average waveform is larger than the number of beats that were extracted. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a shorter duration (secs):', average_waveform_duration, median(beat_periods));
                    
                end
            end
        end
    end
    std_devs_forward = [];
    std_devs_reverse = [];
    index_start_array = [];
    index_end_array = [];
    final_element = size_bna-1;
    %%disp('forward');
    
    for w = 1:final_element
        %%disp('window')
        %%disp(w)
        end_window = w+window-1;
        if end_window >= final_element
            break
        end
        %%disp(end_window)
        std_dev_array = [];
        index_start_array = [index_start_array; w];
        %%disp('each element')
        for i = w:end_window
            %%disp(i)
            %%disp(beat_periods(i))
            std_dev_array = [std_dev_array; beat_periods(i)];
            
        end
        index_end_array = [index_end_array; i];
        std_dev = std(std_dev_array);
        std_devs_forward = [std_devs_forward; std_dev];
        
    end
    index_start_array_rev = [];
    index_end_array_rev = [];
    %%disp('reverse')
    for w = final_element:-1:1
        %%disp('window')
        %%disp(w)
        end_window = w-window+1;
        %%disp(end_window)
        std_dev_array_rev = [];
        
        if end_window < 1
            break
        end
        index_end_array_rev = [index_end_array_rev; w];
        %%disp('each element')
        for i = w:-1:end_window
            %%disp(i)
            
            std_dev_array_rev = [std_dev_array_rev; beat_periods(i)];
            
        end
        index_start_array_rev = [index_start_array_rev; i];
        std_dev = std(std_dev_array_rev);
        std_devs_reverse = [std_devs_forward; std_dev];
        
    end
    
    %%disp(std_devs_forward)
    %%disp(std_devs_reverse)
    indx_min_window_forward = find(std_devs_forward ~= 0);
    try
        indx_min_window_forward = find(std_devs_forward == min(std_devs_forward(indx_min_window_forward)));
    catch
        %disp('FAIL INDX MIN WINDOW');
        %disp('indx')
        %disp(indx_min_window_forward);
        %disp('std devs')
        %disp(std_devs_forward)
        %disp('cycle lengths')
        %disp(cycle_length_array);
        %disp('activation times')
        %disp(activation_time_array);
        %disp('start indxs')
        %disp(index_start_array)
        
        pause(100000);
    end
    
    indx_min_window_rev = find(std_devs_reverse ~= 0);
    indx_min_window_rev = find(std_devs_reverse == min(std_devs_reverse(indx_min_window_rev)));
    
    if min(std_devs_forward(indx_min_window_forward))> min(std_devs_reverse(indx_min_window_rev))
        %%disp('rev')
        try
            start_indx_min_window = index_start_array_rev(indx_min_window_rev);
            end_indx_min_window = index_end_array_rev(indx_min_window_rev);
            min_stdev = min(std_devs_reverse(indx_min_window_rev));
        catch
            %disp('FAIL')
            %disp('start array')
            %disp(index_start_array_rev)
            %disp('end array')
            %disp(index_end_array_rev)
            %disp('activation times')
            %disp(activation_times)
            pause(20000);
        end
    else
        %%disp('for')
        try
        %%disp(min(std_devs_forward(indx_min_window_forward)))
        %%disp(min(std_devs_reverse(indx_min_window_rev)))
            start_indx_min_window = index_start_array(indx_min_window_forward);
            end_indx_min_window = index_end_array(indx_min_window_forward);
            min_stdev = min(std_devs_forward(indx_min_window_forward));
        catch
            %disp('FAIL')
            %disp('start array')
            %disp(index_start_array_forward)
            %disp('end array')
            %disp(index_end_array_forward)
            %disp('activation times')
            %disp(activation_time_array)
            pause(2000);
        end
    end

    %%disp(indx_min_window)
    %%disp(index_start_array)
    
    %start_indx_min_window = index_start_array(indx_min_window);
    %end_indx_min_window = index_end_array(indx_min_window);
    %fig = figure();
    %set(fig ,'Visible', 'off');
    %plot(beat_num_array(start_indx_min_window:end_indx_min_window), beat_periods(start_indx_min_window:end_indx_min_window), 'ro')
    %if ~exist(fullfile(plot_ave_dir, wellID, electrode_id), 'dir')
    %    mkdir(fullfile(plot_ave_dir, wellID, electrode_id));        
    %end
    %print(fullfile(plot_ave_dir, wellID, electrode_id, 'stable_ave_waveform_beat_periods'), '-dbitmap', '-r0');
    
    
    % Compute the average beat by overlaying activation times
    %%disp('activation times');
    
    average_waveform = [];
    sampling_rate = NaN;
    stable_data = StableWaveforms.empty(window, 0);
    for j = 1:(window)
        stable_data(j).waveform = [];
        stable_data(j).time = [];
    end
    
    wave_form_count = 0;
    %{
    stable_data = StableWaveforms.empty(window, 0);
    for s = 1:window
        stable_data(s).time = [];
        stable_data(s).waveform = [];
    end
    electrode_data(electrode_count).stable_data = stable_data;
    %}
    stable_waves = {};
    stable_times = {};
    stable_act_offsets = {};
    stable_act_offset_indxs = {};
    max_act_offset = nan;
    max_act_offset_indx = nan;
    for i = (start_indx_min_window+1): end_indx_min_window+1
        %%disp(activation_time_array(i));
        %%disp(i)
        if i > final_element
            window = window-1;            
            break;
        end
        wave_form_count = wave_form_count + 1;
        prev_activation_time = activation_time_array(i-1);
        activation_time = activation_time_array(i);
        prev_beat_start = beat_start_times(i-1);
        beat_start = beat_start_times(i);

        indx_prev_act_time = find(time == prev_activation_time);
        indx_prev_beat_time = find(time == prev_beat_start);
        
        indx_act_time = find(time == activation_time);
        indx_beat_time = find(time == beat_start);

        

        data_array = data(indx_prev_beat_time:indx_beat_time);
        time_array = time(indx_prev_beat_time:indx_beat_time);
        store_data_array = data_array;
        store_time_array = time_array;
        
        act_indx = find(time_array == prev_activation_time);
        act_offset = prev_activation_time - time_array(1);
        
        
        if isnan(max_act_offset_indx)
            max_act_offset = act_offset;
            max_act_offset_indx = act_indx;
            
        end
        
        if act_offset > max_act_offset
            max_act_offset = act_offset;
            max_act_offset_indx = act_indx;
        end

        if isempty(average_waveform)
            average_waveform = data(indx_prev_beat_time:indx_beat_time); 
            %average_waveform = data(indx_prev_act_time:indx_act_time); 
            sampling_rate = time(2)-time(1);
        else
            size_wf = size(average_waveform);
            %size_data = size(data(indx_prev_act_time:indx_act_time));
            size_data = size(data(indx_prev_beat_time:indx_beat_time));
            
            if size_wf(1) > size_data(1)
                num_extra_elements = size_wf(1) - size_data(1);
                extra_elements = zeros(num_extra_elements, 1);
                ext_ra_elements = Inf(num_extra_elements, 1);
                %pause(10)
                data_array = cat(1, data_array, extra_elements);
                %pause(10)
                time_array = cat(1, time_array, extra_elements);
                store_data_array = cat(1, store_data_array, ext_ra_elements);
                store_time_array = cat(1, store_time_array, ext_ra_elements);
                
            elseif size_data(1) > size_wf(1)
                num_extra_elements = size_data(1) - size_wf(1);
                extra_elements = zeros(num_extra_elements, 1);
                %pause(10)
                average_waveform = cat(1, average_waveform, extra_elements);
                
            end


            average_waveform = average_waveform + data_array;
        end

        stable_waves = [stable_waves; {data_array}];
        stable_times = [stable_times; {store_time_array}];
        stable_act_offsets = [stable_act_offsets; {act_offset}];
        stable_act_offset_indxs = [stable_act_offset_indxs; {act_indx}];


    end
    
    
    stable_waves_shape = size(stable_waves);
    
    average_waveform = [];
    for wf = 1:stable_waves_shape(1)
        
        act_offset_indx = stable_act_offset_indxs(wf, 1);
        act_offset_indx = act_offset_indx{1};
        num_extra_elements = max_act_offset_indx - act_offset_indx;
        if num_extra_elements == 0
            %continue
            dat = stable_waves(wf, 1);
            dat = dat{1};
            
            size_dat_after = length(dat);

            size_ave = length(average_waveform);

            if isempty(average_waveform)
                average_waveform = dat;
            else


                if size_ave<size_dat_after
                    num_extra_end_elements = size_dat_after-size_ave;

                    extra_end_elements = zeros(num_extra_end_elements, 1);
                    average_waveform = cat(1, average_waveform, extra_end_elements);
                end

                if size_ave>size_dat_after
                    num_extra_end_elements = size_ave-size_dat_after;

                    extra_end_elements = zeros(num_extra_end_elements, 1);
                    dat = cat(1, dat, extra_end_elements);
                end
                average_waveform = average_waveform+dat;

            end
        else
            extra_elements = zeros(num_extra_elements, 1);

            dat = stable_waves(wf, 1);
            dat = dat{1};

            size_dat_before = size(dat);

            %disp(dat(1:end-num_extra_elements))

            dat = cat(1, extra_elements, dat(1:end-num_extra_elements));
            size_dat_after = length(dat);

            size_ave = length(average_waveform);

            if isempty(average_waveform)
                average_waveform = dat;
            else


                if size_ave<size_dat_after
                    num_extra_end_elements = size_dat_after-size_ave;

                    extra_end_elements = zeros(num_extra_end_elements, 1);
                    average_waveform = cat(1, average_waveform, extra_end_elements);
                end

                if size_ave>size_dat_after
                    num_extra_end_elements = size_ave-size_dat_after;

                    extra_end_elements = zeros(num_extra_end_elements, 1);
                    dat = cat(1, dat, extra_end_elements);
                end
                average_waveform = average_waveform+dat;

            end
            
        end
        
        
    end
    
    %print(fullfile(plot_ave_dir, wellID, electrode_id, 'overlaid_average_waveforms'), '-dbitmap', '-r0');
    %hold off;
    %pause(10);
    
    %{
    stable_beat_check = input('Do you want to keep the time frame used to extract the stable beats? (yes/no):\n', 's');
    
    if strcmpi(stable_beat_check, 'no')
        average_waveform_duration = input('What is the approximate duration you would like to use for the window used to compute the average waveform that will be used for depol/t-wave analysis (seconds): ');
        [average_waveform_duration] = compute_electrode_average_stable_waveform(beat_num_array, cycle_length_array, activation_time_array, time, data, average_waveform_duration);
    
    else
    %}
    
    average_waveform = average_waveform ./ window;
    len_wf = size(average_waveform);
    artificial_time_space = linspace(0,(sampling_rate*len_wf(1)),len_wf(1));


        
    %end
    %%disp(window);
    filtered_ave_wave_time = [];
    filtered_average_waveform = [];
    
    
    [activation_time, amplitude, max_depol_time, max_depol_point, indx_max_depol_point, min_depol_time, min_depol_point, indx_min_depol_point, slope, electrode_data(electrode_count).ave_warning, pshot_indx_offset] = rate_analysis(artificial_time_space, average_waveform, post_spike_hold_off, stim_spike_hold_off, spon_paced, artificial_time_space(1), electrode_id, filter_intensity, '');
    activation_time_indx = find(artificial_time_space >=activation_time);
    activation_time = artificial_time_space(activation_time_indx(1));
    act_point = average_waveform(activation_time_indx(1));
    
    [t_wave_peak_time, t_wave_peak, FPD, electrode_data(electrode_count).ave_warning, t_wave_indx_start, t_wave_indx_end, polynomial_time, polynomial, wavelet_family, best_p_degree] = t_wave_complex_analysis(artificial_time_space, average_waveform, beat_to_beat, activation_time, 0, spon_paced, t_wave_shape, NaN, t_wave_duration, post_spike_hold_off, est_peak_time, est_fpd, electrode_id, filter_intensity, electrode_data(electrode_count).ave_warning);
    
    
    if ~strcmp(filter_intensity, 'none')
       if strcmp(filter_intensity, 'low')
          filtration_rate = 5;
       elseif strcmp(filter_intensity, 'medium')
          filtration_rate = 10;
       else
          filtration_rate = 20;
       end

       [dr, dc] = size(average_waveform);
       [tr, tc] = size(artificial_time_space);
       if indx_min_depol_point < indx_max_depol_point


           if tc == 1
               filtered_ave_wave_time = [artificial_time_space(1:filtration_rate:indx_min_depol_point); artificial_time_space(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1); artificial_time_space(indx_max_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial_time];

           else
               filtered_ave_wave_time = [artificial_time_space(1:filtration_rate:indx_min_depol_point) artificial_time_space(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1) artificial_time_space(indx_max_depol_point:filtration_rate:pshot_indx_offset) nan polynomial_time];

           end 


           if dc == 1
               filtered_average_waveform  = [average_waveform(1:filtration_rate:indx_min_depol_point); average_waveform(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1); average_waveform(indx_max_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial];

           else
               filtered_average_waveform  = [average_waveform(1:filtration_rate:indx_min_depol_point) average_waveform(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1) average_waveform(indx_max_depol_point:filtration_rate:pshot_indx_offset) nan polynomial];

           end

       else
           if tc == 1
               filtered_ave_wave_time = [artificial_time_space(1:filtration_rate:indx_max_depol_point); artificial_time_space(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1); artificial_time_space(indx_min_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial_time];

           else
               filtered_ave_wave_time = [artificial_time_space(1:filtration_rate:indx_max_depol_point) artificial_time_space(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1) artificial_time_space(indx_min_depol_point:filtration_rate:pshot_indx_offset) nan polynomial_time];

           end

           if dc == 1
               filtered_average_waveform  = [average_waveform(1:filtration_rate:indx_max_depol_point); average_waveform(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1); average_waveform(indx_min_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial];

           else
               filtered_average_waveform  = [average_waveform(1:filtration_rate:indx_max_depol_point) average_waveform(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1) average_waveform(indx_min_depol_point:filtration_rate:pshot_indx_offset) nan polynomial];


           end


       end
   else
       [dr, dc] = size(average_waveform);
       [tr, tc] = size(artificial_time_space);


       if tc == 1
           filtered_ave_wave_time = [polynomial_time];

       else
           filtered_ave_wave_time = [polynomial_time];

       end 

       if dc == 1
           filtered_average_waveform  = [polynomial];

       else
           filtered_average_waveform  = [polynomial];
       end


    end
   
    
    electrode_data(electrode_count).min_stdev = min_stdev;
    electrode_data(electrode_count).average_waveform = average_waveform;
    electrode_data(electrode_count).ave_wave_time = artificial_time_space;
    electrode_data(electrode_count).electrode_id = electrode_id;
    electrode_data(electrode_count).stable_waveforms = stable_waves;
    electrode_data(electrode_count).stable_times = stable_times;
    electrode_data(electrode_count).window = window;
    electrode_data(electrode_count).ave_max_depol_time = max_depol_time;
    electrode_data(electrode_count).ave_min_depol_time = min_depol_time;
    electrode_data(electrode_count).ave_max_depol_point = max_depol_point;
    electrode_data(electrode_count).ave_min_depol_point = min_depol_point;
    electrode_data(electrode_count).ave_activation_time = activation_time;
    electrode_data(electrode_count).ave_activation_point = act_point;;
    electrode_data(electrode_count).ave_t_wave_peak_time = t_wave_peak_time;
    electrode_data(electrode_count).ave_t_wave_peak = t_wave_peak;
    electrode_data(electrode_count).ave_depol_slope = slope;
    
    electrode_data(electrode_count).ave_t_wave_wavelet = wavelet_family;
    electrode_data(electrode_count).ave_t_wave_polynomial_degree = best_p_degree;
    
    electrode_data(electrode_count).filtered_ave_wave_time = filtered_ave_wave_time;
    electrode_data(electrode_count).filtered_average_waveform = filtered_average_waveform;
    
    
    
    %electrode_data(electrode_count).stable_data = stable_data;
    %%disp(electrode_data(electrode_count).stable_data);
end