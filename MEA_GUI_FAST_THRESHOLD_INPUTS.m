function MEA_GUI_FAST_THRESHOLD_INPUTS(RawData, start_fig, Stims, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, save_dir)
    close all hidden;
    close all;

    input_thresh_fig = uifigure;

    input_thresh_fig.Name = 'Estimate Inputs';

    % Move the window to the center of the screen.
    movegui(input_thresh_fig,'center')
    
    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    
    % Get time vector to ensure that the times used are still acceptable
    shape_data = size(RawData);
    
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);
    
    %count = 0;
    %well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    
    well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    %{
    if strcmp(added_wells, 'all')
       added_wells = [];
       for w_r = 1:num_well_rows
          for w_c = 1:num_well_cols
             wellID = strcat(well_dictionary(w_r), '0', string(w_c));
             added_wells = [added_wells; wellID];
          end
       end
    end
    %}
    require_time = 0;
    if strcmp(beat_to_beat, 'on')
        if strcmp(analyse_all_b2b, 'time_region')
            min_end_time = nan;
            require_time = 1;
        end
    else
        if strcmp(stable_ave_analysis, 'time_region')
            min_end_time = nan;
            require_time = 1;
        end
    end
    
    if require_time == 1
        for w_r = 1:num_well_rows
           for w_c = 1:num_well_cols
              wellID = strcat(well_dictionary(w_r), '0', string(w_c));
              if ~contains(added_wells, 'all')
                  if ismember(wellID, added_wells)
                      for e_r = num_electrode_rows:-1:1
                         for e_c = 1:num_electrode_cols
                            RawWellData = RawData{w_r, w_c, e_c, e_r};
                            if (strcmp(class(RawWellData),'Waveform'))
                                %if ~empty(WellRawData)
                                %disp(num_well_rows*num_well_cols)
                                %disp(count)
                                [time, ~] = RawWellData.GetTimeVoltageVector;
                                if isnan(min_end_time)
                                    min_end_time = time(end);
                                else
                                    if isnan(time(end))
                                        continue
                                    end
                                    if min_end_time > time(end)
                                        min_end_time = time(end);
                                    end
                                end
                            end 
                         end 
                      end
                  end
              else
                  for e_r = num_electrode_rows:-1:1
                     for e_c = 1:num_electrode_cols
                        RawWellData = RawData{w_r, w_c, e_c, e_r};
                        if (strcmp(class(RawWellData),'Waveform'))
                            %if ~empty(WellRawData)
                            %disp(num_well_rows*num_well_cols)
                            %disp(count)
                            [time, ~] = RawWellData.GetTimeVoltageVector;
                            if isnan(min_end_time)
                                min_end_time = time(end);
                            else
                                if isnan(time(end))
                                    continue
                                end
                                if min_end_time > time(end)
                                    min_end_time = time(end);
                                end
                            end
                        end 
                     end 
                  end
              end
           end
        end

    end
   
    input_thresh_pan = uipanel(input_thresh_fig, 'BackgroundColor','#B02727', 'Position', [0 0 screen_width screen_height]);
    set(input_thresh_pan, 'AutoResizeChildren', 'off');
    
    %submit_in_well_button = uibutton(input_thresh_pan,'push','Text', 'Submit Input Estimates', 'Position',[screen_width-250 120 200 60], 'ButtonPushedFcn', @(submit_in_well_button,event) submitButtonPushed(submit_in_well_button, input_thresh_fig));
   

    if strcmp(spon_paced, 'spon') || strcmp(spon_paced, 'paced bdt')
        well_bdt_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8,'Value', 'BDT (mV)',  'Position', [10 150 100 40], 'Editable','off');
        well_bdt_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'BDT', 'Position', [10 100 100 40]);
    end

    t_wave_up_down_text = uieditfield(input_thresh_pan, 'Text', 'FontSize', 8, 'Value', 'T-wave Peak Analysis', 'Position', [120 150 100 40], 'Editable','off');
    t_wave_up_down_dropdown = uidropdown(input_thresh_pan, 'Items', {'minimum', 'maximum', 'inflection'}, 'FontSize', 8,'Position', [120 100 100 40]);
    t_wave_up_down_dropdown.ItemsData = [1 2 3];

    t_wave_peak_offset_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'Repol. Time Offset (s)', 'Position', [240 150 100 40], 'Editable','off');
    t_wave_peak_offset_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'T-Wave Time', 'Position', [240 100 100 40], 'FontSize', 12, 'Value', 0.33);

    t_wave_duration_text = uieditfield(input_thresh_pan, 'Text', 'FontSize', 8, 'Value','T-wave duration (s)', 'Position', [360 150 100 40], 'Editable','off');
    t_wave_duration_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'T-Wave Dur', 'Position', [360 100 100 40],  'Value', 0.2);

    %est_fpd_text = uieditfield(input_thresh_pan, 'Text', 'Value', 'Estimated FPD', 'FontSize', 12, 'Position', [480 60 100 40], 'Editable','off');
    %est_fpd_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'FPD', 'Position', [480 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(est_fpd_ui,event) changeFPD(est_fpd_ui, input_thresh_pan, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced));

    post_spike_text = uieditfield(input_thresh_pan, 'Text', 'FontSize', 8,'Value', 'Post spike hold-off (s)', 'Position', [480 150 100 40], 'Editable','off');
    post_spike_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Post-spike', 'Position', [480 100 100 40],  'Value', 0.1);
    
    filter_intensity_text = uieditfield(input_thresh_pan, 'Text', 'FontSize', 8, 'Value', 'Filtering Intensity', 'Position', [600 150 100 40], 'Editable','off');
    filter_intensity_dropdown = uidropdown(input_thresh_pan, 'Items', {'none', 'low', 'medium', 'strong'}, 'FontSize', 8,'Position', [600 100 100 40]);
    filter_intensity_dropdown.ItemsData = [1 2 3 4];
    
    if strcmp(spon_paced, 'spon')

        min_bp_text = uieditfield(input_thresh_pan,'Text','FontSize', 8, 'Value', 'Min. BP (s)', 'Position', [720 150 100 40], 'Editable','off');
        min_bp_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Min BP', 'Position', [720 100 100 40]);
      
        max_bp_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8,'Value', 'Max. BP (s)',  'Position', [840 150 100 40], 'Editable','off');
        max_bp_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Max BP', 'Position', [840 100 100 40]);
      
    elseif strcmp(spon_paced, 'paced bdt')
        min_bp_text = uieditfield(input_thresh_pan,'Text','FontSize', 8, 'Value', 'Min. BP (s)', 'Position', [720 150 100 40], 'Editable','off');
        min_bp_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Min BP', 'Position', [720 100 100 40]);
      
        max_bp_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8,'Value', 'Max. BP (s)', 'Position', [840 150 100 40], 'Editable','off');
        max_bp_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Max BP', 'Position', [840 100 100 40]);
      
        stim_spike_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'Stim. Spike hold-off (s)',  'Position', [960 150 100 40], 'Editable','off');
        stim_spike_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Stim spike', 'Position', [960 100 100 40]);
      
    elseif strcmp(spon_paced, 'paced') 
        stim_spike_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'Stim. Spike hold-off (s)', 'Position', [720 150 100 40], 'Editable','off');
        stim_spike_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Stim spike', 'Position', [720 100 100 40],  'Value', 0.002);
      
    end

    if strcmp(beat_to_beat, 'on')

        if strcmp(analyse_all_b2b, 'time_region')
            time_start_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'B2B Time region start time (s)', 'Position', [1080 150 100 40], 'Editable','off');
            time_start_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Start Time', 'Position', [1080 100 100 40]);
            
            time_end_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8,'Value', 'B2B Time region end time (s)',  'Position', [1200 150 100 40], 'Editable','off');
            time_end_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'End Time', 'Position', [1200 100 100 40]);
            
            set(time_end_ui, 'Value', min_end_time)

        end
    else
        if strcmp(stable_ave_analysis, 'time_region')
            time_start_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'Ave. Waveform time region start time (s)', 'Position', [1080 150 100 40], 'Editable','off');
            time_start_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Start Time', 'Position', [1080 100 100 40]);
            
            time_end_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'Ave. Waveform time region end time (s)',  'Position', [1200 150 100 40], 'Editable','off');
            time_end_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'End Time', 'Position', [1200 100 100 40]);

            set(time_end_ui, 'Value', min_end_time);

        end
        if strcmp(stable_ave_analysis, 'stable')
            %sliding time window to find the elctrode with the most stable beat period and then compute average waveform using this region
            stable_duration_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8,'Value', 'Time Window for GE average waveform (s)', 'Position', [1080 150 100 40], 'Editable','off');
            stable_duration_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'GE Window', 'Position', [1080 100 100 40]);

        end
    end
    
    
    submit_in_well_button = uibutton(input_thresh_pan,'push','Text', 'Submit Input Estimates', 'Position',[screen_width-250 120 200 60], 'ButtonPushedFcn', @(submit_in_well_button,event) submitButtonPushed(submit_in_well_button, input_thresh_fig));
    input_thresh_fig.WindowState = 'maximized';

    %{
    function changeBDT(submit_in_well_button)
        if isempty(t_wave_peak_offset_ui.Value)
            
            
        elseif isempty()
            
            
        end
    end
    %}
    
    
     
    function submitButtonPushed(submit_in_well_button, input_thresh_fig)
        set(input_thresh_fig, 'Visible', 'off')
        well_bdt_array = [];

        well_time_reg_start = [];
        well_time_reg_end = [];
        well_stable_dur = [];
        well_fpd_array = [];
        well_min_bp_array = [];
        well_max_bp_array = [];
        stim_spike_array = [];
        
        post_spike_array = repmat(get(post_spike_ui, 'Value'), length(added_wells));
        well_t_wave_dur_array = repmat(get(t_wave_duration_ui, 'Value'), length(added_wells));
        well_t_wave_shape_array = repmat(get(t_wave_up_down_dropdown, 'Value'), length(added_wells));
        well_t_wave_time_array = repmat(get(t_wave_peak_offset_ui, 'Value'), length(added_wells));
        filter_intensity_array = repmat(get(filter_intensity_dropdown, 'Value'), length(added_wells));
        %well_fpd_array = repmat(get(est_fpd_ui, 'Value'), length(added_wells));

        if strcmp(spon_paced, 'spon')
            
            well_bdt_array = repmat(get(well_bdt_ui, 'Value'), length(added_wells), 1);
            well_min_bp_array = repmat(get(min_bp_ui, 'Value'), length(added_wells), 1);
            well_max_bp_array = repmat(get(max_bp_ui, 'Value'), length(added_wells), 1);
        elseif strcmp(spon_paced, 'paced bdt')
            well_bdt_array = repmat(get(well_bdt_ui, 'Value'), length(added_wells), 1);
            well_min_bp_array = repmat(get(min_bp_ui, 'Value'), length(added_wells), 1);
            well_max_bp_array = repmat(get(max_bp_ui, 'Value'), length(added_wells), 1);
            stim_spike_array = repmat(get(stim_spike_ui, 'Value'), length(added_wells), 1);
        else
           stim_spike_array = repmat(get(stim_spike_ui, 'Value'), length(added_wells), 1);
        end

        if strcmp(beat_to_beat, 'on')
           if strcmp(analyse_all_b2b, 'time_region')
              well_time_reg_start = repmat(get(time_start_ui, 'Value'), length(added_wells), 1);
              well_time_reg_end = repmat(get(time_end_ui, 'Value'), length(added_wells), 1);
           end
        else
           if strcmp(stable_ave_analysis, 'time_region')
              well_time_reg_start = repmat(get(time_start_ui, 'Value'), length(added_wells), 1);
              well_time_reg_end = repmat(get(time_end_ui, 'Value'), length(added_wells));
           elseif strcmp(stable_ave_analysis, 'stable')
              well_stable_dur  = repmat(get(stable_duration_ui, 'Value'), length(added_wells), 1); 

           end
        end


        if strcmp(spon_paced, 'spon') || strcmp(spon_paced, 'paced bdt')
           well_bdt_array = well_bdt_array./1000;
        end
        disp(stim_spike_array)
        
        analyse_MEA_signals_GUI(RawData, Stims, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_bdt_array, well_t_wave_dur_array, well_t_wave_shape_array, well_time_reg_start, well_time_reg_end, well_stable_dur, added_wells, well_min_bp_array, well_max_bp_array, bipolar, post_spike_array, stim_spike_array, well_t_wave_time_array, well_fpd_array, filter_intensity_array, save_dir)

        
        
    end 

end