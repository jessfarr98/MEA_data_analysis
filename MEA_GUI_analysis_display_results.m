function MEA_GUI_analysis_display_results(AllDataRaw, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar, save_dir)
    %% GENERAL DESIGN
    %% Save button in each plot to allow users to save plots to directory of choice (start directory)
    %% Close buttons for each pop-up window that doesn't require user interaction
    
    %% b2b = 'on'
    
    %% display GUI with button for each well and when pressed displays plots for each electrode /
    %% heat map button - shows heatmap in new window that can be closed /
    %% display well and electrode statistics like mean FPD etc. /
    %% if bipolar on = bipolar button to show plots and results /
    
    %% b2b = 'off'
    
    %% Golden electrode
    %% 3 uis for each well - show electrode stable waveforms button, show ave waveforms for each elec button, change GE dropdown /
    %% no dropdown nominated = dropdown menu for electrode options for new GE /
    %% Accept GE's button /
    %% Enter T-wave peak times for all wells and continue button appears along with statistics /
    %% Display statistics and GE for each well /
    %% heatmap buttons and bipolar buttons on the well panels in this GUI /
    
    %% Electrode time region ave waveforms 
    %% buttons for each well /
    %% well button pressed display all electrodes and t-wave peak time uitexts/
    %% Continue button and statistics appear when all entered. /
    %% heatmap and bipolar buttons available when each well clicked and shows electrodes ave waveforms /
    
    %% TO DO
    % reformat b2b electrodes so correct
    % have focus based plots for each complex for just one beat and another plot that you're able to zoom out on and analyse all beats.
    % Save data buttons
    % activation time offset?
    % t-wave time offset?
    % Nice formatting
    % reject electrode button - paced dataset don't analyse 4_1. 
    % cycle length plot ignore the first beat. 
    % GE buttons a bit ugly
    % bipolar plots in results output gui
    % better plot colours
    % plots beat start times
    
    
    %% KEY TASKS    
    
    %% TEST

    %% T-wave inflection point, max, min stored in results. User inputs displayed in file. Heatmap results. Ave electrode results.
    %% Summarise maximum actival time. Diff between earliest electrode and latest electrode activation time for each beat. What were the electrodes?
    %% Multiple time-regions
    
    
       
    shape_data = size(AllDataRaw);
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);

    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    
    num_wells = length(added_wells);
    num_button_rows = 1;
    num_button_cols = num_wells;
    
    % 1  2  3  4
    % 5  6  7  8
    % 9 10 11 12
    %13 14 15 16
    
    if num_wells/num_well_rows > 1
        % need button rows
        num_button_rows = ceil(num_wells/num_well_rows);
        num_button_cols = num_well_cols;
        
    end   
    
    
    button_panel_width = screen_width-200;
    
    button_width = button_panel_width/num_button_cols;
    button_height = (screen_height-40)/num_button_rows;
    
    out_fig = uifigure;
    out_fig.Name = 'MEA Results';
    % left bottom width height
    main_p = uipanel(out_fig, 'Position', [0 0 screen_width screen_height]);
    
    if strcmp(beat_to_beat, 'on')

        close_all_button = uibutton(main_p,'push','Text', 'Close', 'Position', [screen_width-180 100 150 50], 'ButtonPushedFcn', @(close_all_button,event) closeAllButtonPushed(close_all_button, out_fig));
        
        save_all_button =  uibutton(main_p,'push','Text', "Save All To"+ " " + save_dir, 'FontSize', 8, 'Position', [screen_width-180 200 150 50], 'ButtonPushedFcn', @(save_all_button,event) saveAllB2BButtonPushed(save_all_button, save_dir, num_electrode_rows, num_electrode_cols));
        
        %display_final_button = uibutton(main_p,'push','Text', 'Close', 'Position', [screen_width-180 200 120 50], 'ButtonPushedFcn', @(display_final_button,event) displayFinalB2BButtonPushed(display_final_button, out_fig));
        
        % Display Finalised results
        % Shows all analysed electrodes plus statistics and buttons for view plots of b2b statistics and heatmaps etc.
        
    else
        if strcmp(stable_ave_analysis, 'time_region')
            close_all_button = uibutton(main_p,'push','Text', 'Close', 'Position', [screen_width-180 100 150 50], 'ButtonPushedFcn', @(close_all_button,event) closeAllButtonPushed(close_all_button, out_fig));
            save_all_button = uibutton(main_p,'push','Text', "Save All To"+ " " + save_dir, 'FontSize', 8, 'Position', [screen_width-180 200 150 50], 'ButtonPushedFcn', @(save_all_button,event) saveAllTimeRegionButtonPushed(save_all_button, save_dir, num_electrode_rows, num_electrode_cols));
        
            % Display Finalised Results
            % Shows all ave electrodes analysed and also statistics 
            
        elseif strcmp(stable_ave_analysis, 'stable')
            close_all_button = uibutton(main_p,'push','Text', 'Close', 'Position', [screen_width-180 100 120 50], 'ButtonPushedFcn', @(close_all_button,event) closeAllButtonPushed(close_all_button, out_fig));
            accept_GE_button = uibutton(main_p,'push','Text', 'Accept Golden Electrodes', 'Position', [screen_width-180 200 120 50], 'ButtonPushedFcn', @(accept_GE_button,event) acceptGEButtonPushed(accept_GE_button, out_fig, well_electrode_data));
            
            % Accept Golden Electrodes
            % Displays all wells with GE's and T-wave input bars
            % Once all GE's have had their T-wave peaks entered then allowed to continue to stats results dispaly
            
        end
    
    end    
    
    main_pan = uipanel(main_p, 'Title', 'Review Well Results', 'Position', [0 0 button_panel_width screen_height-40]);
    
    %global electrode_data;
    dropdown_array = [];
    if num_button_rows > 1
        button_count = 1;
        stop_add = 0;
        for r = 1:num_button_rows
           for c = 1: num_button_cols
               if button_count > num_wells
                   stop_add = 1;
                   break;
               end
               wellID = added_wells(button_count);
               button_panel = uipanel(main_pan, 'Position', [((c-1)*button_width) ((r-1)*button_height) button_width button_height]);
               
               
               if strcmp(beat_to_beat, 'off')
                   if strcmp(stable_ave_analysis, 'stable')
                        electrode_options = [];
                        for e_r = 1:num_electrode_rows
                           for e_c = 1:num_electrode_cols
                               electrode_id = strcat(wellID, '_', num2str(e_r),'_',num2str(e_c));
                               electrode_options = [electrode_options; electrode_id];
                           end
                        end
                        %celldisp(electrode_options)
                        
                        
                        change_GE_text = uieditfield(button_panel,'Text','Position',[2*(button_width/3) (button_height)/2 button_width/6 (button_height)/2], 'Value',"Change" + " " + wellID + " " + "Golden Electrode", 'Editable','off');
                    
                        change_GE_dropdown = uidropdown(button_panel, 'Items', electrode_options,'Position',[2*(button_width/3) 0 button_width/6 (button_height)/2]);
                        set(change_GE_text, 'Visible', 'off');
                        set(change_GE_dropdown, 'Visible', 'off');
                        
                        dropdown_array = [dropdown_array; change_GE_dropdown];

                        change_GE_button = uibutton(button_panel,'push','Text', "Change" + " " + wellID + " " + "Golden Electrode", 'Position', [2*(button_width/3) 0 button_width/3 button_height], 'ButtonPushedFcn', @(change_GE_button,event) changeGEButtonPushed(change_GE_button, added_wells, change_GE_text, change_GE_dropdown, button_panel));

                        stable_button = uibutton(button_panel,'push','Text', strcat(wellID, {' '}, 'Show Electrode Stable Waveforms'), 'Position', [0 0 button_width/3 button_height], 'ButtonPushedFcn', @(stable_button,event) stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(button_count, :), change_GE_dropdown));
                        average_button = uibutton(button_panel,'push','Text', strcat(wellID, {' '}, 'Show Electrode Average Waveforms'), 'Position', [button_width/3 0 button_width/3 button_height], 'ButtonPushedFcn', @(average_button,event) averageElectrodesButtonPushed(average_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(button_count, :), change_GE_dropdown));
                        
                        
                        %set(change_GE_dropdown, 'Visible', 'off');
                        
                   else
                        
                        well_button = uibutton(button_panel,'push','Text', wellID, 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, button_count, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));
                   
                   end
               else
                   
                   well_button = uibutton(button_panel,'push','Text', wellID, 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, button_count, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));
               
               end
               button_count = button_count + 1;
           end
           if stop_add == 1
               break;
           end
        end
    else
        for b = 1:num_wells
            wellID = added_wells(b);
            button_panel = uipanel(main_pan, 'Position', [((b-1)*button_width) 0 button_width button_height]);
                
            if strcmp(beat_to_beat, 'off')
               if strcmp(stable_ave_analysis, 'stable')
                    electrode_options = [];
                    for e_r = 1:num_electrode_rows
                       for e_c = 1:num_electrode_cols
                           disp('elec')
                           disp(e_r)
                           disp(e_c)
                           electrode_id = strcat(wellID, '_', num2str(e_r),'_',num2str(e_c));
                           electrode_options = [electrode_options; electrode_id];
                       end
                    end
                    disp(electrode_options)
                    
                    
                    change_GE_text = uieditfield(button_panel,'Text','Position',[2*(button_width/3) (button_height)/2 button_width/6 (button_height)/2], 'Value',strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Editable','off');
                    
                    change_GE_dropdown = uidropdown(button_panel, 'Items', electrode_options,'Position',[2*(button_width/3) 0 button_width/6 (button_height)/2]);
                    
                    
                    set(change_GE_text, 'Visible', 'off');
                    set(change_GE_dropdown, 'Visible', 'off');
                    
                    dropdown_array = [dropdown_array; change_GE_dropdown];
                    
                    change_GE_button = uibutton(button_panel,'push','Text', strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Position', [2*(button_width/3) 0 button_width/3 button_height], 'ButtonPushedFcn', @(change_GE_button,event) changeGEButtonPushed(change_GE_button, added_wells, change_GE_text, change_GE_dropdown, button_panel));
                    
                    stable_button = uibutton(button_panel,'push','Text', strcat(wellID, {' '}, 'Show Electrode Stable Waveforms'), 'Position', [0 0 button_width/3 button_height], 'ButtonPushedFcn', @(stable_button,event) stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(b, :), change_GE_dropdown));
                    average_button = uibutton(button_panel,'push','Text', strcat(wellID, {' '}, 'Show Electrode Average Waveforms'), 'Position', [button_width/3 0 button_width/3 button_height], 'ButtonPushedFcn', @(average_button,event) averageElectrodesButtonPushed(average_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(b, :), change_GE_dropdown));
                    
                    
                    %{
                    change_GE_text = uieditfield(button_panel,'Text','Position',[2*(button_width/3) (button_height/3)/2 button_width/3 (button_height/3)/2], 'Value',strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Editable','off');
                    
                    change_GE_dropdown = uidropdown(button_panel, 'Items', electrode_options,'Position',[2*(button_width/3) 0 button_width/3 (button_height/3)/2]);
                    
                    %change_GE_dropdown.ItemsData = [1 2];
                    %}
               else
                    well_button = uibutton(button_panel,'push','Text', wellID, 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, b, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));

               end
            else

                well_button = uibutton(button_panel,'push','Text', wellID, 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, b, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));
            end
        end
    end
    
    function wellButtonPushed(well_button, added_wells, well_count, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig)
        set(out_fig, 'Visible', 'off')
        well_ID = get(well_button, 'Text');
        disp(well_ID)
        disp(contains(added_wells, well_ID))
        
        electrode_data = well_electrode_data(well_count, :);
        %electrode_data = electrod_e_data;
        disp(size(electrode_data))
        
        well_elec_fig = uifigure;
        well_elec_fig.Name = strcat(well_ID, '_', 'Electrode Results');
        % left bottom width height
        main_well_pan = uipanel(well_elec_fig, 'Position', [0 0 screen_width screen_height]);
        
        well_p_width = screen_width-300;
        well_p_height = screen_height -100;
        well_pan = uipanel(main_well_pan, 'Position', [0 0 well_p_width well_p_height]);
        
        close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed(close_button, well_elec_fig, out_fig));
        
        rejec_well_button = uibutton(main_well_pan,'push','Text', 'Reject Well', 'Position', [screen_width-220 600 120 50], 'ButtonPushedFcn', @(rejec_well_button,event) rejectWellButtonPushed(rejec_well_button, well_elec_fig, out_fig, well_button, well_count));

        
        if strcmp(beat_to_beat, 'on')
            if strcmp(bipolar, 'on')
                bipolar_button = uibutton(main_well_pan,'push','Text', well_ID + " " + "Show Bipolar Electrogam Results", 'Position', [screen_width-220 400 180 50], 'ButtonPushedFcn', @(bipolar_button,event) bipolarButtonPushed(bipolar_button, well_ID, num_electrode_rows, num_electrode_cols));
                adjacent_bipolar_button = uibutton(main_well_pan,'push','Text', well_ID+ " " + "Show Adjacent Bipolar Electrogam Results", 'Position', [screen_width-220 300 180 50], 'ButtonPushedFcn', @(adjacent_bipolar_button,event) adjacentBipolarButtonPushed(adjacent_bipolar_button, well_ID, num_electrode_rows, num_electrode_cols));
                
            end

            display_final_button = uibutton(main_well_pan,'push','Text', 'Accept Analysis', 'Position', [screen_width-220 500 120 50], 'ButtonPushedFcn', @(display_final_button,event) displayFinalB2BButtonPushed(display_final_button, out_fig, well_elec_fig, well_button, bipolar));
        
            heat_map_button = uibutton(main_well_pan,'push','Text', well_ID+ " " + "Show Heat Map", 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(heat_map_button,event) heatMapButtonPushed(heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced));

            reanalyse_button = uibutton(main_well_pan,'push','Text', 'Re-analyse Electrodes', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
            reanalyse_well_button = uibutton(main_well_pan,'push','Text', 'Re-analyse Well', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(reanalyse_well_button,event) reanalyseWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
        else
            if strcmp(stable_ave_analysis, 'time_region')
                disp('reanalyse ave time region waveform function?')
                %reanalyse_button = uibutton(main_well_pan,'push','Text', 'Re-analyse well', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, 'ave'));
                display_final_button = uibutton(main_well_pan,'push','Text', 'Accept Analysis', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(display_final_button,event) displayFinalTimeRegionButtonPushed(display_final_button, out_fig, well_elec_fig, well_button));
                
                
                %set(display_final_button, 'Visible', 'off')
                
                
                %auto_t_wave_button = uibutton(main_well_pan,'push','Text', 'Auto T-Wave Peak Search', 'Position', [screen_width-220 400 120 50], 'ButtonPushedFcn', @(auto_t_wave_button,event) autoTwavePeakButtonPushed(auto_t_wave_button, out_fig, well_elec_fig, well_button));
                
                
            end
        end
        
        electrode_count = 0;
        all_t_waves = 1;
        elec_ids = [electrode_data(:).electrode_id]
        for elec_r = num_electrode_rows:-1:1
            for elec_c = 1:num_electrode_cols
                elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                electrode_count = elec_indx;
                %electrode_count = electrode_count+1;
                if strcmp(beat_to_beat, 'on')
                    %plot all the electrodes analysed data and 
                    % left bottom width height
                    disp(electrode_data(electrode_count).electrode_id)
                    elec_pan = uipanel(well_pan, 'Title', electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);
                    
                    elec_ax = uiaxes(elec_pan, 'Position', [0 20 (well_p_width/num_electrode_cols)-25 (well_p_height/num_electrode_rows)-50]);
                    
                    reject_electrode_button = uibutton(elec_pan,'push','Text', 'Reject Electrode', 'Position', [0 0 100 20], 'ButtonPushedFcn', @(reject_electrode_button,event) rejectElectrodeButtonPushed(reject_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count));
        
                    hold(elec_ax,'on')
                    plot(elec_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);
                    
                    t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                    t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                    t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                    t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                    plot(elec_ax, t_wave_peak_times, t_wave_peak_array, 'co');
                    plot(elec_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'ro');
                    plot(elec_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'bo');
                    
                    [~, beat_start_volts, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
                    beat_start_volts = electrode_data(electrode_count).data(beat_start_volts);
                    plot(elec_ax, electrode_data(electrode_count).beat_start_times, beat_start_volts, 'go');
                    
                    if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
                        %stim_indx = find(electrode_data(electrode_count).time == electrode_data(electrode_count).Stims)
                        [in, stim_indx, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).Stims);
                        %disp(in)
                        %disp(electrode_data(electrode_count).Stims)
                        Stim_points = electrode_data(electrode_count).data(stim_indx);
                        Stim_times = electrode_data(electrode_count).time(stim_indx);
                        %disp(length(Stim_points))
                        %disp(length(electrode_data(electrode_count).Stims))
                        %Stim_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).time == electrode_data(electrode_count).Stims));

                        plot(elec_ax, Stim_times, Stim_points, 'mo');
                    end
                    %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                    plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                    hold(elec_ax,'off')
                else
                    if strcmp(stable_ave_analysis, 'time_region') 
                        
                        %% Need T-wave input panels
                        elec_pan = uipanel(well_pan, 'Title', electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);
                    
                        reject_electrode_button = uibutton(elec_pan,'push','Text', 'Reject Electrode', 'Position', [0 20 100 20], 'ButtonPushedFcn', @(reject_electrode_button,event) rejectElectrodeButtonPushed(reject_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count));
        
                        elec_ax = uiaxes(elec_pan, 'Position', [0 40 (well_p_width/num_electrode_cols)-25 (well_p_height/num_electrode_rows)-60]);
                        
                        
                        hold(elec_ax,'on')
                        plot(elec_ax, electrode_data(electrode_count).ave_wave_time, electrode_data(electrode_count).average_waveform);
                        %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
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
                        
                        
                        t_wave_time_text = uieditfield(elec_pan,'Text', 'Value', 'T-wave Peak Time', 'FontSize', 8, 'Position', [0 0 ((well_p_width/num_electrode_cols)-25)/2 20], 'Editable','off');
                        t_wave_time_ui = uieditfield(elec_pan, 'numeric', 'Tag', 'T-Wave', 'Position', [((well_p_width/num_electrode_cols)-25)/2 0 ((well_p_width/num_electrode_cols)-25)/2 20], 'FontSize', 8, 'ValueChangedFcn',@(t_wave_time_ui,event) changeTWaveTime(t_wave_time_ui, elec_ax, electrode_data(electrode_count).ave_wave_time, electrode_data(electrode_count).average_waveform, electrode_count, display_final_button, well_pan));

                        set(t_wave_time_text, 'Visible', 'off');
                        set(t_wave_time_ui, 'Visible', 'off');
                        
                        manual_t_wave_button = uibutton(elec_pan,'push','Text', 'Manual T-Wave Peak Input', 'Position', [0 0 ((well_p_width/num_electrode_cols)-25)/2 20], 'ButtonPushedFcn', @(manual_t_wave_button,event) manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui));
                
                      
 
                    end
                end
            end
            
        end
        
        if strcmp(beat_to_beat, 'off')
            if strcmp(stable_ave_analysis, 'time_region')
                
               reanalyse_button = uibutton(main_well_pan,'push','Text', 'Re-analyse Electrodes', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseTimeRegionButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
               reanalyse_well_button = uibutton(main_well_pan,'push','Text', 'Re-analyse Well', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(reanalyse_well_button,event) reanalyseTimeRegionWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
            end
            
            
        end
        
        function changeTWaveTime(t_wave_time_ui, elec_ax, time, data, electrode_count, display_final_button, well_pan)
            
            max_depol_time = electrode_data(electrode_count).ave_max_depol_time;
            min_depol_time = electrode_data(electrode_count).ave_min_depol_time;
            act_time = electrode_data(electrode_count).ave_activation_time;
            
            
            elec_child = get(elec_ax, 'Children');
            found_plot = 0;
            for ch = 1:length(elec_child)
                child_x_data = elec_child(ch).XData;
                if length(child_x_data) == 1
                    if child_x_data ~= max_depol_time && child_x_data ~= min_depol_time && child_x_data ~= act_time
                        found_plot = 1;
                        t_wave_plot = elec_child(ch);

                    end
                end                

            end

            peak_indx = find(time >= get(t_wave_time_ui, 'Value'));
            peak_indx = peak_indx(1);
            t_wave_peak = data(peak_indx);
            if found_plot == 0
                hold(elec_ax, 'on')

                plot(elec_ax, get(t_wave_time_ui, 'Value'), t_wave_peak, 'co');
                hold(elec_ax, 'off')

            else
                t_wave_plot.XData = get(t_wave_time_ui, 'Value');
                t_wave_plot.YData = t_wave_peak;
            end
            well_electrode_data(well_count, electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
            electrode_data(electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');

            %{
            if ismember([well_electrode_data(well_count, :).ave_t_wave_peak_time], 0)
                set(display_final_button, 'Visible', 'on')
                [le, len_well_elec] = size(well_electrode_data)
                %disp();
                for i = 1:len_well_elec
                    well_electrode_data(well_count, i).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
                    electrode_data(i).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
                end

                % gets the electrode panels
                well_child = get(well_pan, 'Children')
                
                for wc = 1:length(well_child)
                    % gets the axes objects
                    elec_child = get(well_child(wc), 'Children');                 
    
                    for ch = 1:length(elec_child)
                        %disp(get(elec_child(ch), 'Type'))
                        if ~strcmp(get(elec_child(ch), 'Type'), 'axes')
                            continue;
                        end
                        elec_plots = get(elec_child(ch), 'Children');
                        for ep = 1:length(elec_plots)
                            child_x_data = elec_plots(ep).XData;
                            child_y_data = elec_plots(ep).YData;
                            if length(child_x_data) ~= 1
                                %if child_x_data ~= max_depol_time && child_x_data ~= min_depol_time && child_x_data ~= act_time
                                    peak_indx = find(child_x_data >= get(t_wave_time_ui, 'Value'));
                                    peak_indx = peak_indx(1);
                                    t_wave_peak = child_y_data(peak_indx);

                                    hold(elec_child(ch), 'on')
                                    plot(elec_child(ch), get(t_wave_time_ui, 'Value'), t_wave_peak, 'co');
                                    hold(elec_child(ch), 'off')

                                %end
                            end      
                        end
                    end
                end
                
                
            else
                elec_child = get(elec_ax, 'Children');
                found_plot = 0;
                for ch = 1:length(elec_child)
                    child_x_data = elec_child(ch).XData;
                    if length(child_x_data) == 1
                        if child_x_data ~= max_depol_time && child_x_data ~= min_depol_time && child_x_data ~= act_time
                            found_plot = 1;
                            t_wave_plot = elec_child(ch);

                        end
                    end                

                end
                
                peak_indx = find(time >= get(t_wave_time_ui, 'Value'));
                peak_indx = peak_indx(1);
                t_wave_peak = data(peak_indx);
                if found_plot == 0
                    hold(elec_ax, 'on')

                    plot(elec_ax, get(t_wave_time_ui, 'Value'), t_wave_peak, 'co');
                    hold(elec_ax, 'off')

                else
                    t_wave_plot.XData = get(t_wave_time_ui, 'Value');
                    t_wave_plot.YData = t_wave_peak;
                end
                well_electrode_data(well_count, electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
                electrode_data(electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
                
            end
            %}
           
            
        end
        
        function rejectElectrodeButtonPushed(reject_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count)
            well_electrode_data(well_count, electrode_count).min_stdev = 0;
            electrode_data(electrode_count).min_stdev = 0;
            electrode_data(electrode_count).average_waveform = [];
            well_electrode_data(well_count, electrode_count).average_waveform = [];
            electrode_data(electrode_count).ave_wave_time = [];
            well_electrode_data(well_count,electrode_count).ave_wave_time = [];
            electrode_data(electrode_count).time = [];
            well_electrode_data(well_count, electrode_count).time = [];
            electrode_data(electrode_count).data = [];
            well_electrode_data(well_count, electrode_count).data = [];
            electrode_data(electrode_count).electrode_id = '';
            well_electrode_data(well_count, electrode_count).electrode_id = '';
            electrode_data(electrode_count).stable_waveforms = {};
            well_electrode_data(well_count, electrode_count).stable_waveforms = {};
            electrode_data(electrode_count).stable_times = {};
            well_electrode_data(well_count,electrode_count).stable_times = {};
            electrode_data(electrode_count).window = 0;
            well_electrode_data(well_count,electrode_count).window = 0;
            electrode_data(electrode_count).activation_times = [];
            well_electrode_data(well_count, electrode_count).activation_times = [];
            electrode_data(electrode_count).beat_num_array = []; 
            well_electrode_data(well_count, electrode_count).beat_num_array = []; 
            electrode_data(electrode_count).cycle_length_array = [];
            well_electrode_data(well_count, electrode_count).cycle_length_array = [];
            electrode_data(electrode_count).beat_start_times = [];
            well_electrode_data(well_count,electrode_count).beat_start_times = [];
            electrode_data(electrode_count).beat_periods = [];
            well_electrode_data(well_count, electrode_count).beat_periods = [];
            electrode_data(electrode_count).t_wave_peak_times = [];
            well_electrode_data(well_count,electrode_count).t_wave_peak_times = [];
            electrode_data(electrode_count).t_wave_peak_array = [];
            well_electrode_data(well_count,electrode_count).t_wave_peak_array = [];
            electrode_data(electrode_count).max_depol_time_array = [];
            well_electrode_data(well_count,electrode_count).max_depol_time_array = [];
            electrode_data(electrode_count).min_depol_time_array = [];
            well_electrode_data(well_count,electrode_count).min_depol_time_array = [];
            electrode_data(electrode_count).max_depol_point_array = [];
            well_electrode_data(well_count,electrode_count).max_depol_point_array = [];
            electrode_data(electrode_count).min_depol_point_array = [];
            well_electrode_data(well_count,electrode_count).min_depol_point_array = [];
            electrode_data(electrode_count).activation_point_array = [];
            well_electrode_data(well_count,electrode_count).activation_point_array = [];
            electrode_data(electrode_count).Stims = [];
            well_electrode_data(well_count,electrode_count).Stims = [];
            electrode_data(electrode_count).ave_max_depol_time = 0;
            well_electrode_data(well_count,electrode_count).ave_max_depol_time = 0;
            electrode_data(electrode_count).ave_min_depol_time = 0;
            well_electrode_data(well_count,electrode_count).ave_min_depol_time = 0;
            electrode_data(electrode_count).ave_max_depol_point = 0;
            well_electrode_data(well_count,electrode_count).ave_max_depol_point = 0;
            electrode_data(electrode_count).ave_min_depol_point = 0;
            well_electrode_data(well_count,electrode_count).ave_min_depol_point = 0;
            electrode_data(electrode_count).ave_activation_time = 0;
            well_electrode_data(well_count,electrode_count).ave_activation_time = 0;
            electrode_data(electrode_count).ave_t_wave_peak_time = 0;
            well_electrode_data(well_count,electrode_count).ave_t_wave_peak_time = 0;
            electrode_data(electrode_count).ave_depol_slope = 0;
            well_electrode_data(well_count,electrode_count).ave_depol_slope = 0;
            electrode_data(electrode_count).depol_slope_array = [];
            well_electrode_data(well_count,electrode_count).depol_slope_array = [];
            set(elec_pan, 'Visible', 'off');
            
        end
        
        function reanalyseWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            set(well_elec_fig, 'Visible', 'off')
            [well_electrode_data(well_count, :)] = reanalyse_b2b_well_analysis(electrode_data, num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID);
            electrode_data = well_electrode_data(well_count, :);
        end
        
        function reanalyseTimeRegionWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            set(well_elec_fig, 'Visible', 'off')
            [well_electrode_data(well_count, :)] = reanalyse_time_region_well(electrode_data, num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID);
            electrode_data = well_electrode_data(well_count, :);
        end
        
        function reanalyseButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            set(well_elec_fig, 'Visible', 'off')

            reanalyse_fig = uifigure;
            reanalyse_pan = uipanel(reanalyse_fig, 'Position', [0 0 screen_width screen_height]);
            submit_reanalyse_button = uibutton(reanalyse_pan, 'push','Text', 'Submit Electrodes', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(submit_reanalyse_button,event) submitReanalyseButtonPushed(submit_reanalyse_button, well_elec_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));

            reanalyse_width = screen_width-300;
            reanalyse_height = screen_height -100;
            ra_pan = uipanel(reanalyse_pan, 'Position', [0 0 reanalyse_width reanalyse_height]);

            elec_count = 0;

            reanalyse_electrodes = [];
            elec_ids = [electrode_data(:).electrode_id];
            
            for el_r = num_electrode_rows:-1:1
                for el_c = 1:num_electrode_cols
                    elec_id = strcat(well_ID, '_', num2str(el_r), '_', num2str(el_c));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    elec_count = elec_indx;
                    if isempty(electrode_data(elec_count))
                        continue;
                    end
                    %elec_count = elec_count+1;
                    ra_elec_pan = uipanel(ra_pan, 'Title', electrode_data(elec_count).electrode_id, 'Position', [(el_c-1)*(reanalyse_width/num_electrode_cols) (el_r-1)*(reanalyse_height/num_electrode_rows) reanalyse_width/num_electrode_cols reanalyse_height/num_electrode_rows]);
                    ra_elec_button = uibutton(ra_elec_pan, 'push','Text', 'Reanalyse', 'Position', [0 0 reanalyse_width/num_electrode_cols reanalyse_height/num_electrode_rows], 'ButtonPushedFcn', @(ra_elec_button,event) reanalyseElectrodeButtonPushed(ra_elec_button, electrode_data(elec_count).electrode_id));
                    

                end
            end

            function reanalyseElectrodeButtonPushed(ra_elec_button, electrode_id)
                
                if strcmp(get(ra_elec_button, 'Text'), 'Reanalyse')
                    set(ra_elec_button, 'Text', 'Undo');
                    reanalyse_electrodes = [reanalyse_electrodes; electrode_id];
                elseif strcmp(get(ra_elec_button, 'Text'), 'Undo')
                    set(ra_elec_button, 'Text', 'Reanalyse');
                    reanalyse_electrodes = reanalyse_electrodes(~contains(reanalyse_electrodes, electrode_id));
                end
            end
            
            

            function submitReanalyseButtonPushed(submit_reanalyse_button, well_elec_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
                set(reanalyse_fig, 'Visible', 'off')
                if isempty(electrode_data)
                   return; 
                end
                [well_electrode_data(well_count, :)] = electrode_analysis(electrode_data, num_electrode_rows, num_electrode_cols, reanalyse_electrodes, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis);
                %disp(electrode_data(re_count).activation_times(2))
                electrode_data = well_electrode_data(well_count, :);
            end

        end
        
        function reanalyseTimeRegionButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            set(well_elec_fig, 'Visible', 'off')

            reanalyse_fig = uifigure;
            reanalyse_pan = uipanel(reanalyse_fig, 'Position', [0 0 screen_width screen_height]);
            submit_reanalyse_button = uibutton(reanalyse_pan, 'push','Text', 'Submit Electrodes', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(submit_reanalyse_button,event) submitReanalyseButtonPushed(submit_reanalyse_button, well_elec_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));

            reanalyse_width = screen_width-300;
            reanalyse_height = screen_height -100;
            ra_pan = uipanel(reanalyse_pan, 'Position', [0 0 reanalyse_width reanalyse_height]);

            elec_count = 0;

            reanalyse_electrodes = [];
            elec_ids = [electrode_data(:).electrode_id];
            
            for el_r = num_electrode_rows:-1:1
                for el_c = 1:num_electrode_cols
                    elec_id = strcat(well_ID, '_', num2str(el_r), '_', num2str(el_c));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    elec_count = elec_indx;
                    %elec_count = elec_count+1;
                    if ~isempty(electrode_data(elec_count))
                        ra_elec_pan = uipanel(ra_pan, 'Title', electrode_data(elec_count).electrode_id, 'Position', [(el_c-1)*(reanalyse_width/num_electrode_cols) (el_r-1)*(reanalyse_height/num_electrode_rows) reanalyse_width/num_electrode_cols reanalyse_height/num_electrode_rows]);
                        ra_elec_button = uibutton(ra_elec_pan, 'push','Text', 'Reanalyse', 'Position', [0 0 reanalyse_width/num_electrode_cols reanalyse_height/num_electrode_rows], 'ButtonPushedFcn', @(ra_elec_button,event) reanalyseElectrodeButtonPushed(ra_elec_button, electrode_data(elec_count).electrode_id));

                    end
                end
            end

            function reanalyseElectrodeButtonPushed(ra_elec_button, electrode_id)
                if strcmp(get(ra_elec_button, 'Text'), 'Reanalyse')
                    set(ra_elec_button, 'Text', 'Undo');
                    reanalyse_electrodes = [reanalyse_electrodes; electrode_id];
                elseif strcmp(get(ra_elec_button, 'Text'), 'Undo')
                    set(ra_elec_button, 'Text', 'Reanalyse');
                    reanalyse_electrodes = reanalyse_electrodes(~contains(reanalyse_electrodes, electrode_id));
                end
            end
            
            

            function submitReanalyseButtonPushed(submit_reanalyse_button, well_elec_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
                set(reanalyse_fig, 'Visible', 'off')
                if isempty(electrode_data)
                   return; 
                end
                [well_electrode_data(well_count, :), re_count] = electrode_time_region_analysis(electrode_data, num_electrode_rows, num_electrode_cols, reanalyse_electrodes, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis);
                %disp(electrode_data(re_count).activation_times(2))
                electrode_data = well_electrode_data(well_count, :);
            end

            
        end

        function heatMapButtonPushed(heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced)

            %set(well_elec_fig, 'Visible', 'off')
            start_activation_times = [];
            %disp(size(electrode_data))
            for e = 1:num_electrode_rows*num_electrode_cols
                %disp(e);
                elec_data = electrode_data(1,e);
                if isempty(elec_data.activation_times)
                    act_time = nan;
                else
                    act_times = elec_data.activation_times;
                    act_time = act_times(2);
                end
                
                start_activation_times = [start_activation_times; act_time];
            end
            conduction_map_GUI(start_activation_times, num_electrode_rows, num_electrode_cols, spon_paced, well_elec_fig)

        end

        function bipolarButtonPushed(bipolar_button, well_ID, num_electrode_rows, num_electrode_cols)
            calculate_bipolar_electrograms_GUI(electrode_data, num_electrode_rows, num_electrode_cols)

        end
        
        function adjacentBipolarButtonPushed(adjacent_bipolar_button, well_ID, num_electrode_rows, num_electrode_cols)
            calculate_adjacent_bipolar_electrograms_GUI(electrode_data, num_electrode_rows, num_electrode_cols)
        end

        function displayFinalB2BButtonPushed(display_final_button, out_fig, well_elec_fig, well_button, bipolar)
            set(well_elec_fig, 'Visible', 'off')
            well_res_fig = uifigure;
            well_res_fig.Name = strcat(well_ID, '_', 'Electrode Final Results');
            % left bottom width height
            main_res_pan = uipanel(well_res_fig, 'Position', [0 0 screen_width screen_height]);

            well_p_width = screen_width-300;
            well_p_height = screen_height -100;
            well_res_p = uipanel(main_res_pan, 'Position', [0 0 well_p_width well_p_height]);
            
            elec_ids = [electrode_data(:).electrode_id];
            advanced_elec_panel = uipanel(main_res_pan, 'Title', 'View Advanced Statistics', 'Position', [well_p_width 350 300 300]);
            for elec_r = num_electrode_rows:-1:1
                for elec_c = 1:num_electrode_cols
                    elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    electrode_count = elec_indx;
                    if isempty(electrode_data(electrode_count))
                        continue;
                    end
                    adv_stats_elec_button = uibutton(advanced_elec_panel,'push','Text', strcat(num2str(elec_r), '_', num2str(elec_c)), 'Position', [(elec_c-1)*(300/num_electrode_cols) (elec_r-1)*(300/num_electrode_rows) 300/num_electrode_cols 300/num_electrode_rows], 'ButtonPushedFcn', @(adv_stats_elec_button,event) advancedStatsButtonPushed(adv_stats_elec_button, electrode_data(electrode_count)));

           
                end
            end

            results_close_button = uibutton(main_res_pan,'push','Text', 'Close', 'Position', [screen_width-220 0 100 50], 'ButtonPushedFcn', @(results_close_button,event) closeResultsButtonPushed(results_close_button, well_res_fig, out_fig, well_button));
            save_button = uibutton(main_res_pan,'push','Text', 'Save', 'Position', [screen_width-220 300 100 50], 'ButtonPushedFcn', @(save_button,event) saveB2BButtonPushed(save_button, electrode_data, save_dir, well_ID, num_electrode_rows, num_electrode_cols));


            heat_map_results_button = uibutton(main_res_pan,'push','Text', 'View Heat Maps', 'Position', [screen_width-300 50 100 50], 'ButtonPushedFcn', @(heat_map_results_button,event) heatMapButtonPushed(heat_map_results_button, well_res_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced));
            if strcmp(bipolar, 'on')
                results_bipolar_button = uibutton(main_res_pan,'push','Text', 'B.P. Electrogam Results', 'Position', [screen_width-200 50 100 50], 'ButtonPushedFcn', @(results_bipolar_button,event) bipolarButtonPushed(results_bipolar_button, well_ID, num_electrode_rows, num_electrode_cols));
                results_adjacent_bipolar_button = uibutton(main_res_pan,'push','Text', 'Adjacent B.P. Electrogam Results', 'Position', [screen_width-100 50 100 50], 'ButtonPushedFcn', @(results_adjacent_bipolar_button,event) adjacentBipolarButtonPushed(results_adjacent_bipolar_button, well_ID, num_electrode_rows, num_electrode_cols));
                
            end
            
            
            electrode_count = 0;
            well_FPDs = [];
            well_slopes = [];
            well_amps = [];
            well_bps = [];
            for elec_r = num_electrode_rows:-1:1
                for elec_c = 1:num_electrode_cols
                    elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    electrode_count = elec_indx;
                    %electrode_count = electrode_count+1;
                    %plot all the electrodes analysed data and 
                    % left bottom width height
                    
                    if isempty(electrode_data(electrode_count))
                        continue;
                    end
                    
                    elec_res_pan = uipanel(well_res_p, 'Title', electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);

                    
                    
                    elec_res_ax = uiaxes(elec_res_pan, 'Position', [0 20 (well_p_width/num_electrode_cols)-25 (well_p_height/num_electrode_rows)-40]);

                    t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                    t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                    t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                    t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                    hold(elec_res_ax,'on')
                    plot(elec_res_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);
                    plot(elec_res_ax, t_wave_peak_times, t_wave_peak_array, 'co');
                    plot(elec_res_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'ro');
                    plot(elec_res_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'bo');

                    [~, beat_start_volts, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
                    beat_start_volts = electrode_data(electrode_count).data(beat_start_volts);
                    plot(elec_res_ax, electrode_data(electrode_count).beat_start_times, beat_start_volts, 'go');
                    
                    
                    if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
                        %stim_indx = find(electrode_data(electrode_count).time == electrode_data(electrode_count).Stims)
                        [in, stim_indx, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).Stims);
                        %disp(in)
                        %disp(electrode_data(electrode_count).Stims)
                        Stim_points = electrode_data(electrode_count).data(stim_indx);
                        Stim_times = electrode_data(electrode_count).time(stim_indx);
                        %disp(length(Stim_points))
                        %disp(length(electrode_data(electrode_count).Stims))
                        %Stim_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).time == electrode_data(electrode_count).Stims));

                        plot(elec_res_ax, Stim_times, Stim_points, 'mo');
                    end
                                        
                    activation_times = electrode_data(electrode_count).activation_times;
                    activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                    FPDs = [t_wave_peak_times - activation_times];
                    
                    amps = [electrode_data(electrode_count).max_depol_point_array - electrode_data(electrode_count).min_depol_point_array];
                    
                    slopes = [electrode_data(electrode_count).depol_slope_array];
                    
                    bps = [electrode_data(electrode_count).beat_periods];                    
                    
                    
                    well_FPDs = [well_FPDs FPDs];
                    well_slopes = [well_slopes slopes];
                    well_amps = [well_amps amps];
                    well_bps = [well_bps bps];
                    %mean_FPD = mean(FPDs);
                    %mean_amp = mean(amps);
                    
                    %fpd_text = uieditfield(elec_res_pan,'Text', 'Value', strcat('Mean FPD=', num2str(mean_FPD)), 'FontSize', 6, 'Position', [0 0 ((well_p_width/num_electrode_cols)-25)/3 20], 'Editable','off');
                    %amp_text = uieditfield(elec_res_pan,'Text', 'Value', strcat('Mean Depol. Ampl.=', num2str(mean_amp)), 'FontSize', 6, 'Position', [((well_p_width/num_electrode_cols)-25)/3 0 ((well_p_width/num_electrode_cols)-25)/3 20], 'Editable','off');
                    
                    %stat_plots_button = uibutton(elec_res_pan,'push','Text','View Plots', 'Position', [2*(((well_p_width/num_electrode_cols)-25)/3) 0 ((well_p_width/num_electrode_cols)-25)/3 20], 'FontSize', 6,'ButtonPushedFcn', @(stat_plots_button,event) statPlotsButtonPushed(stat_plots_button, well_res_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, electrode_data(electrode_count)));

                    %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                    plot(elec_res_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                    hold(elec_res_ax,'off')
                    
                end
            end
            
            mean_FPD = mean(well_FPDs);
            mean_amp = mean(well_amps);
            mean_slope = mean(well_slopes);
            mean_bp = mean(well_bps);
            
            fpd_text = uieditfield(main_res_pan,'Text', 'Value', strcat(well_ID, 'Mean FPD=', num2str(mean_FPD)), 'FontSize', 10, 'Position', [screen_width-220 250 200 50], 'Editable','off');
            amp_text = uieditfield(main_res_pan,'Text', 'Value', strcat(well_ID, 'Mean Depol. Ampl.=', num2str(mean_amp)), 'FontSize', 10, 'Position', [screen_width-220 200 200 50], 'Editable','off');
            slope_text = uieditfield(main_res_pan,'Text', 'Value', strcat(well_ID, 'Mean Depol. Slope = ', num2str(mean_slope)), 'FontSize', 10, 'Position', [screen_width-220 150 200 50], 'Editable','off');
            bp_text = uieditfield(main_res_pan,'Text', 'Value', strcat(well_ID, 'Mean Beat Period =', num2str(mean_bp)), 'FontSize', 10, 'Position', [screen_width-220 100 200 50], 'Editable','off');
                        
            
            function statPlotsButtonPushed(stat_plots_button, well_res_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, electrode_data)
                stat_plots_fig = uifigure;
                stat_plots_fig.Name = strcat(well_ID, '_', 'Results Plots');
                % left bottom width height
                stats_pan = uipanel(stat_plots_fig, 'Position', [0 0 screen_width screen_height]);

              
                plots_p = uipanel(stats_pan, 'Position', [0 0 well_p_width well_p_height]);

                stats_close_button = uibutton(stats_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(stats_close_button,event) closeAllButtonPushed(stats_close_button, stat_plots_fig));

                %% BASED ON THE CYCLE LENGTHS PERFROM ARRHYTHMIA ANALYSIS
                [arrhythmia_indx] = arrhythmia_analysis(electrode_data.beat_num_array(2:end), electrode_data.cycle_length_array(2:end));
                if ~isempty(arrhythmia_indx)
                    disp('detected arrhythmia!')
                    arrhythmia_text = uieditfield(stats_pan,'Text', 'Value', strcat('Arrhthmic Event Detected Between Beats:', num2str(arrhythmia_indx(1)), '-', num2str(arrhythmia_indx(end))), 'FontSize', 10, 'Position', [screen_width-220 100 250 50], 'Editable','off');
                        
                end
                
                cl_ax = uiaxes(plots_p, 'Position', [0 0 well_p_width well_p_height/4]);
                beat_num_array = electrode_data.beat_num_array(2:end);
                cycle_length_array = electrode_data.cycle_length_array(2:end);
                plot(cl_ax, beat_num_array, cycle_length_array, 'bo');
                if  ~isempty(arrhythmia_indx)
                    hold(cl_ax, 'on')
                    plot(cl_ax, beat_num_array(arrhythmia_indx), cycle_length_array(arrhythmia_indx), 'ro');
                end
                xlabel(cl_ax, 'Beat Number');
                ylabel(cl_ax,'Cycle Length (s)');
                title(cl_ax, strcat('Cycle Length per Beat', {' '}, electrode_data.electrode_id));
 

                bp_ax = uiaxes(plots_p, 'Position', [0 well_p_height/4 well_p_width well_p_height/4]);
                plot(bp_ax, electrode_data.beat_num_array, electrode_data.beat_periods, 'bo');
                xlabel(bp_ax,'Beat Number');
                ylabel(bp_ax,'Beat Period (s)');
                title(bp_ax, strcat('Beat Period per Beat', {' '}, electrode_data.electrode_id));
                

                clcl_ax = uiaxes(plots_p, 'Position', [0 2*(well_p_height/4) well_p_width well_p_height/4]);
                plot(clcl_ax, electrode_data.cycle_length_array(2:end-1), electrode_data.cycle_length_array(3:end), 'bo');
                xlabel(clcl_ax,'Cycle Length Previous Beat (s)');
                ylabel(clcl_ax,'Cycle Length (s)');
                title(clcl_ax, strcat('Cycle Length vs Previous Beat Cycle Length', {' '}, electrode_data.electrode_id));
                
                t_wave_peak_times = electrode_data.t_wave_peak_times;
                t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                t_wave_peak_array = electrode_data.t_wave_peak_array;
                t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                activation_times = electrode_data.activation_times;
                activation_times = activation_times(~isnan(electrode_data.t_wave_peak_times));
                fpd_beats = electrode_data.beat_num_array(~isnan(electrode_data.t_wave_peak_times));
                elec_FPDs = [t_wave_peak_times - activation_times];
                fpd_ax = uiaxes(plots_p, 'Position', [0 3*(well_p_height/4) well_p_width well_p_height/4]);
                plot(fpd_ax, fpd_beats, elec_FPDs, 'bo');
                xlabel(fpd_ax,'Beat Number');
                ylabel(fpd_ax,'FPD (s)');
                title(fpd_ax, strcat('FPD per Beat Num', {' '}, electrode_data.electrode_id));
                
                
            end
            function advancedStatsButtonPushed(adv_stats_elec_button, electrode_data)
                disp(electrode_data.electrode_id)
                
                adv_elec_fig = uifigure;
                adv_elec_fig.Name = strcat(electrode_data.electrode_id, '_', 'Advanced Statistics');
                % left bottom width height
                adv_elec_panel = uipanel(adv_elec_fig, 'Position', [0 0 screen_width screen_height]);
                
                adv_elec_p = uipanel(adv_elec_panel, 'Position', [0 0 well_p_width well_p_height]);

                elec_stat_plots_button = uibutton(adv_elec_panel,'push','Text','View Plots', 'Position', [screen_width-220 150 120 50], 'FontSize', 10,'ButtonPushedFcn', @(elec_stat_plots_button,event) statPlotsButtonPushed(elec_stat_plots_button, adv_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, electrode_data));

                t_wave_peak_times = electrode_data.t_wave_peak_times;
                t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                t_wave_peak_array = electrode_data.t_wave_peak_array;
                t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                activation_times = electrode_data.activation_times;
                activation_times = activation_times(~isnan(electrode_data.t_wave_peak_times));
                elec_FPDs = [t_wave_peak_times - activation_times];
                    
                elec_amps = [electrode_data.max_depol_point_array - electrode_data.min_depol_point_array];
                
                elec_slopes = [electrode_data.depol_slope_array];
                
                elec_bps = [electrode_data.beat_periods];

                elec_mean_FPD = mean(elec_FPDs);
                elec_mean_amp = mean(elec_amps);
                elec_mean_slope = mean(elec_slopes);
                elec_mean_bp = mean(elec_bps);

                elec_fpd_text = uieditfield(adv_elec_panel,'Text', 'Value', strcat('Mean FPD = ', num2str(elec_mean_FPD)), 'FontSize', 10, 'Position', [screen_width-220 550 200 50], 'Editable','off');
                elec_amp_text = uieditfield(adv_elec_panel,'Text', 'Value', strcat('Mean Depol. Ampl. = ', num2str(elec_mean_amp)), 'FontSize', 10, 'Position', [screen_width-220 450 200 50], 'Editable','off');
                elec_slope_text = uieditfield(adv_elec_panel,'Text', 'Value', strcat('Mean Depol. Slope = ', num2str(elec_mean_slope)), 'FontSize', 10, 'Position', [screen_width-220 350 200 50], 'Editable','off');
                elec_bp_text = uieditfield(adv_elec_panel,'Text', 'Value', strcat('Mean Beat Period =', num2str(elec_mean_bp)), 'FontSize', 10, 'Position', [screen_width-220 250 200 50], 'Editable','off');
                
                
                
                adv_close_button = uibutton(adv_elec_panel,'push','Text', 'Close', 'FontSize', 10,'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(adv_close_button,event) closeAllButtonPushed(adv_close_button, adv_elec_fig));

                adv_ax = uiaxes(adv_elec_p, 'Position', [0 50 well_p_width well_p_height-50]);
                hold(adv_ax,'on')
                plot(adv_ax, electrode_data.time, electrode_data.data);
                plot(adv_ax, t_wave_peak_times, t_wave_peak_array, 'co');
                plot(adv_ax, electrode_data.max_depol_time_array, electrode_data.max_depol_point_array, 'ro');
                plot(adv_ax, electrode_data.min_depol_time_array, electrode_data.min_depol_point_array, 'bo');
                
                [~, beat_start_volts, ~] = intersect(electrode_data.time, electrode_data.beat_start_times);
                beat_start_volts = electrode_data.data(beat_start_volts);
                plot(adv_ax, electrode_data.beat_start_times, beat_start_volts, 'go');

                if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
                    %stim_indx = find(electrode_data(electrode_count).time == electrode_data(electrode_count).Stims)
                    [in, stim_indx, ~] = intersect(electrode_data.time, electrode_data.Stims);
                    %disp(in)
                    %disp(electrode_data(electrode_count).Stims)
                    elec_Stim_times = electrode_data.time(stim_indx);
                    elec_Stim_points = electrode_data.data(stim_indx);
                    %disp(length(Stim_points))
                    %disp(length(electrode_data(electrode_count).Stims))
                    %Stim_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).time == electrode_data(electrode_count).Stims));

                    plot(adv_ax, elec_Stim_times, elec_Stim_points, 'mo');
                end
                %% Need slope value
                
                %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                plot(adv_ax, electrode_data.activation_times, electrode_data.activation_point_array, 'ko');
                if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
                    legend(adv_ax, 'signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'stimulus point', 'activation point')
                
                else
                    legend(adv_ax, 'signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point')
                
                end
                hold(adv_ax,'off')
                
            end
        end
        
        function displayFinalTimeRegionButtonPushed(display_final_button, out_fig, well_elec_fig, well_button)
            set(well_elec_fig, 'Visible', 'off')
            well_res_fig = uifigure;
            well_res_fig.Name = strcat(well_ID, '_', 'Electrode Final Results');
            % left bottom width height
            main_res_pan = uipanel(well_res_fig, 'Position', [0 0 screen_width screen_height]);

            well_p_width = screen_width-300;
            well_p_height = screen_height -100;
            well_res_p = uipanel(main_res_pan, 'Position', [0 0 well_p_width well_p_height]);

            save_button = uibutton(main_res_pan,'push','Text', 'Save', 'Position', [screen_width-220 300 100 50], 'ButtonPushedFcn', @(save_button,event) saveAveTimeRegionPushed(save_button, electrode_data, save_dir, well_ID, num_electrode_rows, num_electrode_cols));
            results_close_button = uibutton(main_res_pan,'push','Text', 'Close', 'Position', [screen_width-220 0 120 50], 'ButtonPushedFcn', @(results_close_button,event) closeResultsButtonPushed(results_close_button, well_res_fig, out_fig, well_button));

            %heat_map_results_button = uibutton(main_res_pan,'push','Text', 'Show Heat Map', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(heat_map_results_button,event) heatMapButtonPushed(heat_map_results_button, well_res_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced));

            elec_ids = [electrode_data(:).electrode_id];
            advanced_elec_panel = uipanel(main_res_pan, 'Title', 'View Advanced Statistics', 'Position', [well_p_width 350 300 300]);
            for elec_r = num_electrode_rows:-1:1
                for elec_c = 1:num_electrode_cols
                    elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    electrode_count = elec_indx;
                    if isempty(electrode_data(electrode_count))
                        continue;
                    end
                    adv_stats_elec_button = uibutton(advanced_elec_panel,'push','Text', strcat(num2str(elec_r), '_', num2str(elec_c)), 'Position', [(elec_c-1)*(300/num_electrode_cols) (elec_r-1)*(300/num_electrode_rows) 300/num_electrode_cols 300/num_electrode_rows], 'ButtonPushedFcn', @(adv_stats_elec_button,event) advancedStatsButtonPushed(adv_stats_elec_button, electrode_data(electrode_count)));

           
                end
            end
            electrode_count = 0;
            
            well_FPDs = [];
            well_amps = [];
            well_slopes = [];
            well_bps = [];
            for elec_r = num_electrode_rows:-1:1
                for elec_c = 1:num_electrode_cols
                    elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    electrode_count = elec_indx;
                    if isempty(electrode_data(electrode_count))
                        continue;
                    end
                    %electrode_count = electrode_count+1;
                    %plot all the electrodes analysed data and 
                    % left bottom width height
                    disp(electrode_data(electrode_count).electrode_id)
                    elec_res_pan = uipanel(well_res_p, 'Title', electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);

                    elec_res_ax = uiaxes(elec_res_pan, 'Position', [0 20 (well_p_width/num_electrode_cols)-25 (well_p_height/num_electrode_rows)-40]);

                    hold(elec_res_ax,'on')
                    plot(elec_res_ax, electrode_data(electrode_count).ave_wave_time, electrode_data(electrode_count).average_waveform);
                    %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                    plot(elec_res_ax, electrode_data(electrode_count).ave_max_depol_time, electrode_data(electrode_count).ave_max_depol_point, 'ro');
                    plot(elec_res_ax, electrode_data(electrode_count).ave_min_depol_time, electrode_data(electrode_count).ave_min_depol_point, 'bo');
                    plot(elec_res_ax, electrode_data(electrode_count).ave_activation_time, electrode_data(electrode_count).average_waveform(electrode_data(electrode_count).ave_wave_time == electrode_data(electrode_count).ave_activation_time), 'ko');

                    peak_indx = find(electrode_data(electrode_count).ave_wave_time >= electrode_data(electrode_count).ave_t_wave_peak_time);
                    peak_indx = peak_indx(1);
                    t_wave_peak = electrode_data(electrode_count).average_waveform(peak_indx);
                    plot(elec_res_ax, electrode_data(electrode_count).ave_t_wave_peak_time, t_wave_peak, 'co');
  
                    FPD = electrode_data(electrode_count).ave_t_wave_peak_time - electrode_data(electrode_count).ave_activation_time;
                    amplitude = electrode_data(electrode_count).ave_max_depol_point - electrode_data(electrode_count).ave_min_depol_point;
                    slope = electrode_data(electrode_count).ave_depol_slope;
                    bp = electrode_data(electrode_count).ave_wave_time(end) - electrode_data(electrode_count).ave_wave_time(1);
                    well_FPDs = [well_FPDs FPD];
                    well_amps = [well_amps amplitude];
                    well_slopes = [well_slopes slope];
                    well_bps = [well_bps bp];
                    
                    %fpd_text = uieditfield(elec_res_pan,'Text', 'Value', strcat('FPD = ', num2str(FPD)), 'FontSize', 8, 'Position', [0 0 ((well_p_width/num_electrode_cols)-25)/2 20], 'Editable','off');
                    %amp_text = uieditfield(elec_res_pan,'Text', 'Value', strcat('Depol. Amplitude = ', num2str(amplitude)), 'FontSize', 8, 'Position', [((well_p_width/num_electrode_cols)-25)/2 0 ((well_p_width/num_electrode_cols)-25)/2 20], 'Editable','off');
                    
                    %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                    %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                    hold(elec_res_ax,'off')
                    
                end
            end
            
            mean_FPD = mean(well_FPDs);
            mean_amp = mean(well_amps);
            mean_slope = mean(well_slopes);
            mean_bp = mean(well_bps);
            
            fpd_text = uieditfield(main_res_pan,'Text', 'Value', well_ID + " "+"Mean FPD ="+ " " +num2str(mean_FPD), 'FontSize', 10, 'Position', [screen_width-220 250 200 50], 'Editable','off');
            amp_text = uieditfield(main_res_pan,'Text', 'Value', well_ID + " " + "Mean Depol. Ampl.=" + " " + num2str(mean_amp), 'FontSize', 10, 'Position', [screen_width-220 200 200 50], 'Editable','off');
            slope_text = uieditfield(main_res_pan,'Text', 'Value', well_ID+ " " + "Mean Depol. Slope =" + " " + num2str(mean_slope), 'FontSize', 10, 'Position', [screen_width-220 150 200 50], 'Editable','off');
            bp_text = uieditfield(main_res_pan,'Text', 'Value', strcat(well_ID+ " " + "Mean Beat Period =" + " " + num2str(mean_bp)), 'FontSize', 10, 'Position', [screen_width-220 100 200 50], 'Editable','off');
                       
            
            function advancedStatsButtonPushed(adv_stats_elec_button, electrode_data)
                disp(electrode_data.electrode_id)
                
                adv_elec_fig = uifigure;
                adv_elec_fig.Name = strcat(electrode_data.electrode_id, '_', 'Advanced Statistics');
                % left bottom width height
                adv_elec_panel = uipanel(adv_elec_fig, 'Position', [0 0 screen_width screen_height]);
                
                adv_elec_p = uipanel(adv_elec_panel, 'Position', [0 0 well_p_width well_p_height]);

                elec_FPD = electrode_data.ave_t_wave_peak_time - electrode_data.ave_activation_time;
                elec_amplitude = electrode_data.ave_max_depol_point - electrode_data.ave_min_depol_point;
                elec_slope = electrode_data.ave_depol_slope;
                elec_bp = electrode_data.ave_wave_time(end) - electrode_data.ave_wave_time(1);

                %elec_stat_plots_button = uibutton(adv_elec_panel,'push','Text','View Plots', 'Position', [screen_width-220 200 120 50], 'FontSize', 6,'ButtonPushedFcn', @(elec_stat_plots_button,event) statPlotsButtonPushed(elec_stat_plots_button, adv_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, electrode_data));
                elec_fpd_text = uieditfield(adv_elec_panel,'Text', 'Value', "FPD = "+" " +num2str(elec_FPD), 'FontSize', 10, 'Position', [screen_width-220 250 200 50], 'Editable','off');
                elec_amp_text = uieditfield(adv_elec_panel,'Text', 'Value', "Depol. Amplitude = "+ " " + num2str(elec_amplitude), 'FontSize', 10, 'Position', [screen_width-220 200 200 50], 'Editable','off');
                elec_slope_text = uieditfield(adv_elec_panel,'Text', 'Value', "Depol. Slope = "+ " "+ num2str(elec_slope), 'FontSize', 10, 'Position', [screen_width-220 150 200 50], 'Editable','off');
                elec_bp_text = uieditfield(adv_elec_panel,'Text', 'Value', "Beat Period = " + " " + num2str(elec_bp), 'FontSize', 10, 'Position', [screen_width-220 100 200 50], 'Editable','off');

                
                adv_close_button = uibutton(adv_elec_panel,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(adv_close_button,event) closeAllButtonPushed(adv_close_button, adv_elec_fig));

                adv_ax = uiaxes(adv_elec_p, 'Position', [0 50 well_p_width well_p_height-50]);
                hold(adv_ax,'on')
                plot(adv_ax, electrode_data.ave_wave_time, electrode_data.average_waveform);
                %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                plot(adv_ax, electrode_data.ave_max_depol_time, electrode_data.ave_max_depol_point, 'ro');
                plot(adv_ax, electrode_data.ave_min_depol_time, electrode_data.ave_min_depol_point, 'bo');
                plot(adv_ax, electrode_data.ave_activation_time, electrode_data.average_waveform(electrode_data.ave_wave_time == electrode_data.ave_activation_time), 'ko');

                elec_peak_indx = find(electrode_data.ave_wave_time >= electrode_data.ave_t_wave_peak_time);
                elec_peak_indx = elec_peak_indx(1);
                elec_t_wave_peak = electrode_data.average_waveform(elec_peak_indx);
                plot(adv_ax, electrode_data.ave_t_wave_peak_time, elec_t_wave_peak, 'co');

                
                legend(adv_ax, 'signal', 'max depol.', 'min depol.', 'activation point', 'T-wave peak')
                
                %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                hold(adv_ax,'off')
                
            end
        end

    end

    function closeResultsButtonPushed(close_button, well_elec_fig, out_fig, well_button)
        set(well_elec_fig, 'Visible', 'off');
        set(well_button, 'Visible', 'off');
        set(out_fig, 'Visible', 'on');
    end

    function rejectWellButtonPushed(rejec_well_button, well_elec_fig, out_fig, well_button, well_count)
        set(well_elec_fig, 'Visible', 'off');
        set(well_button, 'Visible', 'off');
        set(out_fig, 'Visible', 'on');
        
        electrode_data = well_electrode_data(well_count, :);
        
        for j = 1:length(electrode_data)
            electrode_data(j).min_stdev = 0;
            electrode_data(j).average_waveform = [];
            electrode_data(j).ave_wave_time = [];
            electrode_data(j).time = [];
            electrode_data(j).data = [];
            electrode_data(j).electrode_id = '';
            electrode_data(j).stable_waveforms = {};
            electrode_data(j).stable_times = {};
            electrode_data(j).window = 0;
            electrode_data(j).activation_times = [];
            electrode_data(j).beat_num_array = []; 
            electrode_data(j).cycle_length_array = [];
            electrode_data(j).beat_start_times = [];
            electrode_data(j).beat_periods = [];
            electrode_data(j).t_wave_peak_times = [];
            electrode_data(j).t_wave_peak_array = [];
            electrode_data(j).max_depol_time_array = [];
            electrode_data(j).min_depol_time_array = [];
            electrode_data(j).max_depol_point_array = [];
            electrode_data(j).min_depol_point_array = [];
            electrode_data(j).activation_point_array = [];
            electrode_data(j).Stims = [];
            electrode_data(j).ave_max_depol_time = 0;
            electrode_data(j).ave_min_depol_time = 0;
            electrode_data(j).ave_max_depol_point = 0;
            electrode_data(j).ave_min_depol_point = 0;
            electrode_data(j).ave_activation_time = 0;
            electrode_data(j).ave_t_wave_peak_time = 0;
            electrode_data(j).ave_depol_slope = 0;
            electrode_data(j).depol_slope_array = [];
        end
        well_electrode_data(well_count, :) = electrode_data;
    end

    function closeButtonPushed(close_button, well_elec_fig, out_fig)
        set(well_elec_fig, 'Visible', 'off');

        set(out_fig, 'Visible', 'on');
    end
    function  closeAllButtonPushed(close_all_button, out_fig)
        set(out_fig, 'Visible', 'off');
    end

    function stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, electrode_data, change_GE_dropdown)
        well_ID = get(stable_button, 'Text');
        well_ID = regexp(well_ID, ' ', 'split');
        well_ID = well_ID{1};
        
        well_elec_fig = uifigure;
        well_elec_fig.Name = strcat(well_ID, '_', 'Electrode Results');
        % left bottom width height
        main_well_pan = uipanel(well_elec_fig, 'Position', [0 0 screen_width screen_height]);
        
        well_p_width = screen_width-300;
        well_p_height = screen_height -100;
        well_pan = uipanel(main_well_pan, 'Position', [0 0 well_p_width well_p_height]);
        
        if strcmp(get(change_GE_dropdown, 'Visible'), 'on')
            new_ge = get(change_GE_dropdown, 'Value');
            min_stdevs = contains([electrode_data(:).electrode_id], new_ge);
            min_electrode_beat_stdev_indx = find(min_stdevs == 1);
        else
            min_stdevs = [electrode_data(:).min_stdev];
            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);
        end
        GE_pan = uipanel(main_well_pan, 'Title', "Golden Electrode" + " " +electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position', [well_p_width screen_height-450 300 300]); 
        GE_ax = uiaxes(GE_pan, 'Position', [0 0 300 300]);
        
        hold(GE_ax, 'on')
        window = electrode_data(min_electrode_beat_stdev_indx).window;
        for k = 1:window
           plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).stable_times{k, 1}, electrode_data(min_electrode_beat_stdev_indx).stable_waveforms{k, 1});

        end
        hold(GE_ax, 'off');
        
        close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed(close_button, well_elec_fig, out_fig));
        
        electrode_count = 0;
        elec_ids = [electrode_data(:).electrode_id];
        for elec_r = num_electrode_rows:-1:1
            for elec_c = 1:num_electrode_cols
                elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                electrode_count = elec_indx;
                %electrode_count = electrode_count+1;
                if ~isempty(electrode_data(electrode_count))
                    
                    window = electrode_data(electrode_count).window;
                    elec_pan = uipanel(well_pan, 'Title', electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);

                    elec_ax = uiaxes(elec_pan, 'Position', [0 0 (well_p_width/num_electrode_cols)-25 (well_p_height/num_electrode_rows)-20]);
                    hold(elec_ax, 'on')
                    for k = 1:window
                       plot(elec_ax, electrode_data(electrode_count).stable_times{k, 1}, electrode_data(electrode_count).stable_waveforms{k, 1});
                       
                    end
                    hold(elec_ax, 'off');
                end
            end
        end
    end

    function averageElectrodesButtonPushed(average_button, added_wells, num_electrode_rows, num_electrode_cols, electrode_data, change_GE_dropdown)
        well_ID = get(average_button, 'Text');
        well_ID = regexp(well_ID, ' ', 'split');
        well_ID = well_ID{1};
        disp(well_ID)
        
        well_elec_fig = uifigure;
        well_elec_fig.Name = strcat(well_ID, '_', 'Electrode Results');
        % left bottom width height
        main_well_pan = uipanel(well_elec_fig, 'Position', [0 0 screen_width screen_height]);
        
        well_p_width = screen_width-300;
        well_p_height = screen_height -100;
        well_pan = uipanel(main_well_pan, 'Position', [0 0 well_p_width well_p_height]);
        
        
        if strcmp(get(change_GE_dropdown, 'Visible'), 'on')
            new_ge = get(change_GE_dropdown, 'Value');
            min_stdevs = contains([electrode_data(:).electrode_id], new_ge);
            min_electrode_beat_stdev_indx = find(min_stdevs == 1);
        else
            min_stdevs = [electrode_data(:).min_stdev];
            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);
        end
        GE_pan = uipanel(main_well_pan, 'Title', "Golden Electrode" + " " + electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position', [well_p_width screen_height-450 300 300]);
        
        GE_ax = uiaxes(GE_pan, 'Position', [0 0 300 300]);
        
        hold(GE_ax,'on')
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
        %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'ro');
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'bo');
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time == electrode_data(min_electrode_beat_stdev_indx).ave_activation_time), 'go');
        peak_indx = find(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time >= electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time);
        peak_indx = peak_indx(1);
        t_wave_peak = electrode_data(min_electrode_beat_stdev_indx).average_waveform(peak_indx);

        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, t_wave_peak, 'co');
        %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
        %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
        hold(GE_ax,'off')
        
        
        close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed(close_button, well_elec_fig, out_fig));
        
        electrode_count = 0;
        elec_ids = [electrode_data(:).electrode_id];
        for elec_r = num_electrode_rows:-1:1
            for elec_c = 1:num_electrode_cols
                elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                electrode_count = elec_indx;
                if ~isempty(electrode_data(electrode_count))
                    
                    elec_pan = uipanel(well_pan, 'Title', electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);

                    elec_ax = uiaxes(elec_pan, 'Position', [0 0 (well_p_width/num_electrode_cols)-25 (well_p_height/num_electrode_rows)-20]);
                    
                    hold(elec_ax,'on')
                    plot(elec_ax, electrode_data(electrode_count).ave_wave_time, electrode_data(electrode_count).average_waveform);
                    %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                    plot(elec_ax, electrode_data(electrode_count).ave_max_depol_time, electrode_data(electrode_count).ave_max_depol_point, 'ro');
                    plot(elec_ax, electrode_data(electrode_count).ave_min_depol_time, electrode_data(electrode_count).ave_min_depol_point, 'bo');
                    plot(elec_ax, electrode_data(electrode_count).ave_activation_time, electrode_data(electrode_count).average_waveform(electrode_data(electrode_count).ave_wave_time == electrode_data(electrode_count).ave_activation_time), 'go');
                    peak_indx = find(electrode_data(electrode_count).ave_wave_time >= electrode_data(electrode_count).ave_t_wave_peak_time);
                    peak_indx = peak_indx(1);
                    t_wave_peak = electrode_data(electrode_count).average_waveform(peak_indx);

                    plot(elec_ax, electrode_data(electrode_count).ave_t_wave_peak_time, t_wave_peak, 'co');

                    %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                    %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                    hold(elec_ax,'off')
                    
                end
            end
        end
    end

    function changeGEButtonPushed(change_GE_button, added_wells, change_GE_text, change_GE_dropdown, button_panel)
        well_ID = get(change_GE_button, 'Text');
        well_ID = regexp(well_ID, ' ', 'split');
        well_ID = well_ID{2};
        %disp(well_ID)
        %disp(contains(added_wells, well_ID))
        
        set(change_GE_button, 'Visible', 'off');
        set(change_GE_text, 'Visible', 'on');
        set(change_GE_dropdown, 'Visible', 'on');
        reset_GE_button = uibutton(button_panel,'push','Text', 'Reset Golden Electrode', 'Position', [2*(button_width/3)+(button_width/6) (button_height)/2 button_width/6 (button_height)/2], 'ButtonPushedFcn', @(reset_GE_button,event)resetGEButtonPushed(reset_GE_button, added_wells, change_GE_dropdown, change_GE_text, change_GE_button));
                        
        
    end

    function resetGEButtonPushed(reset_GE_button, added_wells, change_GE_dropdown, change_GE_text, change_GE_button)
        set(change_GE_button, 'Visible', 'on');
        set(change_GE_text, 'Visible', 'off');
        set(change_GE_dropdown, 'Visible', 'off');
        set(reset_GE_button, 'Visible', 'off');
    end

    function acceptGEButtonPushed(accept_GE_button, out_fig, well_electrode_data)
        % dropdown selections
        % t-wave input 
        % 
        set(out_fig, 'Visible', 'off');
                
        ge_results_fig = uifigure;
        ge_results_fig.Name = 'Golden Electrode Results';
        % left bottom width height
        main_ge_pan = uipanel(ge_results_fig, 'Position', [0 0 screen_width screen_height]);
        
        
        display_results_button = uibutton(main_ge_pan,'push','Text', 'Show Results', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(display_results_button,event) displayGEResultsPushed(display_results_button, ge_results_fig));
        
        well_p_width = screen_width-300;
        well_p_height = screen_height -100;
        ge_pan = uipanel(main_ge_pan, 'Position', [0 0 well_p_width well_p_height]);
        
        reanalyse_button = uibutton(main_ge_pan,'push','Text', 'Re-analyse Electrodes', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseGEButtonPushed(reanalyse_button, ge_results_fig, num_electrode_rows, num_electrode_cols, ge_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
        
        button_w = well_p_width/num_button_cols;
        button_h = well_p_height/num_button_rows;
        
        if num_button_rows > 1
            ge_count = 1;
            stop_ge_add = 0;
            for ge_r = 1:num_button_rows
               for ge_c = 1: num_button_cols
                   if ge_count > num_wells
                       stop_ge_add = 1;
                       break;
                   end
                   drop_down = dropdown_array(ge_count);
                   
                   electrode_data = well_electrode_data(ge_count,:);
                   if strcmp(get(drop_down, 'Visible'), 'off')
                        min_stdevs = [electrode_data(:).min_stdev];
                        min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);
                   else
                        new_ge = get(drop_down, 'Value');
                        new_ge_indx = contains([electrode_data(:).electrode_id], new_ge);
                        min_electrode_beat_stdev_indx = find(new_ge_indx == 1);
                   end
                   
                   ge_panel = uipanel(ge_pan, 'Title', electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position',[((ge_c-1)*button_w) ((ge_r-1)*button_h) button_w button_h]);
                   GE_ax = uiaxes(ge_panel,  'Position', [0 20 button_w button_h-20]);
                   
                   hold(GE_ax,'on')
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                   %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'ro');
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'bo');
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time == electrode_data(min_electrode_beat_stdev_indx).ave_activation_time), 'go');

                   peak_indx = find(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time >= electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time);
                   peak_indx = peak_indx(1);
                   t_wave_peak = electrode_data(min_electrode_beat_stdev_indx).average_waveform(peak_indx);

                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, t_wave_peak, 'co');

                   %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                   %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                   hold(GE_ax,'off')
                   
                   
                   t_wave_time_text = uieditfield(ge_panel,'Text', 'Value', 'T-wave Peak Time', 'FontSize', 8, 'Position', [0 0 (button_w/2)-25 20], 'Editable','off');
                   t_wave_time_ui = uieditfield(ge_panel, 'numeric', 'Tag', 'T-Wave', 'Position', [button_w/2 0 (button_w/2)-25 20], 'FontSize', 8, 'ValueChangedFcn',@(t_wave_time_ui,event) changeGETWaveTime(t_wave_time_ui, GE_ax, ge_count, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform, min_electrode_beat_stdev_indx));

                   manual_t_wave_button = uibutton(ge_panel,'push','Text', 'Manual T-Wave Peak Input', 'Position', [0 0 (button_w/2)-25 20], 'ButtonPushedFcn', @(manual_t_wave_button,event) manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui));
                   set(t_wave_time_text, 'Visible', 'off')
                   set(t_wave_time_ui, 'Visible', 'off')
                   
                   ge_count = ge_count+1;
               end
               if stop_ge_add == 1
                   break;
               end
            end

            
        else
            
            for ge = 1:num_wells
                drop_down = dropdown_array(ge);
                electrode_data = well_electrode_data(ge,:);

                if strcmp(get(drop_down, 'Visible'), 'off')
                    min_stdevs = [electrode_data(:).min_stdev];
                    min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);
                else
                    new_ge = get(drop_down, 'Value');
                    new_ge_indx = contains([electrode_data(:).electrode_id], new_ge);
                    min_electrode_beat_stdev_indx = find(new_ge_indx == 1);
                end
                
                ge_panel = uipanel(ge_pan, 'Title', electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position', [((ge-1)*button_w) 0 button_w button_h]);
                GE_ax = uiaxes(ge_panel,  'Position', [0 20 button_w button_h-20]);
                
                hold(GE_ax,'on')
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'ro');
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'bo');
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time == electrode_data(min_electrode_beat_stdev_indx).ave_activation_time), 'go');

                peak_indx = find(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time >= electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time);
                peak_indx = peak_indx(1);
                t_wave_peak = electrode_data(min_electrode_beat_stdev_indx).average_waveform(peak_indx);

                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, t_wave_peak, 'co');

                t_wave_time_text = uieditfield(ge_panel,'Text', 'Value', 'T-wave Peak Time', 'FontSize', 8, 'Position', [0 0 (button_w/2)-25 20], 'Editable','off');
                t_wave_time_ui = uieditfield(ge_panel, 'numeric', 'Tag', 'T-Wave', 'Position', [button_w/2 0 (button_w/2)-25 20], 'FontSize', 8, 'ValueChangedFcn',@(t_wave_time_ui,event) changeGETWaveTime(t_wave_time_ui, GE_ax, ge, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform, min_electrode_beat_stdev_indx));

               
                manual_t_wave_button = uibutton(ge_panel,'push','Text', 'Manual T-Wave Peak Input', 'Position', [0 0 (button_w/2)-25 20], 'ButtonPushedFcn', @(manual_t_wave_button,event) manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui));
                set(t_wave_time_text, 'Visible', 'off')
                set(t_wave_time_ui, 'Visible', 'off')
                %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                hold(GE_ax,'off')
            end
        end

        function changeGETWaveTime(t_wave_time_ui, GE_ax, well_count, time, data, electrode_count)
             max_depol_time = well_electrode_data(well_count, electrode_count).ave_max_depol_time;
             min_depol_time = well_electrode_data(well_count, electrode_count).ave_min_depol_time;
             act_time = well_electrode_data(well_count, electrode_count).ave_activation_time;
            
            elec_child = get(GE_ax, 'Children');
            found_plot = 0;
            for ch = 1:length(elec_child)
                child_x_data = elec_child(ch).XData;
                if length(child_x_data) == 1
                    if child_x_data ~= max_depol_time && child_x_data ~= min_depol_time && child_x_data ~= act_time
                        found_plot = 1;
                        t_wave_plot = elec_child(ch);

                    end
                end                

            end

            peak_indx = find(time >= get(t_wave_time_ui, 'Value'));
            peak_indx = peak_indx(1);
            t_wave_peak = data(peak_indx);
            if found_plot == 0
                hold(GE_ax, 'on')

                plot(GE_ax, get(t_wave_time_ui, 'Value'), t_wave_peak, 'co');
                hold(GE_ax, 'off')

            else
                t_wave_plot.XData = get(t_wave_time_ui, 'Value');
                t_wave_plot.YData = t_wave_peak;
            end
            well_electrode_data(well_count, electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
            %electrode_data(electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
            
        end 
        
        function reanalyseGEButtonPushed(reanalyse_button, ge_results_fig, num_electrode_rows, num_electrode_cols, ge_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            disp('$$$$$$$$$$$$$$$$$$$$REANALYSE$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$')
            set(ge_results_fig, 'Visible', 'off')

            reanalyse_fig = uifigure;
            reanalyse_pan = uipanel(reanalyse_fig, 'Position', [0 0 screen_width screen_height]);
            submit_reanalyse_button = uibutton(reanalyse_pan, 'push','Text', 'Submit Electrodes', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(submit_reanalyse_button,event) submitReanalyseButtonPushed(submit_reanalyse_button, ge_results_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));

            reanalyse_width = screen_width-300;
            reanalyse_height = screen_height -100;
            ra_pan = uipanel(reanalyse_pan, 'Position', [0 0 reanalyse_width reanalyse_height]);

            elec_count = 0;

            reanalyse_electrodes = [];
            reanalyse_panels = [];
            
            if num_button_rows > 1
                re_ge_count = 1;
                re_stop_ge_add = 0;
                for re_ge_r = 1:num_button_rows
                   for re_ge_c = 1: num_button_cols
                       if re_ge_count > num_wells
                           re_stop_ge_add = 1;
                           break;
                       end
                       drop_down = dropdown_array(re_ge_count);
                       re_well_ID = added_wells(re_ge_count);

                       electro_data = well_electrode_data(re_ge_count,:);
                       if strcmp(get(drop_down, 'Visible'), 'off')
                            min_stdevs = [electro_data(:).min_stdev];
                            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);
                       else
                            new_ge = get(drop_down, 'Value');
                            new_ge_indx = contains([electro_data(:).electrode_id], new_ge);
                            min_electrode_beat_stdev_indx = find(new_ge_indx == 1);
                       end
                   
                        %elec_count = elec_count+1;
                        ge_pan_children = get(ge_pan, 'Children');
                        for gp = 1:length(ge_pan_children)
                            if strcmp(get(ge_pan_children(gp), 'Title'), electro_data(min_electrode_beat_stdev_indx).electrode_id)
                                reanalyse_panels = [reanalyse_panels; ge_pan_children(gp)];
                            end
                        end
                        ra_elec_pan = uipanel(ra_pan, 'Title', re_well_ID, 'Position', [(re_ge_c-1)*(reanalyse_width/num_button_cols) (re_ge_r-1)*(reanalyse_height/num_button_rows) reanalyse_width/num_button_cols reanalyse_height/num_button_rows]);
                        ra_elec_button = uibutton(ra_elec_pan, 'push','Text', 'Reanalyse', 'Position', [0 0 reanalyse_width/num_button_cols reanalyse_height/num_button_rows], 'ButtonPushedFcn', @(ra_elec_button,event) reanalyseElectrodeButtonPushed(ra_elec_button, electro_data(min_electrode_beat_stdev_indx).electrode_id));

                        re_ge_count = re_ge_count+1;
                   end
                   if re_stop_ge_add == 1
                       break;
                   end
                end
            else
            
                for re_ge = 1:num_wells
                    
                    drop_down = dropdown_array(re_ge);
                    electro_data = well_electrode_data(re_ge,:);
                    
                    drop_down = dropdown_array(re_ge);
                    re_well_ID = added_wells(re_ge);

                    electro_data = well_electrode_data(re_ge,:);
                    if strcmp(get(drop_down, 'Visible'), 'off')
                        min_stdevs = [electro_data(:).min_stdev];
                        min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);
                    else
                        new_ge = get(drop_down, 'Value');
                        new_ge_indx = contains([electro_data(:).electrode_id], new_ge);
                        min_electrode_beat_stdev_indx = find(new_ge_indx == 1);
                    end

                    ge_pan_children = get(ge_pan, 'Children');
                    for gp = 1:length(ge_pan_children)
                        disp('title');
                        disp(get(ge_pan_children(gp), 'Title'))
                        if strcmp(get(ge_pan_children(gp), 'Title'), electro_data(min_electrode_beat_stdev_indx).electrode_id)
                            reanalyse_panels = [reanalyse_panels; ge_pan_children(gp)];
                        end
                    end
                    %elec_count = elec_count+1;
                    ra_elec_pan = uipanel(ra_pan, 'Title', re_well_ID, 'Position', [(re_ge-1)*(reanalyse_width/num_button_cols) 0 reanalyse_width/num_button_cols reanalyse_height]);
                    ra_elec_button = uibutton(ra_elec_pan, 'push','Text', 'Reanalyse', 'Position', [0 0 reanalyse_width/num_button_cols reanalyse_height], 'ButtonPushedFcn', @(ra_elec_button,event) reanalyseElectrodeButtonPushed(ra_elec_button, electro_data(min_electrode_beat_stdev_indx).electrode_id));

                end

            end
            function reanalyseElectrodeButtonPushed(ra_elec_button, electrode_id)
                if strcmp(get(ra_elec_button, 'Text'), 'Reanalyse')
                    set(ra_elec_button, 'Text', 'Undo');
                    reanalyse_electrodes = [reanalyse_electrodes; electrode_id];
                elseif strcmp(get(ra_elec_button, 'Text'), 'Undo')
                    set(ra_elec_button, 'Text', 'Reanalyse');
                    reanalyse_electrodes = reanalyse_electrodes(~contains(reanalyse_electrodes, electrode_id));
                end
            end
            
            

            function submitReanalyseButtonPushed(submit_reanalyse_button, ge_results_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
                set(reanalyse_fig, 'Visible', 'off')
                if isempty(electrode_data)
                   return; 
                end
                [well_electrode_data(:,:), re_count] = electrode_GE_analysis(well_electrode_data, num_electrode_rows, num_electrode_cols, reanalyse_electrodes, ge_results_fig, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, num_wells, reanalyse_panels);
                %disp(electrode_data(re_count).activation_times(2))
            end

        end
        
        function displayGEResultsPushed(display_results_button, ge_results_fig)
            set(ge_results_fig, 'Visible', 'off')
            ge_res_fig = uifigure;
            ge_res_fig.Name = 'Golden Electrode Results';
            % left bottom width height
            main_ge_res_pan = uipanel(ge_res_fig, 'Position', [0 0 screen_width screen_height]);

            close_button = uibutton(main_ge_res_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeAllButtonPushed(close_button, ge_res_fig));
            save_button = uibutton(main_ge_res_pan,'push','Text', 'Save', 'Position', [screen_width-220 300 100 50], 'ButtonPushedFcn', @(save_button,event) saveGEPushed(save_button, well_electrode_data, save_dir, num_electrode_rows, num_electrode_cols, drop_down));

            
            well_p_width = screen_width-300;
            well_p_height = screen_height -100;
            
            button_w = well_p_width/num_button_cols;
            button_h = well_p_height/num_button_rows;
            
            ge_res_pan = uipanel(main_ge_res_pan, 'Position', [0 0 well_p_width well_p_height]);

            if num_button_rows > 1
                ge_res_count = 1;
                stop_ge_res_add = 0;
                for ge_res_r = 1:num_button_rows
                   for ge_res_c = 1: num_button_cols
                       if ge_res_count > num_wells
                           stop_ge_res_add = 1;
                           break;
                       end
                       drop_down = dropdown_array(ge_res_count);

                       electrode_data = well_electrode_data(ge_res_count,:);
                       if strcmp(get(drop_down, 'Visible'), 'off')
                            min_stdevs = [electrode_data(:).min_stdev];
                            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);
                       else
                            new_ge = get(drop_down, 'Value');
                            new_ge_indx = contains([electrode_data(:).electrode_id], new_ge);
                            min_electrode_beat_stdev_indx = find(new_ge_indx == 1);
                       end

                       ge_res_panel = uipanel(ge_res_pan, 'Title', electrode_data(min_electrode_beat_stdev_indx).electrode_id,'Position', [((ge_res_c-1)*button_w) ((ge_res_r-1)*button_h) button_w button_h]);
                       GE_res_ax = uiaxes(ge_res_panel,  'Position', [0 20 button_w button_h-20]);

                       hold(GE_res_ax,'on')
                       plot(GE_res_ax, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                       %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                       plot(GE_res_ax, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'ro');
                       plot(GE_res_ax, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'bo');
                       plot(GE_res_ax, electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time == electrode_data(min_electrode_beat_stdev_indx).ave_activation_time), 'go');

                       peak_indx = find(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time >= electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time);
                       peak_indx = peak_indx(1);
                       t_wave_peak = electrode_data(min_electrode_beat_stdev_indx).average_waveform(peak_indx);
                       
                       plot(GE_res_ax, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, t_wave_peak, 'co');
                       
                       FPD = electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time - electrode_data(min_electrode_beat_stdev_indx).ave_activation_time;
                       slope = electrode_data(min_electrode_beat_stdev_indx).ave_depol_slope;
                       bp = electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(end) - electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(1);
                       amplitude = electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point - electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point;
                    
                       fpd_text = uieditfield(ge_res_panel,'Text', 'Value', "FPD = " + " " + num2str(FPD), 'FontSize', 9, 'Position', [0 0 button_w/4 20], 'Editable','off');
                       amp_text = uieditfield(ge_res_panel,'Text', 'Value', "Depol Spike Amplitude =" + " " + num2str(amplitude), 'FontSize', 9, 'Position', [button_w/4 0 button_w/4 20], 'Editable','off');
                       slope_text = uieditfield(ge_res_panel,'Text', 'Value', "Depol Spike Slope = " + " " + num2str(slope), 'FontSize', 9, 'Position', [button_w/4+(button_w/4) 0 (button_w/4) 20], 'Editable','off');
                       bp_text = uieditfield(ge_res_panel,'Text', 'Value', "Beat Period = " + " " + num2str(bp), 'FontSize', 9, 'Position', [button_w/4+2*(button_w/4) 0 (button_w/4) 20], 'Editable','off');
                    
                       
                       %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                       %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                       hold(GE_res_ax,'off');

                       ge_res_count = ge_res_count+1;
                   end
                   if stop_ge_res_add == 1
                       break;
                   end
                end


            else

                for res_ge = 1:num_wells
                    drop_down = dropdown_array(res_ge);
                    electrode_data = well_electrode_data(res_ge,:);
                    ge_res_panel = uipanel(ge_res_pan, 'Title', electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position', [((res_ge-1)*button_w) 0 button_w button_h]);
                    GE_res_ax = uiaxes(ge_res_panel,  'Position', [0 20 button_w button_h-20]);


                    if strcmp(get(drop_down, 'Visible'), 'off')
                        min_stdevs = [electrode_data(:).min_stdev];
                        min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);
                    else
                        new_ge = get(drop_down, 'Value');
                        new_ge_indx = contains([electrode_data(:).electrode_id], new_ge);
                        min_electrode_beat_stdev_indx = find(new_ge_indx == 1);
                    end
                    hold(GE_res_ax,'on')
                    plot(GE_res_ax, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                    %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                    plot(GE_res_ax, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'ro');
                    plot(GE_res_ax, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'bo');
                    plot(GE_res_ax, electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time == electrode_data(min_electrode_beat_stdev_indx).ave_activation_time), 'go');
                    title(GE_res_ax, electrode_data(min_electrode_beat_stdev_indx).electrode_id)
                    peak_indx = find(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time >= electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time);
                    peak_indx = peak_indx(1);
                    t_wave_peak = electrode_data(min_electrode_beat_stdev_indx).average_waveform(peak_indx);

                    plot(GE_res_ax, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, t_wave_peak, 'co');

                    FPD = electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time - electrode_data(min_electrode_beat_stdev_indx).ave_activation_time;
                    slope = electrode_data(min_electrode_beat_stdev_indx).ave_depol_slope;
                    bp = electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(end) - electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(1);
                    amplitude = electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point - electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point;
                    
                    fpd_text = uieditfield(ge_res_panel,'Text', 'Value', "FPD = " + " " + num2str(FPD), 'FontSize', 9, 'Position', [0 0 (button_w/4) 20], 'Editable','off');
                    amp_text = uieditfield(ge_res_panel,'Text', 'Value', "Depol Spike Amplitude = " + " " +num2str(amplitude), 'FontSize', 9, 'Position', [button_w/4 0 (button_w/4) 20], 'Editable','off');
                    slope_text = uieditfield(ge_res_panel,'Text', 'Value', "Depol Spike Slope ="+  " "+num2str(slope), 'FontSize', 9, 'Position', [button_w/4+((button_w/4)) 0 (button_w/4) 20], 'Editable','off');
                    bp_text = uieditfield(ge_res_panel,'Text', 'Value', "Beat Period = " + " " + num2str(bp), 'FontSize', 9, 'Position', [button_w/4+2*((button_w/4)) 0 (button_w/4) 20], 'Editable','off');
                    
                  
                    
                    %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                    %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                    hold(GE_res_ax,'off')
                end
            end
            
        end
    end

    function manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui)
        set(t_wave_time_text, 'Visible', 'on');
        set(t_wave_time_ui, 'Visible', 'on');
        set(manual_t_wave_button, 'Visible', 'off');
            
    end

    function saveB2BButtonPushed(save_button, electrode_data, save_dir, well_ID, num_electrode_rows, num_electrode_cols)
        disp('save b2b')
        disp(save_dir)
        disp(well_ID)
        output_filename = fullfile(save_dir, strcat(well_ID, '.xls'))
        
        well_FPDs = [];
        well_slopes = [];
        well_amps = [];
        well_bps = [];
        
        sheet_count = 1;
        elec_ids = [electrode_data(:).electrode_id];
        average_electrodes = {};
        max_act_elec_id = '';
        max_act_time = nan;
        min_act_elec_id = '';
        min_act_time = nan;
        for elec_r = 1:num_electrode_rows
            for elec_c = 1:num_electrode_cols
                
                elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                electrode_count = elec_indx;
                
                if isempty(electrode_data(electrode_count))
                    continue;
                end
                
                sheet_count = sheet_count+1;
                
                %electrode_stats_header = {electrode_data(electrode_count).electrode_id, 'Beat No.', 'Beat Start Time (s)', 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Cycle Length (s)'};
                
                %t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                %t_wave_peak_times = 
                %activation_times = electrode_data(electrode_count).activation_times;
                %activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                start_activation_time = electrode_data(electrode_count).activation_times(2);
                
                if isempty(max_act_elec_id)
                    max_act_elec_id = electrode_data(electrode_count).electrode_id;
                    max_act_time = start_activation_time;
                else
                    if start_activation_time > max_act_time
                        max_act_time = start_activation_time;
                        max_act_elec_id = electrode_data(electrode_count).electrode_id;
                    end
                end
                if isempty(min_act_elec_id)
                    min_act_elec_id = electrode_data(electrode_count).electrode_id;
                    min_act_time = start_activation_time;
                else
                    if start_activation_time < min_act_time
                        min_act_time = start_activation_time;
                        min_act_elec_id = electrode_data(electrode_count).electrode_id;
                    end
                end
                
                
                FPDs = [electrode_data(electrode_count).t_wave_peak_times - electrode_data(electrode_count).activation_times];

                amps = [electrode_data(electrode_count).max_depol_point_array - electrode_data(electrode_count).min_depol_point_array];

                slopes = [electrode_data(electrode_count).depol_slope_array];

                bps = [electrode_data(electrode_count).beat_periods];    
                
                well_FPDs = [well_FPDs FPDs];
                well_slopes = [well_slopes slopes];
                well_amps = [well_amps amps];
                well_bps = [well_bps bps];
                
                nan_FPDs = FPDs(~isnan(FPDs));
                nan_slopes = slopes(~isnan(slopes));
                nan_amps = amps(~isnan(amps));
                nan_bps = bps(~isnan(bps));

                mean_FPD = mean(nan_FPDs);
                mean_slope = mean(nan_slopes);
                mean_amp = mean(nan_amps);
                mean_bp = mean(nan_bps);

                headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
                mean_data = [mean_FPD; mean_slope; mean_amp; mean_bp];
                mean_data = num2cell(mean_data);
                mean_data = vertcat({''}, mean_data);
                %celldisp(mean_data);

                elec_stats = horzcat(headings, mean_data);
                
                if isempty(average_electrodes)
                    average_electrodes = elec_stats;
                    
                else
                    
                    average_electrodes = vertcat(average_electrodes, elec_stats);
                end
                
                beat_num_array = electrode_data(electrode_count).beat_num_array;
                [br, bc] = size(beat_num_array);
                beat_num_array = reshape(beat_num_array, [bc br]);
                beat_num_array = num2cell([beat_num_array]);
                beat_num_array = vertcat('Beat No.', beat_num_array);
                
                beat_start_times = electrode_data(electrode_count).beat_start_times;
                [br, bc] = size(beat_start_times);
                beat_start_times = reshape(beat_start_times, [bc br]);
                beat_start_times = num2cell([beat_start_times]);
                beat_start_times = vertcat('Beat Start Time (s)', beat_start_times);
                
                activation_times = electrode_data(electrode_count).activation_times;
                min_act = min(activation_times);
                orig_activation_times = activation_times;
                [br, bc] = size(activation_times);
                activation_times = reshape(activation_times, [bc br]);
                activation_times = num2cell([activation_times]);
                activation_times = vertcat('Activation Time (s)', activation_times);
                
                               
                [br, bc] = size(amps);
                amps = reshape(amps, [bc br]);
                amps = num2cell([amps]);
                amps = vertcat('Depolarisation Spike Amplitude (V)', amps);
                
                [br, bc] = size(slopes);
                slopes = reshape(slopes, [bc br]);
                slopes = num2cell([slopes]);
                slopes = vertcat('Depolarisation slope', slopes);
                
                t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                [br, bc] = size(t_wave_peak_times);
                t_wave_peak_times = reshape(t_wave_peak_times, [bc br]);
                t_wave_peak_times = num2cell([t_wave_peak_times]);
                t_wave_peak_times = vertcat('T-wave peak Time (s)', t_wave_peak_times);
                
                t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                [br, bc] = size(t_wave_peak_array);
                t_wave_peak_array = reshape(t_wave_peak_array, [bc br]);
                t_wave_peak_array = num2cell([t_wave_peak_array]);
                t_wave_peak_array = vertcat('T-wave peak (V)', t_wave_peak_array);
                
                [br, bc] = size(FPDs);
                FPDs = reshape(FPDs, [bc br]);
                FPDs = num2cell([FPDs]);
                FPDs = vertcat('FPD (s)', FPDs);
                
                beat_periods = electrode_data(electrode_count).beat_periods;
                [br, bc] = size(beat_periods);
                beat_periods = reshape(beat_periods, [bc br]);
                beat_periods = num2cell([beat_periods]);
                beat_periods = vertcat('Beat Period (s)', beat_periods);
                
                cycle_length_array = electrode_data(electrode_count).cycle_length_array;
                [br, bc] = size(cycle_length_array);
                cycle_length_array = reshape(cycle_length_array, [bc br]);
                cycle_length_array = num2cell([cycle_length_array]);
                cycle_length_array = vertcat('Cycle Length (s)', cycle_length_array);
                
                act_sub_min = orig_activation_times - min_act;
                [br, bc] = size(act_sub_min);
                act_sub_min = reshape(act_sub_min, [bc br]);
                act_sub_min = num2cell([act_sub_min]);
                act_sub_min = vertcat('Activation Time - minimum Activation Time (s)', act_sub_min);
                
                elec_id_column = repmat({''}, bc, br);
                %celldisp(elec_id_column)
                elec_id_column = vertcat(electrode_data(electrode_count).electrode_id, elec_id_column);
                
                
                electrode_stats = horzcat(elec_id_column, beat_num_array, beat_start_times, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, cycle_length_array, act_sub_min);
                %electrode_stats = {[elec_id_column] [beat_num_array] [beat_start_times] [activation_times] [amps] [slopes] [t_wave_peak_times] [t_wave_peak_array] [FPDs] [beat_periods] [cycle_length_array]};
                %electrode_stats = {electrode_stats_header;electrode_stats};
                
                electrode_stats = cellstr(electrode_stats);
                
                %celldisp(electrode_stats)

                [er, ec] = size(electrode_stats);
                
                %disp(sheet_count)
                
                % all_data must be a cell array
                xlswrite(output_filename, electrode_stats, sheet_count);
                
                
            end
        end
        well_FPDs = well_FPDs(~isnan(well_FPDs));
        well_slopes = well_slopes(~isnan(well_slopes));
        well_amps = well_amps(~isnan(well_amps));
        well_bps = well_bps(~isnan(well_bps));
        
        mean_FPD = mean(well_FPDs);
        mean_slope = mean(well_slopes);
        mean_amp = mean(well_amps);
        mean_bp = mean(well_bps);
        
        headings = {strcat(well_ID, ': Well-wide statistics'); 'max start activation time (s)'; 'max start activation time electrode id';'min start activation time (s)'; 'min start activation time electrode id'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
        mean_data1 = [max_act_time]; 
        mean_data2 = [mean_FPD; mean_slope; mean_amp; mean_bp];
        mean_data1 = num2cell(mean_data1);
        mean_data2 = num2cell(mean_data2);
        mean_data = vertcat({''}, {max_act_time}, {max_act_elec_id}, {min_act_time}, {min_act_elec_id}, mean_data2);
        
        
        well_stats = horzcat(headings, mean_data);
        %max_act_elec_id
        celldisp(well_stats);
        well_stats = vertcat(well_stats, average_electrodes);
        %well_stats = cellstr(well_stats)
        
        %celldisp(well_stats)
        
        xlswrite(output_filename, well_stats, 1);
        disp('done');
    end

    function saveAveTimeRegionPushed(save_button, electrode_data, save_dir, well_ID, num_electrode_rows, num_electrode_cols)
        disp('save b2b')
        disp(save_dir)
        disp(well_ID)
        output_filename = fullfile(save_dir, strcat(well_ID, '.xls'))
        
        well_FPDs = [];
        well_slopes = [];
        well_amps = [];
        well_bps = [];
        
        sheet_count = 1;
        elec_ids = [electrode_data(:).electrode_id];
        for elec_r = 1:num_electrode_rows
            for elec_c = 1:num_electrode_cols
                
                elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                electrode_count = elec_indx;
                
                if isempty(electrode_data(electrode_count))
                    continue;
                end
                
                sheet_count = sheet_count+1;
                
                %electrode_stats_header = {electrode_data(electrode_count).electrode_id, 'Beat No.', 'Beat Start Time (s)', 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Cycle Length (s)'};
                
                %t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                %t_wave_peak_times = 
                %activation_times = electrode_data(electrode_count).activation_times;
                %activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                
                FPDs = [electrode_data(electrode_count).ave_t_wave_peak_time - electrode_data(electrode_count).ave_activation_time];

                amps = [electrode_data(electrode_count).ave_max_depol_point - electrode_data(electrode_count).ave_min_depol_point];

                slopes = [electrode_data(electrode_count).ave_depol_slope];

                bps = [electrode_data(electrode_count).ave_wave_time(end)- electrode_data(electrode_count).ave_wave_time(1)];    
                
                well_FPDs = [well_FPDs FPDs];
                well_slopes = [well_slopes slopes];
                well_amps = [well_amps amps];
                well_bps = [well_bps bps];
                
                
                
                activation_times = electrode_data(electrode_count).ave_activation_time;
                [br, bc] = size(activation_times);
                activation_times = reshape(activation_times, [bc br]);
                activation_times = num2cell([activation_times]);
                activation_times = vertcat('Activation Time (s)', activation_times);
                %celldisp(activation_times)
                
                [br, bc] = size(amps);
                amps = reshape(amps, [bc br]);
                amps = num2cell([amps]);
                amps = vertcat('Depolarisation Spike Amplitude (V)', amps);
                %celldisp(amps)
                
                [br, bc] = size(slopes);
                slopes = reshape(slopes, [bc br]);
                slopes = num2cell([slopes]);
                slopes = vertcat('Depolarisation slope', slopes);
                %celldisp(slopes)
                
                t_wave_peak_times = electrode_data(electrode_count).ave_t_wave_peak_time;
                [br, bc] = size(t_wave_peak_times);
                t_wave_peak_times = reshape(t_wave_peak_times, [bc br]);
                t_wave_peak_times = num2cell([t_wave_peak_times]);
                t_wave_peak_times = vertcat('T-wave peak Time (s)', t_wave_peak_times);
                %celldisp(t_wave_peak_times)
                
                %ave_t_wave_peak = electrode_data(electrode_count).average_waveform(find(electrode_data(electrode_count).ave_wave_time == electrode_data(electrode_count).ave_t_wave_peak_time));
                
                peak_indx = find(electrode_data(electrode_count).ave_wave_time >= electrode_data(electrode_count).ave_t_wave_peak_time);
                ave_t_wave_peak = electrode_data(electrode_count).average_waveform(peak_indx(1));
                
                
                t_wave_peak_array = ave_t_wave_peak;
                [br, bc] = size(t_wave_peak_array);
                t_wave_peak_array = reshape(t_wave_peak_array, [bc br]);
                t_wave_peak_array = num2cell([t_wave_peak_array]);
                t_wave_peak_array = vertcat('T-wave peak (V)', t_wave_peak_array);
                %celldisp(t_wave_peak_array)
                
                [br, bc] = size(FPDs);
                FPDs = reshape(FPDs, [bc br]);
                FPDs = num2cell([FPDs]);
                FPDs = vertcat('FPD (s)', FPDs);
                %celldisp(FPDs)
                
                [br, bc] = size(bps);
                beat_periods = reshape(bps, [bc br]);
                beat_periods = num2cell([beat_periods]);
                beat_periods = vertcat('Beat Period (s)', beat_periods);
                %celldisp(beat_periods)
                
                elec_id_column = repmat({''}, bc, br);
                %celldisp(elec_id_column)
                elec_id_column = vertcat(electrode_data(electrode_count).electrode_id, elec_id_column);
                elec_id_column = elec_id_column;
                %disp(elec_id_column)
                %disp(class(elec_id_column))
                
                
                electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods);
                %electrode_stats = {[elec_id_column] [beat_num_array] [beat_start_times] [activation_times] [amps] [slopes] [t_wave_peak_times] [t_wave_peak_array] [FPDs] [beat_periods] [cycle_length_array]};
                %electrode_stats = {electrode_stats_header;electrode_stats};
                
                electrode_stats = cellstr(electrode_stats);
                
                %celldisp(electrode_stats)

                [er, ec] = size(electrode_stats);
                
                
                % all_data must be a cell array
                xlswrite(output_filename, electrode_stats, sheet_count);
            end
        end
        well_FPDs = well_FPDs(~isnan(well_FPDs));
        well_slopes = well_slopes(~isnan(well_slopes));
        well_amps = well_amps(~isnan(well_amps));
        well_bps = well_bps(~isnan(well_bps));
        
        mean_FPD = mean(well_FPDs);
        mean_slope = mean(well_slopes);
        mean_amp = mean(well_amps);
        mean_bp = mean(well_bps);
        
        headings = {strcat(well_ID,':Well-wide statistics'); 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
        mean_data = [mean_FPD; mean_slope; mean_amp; mean_bp];
        mean_data = num2cell(mean_data);
        mean_data = vertcat({''}, mean_data);
        %celldisp(mean_data);
        
        well_stats = horzcat(headings, mean_data);
        %well_stats = cellstr(well_stats)
        
        %celldisp(well_stats)
        
        xlswrite(output_filename, well_stats, 1);
        
    end

    function saveGEPushed(save_button, well_electrode_data, save_dir, num_electrode_rows, num_electrode_cols, drop_down)
        
        output_filename = fullfile(save_dir, strcat('golden_electrode_results.xls'))
        
        well_FPDs = [];
        well_slopes = [];
        well_amps = [];
        well_bps = [];
        
        sheet_count = 1;
        for w = 1:num_wells
            electrode_data = well_electrode_data(w, :);
            if strcmp(get(drop_down, 'Visible'), 'off')
                min_stdevs = [electrode_data(:).min_stdev];
                min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);
            
            else
                new_ge = get(drop_down, 'Value');
                new_ge_indx = contains([electrode_data(:).electrode_id], new_ge);
                min_electrode_beat_stdev_indx = find(new_ge_indx == 1);
            end
            sheet_count = sheet_count+1;
            %electrode_stats_header = {electrode_data(electrode_count).electrode_id, 'Beat No.', 'Beat Start Time (s)', 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Cycle Length (s)'};
    
            disp(min_electrode_beat_stdev_indx)
            
            t_wave_peak_times = electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time
            %t_wave_peak_times = 
            activation_times = electrode_data(min_electrode_beat_stdev_indx).ave_activation_time;
            %activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));

            FPDs = [t_wave_peak_times - activation_times];

            amps = [electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point - electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point];

            slopes = [electrode_data(min_electrode_beat_stdev_indx).ave_depol_slope];

            bps = [electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(end)- electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(1)];    

            well_FPDs = [well_FPDs FPDs];
            well_slopes = [well_slopes slopes];
            well_amps = [well_amps amps];
            well_bps = [well_bps bps];



            activation_times = electrode_data(min_electrode_beat_stdev_indx).ave_activation_time;
            [br, bc] = size(activation_times);
            activation_times = reshape(activation_times, [bc br]);
            activation_times = num2cell([activation_times]);
            activation_times = vertcat('Activation Time (s)', activation_times);

            [br, bc] = size(amps);
            amps = reshape(amps, [bc br]);
            amps = num2cell([amps]);
            amps = vertcat('Depolarisation Spike Amplitude (V)', amps);

            [br, bc] = size(slopes);
            slopes = reshape(slopes, [bc br]);
            slopes = num2cell([slopes]);
            slopes = vertcat('Depolarisation slope', slopes);


            t_wave_peak_times = electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time;
            [br, bc] = size(t_wave_peak_times);
            t_wave_peak_times = reshape(t_wave_peak_times, [bc br]);
            t_wave_peak_times = num2cell([t_wave_peak_times]);
            t_wave_peak_times = vertcat('T-wave peak Time (s)', t_wave_peak_times);

            peak_indx = find(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time >= electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time);
            ave_t_wave_peak = electrode_data(min_electrode_beat_stdev_indx).average_waveform(peak_indx(1));
                
            t_wave_peak_array = ave_t_wave_peak;
            [br, bc] = size(t_wave_peak_array);
            t_wave_peak_array = reshape(t_wave_peak_array, [bc br]);
            t_wave_peak_array = num2cell([t_wave_peak_array]);
            t_wave_peak_array = vertcat('T-wave peak (V)', t_wave_peak_array);

            [br, bc] = size(FPDs);
            FPDs = reshape(FPDs, [bc br]);
            FPDs = num2cell([FPDs]);
            FPDs = vertcat('FPD (s)', FPDs);

            [br, bc] = size(bps);
            beat_periods = reshape(bps, [bc br]);
            beat_periods = num2cell([beat_periods]);
            beat_periods = vertcat('Beat Period (s)', beat_periods);


            elec_id_column = repmat({''}, bc, br);
            %celldisp(elec_id_column)
            elec_id_column = vertcat(electrode_data(min_electrode_beat_stdev_indx).electrode_id, elec_id_column);


            electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods);
            %electrode_stats = {[elec_id_column] [beat_num_array] [beat_start_times] [activation_times] [amps] [slopes] [t_wave_peak_times] [t_wave_peak_array] [FPDs] [beat_periods] [cycle_length_array]};
            %electrode_stats = {electrode_stats_header;electrode_stats};

            electrode_stats = cellstr(electrode_stats);

            % all_data must be a cell array
            xlswrite(output_filename, electrode_stats, sheet_count);
        end
        well_FPDs = well_FPDs(~isnan(well_FPDs));
        well_slopes = well_slopes(~isnan(well_slopes));
        well_amps = well_amps(~isnan(well_amps));
        well_bps = well_bps(~isnan(well_bps));
        
        mean_FPD = mean(well_FPDs);
        mean_slope = mean(well_slopes);
        mean_amp = mean(well_amps);
        mean_bp = mean(well_bps);
        
        headings = {'Analysis Wide Statistics'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
        mean_data = [mean_FPD; mean_slope; mean_amp; mean_bp];
        mean_data = num2cell(mean_data);
        mean_data = vertcat({''}, mean_data);
        %celldisp(mean_data);
        
        well_stats = horzcat(headings, mean_data);
        %well_stats = cellstr(well_stats)
        
        %celldisp(well_stats)
        
        xlswrite(output_filename, well_stats, 1);
        
    end

    function saveAllB2BButtonPushed(save_button, save_dir, num_electrode_rows, num_electrode_cols)
        
        for w = 1:num_wells
            well_ID = added_wells(w);
            electrode_data = well_electrode_data(w, :);
            output_filename = fullfile(save_dir, strcat(well_ID, '.xls'))

            well_FPDs = [];
            well_slopes = [];
            well_amps = [];
            well_bps = [];

            sheet_count = 1;
            elec_ids = [electrode_data(:).electrode_id];
            average_electrodes = {};
            max_act_elec_id = '';
            max_act_time = nan;
            min_act_elec_id = '';
            min_act_time = nan;
            for elec_r = 1:num_electrode_rows
                for elec_c = 1:num_electrode_cols

                    elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    electrode_count = elec_indx;

                    if isempty(electrode_data(electrode_count))
                        continue;
                    end

                    sheet_count = sheet_count+1;

                    %electrode_stats_header = {electrode_data(electrode_count).electrode_id, 'Beat No.', 'Beat Start Time (s)', 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Cycle Length (s)'};

                    %t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                    %t_wave_peak_times = 
                    %activation_times = electrode_data(electrode_count).activation_times;
                    %activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));

                    start_activation_time = electrode_data(electrode_count).activation_times(2);
                    if isempty(max_act_elec_id)
                        max_act_elec_id = electrode_data(electrode_count).electrode_id;
                        max_act_time = start_activation_time;
                    else
                        if start_activation_time > max_act_time
                            max_act_time = start_activation_time;
                            max_act_elec_id = electrode_data(electrode_count).electrode_id;
                        end
                    end
                    if isempty(min_act_elec_id)
                        min_act_elec_id = electrode_data(electrode_count).electrode_id;
                        min_act_time = start_activation_time;
                    else
                        if start_activation_time < min_act_time
                            min_act_time = start_activation_time;
                            min_act_elec_id = electrode_data(electrode_count).electrode_id;
                        end
                    end
                    FPDs = [electrode_data(electrode_count).t_wave_peak_times - electrode_data(electrode_count).activation_times];

                    amps = [electrode_data(electrode_count).max_depol_point_array - electrode_data(electrode_count).min_depol_point_array];

                    slopes = [electrode_data(electrode_count).depol_slope_array];

                    bps = [electrode_data(electrode_count).beat_periods];    

                    well_FPDs = [well_FPDs FPDs];
                    well_slopes = [well_slopes slopes];
                    well_amps = [well_amps amps];
                    well_bps = [well_bps bps];
                    
                    nan_FPDs = FPDs(~isnan(FPDs));
                    nan_slopes = slopes(~isnan(slopes));
                    nan_amps = amps(~isnan(amps));
                    nan_bps = bps(~isnan(bps));

                    mean_FPD = mean(nan_FPDs);
                    mean_slope = mean(nan_slopes);
                    mean_amp = mean(nan_amps);
                    mean_bp = mean(nan_bps);

                    headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
                    mean_data = [mean_FPD; mean_slope; mean_amp; mean_bp];
                    mean_data = num2cell(mean_data);
                    mean_data = vertcat({''}, mean_data);
                    %celldisp(mean_data);

                    elec_stats = horzcat(headings, mean_data);

                    if isempty(average_electrodes)
                        average_electrodes = elec_stats;

                    else

                        average_electrodes = vertcat(average_electrodes, elec_stats);
                    end

                    beat_num_array = electrode_data(electrode_count).beat_num_array;
                    [br, bc] = size(beat_num_array);
                    beat_num_array = reshape(beat_num_array, [bc br]);
                    beat_num_array = num2cell([beat_num_array]);
                    beat_num_array = vertcat('Beat No.', beat_num_array);

                    beat_start_times = electrode_data(electrode_count).beat_start_times;
                    [br, bc] = size(beat_start_times);
                    beat_start_times = reshape(beat_start_times, [bc br]);
                    beat_start_times = num2cell([beat_start_times]);
                    beat_start_times = vertcat('Beat Start Time (s)', beat_start_times);

                    activation_times = electrode_data(electrode_count).activation_times;
                    min_act = min(activation_times);
                    orig_activation_times = activation_times;
                    [br, bc] = size(activation_times);
                    activation_times = reshape(activation_times, [bc br]);
                    activation_times = num2cell([activation_times]);
                    activation_times = vertcat('Activation Time (s)', activation_times);


                    [br, bc] = size(amps);
                    amps = reshape(amps, [bc br]);
                    amps = num2cell([amps]);
                    amps = vertcat('Depolarisation Spike Amplitude (V)', amps);

                    [br, bc] = size(slopes);
                    slopes = reshape(slopes, [bc br]);
                    slopes = num2cell([slopes]);
                    slopes = vertcat('Depolarisation slope', slopes);

                    t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                    [br, bc] = size(t_wave_peak_times);
                    t_wave_peak_times = reshape(t_wave_peak_times, [bc br]);
                    t_wave_peak_times = num2cell([t_wave_peak_times]);
                    t_wave_peak_times = vertcat('T-wave peak Time (s)', t_wave_peak_times);

                    t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                    [br, bc] = size(t_wave_peak_array);
                    t_wave_peak_array = reshape(t_wave_peak_array, [bc br]);
                    t_wave_peak_array = num2cell([t_wave_peak_array]);
                    t_wave_peak_array = vertcat('T-wave peak (V)', t_wave_peak_array);

                    [br, bc] = size(FPDs);
                    FPDs = reshape(FPDs, [bc br]);
                    FPDs = num2cell([FPDs]);
                    FPDs = vertcat('FPD (s)', FPDs);

                    beat_periods = electrode_data(electrode_count).beat_periods;
                    [br, bc] = size(beat_periods);
                    beat_periods = reshape(beat_periods, [bc br]);
                    beat_periods = num2cell([beat_periods]);
                    beat_periods = vertcat('Beat Period (s)', beat_periods);

                    cycle_length_array = electrode_data(electrode_count).cycle_length_array;
                    [br, bc] = size(cycle_length_array);
                    cycle_length_array = reshape(cycle_length_array, [bc br]);
                    cycle_length_array = num2cell([cycle_length_array]);
                    cycle_length_array = vertcat('Cycle Length (s)', cycle_length_array);

                    act_sub_min = orig_activation_times - min_act;
                    [br, bc] = size(act_sub_min);
                    act_sub_min = reshape(act_sub_min, [bc br]);
                    act_sub_min = num2cell([act_sub_min]);
                    act_sub_min = vertcat('Activation Time - minimum Activation Time (s)', act_sub_min);

                    elec_id_column = repmat({''}, bc, br);
                    %celldisp(elec_id_column)
                    elec_id_column = vertcat(electrode_data(electrode_count).electrode_id, elec_id_column);


                    electrode_stats = horzcat(elec_id_column, beat_num_array, beat_start_times, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, cycle_length_array, act_sub_min);
                    %electrode_stats = {[elec_id_column] [beat_num_array] [beat_start_times] [activation_times] [amps] [slopes] [t_wave_peak_times] [t_wave_peak_array] [FPDs] [beat_periods] [cycle_length_array]};
                    %electrode_stats = {electrode_stats_header;electrode_stats};

                    electrode_stats = cellstr(electrode_stats);

                    %celldisp(electrode_stats)

                    [er, ec] = size(electrode_stats);

                    %disp(sheet_count)

                    % all_data must be a cell array
                    xlswrite(output_filename, electrode_stats, sheet_count);
                end
            end
            well_FPDs = well_FPDs(~isnan(well_FPDs));
            well_slopes = well_slopes(~isnan(well_slopes));
            well_amps = well_amps(~isnan(well_amps));
            well_bps = well_bps(~isnan(well_bps));

            mean_FPD = mean(well_FPDs);
            mean_slope = mean(well_slopes);
            mean_amp = mean(well_amps);
            mean_bp = mean(well_bps);

            headings = {strcat(well_ID, ': Well-wide statistics'); 'max start activation time (s)'; 'max start activation time electrode id'; 'min start activation time (s)'; 'min start activation time electrode id'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
            mean_data1 = [max_act_time]; 
            mean_data2 = [mean_FPD; mean_slope; mean_amp; mean_bp];
            mean_data1 = num2cell(mean_data1);
            mean_data2 = num2cell(mean_data2);
            mean_data = vertcat({''}, {max_act_time}, {max_act_elec_id}, {min_act_time}, {min_act_elec_id}, mean_data2);
            

            well_stats = horzcat(headings, mean_data);
            %max_act_elec_id
            %celldisp(well_stats);
            well_stats = vertcat(well_stats, average_electrodes);

            xlswrite(output_filename, well_stats, 1);

        end
    end
    
    function saveAllTimeRegionButtonPushed(save_button, save_dir, num_electrode_rows, num_electrode_cols)
        
        for w = 1:num_wells
            well_ID = added_wells(w);
            electrode_data = well_electrode_data(w, :);
            output_filename = fullfile(save_dir, strcat(well_ID, '.xls'));

            well_FPDs = [];
            well_slopes = [];
            well_amps = [];
            well_bps = [];

            sheet_count = 1;
            elec_ids = [electrode_data(:).electrode_id];
            for elec_r = 1:num_electrode_rows
                for elec_c = 1:num_electrode_cols

                    elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    electrode_count = elec_indx;

                    if isempty(electrode_data(electrode_count))
                        continue;
                    end

                    sheet_count = sheet_count+1;

                    %electrode_stats_header = {electrode_data(electrode_count).electrode_id, 'Beat No.', 'Beat Start Time (s)', 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Cycle Length (s)'};

                    %t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                    %t_wave_peak_times = 
                    %activation_times = electrode_data(electrode_count).activation_times;
                    %activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));

                    FPDs = [electrode_data(electrode_count).ave_t_wave_peak_time - electrode_data(electrode_count).ave_activation_time];

                    amps = [electrode_data(electrode_count).ave_max_depol_point - electrode_data(electrode_count).ave_min_depol_point];

                    slopes = [electrode_data(electrode_count).ave_depol_slope];

                    bps = [electrode_data(electrode_count).ave_wave_time(end)- electrode_data(electrode_count).ave_wave_time(1)];    

                    well_FPDs = [well_FPDs FPDs];
                    well_slopes = [well_slopes slopes];
                    well_amps = [well_amps amps];
                    well_bps = [well_bps bps];



                    activation_times = electrode_data(electrode_count).ave_activation_time;
                    [br, bc] = size(activation_times);
                    activation_times = reshape(activation_times, [bc br]);
                    activation_times = num2cell([activation_times]);
                    activation_times = vertcat('Activation Time (s)', activation_times);
                    %celldisp(activation_times)

                    [br, bc] = size(amps);
                    amps = reshape(amps, [bc br]);
                    amps = num2cell([amps]);
                    amps = vertcat('Depolarisation Spike Amplitude (V)', amps);
                    %celldisp(amps)

                    [br, bc] = size(slopes);
                    slopes = reshape(slopes, [bc br]);
                    slopes = num2cell([slopes]);
                    slopes = vertcat('Depolarisation slope', slopes);
                    %celldisp(slopes)

                    t_wave_peak_times = electrode_data(electrode_count).ave_t_wave_peak_time;
                    [br, bc] = size(t_wave_peak_times);
                    t_wave_peak_times = reshape(t_wave_peak_times, [bc br]);
                    t_wave_peak_times = num2cell([t_wave_peak_times]);
                    t_wave_peak_times = vertcat('T-wave peak Time (s)', t_wave_peak_times);
                    %celldisp(t_wave_peak_times)

                    %ave_t_wave_peak = electrode_data(electrode_count).average_waveform(find(electrode_data(electrode_count).ave_wave_time == electrode_data(electrode_count).ave_t_wave_peak_time));

                    peak_indx = find(electrode_data(electrode_count).ave_wave_time >= electrode_data(electrode_count).ave_t_wave_peak_time);
                    ave_t_wave_peak = electrode_data(electrode_count).average_waveform(peak_indx(1));


                    t_wave_peak_array = ave_t_wave_peak;
                    [br, bc] = size(t_wave_peak_array);
                    t_wave_peak_array = reshape(t_wave_peak_array, [bc br]);
                    t_wave_peak_array = num2cell([t_wave_peak_array]);
                    t_wave_peak_array = vertcat('T-wave peak (V)', t_wave_peak_array);
                    %celldisp(t_wave_peak_array)

                    [br, bc] = size(FPDs);
                    FPDs = reshape(FPDs, [bc br]);
                    FPDs = num2cell([FPDs]);
                    FPDs = vertcat('FPD (s)', FPDs);
                    %celldisp(FPDs)

                    [br, bc] = size(bps);
                    beat_periods = reshape(bps, [bc br]);
                    beat_periods = num2cell([beat_periods]);
                    beat_periods = vertcat('Beat Period (s)', beat_periods);
                    %celldisp(beat_periods)

                    elec_id_column = repmat({''}, bc, br);
                    %celldisp(elec_id_column)
                    elec_id_column = vertcat(electrode_data(electrode_count).electrode_id, elec_id_column);
                    elec_id_column = elec_id_column;
                    %disp(elec_id_column)
                    %disp(class(elec_id_column))

                    
                    electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods);
                    %electrode_stats = {[elec_id_column] [beat_num_array] [beat_start_times] [activation_times] [amps] [slopes] [t_wave_peak_times] [t_wave_peak_array] [FPDs] [beat_periods] [cycle_length_array]};
                    %electrode_stats = {electrode_stats_header;electrode_stats};

                    electrode_stats = cellstr(electrode_stats);

                    %celldisp(electrode_stats)

                    [er, ec] = size(electrode_stats);


                    % all_data must be a cell array
                    xlswrite(output_filename, electrode_stats, sheet_count);
                end
            end
            well_FPDs = well_FPDs(~isnan(well_FPDs));
            well_slopes = well_slopes(~isnan(well_slopes));
            well_amps = well_amps(~isnan(well_amps));
            well_bps = well_bps(~isnan(well_bps));

            mean_FPD = mean(well_FPDs);
            mean_slope = mean(well_slopes);
            mean_amp = mean(well_amps);
            mean_bp = mean(well_bps);

            headings = {strcat(well_ID,':Well-wide statistics'); 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
            mean_data = [mean_FPD; mean_slope; mean_amp; mean_bp];
            mean_data = num2cell(mean_data);
            mean_data = vertcat({''}, mean_data);
            %celldisp(mean_data);

            well_stats = horzcat(headings, mean_data);
            %well_stats = cellstr(well_stats)

            %celldisp(well_stats)

            xlswrite(output_filename, well_stats, 1);
        end
    end

end