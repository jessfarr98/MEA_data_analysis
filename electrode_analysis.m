function [well_electrode_data] = electrode_analysis(well_electrode_data, num_electrode_rows, num_electrode_cols, reanalyse_electrodes, well_elec_fig, well_pan, exp_ax, expand_elec_panel, GE_ax, GE_pan, change_GE_dropdown, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
    if isempty(reanalyse_electrodes)
        set(well_elec_fig, 'Visible', 'on');
        return
        
    end

    set(well_elec_fig, 'Visible', 'off');
    electrode_data = well_electrode_data.electrode_data;
    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    %%disp('elec reanalyse')
    %reanalyse_electrodes
    %pause(100)
    electrode_count = 0;
    found_electrode = 0;
    for elec_r = num_electrode_rows:-1:1  
        for elec_c = 1:num_electrode_cols
            electrode_count = electrode_count+1;
            electrode_id = electrode_data(electrode_count).electrode_id;
            if isempty(electrode_id)
                continue
            end
             
            if contains(electrode_id, reanalyse_electrodes)
                re_count = electrode_count;
                found_electrode = 1;
                %%disp(electrode_id) 
                % reanalyse this electrode
                % create uifigure similar to at input
                well_fig = uifigure;
                well_fig.Name = electrode_data(electrode_count).electrode_id;
                well_p = uipanel(well_fig, 'BackgroundColor','#f2c2c2', 'Position', [0 0 screen_width screen_height]);
                
                movegui(well_fig,'center');
                well_fig.WindowState = 'maximized';

                well_ax = uiaxes(well_p, 'BackgroundColor','#f2c2c2', 'Position', [10 100 screen_width-300 screen_height-200]);
                hold(well_ax, 'on')
                plot(well_ax, electrode_data(electrode_count).time, 1000*electrode_data(electrode_count).data);
                xlabel(well_ax, 'Seconds (s)');
                ylabel(well_ax, 'Milivolts (mV)');
                
                min_voltage = 1000*min(electrode_data(electrode_count).data);
                max_voltage = 1000*max(electrode_data(electrode_count).data);
                
                submit_in_well_button = uibutton(well_p,'push', 'BackgroundColor', '#3dd4d1', 'Text', 'Submit Inputs for Well', 'Position',[screen_width-250 120 200 60], 'ButtonPushedFcn', @(submit_in_well_button,event) submitButtonPushed(submit_in_well_button, well_fig));
                
                set(submit_in_well_button, 'Visible', 'off')
                

                t_wave_up_down_text = uieditfield(well_p, 'Text', 'Value', 'T-wave shape', 'FontSize', 8,'Position', [120 60 100 40], 'Editable','off');
                t_wave_up_down_dropdown = uidropdown(well_p, 'Items', {'minimum', 'maximum', 'inflection', 'zero crossing'}, 'FontSize', 8, 'Position', [120 10 100 40]);
                t_wave_up_down_dropdown.ItemsData = [1 2 3 4];

                help_button = uibutton(well_p, 'push', 'Text', 'Help', 'Position',[screen_width-200 440 100 60], 'ButtonPushedFcn', @(help_button,event) HelpButtonPushed(t_wave_up_down_dropdown));
     
                t_wave_peak_offset_text = uieditfield(well_p,'Text', 'Value', 'Repol. Time Offset (s)', 'FontSize', 8, 'Position', [240 60 100 40], 'Editable','off');
                t_wave_peak_offset_ui = uieditfield(well_p, 'numeric', 'Tag', 'T-Wave Time', 'BackgroundColor','#e68e8e', 'Position', [240 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(t_wave_peak_offset_ui,event) changeTWaveTime(t_wave_peak_offset_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced, electrode_data(electrode_count).Stims, well_ax, min_voltage, max_voltage));
          
                t_wave_duration_text = uieditfield(well_p,'Text', 'Value', 'T-wave duration (s)', 'FontSize', 8, 'Position', [360 60 100 40], 'Editable','off');
                t_wave_duration_ui = uieditfield(well_p, 'numeric', 'Tag', 'T-Wave Dur', 'BackgroundColor','#e68e8e', 'Position', [360 10 100 40], 'ValueChangedFcn',@(t_wave_duration_ui,event) changeTWaveDuration(t_wave_duration_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced, electrode_data(electrode_count).Stims, well_ax, min_voltage, max_voltage));
                
                %est_fpd_text = uieditfield(well_p, 'Text', 'Value', 'Estimated FPD', 'FontSize', 12, 'Position', [480 60 100 40], 'Editable','off');
                %est_fpd_ui = uieditfield(well_p, 'numeric', 'Tag', 'FPD', 'Position', [480 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(est_fpd_ui,event) changeFPD(est_fpd_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced));
          
                post_spike_text = uieditfield(well_p, 'Text', 'Value', 'Post spike hold-off (s)', 'FontSize', 8, 'Position', [480 60 100 40], 'Editable','off');
                post_spike_ui = uieditfield(well_p, 'numeric', 'Tag', 'Post-spike', 'BackgroundColor','#e68e8e', 'Position', [480 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(post_spike_ui,event) changePostSpike(post_spike_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced,  electrode_data(electrode_count).Stims, min_voltage, max_voltage, well_ax));
                
                filter_intensity_text = uieditfield(well_p, 'Text', 'FontSize', 8, 'Value', 'Filtering Intensity', 'Position', [600 60 100 40], 'Editable','off');
                filter_intensity_dropdown = uidropdown(well_p, 'Items', {'none', 'low', 'medium', 'strong'}, 'FontSize', 8,'Position', [600 10 100 40]);
                filter_intensity_dropdown.ItemsData = [1 2 3 4];
                
                

                well_bdt_text = uieditfield(well_p,'Text', 'Value', 'BDT', 'FontSize', 8, 'Position', [10 60 100 40], 'Editable','off');
                well_bdt_ui = uieditfield(well_p, 'numeric', 'Tag', 'BDT', 'BackgroundColor','#e68e8e', 'Position', [10 10 100 40], 'ValueChangedFcn',@(well_bdt_ui,event) changeBDT(well_bdt_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end)));
                
                
                min_bp_text = uieditfield(well_p,'Text', 'Value', 'Min. BP (s)', 'FontSize', 8, 'Position', [720 60 100 40], 'Editable','off');
                min_bp_ui = uieditfield(well_p, 'numeric', 'Tag', 'Min BP', 'BackgroundColor','#e68e8e', 'Position', [720 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(min_bp_ui,event) changeMinBPDuration(min_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced));

                max_bp_text = uieditfield(well_p,'Text', 'Value', 'Max. BP (s)', 'FontSize', 8, 'Position', [840 60 100 40], 'Editable','off');
                max_bp_ui = uieditfield(well_p, 'numeric', 'Tag', 'Max BP','BackgroundColor','#e68e8e', 'Position', [840 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(max_bp_ui,event) changeMaxBPDuration(max_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced));

                stim_spike_text = uieditfield(well_p,'Text', 'Value', 'Stim. Spike hold-off (s)', 'FontSize', 8, 'Position', [960 60 100 40], 'Editable','off');
                stim_spike_ui = uieditfield(well_p, 'numeric', 'Tag', 'Stim spike', 'BackgroundColor','#e68e8e','Position', [960 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(stim_spike_ui,event) changeStimSpike(stim_spike_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, electrode_data(electrode_count).time(end), spon_paced, electrode_data(electrode_count).Stims, min_voltage, max_voltage, well_ax)); 
                
                
                if strcmp(electrode_data(electrode_count).spon_paced, 'paced') 
                    paced_ectopic_dropdown_text = uieditfield(well_p, 'Text', 'Value', 'Paced Options', 'Position', [screen_width-250 290 200 40], 'Editable','off');
                    paced_ectopic_dropdown = uidropdown(well_p, 'Items', {'paced', 'paced w ectopic beats'},  'Position', [screen_width-250 250 200 40], 'ValueChangedFcn',@(paced_ectopic_dropdown,event) changedPacedBDT(paced_ectopic_dropdown, well_ax, length(electrode_data(electrode_count).time)));
                    paced_ectopic_dropdown.ItemsData = [1 2];
                    
                    set(well_bdt_text,'visible', 'off')
                    set(well_bdt_ui,'visible', 'off')
                    set(well_bdt_ui,'value', -1)

                    set(min_bp_text,'visible', 'off')
                    set(min_bp_ui,'visible', 'off')
                    set(min_bp_ui,'value', -1)
                    
                    set(max_bp_text,'visible', 'off')
                    set(max_bp_ui,'visible', 'off')
                    set(max_bp_ui,'value', -1)
                    
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                    set(stim_spike_text,'visible', 'off')
                    set(stim_spike_ui,'visible', 'off')
                    set(stim_spike_ui,'value', -1)
                    
                   
                    init_bdt_data = ones(length(electrode_data(electrode_count).time), 1);
                    init_bdt_data(:,1) = 0;
                    plot(well_ax, electrode_data(electrode_count).time, init_bdt_data);
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                    init_bdt_data = ones(length(electrode_data(electrode_count).time), 1);
                    init_bdt_data(:,1) = 0;
                    plot(well_ax, electrode_data(electrode_count).time, init_bdt_data);
                end
                
                %reanalyse_selected_beat_button = uibutton(well_p,'push','Text', 'Submit Inputs for Well', 'Position',[screen_width-250 120 200 60], 'ButtonPushedFcn', @(submit_in_well_button,event) submitButtonPushed(submit_in_well_button, well_fig));
                
                

              
            %end
            %if found_electrode == 1
                while(1)
                    pause(0.01)
                    if strcmp(get(well_fig, 'Visible'), 'off')
                        break; 
                    end
                end

                
                % input elements to analyse just this electrode again and then re-set the electrode_data and then 
                if get(t_wave_up_down_dropdown, 'Value') == 1
                    t_wave_shape = 'min';
                elseif get(t_wave_up_down_dropdown, 'Value') == 2
                    t_wave_shape = 'max';
                elseif get(t_wave_up_down_dropdown, 'Value') == 3
                    t_wave_shape = 'inflection';
                elseif get(t_wave_up_down_dropdown, 'Value') == 4
                    t_wave_shape = 'zero crossing';

                end
                
                if get(filter_intensity_dropdown, 'Value') == 1
                    filter_intensity = 'none';
                elseif get(filter_intensity_dropdown, 'Value') == 2
                    filter_intensity = 'low';
                elseif get(filter_intensity_dropdown, 'Value') == 3
                    filter_intensity = 'medium';
                elseif get(filter_intensity_dropdown, 'Value') == 4
                    filter_intensity = 'strong';

                end
                
                
                electrode_data(electrode_count).post_spike_hold_off = get(post_spike_ui, 'Value');
                electrode_data(electrode_count).t_wave_offset = get(t_wave_peak_offset_ui, 'Value');
                electrode_data(electrode_count).t_wave_duration = get(t_wave_duration_ui, 'Value');
                electrode_data(electrode_count).t_wave_shape = t_wave_shape;
                electrode_data(electrode_count).filter_intensity = filter_intensity;

                if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                    electrode_data(electrode_count).bdt = get(well_bdt_ui, 'Value')/1000;
                    electrode_data(electrode_count).min_bp = get(min_bp_ui, 'Value');
                    electrode_data(electrode_count).max_bp = get(max_bp_ui, 'Value');                   
                    
                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array, electrode_data(electrode_count).depol_slope_array, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data, electrode_data(electrode_count).t_wave_wavelet_array, electrode_data(electrode_count).t_wave_polynomial_degree_array] = extract_beats_V2('', electrode_data(electrode_count).time, electrode_data(electrode_count).data, get(well_bdt_ui, 'Value')/1000, electrode_data(electrode_count).spon_paced, 'on', 'stable', NaN, NaN, stable_ave_analysis, NaN, NaN, '', electrode_data(electrode_count).electrode_id, t_wave_shape, get(t_wave_duration_ui, 'Value'), electrode_data(electrode_count).Stims, get(min_bp_ui, 'Value'), get(max_bp_ui, 'Value'), get(post_spike_ui, 'Value'), get(t_wave_peak_offset_ui, 'Value'),nan, filter_intensity);     
                    
                    [electrode_data(electrode_count).arrhythmia_indx, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).num_arrhythmic] = arrhythmia_analysis(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).warning_array);
                
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                    electrode_data(electrode_count).bdt = get(well_bdt_ui, 'Value')/1000;
                    electrode_data(electrode_count).min_bp = get(min_bp_ui, 'Value');
                    electrode_data(electrode_count).max_bp = get(max_bp_ui, 'Value');    
                    electrode_data(electrode_count).stim_spike_hold_off = get(stim_spike_ui, 'Value');
                    
                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array, electrode_data(electrode_count).depol_slope_array, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data, electrode_data(electrode_count).t_wave_wavelet_array, electrode_data(electrode_count).t_wave_polynomial_degree_array] = extract_paced_bdt_beats('', electrode_data(electrode_count).time, electrode_data(electrode_count).data, get(well_bdt_ui, 'Value')/1000, electrode_data(electrode_count).spon_paced, beat_to_beat, analyse_all_b2b, NaN, NaN, stable_ave_analysis, NaN, NaN, '', electrode_data(electrode_count).electrode_id, t_wave_shape, get(t_wave_duration_ui, 'Value'), electrode_data(electrode_count).Stims,  get(post_spike_ui, 'Value'), get(stim_spike_ui, 'Value'), get(t_wave_peak_offset_ui, 'Value'), nan, get(min_bp_ui, 'Value'), get(max_bp_ui, 'Value'), filter_intensity);     
                    [electrode_data(electrode_count).arrhythmia_indx, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).num_arrhythmic] = arrhythmia_analysis(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).warning_array);
                    %well_electrode_data.conduction_velocity = calculateConductionVelocity(electrode_data,  num_electrode_rows, num_electrode_cols);
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                    electrode_data(electrode_count).stim_spike_hold_off = get(stim_spike_ui, 'Value');
                    
                    
                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts,electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array, electrode_data(electrode_count).depol_slope_array, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).Stim_volts, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data, electrode_data(electrode_count).t_wave_wavelet_array, electrode_data(electrode_count).t_wave_polynomial_degree_array] = extract_paced_beats('', electrode_data(electrode_count).time, electrode_data(electrode_count).data, NaN, electrode_data(electrode_count).spon_paced, 'on', 'all', NaN, NaN, stable_ave_analysis, NaN, NaN, '', electrode_data(electrode_count).electrode_id, t_wave_shape, get(t_wave_duration_ui, 'Value'), electrode_data(electrode_count).Stims, get(post_spike_ui, 'Value'), get(stim_spike_ui, 'Value'), get(t_wave_peak_offset_ui, 'Value'),nan, filter_intensity, 'off');     
                    [electrode_data(electrode_count).arrhythmia_indx, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).num_arrhythmic] = arrhythmia_analysis(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).warning_array);
                    %well_electrode_data.conduction_velocity = calculateConductionVelocity(electrode_data,  num_electrode_rows, num_electrode_cols);
                end
                
                if ~strcmp(beat_to_beat, 'on')
                    if strcmp(stable_ave_analysis, 'time_region')
                        [~, electrode_data] = compute_average_time_region_waveform(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).time, electrode_data(electrode_count).data, electrode_data, electrode_count, electrode_data(electrode_count).electrode_id, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).beat_start_times, 'N/A', '', electrode_data(electrode_count).post_spike_hold_off, electrode_data(electrode_count).stim_spike_hold_off, electrode_data(electrode_count).spon_paced, beat_to_beat, electrode_data(electrode_count).t_wave_shape, electrode_data(electrode_count).t_wave_duration, electrode_data(electrode_count).t_wave_offset, nan, electrode_data(electrode_count).filter_intensity, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end);

                    elseif strcmp(stable_ave_analysis, 'stable') 
                        
                        [average_waveform_duration, average_waveform, elec_min_stdev, artificial_time_space, electrode_data] = compute_electrode_average_stable_waveform(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).time, electrode_data(electrode_count).data, electrode_data(electrode_count).stable_beats_duration, electrode_data, electrode_count, electrode_id, '', '', electrode_data(electrode_count).post_spike_hold_off, electrode_data(electrode_count).stim_spike_hold_off, spon_paced, beat_to_beat, electrode_data(electrode_count).t_wave_shape, electrode_data(electrode_count).t_wave_duration, electrode_data(electrode_count).t_wave_offset, nan, electrode_data(electrode_count).filter_intensity);
                        
                        
                        %{
                        electrode_data(electrode_count).min_stdev = min_stdev;
                        electrode_data(electrode_count).average_waveform = average_waveform;
                        electrode_data(electrode_count).time = artificial_time_space;
                        electrode_data(electrode_count).electrode_id = electrode_id;
                        %}
                        change_GE = 0;

                        if elec_min_stdev <= well_electrode_data.min_stdev
                            well_electrode_data.min_stdev = elec_min_stdev;
                            well_electrode_data.GE_electrode_indx = electrode_count;
                            change_GE = 1;
                        end
                        if strcmp(get(change_GE_dropdown, 'Visible'), 'on')
                            change_GE = 0;

                        else
                            change_GE = 1;
                            min_stdevs = [electrode_data(:).min_stdev];
                            non_zero_stddevs = find(min_stdevs ~=0);
                            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
                            
                            well_electrode_data.min_stdev = min(min_stdevs(non_zero_stddevs));
                            well_electrode_data.GE_electrode_indx = min_electrode_beat_stdev_indx;
                        end

                    end
                    
                end
                %%disp(electrode_data(electrode_count).activation_times(2))
                elec_pans = get(well_pan, 'Children');
                for ui = 1:length(elec_pans)
                    if strcmp(get(elec_pans(ui), 'Title'), electrode_data(electrode_count).electrode_id)
                        %%disp('found the panel')
                        
                        %%disp(get(elec_pans(ui), 'Title'))
                        %%disp(electrode_data(electrode_count).electrode_id)
                        %elec_ax = get(elec_pans(ui), 'Children');
                        elec_pan_children = get(elec_pans(ui), 'Children');
                        for e_ch = 1:length(elec_pan_children)
                            %disp(get(elec_pan_children(e_ch), 'type'))
                            if strcmp(get(elec_pan_children(e_ch), 'type'), 'axes')
                                elec_ax = elec_pan_children(e_ch);
                            end
                        end
                        cla(elec_ax);
                        
                        MEA_GUI_display_B2B_electrodes(electrode_data, electrode_count, elec_ax)
                        
                        %{
                        hold(elec_ax, 'on')
                        
                        if strcmp(beat_to_beat, 'on')
                            if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                                num_beats = length(electrode_data(electrode_count).beat_start_times);
                            elseif strcmp(electrode_data(electrode_count).spon_paced, 'spon')

                                num_beats = length(electrode_data(electrode_count).beat_start_times);
                            elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                                %num_beats = length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
                                [sr, sc] = size(electrode_data(electrode_count).Stims);
                                [br, bc] = size(electrode_data(electrode_count).beat_start_times);

                                if bc == 1 && sc ~= 1
                                    electrode_data(electrode_count).beat_start_times = reshape(electrode_data(electrode_count).beat_start_times, [bc br]);
                                end
                                if sc == 1 && bc ~= 1
                                    electrode_data(electrode_count).beat_start_times = reshape(electrode_data(electrode_count).beat_start_times, [bc br]);
                                end

                                try 
                                    ectopic_plus_stims = [electrode_data(electrode_count).beat_start_times electrode_data(electrode_count).Stims];
                                catch                                
                                    ectopic_plus_stims = [electrode_data(electrode_count).Stims; electrode_data(electrode_count).beat_start_times];

                                end
                                ectopic_plus_stims = sort(ectopic_plus_stims);
                                ectopic_plus_stims = uniquetol(ectopic_plus_stims);
                                num_beats = length(ectopic_plus_stims);
                            end

                            if num_beats > 4    

                                mid_beat = floor(num_beats/2);
                                %elec_ax.XLim = [electrode_data(electrode_count).beat_start_times(mid_beat) electrode_data(electrode_count).beat_start_times(mid_beat+1)];

                                if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                                    time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
                                    time_end = electrode_data(electrode_count).beat_start_times(mid_beat+1);

                                    time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
                                    time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);
                                    %plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).Stims, well_electrode_data(well_count).electrode_data(electrode_count).Stim_volts, 'mo');

                                    filtered_time_reg_start_indx = find(electrode_data(electrode_count).filtered_time >= time_start);
                                    filtered_time_reg_end_indx = find(electrode_data(electrode_count).filtered_time >= time_end);

                                    plot(elec_ax, electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

                                    plot(elec_ax, electrode_data(electrode_count).filtered_time(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)), electrode_data(electrode_count).filtered_data(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)));


                                    %plot(elec_ax, electrode_data(electrode_count).Stims(mid_beat), electrode_data(electrode_count).Stim_volts(mid_beat), 'm.', 'MarkerSize', 20);
                                    plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat), electrode_data(electrode_count).beat_start_volts(mid_beat), 'm.', 'MarkerSize', 20);

                                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                                    time_start = ectopic_plus_stims(mid_beat);
                                    time_end = ectopic_plus_stims(mid_beat+1);

                                    if ismember(electrode_data(electrode_count).beat_start_times , time_start)
                                        if electrode_data(electrode_count).beat_start_times(mid_beat) - electrode_data(electrode_count).post_spike_hold_off > electrode_data(electrode_count).time(1)

                                            time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-electrode_data(electrode_count).post_spike_hold_off;
                                        else

                                            time_start = electrode_data(electrode_count).beat_start_times(mid_beat);

                                        end 
                                        time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
                                        time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);

                                        filtered_time_reg_start_indx = find(electrode_data(electrode_count).filtered_time >= time_start);
                                        filtered_time_reg_end_indx = find(electrode_data(electrode_count).filtered_time >= time_end);


                                        plot(elec_ax,electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

                                        plot(elec_ax,electrode_data(electrode_count).filtered_time(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)), electrode_data(electrode_count).filtered_data(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)));


                                        plot(elec_ax, ectopic_plus_stims(mid_beat), electrode_data(electrode_count).data(time_reg_start_indx(1)), 'g.', 'MarkerSize', 20);

                                    else
                                        time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
                                        time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);

                                        filtered_time_reg_start_indx = find(electrode_data(electrode_count).filtered_time >= time_start);
                                        filtered_time_reg_end_indx = find(electrode_data(electrode_count).filtered_time >= time_end);


                                        plot(elec_ax,electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

                                        plot(elec_ax,electrode_data(electrode_count).filtered_time(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)), electrode_data(electrode_count).filtered_data(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)));


                                        plot(elec_ax, ectopic_plus_stims(mid_beat), electrode_data(electrode_count).data(time_reg_start_indx(1)), 'm.', 'MarkerSize', 20);

                                    end

                                else
                                    %{
                                    if electrode_data(electrode_count).bdt < 0
                                        time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-electrode_data(electrode_count).post_spike_hold_off;

                                    else
                                        time_start = electrode_data(electrode_count).beat_start_times(mid_beat);

                                    end
                                    %}
                                    if electrode_data(electrode_count).beat_start_times(mid_beat) - electrode_data(electrode_count).post_spike_hold_off > electrode_data(electrode_count).time(1)

                                        time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-electrode_data(electrode_count).post_spike_hold_off;
                                    else

                                        time_start = electrode_data(electrode_count).beat_start_times(mid_beat);

                                    end 


                                    %time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
                                    time_end = electrode_data(electrode_count).beat_start_times(mid_beat+1);

                                    time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
                                    time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);

                                    filtered_time_reg_start_indx = find(electrode_data(electrode_count).filtered_time >= time_start);
                                    filtered_time_reg_end_indx = find(electrode_data(electrode_count).filtered_time >= time_end);


                                    plot(elec_ax,electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

                                    plot(elec_ax, electrode_data(electrode_count).filtered_time(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)), electrode_data(electrode_count).filtered_data(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)));

                                    plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat), electrode_data(electrode_count).beat_start_volts(mid_beat), 'g.', 'MarkerSize', 20);

                                end



                                t_wave_indx = find(electrode_data(electrode_count).t_wave_peak_times >= time_start);
                                
                                if length(t_wave_indx) > 1
                                    t_wave_indx = t_wave_indx(1);
                                    t_wave_peak_time = electrode_data(electrode_count).t_wave_peak_times(t_wave_indx);
                                    t_wave_p = electrode_data(electrode_count).t_wave_peak_array(t_wave_indx);
                                    if ~isnan(t_wave_peak_time) && ~isnan(t_wave_p)
                                        plot(elec_ax, t_wave_peak_time, t_wave_p, 'c.', 'MarkerSize', 20);
                                    end
                                end

                                max_depol_indx = find(electrode_data(electrode_count).max_depol_time_array >= time_start);
                                max_depol_indx = max_depol_indx(1);

                                min_depol_indx = find(electrode_data(electrode_count).min_depol_time_array >= time_start);
                                min_depol_indx = min_depol_indx(1);
                                plot(elec_ax, electrode_data(electrode_count).max_depol_time_array(max_depol_indx), electrode_data(electrode_count).max_depol_point_array(max_depol_indx), 'r.', 'MarkerSize', 20);
                                plot(elec_ax, electrode_data(electrode_count).min_depol_time_array(min_depol_indx), electrode_data(electrode_count).min_depol_point_array(min_depol_indx), 'b.', 'MarkerSize', 20);


                                act_indx = find(electrode_data(electrode_count).activation_times >= time_start);
                                act_indx = act_indx(1);
                                plot(elec_ax, electrode_data(electrode_count).activation_times(act_indx), electrode_data(electrode_count).activation_point_array(act_indx), 'k.', 'MarkerSize', 20);
                                xlim(elec_ax, [time_start time_end])

                            else
                                plot(elec_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);

                                t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                                t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                                t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                                t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                                plot(elec_ax, t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
                                plot(elec_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
                                plot(elec_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

                                [~, beat_start_volts, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
                                beat_start_volts = electrode_data(electrode_count).data(beat_start_volts);


                                if strcmp(electrode_data(electrode_count).spon_paced, 'paced')

                                    plot(elec_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'm.', 'MarkerSize', 20);

                                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                                    plot(elec_ax, electrode_data(electrode_count).beat_start_times, beat_start_volts, 'g.', 'MarkerSize', 20);
                                    plot(elec_ax, electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);

                                else
                                    plot(elec_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);



                                end
                                %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');

                                plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'k.', 'MarkerSize', 20);

                                % Zoom in on beat in the middle

                            end
                            %well_electrode_data(well_count, electrode_count).save_fig = gcf;
                            %electrode_data(electrode_count).save_fig = gcf;
                            
                        else
                            if strcmp(stable_ave_analysis, 'time_region')
                                
                                if isempty(electrode_data(electrode_count).electrode_id)
                                   continue 
                                end

                                if isempty(electrode_data(electrode_count).ave_wave_time)
                                   continue 
                                end

 
                                plot(elec_ax, electrode_data(electrode_count).ave_wave_time, electrode_data(electrode_count).average_waveform);
                                plot(elec_ax, electrode_data(electrode_count).filtered_ave_wave_time, electrode_data(electrode_count).filtered_average_waveform);
                                %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                                plot(elec_ax, electrode_data(electrode_count).ave_max_depol_time, electrode_data(electrode_count).ave_max_depol_point, 'r.', 'MarkerSize', 20);
                                plot(elec_ax, electrode_data(electrode_count).ave_min_depol_time, electrode_data(electrode_count).ave_min_depol_point, 'b.', 'MarkerSize', 20);


                                plot(elec_ax, electrode_data(electrode_count).ave_activation_time, electrode_data(electrode_count).ave_activation_point, 'k.', 'MarkerSize', 20);

                                if electrode_data(electrode_count).ave_t_wave_peak_time ~= 0 
                                    plot(elec_ax, electrode_data(electrode_count).ave_t_wave_peak_time, electrode_data(electrode_count).ave_t_wave_peak, 'c.', 'MarkerSize', 20);
                                end
                                
                                
                                
                                exp_children = get(expand_elec_panel, 'children');
                                for ec = 1:length(exp_children)
                                    %disp(get(exp_children(ec), 'type'))
                                    if strcmp(get(exp_children(ec), 'type'), 'uieditfield')
                                        %disp(get(exp_children(ec), 'value'))
                                        curr_value = get(exp_children(ec), 'value');
                                        if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                                        
                                            if contains('BDT', curr_value)
                                                set(exp_children(ec), 'Value', strcat('BDT = ', num2str(electrode_data(electrode_count).bdt)))
                                            elseif contains('min BP', curr_value)
                                                set(exp_children(ec), 'Value', strcat('min BP = ', num2str(electrode_data(electrode_count).min_bp)))
                                            elseif contains('max BP', curr_value)
                                                set(exp_children(ec), 'Value', strcat('max BP = ', num2str(electrode_data(electrode_count).max_bp)))
                                            end
                                            
                                           
                                        elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                                            if contains('BDT', curr_value)
                                                set(exp_children(ec), 'Value', strcat('BDT = ', num2str(electrode_data(electrode_count).bdt)))
                                            elseif contains('min BP', curr_value)
                                                set(exp_children(ec), 'Value', strcat('min BP = ', num2str(electrode_data(electrode_count).min_bp)))
                                            elseif contains('max BP', curr_value)
                                                set(exp_children(ec), 'Value', strcat('max BP = ', num2str(electrode_data(electrode_count).max_bp)))
                                            elseif contains('Stim-spike hold-off', curr_value)
                                                set(exp_children(ec), 'Value', strcat('Stim-spike hold-off = ', num2str(electrode_data(electrode_count).stim_spike_hold_off)))
                                            end
                                                
                                                
                                            
                                        elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                                            if contains('Stim-spike hold-off', curr_value)
                                                set(exp_children(ec), 'Value', strcat('Stim-spike hold-off = ', num2str(electrode_data(electrode_count).stim_spike_hold_off)))
                                            end
                                            
                                        end
                                        
                                        
                                        if contains('Post-spike', curr_value)
                                            set(exp_children(ec), 'Value', strcat('Post-spike = ', num2str(electrode_data(electrode_count).post_spike_hold_off)))
                                        elseif contains('T-wave offset', curr_value)
                                            set(exp_children(ec), 'Value', strcat('T-wave offset = ', num2str(electrode_data(electrode_count).t_wave_offset)))
                                        elseif contains('T-wave duration', curr_value)
                                            set(exp_children(ec), 'Value', strcat('T-wave duration = ', num2str(electrode_data(electrode_count).t_wave_duration)))
                                        elseif contains('T-wave shape', curr_value)
                                            set(exp_children(ec), 'Value', strcat('T-wave shape = ', electrode_data(electrode_count).t_wave_shape))
                                        end
                                        
                                    end
                                    
                                end
                                
                                t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                                t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                                t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                                t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                                
                                cla(exp_ax);
                                hold(exp_ax,'on')
                                plot(exp_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);
                                plot(exp_ax, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data);
                                plot(exp_ax, t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
                                plot(exp_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
                                plot(exp_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

                                %[~, beat_start_volts, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
                                %beat_start_volts =  electrode_data(electrode_count).data(beat_start_volts);

                                %plot(exp_ax, electrode_data(electrode_count).beat_start_times, beat_start_volts, 'go');

                                if strcmp(electrode_data(electrode_count).spon_paced, 'paced') 


                                    plot(exp_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'm.', 'MarkerSize', 20);
                                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')

                                    plot(exp_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
                                    plot(exp_ax, electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);

                                else

                                    plot(exp_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);

                                end
                                % Need slope value

                                %disp(electrode_data(electrode_count).beat_start_volts)
                                %disp(electrode_data(electrode_count).activation_point_array);
                                %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                                plot(exp_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'k.', 'MarkerSize', 20);

                                if strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                                    legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'ectopic beat start', 'paced beat start', 'activation point')
                                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced') 
                                    legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'paced beat start', 'activation point')

                                else
                                    legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point')

                                end
                                hold(exp_ax,'off')
                            elseif strcmp(stable_ave_analysis, 'stable')
                                window = electrode_data(electrode_count).window;
                                
                                if change_GE == 1
                                    cla(GE_ax)
                                    hold(GE_ax, 'on');
                                end
                                for k = 1:window
                                   plot(elec_ax, electrode_data(electrode_count).stable_times{k, 1}, electrode_data(electrode_count).stable_waveforms{k, 1});
                                   stable_time = electrode_data(electrode_count).stable_times{k, 1};
                                   stable_act_time_indx = find(electrode_data(electrode_count).activation_times >= stable_time(1));
                                   stable_act_time_indx = stable_act_time_indx(1);

                                   plot(elec_ax, electrode_data(electrode_count).activation_times(stable_act_time_indx), electrode_data(electrode_count).activation_point_array(stable_act_time_indx), 'k.', 'MarkerSize', 20)
                                   
                                   if change_GE == 1
                                       
                                       plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).stable_times{k, 1}, electrode_data(min_electrode_beat_stdev_indx).stable_waveforms{k, 1});
                                       
                                       stable_time = electrode_data(min_electrode_beat_stdev_indx).stable_times{k, 1};
                                       stable_act_time_indx = find(electrode_data(min_electrode_beat_stdev_indx).activation_times >= stable_time(1));
                                       stable_act_time_indx = stable_act_time_indx(1);


                                       plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).activation_times(stable_act_time_indx), electrode_data(min_electrode_beat_stdev_indx).activation_point_array(stable_act_time_indx), 'k.', 'MarkerSize', 20)

                                       set(GE_pan, 'Title', "Golden Electrode" + " " +electrode_data(min_electrode_beat_stdev_indx).electrode_id);
                                       
                                   end
                                   
                                end
                                if change_GE == 1
                                    hold(GE_ax, 'off');
                                end
                                
                                
                                exp_children = get(expand_elec_panel, 'children');
                                for ec = 1:length(exp_children)
                                    if strcmp(get(exp_children(ec), 'type'), 'uieditfield')
                                        %disp(get(exp_children(ec), 'value'))
                                        curr_value = get(exp_children(ec), 'value');
                                        if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                                        
                                            if contains('BDT', curr_value)
                                                set(exp_children(ec), 'Value', strcat('BDT = ', num2str(electrode_data(electrode_count).bdt)))
                                            elseif contains('min BP', curr_value)
                                                set(exp_children(ec), 'Value', strcat('min BP = ', num2str(electrode_data(electrode_count).min_bp)))
                                            elseif contains('max BP', curr_value)
                                                set(exp_children(ec), 'Value', strcat('max BP = ', num2str(electrode_data(electrode_count).max_bp)))
                                            end
                                            
                                           
                                        elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                                            if contains('BDT', curr_value)
                                                set(exp_children(ec), 'Value', strcat('BDT = ', num2str(electrode_data(electrode_count).bdt)))
                                            elseif contains('min BP', curr_value)
                                                set(exp_children(ec), 'Value', strcat('min BP = ', num2str(electrode_data(electrode_count).min_bp)))
                                            elseif contains('max BP', curr_value)
                                                set(exp_children(ec), 'Value', strcat('max BP = ', num2str(electrode_data(electrode_count).max_bp)))
                                            elseif contains('Stim-spike hold-off', curr_value)
                                                set(exp_children(ec), 'Value', strcat('Stim-spike hold-off = ', num2str(electrode_data(electrode_count).stim_spike_hold_off)))
                                            end
                                                
                                                
                                            
                                        elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                                            if contains('Stim-spike hold-off', curr_value)
                                                set(exp_children(ec), 'Value', strcat('Stim-spike hold-off = ', num2str(electrode_data(electrode_count).stim_spike_hold_off)))
                                            end
                                            
                                        end
                                        
                                        
                                        if contains('Post-spike', curr_value)
                                            set(exp_children(ec), 'Value', strcat('Post-spike = ', num2str(electrode_data(electrode_count).post_spike_hold_off)))
                                        elseif contains('T-wave offset', curr_value)
                                            set(exp_children(ec), 'Value', strcat('T-wave offset = ', num2str(electrode_data(electrode_count).t_wave_offset)))
                                        elseif contains('T-wave duration', curr_value)
                                            set(exp_children(ec), 'Value', strcat('T-wave duration = ', num2str(electrode_data(electrode_count).t_wave_duration)))
                                        elseif contains('T-wave shape', curr_value)
                                            set(exp_children(ec), 'Value', strcat('T-wave shape = ', electrode_data(electrode_count).t_wave_shape))
                                        end
                                        
                                    end
                                   
                                    
                                end
                                
                                t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                                t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                                t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                                t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                                
                                cla(exp_ax);
                                hold(exp_ax,'on')
                                plot(exp_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);
                                plot(exp_ax, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data);
                                plot(exp_ax, t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
                                plot(exp_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
                                plot(exp_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

                                %[~, beat_start_volts, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
                                %beat_start_volts =  electrode_data(electrode_count).data(beat_start_volts);

                                %plot(exp_ax, electrode_data(electrode_count).beat_start_times, beat_start_volts, 'go');

                                if strcmp(electrode_data(electrode_count).spon_paced, 'paced') 


                                    plot(exp_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'm.', 'MarkerSize', 20);
                                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')

                                    plot(exp_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
                                    plot(exp_ax, electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);

                                else

                                    plot(exp_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);

                                end
                                % Need slope value

                                %disp(electrode_data(electrode_count).beat_start_volts)
                                %disp(electrode_data(electrode_count).activation_point_array);
                                %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                                plot(exp_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'k.', 'MarkerSize', 20);

                                if strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                                    legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'ectopic beat start', 'paced beat start', 'activation point')
                                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced') 
                                    legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'paced beat start', 'activation point')

                                else
                                    legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point')

                                end
                                hold(exp_ax,'off')
                                

                            end
                            
                            
                        end
                        hold(elec_ax,'off')
                        %}
                    end
                end
                close(well_fig);
            end
            
        end
    end
    
    
    if strcmp(spon_paced, 'spon')
        [well_electrode_data.conduction_velocity, well_electrode_data.conduction_velocity_model] = calculateSpontaneousConductionVelocity(well_electrode_data.wellID, electrode_data,  num_electrode_rows, num_electrode_cols, nan);
    
    else
        [well_electrode_data.conduction_velocity, well_electrode_data.conduction_velocity_model] = calculatePacedConductionVelocity(well_electrode_data.wellID, electrode_data,  num_electrode_rows, num_electrode_cols, nan);
    
    end
    well_electrode_data.electrode_data = electrode_data;
    
    set(well_elec_fig, 'Visible', 'on');
    
    function changedPacedBDT(paced_ectopic_dropdown, well_ax, num_time_points)
        if get(paced_ectopic_dropdown, 'Value') == 2
            set(well_bdt_ui,'value', 0)
            set(well_bdt_text,'visible', 'on')
            set(well_bdt_ui,'visible', 'on')

            set(min_bp_ui,'value', 0)
            set(min_bp_text,'visible', 'on')
            set(min_bp_ui,'visible', 'on')

            set(max_bp_ui,'value', 0)
            set(max_bp_text,'visible', 'on')
            set(max_bp_ui,'visible', 'on')
            
            electrode_data(electrode_count).spon_paced = 'paced bdt';
            
            init_bdt_data = ones(num_time_points, 1);
            init_bdt_data(:,1) = 0;
            hold(well_ax, 'on')
            
            plot(well_ax, electrode_data(electrode_count).time, init_bdt_data);
            hold(well_ax,'off')
            
            if strcmp(get(submit_in_well_button, 'visible'), 'on')
                set(submit_in_well_button, 'visible', 'off');
            end
            
        else
            
            set(well_bdt_text,'visible', 'off')
            set(well_bdt_ui,'visible', 'off')
            set(well_bdt_ui,'value', -1)

            set(min_bp_text,'visible', 'off')
            set(min_bp_ui,'visible', 'off')
            set(min_bp_ui,'value', -1)

            set(max_bp_text,'visible', 'off')
            set(max_bp_ui,'visible', 'off')
            set(max_bp_ui,'value', -1)
            
            electrode_data(electrode_count).spon_paced = 'paced';
            
            if get(stim_spike_ui, 'value') ~= 0
                if get(post_spike_ui, 'value') ~= 0
                   if get(t_wave_duration_ui, 'value') ~= 0
                      if get(t_wave_peak_offset_ui, 'value') ~= 0
                          
                          set(submit_in_well_button, 'visible', 'on')
                      end
                   end
                end
            end
            
            
            
            axes_children = get(well_ax, 'Children');
           
            for c = 1:length(axes_children)
               child_y_data = axes_children(c).YData;
               if length(child_y_data) ~= 1
                   if child_y_data(1) == child_y_data(:)
                       delete(axes_children(c))
                       break;
                   end
               end


           end
        end
    end

    function HelpButtonPushed(t_wave_up_down_dropdown)
        help_fig = uifigure;
        movegui(help_fig,'center');
        help_fig.WindowState = 'maximized';
        
        help_p = uipanel(help_fig, 'BackgroundColor','#f2c2c2', 'Position', [0 0 screen_width screen_height]);
        
        close_help_button = uibutton(help_p, 'push', 'Text', 'close', 'Position',[screen_width-250 50 60 60], 'ButtonPushedFcn', @(close_help_button,event) closeHelpButtonPushed());
     
        if screen_height <= 1200
            im_height = screen_height-80;
            
        else
            
            im_height = 1200;
            
        end
        
        if screen_width <= 800
            im_width = screen_width -300;
            
        else
            
            im_width = 800;
        end
        im_horz_offset = (screen_width/2)-(im_width/2);
        
        
        if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
            if get(t_wave_up_down_dropdown, 'Value') == 1
                im = uiimage(help_p, 'ImageSource', 'spontaneous downwards t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 2
                im = uiimage(help_p, 'ImageSource', 'spontaneous upwards t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 3
                im = uiimage(help_p, 'ImageSource', 'spontaneous polynomial t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            end
        elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
            if get(t_wave_up_down_dropdown, 'Value') == 1
                im = uiimage(help_p, 'ImageSource', 'paced data downwards t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 2
                im = uiimage(help_p, 'ImageSource', 'paced data upwards t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 3
                im = uiimage(help_p, 'ImageSource', 'paced data polynomial t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            end
            
        elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
            if get(t_wave_up_down_dropdown, 'Value') == 1
                im = uiimage(help_p, 'ImageSource', 'paced ectopic downwards png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 2
                im = uiimage(help_p, 'ImageSource', 'paced ectopic upwards png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 3
                im = uiimage(help_p, 'ImageSource', 'paced ectopic polynomial.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            end
            
        end
        
       function closeHelpButtonPushed()
          close(help_fig); 
       end
       
        
    end
  
    
    function changeBDT(well_bdt_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time)

       % BDT CANNOT be equal to 0. 
       if get(well_bdt_ui, 'Value') == 0
           msgbox('BDT cannot be equal to 0','Oops!');
           set(well_bdt_ui, 'BackgroundColor','#e68e8e')
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           
           well_pan_components = get(well_p, 'Children');
           for i = 1:length(well_pan_components)
           
              well_ui_con = well_pan_components(i);
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
               
                 bdt_data = ones(length(prev_bdt_plot.XData), 1);
                 bdt_data(:,1) = get(well_bdt_ui, 'Value');
                 prev_bdt_plot.YData = bdt_data;
              end
           end
           return;
       end
       
       set(well_bdt_ui, 'BackgroundColor','white')
       
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
       %disp('change T-wave time')
       %%disp('function entered')
       %%disp(length(well_bdt_ui_array))
       %%disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(t_wave_time_offset_ui, 'Value') == 0
           set(t_wave_time_offset_ui, 'BackgroundColor','#e68e8e')
           msgbox('T-Wave peak time cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           axes_children = get(well_ax, 'Children');
           
           t_wave_y_data = linspace(min_voltage*0.25, max_voltage*0.25);
           for ch = 1:length(axes_children)
              ch_y_data = axes_children(ch).YData;
              ch_x_data = axes_children(ch).XData;
              if size(ch_y_data) == size(t_wave_y_data)
                  delete(axes_children(ch))
              end
           end
           return;
       end
       
       set(t_wave_time_offset_ui, 'BackgroundColor','white')
       
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
           %disp('set vis')
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       %disp(post_spike_ok)
       if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
       % Pace analysis uses stim spike holdoff too
           if t_wave_dur_ok == 1
               
               t_wave_start_window = Stims - (t_wave_dur/2) + get(t_wave_time_offset_ui, 'Value');
               t_wave_end_window = Stims + (t_wave_dur/2) + get(t_wave_time_offset_ui, 'Value');
               if t_wave_start_window < Stims + post_spike_hold_off
                   t_wave_start_window = Stims + post_spike_hold_off;
               end
               
               axes_children = get(well_ax, 'Children');
       
               % boxes are smaller magnitudes than max_voltage-min_voltage
               
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
       %disp('change T-wave duration')
       %%disp('function entered')
       %%disp(length(well_bdt_ui_array))
       %%disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(t_wave_duration_ui, 'Value') == 0
           set(t_wave_duration_ui, 'BackgroundColor','#e68e8e')
           msgbox('T-Wave duration cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           
           axes_children = get(well_ax, 'Children');
           
           t_wave_y_data = linspace(min_voltage*0.25, max_voltage*0.25);
           for ch = 1:length(axes_children)
              ch_y_data = axes_children(ch).YData;
              ch_x_data = axes_children(ch).XData;
              if size(ch_y_data) == size(t_wave_y_data)
                  delete(axes_children(ch))
              end
           end
           return;
       end
       
       set(t_wave_duration_ui, 'BackgroundColor', 'white')
       
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
           %disp('set vis')
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       %disp(post_spike_ok)
       if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
       % Pace analysis uses stim spike holdoff too
           if t_wave_time_ok == 1 
               
               t_wave_start_window = Stims+ t_wave_offset - (get(t_wave_duration_ui, 'Value')/2);
               t_wave_end_window = Stims+ t_wave_offset + (get(t_wave_duration_ui, 'Value')/2);
               if t_wave_start_window < Stims + post_spike_hold_off
                   t_wave_start_window = Stims + post_spike_hold_off;
               end
               
               axes_children = get(well_ax, 'Children');
       
               % boxes are smaller magnitudes than max_voltage-min_voltage
               
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
           
           set(post_spike_ui, 'BackgroundColor','#e68e8e')
           msgbox('Post spike hold-off cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           return;
       end
       
       set(post_spike_ui, 'BackgroundColor', 'white')
       
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
       
               % boxes are smaller magnitudes than max_voltage-min_voltage
               
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
           set(stim_spike_ui, 'BackgroundColor','#e68e8e')
           msgbox('Stim spike hold-off cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
              
          axes_children = get(well_ax, 'Children');
           
          t_wave_y_data = linspace(min_voltage*0.25, max_voltage*0.25);
          for ch = 1:length(axes_children)
              ch_y_data = axes_children(ch).YData;
              ch_x_data = axes_children(ch).XData;
              if size(ch_y_data) == size(t_wave_y_data)
                  continue
              end
              if size(ch_y_data) == 1
                  delete(axes_children(ch))
              end
          end

          return;
       end
       
       set(stim_spike_ui, 'BackgroundColor', 'white')
       
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
       %%disp(spon_paced)
       if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
           % replot
           stim_hold_offs = Stims + get(stim_spike_ui, 'Value');
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
                   else
                       if ch_y_data(1) == ch_y_data(:)    
                          continue 
                       end
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
           
           %%disp(stim_hold_off_points)

           % boxes are smaller magnitudes than max_voltage-min_voltage

           % Find all x values equal to t-wave start windows
           found_stim_point = 0;
           
           for c = 1:length(axes_children)
               child_y_data = axes_children(c).YData;

               if size(child_y_data) == 1
               %if ismember(t_wave_start_window, child_x_data(1, 1))
                   
                   if ch_y_data(1) == ch_y_data(:)    
                      continue 
                   end

                   found_stim_point = 1;
                   break;
               end
           end

           if found_stim_point == 1
               for i = 1:length(stim_hold_off_points)
                   for c = 1:length(axes_children)
                       child_y_data = axes_children(c).YData;
                       child_x_data = axes_children(c).XData;

                       %%disp(child_x_data)
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
 
                  plot(well_ax, stim_hold_off_points(i), stim_y_points(i), 'r.', 'MarkerSize', 20)                  
                   

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
       
               % boxes are smaller magnitudes than max_voltage-min_voltage
               
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
       %%disp('change T-wave duration')
       %%disp('function entered')
       %%disp(length(well_bdt_ui_array))
       %%disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(min_bp_ui, 'Value') == 0
           set(min_bp_ui, 'BackgroundColor','#e68e8e')
           msgbox('Min BP cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           return;
       end
       
       set(min_bp_ui, 'BackgroundColor', 'white')
       
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
       %%disp('change T-wave duration')
       %%disp('function entered')
       %%disp(length(well_bdt_ui_array))
       %%disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(max_bp_ui, 'Value') == 0
           set(max_bp_ui, 'BackgroundColor','#e68e8e')
           msgbox('Max BP cannot be equal to 0','Oops!');
           
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           return;
       end
       
       set(max_bp_ui, 'BackgroundColor', 'white')
       
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
       %%disp('change T-wave duration')
       %%disp('function entered')
       %%disp(length(well_bdt_ui_array))
       %%disp(get(p, 'Children'))
       
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
           set(time_start_ui, 'BackgroundColor','#e68e8e')
           msgbox('Time region start time must be less than the end time.','Oops!');
           set(time_start_ui, 'Value', 0);
           
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           
       else
           set(time_start_ui, 'BackgroundColor', 'white')
       end
       
       
       
       axes_children = get(well_ax, 'Children');
       
       time_region_plots = [];
       ydata = linspace(min_voltage, max_voltage);
       for c = 1:length(axes_children)
           child_x_data = axes_children(c).XData;
           child_y_data = axes_children(c).YData;
           %%disp(child_x_data(1))
           %%disp(floor(child_x_data(1)))
           if size(child_y_data) == size(ydata)
               if child_y_data(1) == ydata(1)
                  time_region_plots = [time_region_plots; axes_children(c)];
               end
               %break;
           end
       end
       
       plot1 = time_region_plots(1);
       plot2 = time_region_plots(2);
       %disp(plot1.XData(1));
       %disp(plot2.XData(1));
       if plot1.XData(1) < plot2.XData(1)
           prev_start_plot = plot1;
       else
           prev_start_plot = plot2;
       end
       %disp(prev_start_plot.XData(1));
       
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
           set(time_end_ui, 'BackgroundColor','#e68e8e')
           set(time_end_ui, 'Value', orig_end_time);
           
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           
           
           
           return;
       else
           set(time_end_ui, 'BackgroundColor','white')
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
           set(stable_duration_ui, 'BackgroundColor','#e68e8e')
           msgbox('Stable duration cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
       end
       
       set(stable_duration_ui, 'BackgroundColor','white')
       
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
       %%disp('clear BDT');
       % Must remove all BDT plots 
       % Set all BDTs to be zero again
       panel_sub_panels = get(p, 'Children');
      
       for i = 1:length(panel_sub_panels)

           sub_pan = panel_sub_panels(i);
           sub_p_ui_controls = get(sub_pan, 'Children');
           
           for j = 1:length(sub_p_ui_controls)

               if strcmp(string(get(sub_p_ui_controls(j), 'Tag')), 'BDT')    
                   %%disp('BDT');
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