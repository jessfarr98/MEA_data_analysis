function minimise_cross_talk(prev_fig, RawData, Stims, added_wells, selected_minimisation_wells, num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, bipolar, save_dir, save_base_dir, parameter_input_method)

    %Prompt asking if they want to include all wells included in analysis in the cross talk subtraction method 
    
    % If they choose no, allow them to pick wells (and visualise data)
    
    %Take average of all data inluded in minimisation and subtract this
    %averaged signals from each electrode \
    
    close all;
    close all hidden;
    
    disp(selected_minimisation_wells)
    
    
    well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    

    count = 0;
    
    sum_signals = [];
    
    for w_r = 1:num_well_rows
        
        for w_c = 1:num_well_cols
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            if ~ismember(wellID, selected_minimisation_wells)
               continue 
            end

            for e_r = 1:num_electrode_rows
                for e_c = 1:num_electrode_cols
                    
                    RawWellData = RawData{w_r, w_c, e_r, e_c};
                    if (strcmp(class(RawWellData),'Waveform'))

                        [time, data] = RawWellData.GetTimeVoltageVector;
                        

                        %data = data*1000;
                        %plot(time, data);

                        count = count + 1;
            
                        if isempty(sum_signals)
                            sum_signals = data;
                        else
                            
                            sum_signals = sum_signals+data;
                        end
  
                        %pause(100000)
                    end
                end
                
                
            end
            
        end
    end
    
    
    count_array = count*ones(length(sum_signals), 1);
    constant_signal = sum_signals./count_array;
    
    % Find the origin electrode
    max_rsq = nan;
    origin_well = '';
    for w_r = 1:num_well_rows
        
        for w_c = 1:num_well_cols
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            if ~ismember(wellID, selected_minimisation_wells)
               continue 
            end
            rsqs = [];
            electrode_count = 0;
            for e_r = 1:num_electrode_rows
                for e_c = 1:num_electrode_cols
                    
                    RawWellData = RawData{w_r, w_c, e_r, e_c};
                    if (strcmp(class(RawWellData),'Waveform'))

                        [time, data] = RawWellData.GetTimeVoltageVector;
                        
                        minimised_signal = data - constant_signal;
                        
                        
                        square_residuals = (data - minimised_signal).^2;
                        
                        total_squares = (data - mean(data)).^2;
                        
                        
                        rsq = 1 - (sum(square_residuals)/sum(total_squares));
                        
                        rsqs(end+1) = rsq;
                        %electrode_count = electrode_count+1;
                        
                        
                        %pause(100000)
                    end
                end
            end
            mean_rsq = mean(rsqs);
            if isnan(max_rsq)
                max_rsq = mean_rsq;
                origin_well = wellID;
            else
                if mean_rsq > max_rsq
                    max_rsq = mean_rsq;
                    origin_well = wellID;
                    
                end
                
            end
            
        end
    end
    
    
    
    if strcmp(parameter_input_method, 'unique')
        MEA_BDT_GUI_V2(RawData,Stims, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, save_dir, save_base_dir, selected_minimisation_wells, constant_signal, origin_well)
        
    elseif strcmp(parameter_input_method, 'general')
        MEA_BDT_PLATE_GUI_V2(RawData,Stims, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, save_dir, save_base_dir,  selected_minimisation_wells, constant_signal, origin_well)
    elseif strcmp(parameter_input_method, 'fast')
        MEA_GUI_FAST_THRESHOLD_INPUTS(RawData, Stims, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, save_dir, save_base_dir, selected_minimisation_wells, constant_signal, origin_well)
        
    end
    
    
    %{
    figure()
    title('constant signal')
    plot(time, constant_signal)
    
    for w_r = 1:num_well_rows
        
        for w_c = 1:num_well_cols
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            if ~ismember(wellID, selected_minimisation_wells)
               continue 
            end
            figure();
            title(strcat('Removed Cross Talk',wellID))
            hold on;
            for e_r = 1:num_electrode_rows
                for e_c = 1:num_electrode_cols
                    
                    RawWellData = RawData{w_r, w_c, e_r, e_c};
                    if (strcmp(class(RawWellData),'Waveform'))

                        [time, data] = RawWellData.GetTimeVoltageVector;
                        

                        %data = data*1000;
                        %plot(time, data);

                        count = count + 1;
            
                        data = data-constant_signal;
                        RawData{w_r, w_c, e_r, e_c}.SetVoltageVector(data);
                        
                        plot(time, data)
                    end
                end
                
                
            end
            hold off;
            
        end
    end
    
    for w_r = 1:num_well_rows
        
        for w_c = 1:num_well_cols
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            if ~ismember(wellID, selected_minimisation_wells)
               continue 
            end
            figure();
            title(strcat('Test Store',wellID))
            hold on;
            for e_r = 1:num_electrode_rows
                for e_c = 1:num_electrode_cols
                    
                    RawWellData = RawData{w_r, w_c, e_r, e_c};
                    if (strcmp(class(RawWellData),'Waveform'))

                        [time, data] = RawWellData.GetTimeVoltageVector;
                        

                        %data = data*1000;
                        %plot(time, data);

                        count = count + 1;
                        
                        plot(time, data)
                    end
                end
                
                
            end
            hold off;
            
        end
    end
    
    
    %}

end