function [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(time, data, beat_to_beat, activation_time, beat_no, spon_paced, peak_analysis, t_wave_peak, t_wave_search_duration, post_spike_holdoff, est_peak_time, est_fpd, electrode_id)
    
    
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
    if est_peak_time >= time(end)-time(1)
                
        est_peak_time = est_peak_time*time(end)-time(1)/4;

    end
    if t_wave_search_duration >= time(end)-time(1)

        t_wave_search_duration = est_peak_time*time(end)-time(1)/5;

    end
    if post_spike_holdoff >= time(end)-time(1)
        post_spike_holdoff = time(end)-time(1)/10;
    end
    lower = time(1)+ est_peak_time - t_wave_search_duration/2;
    upper = time(1)+ est_peak_time + t_wave_search_duration/2;


    if lower < time(1)+post_spike_holdoff
        lower = time(1)+post_spike_holdoff;
    end

    if lower >= time(end)
        lower = time(1)+post_spike_holdoff;
    end         

    if upper > time(end)
        upper = time(end)-post_spike_holdoff;
    end

    if lower >= upper
        lower = time(1)+post_spike_holdoff;
    end
    if strcmp(peak_analysis, 'max')
        %t_wave_indx = find(time >= time(1)+post_spike_holdoff & time <= time(1)+post_spike_holdoff+(t_wave_search_duration));
        try
            
            t_wave_indx = find(time >= lower & time <= upper);

            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);

            t_wave_peak = max(t_wave_data);
            t_wave_peak = t_wave_peak(1);
            t_wave_peak_time = t_wave_time(t_wave_data == t_wave_peak);
            t_wave_peak_time = t_wave_peak_time(1);

        catch
            t_wave_peak_time = NaN;
            t_wave_peak = NaN;
        end

    elseif strcmp(peak_analysis, 'min')            
        %t_wave_indx = find(time >= time(1)+post_spike_holdoff & time <= time(1)+post_spike_holdoff+(t_wave_search_duration));
        try
            
            t_wave_indx = find(time >= lower & time <= upper);

            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);
            t_wave_peak = min(t_wave_data);
            t_wave_peak = t_wave_peak(1);
            t_wave_peak_time = t_wave_time(t_wave_data == t_wave_peak);
            t_wave_peak_time = t_wave_peak_time(1);
            %t_wave_peak = t_wave_peak(1);
        catch
            t_wave_peak_time = NaN;
            t_wave_peak = NaN;
        end
                
    elseif strcmp(peak_analysis, 'inflection') 
        % 4_4 3_1 1_1 1_2 2_2 2_1 4_1 2_3 1_3 = 56% failed 
        % 2_1 1_3 2_4 4_4 4_2 4_3 1_4 3_2 1_1

        % TRY MININUM POINT INSTEAD..
        %disp('inflec')
        
        try
            t_wave_indx = find(time >= lower & time <= upper);
            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);
            
            
            t_wave_data = t_wave_data*1000;
            t_wave_orig = t_wave_data;
            %t_wave_data = sgolayfilt(t_wave_data,3,11);
            t_wave_data = wdenoise(t_wave_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');


            poly_time = t_wave_time - t_wave_time(1);
            pfit7 = polyfit(poly_time,t_wave_data,7);
            %pfit5 = polyfit(t_wave_time,t_wave_data,5);
            %pfit4 = polyfit(t_wave_time,t_wave_data,4);



            polynomial7 = polyval(pfit7, poly_time);



            t_wave_dv = gradient(t_wave_orig);
            t_wave_dv_dv = gradient(t_wave_dv);


            t_wave_dv_dv_noisy = t_wave_dv_dv;
            t_wave_dv_dv = wdenoise(t_wave_dv_dv,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');

            %{
            t_wave_dv = wdenoise(t_wave_dv,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
            dv_peak = min(t_wave_dv);
            dv_peak = dv_peak(1);
            t_wave_peak_time = t_wave_time(find(t_wave_dv == dv_peak));
            t_wave_peak = t_wave_orig(find(t_wave_dv == dv_peak));

            %}


            %{

            %}

            %t_wave_peak_time = t_wave_time(find(t_wave_dv_dv == 0))
            %t_wave_peak_time = t_wave_peak_time;
            %t_wave_peak = t_wave_orig(t_wave_time == t_wave_peak_time);
            %t_wave_peak_time = interp1(t_wave_dv_dv, t_wave_time, 0)


            pos_indx = find(t_wave_dv_dv >= 0);
            pos_dv_dv = t_wave_dv_dv(pos_indx);
            neg_indx = find(t_wave_dv_dv <= 0);
            neg_dv_dv = t_wave_dv_dv(neg_indx);

            [zero_indx] = intersect(neg_indx, pos_indx);
            %correctly sorted
            sort_pos_dv_dv = sort(pos_dv_dv);
            roots = sort_pos_dv_dv(1:7);
            [~, ~, indx_roots] = intersect(roots, t_wave_dv_dv);
            indx_roots = sort(indx_roots);
            t_wave_peak_times = t_wave_time(indx_roots);

            for i = 2:length(t_wave_peak_times)
                try
                    %{
                    disp('i')
                    disp(i)
                    disp(t_wave_peak_times(i))
                    disp('i-1')
                    disp(i-1)
                    disp(t_wave_peak_times(i-1))
                    %}
                    if isalmost(t_wave_peak_times(i-1), t_wave_peak_times(i), 0.08)
                        %disp('cutting i')
                        %t_wave_peak_times
                        half1 = t_wave_peak_times(1:i-1);
                        half2 = t_wave_peak_times(i+1:end);

                        t_wave_peak_times = vertcat(half1, half2);
                    end
                catch
                    break;
                end
            end


            [~, ~, indx_peaks] = intersect(t_wave_peak_times, t_wave_time);



            t_wave_peaks = t_wave_orig(indx_peaks);

            t_wave_peak_time = t_wave_peak_times(2);
            t_wave_peak = t_wave_peaks(2);

            %{
            if strcmp(electrode_id, 'A02_4_4')
                disp(t_wave_peak_times)
                disp(t_wave_peaks)
                figure()
                hold on;
                plot(t_wave_time, t_wave_orig)
                plot(t_wave_time, t_wave_data);
                %plot(t_wave_time, polynomial7);
                plot(t_wave_time, t_wave_dv_dv_noisy);
                plot(t_wave_time, t_wave_dv_dv);

                %plot(t_wave_time_dt, dvdvdt_polynomial7);
                plot(t_wave_peak_times, t_wave_peaks, 'ro');
                plot(t_wave_peak_time, t_wave_peak, 'bo');
                hold off;
            end
            %}


            t_wave_peak = t_wave_peak/1000;
        catch
            t_wave_peak = NaN;
            t_wave_peak_time = NaN;
        end


    elseif strcmp(peak_analysis, 'zero crossing') 
        try
            disp('zero')

            post_spike_indx = find(time >= time(1)+post_spike_holdoff);
            post_spike_indx = post_spike_indx(1);
            baseline_voltage = data(post_spike_indx);
            lower = time(1)+ est_peak_time - t_wave_search_duration/2;
            if post_spike_holdoff >= time(end)-time(1)
                post_spike_holdoff = time(end)-time(1)/4;
            end
            if lower < time(1)+post_spike_holdoff
                lower = time(1)+post_spike_holdoff;
            end

            upper = time(1)+ est_peak_time + t_wave_search_duration/2;

            if upper > time(end)
                upper = time(end);
            end
            t_wave_indx = find(time >= lower & time <= upper);
            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);

            t_wave_data = t_wave_data*1000;
            t_wave_orig = t_wave_data;
            %t_wave_data = sgolayfilt(t_wave_data,3,11);
            t_wave_data = wdenoise(t_wave_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');


            poly_time = t_wave_time - t_wave_time(1);
            pfit7 = polyfit(poly_time,t_wave_data,7);
            %pfit5 = polyfit(t_wave_time,t_wave_data,5);
            %pfit4 = polyfit(t_wave_time,t_wave_data,4);

            polynomial7 = polyval(pfit7, poly_time);


            t_wave_dv = gradient(t_wave_orig);
            t_wave_dv_dv = gradient(t_wave_dv);

            t_wave_dv_dv_noisy = t_wave_dv_dv;
            t_wave_dv_dv = wdenoise(t_wave_dv_dv,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');


            t_wave_time_dt = gradient(t_wave_time);


            %{

            %}

            %t_wave_peak_time = t_wave_time(find(t_wave_dv_dv == 0))
            %t_wave_peak_time = t_wave_peak_time;
            %t_wave_peak = t_wave_orig(t_wave_time == t_wave_peak_time);
            %t_wave_peak_time = interp1(t_wave_dv_dv, t_wave_time, 0)

            pos_indx = find(t_wave_dv_dv >= 0);
            pos_dv_dv = t_wave_dv_dv(pos_indx);
            neg_indx = find(t_wave_dv_dv <= 0);
            neg_dv_dv = t_wave_dv_dv(neg_indx);

            [zero_indx] = intersect(neg_indx, pos_indx);
            %correctly sorted
            sort_pos_dv_dv = sort(pos_dv_dv);
            roots = sort_pos_dv_dv(1:7);
            [~, ~, indx_roots] = intersect(roots, t_wave_dv_dv);
            indx_roots = sort(indx_roots);
            t_wave_peak_times = t_wave_time(indx_roots);

            for i = 2:length(t_wave_peak_times)
                try
                    if isalmost(t_wave_peak_times(i-1), t_wave_peak_times(i), 0.08)
                        t_wave_peak_times
                        half1 = t_wave_peak_times(1:i-1)
                        half2 = t_wave_peak_times(i+1:end)

                        t_wave_peak_times = vertcat(half1, half2)
                    end
                catch
                    break;
                end
            end

            %sorted_peak_times = sort(t_wave_peak_times);
            %t_wave_peak_time = sorted_peak_times(2);



            %t_wave_peak_time = fzero(@(x)(t_wave_dv_dv), t_wave_time(1))
            %t_wave_peak_time = t_wave_peak_time;
            %t_wave_peak = interp1(t_wave_time, t_wave_data, t_wave_peak_time)
            [~, ~, indx_peaks] = intersect(t_wave_peak_times, t_wave_time);


            %t_indx = find(t_wave_time >= t_wave_peak_time);
            %t_wave_peak = t_wave_orig(t_indx(1))
            t_wave_peaks = t_wave_orig(indx_peaks);

            t_wave_peak_time = t_wave_peak_times(2);
            t_wave_peak = t_wave_peaks(2);

            m = gradient(t_wave_orig(find(t_wave_time==t_wave_peak_time)));

            tangent_eqn = @(x) m*(x-t_wave_peak_time)+t_wave_peak == 0;
            tangent_line = tangent_eqn(t_wave_time);
            baseline_indx = find(tangent_line == baseline_voltage);
            intersect_baseline = t_wave_time(baseline_indx)

            baseline_voltage



            figure()
            hold on;
            plot(t_wave_time, t_wave_orig)
            plot(t_wave_time, t_wave_data);
            %plot(t_wave_time, polynomial7);
            plot(t_wave_time, t_wave_dv_dv_noisy);
            plot(t_wave_time, t_wave_dv_dv);

            %plot(t_wave_time_dt, dvdvdt_polynomial7);
            plot(t_wave_peak_times, t_wave_peaks, 'ro');
            plot(t_wave_peak_time, t_wave_peak, 'bo');
            plot(intersect_baseline, baseline_voltage, 'co');
            hold off;


            t_wave_peak = t_wave_peak/1000;
        catch
            t_wave_peak = NaN;
            t_wave_peak_time = NaN;
        end

    end  
       
    %disp(activation_time)
    %t_wave_peak_time = t_wave_peak_times(1);
    FPD = t_wave_peak_time - activation_time;
    %FPD = 1;


end