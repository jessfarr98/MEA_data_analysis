function [electrode_data, re_count] = electrode_time_region_analysis(electrode_data, num_electrode_rows, num_electrode_cols, reanalyse_electrodes, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    electrode_count = 0;
    disp(size(electrode_data))
    found_electrode = 0;
    for elec_r = num_electrode_rows:-1:1
        elec_r
        for elec_c = 1:num_electrode_cols
            elec_c
            electrode_count = electrode_count+1;
            if isempty(electrode_data(electrode_count).time)
                continue;
            end
            
            electrode_id = electrode_data(electrode_count).electrode_id
            if ismember(electrode_id, reanalyse_electrodes)
                re_count = electrode_count;
                found_electrode = 1;
                disp(electrode_id) 
                % reanalyse this electrode
                % create uifigure similar to at input
                well_fig = uifigure;
                well_fig.Name = electrode_data(electrode_count).electrode_id;
                well_p = uipanel(well_fig, 'Position', [0 0 screen_width screen_height]);

                well_ax = uiaxes(well_p, 'Position', [10 100 screen_width-300 screen_height-200]);
                plot(well_ax, electrode_data(electrode_count).ave_wave_time, electrode_data(electrode_count).average_waveform);
                xlabel(well_ax, 'Seconds (s)');
                ylabel(well_ax, 'Milivolts (mV)');
                
                min_voltage = min(electrode_data(electrode_count).data);
                max_voltage = max(electrode_data(electrode_count).data);
                

                submit_in_well_button = uibutton(well_p,'push','Text', 'Submit Inputs for Well', 'Position',[screen_width-250 120 200 60], 'ButtonPushedFcn', @(submit_in_well_button,event) submitButtonPushed(submit_in_well_button, well_fig));
                set(submit_in_well_button, 'Visible', 'off')
                

                t_wave_up_down_text = uieditfield(well_p, 'Text', 'Value', 'T-wave shape', 'FontSize', 8,'Position', [120 60 100 40], 'Editable','off');
                t_wave_up_down_dropdown = uidropdown(well_p, 'Items', {'minimum', 'maximum', 'inflection'}, 'FontSize', 8,'Position', [120 10 100 40]);
                t_wave_up_down_dropdown.ItemsData = [1 2 3 4];

                t_wave_peak_offset_text = uieditfield(well_p,'Text', 'Value', 'Repol. Time Offset (s)', 'FontSize', 8, 'Position', [240 60 100 40], 'Editable','off');
                t_wave_peak_offset_ui = uieditfield(well_p, 'numeric', 'Tag', 'T-Wave Time', 'Position', [240 10 100 40], 'ValueChangedFcn',@(t_wave_peak_offset_ui,event) changeTWaveTime(t_wave_peak_offset_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced, electrode_data(electrode_count).Stims, well_ax, min_voltage, max_voltage));
          
                t_wave_duration_text = uieditfield(well_p,'Text', 'Value', 'T-wave duration (s)', 'FontSize', 8, 'Position', [360 60 100 40], 'Editable','off');
                t_wave_duration_ui = uieditfield(well_p, 'numeric', 'Tag', 'T-Wave Dur', 'Position', [360 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(t_wave_duration_ui,event) changeTWaveDuration(t_wave_duration_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced, electrode_data(electrode_count).Stims, well_ax, min_voltage, max_voltage));
                
                %est_fpd_text = uieditfield(well_p, 'Text', 'Value', 'Estimated FPD', 'FontSize', 12, 'Position', [480 60 100 40], 'Editable','off');
                %est_fpd_ui = uieditfield(well_p, 'numeric', 'Tag', 'FPD', 'Position', [480 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(est_fpd_ui,event) changeFPD(est_fpd_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced));
          
                post_spike_text = uieditfield(well_p, 'Text', 'Value', 'Post spike hold-off (s)', 'FontSize', 8, 'Position', [480 60 100 40], 'Editable','off');
                post_spike_ui = uieditfield(well_p, 'numeric', 'Tag', 'Post-spike', 'Position', [480 10 100 40],  'ValueChangedFcn',@(post_spike_ui,event) changePostSpike(post_spike_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced,  electrode_data(electrode_count).Stims, min_voltage, max_voltage, well_ax));
                
                
                if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt') 
                    stim_spike_text = uieditfield(well_p,'Text', 'Value', 'Stim. Spike hold-off (s)', 'FontSize', 8, 'Position', [600 60 100 40], 'Editable','off');
                    stim_spike_ui = uieditfield(well_p, 'numeric', 'Tag', 'Stim spike', 'Position', [600 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(stim_spike_ui,event) changeStimSpike(stim_spike_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced, electrode_data(electrode_count).Stims, min_voltage, max_voltage, well_ax));

                end
                
              
            end
            if found_electrode == 1
                while(1)
                    pause(0.01)
                    if strcmp(get(well_fig, 'Visible'), 'off')
                        break; 
                    end
                end

                %% input elements to analyse just this electrode again and then re-set the electrode_data and then 
                if get(t_wave_up_down_dropdown, 'Value') == 1
                    t_wave_shape = 'min';
                elseif get(t_wave_up_down_dropdown, 'Value') == 2
                    t_wave_shape = 'max';
                elseif get(t_wave_up_down_dropdown, 'Value') == 3
                    t_wave_shape = 'inflection';
                elseif get(t_wave_up_down_dropdown, 'Value') == 4
                    t_wave_shape = 'zero crossing';

                end

                %{
                if strcmp(spon_paced, 'spon')
                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array] = extract_beats('', electrode_data(electrode_count).time, electrode_data(electrode_count).data, get(bdt_ui, 'Value'), spon_paced, 'on', 'stable', NaN, NaN, stable_ave_analysis, NaN, NaN, '', electrode_data(electrode_count).electrode_id, t_wave_shape, get(t_wave_duration_ui, 'Value'), electrode_data(electrode_count).Stims, get(min_bp_ui, 'Value'), get(max_bp_ui, 'Value'), get(post_spike_ui, 'Value'), get(t_wave_peak_offset_ui, 'Value'),get(est_fpd_ui, 'Value'));     
                elseif strcmp(spon_paced, 'paced bdt')
                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_time_array, electrode_data(electrode_count).activation_point_array, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array, electrode_data(electrode_count).depol_slope_array] = extract_paced_bdt_beats('', electrode_data(electrode_count).time, electrode_data(electrode_count).data, get(bdt_ui, 'Value'), spon_paced, beat_to_beat, analyse_all_b2b, NaN, NaN, stable_ave_analysis, NaN, NaN, '', electrode_data(electrode_count).electrode_id, t_wave_shape, get(t_wave_duration_ui, 'Value'), electrode_data(electrode_count).Stims,  get(post_spike_ui, 'Value'), get(stim_spike_ui, 'Value'), get(t_wave_peak_offset_ui, 'Value'), get(est_fpd_ui, 'Value'), get(min_bp_ui, 'Value'), get(max_bp_ui, 'Value'));     
                elseif strcmp(spon_paced, 'paced')
                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array] = extract_paced_beats('', electrode_data(electrode_count).time, electrode_data(electrode_count).data, NaN, spon_paced, 'on', 'all', NaN, NaN, stable_ave_analysis, NaN, NaN, '', electrode_data(electrode_count).electrode_id, t_wave_shape, get(t_wave_duration_ui, 'Value'), electrode_data(electrode_count).Stims, get(post_spike_ui, 'Value'), get(stim_spike_ui, 'Value'), get(t_wave_peak_offset_ui, 'Value'),get(est_fpd_ui, 'Value'));     
                end
                %}
                if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt') 
                    stim_spike_ho = get(stim_spike_ui, 'Value');
                else
                    stim_spike_ho = NaN;
                end
                 disp(get(post_spike_ui, 'Value'))
                [electrode_data(electrode_count).ave_activation_time, ~, electrode_data(electrode_count).ave_max_depol_time, electrode_data(electrode_count).ave_max_depol_point, electrode_data(electrode_count).ave_min_depol_time, electrode_data(electrode_count).ave_min_depol_point, electrode_data(electrode_count).ave_depol_slope] = rate_analysis(electrode_data(electrode_count).ave_wave_time, electrode_data(electrode_count).average_waveform, get(post_spike_ui, 'Value'),stim_spike_ho, spon_paced, NaN, electrode_data(electrode_count).electrode_id);
                [electrode_data(electrode_count).ave_t_wave_peak_time, ~, ~] = t_wave_complex_analysis( electrode_data(electrode_count).ave_wave_time,  electrode_data(electrode_count).average_waveform, beat_to_beat,  electrode_data(electrode_count).ave_activation_time, 0, spon_paced, t_wave_shape, NaN, get(t_wave_duration_ui, 'Value'), get(post_spike_ui, 'Value'), get(t_wave_peak_offset_ui, 'Value'), nan);
    
                
                
                
                disp(electrode_data(electrode_count).activation_times(2))
                elec_pans = get(well_pan, 'Children');
                for ui = 1:length(elec_pans)
                    if strcmp(get(elec_pans(ui), 'Title'), electrode_data(electrode_count).electrode_id)
                        disp('found the panel')
                        
                        elec_pan_children = get(elec_pans(ui), 'Children');
                        for e_ch = 1:length(elec_pan_children)
                            disp(get(elec_pan_children(e_ch), 'type'))
                            if strcmp(get(elec_pan_children(e_ch), 'type'), 'axes')
                                elec_ax = elec_pan_children(e_ch);
                            end
                        end
                        
                        cla(elec_ax);
                        hold(elec_ax,'on')
                        plot(elec_ax, electrode_data(electrode_count).ave_wave_time, electrode_data(electrode_count).average_waveform)
                        plot(elec_ax, electrode_data(electrode_count).ave_max_depol_time, electrode_data(electrode_count).ave_max_depol_point, 'ro');
                        plot(elec_ax, electrode_data(electrode_count).ave_min_depol_time, electrode_data(electrode_count).ave_min_depol_point, 'bo');
                        plot(elec_ax, electrode_data(electrode_count).ave_activation_time, electrode_data(electrode_count).average_waveform(electrode_data(electrode_count).ave_wave_time == electrode_data(electrode_count).ave_activation_time), 'go');

                        if electrode_data(electrode_count).ave_t_wave_peak_time ~= 0 
                            peak_indx = find(electrode_data(electrode_count).ave_wave_time >= electrode_data(electrode_count).ave_t_wave_peak_time);
                            peak_indx = peak_indx(1);
                            t_wave_peak = electrode_data(electrode_count).average_waveform(peak_indx);
                            plot(elec_ax, electrode_data(electrode_count).ave_t_wave_peak_time, t_wave_peak, 'co');
                        end
                        %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                        %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                        hold(elec_ax,'off')
                        
                    end
                end
                
            end
            
        end
    end
    
    
    
    set(well_elec_fig, 'Visible', 'on');
    
  
    
    function changeBDT(well_bdt_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time)

       % BDT CANNOT be equal to 0. 
       if get(well_bdt_ui, 'Value') == 0
           msgbox('BDT cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       min_BP_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       post_spike_ok = 1;
       stim_spike_ok = 1;
       
       for i = 1:length(well_pan_components)
           
           well_ui_con = well_pan_components(i);
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Type')), 'axes')
               axes_children = get(well_ui_con, 'Children');
           
               for c = 1:length(axes_children)
                   child_y_data = axes_children(c).YData;
                   if length(child_y_data) ~= 1
                       if child_y_data(1) == child_y_data(:)
                           prev_bdt_plot = axes_children(c);
                           break;
                       end
                   end


               end
               %set(prev_bdt_plot, 'Visible', 'off');
               bdt_data = ones(length(prev_bdt_plot.XData), 1);
               bdt_data(:,1) = get(well_bdt_ui, 'Value');
               prev_bdt_plot.YData = bdt_data;
               %{
               time_data = linspace(0, prev_bdt_plot.XData(end), length(prev_bdt_plot.XData));
               bdt_data = ones(length(prev_bdt_plot.XData), 1);
               bdt_data(:,1) = get(well_bdt_ui, 'Value');
               hold(well_ui_con, 'on');
               plot(well_ui_con, time_data, bdt_data);
               hold(well_ui_con, 'off');
               %}
           end
       end
       if t_wave_time_ok == 1 && fpd_ok == 1 && t_wave_dur_ok == 1 && stim_spike_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && min_BP_ok == 1 && post_spike_ok == 1 && max_BP_ok ==1 && GE_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
   end

    function changeTWaveTime(t_wave_time_offset_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced, Stims, well_ax, min_voltage, max_voltage)
       disp('change T-wave time')
       %disp('function entered')
       %disp(length(well_bdt_ui_array))
       %disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(t_wave_time_offset_ui, 'Value') == 0
           msgbox('T-Wave peak time cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       min_BP_ok = 1;
       post_spike_ok = 1;
       post_spike_hold_off = NaN;
       stim_spike_hold_off = NaN;
       stim_spike_ok = 1;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end

           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   t_wave_dur = get(well_ui_con, 'Value');
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                  post_spike_hold_off = get(well_ui_con, 'Value');
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                   stim_spike_hold_off = get(well_ui_con, 'Value');
                   stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       if bdt_ok == 1 && fpd_ok == 1 && t_wave_dur_ok == 1 && stim_spike_ok == 1 && start_time_ok == 1 && post_spike_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           disp('set vis')
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       disp(post_spike_ok)
       if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
       %% Pace analysis uses stim spike holdoff too
           if t_wave_dur_ok == 1
               
               t_wave_start_window =  get(t_wave_time_offset_ui, 'Value') - (t_wave_dur/2);
               t_wave_end_window =(t_wave_dur/2) + get(t_wave_time_offset_ui, 'Value');
               if t_wave_start_window < post_spike_hold_off
                   t_wave_start_window = post_spike_hold_off;
               end
               
               axes_children = get(well_ax, 'Children');
       
               %% boxes are smaller magnitudes than max_voltage-min_voltage
               
               % Find all x values equal to t-wave start windows
               found_plot_box = 0;
               
               y_data = linspace(min_voltage*0.25, max_voltage*0.25);
               for c = 1:length(axes_children)
                   child_y_data = axes_children(c).YData;
                   
                   if size(child_y_data) == size(y_data)
                   %if ismember(t_wave_start_window, child_x_data(1, 1))
                       if child_y_data(1) == y_data(1)
                           found_plot_box = 1;
                           break;
                       end
                   end
               end
               
               if found_plot_box == 1
                   for i = 1:length(t_wave_end_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_end_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   for i = 1:length(t_wave_start_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   
                                   child_x_data(:) = t_wave_start_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   
               else
                   hold(well_ax, 'on')
                   
                   for i = 1:length(t_wave_start_window)                       
                       x_start_data = ones(length(y_data), 1);
                       x_end_data = ones(length(y_data), 1);
                       x_start_data(:,1) = t_wave_start_window(i);
                       x_end_data(:,1) = t_wave_end_window(i);
                       plot(well_ax, x_start_data, y_data, 'b')
                       plot(well_ax, x_end_data, y_data, 'b')
                   end
                   hold(well_ax, 'off')
               end

           end
       end
       
       
   end

   function changeTWaveDuration(t_wave_duration_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced, Stims, well_ax, min_voltage, max_voltage)
       disp('change T-wave duration')
       %disp('function entered')
       %disp(length(well_bdt_ui_array))
       %disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(t_wave_duration_ui, 'Value') == 0
           msgbox('T-Wave duration cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       min_BP_ok = 1;
       post_spike_ok = 1;
       post_spike_hold_off = NaN;
       stim_spike_hold_off = NaN;
       stim_spike_ok = 1;
       t_wave_time_ok = 0;
       fpd_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
    
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end

           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   t_wave_offset = get(well_ui_con, 'Value');
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                  post_spike_hold_off = get(well_ui_con, 'Value');
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                   stim_spike_hold_off = get(well_ui_con, 'Value');
                   stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       if bdt_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && stim_spike_ok == 1 && start_time_ok == 1 && post_spike_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           disp('set vis')
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       disp(post_spike_ok)
       if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
       %% Pace analysis uses stim spike holdoff too
           if t_wave_time_ok == 1 
               
               t_wave_start_window =  t_wave_offset - (get(t_wave_duration_ui, 'Value')/2);
               t_wave_end_window = t_wave_offset + (get(t_wave_duration_ui, 'Value')/2);
               if t_wave_start_window < post_spike_hold_off
                   t_wave_start_window = post_spike_hold_off;
               end
               
               axes_children = get(well_ax, 'Children');
       
               %% boxes are smaller magnitudes than max_voltage-min_voltage
               
               % Find all x values equal to t-wave start windows
               found_plot_box = 0;
               
               y_data = linspace(min_voltage*0.25, max_voltage*0.25);
               for c = 1:length(axes_children)
                   child_y_data = axes_children(c).YData;
                   
                   if size(child_y_data) == size(y_data)
                   %if ismember(t_wave_start_window, child_x_data(1, 1))
                       if child_y_data(1) == y_data(1)
                           found_plot_box = 1;
                           break;
                       end
                   end
               end
               
               if found_plot_box == 1
                   for i = 1:length(t_wave_end_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_end_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   for i = 1:length(t_wave_start_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   
                                   child_x_data(:) = t_wave_start_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   
               else
                   hold(well_ax, 'on')
                   
                   for i = 1:length(t_wave_start_window)                       
                       x_start_data = ones(length(y_data), 1);
                       x_end_data = ones(length(y_data), 1);
                       x_start_data(:,1) = t_wave_start_window(i);
                       x_end_data(:,1) = t_wave_end_window(i);
                       plot(well_ax, x_start_data, y_data, 'b')
                       plot(well_ax, x_end_data, y_data, 'b')
                   end
                   hold(well_ax, 'off')
               end

           end
       end
       
       
   end

   function changePostSpike(post_spike_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced, Stims, min_voltage, max_voltage, well_ax)
       
       % BDT CANNOT be equal to 0. 
       if get(post_spike_ui, 'Value') == 0
           msgbox('Post spike hold-off cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       min_BP_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       t_wave_duration = NaN;
       stim_spike_ok = 1;
       stim_spike_hold_off = NaN;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_hold_off = get(well_ui_con, 'Value');
                  stim_spike_ok = 0;
               end
           end
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       
       %{
       if strcmp(spon_paced, 'paced')
           if t_wave_ok == 1 && stim_spike_ok == 1
               % replot
               t_wave_start_window = Stims+get(post_spike_ui, 'Value')+stim_spike_hold_off;
               t_wave_end_window = Stims+stim_spike_hold_off+get(post_spike_ui, 'Value')+t_wave_duration;
               
               axes_children = get(well_ax, 'Children');
       
               %% boxes are smaller magnitudes than max_voltage-min_voltage
               
               % Find all x values equal to t-wave start windows
               found_plot_box = 0;
               
               y_data = linspace(min_voltage*0.5, max_voltage*0.5);
               for c = 1:length(axes_children)
                   child_y_data = axes_children(c).YData;
                   
                   if size(child_y_data) == size(y_data)
                   %if ismember(t_wave_start_window, child_x_data(1, 1))
                       found_plot_box = 1;
                       break;
                   end
               end
               
               if found_plot_box == 1
                   for i = 1:length(t_wave_end_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_end_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   for i = 1:length(t_wave_start_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_start_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   
               else
                   hold(well_ax, 'on')
                   
                   for i = 1:length(t_wave_start_window)                       
                       x_start_data = ones(length(y_data), 1);
                       x_end_data = ones(length(y_data), 1);
                       x_start_data(:,1) = t_wave_start_window(i);
                       x_end_data(:,1) = t_wave_end_window(i);
                       plot(well_ax, x_start_data, y_data)
                       plot(well_ax, x_end_data, y_data)
                   end
                   hold(well_ax, 'off')
               end

           end
       end
       %}
       
       if bdt_ok == 1 && start_time_ok == 1 && stim_spike_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
   end

    function changeStimSpike(stim_spike_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced, Stims, min_voltage, max_voltage, well_ax)
       
       % BDT CANNOT be equal to 0. 
       if get(stim_spike_ui, 'Value') == 0
           msgbox('Stim spike hold-off cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       min_BP_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       post_spike_ok = 1;
       post_spike_hold_off = NaN;
       t_wave_duration = NaN;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end
          
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                   post_spike_hold_off = get(well_ui_con, 'Value');
                   post_spike_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       %disp(spon_paced)
       if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
           % replot
           stim_hold_offs = get(stim_spike_ui, 'Value');
           stim_hold_off_points = [];
           stim_y_points = [];
           
           axes_children = get(well_ax, 'Children');
           
           t_wave_y_data = linspace(min_voltage*0.25, max_voltage*0.25);
           for i = 1:length(stim_hold_offs)
               for ch = 1:length(axes_children)
                   ch_y_data = axes_children(ch).YData;
                   ch_x_data = axes_children(ch).XData;
                   if size(ch_y_data) == size(t_wave_y_data)
                       continue
                   end
                   if size(ch_y_data) == 1
                       continue
                   end
                   x_point = stim_hold_offs(i) + ch_x_data(1);
                   x_indx = find(ch_x_data >= x_point);
                   x_indx = x_indx(1);

                   x_point = ch_x_data(x_indx);
                   y_point = ch_y_data(x_indx);
                   stim_hold_off_points = [stim_hold_off_points; x_point];
                   stim_y_points = [stim_y_points; y_point];
               end
           end
           
           %disp(stim_hold_off_points)

           %% boxes are smaller magnitudes than max_voltage-min_voltage

           % Find all x values equal to t-wave start windows
           found_stim_point = 0;
           
           for c = 1:length(axes_children)
               child_y_data = axes_children(c).YData;

               if size(child_y_data) == 1
               %if ismember(t_wave_start_window, child_x_data(1, 1))
                   found_stim_point = 1;
                   break;
               end
           end

           if found_stim_point == 1
               for i = 1:length(stim_hold_off_points)
                   for c = 1:length(axes_children)
                       child_y_data = axes_children(c).YData;
                       child_x_data = axes_children(c).XData;

                       %disp(child_x_data)
                       if size(child_y_data) == size(t_wave_y_data)
                           continue
                       elseif size(child_y_data) == 1
                           if ~ismember(child_x_data(1), stim_hold_off_points)
                               axes_children(c).XData = stim_hold_off_points(i);
                               axes_children(c).YData = stim_y_points(i);
                               %{
                               for ch = 1:length(axes_children)
                                   ch_y_data = axes_children(ch).YData;
                                   ch_x_data = axes_children(ch).XData;
                                   if size(ch_y_data) == size(t_wave_y_data)
                                       continue
                                   end
                                   if size(ch_y_data) == 1
                                       continue
                                   end
                                   x_point = stim_hold_off_points(i);
                                   x_indx = find(ch_x_data >= x_point);
                                   x_indx = x_indx(1);
                                   
                                   y_point = ch_y_data(x_indx)
                                   x_point = ch_x_data(x_indx)
                                   axes_children(c).XData = x_point;
                                   axes_children(c).YData = y_point;
                                   break;
                               end
                               %}
                               
                               break;
                           end
                       end
                   end
               end
               
           else
               hold(well_ax, 'on')

               for i = 1:length(stim_hold_off_points)  
 
                  plot(well_ax, stim_hold_off_points(i), stim_y_points(i), 'ro')                  
                   

               end
               hold(well_ax, 'off')
           end

       end
  

       %{
       if strcmp(spon_paced, 'paced')
           if t_wave_ok == 1 && post_spike_ok == 1
               % replot
               t_wave_start_window = Stims+get(stim_spike_ui, 'Value')+post_spike_hold_off;
               t_wave_end_window = Stims+get(stim_spike_ui, 'Value')+t_wave_duration+post_spike_hold_off;
               
               axes_children = get(well_ax, 'Children');
       
               %% boxes are smaller magnitudes than max_voltage-min_voltage
               
               % Find all x values equal to t-wave start windows
               found_plot_box = 0;
               
               y_data = linspace(min_voltage*0.5, max_voltage*0.5);
               for c = 1:length(axes_children)
                   child_y_data = axes_children(c).YData;
                   
                   if size(child_y_data) == size(y_data)
                   %if ismember(t_wave_start_window, child_x_data(1, 1))
                       found_plot_box = 1;
                       break;
                   end
               end
               
               if found_plot_box == 1
                   for i = 1:length(t_wave_end_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_end_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   for i = 1:length(t_wave_start_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_start_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   
               else
                   hold(well_ax, 'on')
                   
                   for i = 1:length(t_wave_start_window)                       
                       x_start_data = ones(length(y_data), 1);
                       x_end_data = ones(length(y_data), 1);
                       x_start_data(:,1) = t_wave_start_window(i);
                       x_end_data(:,1) = t_wave_end_window(i);
                       plot(well_ax, x_start_data, y_data)
                       plot(well_ax, x_end_data, y_data)
                   end
                   hold(well_ax, 'off')
               end

           end
       end
       %}
       
       if bdt_ok == 1 && start_time_ok == 1 && post_spike_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
       
       
   end

    function changeMinBPDuration(min_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced)
       %disp('change T-wave duration')
       %disp('function entered')
       %disp(length(well_bdt_ui_array))
       %disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(min_bp_ui, 'Value') == 0
           msgbox('Min BP cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 0;
       post_spike_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       stim_spike_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           

           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') ~= 0
                  max_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           
       end 
       if bdt_ok == 1 && stim_spike_ok == 1 && post_spike_ok == 1 && t_wave_time_ok == 1 && fpd_ok == 1 && t_wave_dur_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && GE_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
    end

    function changeMaxBPDuration(max_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced)
       %disp('change T-wave duration')
       %disp('function entered')
       %disp(length(well_bdt_ui_array))
       %disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(max_bp_ui, 'Value') == 0
           msgbox('Max BP cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       min_BP_ok = 0;
       post_spike_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       stim_spike_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
   
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') ~= 0
                  min_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       if bdt_ok == 1 && stim_spike_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && post_spike_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
   end

    function changeFPD(fpd_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced)
       %disp('change T-wave duration')
       %disp('function entered')
       %disp(length(well_bdt_ui_array))
       %disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(fpd_ui, 'Value') == 0
           msgbox('Max BP cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       min_BP_ok = 0;
       max_BP_ok = 0;
       post_spike_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       stim_spike_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') ~= 0
                  min_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') ~= 0
                  max_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       if bdt_ok == 1 && stim_spike_ok == 1 && max_BP_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && post_spike_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
   end


   function changeStartTime(time_start_ui, well_ax, min_voltage, max_voltage, orig_end_time, spon_paced)
       if get(time_start_ui, 'Value') >= get(time_end_ui, 'Value')
           msgbox('Time region start time must be less than the end time.','Oops!');
           set(time_start_ui, 'Value', 0);
       end
       axes_children = get(well_ax, 'Children');
       
       time_region_plots = [];
       ydata = linspace(min_voltage, max_voltage);
       for c = 1:length(axes_children)
           child_x_data = axes_children(c).XData;
           child_y_data = axes_children(c).YData;
           %disp(child_x_data(1))
           %disp(floor(child_x_data(1)))
           if size(child_y_data) == size(ydata)
               if child_y_data(1) == ydata(1)
                  time_region_plots = [time_region_plots; axes_children(c)];
               end
               %break;
           end
       end
       
       plot1 = time_region_plots(1);
       plot2 = time_region_plots(2);
       disp(plot1.XData(1));
       disp(plot2.XData(1));
       if plot1.XData(1) < plot2.XData(1)
           prev_start_plot = plot1;
       else
           prev_start_plot = plot2;
       end
       disp(prev_start_plot.XData(1));
       
       %set(prev_start_plot, 'Visible', 'off');
       %hold(well_ax, 'on');
       
       xdata = ones(length(ydata), 1);
       xdata(:,1) = get(time_start_ui, 'Value');
       %plot(well_ax, xdata, ydata)
       %hold(well_ax, 'off');
       prev_start_plot.XData = xdata;
       
       if get(time_start_ui, 'Value') ~= 0
           well_pan_components = get(well_p, 'Children');
           bdt_ok = 1;
           start_time_ok = 1;
           end_time_ok = 1;
           t_wave_time_ok = 0;
           t_wave_dur_ok = 0;
           fpd_ok = 1;
           GE_ok = 1;
           max_BP_ok = 1;
           min_BP_ok = 1;
           post_spike_ok = 1;
           stim_spike_ok = 1;
           for i = 1:length(well_pan_components)
               well_ui_con = well_pan_components(i);
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
                   if get(well_ui_con, 'Value') == 0
                      %set(submit_in_well_button, 'Visible', 'on')
                      bdt_ok = 0;
                   end
               end
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
                   if get(well_ui_con, 'Value') ~= 0 
                       t_wave_time_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
                   if get(well_ui_con, 'Value') ~= 0 
                       t_wave_dur_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
                   if get(well_ui_con, 'Value') == 0
                      fpd_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
                   if get(well_ui_con, 'Value') == 0
                      stim_spike_ok = 0;
                   end
               end
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
                   if get(well_ui_con, 'Value') == 0
                      post_spike_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
                   if get(well_ui_con, 'Value') == 0
                      min_BP_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
                   if get(well_ui_con, 'Value') == 0
                      max_BP_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
                   if get(well_ui_con, 'Value') == 0 
                       start_time_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
                   else
                       start_time = get(well_ui_con, 'Value');
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
                   if get(well_ui_con, 'Value') == orig_end_time
                       end_time_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
                   else
                       end_time = get(well_ui_con, 'Value');
                   end
               end
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
                   if get(well_ui_con, 'Value') == 0
                       GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
           end 
           if bdt_ok == 1 && stim_spike_ok == 1 && post_spike_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && GE_ok == 1
               %if start_time < end_time
               set(submit_in_well_button, 'Visible', 'on')
               %end
           end
       end
   end

   function changeEndTime(time_end_ui, well_ax, min_voltage, max_voltage, orig_end_time, spon_paced)
       if get(time_start_ui, 'Value') >= get(time_end_ui, 'Value')
           msgbox('Time region end time must be greater than the start time.','Oops!');
           %return;
           set(time_end_ui, 'Value', orig_end_time);
       end
       
       axes_children = get(well_ax, 'Children');
       
       time_region_plots = [];
       ydata = linspace(min_voltage, max_voltage);
       for c = 1:length(axes_children)
           child_x_data = axes_children(c).XData;
           child_y_data = axes_children(c).YData;
           if size(child_y_data) == size(ydata)
               if child_y_data(1) == ydata(1)
                  time_region_plots = [time_region_plots; axes_children(c)];
               end
               %break;
           end
       end
       
       plot1 = time_region_plots(1);
       plot2 = time_region_plots(2);
       if plot1.XData(1) > plot2.XData(1)
           prev_start_plot = plot1;
       else
           prev_start_plot = plot2;
       
       end
       
       %set(prev_start_plot, 'Visible', 'off');
       %hold(well_ax, 'on');
       
       xdata = ones(length(ydata), 1);
       xdata(:,1) = get(time_end_ui, 'Value');
       %plot(well_ax, xdata, ydata)
       %hold(well_ax, 'off');
       prev_start_plot.XData = xdata;
       
       if get(time_end_ui, 'Value') ~= orig_end_time
           well_pan_components = get(well_p, 'Children');
           bdt_ok = 1;
           start_time_ok = 1;
           end_time_ok = 1;
           t_wave_time_ok = 0;
           t_wave_dur_ok = 0;
           fpd_ok = 1;
           max_BP_ok = 1;
           min_BP_ok = 1;
           post_spike_ok = 1;
           stim_spike_ok = 1;
           for i = 1:length(well_pan_components)
               well_ui_con = well_pan_components(i);
            
               if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
                   if get(well_ui_con, 'Value') == 0
                      %set(submit_in_well_button, 'Visible', 'on')
                      bdt_ok = 0;
                   end
               end
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
                   if get(well_ui_con, 'Value') ~= 0 
                       t_wave_time_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
                   if get(well_ui_con, 'Value') ~= 0 
                       t_wave_dur_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
                   if get(well_ui_con, 'Value') == 0
                      fpd_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
                   if get(well_ui_con, 'Value') == 0
                      stim_spike_ok = 0;
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
                   if get(well_ui_con, 'Value') == 0
                      post_spike_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
                   if get(well_ui_con, 'Value') == 0
                      max_BP_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
                   if get(well_ui_con, 'Value') == 0
                      min_BP_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
                   if get(well_ui_con, 'Value') == 0 
                       start_time_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
                   else
                       start_time = get(well_ui_con, 'Value');
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
                   if get(well_ui_con, 'Value') == orig_end_time
                       end_time_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
                   else
                       end_time = get(well_ui_con, 'Value');
                   end
               end
               
              
           end 
           if bdt_ok == 1 && stim_spike_ok == 1 && post_spike_ok == 1 && max_BP_ok == 1 && min_BP_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && fpd_ok == 1 && t_wave_dur_ok == 1 && t_wave_time_ok == 1 
               %if start_time < end_time
               set(submit_in_well_button, 'Visible', 'on')
               %end
           end
       end
   end

   function changeGEWindow(stable_duration_ui, well_ax, spon_paced)
       % BDT CANNOT be equal to 0. 
       if get(stable_duration_ui, 'Value') == 0
           msgbox('T-Wave duration cannot be equal to 0','Oops!');
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       min_BP_ok = 1;
       post_spike_ok = 1;
       stim_spike_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end

           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end

           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_ok = 0;
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       if bdt_ok == 1 && stim_spike_ok == 1 && post_spike_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
   end

   function submitButtonPushed(submit_in_well_button, well_fig)
       set(well_fig, 'Visible', 'off')
   end

   function clearAllBDTPushed(clear_all_bdt_button, run_button)
       %disp('clear BDT');
       %% Must remove all BDT plots 
       %% Set all BDTs to be zero again
       panel_sub_panels = get(p, 'Children');
      
       for i = 1:length(panel_sub_panels)

           sub_pan = panel_sub_panels(i);
           sub_p_ui_controls = get(sub_pan, 'Children');
           
           for j = 1:length(sub_p_ui_controls)

               if strcmp(string(get(sub_p_ui_controls(j), 'Tag')), 'BDT')    
                   %disp('BDT');
                   bdt_ui_ctrl = sub_p_ui_controls(j);
  
                   set(bdt_ui_ctrl, 'Value', 0);
                   set(clear_all_bdt_button, 'Visible', 'off');
                   set(run_button, 'Visible', 'off');
                   
                   
               elseif strcmp(string(get(sub_p_ui_controls(j), 'Type')), 'axes')
                   
                   axes_ctrl = sub_p_ui_controls(j);
                   
               end
           end
           
           axes_children = get(axes_ctrl, 'Children');
           
           for c = 1:length(axes_children)
               child_y_data = axes_children(c).YData;
               if child_y_data(1) == child_y_data(:)
                   prev_bdt_plot = axes_children(c);
                   break;
               end
               
               
           end
           set(prev_bdt_plot, 'Visible', 'off');
           
           
       end
  
   end

end