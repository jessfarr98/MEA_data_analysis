function [average_waveform, electrode_data] = compute_average_time_region_waveform(beat_num_array, cycle_length_array, activation_time_array, time, data, electrode_data, electrode_count, electrode_id, beat_periods, beat_start_times, plot_ave_dir, wellID, post_spike_hold_off, stim_spike_hold_off, spon_paced, beat_to_beat, t_wave_shape, t_wave_duration, est_peak_time, est_fpd, filter_intensity, time_region1, time_region2)

    

    beat_start_times = beat_start_times(find(beat_start_times >= time_region1 & beat_start_times <= time_region2));
    activation_time_array = activation_time_array(find(activation_time_array >= time_region1 & activation_time_array <= time_region2));

    average_waveform = [];
    sampling_rate = NaN;    
    wave_form_count = 0;

    stable_waves = {};
    stable_times = {};
    stable_act_offsets = {};
    stable_act_offset_indxs = {};
    %disp(size(beat_periods))
    len = size(beat_start_times);
    len = len(2);
    %fig = figure();
    %set(fig ,'Visible', 'off');
    %hold on;
    max_act_offset = nan;
    max_act_offset_indx = nan;
    
    min_act_offset = nan;
    min_act_offset_indx = nan;
    
    
    
    
    for i = 2:len
        %%disp(activation_time_array(i))
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
        act_indx = find(time_array == prev_activation_time);
        
        act_offset = prev_activation_time - time_array(1);
        
        
        if isnan(max_act_offset_indx)
            max_act_offset = act_offset;
            max_act_offset_indx = act_indx;
            
            min_act_offset = act_offset;
            min_act_offset_indx = act_indx;
        end
        
        if act_offset > max_act_offset
            max_act_offset = act_offset;
            max_act_offset_indx = act_indx;
        end
        
        if act_offset < min_act_offset
            min_act_offset = act_offset;
            min_act_offset_indx = act_indx;
        end
        time_array = time_array - time_array(1);
        %{
        data_array = data(indx_prev_act_time:indx_act_time);
        time_array = time(indx_prev_act_time:indx_act_time);
        %}
        
        store_data_array = data_array;
        store_time_array = time_array;
        %plot(time_array,data_array);
        
        if isempty(average_waveform)
            average_waveform = data(indx_prev_beat_time:indx_beat_time);
            %average_waveform = data(indx_prev_act_time:indx_act_time);
            sampling_rate = time(2)-time(1);
        else
            size_wf = size(average_waveform);
            size_data = size(data(indx_prev_beat_time:indx_beat_time));
            %size_data = size(data(indx_prev_act_time:indx_act_time));
            
            if size_wf(1) > size_data(1)
                num_extra_elements = size_wf(1) - size_data(1);
                extra_elements = zeros(num_extra_elements, 1);
                ext_ra_elements = Inf(num_extra_elements, 1);
                data_array = cat(1, data_array, extra_elements);
                time_array = cat(1, time_array, extra_elements);
               
                store_data_array = cat(1, store_data_array, ext_ra_elements);
                store_time_array = cat(1, store_time_array, ext_ra_elements);
            elseif size_data(1) > size_wf(1)
                num_extra_elements = size_data(1) - size_wf(1);
                extra_elements = zeros(num_extra_elements, 1);
                average_waveform = cat(1, average_waveform, extra_elements);
                
            end
            
            average_waveform = average_waveform + data_array;
        end
        
        stable_waves = [stable_waves; {store_data_array}];
        stable_times = [stable_times; {store_time_array}];
        stable_act_offsets = [stable_act_offsets; {act_offset}];
        stable_act_offset_indxs = [stable_act_offset_indxs; {act_indx}];

        
    end

    
    %Overlay waveforms onto an activation point
    stable_waves_shape = size(stable_waves);
    
    max_extra = 0;
    average_waveform = [];
    new_stable_data = [];
    for wf = 1:stable_waves_shape(1)
        
        %stable_times(wf, 1) = stable_times(wf, 1)-min_act;
 
        act_offset_indx = stable_act_offset_indxs(wf, 1);
        act_offset_indx = act_offset_indx{1};
        num_extra_elements = max_act_offset_indx - act_offset_indx;
        if num_extra_elements == 0
            %continue
            extra_elements = zeros(num_extra_elements, 1);
            if num_extra_elements > max_extra
                max_extra = num_extra_elements;
            end

            time = stable_times(wf, 1);
            dat = stable_waves(wf, 1);
            time = time{1};
            %time = time-min_act_offset;
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
            if num_extra_elements > max_extra
                max_extra = num_extra_elements;
            end

            time = stable_times(wf, 1);
            dat = stable_waves(wf, 1);
            time = time{1};
            %time = time-min_act_offset;
            dat = dat{1};


            dat = cat(1, extra_elements, dat(1:end-num_extra_elements));
            size_dat_after = length(dat);
            new_stable_data = [new_stable_data; {cat(1, extra_elements, dat)}];


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
        
        %[activation_time, amplitude, max_depol_time, max_depol_point, min_depol_time, min_depol_point, slope, electrode_data(electrode_count).ave_warning] = rate_analysis(time, dat, post_spike_hold_off, stim_spike_hold_off, spon_paced, time(1), electrode_id, filter_intensity, '');
        
        %act_point = dat(find(time == activation_time));
        
        %plot(activation_time, act_point, 'o');
        %plot(time , dat)
    end
    
    
    
    
    average_waveform = average_waveform ./ len;
    %%disp(average_waveform)
    
    len_wf = size(average_waveform);
    artificial_time_space = linspace(0,(sampling_rate*len_wf(1)),len_wf(1));
    
    
    %print(fullfile(plot_ave_dir, wellID, electrode_id, 'average_waveform'), '-dbitmap', '-r0');
    filtered_ave_wave_time = [];
    filtered_average_waveform = [];
    
    if isempty(artificial_time_space)
       return 
    end
    [activation_time, amplitude, max_depol_time, max_depol_point,indx_max_depol_point, min_depol_time, min_depol_point, indx_min_depol_point, slope, electrode_data(electrode_count).ave_warning, pshot_indx_offset, depol_polynomial, depol_filtered_time] = rate_analysis(artificial_time_space, average_waveform, post_spike_hold_off, stim_spike_hold_off, spon_paced, artificial_time_space(1), electrode_id, filter_intensity, '');
    %[activation_time, amplitude, max_depol_time, max_depol_point, indx_max_depol_point, min_depol_time, min_depol_point, indx_min_depol_point, slope, electrode_data(electrode_count).ave_warning, pshot_indx_offset, depol_polynomial, depol_filtered_time] = rate_analysis(artificial_time_space, average_waveform, post_spike_hold_off, stim_spike_hold_off, spon_paced, artificial_time_space(1), electrode_id, filter_intensity, '');
    
    activation_time_indx = find(artificial_time_space >=activation_time);
    activation_time = artificial_time_space(activation_time_indx(1));
    act_point = average_waveform(activation_time_indx(1));
    
    [t_wave_peak_time, t_wave_peak, FPD, electrode_data(electrode_count).ave_warning, t_wave_indx_start, t_wave_indx_end, polynomial_time, polynomial, wavelet_family, best_p_degree] = t_wave_complex_analysis(artificial_time_space, average_waveform, beat_to_beat, activation_time, 0, spon_paced, t_wave_shape, NaN, t_wave_duration, post_spike_hold_off, est_peak_time, est_fpd, electrode_id, filter_intensity, electrode_data(electrode_count).ave_warning);
    
    
    %if ~strcmp(filter_intensity, 'none')
       if strcmp(filter_intensity, 'low')
          filtration_rate = 5;
       elseif strcmp(filter_intensity, 'medium')
          filtration_rate = 10;
       else
          filtration_rate = 20;
       end

       [dr, dc] = size(average_waveform);
       [tr, tc] = size(artificial_time_space);
       
       
       [ptr, ptc] = size(polynomial_time);
       [pr, pc] = size(polynomial);
       [pdr, pdc] = size(depol_polynomial);

       if indx_min_depol_point < indx_max_depol_point
            

           if tc == 1
               if ptr == 1
                   polynomial_time = reshape(polynomial_time, [ptc, ptr]);

               end
               %filtered_ave_wave_time = [artificial_time_space(1:filtration_rate:indx_min_depol_point); artificial_time_space(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1); artificial_time_space(indx_max_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial_time];
               filtered_ave_wave_time = [depol_filtered_time; nan; polynomial_time];

           else
               if ptc == 1
                   polynomial_time = reshape(polynomial_time, [ptc, ptr]);

               end
               %filtered_ave_wave_time = [artificial_time_space(1:filtration_rate:indx_min_depol_point) artificial_time_space(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1) artificial_time_space(indx_max_depol_point:filtration_rate:pshot_indx_offset) nan polynomial_time];
                filtered_ave_wave_time = [depol_filtered_time nan polynomial_time];

           end 


           if dc == 1
               if pr == 1
                   polynomial = reshape(polynomial, [pc, pr]);

               end
               %filtered_average_waveform  = [average_waveform(1:filtration_rate:indx_min_depol_point); average_waveform(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1); average_waveform(indx_max_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial];
                filtered_average_waveform  = [depol_polynomial; nan; polynomial];

           else
               if pc == 1
                   polynomial = reshape(polynomial, [pc, pr]);

               end
               %filtered_average_waveform  = [average_waveform(1:filtration_rate:indx_min_depol_point) average_waveform(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1) average_waveform(indx_max_depol_point:filtration_rate:pshot_indx_offset) nan polynomial];
                filtered_average_waveform  = [depol_polynomial nan polynomial];

           end

       else
           if tc == 1
               if ptr == 1
                   polynomial_time = reshape(polynomial_time, [ptc, ptr]);

               end
               %filtered_ave_wave_time = [artificial_time_space(1:filtration_rate:indx_max_depol_point); artificial_time_space(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1); artificial_time_space(indx_min_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial_time];
               filtered_ave_wave_time = [depol_filtered_time; nan; polynomial_time];

           else
               if ptc == 1
                   polynomial_time = reshape(polynomial_time, [ptc, ptr]);

               end
               %filtered_ave_wave_time = [artificial_time_space(1:filtration_rate:indx_max_depol_point) artificial_time_space(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1) artificial_time_space(indx_min_depol_point:filtration_rate:pshot_indx_offset) nan polynomial_time];
                filtered_ave_wave_time = [depol_filtered_time nan polynomial_time];

           end

           if dc == 1
               if pr == 1
                   polynomial = reshape(polynomial, [pc, pr]);

               end
               %filtered_average_waveform  = [average_waveform(1:filtration_rate:indx_max_depol_point); average_waveform(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1); average_waveform(indx_min_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial];
               filtered_average_waveform  = [depol_polynomial; nan; polynomial];

           else
               if pc == 1
                   polynomial = reshape(polynomial, [pc, pr]);

               end
               %filtered_average_waveform  = [average_waveform(1:filtration_rate:indx_max_depol_point) average_waveform(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1) average_waveform(indx_min_depol_point:filtration_rate:pshot_indx_offset) nan polynomial];
               filtered_average_waveform  = [depol_polynomial nan polynomial];


           end


       end
   %{
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
    %}
   
    
    
    electrode_data(electrode_count).min_stdev = NaN;
    electrode_data(electrode_count).average_waveform = average_waveform;
    electrode_data(electrode_count).ave_wave_time = artificial_time_space;
    electrode_data(electrode_count).electrode_id = electrode_id;
    electrode_data(electrode_count).stable_waveforms = stable_waves;
    electrode_data(electrode_count).stable_times = stable_times;
    electrode_data(electrode_count).window = len;
    electrode_data(electrode_count).ave_max_depol_time = max_depol_time;
    electrode_data(electrode_count).ave_min_depol_time = min_depol_time;
    electrode_data(electrode_count).ave_max_depol_point = max_depol_point;
    electrode_data(electrode_count).ave_min_depol_point = min_depol_point;
    electrode_data(electrode_count).ave_activation_time = activation_time;
    electrode_data(electrode_count).ave_activation_point = act_point;
    electrode_data(electrode_count).ave_t_wave_peak_time = t_wave_peak_time;
    electrode_data(electrode_count).ave_t_wave_peak = t_wave_peak;
    electrode_data(electrode_count).ave_depol_slope = slope;
    
    electrode_data(electrode_count).ave_t_wave_wavelet = wavelet_family;
    electrode_data(electrode_count).ave_t_wave_polynomial_degree = best_p_degree;
    
    electrode_data(electrode_count).filtered_ave_wave_time = filtered_ave_wave_time;
    electrode_data(electrode_count).filtered_average_waveform = filtered_average_waveform;
    
    %{
    figure();
    plot(artificial_time_space, average_waveform)
    %}
    
    %electrode_data(electrode_count).stable_data = stable_data;

end

