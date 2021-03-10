function [activation_time, amplitude, max_depol_time, max_depol_point, min_depol_time, min_depol_point] = rate_analysis(time, data, post_spike_hold_off, stim_spike_hold_off, spon_paced, stim_time, electrode_id)

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
    if strcmp(spon_paced, 'spon')
        post_spike_hold_off_time = time(1)+post_spike_hold_off;
        pshot_indx = find(time >= post_spike_hold_off_time);
        pshot_indx_offset = pshot_indx(1);
        depol_complex_time = time(1:pshot_indx_offset);
        depol_complex_data = data(1:pshot_indx_offset);
    elseif strcmp(spon_paced, 'paced')
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
            disp(length(depol_complex_time))
            if length(depol_complex_time) < 1
                %disp('all')
                depol_complex_time = time;
                depol_complex_data = data;
            end
        end
        
    end
    depol_complex_data_derivative = gradient(depol_complex_data);
    %depol_complex_data_derivative = gradient(depol_complex_data_derivative);
    
    activation_time_indx = find(depol_complex_data_derivative == min(depol_complex_data_derivative));
    
    max_depol_point = max(depol_complex_data)
    max_depol_time = depol_complex_time(find(depol_complex_data == max_depol_point))
    
    min_depol_point = min(depol_complex_data)
    min_depol_time = depol_complex_time(find(depol_complex_data == min_depol_point))
    
    
    if length(min_depol_time) > 1
        min_depol_time = min_depol_time(1);
        
    end
    if length(max_depol_time) > 1
        max_depol_time = max_depol_time(1);
        
    end
    
    amplitude = max_depol_point - min_depol_point;
    
    %% To further refine the region to isolate the depol complex, perfrom std analysis
    
    try
        activation_time = depol_complex_time(activation_time_indx(1));
    catch
        disp('error')
    end
    
    %{
    if strcmp(electrode_id, 'A02_1_4')
        disp('time length')
        disp(length(depol_complex_time));

        figure()
        hold on;
        %plot(time, data);
        plot(depol_complex_time, depol_complex_data);
        %plot(depol_complex_time, depol_complex_data_derivative);
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
    
    
    
    %% TO DO calculate max amplitude
    
   
end