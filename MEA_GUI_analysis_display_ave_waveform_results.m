function MEA_GUI_analysis_display_ave_waveform_results(AllDataRaw, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar, save_dir, reanalysis)


% GENERAL DESIGN
    % Save button in each plot to allow users to save plots to directory of choice (start directory)
    % Close buttons for each pop-up window that doesn't require user interaction
    
    % b2b = 'on'
    
    % display GUI with button for each well and when pressed displays plots for each electrode /
    % heat map button - shows heatmap in new window that can be closed /
    % display well and electrode statistics like mean FPD etc. /
    % if bipolar on = bipolar button to show plots and results /
    
    % b2b = 'off'
    
    % Golden electrode
    % 3 uis for each well - show electrode stable waveforms button, show ave waveforms for each elec button, change GE dropdown /
    % no dropdown nominated = dropdown menu for electrode options for new GE /
    % Accept GE's button /
    % Enter T-wave peak times for all wells and continue button appears along with statistics /
    % Display statistics and GE for each well /
    % heatmap buttons and bipolar buttons on the well panels in this GUI /
    
    % Electrode time region ave waveforms 
    % buttons for each well /
    % well button pressed display all electrodes and t-wave peak time uitexts/
    % Continue button and statistics appear when all entered. /
    % heatmap and bipolar buttons available when each well clicked and shows electrodes ave waveforms /
    
    % TO DO
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
    
    
    % KEY TASKS    
    
    % TEST

    % T-wave inflection point, max, min stored in results. User inputs displayed in file. Heatmap results. Ave electrode results.
    % Summarise maximum actival time. Diff between earliest electrode and latest electrode activation time for each beat. What were the electrodes?
    % Multiple time-regions
    
    %'#B02727' Dark red
    %'#d43d3d' Medium red
    %'#e68e8e' Light red
    %'#3dd483' green
    
    warning ('off', 'all');
       
    shape_data = size(AllDataRaw);
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);

    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    screen_height = screen_height - 100;
    
    %screen_width = 1700;
    %screen_height = 956;
    
    num_wells = length(added_wells);
    num_button_rows = 1;
    num_button_cols = num_wells;
    
    % 1  2  3  4
    % 5  6  7  8
    % 9 10 11 12
    %13 14 15 16
    
    if num_wells/num_well_rows > 1
        % need button rows
        num_button_rows = ceil(num_wells/num_well_cols);
        num_button_cols = num_well_cols;
        
    end   
    
    
    button_panel_width = screen_width-200;
    
    button_width = button_panel_width/num_button_cols;
    button_height = ((screen_height)/num_button_rows)-40;
    
    out_fig = uifigure;
    out_fig.Name = 'MEA Results';
    movegui(out_fig,'center')
    out_fig.WindowState = 'maximized';
    % left bottom width height
    main_p = uipanel(out_fig, 'BackgroundColor', '#e68e8e', 'Position', [0 0 screen_width screen_height]);
    

    if strcmp(stable_ave_analysis, 'time_region')
        close_all_button = uibutton(main_p,'push', 'BackgroundColor', '#B02727', 'Text', 'Close', 'FontColor', 'w', 'Position', [screen_width-180 100 150 50], 'ButtonPushedFcn', @(close_all_button,event) closeAllButtonPushed(close_all_button, out_fig));
        save_all_button = uibutton(main_p,'push', 'BackgroundColor', '#3dd4d1', 'Text', "Save All Data", 'FontColor', 'w', 'Tooltip', "Save All To"+ " " + save_dir, 'Position', [screen_width-180 200 150 50], 'ButtonPushedFcn', @(save_all_button,event) saveAllTimeRegionButtonPushed(save_all_button, out_fig, save_dir, num_electrode_rows, num_electrode_cols, 1));

        % Display Finalised Results
        % Shows all ave electrodes analysed and also statistics 


    end
        
    
    main_pan = uipanel(main_p, 'BackgroundColor', '#e68e8e', 'Title', 'Review Well Results', 'Position', [0 0 button_panel_width screen_height-40]);
    
    %global electrode_data;
    %dropdown_array = [];
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
               button_panel = uipanel(main_pan, 'BackgroundColor', '#d43d3d', 'Position', [((c-1)*button_width) ((r-1)*button_height) button_width button_height]);
             
               well_button = uibutton(button_panel,  'push', 'BackgroundColor', '#d43d3d', 'FontSize', 20, 'Text', wellID, 'FontColor', 'w', 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, button_count, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));
               
               button_count = button_count + 1;
           end
           if stop_add == 1
               break;
           end
        end
    else
        
        if num_wells ~= 1
            for b = 1:num_wells
                wellID = added_wells(b);
                button_panel = uipanel(main_pan, 'BackgroundColor', '#d43d3d', 'Position', [((b-1)*button_width) 0 button_width button_height]);

                well_button = uibutton(button_panel,'push', 'BackgroundColor', '#d43d3d', 'FontSize', 20, 'Text', wellID, 'FontColor', 'w', 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, b, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));

            end
        else
            %button_panel = uipanel(main_pan, 'BackgroundColor', '#d43d3d', 'Position', [(button_width) 0 button_width button_height]);

            wellID = added_wells(1);
            %well_button = uibutton(button_panel,'push', 'BackgroundColor', '#d43d3d', 'Text', wellID, 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, b, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));

            set(out_fig, 'Visible', 'off')
            pause(0.01)
            
            wellButtonPushed('', added_wells, 1, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig)
        end
    end
    
    function wellButtonPushed(well_button, added_wells, well_count, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig)
        
        if num_wells ~= 1
            set(out_fig, 'Visible', 'off')
            set(well_button, 'BackgroundColor', '#3dd483');
            well_ID = get(well_button, 'Text');
            close_button_title = 'Back';
        else
            well_ID = wellID;
            set(out_fig, 'Visible', 'off')
            close(out_fig)
            close_button_title = 'Close';
        end
        
        %'#B02727' Dark red
        %'#d43d3d' Medium red
        %'#e68e8e' Light red
        %'#3dd483' green

        
        well_elec_fig = uifigure;
        well_elec_fig.Name = strcat(well_ID, '_', 'Electrode Results');
        well_elec_fig.Position = [100, 100, screen_width, screen_height];
        movegui(well_elec_fig,'center')
        well_elec_fig.WindowState = 'maximized';
        well_elec_fig.AutoResizeChildren = 'off';
        
        main_well_pan = uipanel(well_elec_fig, 'BackgroundColor', '#fbeaea', 'Position', [0 0 screen_width screen_height]);
        
        well_p_width = screen_width-300;
        well_p_height = screen_height;
        well_pan = uipanel(main_well_pan, 'BackgroundColor', '#fbeaea', 'Position', [0 0 well_p_width well_p_height]);
        
        %close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed(close_button, well_elec_fig, out_fig));
        

        close_y = 10;
            
        
        
        if num_wells == 1
     
            results_close_button = uibutton(main_well_pan,'push', 'FontColor', 'w', 'BackgroundColor', '#B02727', 'Text', close_button_title, 'Position', [screen_width-210 close_y 120 30], 'ButtonPushedFcn', @(results_close_button,event) closeAllButtonPushed(results_close_button, well_elec_fig));
            
        else
            results_close_button = uibutton(main_well_pan,'push', 'FontColor', 'w', 'BackgroundColor', '#B02727', 'Text', close_button_title, 'Position', [screen_width-210 close_y 120 30], 'ButtonPushedFcn', @(results_close_button,event) closeResultsButtonPushed(results_close_button, well_elec_fig, out_fig, well_button));
            
   
        end
        
        %info_button = uibutton(main_well_pan,'push','Text', 'Information', 'Position', [screen_width-220 650 120 50], 'ButtonPushedFcn', @(legend_button,event) infoButtonPushed(info_button, beat_to_beat, stable_ave_analysis, bipolar, spon_paced));

        if strcmp(stable_ave_analysis, 'time_region')
            %reanalyse_button = uibutton(main_well_pan,'push','Text', 'Re-analyse well', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, 'ave'));
            %display_final_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd483', 'Text', 'Accept Analysis', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(display_final_button,event) displayFinalTimeRegionButtonPushed(display_final_button, out_fig, well_elec_fig, well_button));

            save_results_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd4d1',  'FontColor', 'k', 'Text', 'Save Results', 'Tooltip', strcat('Save Data to', {' '}, save_dir),'Position', [screen_width-200 440 100 30], 'ButtonPushedFcn', @(save_results_button,event) saveAveTimeRegionPushed(save_results_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, 0, 0));

            %save_plots_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd4d1', 'Text', 'Save Plots', 'Position', [screen_width-200 300 100 50], 'ButtonPushedFcn', @(save_plots_button,event) saveAveTimeRegionPlotsPushed(save_plots_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols));

            %save_alldata_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd4d1', 'Text', 'Save All Data', 'Position', [screen_width-100 300 100 50], 'ButtonPushedFcn', @(save_alldata_button,event) saveAveTimeRegionPushed(save_alldata_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, 1, 0));

            %set(display_final_button, 'Visible', 'off')

            feature_panel = uipanel(main_well_pan, 'ForegroundColor', 'k', 'Position', [screen_width-300 60 300 360]);


            conduction_pan = uipanel(feature_panel, 'ForegroundColor', 'k', 'Title', 'Conduction Assessments', 'Position', [0 310 300 50]);

            heat_map_button = uibutton(conduction_pan,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', well_ID+ " " + "Conduction Map", 'Position', [30 0 120 30], 'ButtonPushedFcn', @(heat_map_button,event) aveHeatMapButtonPushed(heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, 'depol'));


            FPD_heat_map_button = uibutton(conduction_pan,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', well_ID+ " " + "FPD Map", 'Position', [150 0 120 30], 'ButtonPushedFcn', @(FPD_heat_map_button,event) aveHeatMapButtonPushed(FPD_heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, 'fpd'));


            reanalyse_panel = uipanel(feature_panel, 'ForegroundColor', 'k', 'Title', 'Reanalysis Options', 'Position', [0 0 300 110]);

            reanalyse_background_beats_button = uibutton(reanalyse_panel,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', 'Re-analyse All Background Traces', 'Position', [25 60 250 30], 'ButtonPushedFcn', @(reanalyse_background_beats_button,event) reanalyseWellButtonPushed(reanalyse_background_beats_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));

            reanalyse_selected_electrodes_button = uibutton(reanalyse_panel,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2','Text', 'Re-analyse Selected Electrode Ave Waves', 'Position', [25 30 250 30], 'ButtonPushedFcn', @(reanalyse_selected_electrodes_button,event) reanalyseSelectedElectrodesButtonPushed(reanalyse_selected_electrodes_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));

            reanalyse_well_button = uibutton(reanalyse_panel,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', 'Re-analyse All Ave Waves', 'Position', [25 0 250 30], 'ButtonPushedFcn', @(reanalyse_well_button,event) reanalyseTimeRegionWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));

            %auto_t_wave_button = uibutton(main_well_pan,'push','Text', 'Auto T-Wave Peak Search', 'Position', [screen_width-220 400 120 50], 'ButtonPushedFcn', @(auto_t_wave_button,event) autoTwavePeakButtonPushed(auto_t_wave_button, out_fig, well_elec_fig, well_button));

            overlaid_plots_button = uibutton(feature_panel,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', 'View Overlaid Plots', 'Position', [80 130 120 30], 'ButtonPushedFcn', @(overlaid_plots_button,event) viewOverlaidPlotsPushed(overlaid_plots_button, well_count));


            complex_panel_y = 180;
        end
        
        zoom_panel = uipanel(feature_panel, 'ForegroundColor', 'k', 'Title', 'Check Complexes', 'Position', [0 complex_panel_y 300 110]);
            
        
        depol_zoom_button = uibutton(zoom_panel,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', 'Expand Depol. Complexes', 'Position', [75 0 150 30], 'ButtonPushedFcn', @(depol_zoom_button,event) depolZoomButtonPushed(depol_zoom_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
        repol_zoom_button = uibutton(zoom_panel,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', 'Expand Repol. Complexes', 'Position', [75 30 150 30], 'ButtonPushedFcn', @(repol_zoom_button,event) repolZoomButtonPushed(repol_zoom_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
        restore_full_beat_button = uibutton(zoom_panel,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', 'Restore Full Beat', 'Position', [75 60 150 30], 'ButtonPushedFcn', @(restore_full_beat_button,event) restoreBeatButtonPushed(restore_full_beat_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        set(restore_full_beat_button, 'visible', 'off')
        
        electrode_count = 0;
        all_t_waves = 1;
        elec_ids = [well_electrode_data(well_count).electrode_data(:).electrode_id];
        for elec_r = num_electrode_rows:-1:1
            for elec_c = 1:num_electrode_cols
                %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                if isempty (elec_indx)
                    continue
                end
                electrode_count = elec_indx;
                
                %electrode_data(electrode_count).rejected = 0;
                %well_electrode_data(well_count, electrode_count).rejected = 0;
                
                if reanalysis == 0
                    well_electrode_data(well_count).electrode_data(electrode_count).rejected = 0;
                else
                    %{
                    if well_electrode_data(well_count).electrode_data(electrode_count).rejected == 1
                       continue
                    end
                    %}
                    
                end
                

                if strcmp(stable_ave_analysis, 'time_region') 

                    % Need T-wave input panels
                    if isempty(well_electrode_data(well_count).electrode_data(electrode_count).electrode_id)
                       continue 
                    end



                    elec_pan = uipanel(well_pan, 'ForegroundColor', 'k',   'BackgroundColor', '#f2c2c2', 'Title', well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);

                    undo_elec_pan = uipanel(well_pan, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);

                    undo_reject_electrode_button = uibutton(undo_elec_pan,'push', 'BackgroundColor', '#B02727', 'Text', 'Undo Reject Electrode', 'Position', [0 0 well_p_width/num_electrode_cols well_p_height/num_electrode_rows], 'ButtonPushedFcn', @(reject_electrode_button,event) undoRejectElectrodeButtonPushed(elec_pan, undo_elec_pan, electrode_count));

                    set(undo_elec_pan, 'Visible', 'off');

                    elec_ax = uiaxes(elec_pan, 'Position', [15 40 (well_p_width/num_electrode_cols)-30 (well_p_height/num_electrode_rows)-60]);

                    reject_electrode_button = uibutton(elec_pan,'push','FontColor', 'w','Text', 'Reject Electrode', 'BackgroundColor', '#B02727', 'Tooltip', 'Reject Electrode', 'Position', [0 20 ((well_p_width/num_electrode_cols))/3 20], 'ButtonPushedFcn', @(reject_electrode_button,event) rejectElectrodeButtonPushed(reject_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count, undo_elec_pan));

                    adv_stats_elec_button = uibutton(elec_pan,'push', 'BackgroundColor', '#bc2929', 'FontColor', 'w', 'Text', 'Advanced Results View', 'Tooltip', 'View expanded signal with statistics+inputs and B2B analysis results used to produce average signal', 'Position', [((well_p_width/num_electrode_cols))/3 20 ((well_p_width/num_electrode_cols))/3 20], 'ButtonPushedFcn', @(adv_stats_elec_button,event) expandAveTimeRegionElectrodePushed2(adv_stats_elec_button, electrode_count));

                    %expand_background_signals_button = uibutton(elec_pan,'push', 'BackgroundColor', '#d12e2e', 'FontColor', 'w', 'Text', 'Expand Background Beats', 'Tooltip', 'View B2B analysis results used to produce average signal', 'Position', [2*((well_p_width/num_electrode_cols))/4 20 ((well_p_width/num_electrode_cols))/4 20], 'ButtonPushedFcn', @(expand_background_signals_button,event) expandAllTimeRegionDataButtonPushed(expand_background_signals_button, num_electrode_rows, num_electrode_cols, elec_pan, well_count, electrode_count));

                    reanalyse_electrode_button = uibutton(elec_pan,'push', 'BackgroundColor', '#d12e2e', 'FontColor', 'w', 'Text', 'Reanalyse', 'Tooltip', 'Reanalyse averaged signal', 'Position', [2*(((well_p_width/num_electrode_cols))/3) 20 ((well_p_width/num_electrode_cols))/3 20], 'ButtonPushedFcn', @(reanalyse_electrode_button,event) reanalyseTimeRegionElectrodeButtonPushed(well_count, elec_id));

                    t_wave_time_text = uieditfield(elec_pan,'Text', 'Value', 'T-wave Peak Time', 'FontSize', 8, 'Position', [0 0 ((well_p_width/num_electrode_cols))/2 20], 'Editable','off');
                    t_wave_time_ui = uieditfield(elec_pan, 'numeric', 'Tag', 'T-Wave', 'Position', [((well_p_width/num_electrode_cols))/2 0 ((well_p_width/num_electrode_cols))/2 20], 'FontSize', 8, 'ValueChangedFcn',@(t_wave_time_ui,event) changeTWaveTime(t_wave_time_ui, elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time, well_electrode_data(well_count).electrode_data(electrode_count).average_waveform, electrode_count, well_pan));

                    set(t_wave_time_text, 'Visible', 'off');
                    set(t_wave_time_ui, 'Visible', 'off');

                    manual_t_wave_button = uibutton(elec_pan,'push','Text', 'Manual T-Wave Peak Input', 'BackgroundColor', '#d64343', 'FontColor', 'w', 'Position', [0 0 ((well_p_width/num_electrode_cols)-25)/2 20], 'ButtonPushedFcn', @(manual_t_wave_button,event) manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui));

                    if isempty(well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time)
                        %set()

                       continue 


                    end



                    hold(elec_ax,'on')
                    plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time, well_electrode_data(well_count).electrode_data(electrode_count).average_waveform);
                    plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).filtered_ave_wave_time, well_electrode_data(well_count).electrode_data(electrode_count).filtered_average_waveform);
                    %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                    plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_time, well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_point, 'r.', 'MarkerSize', 20);
                    plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_time, well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_point, 'b.', 'MarkerSize', 20);


                    plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time, well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_point, 'k.', 'MarkerSize', 20);

                    if well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time ~= 0 
                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time, well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak, 'c.', 'MarkerSize', 20);
                    end
                    hold(elec_ax,'off')


                end
            end  
        end
        
        
        function changeTWaveTime(t_wave_time_ui, elec_ax, time, data, electrode_count, well_pan)
            electrode_data = well_electrode_data(well_count).electrode_data;
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
            
            time = electrode_data(electrode_count).ave_wave_time;
            data = electrode_data(electrode_count).average_waveform;

            peak_indx = find(time >= get(t_wave_time_ui, 'Value'));
            if isempty(peak_indx)
               return 
            end
            peak_indx = peak_indx(1);
            t_wave_peak = data(peak_indx);
            if found_plot == 0
                hold(elec_ax, 'on')

                plot(elec_ax, get(t_wave_time_ui, 'Value'), t_wave_peak, 'c.', 'MarkerSize', 20);
                hold(elec_ax, 'off')

            else
                t_wave_plot.XData = get(t_wave_time_ui, 'Value');
                t_wave_plot.YData = t_wave_peak;
            end
            %well_electrode_data(well_count, electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
            well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
            well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak = t_wave_peak;
            %electrode_data(electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');

            
        end
        
        function rejectElectrodeButtonPushed(reject_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count, undo_elec_pan)
            
            %electrode_data(electrode_count).rejected = 1;
            %well_electrode_data(well_count,electrode_count).rejected = 1;

            well_electrode_data(well_count).electrode_data(electrode_count).rejected = 1;
            
            if strcmp(well_electrode_data(well_count).spon_paced, 'spon')
                [well_electrode_data(well_count).conduction_velocity, well_electrode_data(well_count).conduction_velocity_model] = calculateSpontaneousConductionVelocity(wellID, well_electrode_data(well_count).electrode_data,  num_electrode_rows, num_electrode_cols, nan);
            
            else
                %[well_electrode_data(well_count).conduction_velocity, well_electrode_data(well_count).conduction_velocity_model] = calculatePacedConductionVelocity(wellID, well_electrode_data(well_count).electrode_data,  num_electrode_rows, num_electrode_cols, nan);
                [well_electrode_data(well_count).conduction_velocity, well_electrode_data(well_count).conduction_velocity_model] = calculateSpontaneousConductionVelocity(wellID, well_electrode_data(well_count).electrode_data,  num_electrode_rows, num_electrode_cols, nan);
            
            end
            
            set(elec_pan, 'Visible', 'off');
            set(undo_elec_pan, 'Visible', 'on'); 
        end
        
        function undoRejectElectrodeButtonPushed(elec_pan, undo_elec_pan, electrode_count)
            %electrode_data(electrode_count).rejected = 0;
            %well_electrode_data(well_count,electrode_count).rejected = 0;
            well_electrode_data(well_count).electrode_data(electrode_count).rejected = 0;
            
            if strcmp(well_electrode_data(well_count).spon_paced, 'spon')
                [well_electrode_data(well_count).conduction_velocity, well_electrode_data(well_count).conduction_velocity_model] = calculateSpontaneousConductionVelocity(wellID, well_electrode_data(well_count).electrode_data,  num_electrode_rows, num_electrode_cols, nan);
            
            else
                %[well_electrode_data(well_count).conduction_velocity, well_electrode_data(well_count).conduction_velocity_model] = calculatePacedConductionVelocity(wellID, well_electrode_data(well_count).electrode_data,  num_electrode_rows, num_electrode_cols, nan);
                [well_electrode_data(well_count).conduction_velocity, well_electrode_data(well_count).conduction_velocity_model] = calculateSpontaneousConductionVelocity(wellID, well_electrode_data(well_count).electrode_data,  num_electrode_rows, num_electrode_cols, nan);
            
            end
            set(elec_pan, 'Visible', 'on');
            set(undo_elec_pan, 'Visible', 'off'); 
            
            
        end
        
        
        function expandAveTimeRegionElectrodePushed2(adv_stats_elec_button, electrode_count)
            %%disp(electrode_data.electrode_id)

            electrode_data = well_electrode_data(well_count).electrode_data(electrode_count);
            adv_elec_fig = uifigure;
            movegui(adv_elec_fig,'center')
            %adv_elec_fig.WindowState = 'maximized';
            adv_elec_fig.Name = strcat(electrode_data.electrode_id, '_', 'Advanced Statistics');
            adv_elec_fig.Position = [100, 100, screen_width, screen_height];
            % left bottom width height
            
            expand_elec_tabs = uitabgroup(adv_elec_fig,  'Position', [0 0 screen_width screen_height]);
            

            adv_elec_panel = uitab(expand_elec_tabs, 'Title', 'Annotated Ave Trace', 'BackgroundColor', '#f2c2c2');
            %adv_elec_panel = uipanel(adv_elec_fig, 'BackgroundColor', '#e68e8e', 'Position', [0 0 screen_width screen_height]);

            adv_elec_p = uipanel(adv_elec_panel, 'BackgroundColor', '#f2c2c2', 'Position', [0 0 well_p_width well_p_height]);

            
            if ~strcmp(spon_paced, 'spon')

                text_box_height = screen_height/12;

            else
                text_box_height = screen_height/11;

            end
            adv_close_button = uibutton(adv_elec_panel,'push','Text', 'Close', 'Position', [screen_width-210 text_box_height*0 120 text_box_height], 'ButtonPushedFcn', @(adv_close_button,event) closeSingleFig(adv_close_button, adv_elec_fig));

            adv_ax = uiaxes(adv_elec_p,  'Position', [30 30 well_p_width-60 well_p_height-60]);
            

            %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
            %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
            MEA_GUI_display_ave_waveform(well_electrode_data(well_count).electrode_data, electrode_count, adv_elec_panel, adv_ax)
            
            % TAB 2
            expand_elec_panel = uitab(expand_elec_tabs, 'Title', 'Annotated B2B Trace', 'BackgroundColor', '#f2c2c2');
            %expand_elec_panel = uipanel(expand_elec_fig, 'BackgroundColor', '#e68e8e', 'Position', [0 0 screen_width screen_height]);
                
            expand_elec_p = uipanel(expand_elec_panel, 'BackgroundColor', '#f2c2c2', 'Position', [0 0 well_p_width well_p_height]);

            electrode_data = well_electrode_data(well_count).electrode_data;
            
            exp_ax = uiaxes(expand_elec_p, 'Position', [30 30 well_p_width-60 well_p_height-60]);
            
            MEA_GUI_display_ave_waveform_background_B2B_analysis(well_electrode_data(well_count).electrode_data, electrode_count, expand_elec_panel, exp_ax)
            
            expand_close_button = uibutton(expand_elec_panel,'push','Text', 'Close', 'Position', [screen_width-210 0 120 text_box_height], 'ButtonPushedFcn', @(expand_close_button,event) closeSingleFig(expand_close_button, adv_elec_fig));

            
            
            reanalyse_background_button = uibutton(expand_elec_panel,'push','Text', 'Reanalyse All Data', 'BackgroundColor', '#3dd4d1', 'Position', [screen_width-210 text_box_height*2 120 text_box_height], 'ButtonPushedFcn', @(reanalyse_background_button,event) reanalyseElectrodeButtonPushed(well_count, electrode_data(electrode_count).electrode_id, exp_ax, adv_ax, expand_elec_panel, adv_elec_panel));
               
                
        end
        
        
         
        function depolZoomButtonPushed(depol_zoom_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            well_panel_children = get(well_pan, 'Children');
            
            
            axes_array = [];
            electrode_count = 0;
            electrode_ids = [well_electrode_data(well_count).electrode_data(:).electrode_id];
            
            for el_r = num_electrode_rows:-1:1
                for el_c = 1:num_electrode_cols
                    %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                    elec_id = strcat(well_ID, '_', num2str(el_c), '_', num2str(el_r));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    
                    if isempty (elec_indx)
                        continue
                    end
                    
                    electrode_count = elec_indx;

                    if well_electrode_data(well_count).electrode_data(electrode_count).rejected == 1
                        
                       continue 
                    end
                    %electrode_count = electrode_count+1;

                    if isempty(well_electrode_data(well_count).electrode_data(electrode_count))
                        continue
                        
                    end
                    
                    if strcmp(beat_to_beat, 'on')
                        if isempty(well_electrode_data(well_count).electrode_data(electrode_count).time)
                        
                            continue
                        end
                    else
                        if isempty(well_electrode_data(well_count).electrode_data(electrode_count).average_waveform)
                        
                            continue
                        end
                        
                    end

                    for well_panel_child = 1:length(well_panel_children)
                        
                        if isempty(well_panel_children(well_panel_child))
                           continue 
                        end

                        if strcmp(get(well_panel_children(well_panel_child), 'Title'), elec_id)
                            
                            if strcmp(spon_paced, 'paced')
                                num_beats = length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
                            elseif strcmp(spon_paced, 'spon')

                                num_beats = length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
                            elseif strcmp(spon_paced, 'paced bdt')
                                %num_beats = length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
                                ectopic_plus_stims = [well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times well_electrode_data(well_count).electrode_data(electrode_count).Stims];
                                ectopic_plus_stims = sort(ectopic_plus_stims);
                                ectopic_plus_stims = uniquetol(ectopic_plus_stims);
                                num_beats = length(ectopic_plus_stims);
                            end

                            if num_beats > 4    

                                mid_beat = floor(num_beats/2);
                                
                            else
                               continue; 
                            end

                            electrode_panel_children = get(well_panel_children(well_panel_child), 'Children');

                            for elec_panel_child = 1:length(electrode_panel_children)

                                if strcmp(string(get(electrode_panel_children(elec_panel_child), 'Type')), 'axes')
                                    %disp(electrode_panel_children(elec_panel_child))
                                    % Change the view of the panel
                                    
                                    axes_children = get(electrode_panel_children(elec_panel_child), 'children');
                                    
                                    %{
                                    if well_electrode_data(well_count).electrode_data(electrode_count).bdt < 0
                                        post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off*2;
                                    
                                    else
                                        beat_warning = well_electrode_data(well_count).electrode_data(electrode_count).warning_array{mid_beat};
                                        if ~isempty(beat_warning)
                                            beat_warning = beat_warning{1};
                                        end

                                        if contains(beat_warning, 'Reanalysed')
                                            split_one = strsplit(beat_warning, 'BDT=');
                                            split_two = strsplit(split_one{1, 2}, ',');
                                            reanalysed_bdt = str2num(split_two{1});

                                            if reanalysed_bdt < 0
                                               postspike_tag = split_two{2};
                                               split_postspike = strsplit(postspike_tag, '=');
                                               re_analysed_post_spike = str2num(split_postspike{2});
                                               post_spike_hold_off = 2*re_analysed_post_spike;
                                               
                                            else
                                                post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off;
                                            end
                                        else
                                            post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off;
                                        end
                                    end
                                    %}
                                    
                                    if strcmp(beat_to_beat, 'on')
                                        beat_warning = well_electrode_data(well_count).electrode_data(electrode_count).warning_array{mid_beat};
                                        %{
                                        if ~isempty(beat_warning)
                                            beat_warning = beat_warning{1};
                                        end
                                        %}

                                        if contains(beat_warning, 'Reanalysed')
                                            split_one = strsplit(beat_warning, 'BDT=');
                                            split_two = strsplit(split_one{1, 2}, ',');
                                            reanalysed_bdt = str2num(split_two{1});

                                            if reanalysed_bdt < 0
                                               postspike_tag = split_two{2};
                                               split_postspike = strsplit(postspike_tag, '=');
                                               re_analysed_post_spike = str2num(split_postspike{2});
                                               post_spike_hold_off = 2*re_analysed_post_spike;

                                            else
                                                post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off*2;
                                                if isnan(post_spike_hold_off)
                                                    post_spike_hold_off = 0;
                                                end
                                            end
                                        else
                                            post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off*2;
                                            if isnan(post_spike_hold_off)
                                                post_spike_hold_off = 0;
                                            end
                                        end
                                    else
                                        post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_post_spike_hold_off;
                                        if isnan(post_spike_hold_off)
                                            post_spike_hold_off = 0;
                                        end
                                    end
                                    full_beat_x = [];
                                    for plot_child = 1:length(axes_children)
                                        x_data = axes_children(plot_child).XData;
                                        
                                        if length(x_data) > 1
                                            if isempty(full_beat_x)
                                                full_beat_x = x_data;
                                            else
                                                if length(full_beat_x) < length(x_data)
                                                    full_beat_x = x_data;
                                                end
                                                
                                                %break;
                                            end
                                        end
                                    end
                                    if ~isempty(full_beat_x)
                                        if full_beat_x(1)~= full_beat_x(1)+post_spike_hold_off
                                            set(electrode_panel_children(elec_panel_child), 'xlim', [full_beat_x(1) full_beat_x(1)+post_spike_hold_off])
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            %disp(axes_array)
            
            set(restore_full_beat_button, 'visible', 'on')
            
        end
        
        
        function repolZoomButtonPushed(repol_zoom_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            well_panel_children = get(well_pan, 'Children');
            
            axes_array = [];
            electrode_count = 0;
            electrode_ids = [well_electrode_data(well_count).electrode_data(:).electrode_id];
            
            for el_r = num_electrode_rows:-1:1
                for el_c = 1:num_electrode_cols
                    %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                    elec_id = strcat(well_ID, '_', num2str(el_c), '_', num2str(el_r));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    
                    if isempty (elec_indx)
                        continue
                    end
                    
                    electrode_count = elec_indx;

                    if well_electrode_data(well_count).electrode_data(electrode_count).rejected == 1
                        
                       continue 
                    end
                    
                    
                    %electrode_count = electrode_count+1;

                    if isempty(well_electrode_data(well_count).electrode_data(electrode_count))
                        continue
                        
                    end
                    
                    if strcmp(beat_to_beat, 'on')
                        if isempty(well_electrode_data(well_count).electrode_data(electrode_count).time)
                        
                            continue
                        end
                    else
                        if isempty(well_electrode_data(well_count).electrode_data(electrode_count).average_waveform)
                        
                            continue
                        end
                        
                    end
                    

                    for well_panel_child = 1:length(well_panel_children)
                        
                        if isempty(well_panel_children(well_panel_child))
                           continue 
                        end

                        if strcmp(get(well_panel_children(well_panel_child), 'Title'), elec_id)
                            
                            electrode_panel_children = get(well_panel_children(well_panel_child), 'Children');

                            for elec_panel_child = 1:length(electrode_panel_children)

                                if strcmp(string(get(electrode_panel_children(elec_panel_child), 'Type')), 'axes')
                                    %disp(electrode_panel_children(elec_panel_child))
                                    % Change the view of the panel
                                    
                                    axes_children = get(electrode_panel_children(elec_panel_child), 'children');
                                    if strcmp(beat_to_beat, 'on')
                                        post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off;
                                        t_wave_duration = well_electrode_data(well_count).electrode_data(electrode_count).t_wave_duration;
                                        
                                    else
                                        post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_post_spike_hold_off;
                                        t_wave_duration = well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_t_wave_duration;
                                        
                                    end
                                    
                                    full_beat_x = [];
                                    for plot_child = 1:length(axes_children)
                                        x_data = axes_children(plot_child).XData;
                                        
                                        if length(x_data) > 1
                                            if isempty(full_beat_x)
                                                full_beat_x = x_data;
                                            else
                                                if length(full_beat_x) < length(x_data)
                                                    full_beat_x = x_data;
                                                end
                                                
                                                %break;
                                            end
                                        end
                                    end
                                    if ~isempty(full_beat_x)
                                        axis_time_start = full_beat_x(1);

                                        for plot_child = 1:length(axes_children)
                                            x_data = axes_children(plot_child).XData;
                                            if length(x_data) == 1
                                                if x_data > axis_time_start+post_spike_hold_off
                                                    set(electrode_panel_children(elec_panel_child), 'xlim', [x_data-(t_wave_duration/2) x_data+(t_wave_duration/2)])

                                                end
                                                %set(electrode_panel_children(elec_panel_child), 'xlim', [x_data(1) x_data(1)+post_spike_hold_off])
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            set(restore_full_beat_button, 'visible', 'on')
            
        end
        
        function restoreBeatButtonPushed(restore_full_beat_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
           well_panel_children = get(well_pan, 'Children');
            
            axes_array = [];
            electrode_count = 0;
            electrode_ids = [well_electrode_data(well_count).electrode_data(:).electrode_id];
            
            for el_r = num_electrode_rows:-1:1
                for el_c = 1:num_electrode_cols
                    %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                    elec_id = strcat(well_ID, '_', num2str(el_c), '_', num2str(el_r));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    
                    if isempty (elec_indx)
                        continue
                    end
                    
                    electrode_count = elec_indx;

                    if well_electrode_data(well_count).electrode_data(electrode_count).rejected == 1
                        
                       continue 
                    end
                    %electrode_count = electrode_count+1;

                    if isempty(well_electrode_data(well_count).electrode_data(electrode_count))
                        continue
                        
                    end
                    
                    if strcmp(beat_to_beat, 'on')
                        if isempty(well_electrode_data(well_count).electrode_data(electrode_count).time)
                        
                            continue
                        end
                    else
                        if isempty(well_electrode_data(well_count).electrode_data(electrode_count).average_waveform)
                        
                            continue
                        end
                        
                    end

                    for well_panel_child = 1:length(well_panel_children)
                        
                        if isempty(well_panel_children(well_panel_child))
                           continue 
                        end

                        if strcmp(get(well_panel_children(well_panel_child), 'Title'), elec_id)
                            
                            electrode_panel_children = get(well_panel_children(well_panel_child), 'Children');

                            for elec_panel_child = 1:length(electrode_panel_children)

                                if strcmp(string(get(electrode_panel_children(elec_panel_child), 'Type')), 'axes')
                                    %disp(electrode_panel_children(elec_panel_child))
                                    % Change the view of the panel
                                    
                                    axes_children = get(electrode_panel_children(elec_panel_child), 'children');
 
                                    full_beat_x = [];
                                    for plot_child = 1:length(axes_children)
                                        x_data = axes_children(plot_child).XData;
                                        
                                        if length(x_data) > 1
                                            if isempty(full_beat_x)
                                                full_beat_x = x_data;
                                            else
                                                if length(full_beat_x) < length(x_data)
                                                    full_beat_x = x_data;
                                                end
                                                
                                                %break;
                                            end
                                        end
                                    end
                                    
                                    if ~isempty(full_beat_x)
                                        set(electrode_panel_children(elec_panel_child), 'xlim', [full_beat_x(1) full_beat_x(end)])
                                    end
                                    
                                end
                            end
                        end
                    end
                end
            end
            set(restore_full_beat_button, 'visible', 'off')
        end
        
       
            
        function reanalyseWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            set(well_elec_fig, 'Visible', 'off')
            %[well_electrode_data(well_count, :)] = reanalyse_b2b_well_analysis(electrode_data, num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID);
            [well_electrode_data(well_count)] = reanalyse_b2b_well_analysis(well_electrode_data(well_count), num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, [], [], [], spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID, ['all']);
            
            %electrode_data = well_electrode_data(well_count).electrode_data;
        end
        
        function reanalyseTimeRegionWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            set(well_elec_fig, 'Visible', 'off')
            [well_electrode_data(well_count).electrode_data] = reanalyse_time_region_well(well_electrode_data(well_count).electrode_data, num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, [], [], spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID, ['all']);
            
            %electrode_data = well_electrode_data(well_count).electrode_data;
        end
        
        function reanalyseElectrodeButtonPushed(well_count, elec_id, exp_ax, adv_ax, expand_elec_panel, adv_elec_panel)
            
            [well_electrode_data(well_count)] = electrode_analysis(well_electrode_data(well_count), num_electrode_rows, num_electrode_cols, elec_id, well_elec_fig, well_pan, exp_ax, expand_elec_panel, [], [], [], spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, adv_ax, adv_elec_panel);
                
        end
        
        function reanalyseSelectedElectrodesButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            set(well_elec_fig, 'Visible', 'off')

            reanalyse_fig = uifigure;
            movegui(reanalyse_fig,'center')
            reanalyse_fig.WindowState = 'maximized';
            reanalyse_pan = uipanel(reanalyse_fig, 'Position', [0 0 screen_width screen_height]);
            submit_reanalyse_button = uibutton(reanalyse_pan, 'push','Text', 'Submit Electrodes', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(submit_reanalyse_button,event) submitReanalyseButtonPushed(submit_reanalyse_button, well_elec_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));

            reanalyse_width = screen_width-300;
            reanalyse_height = screen_height -100;
            ra_pan = uipanel(reanalyse_pan, 'Position', [0 0 reanalyse_width reanalyse_height]);

            elec_count = 0;

            reanalyse_electrodes = [];
            elec_ids = [well_electrode_data(well_count).electrode_data(:).electrode_id];
            
            for el_r = num_electrode_rows:-1:1
                for el_c = 1:num_electrode_cols
                    %elec_id = strcat(well_ID, '_', num2str(el_r), '_', num2str(el_c));
                    elec_id = strcat(well_ID, '_', num2str(el_c), '_', num2str(el_r));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    elec_count = elec_indx;
                    if isempty(well_electrode_data(well_count).electrode_data(elec_count))
                        continue;
                    end
                    if isempty(well_electrode_data(well_count).electrode_data(elec_count).electrode_id)
                        continue;
                    end
                    if well_electrode_data(well_count).electrode_data(elec_count).rejected == 1
                        continue;
                    end
                    %elec_count = elec_count+1;
                    ra_elec_pan = uipanel(ra_pan, 'Title', well_electrode_data(well_count).electrode_data(elec_count).electrode_id, 'Position', [(el_c-1)*(reanalyse_width/num_electrode_cols) (el_r-1)*(reanalyse_height/num_electrode_rows) reanalyse_width/num_electrode_cols reanalyse_height/num_electrode_rows]);
                    
                    ra_elec_ax = uiaxes(ra_elec_pan, 'Position', [0 20 (well_p_width/num_electrode_cols)-25 (well_p_height/num_electrode_rows)-50]);
                    
                    
                    MEA_GUI_display_B2B_electrodes(well_electrode_data(well_count).electrode_data, elec_count, ra_elec_ax)
                    
                    ra_elec_button = uibutton(ra_elec_pan, 'push','Text', 'Reanalyse', 'BackgroundColor','#e68e8e', 'Position', [0 0 reanalyse_width/num_electrode_cols 20], 'ButtonPushedFcn', @(ra_elec_button,event) reanalyseElectrodeButtonPushed(ra_elec_button, well_electrode_data(well_count).electrode_data(elec_count).electrode_id));
                    

                end
            end

            function reanalyseElectrodeButtonPushed(ra_elec_button, electrode_id)
                
                if strcmp(get(ra_elec_button, 'Text'), 'Reanalyse')
                    set(ra_elec_button, 'Text', 'Undo');
                    set(ra_elec_button, 'BackgroundColor','#B02727');
                    reanalyse_electrodes = [reanalyse_electrodes; electrode_id];
                elseif strcmp(get(ra_elec_button, 'Text'), 'Undo')
                    set(ra_elec_button, 'Text', 'Reanalyse');
                    set(ra_elec_button, 'BackgroundColor','#e68e8e');
                    reanalyse_electrodes = reanalyse_electrodes(~contains(reanalyse_electrodes, electrode_id));
                end
            end
            
            

            function submitReanalyseButtonPushed(submit_reanalyse_button, well_elec_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
                %set(reanalyse_fig, 'Visible', 'off')
                delete(submit_reanalyse_button);
                close(reanalyse_fig);
                if isempty(well_electrode_data(well_count).electrode_data)
                   return; 
                end
                
                if strcmp(beat_to_beat, 'on')
                    %[well_electrode_data(well_count).electrode_data] = electrode_analysis(well_electrode_data(well_count), num_electrode_rows, num_electrode_cols, reanalyse_electrodes, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis);
                    [well_electrode_data(well_count)] = reanalyse_b2b_well_analysis(well_electrode_data(well_count), num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, [], [], [], spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID, reanalyse_electrodes);
                else
                    if strcmp(stable_ave_analysis, 'time_region')
                        [well_electrode_data(well_count).electrode_data] = reanalyse_time_region_well(well_electrode_data(well_count).electrode_data, num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, [], [], spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID, reanalyse_electrodes);
            
                        
                    end
                    
                end
                
                %%disp(electrode_data(re_count).activation_times(2))
                %electrode_data = well_electrode_data(well_count).electrode_data;
            end

        end
        
        
        function reanalyseTimeRegionElectrodeButtonPushed(well_count, elec_id)
            [well_electrode_data(well_count).electrode_data] = electrode_time_region_analysis(well_electrode_data(well_count).electrode_data, num_electrode_rows, num_electrode_cols, elec_id, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis);
        
        end
        

        function aveHeatMapButtonPushed(heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, map_type)
            
            act_row = [];
            start_activation_times = [];
            for e = 1:num_electrode_rows*num_electrode_cols
                disp(e);
                elec_data = well_electrode_data(well_count).electrode_data(1,e);

                if elec_data.rejected == 1
                    act_time = nan;
                else
                    if isempty(elec_data.activation_times)
                        act_time = nan;
                    else
                        if strcmp(map_type, 'depol')
                            act_time = elec_data.ave_activation_time;
                        elseif strcmp(map_type, 'fpd')
                            act_time = elec_data.ave_t_wave_peak_time - elec_data.ave_activation_time;

                        end
                       
                        
                    end
                end

                %start_activation_times = [start_activation_times, act_time];
                act_row = [act_row, act_time];
                %start_activation_tims(num_beats, act_count) = act_time;
                %act_count = act_count+1;
            end
            start_activation_times = [start_activation_times; {act_row}];
            conduction_map_GUI4(start_activation_times, num_electrode_rows, num_electrode_cols, spon_paced, well_elec_fig, nan, 1, 1, map_type, 1)
            
        end
        
        
        function viewOverlaidPlotsPushed(overlaid_plots_button, well_count)
            overlaid_fig = uifigure;
            movegui(overlaid_fig,'center')
            overlaid_fig.WindowState = 'maximized';
            overlaid_fig.Name = strcat(well_ID, '_', 'Overlaid Electrode Results');
            % left bottom width height
            overlaid_main_well_pan = uipanel(overlaid_fig, 'BackgroundColor', '#e68e8e', 'Position', [0 0 screen_width screen_height]);
            close_overlaid_button = uibutton(overlaid_main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_overlaid_button,event) closeSingleFig(close_overlaid_button, overlaid_fig));

            overlaid_well_pan = uipanel(overlaid_main_well_pan, 'BackgroundColor', '#e68e8e', 'Position', [0 0 well_p_width well_p_height]);
            overlaid_ax = uiaxes(overlaid_well_pan, 'BackgroundColor', '#e68e8e', 'Position', [0 0 well_p_width well_p_height]);
            hold(overlaid_ax,'on')
            
            elec_count = 0;
            el_ids = [well_electrode_data(well_count).electrode_data(:).electrode_id];
            max_act = max([well_electrode_data(well_count).electrode_data(:).ave_activation_time]);
            legend_array = [];
            plot_array = [];
            for el_r = num_electrode_rows:-1:1
                for el_c = 1:num_electrode_cols
                    %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                    el_id = strcat(well_ID, '_', num2str(el_c), '_', num2str(el_r));
                    el_indx = contains(el_ids, el_id);
                    el_indx = find(el_indx == 1);
                    if isempty(el_indx)
                        continue
                    end
                    elec_count = el_indx;
                    
                    if isempty(well_electrode_data(well_count).electrode_data(elec_count).electrode_id)
                       continue 
                    end
                    
                    if well_electrode_data(well_count).electrode_data(elec_count).rejected == 1
                        continue
                    end
                        
                    
                    
                    p = plot(overlaid_ax, well_electrode_data(well_count).electrode_data(elec_count).ave_wave_time+(max_act-well_electrode_data(well_count).electrode_data(elec_count).ave_activation_time), well_electrode_data(well_count).electrode_data(elec_count).average_waveform);
                    %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                    plot(overlaid_ax, well_electrode_data(well_count).electrode_data(elec_count).ave_max_depol_time+(max_act-well_electrode_data(well_count).electrode_data(elec_count).ave_activation_time), well_electrode_data(well_count).electrode_data(elec_count).ave_max_depol_point, 'r.', 'MarkerSize', 20);
                    plot(overlaid_ax, well_electrode_data(well_count).electrode_data(elec_count).ave_min_depol_time+(max_act-well_electrode_data(well_count).electrode_data(elec_count).ave_activation_time), well_electrode_data(well_count).electrode_data(elec_count).ave_min_depol_point, 'b.', 'MarkerSize', 20);

                    plot(overlaid_ax, well_electrode_data(well_count).electrode_data(elec_count).ave_activation_time+(max_act-well_electrode_data(well_count).electrode_data(elec_count).ave_activation_time), well_electrode_data(well_count).electrode_data(elec_count).average_waveform(well_electrode_data(well_count).electrode_data(elec_count).ave_wave_time == well_electrode_data(well_count).electrode_data(elec_count).ave_activation_time), 'k.', 'MarkerSize', 20);

                    if well_electrode_data(well_count).electrode_data(elec_count).ave_t_wave_peak_time ~= 0 
                        peak_indx = find(well_electrode_data(well_count).electrode_data(elec_count).ave_wave_time >= well_electrode_data(well_count).electrode_data(elec_count).ave_t_wave_peak_time);
                        peak_indx = peak_indx(1);
                        t_wave_peak = well_electrode_data(well_count).electrode_data(elec_count).average_waveform(peak_indx);
                        plot(overlaid_ax, well_electrode_data(well_count).electrode_data(elec_count).ave_t_wave_peak_time+(max_act-well_electrode_data(well_count).electrode_data(elec_count).ave_activation_time), t_wave_peak, 'c.', 'MarkerSize', 20);
                    end
                    
                    plot_array = [plot_array; p];
                    legend_array = [legend_array; {el_id}];
  
                end
            end
            legend(overlaid_ax, plot_array, legend_array, 'interpreter', 'none')
            hold(overlaid_ax,'off')

        end

        function bipolarButtonPushed(bipolar_button, well_ID, num_electrode_rows, num_electrode_cols)
            calculate_bipolar_electrograms_GUI(well_electrode_data(well_count).electrode_data, num_electrode_rows, num_electrode_cols)

        end
        
        function adjacentBipolarButtonPushed(adjacent_bipolar_button, well_ID, num_electrode_rows, num_electrode_cols)
            calculate_adjacent_bipolar_electrograms_GUI(well_electrode_data(well_count).electrode_data, num_electrode_rows, num_electrode_cols)
        end

    end

    function backButtonPushed(current_fig, prev_fig)
        close(current_fig);
        set(prev_fig, 'Visible', 'on');
        
    end

    function closeResultsButtonPushed(close_button, well_elec_fig, out_fig, well_button, well_count)
        %set(well_elec_fig, 'Visible', 'off');
        close(well_elec_fig);
        %set(well_button, 'Visible', 'off');
        %set(well_button, 'Text', strcat(get(well_button, 'Text'), '_analysed'));
        %well_electrode_data(well_count, :).rejected
        set(out_fig, 'Visible', 'on');
        %pause(0.01);
        %close all hidden;
    end

    function closeSingleFig(close_button, fig)
        close(fig)
    end

    

    function closeButtonPushed(close_button, well_elec_fig, out_fig)
        %set(well_elec_fig, 'Visible', 'off');
        close(well_elec_fig)
        set(out_fig, 'Visible', 'on');
    end
    function  closeAllButtonPushed(close_all_button, out_fig)
        %set(out_fig, 'Visible', 'off');
        close(out_fig);
        close all;
        close all hidden;
        clear;
    end

    

    function manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui)
        set(t_wave_time_text, 'Visible', 'on');
        set(t_wave_time_ui, 'Visible', 'on');
        set(manual_t_wave_button, 'Visible', 'off');
            
    end

  

    function saveAveTimeRegionPushed(save_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, save_plots, saving_multiple)
        %%disp('save b2b')
        %%disp(save_dir)
        %%disp(well_ID)
        disp(strcat('Saving Data for', {' '}, well_ID))
        output_filename = fullfile(save_dir, strcat(well_ID, '.xlsx'));
        if exist(output_filename, 'file')
            try
                delete(output_filename);
            catch
                msgbox(strcat(output_filename, {' '}, 'is open. Please close and try saving again.'))
                %set(ge_results_fig, 'visible', 'on')
                return
            end
        end
        
        if save_plots == 1
            if ~exist(fullfile(save_dir, strcat(well_ID, '_figures')), 'dir')
                mkdir(fullfile(save_dir, strcat(well_ID, '_figures')))
            else
                try
                    rmdir(fullfile(save_dir, strcat(well_ID, '_figures')), 's')
                    mkdir(fullfile(save_dir, strcat(well_ID, '_figures')))
                catch
                    msgbox(strcat('A file in', {' '}, fullfile(save_dir, strcat(well_ID, '_figures')), {' '}, 'is open. Please close and try saving again.'))

                    return
                end
            end
            if ~exist(fullfile(save_dir, strcat(well_ID, '_images')), 'dir')
                mkdir(fullfile(save_dir, strcat(well_ID, '_images')))
            else
                try 
                    rmdir(fullfile(save_dir, strcat(well_ID, '_images')), 's')
                    mkdir(fullfile(save_dir, strcat(well_ID, '_images')))
                catch
                    msgbox(strcat('A file in', {' '}, fullfile(save_dir, strcat(well_ID, '_images')), {' '}, 'is open. Please close and try saving again.'))

                    return
                    
                end
            end
        end
        well_FPDs = [];
        well_slopes = [];
        well_amps = [];
        well_bps = [];
        
        if saving_multiple == 0
            %set(well_elec_fig, 'visible', 'off')
            wait_bar = waitbar(0, strcat('Saving Data for ', {' '}, well_ID));
        end
        
        sheet_count = 1;
        elec_ids = [well_electrode_data(well_count).electrode_data(:).electrode_id];
        %for elec_r = 1:num_electrode_rows
        num_partitions = 1/(num_electrode_rows*num_electrode_cols);
        partition = num_partitions;
        for elec_r = num_electrode_rows:-1:1
            for elec_c = 1:num_electrode_cols
                if saving_multiple == 0
                    waitbar(partition, wait_bar, strcat('Saving Data for ', {' '}, well_ID));
                    partition = partition+num_partitions;
                end
                
                %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                if isempty(elec_indx)
                    
                    continue
                end
                electrode_count = elec_indx;
                
                if isempty(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times)
                    %continue;
                end
                
                
                
                sheet_count = sheet_count+1;
                
                %electrode_stats_header = {electrode_data(electrode_count).electrode_id, 'Beat No.', 'Beat Start Time (s)', 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Cycle Length (s)'};
                
                %t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                %t_wave_peak_times = 
                %activation_times = electrode_data(electrode_count).activation_times;
                %activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                
                FPDs = [well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time - well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time];

                amps = [well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_point - well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_point];

                slopes = [well_electrode_data(well_count).electrode_data(electrode_count).ave_depol_slope];

                if ~isempty(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times)
                    bps = [well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time(end)- well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time(1)];    
                
                    well_FPDs = [well_FPDs FPDs];
                    well_slopes = [well_slopes slopes];
                    well_amps = [well_amps amps];
                    well_bps = [well_bps bps];
                end
                               
                
                
                activation_times = well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time;
                [br, bc] = size(activation_times);
                activation_times = reshape(activation_times, [bc br]);
                activation_times = num2cell([activation_times]);
                %cell%disp(activation_times)
                
                activation_point = well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_point;
                [br, bc] = size(activation_point);
                activation_point = reshape(activation_point, [bc br]);
                activation_point = num2cell([activation_point]);
                
                min_depol_time = well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_time;
                [br, bc] = size(min_depol_time);
                min_depol_time = reshape(min_depol_time, [bc br]);
                min_depol_time = num2cell([min_depol_time]);
                
                min_depol_point = well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_point;
                [br, bc] = size(min_depol_point);
                min_depol_point = reshape(min_depol_point, [bc br]);
                min_depol_point = num2cell([min_depol_point]);
                
                max_depol_time = well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_time;
                [br, bc] = size(max_depol_time);
                max_depol_time = reshape(max_depol_time, [bc br]);
                max_depol_time = num2cell([max_depol_time]);
                
                max_depol_point = well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_point;
                [br, bc] = size(max_depol_point);
                max_depol_point = reshape(max_depol_point, [bc br]);
                max_depol_point = num2cell([max_depol_point]);
              
                [br, bc] = size(amps);
                amps = reshape(amps, [bc br]);
                amps = num2cell([amps]);
                %cell%disp(amps)
                
                [br, bc] = size(slopes);
                slopes = reshape(slopes, [bc br]);
                slopes = num2cell([slopes]);

                %cell%disp(slopes)
                
                t_wave_peak_times = well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time;
                [br, bc] = size(t_wave_peak_times);
                t_wave_peak_times = reshape(t_wave_peak_times, [bc br]);
                t_wave_peak_times = num2cell([t_wave_peak_times]);
                %cell%disp(t_wave_peak_times)
                
                %ave_t_wave_peak = electrode_data(electrode_count).average_waveform(find(electrode_data(electrode_count).ave_wave_time == electrode_data(electrode_count).ave_t_wave_peak_time));
                
                t_wave_peak_array = well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak;
                [br, bc] = size(t_wave_peak_array);
                t_wave_peak_array = reshape(t_wave_peak_array, [bc br]);
                t_wave_peak_array = num2cell([t_wave_peak_array]);
                
                %cell%disp(t_wave_peak_array)
                
                [br, bc] = size(FPDs);
                FPDs = reshape(FPDs, [bc br]);
                FPD_num = FPDs;
                FPDs = num2cell([FPDs]);
      
                %cell%disp(FPDs)
                
                [br, bc] = size(bps);
                beat_periods = reshape(bps, [bc br]);
                bp_num = beat_periods;
                beat_periods = num2cell([beat_periods]);
                %cell%disp(beat_periods)

                if strcmp(spon_paced, 'spon')
                    
                    
                        
                    time_start_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_start]);
                    
                    
                    time_end_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_end]);
                    
                    
                    bdt_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).bdt]);
                    
                    
                    min_bp_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).min_bp]);
                    
                    
                    max_bp_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).max_bp]);
                    
                    
                    post_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off]);
                    
                    
                    t_wave_duration_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_duration]);
                    
                    
                    t_wave_offset_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_offset]);
                    
                    
                    %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                    t_wave_shape_array = {well_electrode_data(well_count).electrode_data(electrode_count).t_wave_shape};
                    
                    filter_intensity_array = {well_electrode_data(well_count).electrode_data(electrode_count).filter_intensity};
                    
                    
                    ave_wave_post_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_post_spike_hold_off]);
                    
                    
                    ave_wave_t_wave_duration_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_t_wave_duration]);
                    
                    
                    ave_wave_t_wave_offset_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_t_wave_offset]);
                    
                    
                    %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                    ave_wave_t_wave_shape_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_t_wave_shape};
                    
                    
                    ave_wave_filter_intensity_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_filter_intensity};
                    
                    
                    wavelet_family = {well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_wavelet};
                    
                    polynomial_degree = num2cell(well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_polynomial_degree);
                    
                    warning_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_warning};
                    
                    FPDc_fridericia = FPD_num/((bp_num)^(1/3));
                    FPDc_bazzet = FPD_num/((bp_num)^(1/2));
                    
                    
                    if well_electrode_data(well_count).electrode_data(electrode_count).rejected == 0
                        electrode_stats_table = table('Size', [1, 33], 'VariableTypes', ["string", "double", "double", "double",  "double",  "double",  "double", "double",  "double",  "double",  "double",  "double", "double",  "double", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string", "double", "double", "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'FPDc Fridericia (s)', 'FPDc Bazzet (s)', 'Beat Period (s)', 'Time Region Start (s)', 'Time Region End (s)', 'Beat Wide Beat Detection Threshold Input (V)', 'Beat Wide Mininum Beat Period Input (s)', 'Beat Wide Maximum Beat Period Input (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'Ave Beat Post-spike hold-off (s)', 'Ave Beat T-wave Duration Input (s)', 'Ave Beat T-wave offset Input (s)', 'Ave Beat T-wave Shape', 'Ave Beat Filter Intensity', "Ave T-wave Denoising Wavelet Family", "Ave T-wave Polynomial Degree", 'Warnings']));

                        if ~isempty(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times)
                            

                            electrode_stats_table(:, 2) = activation_times;
                            electrode_stats_table(:, 3) = activation_point;
                            electrode_stats_table(:, 4) = min_depol_time;
                            electrode_stats_table(:, 5) = min_depol_point;
                            electrode_stats_table(:, 6) = max_depol_time;
                            electrode_stats_table(:, 7) = max_depol_point;
                            electrode_stats_table(:, 8) = amps;
                            electrode_stats_table(:, 9) = slopes;
                            electrode_stats_table(:, 10) = t_wave_peak_times;
                            electrode_stats_table(:, 11) = t_wave_peak_array;

                            electrode_stats_table(:, 12) = FPDs;
                            electrode_stats_table(:, 13) = num2cell(FPDc_fridericia);
                            electrode_stats_table(:, 14) = num2cell(FPDc_bazzet);
                            electrode_stats_table(:, 15) = beat_periods;
                            electrode_stats_table(:, 16) = time_start_array;
                            electrode_stats_table(:, 17) = time_end_array;
                            electrode_stats_table(:, 18) = bdt_array;
                            electrode_stats_table(:, 19) = min_bp_array;
                            electrode_stats_table(:, 20) = max_bp_array;
                            electrode_stats_table(:, 21) = post_spike_hold_off_array;
                            electrode_stats_table(:, 22) = t_wave_duration_array;
                            electrode_stats_table(:, 23) = t_wave_offset_array;
                            electrode_stats_table(:, 24) = t_wave_shape_array;
                            electrode_stats_table(:, 25) = filter_intensity_array;

                            electrode_stats_table(:, 26) = ave_wave_post_spike_hold_off_array;
                            electrode_stats_table(:, 27) = ave_wave_t_wave_duration_array;
                            electrode_stats_table(:, 28) = ave_wave_t_wave_offset_array;
                            electrode_stats_table(:, 29) = ave_wave_t_wave_shape_array;
                            electrode_stats_table(:, 30) = ave_wave_filter_intensity_array;

                            electrode_stats_table(:, 31) = wavelet_family;
                            electrode_stats_table(:, 32) = polynomial_degree;
                            electrode_stats_table(:, 33) = warning_array;
                        
                        end
                        
                    else
                        electrode_stats_table = table('Size', [0, 33], 'VariableTypes', ["string", "double", "double", "double",  "double",  "double",  "double", "double",  "double",  "double",  "double",  "double", "double",  "double", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string", "double", "double", "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'FPDc Fridericia (s)', 'FPDc Bazzet (s)', 'Beat Period (s)', 'Time Region Start (s)', 'Time Region End (s)', 'Beat Wide Beat Detection Threshold Input (V)', 'Beat Wide Mininum Beat Period Input (s)', 'Beat Wide Maximum Beat Period Input (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'Ave Beat Post-spike hold-off (s)', 'Ave Beat T-wave Duration Input (s)', 'Ave Beat T-wave offset Input (s)', 'Ave Beat T-wave Shape', 'Ave Beat Filter Intensity', "Ave T-wave Denoising Wavelet Family", "Ave T-wave Polynomial Degree", 'Warnings']));
                    
                    end
                    
                    
                    
                    
                elseif strcmp(spon_paced, 'paced')
                    time_start_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_start]);
                    
                    time_end_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_end]);
                    
                    stim_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).stim_spike_hold_off]);
                    
                    post_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off]);
                    
                    t_wave_duration_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_duration]);
                    
                    t_wave_offset_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_offset]);


                    %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                    t_wave_shape_array = {well_electrode_data(well_count).electrode_data(electrode_count).t_wave_shape};
                    
                    filter_intensity_array = {well_electrode_data(well_count).electrode_data(electrode_count).filter_intensity};
                    
                    ave_wave_stim_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_stim_spike_hold_off]);
                    
                    ave_wave_post_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_post_spike_hold_off]);
                    
                    
                    ave_wave_t_wave_duration_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_t_wave_duration]);
                    
                    
                    ave_wave_t_wave_offset_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_t_wave_offset]);
                    
                    
                    %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                    ave_wave_t_wave_shape_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_t_wave_shape};
                    
                    
                    ave_wave_filter_intensity_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_filter_intensity};
                    
                    
                    wavelet_family = {well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_wavelet};
                    
                    polynomial_degree = num2cell(well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_polynomial_degree);
                    
                    warning_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_warning};
                    
                    if well_electrode_data(well_count).electrode_data(electrode_count).rejected == 0
                        
                        electrode_stats_table = table('Size', [1, 30], 'VariableTypes', ["string", "double", "double", "double", "double",  "double", "double", "double",  "double",  "double",  "double",  "double", "double",  "double",  "double",  "double",  "double",  "double", "double", "string", "string", "double", "double", "double", "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Time Region Start (s)', 'Time Region End (s)', 'Beat Wide Stim-spike hold-off (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'Ave Beat Stim-spike hold-off (s)', 'Ave Beat Post-spike hold-off (s)', 'Ave Beat T-wave Duration Input (s)', 'Ave Beat T-wave offset Input (s)', 'Ave Beat T-wave Shape', 'Ave Beat Filter Intensity', "Ave Beat T-wave Denoising Wavelet Family", "Ave Beat T-wave Polynomial Degree", 'Warnings']));

                        
                        if ~isempty(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times)
                            electrode_stats_table(:, 2) = activation_times;
                            electrode_stats_table(:, 3) = activation_point;
                            electrode_stats_table(:, 4) = min_depol_time;
                            electrode_stats_table(:, 5) = min_depol_point;
                            electrode_stats_table(:, 6) = max_depol_time;
                            electrode_stats_table(:, 7) = max_depol_point;
                            electrode_stats_table(:, 8) = amps;
                            electrode_stats_table(:, 8) = slopes;
                            electrode_stats_table(:, 10) = t_wave_peak_times;
                            electrode_stats_table(:, 11) = t_wave_peak_array;
                            electrode_stats_table(:, 12) = FPDs;
                            electrode_stats_table(:, 13) = beat_periods;
                            electrode_stats_table(:, 14) = time_start_array;
                            electrode_stats_table(:, 15) = time_end_array;
                            electrode_stats_table(:, 16) = stim_spike_hold_off_array;
                            electrode_stats_table(:, 17) = post_spike_hold_off_array;
                            electrode_stats_table(:, 18) = t_wave_duration_array;
                            electrode_stats_table(:, 19) = t_wave_offset_array;
                            electrode_stats_table(:, 20) = t_wave_shape_array;
                            electrode_stats_table(:, 21) = filter_intensity_array;

                            electrode_stats_table(:, 22) = ave_wave_stim_spike_hold_off_array;
                            electrode_stats_table(:, 23) = ave_wave_post_spike_hold_off_array;
                            electrode_stats_table(:, 24) = ave_wave_t_wave_duration_array;
                            electrode_stats_table(:, 25) = ave_wave_t_wave_offset_array;
                            electrode_stats_table(:, 26) = ave_wave_t_wave_shape_array;
                            electrode_stats_table(:, 27) = ave_wave_filter_intensity_array;

                            electrode_stats_table(:, 28) = wavelet_family;
                            electrode_stats_table(:, 29) = polynomial_degree;
                            electrode_stats_table(:, 30) = warning_array;
                        end
                   else
                       electrode_stats_table = table('Size', [0, 30], 'VariableTypes', ["string", "double", "double", "double", "double",  "double", "double", "double",  "double",  "double",  "double",  "double", "double",  "double",  "double",  "double",  "double",  "double", "double", "string", "string", "double", "double", "double", "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Time Region Start (s)', 'Time Region End (s)', 'Beat Wide Stim-spike hold-off (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'Ave Beat Stim-spike hold-off (s)', 'Ave Beat Post-spike hold-off (s)', 'Ave Beat T-wave Duration Input (s)', 'Ave Beat T-wave offset Input (s)', 'Ave Beat T-wave Shape', 'Ave Beat Filter Intensity', "Ave Beat T-wave Denoising Wavelet Family", "Ave Beat T-wave Polynomial Degree", 'Warnings']));

                       
                       
                   end
                    
                elseif strcmp(spon_paced, 'paced bdt')
                    time_start_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_start]);
                    
                    time_end_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_end]);
                    
                    bdt_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).bdt]);
                    
                    min_bp_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).min_bp]);
                    
                    max_bp_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).max_bp]);
                    
                    stim_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).stim_spike_hold_off]);
                    
                    post_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off]);
                    
                    t_wave_duration_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_duration]);
                    
                    t_wave_offset_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_offset]);
                    
                    %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                    t_wave_shape_array = {well_electrode_data(well_count).electrode_data(electrode_count).t_wave_shape};
                    
                    filter_intensity_array = {well_electrode_data(well_count).electrode_data(electrode_count).filter_intensity};
                    
                    
                    ave_wave_stim_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_stim_spike_hold_off]);
                    
                    
                    ave_wave_post_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_post_spike_hold_off]);
                    
                    
                    ave_wave_t_wave_duration_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_t_wave_duration]);
                    
                    
                    ave_wave_t_wave_offset_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_t_wave_offset]);
                    
                    
                    %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                    ave_wave_t_wave_shape_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_t_wave_shape};
                    
                    
                    ave_wave_filter_intensity_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_filter_intensity};
                    
                    
                    wavelet_family = {well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_wavelet};
                    
                    
                    polynomial_degree = num2cell(well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_polynomial_degree);
                    
                    
                    warning_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_warning};
                    
                    %electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, time_start_array, time_end_array, bdt_array, min_bp_array, max_bp_array, stim_spike_hold_off_array, post_spike_hold_off_array, t_wave_duration_array, t_wave_offset_array, t_wave_shape_array, filter_intensity_array, warning_array);
                
                    if well_electrode_data(well_count).electrode_data(electrode_count).rejected == 0
                        electrode_stats_table = table('Size', [1, 33], 'VariableTypes', ["string", "double", "double", "double", "double",  "double",  "double",  "double",  "double", "double", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string", "double", "double", "double", "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Time Region Start (s)', 'Time Region End (s)', 'Beat Wide Beat Detection Threshold Input (V)', 'Beat Wide Mininum Beat Period Input (s)', 'Beat Wide Maximum Beat Period Input (s)', 'Beat Wide Stim-spike hold-off (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'Ave Beat Stim-spike hold-off (s)', 'Ave Beat Post-spike hold-off (s)', 'Ave Beat T-wave Duration Input (s)', 'Ave Beat T-wave offset Input (s)', 'Ave Beat T-wave Shape', 'Ave Beat Filter Intensity', "Ave Beat T-wave Denoising Wavelet Family", "Ave Beat T-wave Polynomial Degree", 'Warnings']));

                        if ~isempty(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times)
                            electrode_stats_table(:, 2) = activation_times;
                            electrode_stats_table(:, 3) = activation_point;
                            electrode_stats_table(:, 4) = min_depol_time;
                            electrode_stats_table(:, 5) = min_depol_point;
                            electrode_stats_table(:, 6) = max_depol_time;
                            electrode_stats_table(:, 7) = max_depol_point;
                            electrode_stats_table(:, 8) = amps;
                            electrode_stats_table(:, 9) = slopes;
                            electrode_stats_table(:, 10) = t_wave_peak_times;
                            electrode_stats_table(:, 11) = t_wave_peak_array;
                            electrode_stats_table(:, 12) = FPDs;
                            electrode_stats_table(:, 13) = beat_periods;
                            electrode_stats_table(:, 14) = time_start_array;
                            electrode_stats_table(:, 15) = time_end_array;
                            electrode_stats_table(:, 16) = bdt_array; 
                            electrode_stats_table(:, 17) = min_bp_array; 
                            electrode_stats_table(:, 18) = max_bp_array; 
                            electrode_stats_table(:, 19) = stim_spike_hold_off_array;
                            electrode_stats_table(:, 20) = post_spike_hold_off_array;
                            electrode_stats_table(:, 21) = t_wave_duration_array;
                            electrode_stats_table(:, 22) = t_wave_offset_array;
                            electrode_stats_table(:, 23) = t_wave_shape_array;
                            electrode_stats_table(:, 24) = filter_intensity_array;

                            electrode_stats_table(:, 25) = ave_wave_stim_spike_hold_off_array;
                            electrode_stats_table(:, 26) = ave_wave_post_spike_hold_off_array;
                            electrode_stats_table(:, 27) = ave_wave_t_wave_duration_array;
                            electrode_stats_table(:, 28) = ave_wave_t_wave_offset_array;
                            electrode_stats_table(:, 29) = ave_wave_t_wave_shape_array;
                            electrode_stats_table(:, 30) = ave_wave_filter_intensity_array;

                            electrode_stats_table(:, 31) = wavelet_family;
                            electrode_stats_table(:, 32) = polynomial_degree;
                            electrode_stats_table(:, 33) = warning_array;
                        end
                    else
                        electrode_stats_table = table('Size', [0, 33], 'VariableTypes', ["string", "double", "double", "double", "double",  "double",  "double",  "double",  "double", "double", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string", "double", "double", "double", "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Time Region Start (s)', 'Time Region End (s)', 'Beat Wide Beat Detection Threshold Input (V)', 'Beat Wide Mininum Beat Period Input (s)', 'Beat Wide Maximum Beat Period Input (s)', 'Beat Wide Stim-spike hold-off (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'Ave Beat Stim-spike hold-off (s)', 'Ave Beat Post-spike hold-off (s)', 'Ave Beat T-wave Duration Input (s)', 'Ave Beat T-wave offset Input (s)', 'Ave Beat T-wave Shape', 'Ave Beat Filter Intensity', "Ave Beat T-wave Denoising Wavelet Family", "Ave Beat T-wave Polynomial Degree", 'Warnings']));

                        
                        
                        
                    end
                end
                
                
                %electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, time_start_array, time_end_array, bdt_array, min_bp_array, max_bp_array, post_spike_hold_off_array, );
                
                %electrode_stats = {[elec_id_column] [beat_num_array] [beat_start_times] [activation_times] [amps] [slopes] [t_wave_peak_times] [t_wave_peak_array] [FPDs] [beat_periods] [cycle_length_array]};
                %electrode_stats = {electrode_stats_header;electrode_stats};
                
                
                
                % all_data must be a cell array

                try
                    if sheet_count ~= 2
                        fileattrib(output_filename, '-h +w');
                    end

                    %writecell(electrode_stats, output_filename, 'Sheet', sheet_count);
                    writetable(electrode_stats_table, output_filename, 'Sheet', sheet_count);
                    fileattrib(output_filename, '+h +w');
                catch
                    msgbox(strcat(output_filename, {' '}, 'is open and cannot be written to. Please close it and try saving again.'));
                    if saving_multiple == 0
                        close(wait_bar)

                        set(well_elec_fig, 'visible', 'on')
                        return
                    end
                end
                %{
                if save_plots == 1
                    fig = figure();
                    set(fig, 'visible', 'off');
                    hold('on')
                    plot(well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time, well_electrode_data(well_count).electrode_data(electrode_count).average_waveform);
                    plot(well_electrode_data(well_count).electrode_data(electrode_count).filtered_ave_wave_time, well_electrode_data(well_count).electrode_data(electrode_count).filtered_ave_wave_time);
                    %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                    plot(well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_time, well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_point, 'r.', 'MarkerSize', 20);
                    plot(well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_time, well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_point, 'b.', 'MarkerSize', 20);
                    plot(well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time, well_electrode_data(well_count).electrode_data(electrode_count).average_waveform(well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time == well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time), 'ko');

                    peak_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time >= well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time);
                    peak_indx = peak_indx(1);
                    t_wave_peak = well_electrode_data(well_count).electrode_data(electrode_count).average_waveform(peak_indx);
                    plot(well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time, t_wave_peak, 'c.', 'MarkerSize', 20);

                    legend('signal', 'filtered signal', 'max depol', 'min depol', 'act. time', 'repol. recovery', 'location', 'northeastoutside')
                    title({well_electrode_data(well_count).electrode_data(electrode_count).electrode_id},  'Interpreter', 'none')
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  well_electrode_data(well_count).electrode_data(electrode_count).electrode_id));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  well_electrode_data(well_count).electrode_data(electrode_count).electrode_id), 'png')
                    hold('off')
                    close(fig)
                end
                %}
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
        
        
        if strcmp(well_electrode_data(well_count).spon_paced, 'spon')
            FPDc_fridericia = mean_FPD/((mean_bp)^(1/3));
            FPDc_bazzet = mean_FPD/((mean_bp)^(1/2));
            
            headings = {strcat(well_ID,':Well-wide statistics'); 'mean FPD (s)'; 'FPDc Fridericia (s)'; 'FPDc Bazzet (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
            mean_data = [mean_FPD; FPDc_fridericia; FPDc_bazzet; mean_slope; mean_amp; mean_bp];
        else
            headings = {strcat(well_ID,':Well-wide statistics'); 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
            mean_data = [mean_FPD; mean_slope; mean_amp; mean_bp];
        end
            
            
       
        mean_data = num2cell(mean_data);
        mean_data = vertcat({''}, mean_data);
        %cell%disp(mean_data);
        
        well_stats = horzcat(headings, mean_data);
        %well_stats = cellstr(well_stats)
        
        %cell%disp(well_stats)
        
        %xlsxwrite(output_filename, well_stats, 1);
        fileattrib(output_filename, '-h +w');
        writecell(well_stats, output_filename, 'Sheet', 1);
        
        if saving_multiple == 0
            close(wait_bar)
            msgbox(strcat('Saved Data for', {' '}, well_ID, {' '}, 'to', {' '}, output_filename));
            set(well_elec_fig, 'visible', 'on')
            
        end
    end


    
    function saveAllTimeRegionButtonPushed(save_button, out_fig, save_dir, num_electrode_rows, num_electrode_cols, save_plots)
        set(out_fig, 'visible', 'off')
        
        num_partitions = 1/(2*num_wells);
        partition = num_partitions;
        wait_bar = waitbar(0, 'Please Wait...');
        for w = 1:num_wells
            well_ID = added_wells(w);
            %electrode_data = well_electrode_data(w).electrode_data;
            
            waitbar(partition, wait_bar, strcat('Saving', {' '}, well_ID));
            partition = partition+num_partitions;
            saveAveTimeRegionPushed(save_button, '', w, save_dir, well_ID, num_electrode_rows, num_electrode_cols, save_plots, 1)
            if num_partitions ~= 1
                waitbar(partition, wait_bar, strcat('Saved', {' '}, well_ID));
                pause(0.8)
            else
                waitbar(partition, wait_bar, 'Saving all data complete.');
                pause(0.8)
            end
            partition = partition+num_partitions;
        end
        
        close(wait_bar)
        set(out_fig, 'visible', 'onn')
    end

end