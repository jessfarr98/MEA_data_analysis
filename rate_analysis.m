%function [activation_time, amplitude, max_depol_time, max_depol_point, min_depol_time, min_depol_point, slope, warning] = rate_analysis(time, data, post_spike_hold_off, stim_spike_hold_off, spon_paced, stim_time, electrode_id, filter_intensity, warning)
function [activation_time, amplitude, max_depol_time, max_depol_point, indx_max_depol_point, min_depol_time, min_depol_point, indx_min_depol_point, slope, warning, pshot_indx_offset, filtered_data, depol_complex_time_filtered] = rate_analysis(time, data, post_spike_hold_off, stim_spike_hold_off, spon_paced, stim_time, electrode_id, filter_intensity, warning)    
    
    if post_spike_hold_off >= time(end)-time(1)
        post_spike_hold_off = time(end)-time(1)/10;
    end
            
    if strcmp(spon_paced, 'spon')
        iters = 1;
        while(1)
            post_spike_hold_off_time = time(1)+post_spike_hold_off;
            pshot_indx = find(time >= post_spike_hold_off_time);
            if length(pshot_indx)>=1
                pshot_indx_offset = pshot_indx(1);
                break;

            end
            post_spike_hold_off = post_spike_hold_off*0.9;
            iters = iters+1;
            if iters == 20
                pshot_indx_offset = length(time);
                break;
            end
        end
        depol_complex_time = time(1:pshot_indx_offset);
        depol_complex_data = data(1:pshot_indx_offset);
    elseif strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
        start_time_indx = find(time >= time(1)+stim_spike_hold_off);
        
        %start_time_indx(1)
        iters = 1;
        while(1)
            post_spike_hold_off_time = time(1)+post_spike_hold_off;
            pshot_indx = find(time >= post_spike_hold_off_time);
            if length(pshot_indx)>=1
                pshot_indx_offset = pshot_indx(1);
                break;
            end
            post_spike_hold_off = post_spike_hold_off*0.9;
            iters = iters+1;
            if iters == 20
                pshot_indx_offset = length(time);
                break;
            end
        end
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
            
            % make it require at least 40 elements so strong filtering can be applied if opted for
            if length(depol_complex_time) < 40
                depol_complex_time = time;
                depol_complex_data = data;
            end
        catch 
            %disp('catch')
            depol_complex_time = time(1:pshot_indx_offset);
            depol_complex_data = data(1:pshot_indx_offset);
            %disp(length(depol_complex_time))
            % make it require at least 40 elements so strong filtering can be applied if opted for
            if length(depol_complex_time) < 40
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
        
        
        
        %{
        if dc == 1
            %filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1), depol_complex_data(indx_max_depol_point:filtration_rate:end));
            filtered_data = depol_complex_data(1:filtration_rate:indx_min_depol_point);
            
        else

            
            %filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1), depol_complex_data(indx_max_depol_point:filtration_rate:end));
            
        end
        
        if tc == 1
            depol_complex_time_filtered = vertcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1), depol_complex_time(indx_max_depol_point:filtration_rate:end));
        
        else
            depol_complex_time_filtered = horzcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1), depol_complex_time(indx_max_depol_point:filtration_rate:end));
        
        end
        %}
        
        %depol_complex_data = depol_complex_data(1:indx_min_depol_point);
        %depol_complex_time = depol_complex_time(1:indx_min_depol_point);
        
        filtered_data_test = depol_complex_data(1:filtration_rate:indx_min_depol_point);
        if length(filtered_data_test) > 5
            filtered_data = filtered_data_test;
            depol_complex_time_filtered = depol_complex_time(1:filtration_rate:indx_min_depol_point);

            max_depol_point = max(filtered_data);
            indx_max_depol_point = find(filtered_data == max_depol_point);
            indx_max_depol_point = indx_max_depol_point(1);

            max_depol_time = depol_complex_time_filtered(indx_max_depol_point);

            %depol_complex_time_filtered = depol_complex_time;

            %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');

            depol_complex_data_derivative = gradient(filtered_data);

            if strcmp(warning, '')
                warning = strcat(warning, 'Possibly no upwards depol stroke');
            else
                warning = strcat(warning, {' '}, 'and possibly no upwards depol stroke');
            end
        else
            if strcmp(spon_paced, 'paced')||strcmp(spon_paced, 'paced bdt')
                if strcmp(warning, '')
                    warning = strcat(warning, 'Stimulated point possibly not producing a beat');
                else
                    warning = strcat(warning, {' '}, 'and stimulated point possibly not producing a beat');
                end
                
            end
            
            activation_filtration_rate  = filtration_rate;
            activation_filter_intensity = filter_intensity;
            
            while(1)
                if (length(depol_complex_data(indx_min_depol_point:indx_max_depol_point))/activation_filtration_rate) >= 5
                    break
                else
                    if strcmp(activation_filter_intensity, 'none')
                        break;
                    elseif strcmp(activation_filter_intensity, 'low')
                        %filtration_rate = 5;
                        activation_filtration_rate  = 1;
                        activation_filter_intensity = 'none';
                    elseif strcmp(activation_filter_intensity, 'medium')
                        %filtration_rate = 10;
                        activation_filtration_rate  = 5;
                        activation_filter_intensity = 'low';
                    else
                        %filtration_rate = 10;
                        activation_filtration_rate  = 10;
                        activation_filter_intensity = 'medium';
                    end

                end
            end
            
            if dc == 1
                filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:activation_filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:filtration_rate:end));
                %filtered_data = depol_complex_data(1:filtration_rate:indx_min_depol_point);

            else


                filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:activation_filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:filtration_rate:end));

            end
            
            
            %{
            if dc == 1
                filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), model, depol_complex_data(indx_max_depol_point:filtration_rate:end));
                %filtered_data = depol_complex_data(1:filtration_rate:indx_min_depol_point);

            else


                filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), model, depol_complex_data(indx_max_depol_point:filtration_rate:end));

            end

            %}
            if tc == 1
                depol_complex_time_filtered = vertcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:activation_filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:filtration_rate:end));

            else
                depol_complex_time_filtered = horzcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:activation_filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:filtration_rate:end));

            end
            
            %{
            % denoise only
            
            if dc == 1
                filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:indx_max_depol_point), depol_complex_data(indx_max_depol_point:filtration_rate:end));
                %filtered_data = depol_complex_data(1:filtration_rate:indx_min_depol_point);

            else


                filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:indx_max_depol_point), depol_complex_data(indx_max_depol_point:filtration_rate:end));

            end
            
            
            %{
            if dc == 1
                filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), model, depol_complex_data(indx_max_depol_point:filtration_rate:end));
                %filtered_data = depol_complex_data(1:filtration_rate:indx_min_depol_point);

            else


                filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), model, depol_complex_data(indx_max_depol_point:filtration_rate:end));

            end

            %}
            if tc == 1
                depol_complex_time_filtered = vertcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:indx_max_depol_point), depol_complex_time(indx_max_depol_point:filtration_rate:end));

            else
                depol_complex_time_filtered = horzcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:indx_max_depol_point), depol_complex_time(indx_max_depol_point:filtration_rate:end));

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
            %}
            
            
            
            %{
            % model method
            if dc == 1
                filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:indx_max_depol_point), depol_complex_data(indx_max_depol_point:filtration_rate:end));
                %filtered_data = depol_complex_data(1:filtration_rate:indx_min_depol_point);

            else


                filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:indx_max_depol_point), depol_complex_data(indx_max_depol_point:filtration_rate:end));

            end
            
            
            %{
            if dc == 1
                filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), model, depol_complex_data(indx_max_depol_point:filtration_rate:end));
                %filtered_data = depol_complex_data(1:filtration_rate:indx_min_depol_point);

            else


                filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), model, depol_complex_data(indx_max_depol_point:filtration_rate:end));

            end

            %}
            if tc == 1
                depol_complex_time_filtered = vertcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:indx_max_depol_point), depol_complex_time(indx_max_depol_point:filtration_rate:end));

            else
                depol_complex_time_filtered = horzcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:indx_max_depol_point), depol_complex_time(indx_max_depol_point:filtration_rate:end));

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
            
            
            
            max_depol_point = max(filtered_data);
            indx_max_depol_point = find(filtered_data == max_depol_point);


            min_depol_point = min(filtered_data);
            indx_min_depol_point = find(filtered_data == min_depol_point);



            indx_max_depol_point = indx_max_depol_point(1);
            max_depol_time = depol_complex_time_filtered(indx_max_depol_point);

            indx_min_depol_point = indx_min_depol_point(1);
            min_depol_time = depol_complex_time_filtered(indx_min_depol_point);
            
            
            %{
            fit_x = depol_complex_time_filtered(indx_min_depol_point:indx_max_depol_point);
            fit_y = filtered_data(indx_min_depol_point:indx_max_depol_point);
            
            lims_indx = find(fit_y <= max_depol_point & fit_y >= min_depol_point);
                
            fit_y = fit_y(lims_indx);
            fit_x = fit_x(lims_indx);
            %}
            
            try
                lin_eqn = fittype('m*x+b');

                model = fit(fit_x, fit_y, lin_eqn);

                model = model.m.*depol_complex_time_filtered(indx_min_depol_point:indx_max_depol_point) + model.b;

                model_x = depol_complex_time_filtered(indx_min_depol_point:indx_max_depol_point);
                
                model_lims_indx = find(model <= max_depol_point & model >= min_depol_point);
                
                model = model(model_lims_indx);
                model_x = model_x(model_lims_indx);
            catch
                model = filtered_data(indx_min_depol_point:indx_max_depol_point);
                
                model_x = depol_complex_time_filtered(indx_min_depol_point:indx_max_depol_point);
                
                
                
            end
            
            if dc == 1
                filtered_data = vertcat(filtered_data(1:indx_min_depol_point), model, filtered_data(indx_max_depol_point:end));
                %filtered_data = depol_complex_data(1:filtration_rate:indx_min_depol_point);

            else


                filtered_data = horzcat(filtered_data(1:indx_min_depol_point), model, filtered_data(indx_max_depol_point:end));

            end


            if tc == 1
                depol_complex_time_filtered = vertcat(depol_complex_time_filtered(1:indx_min_depol_point), model_x, depol_complex_time_filtered(indx_max_depol_point:end));

            else
                depol_complex_time_filtered = horzcat(depol_complex_time_filtered(1:indx_min_depol_point), model_x, depol_complex_time_filtered(indx_max_depol_point:end));

            end
            
            %}    
            
            %{
            poly_time = depol_complex_time_filtered - depol_complex_time_filtered(1);
            best_p_degree = 21;

            pfit = polyfit(poly_time,filtered_data,best_p_degree);
            filtered_data = polyval(pfit, poly_time);
            %}
            
            
            depol_complex_data_derivative = gradient(filtered_data);
        end
    else
        
        
        
        %{
        figure();
        plot(depol_complex_time(indx_max_depol_point:indx_min_depol_point), depol_complex_data(indx_max_depol_point:indx_min_depol_point))
        hold on;
        plot(depol_complex_time(indx_max_depol_point:indx_min_depol_point), model)
        pause(10)
        %}
        
        activation_filtration_rate  = filtration_rate;
        activation_filter_intensity = filter_intensity;

        while(1)
            if (length(depol_complex_data(indx_max_depol_point:indx_min_depol_point))/activation_filtration_rate) >= 5
                break
            else
                if strcmp(activation_filter_intensity, 'none')
                    break;
                elseif strcmp(activation_filter_intensity, 'low')
                    %filtration_rate = 5;
                    activation_filtration_rate  = 1;
                    activation_filter_intensity = 'none';
                elseif strcmp(activation_filter_intensity, 'medium')
                    %filtration_rate = 10;
                    activation_filtration_rate  = 5;
                    activation_filter_intensity = 'low';
                else
                    %filtration_rate = 10;
                    activation_filtration_rate  = 10;
                    activation_filter_intensity = 'medium';
                end

            end
        end

        if dc == 1
            filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:activation_filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        else

            filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:activation_filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        end
        
        %{
        if dc == 1
            filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), model, depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        else

            filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), model, depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        end
        %}
        
        if tc == 1
            depol_complex_time_filtered = vertcat(depol_complex_time(1:filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:activation_filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:filtration_rate:end));
        
        else
            
            depol_complex_time_filtered = horzcat(depol_complex_time(1:filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:activation_filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:filtration_rate:end));
        
        end
        
        
        %{
        % denoise only method
        if dc == 1
            filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:indx_min_depol_point), depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        else

            filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:indx_min_depol_point), depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        end
        
        %{
        if dc == 1
            filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), model, depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        else

            filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), model, depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        end
        %}
        
        if tc == 1
            depol_complex_time_filtered = vertcat(depol_complex_time(1:filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:indx_min_depol_point), depol_complex_time(indx_min_depol_point:filtration_rate:end));
        
        else
            
            depol_complex_time_filtered = horzcat(depol_complex_time(1:filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:indx_min_depol_point), depol_complex_time(indx_min_depol_point:filtration_rate:end));
        
        end
        
        

        %depol_complex_time_filtered = depol_complex_time;
        
        %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
        
        
        
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
        
        %}
        
        %{
        
        % model method
        if dc == 1
            filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:indx_min_depol_point), depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        else

            filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:indx_min_depol_point), depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        end
        
        %{
        if dc == 1
            filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), model, depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        else

            filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), model, depol_complex_data(indx_min_depol_point:filtration_rate:end));
            
        end
        %}
        
        if tc == 1
            depol_complex_time_filtered = vertcat(depol_complex_time(1:filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:indx_min_depol_point), depol_complex_time(indx_min_depol_point:filtration_rate:end));
        
        else
            
            depol_complex_time_filtered = horzcat(depol_complex_time(1:filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:indx_min_depol_point), depol_complex_time(indx_min_depol_point:filtration_rate:end));
        
        end
        
        

        %depol_complex_time_filtered = depol_complex_time;
        
        %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
        
        
        
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
        
        max_depol_point = max(filtered_data);
        indx_max_depol_point = find(filtered_data == max_depol_point);


        min_depol_point = min(filtered_data);
        indx_min_depol_point = find(filtered_data == min_depol_point);



        indx_max_depol_point = indx_max_depol_point(1);
        max_depol_time = depol_complex_time_filtered(indx_max_depol_point);

        indx_min_depol_point = indx_min_depol_point(1);
        min_depol_time = depol_complex_time_filtered(indx_min_depol_point);
        
        
        
        

        try
            
            lin_eqn = fittype('m*x+b');
            model = fit(depol_complex_time_filtered(indx_max_depol_point:indx_min_depol_point), filtered_data(indx_max_depol_point:indx_min_depol_point), lin_eqn);

            model = model.m.*depol_complex_time_filtered(indx_max_depol_point:indx_min_depol_point) + model.b;

            model_x = depol_complex_time_filtered(indx_max_depol_point:indx_min_depol_point);
            
            model_lims_indx = find(model <= max_depol_point & model >= min_depol_point);
                
            model = model(model_lims_indx);
            model_x = model_x(model_lims_indx);
        catch 
            model = filtered_data(indx_max_depol_point:indx_min_depol_point);
            
            model_x = depol_complex_time_filtered(indx_max_depol_point:indx_min_depol_point);
            
        end

        if dc == 1
            filtered_data = vertcat(filtered_data(1:indx_max_depol_point), model, filtered_data(indx_min_depol_point:end));
            %filtered_data = depol_complex_data(1:filtration_rate:indx_min_depol_point);

        else


            filtered_data = horzcat(filtered_data(1:indx_max_depol_point), model, filtered_data(indx_min_depol_point:end));

        end
        if tc == 1
            depol_complex_time_filtered = vertcat(depol_complex_time_filtered(1:indx_max_depol_point), model_x, depol_complex_time_filtered(indx_min_depol_point:end));

        else
            depol_complex_time_filtered = horzcat(depol_complex_time_filtered(1:indx_max_depol_point), model_x, depol_complex_time_filtered(indx_min_depol_point:end));

        end
        %}
        
        %{
        
        poly_time = depol_complex_time_filtered - depol_complex_time_filtered(1);
        best_p_degree = 21;
                
        pfit = polyfit(poly_time,filtered_data,best_p_degree);
        filtered_data = polyval(pfit, poly_time);
        %}
        

            
        depol_complex_data_derivative = gradient(filtered_data);
        
        %{
        if strcmp(electrode_id, 'D02_2_4')
            figure()
            hold on;
            plot(depol_complex_time, depol_complex_data)
            plot(depol_complex_time_filtered, down_sampled)
            plot(depol_complex_time_filtered, filtered_data)
            plot(depol_complex_time_filtered, depol_complex_data_derivative)
            legend('og', 'downsampled', 'denoised', 'gradient')
            hold off;

            pause(15);
        end
        %}
        
    end
    
   
    %disp(size(depol_complex_time_filtered))
    %disp(size(filtered_data))
    
    
    %{
    figure(1);
    plot(depol_complex_time, depol_complex_data);
    hold on;
    plot(depol_complex_time_filtered, filtered_data);
    %plot(depol_complex_time_filtered, depol_complex_data_derivative);
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
                    
                    max_depol_filtered = max(filtered_data);
                    min_depol_filtered = min(filtered_data);
                    
                    indx_max_depol_filtered_point = find(filtered_data == max_depol_filtered);
                    indx_min_depol_filtered_point = find(filtered_data == min_depol_filtered);
                    
                    indx_max_depol_filtered_point = indx_max_depol_filtered_point(1);
                    indx_min_depol_filtered_point = indx_min_depol_filtered_point(1);
                    
                    if indx_max_depol_filtered_point < indx_min_depol_filtered_point
                        depol_complex_filtered_data_derivative = gradient(filtered_data(indx_max_depol_filtered_point:indx_min_depol_filtered_point));
                        depol_complex_time_filtered2 = depol_complex_time_filtered(indx_max_depol_filtered_point:indx_min_depol_filtered_point);
                    else
                        depol_complex_filtered_data_derivative = gradient(filtered_data(indx_min_depol_filtered_point:indx_max_depol_filtered_point));
                        depol_complex_time_filtered2 = depol_complex_time_filtered(indx_min_depol_filtered_point:indx_max_depol_filtered_point);
                    end
                    
                    min_raw_slope = min(depol_complex_filtered_data_derivative);
                    activation_time_indx_min_raw = find(depol_complex_filtered_data_derivative == min_raw_slope);
                    activation_time = depol_complex_time_filtered2(activation_time_indx_min_raw(1));
                    slope = depol_complex_filtered_data_derivative(activation_time_indx_min_raw(1));
                    
                    %{
                    if strcmp(warning, '')
                        warning = strcat(warning, 'Activation Point Calculated out of the Max/Min Range');
                    else
                        warning = strcat(warning, {' '}, ' and Activation Point Calculated out of the Max/Min Range');
                    end
                    %}
                else
                    activation_time = depol_complex_time_filtered(activation_time_indx_min_raw(1));
                    %slope = depol_complex_data(activation_time_indx(1)); %3/12/2021 bug was calculating the slope using the original y data, not the dydx of te signal - this is a scalar value
                    slope = depol_complex_data_derivative(activation_time_indx_min_raw(1));

                    max_depol_filtered = max(filtered_data);
                    min_depol_filtered = min(filtered_data);
                    
                    indx_max_depol_filtered_point = find(filtered_data == max_depol_filtered);
                    indx_min_depol_filtered_point = find(filtered_data == min_depol_filtered);
                    
                    indx_max_depol_filtered_point = indx_max_depol_filtered_point(1);
                    indx_min_depol_filtered_point = indx_min_depol_filtered_point(1);
                    
                    if indx_max_depol_filtered_point < indx_min_depol_filtered_point
                        depol_complex_filtered_data_derivative = gradient(filtered_data(indx_max_depol_filtered_point:indx_min_depol_filtered_point));
                        depol_complex_time_filtered2 = depol_complex_time_filtered(indx_max_depol_filtered_point:indx_min_depol_filtered_point);
                    else
                        depol_complex_filtered_data_derivative = gradient(filtered_data(indx_min_depol_filtered_point:indx_max_depol_filtered_point));
                        depol_complex_time_filtered2 = depol_complex_time_filtered(indx_min_depol_filtered_point:indx_max_depol_filtered_point);
                    end
                    
                    min_raw_slope = min(depol_complex_filtered_data_derivative);
                    activation_time_indx_min_raw = find(depol_complex_filtered_data_derivative == min_raw_slope);
                    activation_time = depol_complex_time_filtered2(activation_time_indx_min_raw(1));
                    slope = depol_complex_filtered_data_derivative(activation_time_indx_min_raw(1));
                    
                    %{
                    if strcmp(warning, '')
                        warning = strcat(warning, 'Activation Point Calculated out of the Max/Min Range');
                    else
                        warning = strcat(warning, {' '}, ' and Activation Point Calculated out of the Max/Min Range');
                    end
                    %}
                end
            end
        end
        
        
    end
    
    %if isalmost(time(1), 80.40808, 10^-3)


    
    
    %disp(activation_time)
    
    
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