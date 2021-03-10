function [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(time, data, beat_to_beat, activation_time, beat_no, spon_paced, mono_up_down, t_wave_peak, t_wave_search_duration, post_spike_holdoff)
    
    disp(mono_up_down);
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
            t_wave_peak = t_wave_peak(1);
            t_wave_peak_time = t_wave_time(t_wave_data == t_wave_peak);
            t_wave_peak_time = t_wave_peak_time(1);
            
           
        elseif strcmp(mono_up_down, 'down')            
            t_wave_indx = find(time >= time(1)+post_spike_holdoff & time <= time(1)+post_spike_holdoff+(t_wave_search_duration));
            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);
            t_wave_peak = min(t_wave_data);
            t_wave_peak = t_wave_peak(1);
            t_wave_peak_time = t_wave_time(t_wave_data == t_wave_peak);
            t_wave_peak_time = t_wave_peak_time(1);
            %t_wave_peak = t_wave_peak(1);
        end  
    end
    
    %disp(activation_time)
    %disp(t_wave_peak_time)
    FPD = t_wave_peak_time - activation_time;
    


end