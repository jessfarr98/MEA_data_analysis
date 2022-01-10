%function [activation_time, amplitude, max_depol_time, max_depol_point, min_depol_time, min_depol_point, slope, warning] = rate_analysis(time, data, post_spike_hold_off, stim_spike_hold_off, spon_paced, stim_time, electrode_id, filter_intensity, warning)
function [activation_time, amplitude, max_depol_time, max_depol_point, min_depol_time, min_depol_point, slope, warning] = rate_analysis(time, data, post_spike_hold_off, stim_spike_hold_off, spon_paced, stim_time, electrode_id, filter_intensity, warning)

    % propagation maps:
    % sort the first act time per electrode per well and then calc
    % delta_time between each 
    % Can use diff prop patterns - see statistic compiler. Some are more
    % common than others. Not default, need to be turned on. 

    %{
    if strcmp(electrode_id, 'A02_1_4')
        figure()

        plot(time, data);
        title('Full beat');

        disp('post spike hold off')
        disp(post_spike_hold_off);
        disp('tim spike hold off')
        disp(stim_spike_hold_off);
        disp('stim');
        disp(stim_time);

        disp('start time');
        disp(time(1))
        disp('end time')
        disp(time(end))
    
    end
    %}
    %time
    %{
    if isempty(time)
        disp(time)
    end
    time(end)
    time(1)
    
    post_spike_hold_off
    %}
    
    
    if post_spike_hold_off >= time(end)-time(1)
        post_spike_hold_off = time(end)-time(1)/10;
    end
            
    if strcmp(spon_paced, 'spon')
        post_spike_hold_off_time = time(1)+post_spike_hold_off;
        pshot_indx = find(time >= post_spike_hold_off_time);
        pshot_indx_offset = pshot_indx(1);
        depol_complex_time = time(1:pshot_indx_offset);
        depol_complex_data = data(1:pshot_indx_offset);
    elseif strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
        start_time_indx = find(time >= time(1)+stim_spike_hold_off);
        
        %start_time_indx(1)
        post_spike_hold_off_time = time(1)+post_spike_hold_off;
        pshot_indx = find(time >= post_spike_hold_off_time);
        pshot_indx_offset = pshot_indx(1);
        try
            depol_complex_time = time(start_time_indx(1):pshot_indx_offset);
            depol_complex_data = data(start_time_indx(1):pshot_indx_offset);
            %{
            disp(length(depol_complex_time))
            disp('depol start')
            disp(depol_complex_time(1))
            disp('depol end')
            disp(depol_complex_time(end))
            %}
            if length(depol_complex_time) < 1
                depol_complex_time = time;
                depol_complex_data = data;
            end
        catch 
            %disp('catch')
            depol_complex_time = time(1:pshot_indx_offset);
            depol_complex_data = data(1:pshot_indx_offset);
            %disp(length(depol_complex_time))
            if length(depol_complex_time) < 1
                %disp('all')
                depol_complex_time = time;
                depol_complex_data = data;
            end
        end
        
    end
    
    %depol_complex_data_derivative = gradient(depol_complex_data_derivative);
    
    %activation_time_indx = find(depol_complex_data_derivative == min(depol_complex_data_derivative));
    %activation_time_indx = find(abs(depol_complex_data_derivative) == max(abs(depol_complex_data_derivative)));
    
    max_depol_point = max(depol_complex_data);
    indx_max_depol_point = find(depol_complex_data == max_depol_point);
    
    
    min_depol_point = min(depol_complex_data);
    indx_min_depol_point = find(depol_complex_data == min_depol_point);
    
    
    if length(indx_min_depol_point) > 1
        if strcmp(warning, '')
            warning = strcat(warning, 'Lower Depol. stroke clipped');
        else
            warning = strcat(warning, {' '}, 'and lower Depol. stroke clipped');
        end
        
    end
    
    if length(indx_max_depol_point) > 1

        
        if strcmp(warning, '')
            warning = strcat(warning, 'Upper Depol. stroke clipped');
        else
            warning = strcat(warning, {' '}, 'and upper Depol. stroke clipped');
        end
    end
    
    indx_max_depol_point = indx_max_depol_point(1);
    max_depol_time = depol_complex_time(indx_max_depol_point);
    
    indx_min_depol_point = indx_min_depol_point(1);
    min_depol_time = depol_complex_time(indx_min_depol_point);
    
    
    size_depol = length(depol_complex_data);

    if strcmp(filter_intensity, 'none')
        filtration_rate = 1;
    elseif strcmp(filter_intensity, 'low')
        filtration_rate = 5;
    elseif strcmp(filter_intensity, 'medium')
        filtration_rate = 10;
    else
        filtration_rate = 20;
    end
    
    [dr, dc] = size(depol_complex_data);
    [tr, tc] = size(depol_complex_time);
    
    if indx_min_depol_point < indx_max_depol_point
        if dc == 1
            filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1), depol_complex_data(indx_max_depol_point:filtration_rate:end));
            
        else

            
            filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1), depol_complex_data(indx_max_depol_point:filtration_rate:end));
            
        end
        
        if tc == 1
            depol_complex_time_filtered = vertcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1), depol_complex_time(indx_max_depol_point:filtration_rate:end));
        
        else
            depol_complex_time_filtered = horzcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1), depol_complex_time(indx_max_depol_point:filtration_rate:end));
        
        end
        
        
        %depol_complex_time_filtered = depol_complex_time;
        
        %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
        
        depol_complex_data_derivative = gradient(filtered_data);
    else
        if dc == 1
            filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1), depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        else

            filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1), depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        end
        
        if tc == 1
            depol_complex_time_filtered = vertcat(depol_complex_time(1:filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1), depol_complex_time(indx_min_depol_point:filtration_rate:end));
        
        else
            
            depol_complex_time_filtered = horzcat(depol_complex_time(1:filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1), depol_complex_time(indx_min_depol_point:filtration_rate:end));
        
        end

        %depol_complex_time_filtered = depol_complex_time;
        
        %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
        
        depol_complex_data_derivative = gradient(filtered_data);
        
    end
    
    %{
    figure(1);
    plot(depol_complex_time, depol_complex_data);
    hold on;
    plot(depol_complex_time_filtered, filtered_data);
    plot(depol_complex_time_filtered, depol_complex_data_derivative);
    hold off;
    pause(15)
    
    %}
    
    min_raw_slope = min(depol_complex_data_derivative);
    max_raw_slope = max(depol_complex_data_derivative);
    max_abs_slope = max(abs(depol_complex_data_derivative));
    
    activation_time_indx_min_raw = find(depol_complex_data_derivative == min_raw_slope);
    activation_time_indx_max_raw = find(depol_complex_data_derivative == max_raw_slope);
    activation_time_indx_max_abs = find(abs(depol_complex_data_derivative) == max_abs_slope);
    
    
    
    amplitude = max_depol_point - min_depol_point;
    
    % To further refine the region to isolate the depol complex, perfrom std analysis
    
    min_raw_act_time = depol_complex_time_filtered(activation_time_indx_min_raw(1));
    max_raw_act_time = depol_complex_time_filtered(activation_time_indx_max_raw(1));
    max_abs_act_time = depol_complex_time_filtered(activation_time_indx_max_abs(1));
    
    if ((max_depol_time >= min_raw_act_time)&& (min_raw_act_time>= min_depol_time)) || ((min_depol_time >= min_raw_act_time) && (min_raw_act_time>= max_depol_time))
        activation_time = depol_complex_time_filtered(activation_time_indx_min_raw(1));
        %slope = depol_complex_data(activation_time_indx(1)); %3/12/2021 bug was calculating the slope using the original y data, not the dydx of te signal - this is a scalar value
        slope = depol_complex_data_derivative(activation_time_indx_min_raw(1));
        
    else
        if ((max_depol_time >= max_abs_act_time)&& (max_abs_act_time>= min_depol_time)) || ((min_depol_time >= max_abs_act_time)&& (max_abs_act_time>= max_depol_time))
            activation_time = depol_complex_time_filtered(activation_time_indx_max_abs(1));
            %slope = depol_complex_data(activation_time_indx(1)); %3/12/2021 bug was calculating the slope using the original y data, not the dydx of te signal - this is a scalar value
            slope = depol_complex_data_derivative(activation_time_indx_max_abs(1));
        else
            %{
            if max_raw_slope >= 0
                if min_raw_slope < -1* max_raw_slope
                % If the raw minimum is steeper than the raw maximum
                    activation_time = depol_complex_time(activation_time_indx_min_raw(1));
                    %slope = depol_complex_data(activation_time_indx(1)); %3/12/2021 bug was calculating the slope using the original y data, not the dydx of te signal - this is a scalar value
                    slope = depol_complex_data_derivative(activation_time_indx_min_raw(1));
                else
                % Use abs max value as it is steeper
                    activation_time = depol_complex_time(activation_time_indx_max_abs(1));
                    %slope = depol_complex_data(activation_time_indx(1)); %3/12/2021 bug was calculating the slope using the original y data, not the dydx of te signal - this is a scalar value
                    slope = depol_complex_data_derivative(activation_time_indx_max_abs(1));
                end
            else
                activation_time = depol_complex_time(activation_time_indx_max_abs(1));
                %slope = depol_complex_data(activation_time_indx(1)); %3/12/2021 bug was calculating the slope using the original y data, not the dydx of te signal - this is a scalar value
                slope = depol_complex_data_derivative(activation_time_indx_max_abs(1));
               
            end
            %}
            if ((max_depol_time >= max_raw_act_time)&& (max_raw_act_time>= min_depol_time)) || ((min_depol_time >= max_raw_act_time)&& (max_raw_act_time>= max_depol_time))
                activation_time = depol_complex_time_filtered(activation_time_indx_max_raw(1));
                %slope = depol_complex_data(activation_time_indx(1)); %3/12/2021 bug was calculating the slope using the original y data, not the dydx of te signal - this is a scalar value
                slope = depol_complex_data_derivative(activation_time_indx_max_raw(1));
            else
                if min_depol_time < max_depol_time
                    activation_time = depol_complex_time_filtered(activation_time_indx_max_abs(1));
                    %slope = depol_complex_data(activation_time_indx(1)); %3/12/2021 bug was calculating the slope using the original y data, not the dydx of te signal - this is a scalar value
                    slope = depol_complex_data_derivative(activation_time_indx_max_abs(1));
                    
                    if strcmp(warning, '')
                        warning = strcat(warning, 'Activation Point Calculated out of the Max/Min Range');
                    else
                        warning = strcat(warning, {' '}, ' and Activation Point Calculated out of the Max/Min Range');
                    end
                else
                    activation_time = depol_complex_time_filtered(activation_time_indx_min_raw(1));
                    %slope = depol_complex_data(activation_time_indx(1)); %3/12/2021 bug was calculating the slope using the original y data, not the dydx of te signal - this is a scalar value
                    slope = depol_complex_data_derivative(activation_time_indx_min_raw(1));

                    if strcmp(warning, '')
                        warning = strcat(warning, 'Activation Point Calculated out of the Max/Min Range');
                    else
                        warning = strcat(warning, {' '}, ' and Activation Point Calculated out of the Max/Min Range');
                    end
                end
            end
        end
        
        
    end
    
    
    
    
    %try
    %{
    activation_time = depol_complex_time(activation_time_indx(1));
    %slope = depol_complex_data(activation_time_indx(1)); %3/12/2021 bug was calculating the slope using the original y data, not the dydx of te signal - this is a scalar value
    slope = depol_complex_data_derivative(activation_time_indx(1));
    
    
    %}
    
    
    
    
    
    %catch
    %    disp('error')
    %    activation_time = nan;
    %    slope = nan;
    %end
    
    %{
    if strcmp(electrode_id, 'A03_1_4')
        disp('time length')
        disp(length(depol_complex_time));

        figure()
        hold on;
        %plot(time, data);
        plot(depol_complex_time, depol_complex_data);
        plot(depol_complex_time, depol_complex_data_derivative);
        plot(max_depol_time, max_depol_point, 'ro');
        plot(min_depol_time, min_depol_point, 'ro');
        plot(depol_complex_time(activation_time_indx(1)), depol_complex_data(activation_time_indx(1)), 'ro')
        xlabel('Time (secs)')
        ylabel('Voltage (V)')
        title('Extracted Depol. Complex');
        hold off;
        
        disp('max')
        disp(max_depol_time)
        disp('min')
        disp(min_depol_time)
        disp('start depol');
        disp(depol_complex_time(1))
        disp('end depol')
        disp(depol_complex_time(end))
    end
        %}
    
    %}
    
    %cpause(5);cl
    %pause(5);
    
    
    
    % TO DO calculate max amplitude
    
   
end