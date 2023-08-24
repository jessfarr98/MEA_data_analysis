function MEA_GUI_FAST_THRESHOLD_INPUTS(RawData, Stims, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, save_dir, save_base_dir, minimise_wells, constant_signal, origin_well)
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
    
    added_wells = sort(added_wells);
    
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
    %require_time = 0;
    require_time = 1;
    found_waveform = 0;
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
    
    min_end_time = nan;
    if require_time == 1
        for w_r = 1:num_well_rows
           for w_c = 1:num_well_cols
              wellID = strcat(well_dictionary(w_r), '0', string(w_c));
              if ~contains(added_wells, 'all')
                  if ismember(wellID, added_wells)
                      found_well_waveform = 0;
                      for e_r = num_electrode_rows:-1:1
                         for e_c = 1:num_electrode_cols
                            RawWellData = RawData{w_r, w_c, e_c, e_r};
                            if (strcmp(class(RawWellData),'Waveform'))
                                found_waveform = 1;
                                found_well_waveform = 1;
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
                      if found_well_waveform == 0
                          added_wells = setdiff(added_wells, wellID);
                          
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
                            found_waveform = 1;
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
    
    if found_waveform == 0
        close(input_thresh_fig)
        MEA_GUI_Return(RawData, Stims, save_dir, 0)
        return;
    end
   
    input_thresh_pan = uipanel(input_thresh_fig, 'BackgroundColor','#d43d3d', 'Position', [0 0 screen_width screen_height]);
    %input_thresh_pan = uipanel(input_thresh_fig, 'Position', [0 0 screen_width screen_height]);
    set(input_thresh_pan, 'AutoResizeChildren', 'off');
    
    if screen_height <= 1200
        im_height = screen_height-300;
        %im_vert_offset = (screen_height/2)-(im_height/2);
    else
        im_height = 1200;
        %im_vert_offset = (screen_height/2)-(im_height/2);
    end

    if screen_width <= 800
        im_width = screen_width -300;
        im_horz_offset = 40;
    else
        
        im_width = 800;
        im_horz_offset = (screen_width/2)-(im_width/2);
    end
    if strcmp(spon_paced, 'spon')
        im = uiimage(input_thresh_pan, 'ImageSource', 'spontaneous downwards t-wave png.png', 'Position', [im_horz_offset 220 im_width, im_height]);
    elseif strcmp(spon_paced, 'paced')
        im = uiimage(input_thresh_pan, 'ImageSource', 'paced data downwards t-wave png.png', 'Position', [im_horz_offset 220 im_width, im_height]);
        
    elseif strcmp(spon_paced, 'paced bdt')
        im = uiimage(input_thresh_pan, 'ImageSource', 'paced ectopic downwards png.png', 'Position', [im_horz_offset 220 im_width im_height]);
    end
    
    
    
    if strcmp(spon_paced, 'spon')
       if strcmp(beat_to_beat, 'on')
           if strcmp(analyse_all_b2b, 'all')
               num_inputs = 8;
           elseif strcmp(analyse_all_b2b, 'time_region')
               num_inputs = 10;
           end
           
       else
           if strcmp(stable_ave_analysis, 'stable')
               num_inputs = 9;
           elseif strcmp(stable_ave_analysis, 'time_region')
               num_inputs = 10;
           end
           
       end
       
    elseif strcmp(spon_paced, 'paced')
       if strcmp(beat_to_beat, 'on')
           if strcmp(analyse_all_b2b, 'all')
               num_inputs = 6;
           elseif strcmp(analyse_all_b2b, 'time_region')
               num_inputs = 8;
           end
           
       else
           if strcmp(stable_ave_analysis, 'stable')
               num_inputs = 7;
           elseif strcmp(stable_ave_analysis, 'time_region')
               num_inputs = 8;
           end
           
       end
       
    elseif strcmp(spon_paced, 'paced bdt')
       if strcmp(beat_to_beat, 'on')
           if strcmp(analyse_all_b2b, 'all')
               num_inputs = 9;
           elseif strcmp(analyse_all_b2b, 'time_region')
               num_inputs = 11;
           end
           
       else
           if strcmp(stable_ave_analysis, 'stable')
               num_inputs = 10;
           elseif strcmp(stable_ave_analysis, 'time_region')
               num_inputs = 11;
           end
           
       end
    end
   
    input_width = 200;
    input_distance = 10;
   
    if num_inputs*input_width+num_inputs*input_distance > screen_width
       input_space = screen_width/num_inputs;
       
       ratio = input_width/(input_distance+input_width);
       
       input_width = floor(input_space*ratio);
       input_distance = input_space-input_width;
              
       
    end
    
    %submit_in_well_button = uibutton(input_thresh_pan,'push','Text', 'Submit Input Estimates', 'Position',[screen_width-250 120 200 60], 'ButtonPushedFcn', @(submit_in_well_button,event) submitButtonPushed(submit_in_well_button, input_thresh_fig));
   
    offset_input_box = input_distance;
    
    if strcmp(spon_paced, 'spon') || strcmp(spon_paced, 'paced bdt')
        well_bdt_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8,'Value', 'BDT (mV)',  'Position', [offset_input_box 150 input_width 40], 'Editable','off');
        well_bdt_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'BDT', 'BackgroundColor','#e68e8e', 'Position', [offset_input_box 100 input_width 40], 'ValueChangedFcn', @(well_bdt_ui,event) zeroInputChanged(well_bdt_ui, 0));
        
        offset_input_box = offset_input_box+input_width+input_distance;
    end

    t_wave_up_down_text = uieditfield(input_thresh_pan, 'Text', 'FontSize', 8, 'Value', 'T-wave Peak Analysis', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
    t_wave_up_down_dropdown = uidropdown(input_thresh_pan, 'Items', {'minimum', 'maximum', 'inflection', 'zero crossing'}, 'FontSize', 8,'Position', [offset_input_box 100 input_width 40],'ValueChangedFcn', @(t_wave_up_down_dropdown,event) TWaveChanged(t_wave_up_down_dropdown));
    t_wave_up_down_dropdown.ItemsData = [1 2 3 4];
    
    offset_input_box = offset_input_box+input_width+input_distance;

    t_wave_peak_offset_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'Repol. Time Offset (s)', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
    t_wave_peak_offset_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'T-Wave Time', 'Position', [offset_input_box 100 input_width 40], 'FontSize', 12, 'Value', 0.33);
    
    offset_input_box = offset_input_box+input_width+input_distance;

    t_wave_duration_text = uieditfield(input_thresh_pan, 'Text', 'FontSize', 8, 'Value','T-wave duration (s)', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
    t_wave_duration_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'T-Wave Dur', 'Position', [offset_input_box 100 input_width 40],  'Value', 0.2);
    
    offset_input_box = offset_input_box+input_width+input_distance;

    %est_fpd_text = uieditfield(input_thresh_pan, 'Text', 'Value', 'Estimated FPD', 'FontSize', 12, 'Position', [480 60 100 40], 'Editable','off');
    %est_fpd_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'FPD', 'Position', [480 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(est_fpd_ui,event) changeFPD(est_fpd_ui, input_thresh_pan, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced));

    post_spike_text = uieditfield(input_thresh_pan, 'Text', 'FontSize', 8,'Value', 'Post spike hold-off (s)', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
    post_spike_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Post-spike', 'Position', [offset_input_box 100 input_width 40],  'Value', 0.1);
    
    offset_input_box = offset_input_box+input_width+input_distance;
    
    filter_intensity_text = uieditfield(input_thresh_pan, 'Text', 'FontSize', 8, 'Value', 'Filtering Intensity', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
    filter_intensity_dropdown = uidropdown(input_thresh_pan, 'Items', {'none', 'low', 'medium', 'strong'}, 'FontSize', 8,'Position', [offset_input_box 100 input_width 40]);
    filter_intensity_dropdown.ItemsData = [1 2 3 4];
    
    offset_input_box = offset_input_box+input_width+input_distance;
    
    if strcmp(spon_paced, 'spon')

        min_bp_text = uieditfield(input_thresh_pan,'Text','FontSize', 8, 'Value', 'Min. BP (s)', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
        min_bp_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Min BP', 'BackgroundColor','#e68e8e', 'Position', [offset_input_box 100 input_width 40], 'ValueChangedFcn', @(min_bp_ui,event) zeroInputChanged(min_bp_ui, 0));
        
        offset_input_box = offset_input_box+input_width+input_distance;
      
        max_bp_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8,'Value', 'Max. BP (s)',  'Position', [offset_input_box 150 input_width 40], 'Editable','off');
        max_bp_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Max BP', 'BackgroundColor','#e68e8e', 'Position', [offset_input_box 100 input_width 40], 'ValueChangedFcn', @(max_bp_ui,event) zeroInputChanged(max_bp_ui, 0));
        
        offset_input_box = offset_input_box+input_width+input_distance;
      
    elseif strcmp(spon_paced, 'paced bdt')
        min_bp_text = uieditfield(input_thresh_pan,'Text','FontSize', 8, 'Value', 'Min. BP (s)', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
        min_bp_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Min BP', 'BackgroundColor','#e68e8e','Position', [offset_input_box 100 input_width 40], 'ValueChangedFcn', @(min_bp_ui,event) zeroInputChanged(min_bp_ui, 0));
        
        offset_input_box = offset_input_box+input_width+input_distance;
      
        max_bp_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8,'Value', 'Max. BP (s)', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
        max_bp_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Max BP', 'BackgroundColor','#e68e8e', 'Position', [offset_input_box 100 input_width 40], 'ValueChangedFcn', @(max_bp_ui,event) zeroInputChanged(max_bp_ui, 0));
        
        offset_input_box = offset_input_box+input_width+input_distance;
      
        stim_spike_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'Stim. Spike hold-off (s)',  'Position', [offset_input_box 150 input_width 40], 'Editable','off');
        stim_spike_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Stim spike', 'Position', [offset_input_box 100 input_width 40], 'Value', 0.002);
        
        offset_input_box = offset_input_box+input_width+input_distance;
      
    elseif strcmp(spon_paced, 'paced') 
        stim_spike_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'Stim. Spike hold-off (s)', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
        stim_spike_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Stim spike', 'Position', [offset_input_box 100 input_width 40],  'Value', 0.002);
        
        offset_input_box = offset_input_box+input_width+input_distance;
      
    end

    if strcmp(beat_to_beat, 'on')

        if strcmp(analyse_all_b2b, 'time_region')
            time_start_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'B2B Time region start time (s)', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
            time_start_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Start Time', 'BackgroundColor','#e68e8e', 'Position', [offset_input_box 100 input_width 40], 'ValueChangedFcn', @(time_start_ui,event) zeroInputChanged(time_start_ui, 0));
            
            offset_input_box = offset_input_box+input_width+input_distance;
            
            time_end_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8,'Value', 'B2B Time region end time (s)',  'Position', [offset_input_box 150 input_width 40], 'Editable','off');
            time_end_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'End Time', 'BackgroundColor','#e68e8e', 'Position', [offset_input_box 100 input_width 40], 'ValueChangedFcn', @(time_end_ui,event) zeroInputChanged(time_end_ui, min_end_time));
            
            offset_input_box = offset_input_box+input_width+input_distance;
            
            set(time_end_ui, 'Value', min_end_time)

        end
    else
        if strcmp(stable_ave_analysis, 'time_region')
            time_start_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'Ave. Waveform time region start time (s)', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
            time_start_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'Start Time', 'BackgroundColor','#e68e8e', 'Position', [offset_input_box 100 input_width 40], 'ValueChangedFcn', @(time_start_ui,event) zeroInputChanged(time_start_ui, 0));
            
            offset_input_box = offset_input_box+input_width+input_distance;
            
            time_end_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8, 'Value', 'Ave. Waveform time region end time (s)',  'Position', [offset_input_box 150 input_width 40], 'Editable','off');
            time_end_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'End Time', 'BackgroundColor','#e68e8e', 'Position', [offset_input_box 100 input_width 40], 'ValueChangedFcn', @(time_end_ui,event) zeroInputChanged(time_end_ui, min_end_time));
            
            offset_input_box = offset_input_box+input_width+input_distance;

            set(time_end_ui, 'Value', min_end_time);

        end
        if strcmp(stable_ave_analysis, 'stable')
            %sliding time window to find the elctrode with the most stable beat period and then compute average waveform using this region
            stable_duration_text = uieditfield(input_thresh_pan,'Text', 'FontSize', 8,'Value', 'Time Window for GE average waveform (s)', 'Position', [offset_input_box 150 input_width 40], 'Editable','off');
            stable_duration_ui = uieditfield(input_thresh_pan, 'numeric', 'Tag', 'GE Window', 'BackgroundColor','#e68e8e', 'Position', [offset_input_box 100 input_width 40], 'ValueChangedFcn', @(stable_duration_ui,event) zeroInputChanged(stable_duration_ui, 0));
            
            offset_input_box = offset_input_box+input_width+input_distance;

        end
    end
    
    return_input_menu_button = uibutton(input_thresh_pan,'push','Text', 'Return to Main Menu', 'Position',[screen_width-250 280 200 60], 'BackgroundColor', '#B02727', 'ButtonPushedFcn', @(return_input_menu_button,event) returnInputMenuPushed());
    %set(return_input_menu_button, 'BackgroundColour', '#B02727');
    
    submit_in_well_button = uibutton(input_thresh_pan,'push','Text', 'Submit Input Estimates', 'Position',[screen_width-250 200 200 60],'BackgroundColor', '#3dd4d1','ButtonPushedFcn', @(submit_in_well_button,event) submitButtonPushed(submit_in_well_button, input_thresh_fig));
    
    movegui(input_thresh_fig,'center')
    input_thresh_fig.WindowState = 'maximized';

    %{
    function changeBDT(submit_in_well_button)
        if isempty(t_wave_peak_offset_ui.Value)
            
            
        elseif isempty()
            
            
        end
    end
    %}
    function returnInputMenuPushed()
        MEA_GUI_Return(RawData, Stims, save_dir, 0)
        %MEA_GUI(raw_file, save_dir)
    end
    
    function zeroInputChanged(input_ui, original_value)
        if get(input_ui, 'value') ~= original_value
           set(input_ui, 'BackgroundColor', 'white')
        else
           set(input_ui, 'BackgroundColor', '#e68e8e')
            
        end
        
    end

    function TWaveChanged(t_wave_up_down_dropdown)
        delete(im)
        if strcmp(spon_paced, 'spon')
            if get(t_wave_up_down_dropdown, 'Value') == 1
                im = uiimage(input_thresh_pan, 'ImageSource', 'spontaneous downwards t-wave png.png', 'Position', [im_horz_offset 220 im_width, im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 2
                im = uiimage(input_thresh_pan, 'ImageSource', 'spontaneous upwards t-wave png.png', 'Position', [im_horz_offset 220 im_width, im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 3
                im = uiimage(input_thresh_pan, 'ImageSource', 'spontaneous polynomial t-wave png.png', 'Position', [im_horz_offset 220 im_width, im_height]);
    

            end
        elseif strcmp(spon_paced, 'paced')
            if get(t_wave_up_down_dropdown, 'Value') == 1
                im = uiimage(input_thresh_pan, 'ImageSource', 'paced data downwards t-wave png.png', 'Position', [im_horz_offset 220 im_width, im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 2
                im = uiimage(input_thresh_pan, 'ImageSource', 'paced data upwards t-wave png.png', 'Position', [im_horz_offset 220 im_width, im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 3
                im = uiimage(input_thresh_pan, 'ImageSource', 'paced data polynomial t-wave png.png', 'Position', [im_horz_offset 220 im_width, im_height]);
    

            end
        elseif strcmp(spon_paced, 'paced bdt')
            if get(t_wave_up_down_dropdown, 'Value') == 1
                im = uiimage(input_thresh_pan, 'ImageSource', 'paced ectopic downwards png.png', 'Position', [im_horz_offset 220 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 2
                im = uiimage(input_thresh_pan, 'ImageSource', 'paced ectopic upwards png.png', 'Position', [im_horz_offset 220 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 3
                im = uiimage(input_thresh_pan, 'ImageSource', 'paced ectopic polynomial.png', 'Position', [im_horz_offset 220 im_width im_height]);
    
            end
            
        end
        
    end
     
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
        
        analyse_MEA_signals_GUI(RawData, Stims, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_bdt_array, well_t_wave_dur_array, well_t_wave_shape_array, well_time_reg_start, well_time_reg_end, well_stable_dur, added_wells, well_min_bp_array, well_max_bp_array, bipolar, post_spike_array, stim_spike_array, well_t_wave_time_array, well_fpd_array, filter_intensity_array, fullfile(save_dir, save_base_dir), minimise_wells, constant_signal, origin_well)

        
        
    end 

end