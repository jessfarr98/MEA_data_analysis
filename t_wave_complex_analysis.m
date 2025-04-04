function [t_wave_peak_time, t_wave_peak, FPD, warning, t_wave_indx_start, t_wave_indx_end, time_filtered, polynomial, wavelet_family, best_p_degree] = t_wave_complex_analysis(time, data, beat_to_beat, activation_time, beat_no, spon_paced, peak_analysis, t_wave_peak, t_wave_search_duration, post_spike_holdoff, est_peak_time, est_fpd, electrode_id, filter_intensity, warning)
    
    
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
    
    polynomial = [];
    time_filtered = [];
    wavelet_family = '';
    best_p_degree = nan;
    
    
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
            
            time_filtered = t_wave_time(1:20:end);
            filtered_data = t_wave_data(1:20:end);
            
            down_sampled = filtered_data;
            filtered_data_sym8 = wdenoise(filtered_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
            filtered_data_coif5 = wdenoise(filtered_data,'Wavelet', 'coif5', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
            filtered_data_db4 = wdenoise(filtered_data,'Wavelet', 'db4', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');


            sym8_rsq = 1-(sum((down_sampled-filtered_data_sym8).^2)/(sum((down_sampled-mean(down_sampled)).^2))); 
            coif5_rsq = 1-(sum((down_sampled-filtered_data_coif5).^2)/(sum((down_sampled-mean(down_sampled)).^2)));       
            db4_rsq = 1-(sum((down_sampled-filtered_data_db4).^2)/(sum((down_sampled-mean(down_sampled)).^2)));       

            if sym8_rsq > coif5_rsq
                if sym8_rsq > db4_rsq
                    wavelet_family = 'sym8';
                    filtered_data = filtered_data_sym8;
                else
                    wavelet_family = 'db4';
                    filtered_data = filtered_data_db4;

                end

            else
                if coif5_rsq > db4_rsq
                    wavelet_family = 'coif5';
                    filtered_data = filtered_data_coif5;
                else
                    wavelet_family = 'db4';
                    filtered_data = filtered_data_db4;

                end

            end

            [fr, fc] = size(filtered_data);
            if fc == 1
                filtered_data = reshape(filtered_data, [fc, fr]);
            end
            
            [ftr, ftc] = size(time_filtered);
            if ftc == 1
                time_filtered = reshape(time_filtered, [ftc, ftr]);
            end
            
            poly_time = time_filtered - time_filtered(1);

            best_rsq = nan;
            best_p_degree = nan;
            
            %{
            for p_degree = 3:2:21
                pfit = polyfit(poly_time,filtered_data,p_degree);
                polynomial = polyval(pfit, poly_time);
                poly_rsq = 1-(sum((filtered_data-polynomial).^2)/(sum((filtered_data-mean(filtered_data)).^2)));
                if isnan(best_rsq)
                    best_rsq = poly_rsq;
                    best_p_degree = p_degree;

                else
                    if poly_rsq > best_rsq
                        best_rsq = poly_rsq;
                        best_p_degree = p_degree;
                    end
                end

            end
            %}
            best_p_degree = 21;

            pfit = polyfit(poly_time,filtered_data,best_p_degree);
            polynomial = polyval(pfit, poly_time);
            

            t_wave_peak = max(polynomial);
            t_wave_peak = t_wave_peak(1);
            t_wave_peak_time = time_filtered(polynomial == t_wave_peak);
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
            
            time_filtered = t_wave_time(1:20:end);
            filtered_data = t_wave_data(1:20:end);
            
            down_sampled = filtered_data;
            filtered_data_sym8 = wdenoise(filtered_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
            filtered_data_coif5 = wdenoise(filtered_data,'Wavelet', 'coif5', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
            filtered_data_db4 = wdenoise(filtered_data,'Wavelet', 'db4', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');


            sym8_rsq = 1-(sum((down_sampled-filtered_data_sym8).^2)/(sum((down_sampled-mean(down_sampled)).^2))); 
            coif5_rsq = 1-(sum((down_sampled-filtered_data_coif5).^2)/(sum((down_sampled-mean(down_sampled)).^2)));       
            db4_rsq = 1-(sum((down_sampled-filtered_data_db4).^2)/(sum((down_sampled-mean(down_sampled)).^2)));       

            if sym8_rsq > coif5_rsq
                if sym8_rsq > db4_rsq
                    wavelet_family = 'sym8';
                    filtered_data = filtered_data_sym8;
                else
                    wavelet_family = 'db4';
                    filtered_data = filtered_data_db4;

                end

            else
                if coif5_rsq > db4_rsq
                    wavelet_family = 'coif5';
                    filtered_data = filtered_data_coif5;
                else
                    wavelet_family = 'db4';
                    filtered_data = filtered_data_db4;

                end

            end

            [fr, fc] = size(filtered_data);
            if fc == 1
                filtered_data = reshape(filtered_data, [fc, fr]);
            end
            
            [ftr, ftc] = size(time_filtered);
            if ftc == 1
                time_filtered = reshape(time_filtered, [ftc, ftr]);
            end
            
            poly_time = time_filtered - time_filtered(1);

            best_rsq = nan;
            best_p_degree = nan;
            %{
            for p_degree = 3:2:21
               
                pfit = polyfit(poly_time,filtered_data,p_degree);
                polynomial = polyval(pfit, poly_time);
                poly_rsq = 1-(sum((filtered_data-polynomial).^2)/(sum((filtered_data-mean(filtered_data)).^2)));
                if isnan(best_rsq)
                    best_rsq = poly_rsq;
                    best_p_degree = p_degree;

                else
                    if poly_rsq > best_rsq
                        best_rsq = poly_rsq;
                        best_p_degree = p_degree;
                    end
                end

            end
            %}
            best_p_degree = 21;

            pfit = polyfit(poly_time,filtered_data,best_p_degree);
            polynomial = polyval(pfit, poly_time);
            
 
            t_wave_peak = min(polynomial);
            t_wave_peak = t_wave_peak(1);
            t_wave_peak_time = time_filtered(polynomial == t_wave_peak);
            t_wave_peak_time = t_wave_peak_time(1);
            
            
            %{
            figure()
            hold on;
            plot(t_wave_time, t_wave_data)
            plot(time_filtered, filtered_data)
            plot(time_filtered, polynomial)
            plot(t_wave_peak_time, t_wave_peak, 'ro')
            hold off;
            pause(10)
            %}
            %t_wave_peak = t_wave_peak(1);
            
            %{
            figure()
            hold on;
            plot(t_wave_time, t_wave_orig)
            plot(t_wave_time, t_wave_data)
            plot(t_wave_peak_time, t_wave_peak, 'r.')
            hold off;
            %}
            
        catch
            t_wave_peak_time = NaN;
            t_wave_peak = NaN;
        end
                
    elseif strcmp(peak_analysis, 'inflection') 
        % 4_4 3_1 1_1 1_2 2_2 2_1 4_1 2_3 1_3 = 56% failed 
        % 2_1 1_3 2_4 4_4 4_2 4_3 1_4 3_2 1_1

        % TRY MININUM POINT INSTEAD..
        %disp('inflec')
        
        
        %{
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
        
        if ((t_wave_peak_time >= t_wave_max_time)&&(t_wave_peak_time >= t_wave_min_time))|| ((t_wave_peak_time <= t_wave_min_time)&&(t_wave_max_time >= t_wave_peak_time))
            if strcmp(warning, '')
                warning = {'T-wave inflection point outside expected range'};
            else
                warning = strcat({' '}, {'and T-wave inflection point outside expected range'});
            end

        end
        %}
        
        try 
            t_wave_indx = find(time >= lower & time <= upper);
            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);

            t_wave_orig = t_wave_data;
            %t_wave_data = t_wave_data(1:20:end);

            %

            t_wave_max_indx = find(t_wave_data == max(t_wave_data), 1);
            t_wave_min_indx = find(t_wave_data == min(t_wave_data), 1);

            t_wave_max_time = t_wave_time(t_wave_max_indx);

            t_wave_min_time = t_wave_time(t_wave_min_indx);

            
            
            filtration_rate = 20;


            [dr, dc] = size(t_wave_data);
            [tr, tc] = size(t_wave_time);

            if t_wave_min_indx < t_wave_max_indx
                
                
                if dc == 1
                    filtered_data = vertcat(t_wave_data(1:filtration_rate:t_wave_min_indx), t_wave_data(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_data(t_wave_max_indx:filtration_rate:end));

                else


                    filtered_data = horzcat(t_wave_data(1:filtration_rate:t_wave_min_indx), t_wave_data(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_data(t_wave_max_indx:filtration_rate:end));

                end

                down_sampled = filtered_data;
                filtered_data_sym8 = wdenoise(filtered_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_coif5 = wdenoise(filtered_data,'Wavelet', 'coif5', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_db4 = wdenoise(filtered_data,'Wavelet', 'db4', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                
                
                sym8_rsq = 1-(sum((down_sampled-filtered_data_sym8).^2)/(sum((down_sampled-mean(down_sampled)).^2))); 
                coif5_rsq = 1-(sum((down_sampled-filtered_data_coif5).^2)/(sum((down_sampled-mean(down_sampled)).^2)));       
                db4_rsq = 1-(sum((down_sampled-filtered_data_db4).^2)/(sum((down_sampled-mean(down_sampled)).^2)));       
            
                if sym8_rsq > coif5_rsq
                    if sym8_rsq > db4_rsq
                        wavelet_family = 'sym8';
                        filtered_data = filtered_data_sym8;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                else
                    if coif5_rsq > db4_rsq
                        wavelet_family = 'coif5';
                        filtered_data = filtered_data_coif5;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                end
                
                if tc == 1
                    time_filtered = vertcat(t_wave_time(1:filtration_rate:t_wave_min_indx), t_wave_time(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_time(t_wave_max_indx:filtration_rate:end));

                else
                    time_filtered = horzcat(t_wave_time(1:filtration_rate:t_wave_min_indx), t_wave_time(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_time(t_wave_max_indx:filtration_rate:end));

                end

                [fr, fc] = size(filtered_data);
                if fc == 1
                    filtered_data = reshape(filtered_data, [fc, fr]);
                end
                
                [ftr, ftc] = size(time_filtered);
                if ftc == 1
                    time_filtered = reshape(time_filtered, [ftc, ftr]);
                end
                
                poly_time = time_filtered - time_filtered(1);

                best_rsq = nan;
                best_p_degree = nan;
                %{
                for p_degree = 3:2:21
                    pfit = polyfit(poly_time,filtered_data,p_degree);
                    polynomial = polyval(pfit, poly_time);
                    poly_rsq = 1-(sum((filtered_data-polynomial).^2)/(sum((filtered_data-mean(filtered_data)).^2)));
                    if isnan(best_rsq)
                        best_rsq = poly_rsq;
                        best_p_degree = p_degree;
                        
                    else
                        if poly_rsq > best_rsq
                            best_rsq = poly_rsq;
                            best_p_degree = p_degree;
                        end
                    end
                    
                end
                %}
                best_p_degree = 21;
                
                pfit = polyfit(poly_time,filtered_data,best_p_degree);
                polynomial = polyval(pfit, poly_time);
                %depol_complex_time_filtered = depol_complex_time;

                %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');

                t_wave_data_derivative = gradient(polynomial);

            else
                if dc == 1
                    filtered_data = vertcat(t_wave_data(1:filtration_rate:t_wave_max_indx), t_wave_data(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_data(t_wave_min_indx:filtration_rate:end));

                else

                    filtered_data = horzcat(t_wave_data(1:filtration_rate:t_wave_max_indx), t_wave_data(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_data(t_wave_min_indx:filtration_rate:end));

                end
                
                down_sampled = filtered_data;
                filtered_data_sym8 = wdenoise(filtered_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_coif5 = wdenoise(filtered_data,'Wavelet', 'coif5', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_db4 = wdenoise(filtered_data,'Wavelet', 'db4', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                
                
                sym8_rsq = 1-(sum((down_sampled-filtered_data_sym8).^2)/(sum((down_sampled-mean(down_sampled)).^2)));
                coif5_rsq = 1-(sum((down_sampled-filtered_data_coif5).^2)/(sum((down_sampled-mean(down_sampled)).^2)));     
                db4_rsq = 1-(sum((down_sampled-filtered_data_db4).^2)/(sum((down_sampled-mean(down_sampled)).^2)));     
                
                if sym8_rsq > coif5_rsq
                    if sym8_rsq > db4_rsq
                        wavelet_family = 'sym8';
                        filtered_data = filtered_data_sym8;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                else
                    if coif5_rsq > db4_rsq
                        wavelet_family = 'coif5';
                        filtered_data = filtered_data_coif5;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                end
                

                [fr, fc] = size(filtered_data);
                if fc == 1
                    filtered_data = reshape(filtered_data, [fc, fr]);
                end
                
                
            
                if tc == 1
                    time_filtered = vertcat(t_wave_time(1:filtration_rate:t_wave_max_indx), t_wave_time(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_time(t_wave_min_indx:filtration_rate:end));

                else

                    time_filtered = horzcat(t_wave_time(1:filtration_rate:t_wave_max_indx), t_wave_time(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_time(t_wave_min_indx:filtration_rate:end));

                end
                
                [ftr, ftc] = size(time_filtered);
                if ftc == 1
                    time_filtered = reshape(time_filtered, [ftc, ftr]);
                end

                poly_time = time_filtered - time_filtered(1);

                best_rsq = nan;
                best_p_degree = nan;
                %{
                for p_degree = 3:2:21
                    pfit = polyfit(poly_time,filtered_data,p_degree);
                    polynomial = polyval(pfit, poly_time);
                    poly_rsq = 1-(sum((filtered_data-polynomial).^2)/(sum((filtered_data-mean(filtered_data)).^2)));
                    if isnan(best_rsq)
                        best_rsq = poly_rsq;
                        best_p_degree = p_degree;
                        
                    else
                        if poly_rsq > best_rsq
                            best_rsq = poly_rsq;
                            best_p_degree = p_degree;
                        end
                    end
                    
                end
                %}
                best_p_degree = 21;
                
                pfit = polyfit(poly_time,filtered_data,best_p_degree);
                polynomial = polyval(pfit, poly_time);
                %depol_complex_time_filtered = depol_complex_time;

                %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');

                t_wave_data_derivative = gradient(polynomial);

            end

            min_raw_slope = min(t_wave_data_derivative);
            max_raw_slope = max(t_wave_data_derivative);
            max_abs_slope = max(abs(t_wave_data_derivative));

            repol_indx_min_raw = find(t_wave_data_derivative == min_raw_slope);
            repol_indx_max_raw = find(t_wave_data_derivative == max_raw_slope);
            repol_indx_max_abs = find(abs(t_wave_data_derivative) == max_abs_slope);

            min_raw_repol_time = time_filtered(repol_indx_min_raw(1));
            max_raw_repol_time = time_filtered(repol_indx_max_raw(1));
            max_abs_repol_time = time_filtered(repol_indx_max_abs(1));

            if ((t_wave_max_time >= min_raw_repol_time)&& (min_raw_repol_time>= t_wave_min_time)) || ((t_wave_min_time >= min_raw_repol_time) && (min_raw_repol_time>= t_wave_max_time))
                t_wave_peak = filtered_data(repol_indx_min_raw(1));

                t_wave_peak_time = time_filtered(repol_indx_min_raw(1));

            else
                if ((t_wave_max_time >= max_abs_repol_time)&& (max_abs_repol_time>= t_wave_min_time)) || ((t_wave_min_time >= max_abs_repol_time)&& (max_abs_repol_time>= t_wave_max_time))
                    t_wave_peak = filtered_data(repol_indx_max_abs(1));

                    t_wave_peak_time = time_filtered(repol_indx_max_abs(1));
                else

                    if ((t_wave_max_time >= max_raw_repol_time)&& (max_raw_repol_time>= t_wave_min_time)) || ((t_wave_min_time >= max_raw_repol_time)&& (max_raw_repol_time>= t_wave_max_time))
                        t_wave_peak = filtered_data(repol_indx_max_raw(1));

                        t_wave_peak_time = time_filtered(repol_indx_max_raw(1));
                    else
                        if t_wave_min_time < t_wave_max_time
                            t_wave_peak = filtered_data(repol_indx_max_abs(1));

                            t_wave_peak_time = time_filtered(repol_indx_max_abs(1));

                            if strcmp(warning, '')
                                warning = {'T-wave inflection point outside expected range'};
                            else
                                warning = strcat(warning, {' '}, 'and T-wave inflection point outside expected range');
                            end
                        else
                            t_wave_peak = filtered_data(repol_indx_min_raw(1));

                            t_wave_peak_time = time_filtered(repol_indx_min_raw(1));

                            if strcmp(warning, '')
                                warning = {'T-wave inflection point outside expected range'};
                            else
                                warning = strcat(warning, {' '}, 'and T-wave inflection point outside expected range');
                            end
                        end
                    end
                end
            end
            
            
            %{
            figure()
            hold on;
            plot(t_wave_time, t_wave_data)
            plot(time_filtered, down_sampled, 'LineWidth',7)
            plot(time_filtered, filtered_data, 'LineWidth',7)
            plot(time_filtered, polynomial, 'LineWidth',7)
            %{
            plot(time_filtered, polynomial11, 'LineWidth',7)
            plot(time_filtered, polynomial9, 'LineWidth',7)
            plot(time_filtered, polynomial7, 'LineWidth',7)
            plot(time_filtered, polynomial5, 'LineWidth',7)
            plot(time_filtered, polynomial3, 'LineWidth',7)
            %}
            plot(t_wave_peak_time, t_wave_peak, 'ro')
            legend('orig', 'down sampled', 'filtered', 'polyfit')
            %legend('orig', 'down sampled', 'filtered', 'poly11', 'poly9', 'poly7', 'ploy5', 'poly3');
            hold off;

            pause(10)
            %}
  
        catch
            t_wave_peak_time = nan;
            t_wave_peak = nan;
            
        end
            
        
    elseif strcmp(peak_analysis, 'zero crossing')
        
        %try 
              
                
            t_wave_indx = find(time >= lower & time <= upper);
            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);
           

            t_wave_orig = t_wave_data;
            %t_wave_data = t_wave_data(1:20:end);

            t_wave_max_indx = find(t_wave_data == max(t_wave_data), 1);
            t_wave_min_indx = find(t_wave_data == min(t_wave_data), 1);

            t_wave_max_time = t_wave_time(t_wave_max_indx);

            t_wave_min_time = t_wave_time(t_wave_min_indx);

            
            
            filtration_rate = 20;


            [dr, dc] = size(t_wave_data);
            [tr, tc] = size(t_wave_time);

            if t_wave_min_indx < t_wave_max_indx
                
                
                if dc == 1
                    filtered_data = vertcat(t_wave_data(1:filtration_rate:t_wave_min_indx), t_wave_data(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_data(t_wave_max_indx:filtration_rate:end));

                else


                    filtered_data = horzcat(t_wave_data(1:filtration_rate:t_wave_min_indx), t_wave_data(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_data(t_wave_max_indx:filtration_rate:end));

                end

                down_sampled = filtered_data;
                filtered_data_sym8 = wdenoise(filtered_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_coif5 = wdenoise(filtered_data,'Wavelet', 'coif5', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_db4 = wdenoise(filtered_data,'Wavelet', 'db4', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                
                
                sym8_rsq = 1-(sum((down_sampled-filtered_data_sym8).^2)/(sum((down_sampled-mean(down_sampled)).^2))); 
                coif5_rsq = 1-(sum((down_sampled-filtered_data_coif5).^2)/(sum((down_sampled-mean(down_sampled)).^2)));       
                db4_rsq = 1-(sum((down_sampled-filtered_data_db4).^2)/(sum((down_sampled-mean(down_sampled)).^2)));       
            
                if sym8_rsq > coif5_rsq
                    if sym8_rsq > db4_rsq
                        wavelet_family = 'sym8';
                        filtered_data = filtered_data_sym8;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                else
                    if coif5_rsq > db4_rsq
                        wavelet_family = 'coif5';
                        filtered_data = filtered_data_coif5;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                end
                
                
                
                if tc == 1
                    time_filtered = vertcat(t_wave_time(1:filtration_rate:t_wave_min_indx), t_wave_time(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_time(t_wave_max_indx:filtration_rate:end));

                else
                    time_filtered = horzcat(t_wave_time(1:filtration_rate:t_wave_min_indx), t_wave_time(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_time(t_wave_max_indx:filtration_rate:end));

                end
                
                [fr, fc] = size(filtered_data);
                if fc == 1
                    filtered_data = reshape(filtered_data, [fc, fr]);
                end
                
                [ftr, ftc] = size(time_filtered);
                if ftc == 1
                    time_filtered = reshape(time_filtered, [ftc, ftr]);
                end

                poly_time = time_filtered - time_filtered(1);

                best_rsq = nan;
                best_p_degree = nan;
                %{
                for p_degree = 3:2:21
                    pfit = polyfit(poly_time,filtered_data,p_degree);
                    polynomial = polyval(pfit, poly_time);
                    poly_rsq = 1-(sum((filtered_data-polynomial).^2)/(sum((filtered_data-mean(filtered_data)).^2)));
                    if isnan(best_rsq)
                        best_rsq = poly_rsq;
                        best_p_degree = p_degree;
                        
                    else
                        if poly_rsq > best_rsq
                            best_rsq = poly_rsq;
                            best_p_degree = p_degree;
                        end
                    end
                    
                end
                %}
                best_p_degree = 21;
                
                pfit = polyfit(poly_time,filtered_data,best_p_degree);
                polynomial = polyval(pfit, poly_time);
                %depol_complex_time_filtered = depol_complex_time;

                %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');

                %t_wave_data_derivative = gradient(polynomial);
                
                min_filtered_t_wave = min(polynomial);
                max_filtered_t_wave = max(polynomial);
                
                min_filtered_t_wave_indx = find(polynomial == min_filtered_t_wave);
                max_filtered_t_wave_indx = find(polynomial == max_filtered_t_wave);
                
                min_filtered_t_wave_indx = min_filtered_t_wave_indx(1);
                max_filtered_t_wave_indx = max_filtered_t_wave_indx(1);
               
                min_filtered_t_wave_time = time_filtered(min_filtered_t_wave_indx)-time_filtered(1);
                max_filtered_t_wave_time = time_filtered(max_filtered_t_wave_indx)-time_filtered(1);
                
                %polynomial = polynomial*1000;
            
                poly_roots  = roots(pfit);
                
                all_poly_peaks = polyval(pfit, poly_roots);
                
                poly_roots_correct_range_indx = find(min_filtered_t_wave_time <= poly_roots &  poly_roots<= max_filtered_t_wave_time);
                
                possible_roots = poly_roots(poly_roots_correct_range_indx);
                %real_roots = isreal(poly_roots(poly_roots_correct_range_indx))
                real_array = [];
                for r = 1:length(possible_roots)
                    if imag(possible_roots(r)) == 0
                        real_array = [real_array real(possible_roots(r))];
                    end
                end
                
                if length(real_array) < 1
                    t_wave_peak_time = nan;
                    t_wave_peak = nan;
                elseif length(real_array) == 1
                    t_wave_peak_time = (real_array(1))+time_filtered(1);
                    t_wave_peak = polyval(pfit, real_array(1)); 
                else
                    t_wave_peak_time = (real_array(1))+time_filtered(1);
                    t_wave_peak = polyval(pfit, real_array(1)); 
                    
                end
                
                %{
                
                figure();
                hold on;
                plot(poly_time, polynomial);
                plot(t_wave_peak_time, t_wave_peak, 'ro');
                %plot(poly_roots, all_poly_peaks, 'ko');
                hold off;
                
                
                pause(10)
                %}
                
               % t_wave_peak_time = nan;
                %t_wave_peak = nan;
                
               

            else
                if dc == 1
                    filtered_data = vertcat(t_wave_data(1:filtration_rate:t_wave_max_indx), t_wave_data(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_data(t_wave_min_indx:filtration_rate:end));

                else

                    filtered_data = horzcat(t_wave_data(1:filtration_rate:t_wave_max_indx), t_wave_data(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_data(t_wave_min_indx:filtration_rate:end));

                end
                
                down_sampled = filtered_data;
                filtered_data_sym8 = wdenoise(filtered_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_coif5 = wdenoise(filtered_data,'Wavelet', 'coif5', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_db4 = wdenoise(filtered_data,'Wavelet', 'db4', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                
                
                sym8_rsq = 1-(sum((down_sampled-filtered_data_sym8).^2)/(sum((down_sampled-mean(down_sampled)).^2)));
                coif5_rsq = 1-(sum((down_sampled-filtered_data_coif5).^2)/(sum((down_sampled-mean(down_sampled)).^2)));     
                db4_rsq = 1-(sum((down_sampled-filtered_data_db4).^2)/(sum((down_sampled-mean(down_sampled)).^2)));     
                
                if sym8_rsq > coif5_rsq
                    if sym8_rsq > db4_rsq
                        wavelet_family = 'sym8';
                        filtered_data = filtered_data_sym8;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                else
                    if coif5_rsq > db4_rsq
                        wavelet_family = 'coif5';
                        filtered_data = filtered_data_coif5;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                end
                

                if tc == 1
                    time_filtered = vertcat(t_wave_time(1:filtration_rate:t_wave_max_indx), t_wave_time(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_time(t_wave_min_indx:filtration_rate:end));

                else

                    time_filtered = horzcat(t_wave_time(1:filtration_rate:t_wave_max_indx), t_wave_time(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_time(t_wave_min_indx:filtration_rate:end));

                end
                
                [fr, fc] = size(filtered_data);
                if fc == 1
                    filtered_data = reshape(filtered_data, [fc, fr]);
                end
                
                [ftr, ftc] = size(time_filtered);
                if ftc == 1
                    time_filtered = reshape(time_filtered, [ftc, ftr]);
                end

                poly_time = time_filtered - time_filtered(1);

                best_rsq = nan;
                best_p_degree = nan;
                %{
                for p_degree = 3:2:21
                    pfit = polyfit(poly_time,filtered_data,p_degree);
                    polynomial = polyval(pfit, poly_time);
                    poly_rsq = 1-(sum((filtered_data-polynomial).^2)/(sum((filtered_data-mean(filtered_data)).^2)));
                    if isnan(best_rsq)
                        best_rsq = poly_rsq;
                        best_p_degree = p_degree;
                        
                    else
                        if poly_rsq > best_rsq
                            best_rsq = poly_rsq;
                            best_p_degree = p_degree;
                        end
                    end
                    
                end
                %}
                best_p_degree = 21;
                
                pfit = polyfit(poly_time,filtered_data,best_p_degree);
                polynomial = polyval(pfit, poly_time);
                %depol_complex_time_filtered = depol_complex_time;

                %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');

                min_filtered_t_wave = min(polynomial);
                max_filtered_t_wave = max(polynomial);
                
                min_filtered_t_wave_indx = find(polynomial == min_filtered_t_wave);
                max_filtered_t_wave_indx = find(polynomial == max_filtered_t_wave);
                
                min_filtered_t_wave_indx = min_filtered_t_wave_indx(1);
                max_filtered_t_wave_indx = max_filtered_t_wave_indx(1);
               
                min_filtered_t_wave_time = time_filtered(min_filtered_t_wave_indx) -time_filtered(1);
                max_filtered_t_wave_time = time_filtered(max_filtered_t_wave_indx) -time_filtered(1);
                
                %polynomial = polynomial*1000;
            
                poly_roots  = roots(pfit);
                all_poly_peaks = polyval(pfit, poly_roots);
                
                poly_roots_correct_range_indx = find(max_filtered_t_wave_time <= poly_roots & poly_roots<= min_filtered_t_wave_time);
                
                
                possible_roots = poly_roots(poly_roots_correct_range_indx);
                %real_roots = isreal(poly_roots(poly_roots_correct_range_indx))
                real_array = [];
                for r = 1:length(possible_roots)
                    if imag(possible_roots(r)) == 0
                        real_array = [real_array real(possible_roots(r))];
                    end
                end
                
                if length(real_array) < 1
                    t_wave_peak_time = nan;
                    t_wave_peak = nan;
                elseif length(real_array) == 1
                    t_wave_peak_time = (real_array(1))+time_filtered(1);
                    t_wave_peak = polyval(pfit, real_array(1)); 
                else
                    t_wave_peak_time = (real_array(1))+time_filtered(1);
                    t_wave_peak = polyval(pfit, real_array(1)); 
                    
                end
                
                %{
                figure();
                hold on;
                plot(poly_time, polynomial);
                plot(t_wave_peak_time, t_wave_peak, 'ro');
                %plot(poly_roots, all_poly_peaks, 'ko');
                hold off;
                
                
                pause(10)
                %}
                
            end
            
            


            
            %cartesian_x = linspace(1, length(polynomial), length(polynomial));
            
            
            %[~, poly_root_indxs, ~] = intersect();
           
            %disp(polynomial)
            
            
            %{
            less mathematical
            positive_poly = polynomial(polynomial >= 0);
           
            neg_poly  = polynomial(polynomial < 0);
           
           
            min_pos_poly = min(positive_poly);
           
            max_neg_poly = max(neg_poly);
           
            if min_pos_poly < abs(max_neg_poly)
               zero_point = min_pos_poly;
            else
               zero_point = max_neg_poly;
            end
             
           
            zero_indx = find(polynomial == zero_point);
            zero_indx = zero_indx(1);
            t_wave_peak_time = time_filtered(zero_indx);
            t_wave_peak = polynomial(zero_indx)/1000;
            
            polynomial = polynomial./1000;
            %}
  
        %catch
        %    t_wave_peak_time = nan;
        %    t_wave_peak = nan;
            
        %end
        %{
        % Method using the baseline model/polynomial intercept point
        try 
                
            baseline_indx = find(time >= time(1)+post_spike_holdoff & time < lower);
            baseline_time = time(baseline_indx);
            baseline_data = data(baseline_indx);
            
            lin_eqn = fittype('m*x+b');

            model = fit(baseline_time, baseline_data, lin_eqn);
            
            m = model.m;
            b = model.b;
            %{
            
            %}
                
            t_wave_indx = find(time >= lower & time <= upper);
            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);
            
            extrap_baseline_model = (m.*t_wave_time)+b;
            
            
            %{
            figure()
            hold on;
            plot(time, data)
            plot(baseline_time, baseline_data)
            plot(t_wave_time, extrap_baseline_model)
            hold off;

            pause(10)
            %}

            t_wave_orig = t_wave_data;
            %t_wave_data = t_wave_data(1:20:end);

            %

            t_wave_max_indx = find(t_wave_data == max(t_wave_data), 1);
            t_wave_min_indx = find(t_wave_data == min(t_wave_data), 1);

            t_wave_max_time = t_wave_time(t_wave_max_indx);

            t_wave_min_time = t_wave_time(t_wave_min_indx);

            
            
            filtration_rate = 20;


            [dr, dc] = size(t_wave_data);
            [tr, tc] = size(t_wave_time);

            if t_wave_min_indx < t_wave_max_indx
                
                
                if dc == 1
                    filtered_data = vertcat(t_wave_data(1:filtration_rate:t_wave_min_indx), t_wave_data(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_data(t_wave_max_indx:filtration_rate:end));

                else


                    filtered_data = horzcat(t_wave_data(1:filtration_rate:t_wave_min_indx), t_wave_data(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_data(t_wave_max_indx:filtration_rate:end));

                end

                down_sampled = filtered_data;
                filtered_data_sym8 = wdenoise(filtered_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_coif5 = wdenoise(filtered_data,'Wavelet', 'coif5', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_db4 = wdenoise(filtered_data,'Wavelet', 'db4', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                
                
                sym8_rsq = 1-(sum((down_sampled-filtered_data_sym8).^2)/(sum((down_sampled-mean(down_sampled)).^2))); 
                coif5_rsq = 1-(sum((down_sampled-filtered_data_coif5).^2)/(sum((down_sampled-mean(down_sampled)).^2)));       
                db4_rsq = 1-(sum((down_sampled-filtered_data_db4).^2)/(sum((down_sampled-mean(down_sampled)).^2)));       
            
                if sym8_rsq > coif5_rsq
                    if sym8_rsq > db4_rsq
                        wavelet_family = 'sym8';
                        filtered_data = filtered_data_sym8;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                else
                    if coif5_rsq > db4_rsq
                        wavelet_family = 'coif5';
                        filtered_data = filtered_data_coif5;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                end
                
                if tc == 1
                    time_filtered = vertcat(t_wave_time(1:filtration_rate:t_wave_min_indx), t_wave_time(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_time(t_wave_max_indx:filtration_rate:end));

                else
                    time_filtered = horzcat(t_wave_time(1:filtration_rate:t_wave_min_indx), t_wave_time(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_time(t_wave_max_indx:filtration_rate:end));

                end

                poly_time = time_filtered - time_filtered(1);

                best_rsq = nan;
                best_p_degree = nan;
                for p_degree = 3:2:21
                    pfit = polyfit(poly_time,filtered_data,p_degree);
                    polynomial = polyval(pfit, poly_time);
                    poly_rsq = 1-(sum((filtered_data-polynomial).^2)/(sum((filtered_data-mean(filtered_data)).^2)));
                    if isnan(best_rsq)
                        best_rsq = poly_rsq;
                        best_p_degree = p_degree;
                        
                    else
                        if poly_rsq > best_rsq
                            best_rsq = poly_rsq;
                            best_p_degree = p_degree;
                        end
                    end
                    
                end
                
                pfit = polyfit(poly_time,filtered_data,best_p_degree);
                polynomial = polyval(pfit, poly_time);
                %depol_complex_time_filtered = depol_complex_time;

                %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');

                %t_wave_data_derivative = gradient(polynomial);
                
                
                min_poly = min(polynomial);
                min_poly_indx = find(polynomial == min_poly);
                min_poly_indx = min_poly_indx(1);
                %zero_crossing_search_indx = find(time_filtered >= min(polynomial))
                
                zero_crossing_search_time = time_filtered(min_poly_indx:end);
                zero_crossing_search_data = polynomial(min_poly_indx:end);
                
                search_baseline_model = (m.*zero_crossing_search_time)+b;
                
                if min_poly < search_baseline_model(1)
                    search_direction = 'above';
                    
                else
                    search_direction = 'below';
                    
                end
                
                if strcmp(search_direction, 'below')
                    zero_crossing_indx = find(zero_crossing_search_data <= search_baseline_model);
                    if isempty(zero_crossing_indx)
                        zero_crossing_indx = find(zero_crossing_search_data >= search_baseline_model);
                        if isempty(zero_crossing_indx)
                            t_wave_peak_time = nan;
                            t_wave_peak = nan;
                            return;
                        end
                    
                    end
                    
                else
                    zero_crossing_indx = find(zero_crossing_search_data >= search_baseline_model);
                    if isempty(zero_crossing_indx)
                        zero_crossing_indx = find(zero_crossing_search_data <= search_baseline_model);
                        if isempty(zero_crossing_indx)
                            t_wave_peak_time = nan;
                            t_wave_peak = nan;
                            return;
                        end
                    
                    end
                    
                end
                zero_crossing_indx = zero_crossing_indx(1);
                t_wave_peak_time = zero_crossing_search_time(zero_crossing_indx);
                t_wave_peak = zero_crossing_search_data(zero_crossing_indx);

            else
                if dc == 1
                    filtered_data = vertcat(t_wave_data(1:filtration_rate:t_wave_max_indx), t_wave_data(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_data(t_wave_min_indx:filtration_rate:end));

                else

                    filtered_data = horzcat(t_wave_data(1:filtration_rate:t_wave_max_indx), t_wave_data(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_data(t_wave_min_indx:filtration_rate:end));

                end
                
                down_sampled = filtered_data;
                filtered_data_sym8 = wdenoise(filtered_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_coif5 = wdenoise(filtered_data,'Wavelet', 'coif5', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                filtered_data_db4 = wdenoise(filtered_data,'Wavelet', 'db4', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
                
                
                sym8_rsq = 1-(sum((down_sampled-filtered_data_sym8).^2)/(sum((down_sampled-mean(down_sampled)).^2)));
                coif5_rsq = 1-(sum((down_sampled-filtered_data_coif5).^2)/(sum((down_sampled-mean(down_sampled)).^2)));     
                db4_rsq = 1-(sum((down_sampled-filtered_data_db4).^2)/(sum((down_sampled-mean(down_sampled)).^2)));     
                
                if sym8_rsq > coif5_rsq
                    if sym8_rsq > db4_rsq
                        wavelet_family = 'sym8';
                        filtered_data = filtered_data_sym8;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                else
                    if coif5_rsq > db4_rsq
                        wavelet_family = 'coif5';
                        filtered_data = filtered_data_coif5;
                    else
                        wavelet_family = 'db4';
                        filtered_data = filtered_data_db4;

                    end

                end
                

                if tc == 1
                    time_filtered = vertcat(t_wave_time(1:filtration_rate:t_wave_max_indx), t_wave_time(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_time(t_wave_min_indx:filtration_rate:end));

                else

                    time_filtered = horzcat(t_wave_time(1:filtration_rate:t_wave_max_indx), t_wave_time(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_time(t_wave_min_indx:filtration_rate:end));

                end

                poly_time = time_filtered - time_filtered(1);

                best_rsq = nan;
                best_p_degree = nan;
                for p_degree = 3:2:21
                    pfit = polyfit(poly_time,filtered_data,p_degree);
                    polynomial = polyval(pfit, poly_time);
                    poly_rsq = 1-(sum((filtered_data-polynomial).^2)/(sum((filtered_data-mean(filtered_data)).^2)));
                    if isnan(best_rsq)
                        best_rsq = poly_rsq;
                        best_p_degree = p_degree;
                        
                    else
                        if poly_rsq > best_rsq
                            best_rsq = poly_rsq;
                            best_p_degree = p_degree;
                        end
                    end
                    
                end
                
                pfit = polyfit(poly_time,filtered_data,best_p_degree);
                polynomial = polyval(pfit, poly_time);
                %depol_complex_time_filtered = depol_complex_time;

                %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');

                max_poly = max(polynomial);
                max_poly_indx = find(polynomial == max_poly);
                max_poly_indx = max_poly_indx(1);
                %zero_crossing_search_indx = find(time_filtered >= min(polynomial))
                
                zero_crossing_search_time = time_filtered(max_poly_indx:end);
                zero_crossing_search_data = polynomial(max_poly_indx:end);
                
                search_baseline_model = (m.*zero_crossing_search_time)+b;
                
                if max_poly > search_baseline_model(1)
                    search_direction = 'below';
                    
                else
                    search_direction = 'above';
                    
                end
                
                if strcmp(search_direction, 'below')
                    zero_crossing_indx = find(zero_crossing_search_data <= search_baseline_model);
                    if isempty(zero_crossing_indx)
                        zero_crossing_indx = find(zero_crossing_search_data >= search_baseline_model);
                        if isempty(zero_crossing_indx)
                            t_wave_peak_time = nan;
                            t_wave_peak = nan;
                            return;
                        end
                    
                    end
                    
                else
                    zero_crossing_indx = find(zero_crossing_search_data >= search_baseline_model);
                    if isempty(zero_crossing_indx)
                        zero_crossing_indx = find(zero_crossing_search_data <= search_baseline_model);
                        if isempty(zero_crossing_indx)
                            t_wave_peak_time = nan;
                            t_wave_peak = nan;
                            return;
                        end
                    
                    end
                    
                end
                zero_crossing_indx = zero_crossing_indx(1);
                t_wave_peak_time = zero_crossing_search_time(zero_crossing_indx);
                t_wave_peak = zero_crossing_search_data(zero_crossing_indx);


            end

           
            
            
  
        catch
            t_wave_peak_time = nan;
            t_wave_peak = nan;
            
        end
        %}
            

    end  
       
    
    
    %disp(activation_time)
    %t_wave_peak_time = t_wave_peak_times(1);
    
    if ~isnan(t_wave_peak_time)
        FPD = t_wave_peak_time - activation_time;
    else
        FPD = nan;
    end
    
    if ~isempty(t_wave_indx)
        t_wave_indx_start = t_wave_indx(1);
        t_wave_indx_end = t_wave_indx(end);
    else
        t_wave_indx_start = nan;
        t_wave_indx_end = nan;
        
    end
    %FPD = 1;


end