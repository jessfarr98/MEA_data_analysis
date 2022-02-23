function MEA_GUI_analysis_display_resultsV2(AllDataRaw, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar, save_dir)
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
    
    if strcmp(beat_to_beat, 'on')

        close_all_button = uibutton(main_p,'push', 'BackgroundColor', '#B02727', 'Text', 'Close', 'Position', [screen_width-180 100 150 50], 'ButtonPushedFcn', @(close_all_button,event) closeAllButtonPushed(close_all_button, out_fig));
        
        save_all_button =  uibutton(main_p,'push', 'BackgroundColor', '#3dd4d1', 'Text', "Save All To"+ " " + save_dir, 'FontSize', 8, 'Position', [screen_width-180 200 150 50], 'ButtonPushedFcn', @(save_all_button,event) saveAllB2BButtonPushed(save_all_button, out_fig, save_dir, num_electrode_rows, num_electrode_cols, 1));
        
        %display_final_button = uibutton(main_p,'push','Text', 'Close', 'Position', [screen_width-180 200 120 50], 'ButtonPushedFcn', @(display_final_button,event) displayFinalB2BButtonPushed(display_final_button, out_fig));
        
        % Display Finalised results
        % Shows all analysed electrodes plus statistics and buttons for view plots of b2b statistics and heatmaps etc.
        
    else
        if strcmp(stable_ave_analysis, 'time_region')
            close_all_button = uibutton(main_p,'push', 'BackgroundColor', '#B02727', 'Text', 'Close', 'Position', [screen_width-180 100 150 50], 'ButtonPushedFcn', @(close_all_button,event) closeAllButtonPushed(close_all_button, out_fig));
            save_all_button = uibutton(main_p,'push', 'BackgroundColor', '#3dd4d1', 'Text', "Save All To"+ " " + save_dir, 'FontSize', 8, 'Position', [screen_width-180 200 150 50], 'ButtonPushedFcn', @(save_all_button,event) saveAllTimeRegionButtonPushed(save_all_button, out_fig, save_dir, num_electrode_rows, num_electrode_cols, 1));
        
            % Display Finalised Results
            % Shows all ave electrodes analysed and also statistics 
           
            
        end
    
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
               
               
               
                   
               well_button = uibutton(button_panel,  'push', 'BackgroundColor', '#d43d3d','Text', wellID, 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, button_count, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));
               
               
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


                well_button = uibutton(button_panel,'push', 'BackgroundColor', '#d43d3d', 'Text', wellID, 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, b, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));

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
        else
            well_ID = wellID;
            set(out_fig, 'Visible', 'off')
            close(out_fig)
        end
        
        %'#B02727' Dark red
        %'#d43d3d' Medium red
        %'#e68e8e' Light red
        %'#3dd483' green

        
        well_elec_fig = uifigure;
        well_elec_fig.Name = strcat(well_ID, '_', 'Electrode Results');
        movegui(well_elec_fig,'center')
        well_elec_fig.WindowState = 'maximized';
        % left bottom width height
        main_well_pan = uipanel(well_elec_fig, 'Position', [0 0 screen_width screen_height]);
        
        well_p_width = screen_width-300;
        well_p_height = screen_height -100;
        well_pan = uipanel(main_well_pan, 'Position', [0 0 well_p_width well_p_height]);
        
        %close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed(close_button, well_elec_fig, out_fig));
        
        if num_wells == 1
     
            %results_close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 0 120 50], 'ButtonPushedFcn', @(results_close_button,event) closeAllButtonPushed(results_close_button, well_elec_fig));
            rejec_well_button = uibutton(main_well_pan,'push','Text', 'Reject Well', 'Position', [screen_width-220 350 120 50], 'ButtonPushedFcn', @(rejec_well_button,event) rejectWellButtonPushed(rejec_well_button, well_elec_fig, out_fig, well_button, well_count));

            results_close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 0 120 50], 'ButtonPushedFcn', @(results_close_button,event) closeAllButtonPushed(rejec_well_button, well_elec_fig));
            
        else
            results_close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 0 120 50], 'ButtonPushedFcn', @(results_close_button,event) closeResultsButtonPushed(results_close_button, well_elec_fig, out_fig, well_button));
            
            rejec_well_button = uibutton(main_well_pan,'push','Text', 'Reject Well', 'Position', [screen_width-220 350 120 50], 'ButtonPushedFcn', @(rejec_well_button,event) rejectWellButtonPushed(rejec_well_button, well_elec_fig, out_fig, well_button, well_count));

        end
        
        %info_button = uibutton(main_well_pan,'push','Text', 'Information', 'Position', [screen_width-220 650 120 50], 'ButtonPushedFcn', @(legend_button,event) infoButtonPushed(info_button, beat_to_beat, stable_ave_analysis, bipolar, spon_paced));
        
        if strcmp(beat_to_beat, 'on')
            if strcmp(bipolar, 'on')
                bipolar_button = uibutton(main_well_pan,'push','Text', well_ID + " " + "Show Bipolar Electrogam Results", 'Position', [screen_width-220 250 180 50], 'ButtonPushedFcn', @(bipolar_button,event) bipolarButtonPushed(bipolar_button, well_ID, num_electrode_rows, num_electrode_cols));
                adjacent_bipolar_button = uibutton(main_well_pan,'push','Text', well_ID+ " " + "Show Adjacent Bipolar Electrogam Results", 'Position', [screen_width-220 200 180 50], 'ButtonPushedFcn', @(adjacent_bipolar_button,event) adjacentBipolarButtonPushed(adjacent_bipolar_button, well_ID, num_electrode_rows, num_electrode_cols));
                
            end
            
            %save_button = uibutton(main_well_pan,'push',  'BackgroundColor', '#3dd4d1', 'Text', 'Save', 'Position', [screen_width-220 300 100 50], 'ButtonPushedFcn', @(save_button,event) saveB2BButtonPushed(save_button, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, 0));
            
            
            save_results_button = uibutton(main_well_pan,'push',  'BackgroundColor', '#3dd4d1', 'Text', 'Save Results', 'Position', [screen_width-300 300 100 50], 'ButtonPushedFcn', @(save_results_button,event) saveB2BButtonPushed(save_results_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, 0, 0));

            save_plots_button = uibutton(main_well_pan,'push',  'BackgroundColor', '#3dd4d1', 'Text', 'Save Plots', 'Position', [screen_width-200 300 100 50], 'ButtonPushedFcn', @(save_plots_button,event) saveB2BPlotsButtonPushed(save_plots_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols));

            save_alldata_button = uibutton(main_well_pan,'push',  'BackgroundColor', '#3dd4d1', 'Text', 'Save All Data', 'Position', [screen_width-100 300 100 50], 'ButtonPushedFcn', @(save_alldata_button,event) saveB2BButtonPushed(save_alldata_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, 1, 0));

            %{
            if num_wells == 1
                display_final_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd483', 'Text', 'Accept Analysis', 'Position', [screen_width-220 300 120 50], 'ButtonPushedFcn', @(display_final_button,event) displayFinalB2BButtonPushed(display_final_button, '', well_elec_fig, well_button, bipolar));
            
            else
                display_final_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd483', 'Text', 'Accept Analysis', 'Position', [screen_width-220 300 120 50], 'ButtonPushedFcn', @(display_final_button,event) displayFinalB2BButtonPushed(display_final_button, out_fig, well_elec_fig, well_button, bipolar));
            
            end
            %}
            heat_map_button = uibutton(main_well_pan,'push','Text', well_ID+ " " + "Show Heat Map", 'Position', [screen_width-220 150 120 50], 'ButtonPushedFcn', @(heat_map_button,event) heatMapButtonPushed(heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced));

            %reanalyse_button = uibutton(main_well_pan,'push','Text', 'Re-analyse Electrodes', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
            reanalyse_well_button = uibutton(main_well_pan,'push','Text', 'Re-analyse Well', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_well_button,event) reanalyseWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
            assess_conduction_velocity_model_button = uibutton(main_well_pan,'push','Text', 'Assess Conduction Velocity Model', 'Position', [screen_width-220 500 200 50], 'ButtonPushedFcn', @(assess_conduction_velocity_model_button,event) assessConductionVelocityModelButtonPushed(assess_conduction_velocity_model_button, well_elec_fig, well_count));
        
            
        else
            if strcmp(stable_ave_analysis, 'time_region')
                %reanalyse_button = uibutton(main_well_pan,'push','Text', 'Re-analyse well', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, 'ave'));
                %display_final_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd483', 'Text', 'Accept Analysis', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(display_final_button,event) displayFinalTimeRegionButtonPushed(display_final_button, out_fig, well_elec_fig, well_button));
                
                save_results_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd4d1', 'Text', 'Save Results', 'Position', [screen_width-300 300 100 50], 'ButtonPushedFcn', @(save_results_button,event) saveAveTimeRegionPushed(save_results_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, 0, 0));
            
                save_plots_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd4d1', 'Text', 'Save Plots', 'Position', [screen_width-200 300 100 50], 'ButtonPushedFcn', @(save_plots_button,event) saveAveTimeRegionPlotsPushed(save_plots_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols));
            
                save_alldata_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd4d1', 'Text', 'Save All Data', 'Position', [screen_width-100 300 100 50], 'ButtonPushedFcn', @(save_alldata_button,event) saveAveTimeRegionPushed(save_alldata_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, 1, 0));
            
                %set(display_final_button, 'Visible', 'off')
                
                
                %auto_t_wave_button = uibutton(main_well_pan,'push','Text', 'Auto T-Wave Peak Search', 'Position', [screen_width-220 400 120 50], 'ButtonPushedFcn', @(auto_t_wave_button,event) autoTwavePeakButtonPushed(auto_t_wave_button, out_fig, well_elec_fig, well_button));
                
                overlaid_plots_button = uibutton(main_well_pan,'push',  'Text', 'View Overlaid Plots', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(overlaid_plots_button,event) viewOverlaidPlotsPushed(overlaid_plots_button, well_count));
            
                
            end
        end
        
        depol_zoom_button = uibutton(main_well_pan,'push','Text', 'Expand Depol. Complexes', 'Position', [screen_width-220 350 150 50], 'ButtonPushedFcn', @(depol_zoom_button,event) depolZoomButtonPushed(depol_zoom_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
        repol_zoom_button = uibutton(main_well_pan,'push','Text', 'Expand Repol. Complexes', 'Position', [screen_width-220 400 150 50], 'ButtonPushedFcn', @(repol_zoom_button,event) repolZoomButtonPushed(repol_zoom_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
        restore_full_beat_button = uibutton(main_well_pan,'push','Text', 'Restore Full Beat', 'Position', [screen_width-220 450 150 50], 'ButtonPushedFcn', @(restore_full_beat_button,event) restoreBeatButtonPushed(restore_full_beat_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
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
                well_electrode_data(well_count).electrode_data(electrode_count).rejected = 0;
                %electrode_count = electrode_count+1;
                if strcmp(beat_to_beat, 'on')
                    %plot all the electrodes analysed data and 
                    % left bottom width height
                    %%disp(electrode_data(electrode_count).electrode_id)
                    if isempty(well_electrode_data(well_count).electrode_data(electrode_count))
                        continue
                        
                    end
                    elec_pan = uipanel(well_pan, 'Title', well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);
                    
                    undo_elec_pan = uipanel(well_pan, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);
                    
                    undo_reject_electrode_button = uibutton(undo_elec_pan,'push','Text', 'Undo Reject Electrode', 'Position', [0 0 well_p_width/num_electrode_cols well_p_height/num_electrode_rows], 'ButtonPushedFcn', @(reject_electrode_button,event) undoRejectElectrodeButtonPushed(elec_pan, undo_elec_pan, electrode_count));

                    set(undo_elec_pan, 'Visible', 'off');
                    
                    elec_ax = uiaxes(elec_pan, 'Position', [0 20 (well_p_width/num_electrode_cols)-25 (well_p_height/num_electrode_rows)-50]);
                    
                    reject_electrode_button = uibutton(elec_pan,'push','Text', 'Reject Electrode', 'Position', [0 0 ((well_p_width/num_electrode_cols)-25)/4 20], 'ButtonPushedFcn', @(reject_electrode_button,event) rejectElectrodeButtonPushed(reject_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count, undo_elec_pan));
                    
                    expand_electrode_button = uibutton(elec_pan,'push','Text', 'Expanded Plot', 'Position', [((well_p_width/num_electrode_cols)-25)/4 0 ((well_p_width/num_electrode_cols)-25)/4 20], 'ButtonPushedFcn', @(expand_electrode_button,event) expandElectrodeButtonPushed(expand_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count));
                    
                    reanalyse_electrode_button = uibutton(elec_pan,'push','Text', 'Reanalyse Electrode', 'Position', [2*(((well_p_width/num_electrode_cols)-25)/4) 0 ((well_p_width/num_electrode_cols)-25)/4 20], 'ButtonPushedFcn', @(reanalyse_electrode_button,event) reanalyseElectrodeButtonPushed(well_count, elec_id));
                    
                    
                    reanalyse_beat_button = uibutton(elec_pan,'push','Text', 'Reanalyse Beat', 'Position', [3*(((well_p_width/num_electrode_cols)-25)/4) 0 ((well_p_width/num_electrode_cols)-25)/4 20], 'ButtonPushedFcn', @(reanalyse_beat_button,event) reanalyseBeatButtonPushed(well_count, electrode_count, elec_id, elec_ax));
                    
                    
                    hold(elec_ax,'on')

                    if strcmp(spon_paced, 'paced')
                        num_beats = length(well_electrode_data(well_count).electrode_data(electrode_count).Stims);
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
                        %elec_ax.XLim = [electrode_data(electrode_count).beat_start_times(mid_beat) electrode_data(electrode_count).beat_start_times(mid_beat+1)];
                        
                        if strcmp(spon_paced, 'paced')
                            time_start = well_electrode_data(well_count).electrode_data(electrode_count).Stims(mid_beat);
                            time_end = well_electrode_data(well_count).electrode_data(electrode_count).Stims(mid_beat+1);

                            time_reg_start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).time >= time_start);
                            time_reg_end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).time >= time_end);
                            %plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).Stims, well_electrode_data(well_count).electrode_data(electrode_count).Stim_volts, 'mo');
                            
                            plot(elec_ax,well_electrode_data(well_count). electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), well_electrode_data(well_count).electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));
                        
                            
                            plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).Stims(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).Stim_volts(mid_beat), 'm.', 'MarkerSize', 20);

                        elseif strcmp(spon_paced, 'paced bdt')
                            %{
                            time_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat);
                            time_end = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat+1);

                            time_reg_start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).time >= time_start);
                            time_reg_end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).time >= time_end);
                            
                            
                            plot(elec_ax,well_electrode_data(well_count). electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), well_electrode_data(well_count).electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));
                        
                            plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).data(time_reg_start_indx(1)), 'go');
                            
                            %}
                            time_start = ectopic_plus_stims(mid_beat);
                            time_end = ectopic_plus_stims(mid_beat+1);
                            
                            
                            
                            
                            
                            if ismember(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times , time_start)
                                if well_electrode_data(well_count).electrode_data(electrode_count).bdt < 0
                                    time_start = time_start - well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off;
                                end
                                time_reg_start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).time >= time_start);
                                time_reg_end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).time >= time_end);
                            
                                plot(elec_ax, ectopic_plus_stims(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).data(time_reg_start_indx(1)), 'g.', 'MarkerSize', 20);
                            
                            else
                                time_reg_start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).time >= time_start);
                                time_reg_end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).time >= time_end);
                            
                                plot(elec_ax, ectopic_plus_stims(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).data(time_reg_start_indx(1)), 'm.', 'MarkerSize', 20);
                            
                            end
                            
                            
                            plot(elec_ax,well_electrode_data(well_count).electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), well_electrode_data(well_count).electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));
                        
                        else
                            %{
                            if well_electrode_data(well_count).electrode_data(electrode_count).bdt < 0
                                time_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat)-well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off;
                            
                            else
                                time_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat);
                            
                            end
                            %}
                            if well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat) - well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off > well_electrode_data(well_count).electrode_data(electrode_count).time(1)

                                time_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat)-well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off;
                            else

                                time_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat);

                            end 
                                
                            time_end = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat+1);

                            time_reg_start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).time >= time_start);
                            time_reg_end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).time >= time_end);
                            
                            
                            plot(elec_ax,well_electrode_data(well_count). electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), well_electrode_data(well_count).electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));
                        
                            %plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).data(time_reg_start_indx(1)), 'g.', 'MarkerSize', 20);
                            plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).beat_start_volts(mid_beat), 'g.', 'MarkerSize', 20);

                        end
                        
                        
                        %if strcmp(spon_paced, 'paced bdt')
                        t_wave_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).t_wave_peak_times >= time_start);
                        t_wave_indx = t_wave_indx(1);
                        t_wave_peak_time = well_electrode_data(well_count).electrode_data(electrode_count).t_wave_peak_times(t_wave_indx);
                        t_wave_p = well_electrode_data(well_count).electrode_data(electrode_count).t_wave_peak_array(t_wave_indx);
                        if ~isnan(t_wave_peak_time) && ~isnan(t_wave_p)
                            plot(elec_ax, t_wave_peak_time, t_wave_p, 'c.', 'MarkerSize', 20);
                        end

                        max_depol_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).max_depol_time_array >= time_start);
                        max_depol_indx = max_depol_indx(1);

                        min_depol_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).min_depol_time_array >= time_start);
                        min_depol_indx = min_depol_indx(1);
                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).max_depol_time_array(max_depol_indx), well_electrode_data(well_count).electrode_data(electrode_count).max_depol_point_array(max_depol_indx), 'r.', 'MarkerSize', 20);
                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).min_depol_time_array(min_depol_indx), well_electrode_data(well_count).electrode_data(electrode_count).min_depol_point_array(min_depol_indx), 'b.', 'MarkerSize', 20);

                        %plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).data(time_reg_start_indx(1)), 'go');


                        %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');

                        act_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).activation_times >= time_start);
                        act_indx = act_indx(1);
                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).activation_times(act_indx), well_electrode_data(well_count).electrode_data(electrode_count).activation_point_array(act_indx), 'k.', 'MarkerSize', 20);

                         %{
                        else
                            t_wave_peak_time = well_electrode_data(well_count).electrode_data(electrode_count).t_wave_peak_times(mid_beat);
                            t_wave_p = well_electrode_data(well_count).electrode_data(electrode_count).t_wave_peak_array(mid_beat);
                            if ~isnan(t_wave_peak_time) && ~isnan(t_wave_p)
                                plot(elec_ax, t_wave_peak_time, t_wave_p, 'co');
                            end
                            plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).max_depol_time_array(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).max_depol_point_array(mid_beat), 'ro');
                            plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).min_depol_time_array(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).min_depol_point_array(mid_beat), 'bo');

                            %plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).data(time_reg_start_indx(1)), 'go');


                            %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                            plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).activation_times(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).activation_point_array(mid_beat), 'ko');

                        end
                         %}
                    else
                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).time, well_electrode_data(well_count).electrode_data(electrode_count).data);
                    
                        t_wave_peak_times = well_electrode_data(well_count).electrode_data(electrode_count).t_wave_peak_times;
                        t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                        t_wave_peak_array = well_electrode_data(well_count).electrode_data(electrode_count).t_wave_peak_array;
                        t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                        plot(elec_ax, t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).max_depol_time_array, well_electrode_data(well_count).electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).min_depol_time_array, well_electrode_data(well_count).electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

                        %[~, beat_start_volts, ~] = intersect(well_electrode_data(well_count).electrode_data(electrode_count).time, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
                        %beat_start_volts = well_electrode_data(well_count).electrode_data(electrode_count).data(beat_start_volts);


                        if strcmp(spon_paced, 'paced')
                            
                            plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).Stims, well_electrode_data(well_count).electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);
                            
                        elseif strcmp(spon_paced, 'paced bdt')
                            plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
                            plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).Stims, well_electrode_data(well_count).electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);
                            
                        else
                            plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
                            
                            
                            
                        end
                        %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');

                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).activation_times, well_electrode_data(well_count).electrode_data(electrode_count).activation_point_array, 'k.', 'MarkerSize', 20);

                        % Zoom in on beat in the middle
    
                    end
                    %well_electrode_data(well_count, electrode_count).save_fig = gcf;
                    %electrode_data(electrode_count).save_fig = gcf;
                    hold(elec_ax,'off')
                else
                    if strcmp(stable_ave_analysis, 'time_region') 
                        
                        % Need T-wave input panels
                        if isempty(well_electrode_data(well_count).electrode_data(electrode_count).electrode_id)
                           continue 
                        end
                        elec_pan = uipanel(well_pan, 'Title', well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);
                    
                        undo_elec_pan = uipanel(well_pan, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);
                    
                        undo_reject_electrode_button = uibutton(undo_elec_pan,'push','Text', 'Undo Reject Electrode', 'Position', [0 0 well_p_width/num_electrode_cols well_p_height/num_electrode_rows], 'ButtonPushedFcn', @(reject_electrode_button,event) undoRejectElectrodeButtonPushed(elec_pan, undo_elec_pan, electrode_count));

                        set(undo_elec_pan, 'Visible', 'off');
                        
                        reject_electrode_button = uibutton(elec_pan,'push','Text', 'Reject Electrode', 'Position', [0 20 ((well_p_width/num_electrode_cols)-25)/3 20], 'ButtonPushedFcn', @(reject_electrode_button,event) rejectElectrodeButtonPushed(reject_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count, undo_elec_pan));
        
                        adv_stats_elec_button = uibutton(elec_pan,'push','Text', 'Advanced Results View', 'Position', [((well_p_width/num_electrode_cols)-25)/3 20 ((well_p_width/num_electrode_cols)-25)/3 20], 'ButtonPushedFcn', @(adv_stats_elec_button,event) expandAveTimeRegionElectrodePushed(adv_stats_elec_button, electrode_count));

                        reanalyse_electrode_button = uibutton(elec_pan,'push','Text', 'Reanalyse', 'Position', [2*(((well_p_width/num_electrode_cols)-25)/3) 20 ((well_p_width/num_electrode_cols)-25)/3 20], 'ButtonPushedFcn', @(reanalyse_electrode_button,event) reanalyseTimeRegionElectrodeButtonPushed(well_count, elec_id));
                    
                        
                        
                        elec_ax = uiaxes(elec_pan, 'Position', [0 40 (well_p_width/num_electrode_cols)-25 (well_p_height/num_electrode_rows)-60]);
                        
                        
                        hold(elec_ax,'on')
                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time, well_electrode_data(well_count).electrode_data(electrode_count).average_waveform);
                        %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_time, well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_point, 'r.', 'MarkerSize', 20);
                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_time, well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_point, 'b.', 'MarkerSize', 20);
                        
                        plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time, well_electrode_data(well_count).electrode_data(electrode_count).average_waveform(well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time == well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time), 'k.', 'MarkerSize', 20);

                        if well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time ~= 0 
                            peak_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time >= well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time);
                            peak_indx = peak_indx(1);
                            t_wave_peak = well_electrode_data(well_count).electrode_data(electrode_count).average_waveform(peak_indx);
                            plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time, t_wave_peak, 'c.', 'MarkerSize', 20);
                        end
  
                        
                        t_wave_time_text = uieditfield(elec_pan,'Text', 'Value', 'T-wave Peak Time', 'FontSize', 8, 'Position', [0 0 ((well_p_width/num_electrode_cols)-25)/2 20], 'Editable','off');
                        t_wave_time_ui = uieditfield(elec_pan, 'numeric', 'Tag', 'T-Wave', 'Position', [((well_p_width/num_electrode_cols)-25)/2 0 ((well_p_width/num_electrode_cols)-25)/2 20], 'FontSize', 8, 'ValueChangedFcn',@(t_wave_time_ui,event) changeTWaveTime(t_wave_time_ui, elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time, well_electrode_data(well_count).electrode_data(electrode_count).average_waveform, electrode_count, well_pan));

                        set(t_wave_time_text, 'Visible', 'off');
                        set(t_wave_time_ui, 'Visible', 'off');
                        
                        manual_t_wave_button = uibutton(elec_pan,'push','Text', 'Manual T-Wave Peak Input', 'Position', [0 0 ((well_p_width/num_electrode_cols)-25)/2 20], 'ButtonPushedFcn', @(manual_t_wave_button,event) manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui));
                
                      
 
                    end
                end
            end
            
        end
        
        if strcmp(beat_to_beat, 'off')
            if strcmp(stable_ave_analysis, 'time_region')
                
               %reanalyse_button = uibutton(main_well_pan,'push','Text', 'Re-analyse Electrodes', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseTimeRegionButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
               reanalyse_well_button = uibutton(main_well_pan,'push','Text', 'Re-analyse Well', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_well_button,event) reanalyseTimeRegionWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
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

            peak_indx = find(time >= get(t_wave_time_ui, 'Value'));
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
            %electrode_data(electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');

           
           
            
        end
        
        function rejectElectrodeButtonPushed(reject_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count, undo_elec_pan)
            
            %electrode_data(electrode_count).rejected = 1;
            %well_electrode_data(well_count,electrode_count).rejected = 1;
            well_electrode_data(well_count).electrode_data(electrode_count).rejected = 1;
            
            set(elec_pan, 'Visible', 'off');
            set(undo_elec_pan, 'Visible', 'on'); 
        end
        
        function undoRejectElectrodeButtonPushed(elec_pan, undo_elec_pan, electrode_count)
            %electrode_data(electrode_count).rejected = 0;
            %well_electrode_data(well_count,electrode_count).rejected = 0;
            well_electrode_data(well_count).electrode_data(electrode_count).rejected = 0;
            
            set(elec_pan, 'Visible', 'on');
            set(undo_elec_pan, 'Visible', 'off'); 
            
            
        end
        function expandAveTimeRegionElectrodePushed(adv_stats_elec_button, electrode_count)
            %%disp(electrode_data.electrode_id)

            electrode_data = well_electrode_data(well_count).electrode_data(electrode_count);
            adv_elec_fig = uifigure;
            movegui(adv_elec_fig,'center')
            adv_elec_fig.WindowState = 'maximized';
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


            adv_close_button = uibutton(adv_elec_panel,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(adv_close_button,event) closeSingleFig(adv_close_button, adv_elec_fig));

            adv_ax = uiaxes(adv_elec_p, 'Position', [0 50 well_p_width well_p_height-50]);
            hold(adv_ax,'on')
            plot(adv_ax, electrode_data.ave_wave_time, electrode_data.average_waveform);
            %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
            plot(adv_ax, electrode_data.ave_max_depol_time, electrode_data.ave_max_depol_point, 'r.', 'MarkerSize', 20);
            plot(adv_ax, electrode_data.ave_min_depol_time, electrode_data.ave_min_depol_point, 'b.', 'MarkerSize', 20);
            plot(adv_ax, electrode_data.ave_activation_time, electrode_data.average_waveform(electrode_data.ave_wave_time == electrode_data.ave_activation_time), 'k.', 'MarkerSize', 20);

            elec_peak_indx = find(electrode_data.ave_wave_time >= electrode_data.ave_t_wave_peak_time);
            elec_peak_indx = elec_peak_indx(1);
            elec_t_wave_peak = electrode_data.average_waveform(elec_peak_indx);
            plot(adv_ax, electrode_data.ave_t_wave_peak_time, elec_t_wave_peak, 'c.', 'MarkerSize', 20);


            legend(adv_ax, 'signal', 'max depol.', 'min depol.', 'activation point', 'T-wave peak')

            %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
            %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
            hold(adv_ax,'off')
                
        end
            
        function expandElectrodeButtonPushed(expand_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count)
            expand_elec_fig = uifigure;
            expand_elec_fig.Name = well_electrode_data(well_count).electrode_data(electrode_count).electrode_id;
            movegui(expand_elec_fig,'center')
            expand_elec_fig.WindowState = 'maximized';
            expand_elec_panel = uipanel(expand_elec_fig, 'Position', [0 0 screen_width screen_height]);
                
            expand_elec_p = uipanel(expand_elec_panel, 'Position', [0 0 well_p_width well_p_height]);

            electrode_data = well_electrode_data(well_count).electrode_data;
            t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
            t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
            t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
            t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
            activation_times = electrode_data(electrode_count).activation_times;
            activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
            elec_FPDs = [t_wave_peak_times - activation_times];

            elec_amps = [electrode_data(electrode_count).max_depol_point_array - electrode_data(electrode_count).min_depol_point_array];

            elec_slopes = [electrode_data(electrode_count).depol_slope_array];

            elec_bps = [electrode_data(electrode_count).beat_periods];

            elec_mean_FPD = mean(elec_FPDs);
            elec_mean_amp = mean(elec_amps);
            elec_mean_slope = mean(elec_slopes);
            elec_mean_bp = mean(elec_bps);
            
           

            if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'spon')
                text_box_height = screen_height/14;
                
                elec_bdt_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('BDT = ', num2str(electrode_data(electrode_count).bdt)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*12 200 text_box_height], 'Editable','off');
                elec_min_bp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('min BP = ', num2str(electrode_data(electrode_count).min_bp)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*11 200 text_box_height], 'Editable','off');
                elec_max_bp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('max BP = ', num2str(electrode_data(electrode_count).max_bp)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*10 200 text_box_height], 'Editable','off');
         
            elseif strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced bdt')
                text_box_height = screen_height/15;
                
                elec_bdt_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('BDT = ', num2str(electrode_data(electrode_count).bdt)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*13 200 text_box_height], 'Editable','off');
                elec_min_bp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('min BP = ', num2str(electrode_data(electrode_count).min_bp)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*12 200 text_box_height], 'Editable','off');
                elec_max_bp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('max BP = ', num2str(electrode_data(electrode_count).max_bp)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*11 200 text_box_height], 'Editable','off');
                elec_stim_spike_hold_off_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('Stim-spike hold-off = ', num2str(electrode_data(electrode_count).stim_spike_hold_off)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*10 200 text_box_height], 'Editable','off');
                
            elseif strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced')
                text_box_height = screen_height/12;
                
                elec_stim_spike_hold_off_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('Stim-spike hold-off = ', num2str(electrode_data(electrode_count).stim_spike_hold_off)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*10 200 text_box_height], 'Editable','off');
                
            end
            
            elec_post_spike_input_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('Post-spike = ', num2str(electrode_data(electrode_count).post_spike_hold_off)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*9 200 text_box_height], 'Editable','off');
            elec_t_wave_offset_input_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('T-wave offset = ', num2str(electrode_data(electrode_count).t_wave_offset)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*8 200 text_box_height], 'Editable','off');
            elec_t_wave_duration_input_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('T-wave duration = ', num2str(electrode_data(electrode_count).t_wave_duration)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*7 200 text_box_height], 'Editable','off');
            elec_t_wave_shape_input_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('T-wave shape = ', electrode_data(electrode_count).t_wave_shape), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*6 200 text_box_height], 'Editable','off');
            
            
            elec_fpd_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('Mean FPD = ', num2str(elec_mean_FPD)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*5 200 text_box_height], 'Editable','off');
            elec_amp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('Mean Depol. Ampl. = ', num2str(elec_mean_amp)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*4 200 text_box_height], 'Editable','off');
            elec_slope_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('Mean Depol. Slope = ', num2str(elec_mean_slope)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*3 200 text_box_height], 'Editable','off');
            elec_bp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('Mean Beat Period =', num2str(elec_mean_bp)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*2 200 text_box_height], 'Editable','off');

            elec_stat_plots_button = uibutton(expand_elec_panel,'push','Text','View Plots', 'Position', [screen_width-220 text_box_height 200 text_box_height], 'FontSize', 10,'ButtonPushedFcn', @(elec_stat_plots_button,event) statPlotsButtonPushed(elec_stat_plots_button, expand_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, electrode_data(electrode_count)));

            expand_close_button = uibutton(expand_elec_panel,'push','Text', 'Close', 'FontSize', 10,'Position', [screen_width-220 0 120 text_box_height], 'ButtonPushedFcn', @(expand_close_button,event) closeExpandButtonPushed(expand_close_button, expand_elec_fig));

            exp_ax = uiaxes(expand_elec_p, 'Position', [0 50 well_p_width well_p_height-50]);
            hold(exp_ax,'on')
            plot(exp_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);
            plot(exp_ax, t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
            plot(exp_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
            plot(exp_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

            %[~, beat_start_volts, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
            %beat_start_volts =  electrode_data(electrode_count).data(beat_start_volts);

            %plot(exp_ax, electrode_data(electrode_count).beat_start_times, beat_start_volts, 'go');

            if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced') 
                        

                plot(exp_ax, electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);
            elseif strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced bdt')

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
            
            if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced bdt')
                legend(exp_ax, 'signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'stimulus point', 'activation point')
            elseif strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced') 
                legend(exp_ax, 'signal', 'T-wave peak', 'max depol.', 'min depol.', 'stimulus point', 'activation point')

            else
                legend(exp_ax, 'signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point')

            end
            hold(exp_ax,'off')
            
            function closeExpandButtonPushed(expand_close_button, expand_elec_fig)
                
                %set(expand_elec_fig, 'Visible', 'off');
                delete(expand_close_button)
                close(expand_elec_fig)
            end


            function statPlotsButtonPushed(stat_plots_button, well_res_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, electrode_data)
                stat_plots_fig = uifigure;
                movegui(stat_plots_fig,'center')       
                stat_plots_fig.WindowState = 'maximized';
                stat_plots_fig.Name = strcat(electrode_data.electrode_id, '_', 'Results Plots');
                % left bottom width height
                stats_pan = uipanel(stat_plots_fig, 'Position', [0 0 screen_width screen_height]);


                plots_p = uipanel(stats_pan, 'Position', [0 0 well_p_width well_p_height]);

                stats_close_button = uibutton(stats_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(stats_close_button,event) closeSingleFig(stats_close_button, stat_plots_fig));

                % BASED ON THE CYCLE LENGTHS PERFROM ARRHYTHMIA ANALYSIS
                
                %[arrhythmia_indx] = arrhythmia_analysis(electrode_data.beat_num_array(2:end), electrode_data.cycle_length_array(2:end));
                if ~isempty(electrode_data.arrhythmia_indx)
                    %disp('detected arrhythmia!')
                    arrhythmia_text = uieditfield(stats_pan,'Text', 'Value', strcat('Arrhthmic Event Detected Between Beats:', num2str(electrode_data.arrhythmia_indx(1)), '-', num2str(electrode_data.arrhythmia_indx(end))), 'FontSize', 10, 'Position', [screen_width-220 100 250 50], 'Editable','off');

                end
                
                cl_ax = uiaxes(plots_p, 'Position', [0 0 well_p_width well_p_height/4]);
                beat_num_array = electrode_data.beat_num_array(2:end);
                cycle_length_array = electrode_data.cycle_length_array(2:end);
                plot(cl_ax, beat_num_array, cycle_length_array, 'b.', 'MarkerSize', 20);
                if  ~isempty(electrode_data.arrhythmia_indx)
                    hold(cl_ax, 'on')
                    plot(cl_ax, beat_num_array(electrode_data.arrhythmia_indx), cycle_length_array(electrode_data.arrhythmia_indx), 'r.', 'MarkerSize', 20);
                end
                xlabel(cl_ax, 'Beat Number');
                ylabel(cl_ax,'Cycle Length (s)');
                ylim(cl_ax, [0 max(cycle_length_array)])
                title(cl_ax, strcat('Cycle Length per Beat', {' '}, electrode_data.electrode_id),  'Interpreter', 'none');


                bp_ax = uiaxes(plots_p, 'Position', [0 well_p_height/4 well_p_width well_p_height/4]);
                plot(bp_ax, electrode_data.beat_num_array, electrode_data.beat_periods, 'b.', 'MarkerSize', 20);
                xlabel(bp_ax,'Beat Number');
                ylabel(bp_ax,'Beat Period (s)');
                ylim(bp_ax, [0 max(electrode_data.beat_periods)])
                title(bp_ax, strcat('Beat Period per Beat', {' '}, electrode_data.electrode_id),  'Interpreter', 'none');


                clcl_ax = uiaxes(plots_p, 'Position', [0 2*(well_p_height/4) well_p_width well_p_height/4]);
                plot(clcl_ax, electrode_data.cycle_length_array(2:end-1), electrode_data.cycle_length_array(3:end), 'b.', 'MarkerSize', 20);
                xlabel(clcl_ax,'Cycle Length Previous Beat (s)');
                ylabel(clcl_ax,'Cycle Length (s)');
                title(clcl_ax, strcat('Cycle Length vs Previous Beat Cycle Length', {' '}, electrode_data.electrode_id),  'Interpreter', 'none');

                t_wave_peak_times = electrode_data.t_wave_peak_times;
                t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                t_wave_peak_array = electrode_data.t_wave_peak_array;
                t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                activation_times = electrode_data.activation_times;
                activation_times = activation_times(~isnan(electrode_data.t_wave_peak_times));
                fpd_beats = electrode_data.beat_num_array(~isnan(electrode_data.t_wave_peak_times));
                elec_FPDs = [t_wave_peak_times - activation_times];
                fpd_ax = uiaxes(plots_p, 'Position', [0 3*(well_p_height/4) well_p_width well_p_height/4]);
                plot(fpd_ax, fpd_beats, elec_FPDs, 'b.', 'MarkerSize', 20);
                xlabel(fpd_ax,'Beat Number');
                ylabel(fpd_ax,'FPD (s)');
                ylim(fpd_ax, [0 max(elec_FPDs)])
                title(fpd_ax, strcat('FPD per Beat Num', {' '}, electrode_data.electrode_id),  'Interpreter', 'none');


            end

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

                    for well_panel_child = 1:length(well_panel_children)
                        
                        if isempty(well_panel_children(well_panel_child))
                           continue 
                        end

                        if strcmp(get(well_panel_children(well_panel_child), 'Title'), elec_id)
                            
                            if strcmp(spon_paced, 'paced')
                                num_beats = length(well_electrode_data(well_count).electrode_data(electrode_count).Stims);
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
                                        end
                                    else
                                        post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off*2;
                                    end
                                    
                                    
                                    for plot_child = 1:length(axes_children)
                                        x_data = axes_children(plot_child).XData;
                                        if length(x_data) > 1
                                            set(electrode_panel_children(elec_panel_child), 'xlim', [x_data(1) x_data(1)+post_spike_hold_off])
                                            break;
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
                                    post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off;
                                    t_wave_duration = well_electrode_data(well_count).electrode_data(electrode_count).t_wave_duration;
                                    
                                    for plot_child = 1:length(axes_children)
                                        x_data = axes_children(plot_child).XData;
                                        if length(x_data) > 1
                                            axis_time_start = x_data(1);
                                            break;
                                            %set(electrode_panel_children(elec_panel_child), 'xlim', [x_data(1) x_data(1)+post_spike_hold_off])
                                        end
                                    end
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
 
                                    
                                    for plot_child = 1:length(axes_children)
                                        x_data = axes_children(plot_child).XData;
                                        if length(x_data) > 1
                                            
                                            set(electrode_panel_children(elec_panel_child), 'xlim', [x_data(1) x_data(end)])
                                            break;
                                        end
                                    end
                                    
                                    
                                end
                            end
                        end
                    end
                end
            end
            set(restore_full_beat_button, 'visible', 'off')
        end
        
        function assessConductionVelocityModelButtonPushed(assess_conduction_velocity_model_button, well_elec_fig, well_count)
        
            conduction_velocity_figure = uifigure;
            conduction_velocity_figure.Name = 'Conduction Velocity Model';
            movegui(conduction_velocity_figure,'center')
            conduction_velocity_figure.WindowState = 'maximized';
            con_vel_panel = uipanel(conduction_velocity_figure, 'Position', [0 0 screen_width screen_height]);
            close_con_vel_button = uibutton(con_vel_panel,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_con_vel_button,event) closeSingleFig(close_con_vel_button, conduction_velocity_figure));

            
            
            if strcmp(well_electrode_data(well_count).spon_paced, 'spon')
                el_count = 1;
                dist_array = [];
                %act_array = one(num_electrode_rows*num_electrode_cols);
                act_array = [];
                electrode_ids = [];
                for er = num_electrode_rows:-1:1
                    for ec = num_electrode_cols:-1:1
                        elec_id = well_electrode_data(well_count).electrode_data(el_count).electrode_id;

                        if isempty(elec_id)
                            continue
                        end
                        act_array = [act_array; well_electrode_data(well_count).electrode_data(el_count).activation_times(2)];
                        electrode_ids = [electrode_ids; elec_id];
                        el_count = el_count + 1;

                    end
                end
                min_act_indx = find(act_array == min(act_array));
                origin_electrode = electrode_ids(min_act_indx(1));

                split_orig_elec = strsplit(origin_electrode, '_');
                origin_elec_row = str2num(split_orig_elec{2});
                origin_elec_col = str2num(split_orig_elec{3});

                el_count = 1;
                act_array =[];
                for er = num_electrode_rows:-1:1
                    for ec = 1:num_electrode_cols
                        elec_id = well_electrode_data(well_count).electrode_data(el_count).electrode_id;

                        if isempty(elec_id)
                            continue
                        end

                        %%x = y = 350um
                        split_elec = strsplit(elec_id, '_');
                        elec_row = str2num(split_elec{2});
                        elec_col = str2num(split_elec{3});

                        if elec_row < origin_elec_row
                            row_dist = origin_elec_row - elec_row;

                        else
                            row_dist = elec_row - origin_elec_row;
                        end


                        if elec_col < origin_elec_col
                            col_dist = origin_elec_col - elec_col;
                        else
                            col_dist = elec_col - origin_elec_col;

                        end

                        dist = sqrt(((350*col_dist)^2)+((350*row_dist)^2));


                        if length(well_electrode_data(well_count).electrode_data(el_count).activation_times) < 2
                            continue
                        end
                        dist_array = [dist_array; dist];

                        act_array =[act_array; well_electrode_data(well_count).electrode_data(el_count).activation_times(2)];
                        el_count = el_count + 1;
                    end
                end
            else
                el_count = 1;
                dist_array = [];
                act_array =[];
                for er = num_electrode_rows:-1:1
                    for ec = num_electrode_cols:-1:1
                        elec_id = well_electrode_data(well_count).electrode_data(el_count).electrode_id;

                        if isempty(elec_id)
                            continue
                        end
                        
                        dist = sqrt(((350*ec)^2)+((350*er)^2));


                        if length(well_electrode_data(well_count).electrode_data(el_count).activation_times) < 2
                            continue
                        end
                        dist_array = [dist_array; dist];

                        act_array =[act_array; well_electrode_data(well_count).electrode_data(el_count).activation_times(2)];
                        el_count = el_count + 1;
                    end
                end
            end

            if isempty(dist_array)
                close(conduction_velocity_figure)
                return
            end
            
            conduction_velocity = well_electrode_data(well_count).conduction_velocity;
            
            display_con_vel = sprintf('Conduction Velcoty = %f', conduction_velocity);
            
            %display_units = sprintf('%im', '\mu');
            display_units = 'dμm/dt';
            
            display_con_vel= strcat(display_con_vel, [' '],  display_units);
            
            conduction_velocity_text = uieditfield(con_vel_panel,'Text', 'Value', display_con_vel, 'FontSize', 12, 'Position', [screen_width-300 150 260 50], 'Editable','off');
    
            lin_eqn = fittype(sprintf('(1/%f)*x+b', conduction_velocity));
    
            %model = fit(dist_array, act_array, lin_eqn)
            model = well_electrode_data(well_count).conduction_velocity_model;
            plot_model = (model.m)*dist_array+model.b;

            con_vel_ax = uiaxes(con_vel_panel, 'Position', [0 0 well_p_width well_p_height]);
            plot(con_vel_ax, dist_array, act_array, '.', 'MarkerSize', 20)
            hold(con_vel_ax, 'on')
            plot(con_vel_ax, dist_array , plot_model)
            xlabel(con_vel_ax, 'Distance from Origin Electrode (\mum)')
            ylabel(con_vel_ax, 'Electrode Activation Time (s)')
            legend(con_vel_ax, 'Activation Times', 'Model')
            
            
            
            
        end
            
        function reanalyseWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            set(well_elec_fig, 'Visible', 'off')
            %[well_electrode_data(well_count, :)] = reanalyse_b2b_well_analysis(electrode_data, num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID);
            [well_electrode_data(well_count)] = reanalyse_b2b_well_analysis(well_electrode_data(well_count), num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID);
            
            %electrode_data = well_electrode_data(well_count).electrode_data;
        end
        
        function reanalyseTimeRegionWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            set(well_elec_fig, 'Visible', 'off')
            [well_electrode_data(well_count).electrode_data] = reanalyse_time_region_well(well_electrode_data(well_count).electrode_data, num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID);
            %electrode_data = well_electrode_data(well_count).electrode_data;
        end
        
        function reanalyseElectrodeButtonPushed(well_count, elec_id)
            
            [well_electrode_data(well_count)] = electrode_analysis(well_electrode_data(well_count), num_electrode_rows, num_electrode_cols, elec_id, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis);
                
        end
        
        
        
        function reanalyseTimeRegionElectrodeButtonPushed(well_count, elec_id)
            [well_electrode_data(well_count).electrode_data] = electrode_time_region_analysis(well_electrode_data(well_count).electrode_data, num_electrode_rows, num_electrode_cols, elec_id, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis);
        end
        
        function reanalyseBeatButtonPushed(well_count, electrode_count, elec_id, elec_ax)
            reanalyse_beat_fig = uifigure;
            reanalyse_beat_panel = uipanel(reanalyse_beat_fig, 'Position', [0 0 screen_width screen_height]);
            
            beat_num_text = uieditfield(reanalyse_beat_panel,'Text', 'FontSize', 12, 'Value', 'Reanalyse Beat Number', 'Position', [10 150 200 40], 'Editable','off');
            beat_num_ui = uieditfield(reanalyse_beat_panel, 'numeric', 'Tag', 'Num Beat Patterns', 'Position', [10 100 200 40], 'FontSize', 12, 'Value', 1, 'ValueChangedFcn', @(beat_num_ui,event) changedNumBeats(beat_num_ui, electrode_count));
            
            beats_range_1_text = uieditfield(reanalyse_beat_panel,'Text', 'FontSize', 12, 'Value', 'Start Beat Range', 'Position', [10 150 150 40], 'Editable','off');
            beats_time_range_1_text = uieditfield(reanalyse_beat_panel,'Text', 'FontSize', 12, 'Value', 'Beat Time Range Start (s)', 'Position', [10 150 150 40], 'Editable','off');
            beats_range_1_ui = uieditfield(reanalyse_beat_panel, 'numeric', 'Tag', 'Start Beat Range', 'Position', [10 100 150 40], 'FontSize', 12, 'Value', 1, 'ValueChangedFcn', @(beats_range_1_ui,event) changedNumBeats(beats_range_1_ui, electrode_count));
            
            beats_range_2_text = uieditfield(reanalyse_beat_panel,'Text', 'FontSize', 12, 'Value', 'End Beat Range', 'Position', [160 150 150 40], 'Editable','off');
            beats_time_range_2_text = uieditfield(reanalyse_beat_panel,'Text', 'FontSize', 12, 'Value', 'Beat Time Range End (s)', 'Position', [160 150 150 40], 'Editable','off');
            beats_range_2_ui = uieditfield(reanalyse_beat_panel, 'numeric', 'Tag', 'End Beat Range', 'Position', [160 100 150 40], 'FontSize', 12, 'Value', 1, 'ValueChangedFcn', @(beats_range_2_ui,event) changedNumBeats(beats_range_2_ui, electrode_count));
            
            
            reanalyse_button = uibutton(reanalyse_beat_panel,'push','Text', 'Reanalyse Beats',  'BackgroundColor', '#3dd4d1', 'Position', [210 50 100 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseSelectedBeats(reanalyse_button, reanalyse_beat_fig));
            remove_button = uibutton(reanalyse_beat_panel,'push','Text', 'Remove Beats',  'BackgroundColor', '#3dd4d1', 'Position', [210 0 100 50], 'ButtonPushedFcn', @(remove_button,event) removeSelectedBeats(remove_button, reanalyse_beat_fig));
            

            range_button = uibutton(reanalyse_beat_panel,'push','Text', 'Enter Beat Number Range', 'Position', [210 100 150 50], 'ButtonPushedFcn', @(range_button,event) numBeatsRangeButtonPressed('off', 'on', 'no'));
            
            time_range_button = uibutton(reanalyse_beat_panel,'push','Text', 'Enter Beat Time Range', 'Position', [360 100 150 50], 'ButtonPushedFcn', @(time_range_button,event) numBeatsRangeButtonPressed('off', 'on', 'yes'));
               
            num_beats_button = uibutton(reanalyse_beat_panel,'push','Text', 'Enter Num Beats', 'Position', [310 100 100 50], 'ButtonPushedFcn', @(num_beats_button,event) numBeatsRangeButtonPressed('on', 'off', 'N/A'));
            
            set(num_beats_button, 'visible', 'off')
            set(beats_range_1_text, 'visible', 'off')
            set(beats_time_range_1_text, 'visible', 'off')
            set(beats_range_1_ui, 'visible', 'off')
            set(beats_range_2_text, 'visible', 'off')
            set(beats_time_range_2_text, 'visible', 'off')
            set(beats_range_2_ui, 'visible', 'off')

            function changedNumBeats(ui, electrode_count)
                if strcmp(get(time_range_button, 'visible'), 'on')
                    % Means assessing beat number/index
                    if get(ui, 'Value') > length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times)
                        msgbox('The value entered was too large')
                        set(ui, 'Value', 1)
                    end
                    if get(ui, 'Value') < 1
                        msgbox('The value entered was too small')
                        set(ui, 'Value', 1)
                    end
                    
                else
                    if get(ui, 'Value') > well_electrode_data(well_count).electrode_data(electrode_count).time(end)
                        msgbox('The value entered was too large')
                        %disp(get(ui, 'tag'))
                        tag = get(ui, 'tag');
                        if contains(tag, 'End')
                            set(ui, 'Value', well_electrode_data(well_count).electrode_data(electrode_count).time(end))
                        else
                            set(ui, 'Value', well_electrode_data(well_count).electrode_data(electrode_count).time(1))
                        end
                        
                    end
                    if get(ui, 'Value') < well_electrode_data(well_count).electrode_data(electrode_count).time(1)
                        msgbox('The value entered was too small')
                        tag = get(ui, 'tag');
                        if contains(tag, 'End')
                            set(ui, 'Value', well_electrode_data(well_count).electrode_data(electrode_count).time(end))
                        else
                            set(ui, 'Value', well_electrode_data(well_count).electrode_data(electrode_count).time(1))
                        end
                    end
                end

            end
            
            function numBeatsRangeButtonPressed(action1, action2, time_range)
                
                
                set(beat_num_text, 'visible', action1)
                set(beat_num_ui, 'visible', action1)
                set(num_beats_button, 'visible', action2)
                
                set(beats_range_1_ui, 'visible', action2)
                set(beats_range_2_ui, 'visible', action2)
                
                if strcmp(action2, 'on')
                    if strcmp(time_range, 'no')
                        set(beats_range_1_text, 'visible', action2)
                        set(beats_range_2_text, 'visible', action2)
                        set(beats_time_range_1_text, 'visible', action1)
                        set(beats_time_range_2_text, 'visible', action1)
                        
                        
                        set(beats_range_1_ui, 'value', 1)
                        set(beats_range_2_ui, 'value', 1)
                    
                        
                        set(time_range_button, 'visible', action2)
                        set(range_button, 'visible', action1)
                        set(time_range_button, 'position', [410 100 150 50])
                        
                    elseif strcmp(time_range, 'yes')
                        set(beats_range_1_text, 'visible', action1)
                        set(beats_range_2_text, 'visible', action1)
                        set(beats_time_range_1_text, 'visible', action2)
                        set(beats_time_range_2_text, 'visible', action2)
                        
                        set(beats_range_1_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(1))
                        set(beats_range_2_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(end))
                    
                        set(time_range_button, 'visible', action1)
                        set(range_button, 'visible', action2)
                        
                        set(range_button, 'position', [410 100 150 50])
                    end
                    set(reanalyse_button, 'position', [310 50 100 50])
                    set(remove_button, 'position', [310 0 100 50])
                else
                    set(beats_range_1_text, 'visible', action2)
                    set(beats_range_2_text, 'visible', action2)
                    set(beats_time_range_1_text, 'visible', action2)
                    set(beats_time_range_2_text, 'visible', action2)
                    
                    set(reanalyse_button, 'position', [210 50 100 50])
                    set(remove_button, 'position', [210 0 100 50])
                    
                    set(time_range_button, 'position', [360 100 150 50])
                    set(range_button, 'position', [210 100 150 50])
                    
                    set(time_range_button, 'visible', action1)
                    set(range_button, 'visible', action1)
                end
                
                
                
            end
            
            function reanalyseSelectedBeats(reanalyse_button, reanalyse_beat_fig)
                
                if strcmp(get(range_button, 'visible'), 'off')
                    
                    
                    start_beat = get(beats_range_1_ui, 'value');
                    end_beat = get(beats_range_2_ui, 'value');
                    
                    if start_beat > end_beat
                        msgbox('Start beat entered after end beat. Choose new values please');

                        set(beats_range_1_ui, 'value', 1);
                        set(beats_range_2_ui, 'value', 1);
                        
                        return
                    end
                    
                    start_indx = start_beat;
                    if end_beat == length(well_electrode_data(well_count).electrode_data(electrode_count).beat_num_array)
                        end_indx = end_beat;
                    else
                        end_indx = end_beat+1;
                    end
                else
                    if strcmp(get(time_range_button, 'visible'), 'off')
                        start_beat = get(beats_range_1_ui, 'value');
                        end_beat = get(beats_range_2_ui, 'value');
                        
                        
                    
                        if start_beat > end_beat
                            msgbox('Start beat entered as time after end beat. Choose new values please');

                            set(beats_range_1_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(1));
                            set(beats_range_2_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(end));
                            return
                        end
                        
                        if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced')
                            start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).Stims >= start_beat);
                            start_indx = start_indx(1);
                            
                            end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).Stims >= end_beat);
                            end_indx = end_indx(1);
                        else
                            start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times >= start_beat);
                            
                            
                            if isempty(start_indx)
                                if start_beat < well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(1)
                                    start_indx = 1;
                                else
                                    start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times <= start_beat);
                                    start_indx = start_indx(1);
                                    if isempty(start_indx)
                                        start_indx = 1;
                                        
                                    end
                                end
                                
                            else
                                
                                start_indx = start_indx(1);
                            end
                            
                            end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times >= end_beat);
                            
                            if isempty(end_indx)
                                if end_beat > well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(end)
                                    end_indx = length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
                                else
                                    end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times <= end_beat);
                                    end_indx = end_indx(1);
                                    if isempty(end_indx)
                                        end_indx = length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
                                        
                                    end
                                end
                            else
                                end_indx = end_indx(1);
                            end
                        end
                        
                        
            
                    else
                        beat_num = get(beat_num_ui, 'value');
                        start_indx = beat_num;
                        if beat_num == length(well_electrode_data(well_count).electrode_data(electrode_count).beat_num_array)
                            end_indx = beat_num;
                        else
                            end_indx = beat_num+1;
                        end
                    
                    end
                end
                negative_skip = 'n/a';
                reanalysed_post_spike = nan;
                if strcmp(get(time_range_button, 'visible'), 'on')
                    
                    if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'spon')
                    
                        if well_electrode_data(well_count).electrode_data(electrode_count).bdt < 0
                           reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(start_indx);

                           %if reanalyse_time_region_start - well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off > well_electrode_data(well_count).electrode_data(electrode_count).time(1)
                              % reanalyse_time_region_start = reanalyse_time_region_start-well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off;

                           %end



                        else

                           reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(start_indx);

                        end
                        reanalyse_time_region_end = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(end_indx);
                
                    else
                        
                        reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).Stims(start_indx);

                        reanalyse_time_region_end = well_electrode_data(well_count).electrode_data(electrode_count).Stims(end_indx);
                
                    end
                    
                else
                    %{
                    reanalyse_time_region_start = start_beat;
                    
                    reanalyse_time_region_end = end_beat;
                    %}
                    if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'spon')
                    
                        negative_skip = 'no';
                        if well_electrode_data(well_count).electrode_data(electrode_count).bdt < 0
                            disp('Whole electrode negative bdt');
                           reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(start_indx);

                           if reanalyse_time_region_start - well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off > well_electrode_data(well_count).electrode_data(electrode_count).time(1)
                              reanalyse_time_region_start = reanalyse_time_region_start-well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off;

                           end



                        else
                            %well_electrode_data(well_count).electrode_data(electrode_count).warning_array(start_indx)
                            first_beat_warning = well_electrode_data(well_count).electrode_data(electrode_count).warning_array{start_indx};
                            
                            %if ~isempty(first_beat_warning)
                            %    first_beat_warning = first_beat_warning{1};
                            %end
                            reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(start_indx);

                           if contains(first_beat_warning, 'Reanalysed')
                               split_one = strsplit(first_beat_warning, 'BDT=');
                               split_two = strsplit(split_one{1, 2}, ',');
                               reanalysed_bdt = str2num(split_two{1});
                               
                               if reanalysed_bdt < 0
                                   disp('Previous reanalyses have been negative. whole electrode has been analysed with positive');
                                   negative_skip = 'yes';
                                   postspike_tag = split_two{2};
                                   split_postspike = strsplit(postspike_tag, '=');
                                   reanalysed_post_spike = str2num(split_postspike{2});
                                   
                                   if reanalyse_time_region_start-reanalysed_post_spike > well_electrode_data(well_count).electrode_data(electrode_count).time(1)
                                       reanalyse_time_region_start = reanalyse_time_region_start-reanalysed_post_spike;
                                       %disp('removed')
                                   end
                                   
                               end
                               
                               
                               
                               
                           end
                               
                           
                        end
                        reanalyse_time_region_end = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(end_indx);
                
                    else
                        
                        reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).Stims(start_indx);

                        reanalyse_time_region_end = well_electrode_data(well_count).electrode_data(electrode_count).Stims(end_indx);
                
                    end
                end
                
                [well_electrode_data(well_count)] = reanalyse_selected_beats(well_electrode_data(well_count), electrode_count, num_electrode_rows, num_electrode_cols, well_elec_fig, elec_ax, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, reanalyse_time_region_start, reanalyse_time_region_end, start_indx, end_indx, reanalyse_beat_fig, negative_skip, reanalysed_post_spike);
 
            end
            
            function removeSelectedBeats(remove_button, reanalyse_beat_fig)
                
                if strcmp(get(range_button, 'visible'), 'off')
                    start_beat = get(beats_range_1_ui, 'value');
                    end_beat = get(beats_range_2_ui, 'value');
                    
                    if start_beat > end_beat
                        msgbox('Start beat entered after end beat. Choose new values please');
                        set(beats_range_1_ui, 'value', 1);
                        set(beats_range_2_ui, 'value', 1);
                        return
                    end
                    
                    start_indx = start_beat;
                    if end_beat == length(well_electrode_data(well_count).electrode_data(electrode_count).beat_num_array)
                        end_indx = end_beat;
                    else
                        end_indx = end_beat+1;
                    end
                else
                    if strcmp(get(time_range_button, 'visible'), 'off')
                        start_beat = get(beats_range_1_ui, 'value');
                        end_beat = get(beats_range_2_ui, 'value');
                        
                        
                    
                        if start_beat > end_beat
                            msgbox('Start beat entered as time after end beat. Choose new values please');

                            set(beats_range_1_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(1));
                            set(beats_range_2_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(end));
                            return
                        end
                        
                        if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced')
                            start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).Stims >= start_beat);
                            start_indx = start_indx(1);
                            
                            end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).Stims >= end_beat);
                            end_indx = end_indx(1);
                        else
                            start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times >= start_beat);
                            
                            
                            if isempty(start_indx)
                                if start_beat < well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(1)
                                    start_indx = 1;
                                else
                                    start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times <= start_beat);
                                    start_indx = start_indx(1);
                                    if isempty(start_indx)
                                        start_indx = 1;
                                        
                                    end
                                end
                                
                            else
                                
                                start_indx = start_indx(1);
                            end
                            
                            end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times >= end_beat);
                            
                            if isempty(end_indx)
                                if end_beat > well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(end)
                                    end_indx = length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
                                else
                                    end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times <= end_beat);
                                    end_indx = end_indx(1);
                                    if isempty(end_indx)
                                        end_indx = length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
                                        
                                    end
                                end
                            else
                                end_indx = end_indx(1);
                            end
                        end
                        
                        

                    else
                    
                    
                        beat_num = get(beat_num_ui, 'value');
                        start_indx = beat_num;
                        if beat_num == length(well_electrode_data(well_count).electrode_data(electrode_count).beat_num_array)
                            end_indx = beat_num;
                        else
                            end_indx = beat_num+1;
                        end
                    end

                    
                    
                end
                
                reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(start_indx);
                reanalyse_time_region_end = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(end_indx);
                
                [well_electrode_data(well_count)] = remove_selected_beats(well_electrode_data(well_count), electrode_count, num_electrode_rows, num_electrode_cols, well_elec_fig, elec_ax, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, reanalyse_time_region_start, reanalyse_time_region_end, start_indx, end_indx, reanalyse_beat_fig);
 
            end
            
            
        end
        

        function heatMapButtonPushed(heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced)

            %set(well_elec_fig, 'Visible', 'off')
            
            hmap_prompt_fig = uifigure;
            hmap_prompt_pan = uipanel(hmap_prompt_fig, 'Position', [0 0 screen_width screen_height]);
            
            beat_num_text = uieditfield(hmap_prompt_pan,'Text', 'FontSize', 12, 'Value', 'Reanalyse Beat Number', 'Position', [10 150 200 40], 'Editable','off');
            beat_num_ui = uieditfield(hmap_prompt_pan, 'numeric', 'Tag', 'Num Beat Patterns', 'Position', [10 100 200 40], 'FontSize', 12, 'Value', 1, 'ValueChangedFcn', @(beat_num_ui,event) changedNumBeats(beat_num_ui, electrode_count));
            
            beats_range_1_text = uieditfield(hmap_prompt_pan,'Text', 'FontSize', 12, 'Value', 'Start Beat Range', 'Position', [10 150 150 40], 'Editable','off');
            beats_time_range_1_text = uieditfield(hmap_prompt_pan,'Text', 'FontSize', 12, 'Value', 'Beat Time Range Start (s)', 'Position', [10 150 150 40], 'Editable','off');
            beats_range_1_ui = uieditfield(hmap_prompt_pan, 'numeric', 'Tag', 'Start Beat Range', 'Position', [10 100 150 40], 'FontSize', 12, 'Value', 1, 'ValueChangedFcn', @(beats_range_1_ui,event) changedNumBeats(beats_range_1_ui, electrode_count));
            
            beats_range_2_text = uieditfield(hmap_prompt_pan,'Text', 'FontSize', 12, 'Value', 'End Beat Range', 'Position', [160 150 150 40], 'Editable','off');
            beats_time_range_2_text = uieditfield(hmap_prompt_pan,'Text', 'FontSize', 12, 'Value', 'Beat Time Range End (s)', 'Position', [160 150 150 40], 'Editable','off');
            beats_range_2_ui = uieditfield(hmap_prompt_pan, 'numeric', 'Tag', 'End Beat Range', 'Position', [160 100 150 40], 'FontSize', 12, 'Value', 1, 'ValueChangedFcn', @(beats_range_2_ui,event) changedNumBeats(beats_range_2_ui, electrode_count));
            
            
            go_button = uibutton(hmap_prompt_pan,'push','Text', 'Go',  'BackgroundColor', '#3dd4d1', 'Position', [210 50 100 50], 'ButtonPushedFcn', @(go_button,event) conductionMapGo(go_button));
            
            

            range_button = uibutton(hmap_prompt_pan,'push','Text', 'Enter Beat Number Range', 'Position', [210 100 150 50], 'ButtonPushedFcn', @(range_button,event) numBeatsRangeButtonPressed('off', 'on', 'no'));
            
            time_range_button = uibutton(hmap_prompt_pan,'push','Text', 'Enter Beat Time Range', 'Position', [360 100 150 50], 'ButtonPushedFcn', @(time_range_button,event) numBeatsRangeButtonPressed('off', 'on', 'yes'));
               
            num_beats_button = uibutton(hmap_prompt_pan,'push','Text', 'Enter Num Beats', 'Position', [310 100 100 50], 'ButtonPushedFcn', @(num_beats_button,event) numBeatsRangeButtonPressed('on', 'off', 'N/A'));
            
            set(num_beats_button, 'visible', 'off')
            set(beats_range_1_text, 'visible', 'off')
            set(beats_time_range_1_text, 'visible', 'off')
            set(beats_range_1_ui, 'visible', 'off')
            set(beats_range_2_text, 'visible', 'off')
            set(beats_time_range_2_text, 'visible', 'off')
            set(beats_range_2_ui, 'visible', 'off')

            function changedNumBeats(ui, electrode_count)
                if strcmp(get(time_range_button, 'visible'), 'on')
                    % Means assessing beat number/index
                    if get(ui, 'Value') > length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times)
                        msgbox('The value entered was too large')
                        set(ui, 'Value', 1)
                    end
                    if get(ui, 'Value') < 1
                        msgbox('The value entered was too small')
                        set(ui, 'Value', 1)
                    end
                    
                else
                    if get(ui, 'Value') > well_electrode_data(well_count).electrode_data(electrode_count).time(end)
                        msgbox('The value entered was too large')
                        %disp(get(ui, 'tag'))
                        tag = get(ui, 'tag');
                        if contains(tag, 'End')
                            set(ui, 'Value', well_electrode_data(well_count).electrode_data(electrode_count).time(end))
                        else
                            set(ui, 'Value', well_electrode_data(well_count).electrode_data(electrode_count).time(1))
                        end
                        
                    end
                    if get(ui, 'Value') < well_electrode_data(well_count).electrode_data(electrode_count).time(1)
                        msgbox('The value entered was too small')
                        tag = get(ui, 'tag');
                        if contains(tag, 'End')
                            set(ui, 'Value', well_electrode_data(well_count).electrode_data(electrode_count).time(end))
                        else
                            set(ui, 'Value', well_electrode_data(well_count).electrode_data(electrode_count).time(1))
                        end
                    end
                end

            end
            
            function numBeatsRangeButtonPressed(action1, action2, time_range)
                
                
                set(beat_num_text, 'visible', action1)
                set(beat_num_ui, 'visible', action1)
                set(num_beats_button, 'visible', action2)
                
                set(beats_range_1_ui, 'visible', action2)
                set(beats_range_2_ui, 'visible', action2)
                
                if strcmp(action2, 'on')
                    if strcmp(time_range, 'no')
                        set(beats_range_1_text, 'visible', action2)
                        set(beats_range_2_text, 'visible', action2)
                        set(beats_time_range_1_text, 'visible', action1)
                        set(beats_time_range_2_text, 'visible', action1)
                        
                        
                        set(beats_range_1_ui, 'value', 1)
                        set(beats_range_2_ui, 'value', 1)
                    
                        
                        set(time_range_button, 'visible', action2)
                        set(range_button, 'visible', action1)
                        set(time_range_button, 'position', [410 100 150 50])
                        
                    elseif strcmp(time_range, 'yes')
                        set(beats_range_1_text, 'visible', action1)
                        set(beats_range_2_text, 'visible', action1)
                        set(beats_time_range_1_text, 'visible', action2)
                        set(beats_time_range_2_text, 'visible', action2)
                        
                        set(beats_range_1_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(1))
                        set(beats_range_2_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(end))
                    
                        set(time_range_button, 'visible', action1)
                        set(range_button, 'visible', action2)
                        
                        set(range_button, 'position', [410 100 150 50])
                    end
                    set(go_button, 'position', [310 50 100 50])
                    
                else
                    set(beats_range_1_text, 'visible', action2)
                    set(beats_range_2_text, 'visible', action2)
                    set(beats_time_range_1_text, 'visible', action2)
                    set(beats_time_range_2_text, 'visible', action2)
                    
                    set(go_button, 'position', [210 50 100 50])
                    
                    set(time_range_button, 'position', [360 100 150 50])
                    set(range_button, 'position', [210 100 150 50])
                    
                    set(time_range_button, 'visible', action1)
                    set(range_button, 'visible', action1)
                end
                
                
                
            end
            
            function conductionMapGo(go_button)
                
                if strcmp(get(range_button, 'visible'), 'off')
                    start_beat = get(beats_range_1_ui, 'value');
                    end_beat = get(beats_range_2_ui, 'value');
                    
                    if start_beat > end_beat
                        msgbox('Start beat entered after end beat. Choose new values please');
                        set(beats_range_1_ui, 'value', 1);
                        set(beats_range_2_ui, 'value', 1);
                        return
                    end
                    
                    if end_beat == start_beat
                        num_hm_beats = 1;
                    else
                        end_beat = end_beat+1;
                        num_hm_beats = end_beat - start_beat;
                    end
                else
                    if strcmp(get(time_range_button, 'visible'), 'off')
                        start_beat = get(beats_range_1_ui, 'value');
                        end_beat = get(beats_range_2_ui, 'value');
                        
                        if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced')
                            start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).Stims >= start_beat);
                            start_indx = start_indx(1);
                            
                            end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).Stims >= end_beat);
                            end_indx = end_indx(1);
                        else
                            start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times >= start_beat);
                            
                            
                            if isempty(start_indx)
                                if start_beat < well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(1)
                                    start_indx = 1;
                                else
                                    start_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times <= start_beat);
                                    start_indx = start_indx(1);
                                    if isempty(start_indx)
                                        start_indx = 1;
                                        
                                    end
                                end
                                
                            else
                                
                                start_indx = start_indx(1);
                            end
                            
                            end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times >= end_beat);
                            
                            if isempty(end_indx)
                                if end_beat > well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(end)
                                    end_indx = length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
                                else
                                    end_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times <= end_beat);
                                    end_indx = end_indx(1);
                                    if isempty(end_indx)
                                        end_indx = length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
                                        
                                    end
                                end
                            else
                                end_indx = end_indx(1);
                            end
                        end
                        
                        start_beat = start_indx;
                        end_beat = end_indx;

                        if start_beat > end_beat
                            msgbox('Start beat entered after end beat. Choose new values please');
                            set(beats_range_1_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(1));
                            set(beats_range_2_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(end));
                            return
                        end

                        if end_beat == start_beat
                            num_hm_beats = 1;
                        else
                            end_beat = end_beat+1;
                            num_hm_beats = end_beat - start_beat;
                        end
                        
                    else
                        % Number of beats selected
                        num_hm_beats = get(num_beats_ui, 'value');
                        start_beat = 1;
                        end_beat = get(num_beats_ui, 'value');
                    end
                end
                
                
                start_activation_times = [];
                %start_activation_times = empty(num_beats, 0);
                %%disp(size(electrode_data))
                for n = start_beat:end_beat
                    
                    act_row = [];
                    for e = 1:num_electrode_rows*num_electrode_cols
                        %%disp(e);
                        elec_data = well_electrode_data(well_count).electrode_data(1,e);

                        if elec_data.rejected == 1
                            act_time = nan;
                        else
                            if isempty(elec_data.activation_times)
                                act_time = nan;
                            else
                                act_times = elec_data.activation_times;
                                act_time = act_times(2+n-1);
                            end
                        end

                        %start_activation_times = [start_activation_times, act_time];
                        act_row = [act_row, act_time];
                        %start_activation_tims(num_beats, act_count) = act_time;
                        %act_count = act_count+1;
                    end
                    start_activation_times = [start_activation_times; {act_row}];
                end
                %conduction_map_GUI(start_activation_times, num_electrode_rows, num_electrode_cols, spon_paced, well_elec_fig)
                conduction_map_GUI4(start_activation_times, num_electrode_rows, num_electrode_cols, spon_paced, well_elec_fig, hmap_prompt_fig, num_hm_beats, start_beat)
            end
        end
        
        function viewOverlaidPlotsPushed(overlaid_plots_button, well_count)
            overlaid_fig = uifigure;
            movegui(overlaid_fig,'center')
            overlaid_fig.WindowState = 'maximized';
            overlaid_fig.Name = strcat(well_ID, '_', 'Overlaid Electrode Results');
            % left bottom width height
            overlaid_main_well_pan = uipanel(overlaid_fig, 'Position', [0 0 screen_width screen_height]);
            close_overlaid_button = uibutton(overlaid_main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_overlaid_button,event) closeSingleFig(close_overlaid_button, overlaid_fig));

            overlaid_well_pan = uipanel(overlaid_main_well_pan, 'Position', [0 0 well_p_width well_p_height]);
            overlaid_ax = uiaxes(overlaid_well_pan, 'Position', [0 0 well_p_width well_p_height]);
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

    function rejectWellButtonPushed(rejec_well_button, well_elec_fig, out_fig, well_button, well_count)
        %set(well_elec_fig, 'Visible', 'off');
        
        %set(well_button, 'Visible', 'off');
        
        
        if exist(fullfile(save_dir, strcat(well_electrode_data(well_count).wellID, '.xls')), 'file')
            %disp('yeah')
            delete(fullfile(save_dir, strcat(well_electrode_data(well_count).wellID, '.xls')))
        end
        
        if exist(fullfile(save_dir, strcat(well_electrode_data(well_count).wellID, '_figures')), 'dir')

           rmdir(fullfile(save_dir, strcat(well_electrode_data(well_count).wellID, '_figures')), 's')
        end
        if exist(fullfile(save_dir, strcat(well_electrode_data(well_count).wellID, '_images')), 'dir')
            rmdir(fullfile(save_dir, strcat(well_electrode_data(well_count).wellID, '_images')), 's')
        end
        
        
        electrode_data = well_electrode_data(well_count).electrode_data;
        
        for j = 1:length(electrode_data)

            well_electrode_data(well_count).electrode_data(j).rejected = 1;
            
        end
        
        if num_wells == 1
            close all;
            close all hidden;
        else
            close(well_elec_fig);
            set(out_fig, 'Visible', 'on');
        end
        %well_electrode_data(well_count, :) = electrode_data;
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

    function saveB2BButtonPushed(save_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, save_plots, saving_multiple)
        %%disp('save b2b')
        %%disp(save_dir)
        
        
        disp(strcat('Saving Data for', {' '}, well_ID))
        output_filename = fullfile(save_dir, strcat(well_ID, '.xls'));
        if exist(output_filename, 'file')
            delete(output_filename);
        end
        
        if saving_multiple == 0
            set(well_elec_fig, 'visible', 'off')
            wait_bar = waitbar(0, strcat('Saving Data for ', {' '}, well_ID));
            
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
                    if saving_multiple == 0
                        close(wait_bar)
                        set(well_elec_fig, 'visible', 'on')
                    
                    end
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
                    if saving_multiple == 0
                        close(wait_bar)
                        set(well_elec_fig, 'visible', 'on')
                    
                    end
                    return
                    
                end
            end
        end
        well_FPDs = [];
        well_slopes = [];
        well_amps = [];
        well_bps = [];
        
        sheet_count = 1;
        electrode_data = well_electrode_data(well_count).electrode_data;
        elec_ids = [electrode_data(:).electrode_id];
        average_electrodes = {};
        max_act_elec_id = '';
        max_act_time = nan;
        min_act_elec_id = '';
        min_act_time = nan;
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
                
                if isempty(electrode_data(electrode_count).beat_start_times)
                    continue;
                end
                if electrode_data(electrode_count).rejected == 1
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

                if strcmp(analyse_all_b2b, 'all')
                    if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape}, {electrode_data(electrode_count).filter_intensity});
                        %mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Stim-spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Stim spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    end
                else
                    if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Stim-spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Stim spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    end

                end 
                
                %cell%disp(mean_data);

                elec_stats = horzcat(headings, mean_data);
                
                if isempty(average_electrodes)
                    average_electrodes = elec_stats;
                    
                else
                    
                    average_electrodes = vertcat(average_electrodes, elec_stats);
                end
                
                
                beat_num_array = electrode_data(electrode_count).beat_num_array;
                [br, bc] = size(beat_num_array);
                beat_num_array = reshape(beat_num_array, [bc br]);
                
                beat_start_times = electrode_data(electrode_count).beat_start_times;
                [br, bc] = size(beat_start_times);
                beat_start_times = reshape(beat_start_times, [bc br]);
                
                activation_times = electrode_data(electrode_count).activation_times;
                min_act = min(activation_times);
                orig_activation_times = activation_times;
                
                [br, bc] = size(activation_times);
                activation_times = reshape(activation_times, [bc br]);
                
                [br, bc] = size(amps);
                amps = reshape(amps, [bc br]);
                
                [br, bc] = size(slopes);
                slopes = reshape(slopes, [bc br]);
                
                
                [br, bc] = size(FPDs);
                FPDs = reshape(FPDs, [bc br]);
                
                
                t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                [br, bc] = size(t_wave_peak_times);
                t_wave_peak_times = reshape(t_wave_peak_times, [bc br]);
                
                t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                [br, bc] = size(t_wave_peak_array);
                t_wave_peak_array = reshape(t_wave_peak_array, [bc br]);
                
                beat_periods = electrode_data(electrode_count).beat_periods;
                [br, bc] = size(beat_periods);
                beat_periods = reshape(beat_periods, [bc br]);

                
                cycle_length_array = electrode_data(electrode_count).cycle_length_array;
                [br, bc] = size(cycle_length_array);
                cycle_length_array = reshape(cycle_length_array, [bc br]);
                
                act_sub_min = orig_activation_times - min_act;
                [br, bc] = size(act_sub_min);
                act_sub_min = reshape(act_sub_min, [bc br]);
   
                
                warning_array = electrode_data(electrode_count).warning_array;
                [br, bc] = size(warning_array);
                warning_array = reshape(warning_array, [bc br]);
   
                
                electrode_stats_table = table('Size', [length(beat_num_array) 13], 'VariableTypes',["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string"], 'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Activation Time (s)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "Warnings"]));
                
                
                num2cell(beat_num_array)
                electrode_stats_table(:, 2) = num2cell(beat_num_array);
                
                electrode_stats_table(:, 3) = num2cell(beat_start_times);
                
                electrode_stats_table(:, 4) = num2cell(activation_times);
                
                electrode_stats_table(:, 5) = num2cell(amps);
                
                electrode_stats_table(:, 6) = num2cell(slopes);

                electrode_stats_table(:, 7) = num2cell(t_wave_peak_times);

                electrode_stats_table(:, 8) = num2cell(t_wave_peak_array);

                electrode_stats_table(:, 9) = num2cell(FPDs);

                electrode_stats_table(:, 10) = num2cell(beat_periods);

                electrode_stats_table(:, 11) = num2cell(cycle_length_array);

                electrode_stats_table(:, 12) = num2cell(act_sub_min);
                
                electrode_stats_table(:, 13) = warning_array;
                
                
                
                
                
                
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

                    
                    end
                    return
                end
                
                if save_plots == 1
                    fig = figure();
                    set(fig, 'visible', 'off');
                    hold('on')
                    plot(electrode_data(electrode_count).time, electrode_data(electrode_count).data);

                    t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                    t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                    t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                    t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                    plot(t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
                    plot(electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
                    plot(electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

                   

                    if strcmp(electrode_data(electrode_count).spon_paced, 'paced') 
                        

                        plot(electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                        plot(electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
                        plot(electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);
                        
                    else
                        
                        plot(electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
                        
                    end
                    %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');

                    plot(electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'k.', 'MarkerSize', 20);

                    if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                        legend('signal', 'T-wave peak', 'max depol.', 'min depol.', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                        legend('signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                    else
                        legend('signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point', 'location', 'northeastoutside')

                    end
                    title({electrode_data(electrode_count).electrode_id},  'Interpreter', 'none')
                    
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  electrode_data(electrode_count).electrode_id));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  electrode_data(electrode_count).electrode_id), 'png')
                    hold('off')
                    close(fig)
                    
                    fig = figure();
                    set(fig, 'Visible', 'off')
                    beat_num_array = electrode_data(electrode_count).beat_num_array(2:end);
                    cycle_length_array = electrode_data(electrode_count).cycle_length_array(2:end);
                    plot(beat_num_array, cycle_length_array, 'b.', 'MarkerSize', 20);
                    if  ~isempty(electrode_data(electrode_count).arrhythmia_indx)
                        hold('on')
                        plot(beat_num_array(electrode_data(electrode_count).arrhythmia_indx), cycle_length_array(electrode_data(electrode_count).arrhythmia_indx), 'r.', 'MarkerSize', 20);
                        legend('Stable beats', 'Arrhythmic beats', 'location', 'northeastoutside');
                    end
                    xlabel('Beat Number');
                    ylabel('Cycle Length (s)');
                    ylim([0 max(cycle_length_array)])
                    title(strcat('Cycle Length per Beat', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_beat')));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_beat')), 'png')
                    hold('off')
                    close(fig)

                    fig = figure();
                    set(fig, 'Visible', 'off')
                    plot(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).beat_periods, 'bo');
                    xlabel('Beat Number');
                    ylabel('Beat Period (s)');
                    ylim([0 max(electrode_data(electrode_count).beat_periods)])
                    title(strcat('Beat Period per Beat', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_beat_period_per_beat')));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_beat_period_per_beat')), 'png')
                    hold('off')
                    close(fig)

                    fig = figure();
                    set(fig, 'Visible', 'off')
                    plot(electrode_data(electrode_count).cycle_length_array(2:end-1), electrode_data(electrode_count).cycle_length_array(3:end), 'b.', 'MarkerSize', 20);
                    xlabel('Cycle Length Previous Beat (s)');
                    ylabel('Cycle Length (s)');
                    title(strcat('Cycle Length vs Previous Beat Cycle Length', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_previous_cycle_length')));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_previous_cycle_length')), 'png')
                    hold('off')
                    close(fig)

                    t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                    t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                    t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                    t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                    activation_times = electrode_data(electrode_count).activation_times;
                    activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                    fpd_beats = electrode_data(electrode_count).beat_num_array(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                    elec_FPDs = [t_wave_peak_times - activation_times];
                    fig = figure();
                    set(fig, 'Visible', 'off')
                    plot(fpd_beats, elec_FPDs, 'bo');
                    xlabel('Beat Number');
                    ylabel('FPD (s)');
                    ylim([0 max(elec_FPDs)])
                    title(strcat('FPD per Beat Num', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_FPD_per_beat_number')));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, 'FPD_per_beat_number')), 'png')
                    hold('off')
                    close(fig)
                end
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
        
        headings = {strcat(well_ID, ': Well-wide statistics'); 'max start activation time (s)'; 'max start activation time electrode id';'min start activation time (s)'; 'min start activation time electrode id'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Conduction Velocity (dum/dt)'};
        mean_data1 = [max_act_time]; 
        mean_data2 = [mean_FPD; mean_slope; mean_amp; mean_bp; well_electrode_data(well_count).conduction_velocity];
        mean_data1 = num2cell(mean_data1);
        mean_data2 = num2cell(mean_data2);
        mean_data = vertcat({''}, {max_act_time}, {max_act_elec_id}, {min_act_time}, {min_act_elec_id}, mean_data2);
        
        
        well_stats = horzcat(headings, mean_data);
        %max_act_elec_id
        %cell%disp(well_stats);
        well_stats = vertcat(well_stats, average_electrodes);
        %well_stats = cellstr(well_stats)
        
        %cell%disp(well_stats)
        
        %xlswrite(output_filename, well_stats, 1);
        fileattrib(output_filename, '-h +w');
        writecell(well_stats, output_filename, 'Sheet', 1);
        
        
        if saving_multiple == 0
            close(wait_bar)
            msgbox(strcat('Saved Data for', {' '}, well_ID, {' '}, 'to', {' '}, output_filename));
        
            set(well_elec_fig, 'visible', 'on')
        end
        
        fclose('all');

    end
    %{
    function saveB2BButtonPushed(save_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, save_plots, saving_multiple)
        %%disp('save b2b')
        %%disp(save_dir)
        
        
        disp(strcat('Saving Data for', {' '}, well_ID))
        output_filename = fullfile(save_dir, strcat(well_ID, '.xls'));
        if exist(output_filename, 'file')
            delete(output_filename);
        end
        
        if saving_multiple == 0
            set(well_elec_fig, 'visible', 'off')
            wait_bar = waitbar(0, strcat('Saving Data for ', {' '}, well_ID));
            
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
                    if saving_multiple == 0
                        close(wait_bar)
                        set(well_elec_fig, 'visible', 'on')
                    
                    end
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
                    if saving_multiple == 0
                        close(wait_bar)
                        set(well_elec_fig, 'visible', 'on')
                    
                    end
                    return
                    
                end
            end
        end
        well_FPDs = [];
        well_slopes = [];
        well_amps = [];
        well_bps = [];
        
        sheet_count = 1;
        electrode_data = well_electrode_data(well_count).electrode_data;
        elec_ids = [electrode_data(:).electrode_id];
        average_electrodes = {};
        max_act_elec_id = '';
        max_act_time = nan;
        min_act_elec_id = '';
        min_act_time = nan;
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
                
                if isempty(electrode_data(electrode_count).beat_start_times)
                    continue;
                end
                if electrode_data(electrode_count).rejected == 1
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

                if strcmp(analyse_all_b2b, 'all')
                    if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape}, {electrode_data(electrode_count).filter_intensity});
                        %mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Stim-spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Stim spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    end
                else
                    if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Stim-spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Stim spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    end

                end 
                
                %cell%disp(mean_data);

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
                
                warning_array = electrode_data(electrode_count).warning_array;
                [br, bc] = size(warning_array);
                warning_array = reshape(warning_array, [bc br]);
                warnings = vertcat('Warnings', warning_array);
                
                elec_id_column = repmat({''}, bc, br);
                %cell%disp(elec_id_column)
                elec_id_column = vertcat(electrode_data(electrode_count).electrode_id, elec_id_column);
                
                
                electrode_stats = horzcat(elec_id_column, beat_num_array, beat_start_times, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, cycle_length_array, act_sub_min, warnings);
                %electrode_stats = {[elec_id_column] [beat_num_array] [beat_start_times] [activation_times] [amps] [slopes] [t_wave_peak_times] [t_wave_peak_array] [FPDs] [beat_periods] [cycle_length_array]};
                %electrode_stats = {electrode_stats_header;electrode_stats};
                
                electrode_stats = cellstr(electrode_stats);
                
                %cell%disp(electrode_stats)

                [ec, er] = size(electrode_stats);
                
                %%disp(sheet_count)
                
                % all_data must be a cell array
                %xlswrite(output_filename, electrode_stats, sheet_count);
                
                try
                    if sheet_count ~= 2
                        fileattrib(output_filename, '-h +w');
                    end

                    writecell(electrode_stats, output_filename, 'Sheet', sheet_count);
                    fileattrib(output_filename, '+h +w');
                catch
                    msgbox(strcat(output_filename, {' '}, 'is open and cannot be written to. Please close it and try saving again.'));
                    if saving_multiple == 0
                        close(wait_bar)

                        set(well_elec_fig, 'visible', 'on')

                    
                    end
                    return
                end
                
                if save_plots == 1
                    fig = figure();
                    set(fig, 'visible', 'off');
                    hold('on')
                    plot(electrode_data(electrode_count).time, electrode_data(electrode_count).data);

                    t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                    t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                    t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                    t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                    plot(t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
                    plot(electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
                    plot(electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

                   

                    if strcmp(electrode_data(electrode_count).spon_paced, 'paced') 
                        

                        plot(electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                        plot(electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
                        plot(electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);
                        
                    else
                        
                        plot(electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
                        
                    end
                    %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');

                    plot(electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'k.', 'MarkerSize', 20);

                    if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                        legend('signal', 'T-wave peak', 'max depol.', 'min depol.', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                        legend('signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                    else
                        legend('signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point', 'location', 'northeastoutside')

                    end
                    title({electrode_data(electrode_count).electrode_id},  'Interpreter', 'none')
                    
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  electrode_data(electrode_count).electrode_id));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  electrode_data(electrode_count).electrode_id), 'png')
                    hold('off')
                    close(fig)
                    
                    fig = figure();
                    set(fig, 'Visible', 'off')
                    beat_num_array = electrode_data(electrode_count).beat_num_array(2:end);
                    cycle_length_array = electrode_data(electrode_count).cycle_length_array(2:end);
                    plot(beat_num_array, cycle_length_array, 'b.', 'MarkerSize', 20);
                    if  ~isempty(electrode_data(electrode_count).arrhythmia_indx)
                        hold('on')
                        plot(beat_num_array(electrode_data(electrode_count).arrhythmia_indx), cycle_length_array(electrode_data(electrode_count).arrhythmia_indx), 'r.', 'MarkerSize', 20);
                        legend('Stable beats', 'Arrhythmic beats', 'location', 'northeastoutside');
                    end
                    xlabel('Beat Number');
                    ylabel('Cycle Length (s)');
                    ylim([0 max(cycle_length_array)])
                    title(strcat('Cycle Length per Beat', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_beat')));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_beat')), 'png')
                    hold('off')
                    close(fig)

                    fig = figure();
                    set(fig, 'Visible', 'off')
                    plot(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).beat_periods, 'bo');
                    xlabel('Beat Number');
                    ylabel('Beat Period (s)');
                    ylim([0 max(electrode_data(electrode_count).beat_periods)])
                    title(strcat('Beat Period per Beat', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_beat_period_per_beat')));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_beat_period_per_beat')), 'png')
                    hold('off')
                    close(fig)

                    fig = figure();
                    set(fig, 'Visible', 'off')
                    plot(electrode_data(electrode_count).cycle_length_array(2:end-1), electrode_data(electrode_count).cycle_length_array(3:end), 'b.', 'MarkerSize', 20);
                    xlabel('Cycle Length Previous Beat (s)');
                    ylabel('Cycle Length (s)');
                    title(strcat('Cycle Length vs Previous Beat Cycle Length', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_previous_cycle_length')));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_previous_cycle_length')), 'png')
                    hold('off')
                    close(fig)

                    t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                    t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                    t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                    t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                    activation_times = electrode_data(electrode_count).activation_times;
                    activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                    fpd_beats = electrode_data(electrode_count).beat_num_array(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                    elec_FPDs = [t_wave_peak_times - activation_times];
                    fig = figure();
                    set(fig, 'Visible', 'off')
                    plot(fpd_beats, elec_FPDs, 'bo');
                    xlabel('Beat Number');
                    ylabel('FPD (s)');
                    ylim([0 max(elec_FPDs)])
                    title(strcat('FPD per Beat Num', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_FPD_per_beat_number')));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, 'FPD_per_beat_number')), 'png')
                    hold('off')
                    close(fig)
                end
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
        
        headings = {strcat(well_ID, ': Well-wide statistics'); 'max start activation time (s)'; 'max start activation time electrode id';'min start activation time (s)'; 'min start activation time electrode id'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Conduction Velocity (dum/dt)'};
        mean_data1 = [max_act_time]; 
        mean_data2 = [mean_FPD; mean_slope; mean_amp; mean_bp; well_electrode_data(well_count).conduction_velocity];
        mean_data1 = num2cell(mean_data1);
        mean_data2 = num2cell(mean_data2);
        mean_data = vertcat({''}, {max_act_time}, {max_act_elec_id}, {min_act_time}, {min_act_elec_id}, mean_data2);
        
        
        well_stats = horzcat(headings, mean_data);
        %max_act_elec_id
        %cell%disp(well_stats);
        well_stats = vertcat(well_stats, average_electrodes);
        %well_stats = cellstr(well_stats)
        
        %cell%disp(well_stats)
        
        %xlswrite(output_filename, well_stats, 1);
        fileattrib(output_filename, '-h +w');
        writecell(well_stats, output_filename, 'Sheet', 1);
        
        
        if saving_multiple == 0
            close(wait_bar)
            msgbox(strcat('Saved Data for', {' '}, well_ID, {' '}, 'to', {' '}, output_filename));
        
            set(well_elec_fig, 'visible', 'on')
        end
        
        fclose('all');

    end
    %}

    function saveB2BPlotsButtonPushed(save_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols)
        %%disp('save b2b')
        %%disp(save_dir)
        set(well_elec_fig, 'visible', 'off');
        
        disp(strcat('Saving Data for', {' '}, well_ID))
        
        if ~exist(fullfile(save_dir, strcat(well_ID, '_figures')), 'dir')
            mkdir(fullfile(save_dir, strcat(well_ID, '_figures')))
        else
            try
                rmdir(fullfile(save_dir, strcat(well_ID, '_figures')), 's')
                mkdir(fullfile(save_dir, strcat(well_ID, '_figures')))
            catch
                msgbox(strcat('A file in', {' '}, fullfile(save_dir, strcat(well_ID, '_figures')), {' '}, 'is open. Please close and try saving again.'))
                set(well_elec_fig, 'visible', 'on')

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
                set(well_elec_fig, 'visible', 'on')
                return
            end
        end
        
        wait_bar = waitbar(0, strcat('Saving Plots for ', {' '}, well_ID));
        
        electrode_data = well_electrode_data(well_count).electrode_data;
        elec_ids = [electrode_data(:).electrode_id];
        num_partitions = 1/(num_electrode_rows*num_electrode_cols);
        partition = num_partitions;
        for elec_r = num_electrode_rows:-1:1
            for elec_c = 1:num_electrode_cols
                waitbar(partition, wait_bar, strcat('Saving Data for ', {' '}, well_ID));
                partition = partition+num_partitions;
                
                %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                if isempty(elec_indx)
                    continue
                end
                electrode_count = elec_indx;
                
                if isempty(electrode_data(electrode_count).beat_start_times)
                    continue;
                end
                if electrode_data(electrode_count).rejected == 1
                    continue;
                end
                
                
                fig = figure();
                set(fig, 'visible', 'off');
                hold('on')
                plot(electrode_data(electrode_count).time, electrode_data(electrode_count).data);

                t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                plot(t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
                plot(electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
                plot(electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

                %[~, beat_start_volts, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
                %beat_start_volts = electrode_data(electrode_count).data(beat_start_volts);
                %plot(electrode_data(electrode_count).beat_start_times, beat_start_volts, 'go');




                if strcmp(electrode_data(electrode_count).spon_paced, 'paced') 
                        

                    plot(electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                    plot(electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
                    plot(electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);

                else

                    plot(electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);

                end
                %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');

                plot(electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'k.', 'MarkerSize', 20);

                if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                    legend('signal', 'T-wave peak', 'max depol.', 'min depol.', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                    legend('signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                else
                    legend('signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point', 'location', 'northeastoutside')

                end
                title({electrode_data(electrode_count).electrode_id},  'Interpreter', 'none')
                savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  electrode_data(electrode_count).electrode_id));
                saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  electrode_data(electrode_count).electrode_id), 'png')
                hold('off')
                close(fig)
                
                
                
                fig = figure();
                set(fig, 'Visible', 'off')
                beat_num_array = electrode_data(electrode_count).beat_num_array(2:end);
                cycle_length_array = electrode_data(electrode_count).cycle_length_array(2:end);
                plot(beat_num_array, cycle_length_array, 'b.', 'MarkerSize', 20);
                if  ~isempty(electrode_data(electrode_count).arrhythmia_indx)
                    hold('on')
                    plot(beat_num_array(electrode_data(electrode_count).arrhythmia_indx), cycle_length_array(electrode_data(electrode_count).arrhythmia_indx), 'r.', 'MarkerSize', 20);
                    legend('Stable beats', 'Arrhythmic beats', 'location', 'northeastoutside');
                end
                xlabel('Beat Number');
                ylabel('Cycle Length (s)');
                ylim([0 max(cycle_length_array)])
                title(strcat('Cycle Length per Beat', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_beat')));
                saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_beat')), 'png')
                hold('off')
                close(fig)

                fig = figure();
                set(fig, 'Visible', 'off')
                plot(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).beat_periods, 'b.', 'MarkerSize', 20);
                xlabel('Beat Number');
                ylabel('Beat Period (s)');
                ylim([0 max(electrode_data(electrode_count).beat_periods)])
                title(strcat('Beat Period per Beat', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_beat_period_per_beat')));
                saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_beat_period_per_beat')), 'png')
                hold('off')
                close(fig)

                fig = figure();
                set(fig, 'Visible', 'off')
                plot(electrode_data(electrode_count).cycle_length_array(2:end-1), electrode_data(electrode_count).cycle_length_array(3:end), 'b.', 'MarkerSize', 20);
                xlabel('Cycle Length Previous Beat (s)');
                ylabel('Cycle Length (s)');
                title(strcat('Cycle Length vs Previous Beat Cycle Length', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_previous_cycle_length')));
                saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_previous_cycle_length')), 'png')
                hold('off')
                close(fig)

                t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                activation_times = electrode_data(electrode_count).activation_times;
                activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                fpd_beats = electrode_data(electrode_count).beat_num_array(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                elec_FPDs = [t_wave_peak_times - activation_times];
                fig = figure();
                set(fig, 'Visible', 'off')
                plot(fpd_beats, elec_FPDs, 'bo');
                xlabel('Beat Number');
                ylabel('FPD (s)');
                ylim([0 max(elec_FPDs)])
                title(strcat('FPD per Beat Num', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_FPD_per_beat_number')));
                saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, 'FPD_per_beat_number')), 'png')
                hold('off')
                close(fig)
                
                
            end
        end
        
        
        close(wait_bar)
        msgbox(strcat('Saved Plots for', {' '}, well_ID, {' '}, 'to', {' '}, save_dir));
        
        set(well_elec_fig, 'visible', 'on')
    end

    function saveAveTimeRegionPushed(save_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, save_plots, saving_multiple)
        %%disp('save b2b')
        %%disp(save_dir)
        %%disp(well_ID)
        disp(strcat('Saving Data for', {' '}, well_ID))
        output_filename = fullfile(save_dir, strcat(well_ID, '.xls'));
        if exist(output_filename, 'file')
            delete(output_filename);
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
                    continue;
                end
                
                if well_electrode_data(well_count).electrode_data(electrode_count).rejected == 1
                    continue;
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

                bps = [well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time(end)- well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time(1)];    
                
                well_FPDs = [well_FPDs FPDs];
                well_slopes = [well_slopes slopes];
                well_amps = [well_amps amps];
                well_bps = [well_bps bps];
                
                
                %{
                activation_times = well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time;
                [br, bc] = size(activation_times);
                activation_times = reshape(activation_times, [bc br]);
                activation_times = num2cell([activation_times]);
                activation_times = vertcat('Activation Time (s)', activation_times);
                %cell%disp(activation_times)
                
                [br, bc] = size(amps);
                amps = reshape(amps, [bc br]);
                amps = num2cell([amps]);
                amps = vertcat('Depolarisation Spike Amplitude (V)', amps);
                %cell%disp(amps)
                
                [br, bc] = size(slopes);
                slopes = reshape(slopes, [bc br]);
                slopes = num2cell([slopes]);
                slopes = vertcat('Depolarisation slope', slopes);
                %cell%disp(slopes)
                
                t_wave_peak_times = well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time;
                [br, bc] = size(t_wave_peak_times);
                t_wave_peak_times = reshape(t_wave_peak_times, [bc br]);
                t_wave_peak_times = num2cell([t_wave_peak_times]);
                t_wave_peak_times = vertcat('T-wave peak Time (s)', t_wave_peak_times);
                %cell%disp(t_wave_peak_times)
                
                %ave_t_wave_peak = electrode_data(electrode_count).average_waveform(find(electrode_data(electrode_count).ave_wave_time == electrode_data(electrode_count).ave_t_wave_peak_time));
                
                peak_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time >= well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time);
                ave_t_wave_peak = well_electrode_data(well_count).electrode_data(electrode_count).average_waveform(peak_indx(1));
                
                
                t_wave_peak_array = ave_t_wave_peak;
                [br, bc] = size(t_wave_peak_array);
                t_wave_peak_array = reshape(t_wave_peak_array, [bc br]);
                t_wave_peak_array = num2cell([t_wave_peak_array]);
                t_wave_peak_array = vertcat('T-wave peak (V)', t_wave_peak_array);
                %cell%disp(t_wave_peak_array)
                
                [br, bc] = size(FPDs);
                FPDs = reshape(FPDs, [bc br]);
                FPDs = num2cell([FPDs]);
                FPDs = vertcat('FPD (s)', FPDs);
                %cell%disp(FPDs)
                
                [br, bc] = size(bps);
                beat_periods = reshape(bps, [bc br]);
                beat_periods = num2cell([beat_periods]);
                beat_periods = vertcat('Beat Period (s)', beat_periods);
                %cell%disp(beat_periods)
                
                elec_id_column = repmat({''}, bc, br);
                %cell%disp(elec_id_column)
                elec_id_column = vertcat(well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, elec_id_column);
                elec_id_column = elec_id_column;
                %%disp(elec_id_column)
                %%disp(class(elec_id_column))
                %}
                
                %{
                % Old cell array method
                if strcmp(spon_paced, 'spon')
                        
                    time_start_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_start]);
                    time_start_array = vertcat('Time Region Start (s)', time_start_array);
                    
                    time_end_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_end]);
                    time_end_array = vertcat('Time Region End (s)', time_end_array);
                    
                    bdt_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).bdt]);
                    bdt_array = vertcat('Beat Detection Threshold Input (V)', bdt_array);
                    
                    min_bp_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).min_bp]);
                    min_bp_array = vertcat('Mininum Beat Period Input (s)', min_bp_array);
                    
                    max_bp_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).max_bp]);
                    max_bp_array = vertcat('Maximum Beat Period Input (s)', max_bp_array);
                    
                    post_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off]);
                    post_spike_hold_off_array = vertcat('Post-spike hold-off (s)', post_spike_hold_off_array);
                    
                    t_wave_duration_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_duration]);
                    t_wave_duration_array = vertcat('T-wave Duration Input (s)', t_wave_duration_array);
                    
                    t_wave_offset_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_offset]);
                    t_wave_offset_array = vertcat('T-wave offset Input (s)', t_wave_offset_array);
                    
                    %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                    t_wave_shape_array = vertcat('T-wave Shape', {well_electrode_data(well_count).electrode_data(electrode_count).t_wave_shape});
                    
                    filter_intensity_array = vertcat('Filter Intensity', {well_electrode_data(well_count).electrode_data(electrode_count).filter_intensity});
                    
                    warning_array = vertcat('Warnings', {well_electrode_data(well_count).electrode_data(electrode_count).ave_warning});
                    
                    electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, time_start_array, time_end_array, bdt_array, min_bp_array, max_bp_array, post_spike_hold_off_array, t_wave_duration_array, t_wave_offset_array, t_wave_shape_array, filter_intensity_array, warning_array);
                
                elseif strcmp(spon_paced, 'paced')
                    time_start_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_start]);
                    time_start_array = vertcat('Time Region Start (s)', time_start_array);
                    
                    time_end_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_end]);
                    time_end_array = vertcat('Time Region End (s)', time_end_array);
                    
                    stim_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).stim_spike_hold_off]);
                    stim_spike_hold_off_array = vertcat('Stim-spike hold-off (s)', stim_spike_hold_off_array);
                    
                    post_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off]);
                    post_spike_hold_off_array = vertcat('Post-spike hold-off (s)', post_spike_hold_off_array);
                    
                    t_wave_duration_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_duration]);
                    t_wave_duration_array = vertcat('T-wave Duration Input (s)', t_wave_duration_array);
                    
                    t_wave_offset_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_offset]);
                    t_wave_offset_array = vertcat('T-wave offset Input (s)', t_wave_offset_array);
                    
                    %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                    t_wave_shape_array = vertcat('T-wave Shape', {well_electrode_data(well_count).electrode_data(electrode_count).t_wave_shape});
                    
                    filter_intensity_array = vertcat('Filter Intensity', {well_electrode_data(well_count).electrode_data(electrode_count).filter_intensity});
                    
                    warning_array = vertcat('Warnings', {well_electrode_data(well_count).electrode_data(electrode_count).ave_warning});
                    
                    
                    electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, time_start_array, time_end_array, stim_spike_hold_off_array, post_spike_hold_off_array, t_wave_duration_array, t_wave_offset_array, t_wave_shape_array, filter_intensity_array, warning_array);
                
                    
                elseif strcmp(spon_paced, 'paced bdt')
                    time_start_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_start]);
                    time_start_array = vertcat('Time Region Start (s)', time_start_array);
                    
                    time_end_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).time_region_end]);
                    time_end_array = vertcat('Time Region End (s)', time_end_array);
                    
                    bdt_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).bdt]);
                    bdt_array = vertcat('Beat Detection Threshold Input (V)', bdt_array);
                    
                    min_bp_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).min_bp]);
                    min_bp_array = vertcat('Mininum Beat Period Input (s)', min_bp_array);
                    
                    max_bp_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).max_bp]);
                    max_bp_array = vertcat('Maximum Beat Period Input (s)', max_bp_array);
                    
                    stim_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).stim_spike_hold_off]);
                    stim_spike_hold_off_array = vertcat('Stim-spike hold-off (s)', stim_spike_hold_off_array);
                    
                    post_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off]);
                    post_spike_hold_off_array = vertcat('Post-spike hold-off (s)', post_spike_hold_off_array);
                    
                    t_wave_duration_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_duration]);
                    t_wave_duration_array = vertcat('T-wave Duration Input (s)', t_wave_duration_array);
                    
                    t_wave_offset_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).t_wave_offset]);
                    t_wave_offset_array = vertcat('T-wave offset Input (s)', t_wave_offset_array);
                    
                    %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                    t_wave_shape_array = vertcat('T-wave Shape', {well_electrode_data(well_count).electrode_data(electrode_count).t_wave_shape});
                    
                    filter_intensity_array = vertcat('Filter Intensity', {well_electrode_data(well_count).electrode_data(electrode_count).filter_intensity});
                    
                    warning_array = vertcat('Warnings', {well_electrode_data(well_count).electrode_data(electrode_count).ave_warning});
                    
                    
                    electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, time_start_array, time_end_array, bdt_array, min_bp_array, max_bp_array, stim_spike_hold_off_array, post_spike_hold_off_array, t_wave_duration_array, t_wave_offset_array, t_wave_shape_array, filter_intensity_array, warning_array);
                
                end
                %}
                
                
                
                activation_times = well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time;
                [br, bc] = size(activation_times);
                activation_times = reshape(activation_times, [bc br]);
                activation_times = num2cell([activation_times]);
                %cell%disp(activation_times)
                
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
                
                peak_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time >= well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time);
                ave_t_wave_peak = well_electrode_data(well_count).electrode_data(electrode_count).average_waveform(peak_indx(1));
                
                
                t_wave_peak_array = ave_t_wave_peak;
                [br, bc] = size(t_wave_peak_array);
                t_wave_peak_array = reshape(t_wave_peak_array, [bc br]);
                t_wave_peak_array = num2cell([t_wave_peak_array]);
                %cell%disp(t_wave_peak_array)
                
                [br, bc] = size(FPDs);
                FPDs = reshape(FPDs, [bc br]);
                FPDs = num2cell([FPDs]);
      
                %cell%disp(FPDs)
                
                [br, bc] = size(bps);
                beat_periods = reshape(bps, [bc br]);
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
                    
                    warning_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_warning};
                    
                    
                    
                    electrode_stats_table = table('Size', [1, 19], 'VariableTypes', ["string", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string", "string"], 'VariableNames', cellstr([well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Time Region Start (s)', 'Time Region End (s)', 'Beat Detection Threshold Input (V)', 'Mininum Beat Period Input (s)', 'Maximum Beat Period Input (s)', 'Post-spike hold-off (s)', 'T-wave Duration Input (s)', 'T-wave offset Input (s)', 'T-wave Shape', 'Filter Intensity', 'Warnings']));
                    
                    electrode_stats_table(:, 2) = activation_times;
                    electrode_stats_table(:, 3) = amps;
                    electrode_stats_table(:, 4) = slopes;
                    electrode_stats_table(:, 5) = t_wave_peak_times;
                    electrode_stats_table(:, 6) = t_wave_peak_array;
                    electrode_stats_table(:, 7) = FPDs;
                    electrode_stats_table(:, 8) = beat_periods;
                    electrode_stats_table(:, 9) = time_start_array;
                    electrode_stats_table(:, 10) = time_end_array;
                    electrode_stats_table(:, 11) = bdt_array;
                    electrode_stats_table(:, 12) = min_bp_array;
                    electrode_stats_table(:, 13) = max_bp_array;
                    electrode_stats_table(:, 14) = post_spike_hold_off_array;
                    electrode_stats_table(:, 15) = t_wave_duration_array;
                    electrode_stats_table(:, 16) = t_wave_offset_array;
                    electrode_stats_table(:, 17) = t_wave_shape_array;
                    electrode_stats_table(:, 18) = filter_intensity_array;
                    electrode_stats_table(:, 19) = warning_array;
                    
                    
                    
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
                    
                    warning_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_warning};
                    
                   
                    electrode_stats_table = table('Size', [1, 17], 'VariableTypes', ["string", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string", "string"], 'VariableNames', cellstr([well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Time Region Start (s)', 'Time Region End (s)', 'Stim-spike hold-off (s)', 'Post-spike hold-off (s)', 'T-wave Duration Input (s)', 'T-wave offset Input (s)', 'T-wave Shape', 'Filter Intensity', 'Warnings']));
                    
                    electrode_stats_table(:, 2) = activation_times;
                    electrode_stats_table(:, 3) = amps;
                    electrode_stats_table(:, 4) = slopes;
                    electrode_stats_table(:, 5) = t_wave_peak_times;
                    electrode_stats_table(:, 6) = t_wave_peak_array;
                    electrode_stats_table(:, 7) = FPDs;
                    electrode_stats_table(:, 8) = beat_periods;
                    electrode_stats_table(:, 9) = time_start_array;
                    electrode_stats_table(:, 10) = time_end_array;
                    electrode_stats_table(:, 11) = stim_spike_hold_off_array;
                    electrode_stats_table(:, 12) = post_spike_hold_off_array;
                    electrode_stats_table(:, 13) = t_wave_duration_array;
                    electrode_stats_table(:, 14) = t_wave_offset_array;
                    electrode_stats_table(:, 15) = t_wave_shape_array;
                    electrode_stats_table(:, 16) = filter_intensity_array;
                    electrode_stats_table(:, 17) = warning_array;
                    
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
                    
                    warning_array = {well_electrode_data(well_count).electrode_data(electrode_count).ave_warning};
                    
                    
                    
                    %electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, time_start_array, time_end_array, bdt_array, min_bp_array, max_bp_array, stim_spike_hold_off_array, post_spike_hold_off_array, t_wave_duration_array, t_wave_offset_array, t_wave_shape_array, filter_intensity_array, warning_array);
                
                    electrode_stats_table = table('Size', [1, 20], 'VariableTypes', ["string", "double",  "double",  "double",  "double", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string", "string"], 'VariableNames', cellstr([well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Time Region Start (s)', 'Time Region End (s)', 'Beat Detection Threshold Input (V)', 'Mininum Beat Period Input (s)', 'Maximum Beat Period Input (s)', 'Stim-spike hold-off (s)', 'Post-spike hold-off (s)', 'T-wave Duration Input (s)', 'T-wave offset Input (s)', 'T-wave Shape', 'Filter Intensity', 'Warnings']));
                    
                    electrode_stats_table(:, 2) = activation_times;
                    electrode_stats_table(:, 3) = amps;
                    electrode_stats_table(:, 4) = slopes;
                    electrode_stats_table(:, 5) = t_wave_peak_times;
                    electrode_stats_table(:, 6) = t_wave_peak_array;
                    electrode_stats_table(:, 7) = FPDs;
                    electrode_stats_table(:, 8) = beat_periods;
                    electrode_stats_table(:, 9) = time_start_array;
                    electrode_stats_table(:, 10) = time_end_array;
                    electrode_stats_table(:, 11) = bdt_array; 
                    electrode_stats_table(:, 12) = min_bp_array; 
                    electrode_stats_table(:, 13) = max_bp_array; 
                    electrode_stats_table(:, 14) = stim_spike_hold_off_array;
                    electrode_stats_table(:, 15) = post_spike_hold_off_array;
                    electrode_stats_table(:, 16) = t_wave_duration_array;
                    electrode_stats_table(:, 17) = t_wave_offset_array;
                    electrode_stats_table(:, 18) = t_wave_shape_array;
                    electrode_stats_table(:, 19) = filter_intensity_array;
                    electrode_stats_table(:, 20) = warning_array;
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
                if save_plots == 1
                    fig = figure();
                    set(fig, 'visible', 'off');
                    hold('on')
                    plot(well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time, well_electrode_data(well_count).electrode_data(electrode_count).average_waveform);
                    %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                    plot(well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_time, well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_point, 'r.', 'MarkerSize', 20);
                    plot(well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_time, well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_point, 'b.', 'MarkerSize', 20);
                    plot(well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time, well_electrode_data(well_count).electrode_data(electrode_count).average_waveform(well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time == well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time), 'ko');

                    peak_indx = find(well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_time >= well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time);
                    peak_indx = peak_indx(1);
                    t_wave_peak = well_electrode_data(well_count).electrode_data(electrode_count).average_waveform(peak_indx);
                    plot(well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time, t_wave_peak, 'c.', 'MarkerSize', 20);

                    legend('signal', 'max depol', 'min depol', 'act. time', 'repol. recovery', 'location', 'northeastoutside')
                    title({well_electrode_data(well_count).electrode_data(electrode_count).electrode_id},  'Interpreter', 'none')
                    savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  well_electrode_data(well_count).electrode_data(electrode_count).electrode_id));
                    saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  well_electrode_data(well_count).electrode_data(electrode_count).electrode_id), 'png')
                    hold('off')
                    close(fig)
                end
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
        %cell%disp(mean_data);
        
        well_stats = horzcat(headings, mean_data);
        %well_stats = cellstr(well_stats)
        
        %cell%disp(well_stats)
        
        %xlswrite(output_filename, well_stats, 1);
        fileattrib(output_filename, '-h +w');
        writecell(well_stats, output_filename, 'Sheet', 1);
        
        if saving_multiple == 0
            close(wait_bar)
            msgbox(strcat('Saved Data for', {' '}, well_ID, {' '}, 'to', {' '}, output_filename));
            set(well_elec_fig, 'visible', 'on')
            
        end
    end


    function saveAveTimeRegionPlotsPushed(save_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols)
        %%disp('save b2b')
        %%disp(save_dir)
        %%disp(well_ID)
        
        figs_dir = fullfile(save_dir, strcat(well_ID, '_figures'));
        images_dir = fullfile(save_dir, strcat(well_ID, '_images'));
        if ~exist(figs_dir, 'dir')
            mkdir(figs_dir)
        else
            try
                rmdir(figs_dir, 's')
                mkdir(figs_dir)
            catch
                
                msgbox(strcat('A file in', {' '}, figs_dir, {' '}, 'is open. Please close and try saving again.'))
                return
            end
        end
        
        
        if ~exist(images_dir, 'dir')
            mkdir(images_dir)
        else
            try
                rmdir(images_dir, 's')
                mkdir(images_dir)
            catch
                msgbox(strcat('A file in', {' '}, images_dir, {' '}, 'is open. Please close and try saving again.'))
                return
                
            end
        end
        
        set(well_elec_fig, 'visible', 'off')
        wait_bar = waitbar(0, strcat('Saving Plots for ', {' '}, well_ID));
        
        electrode_data = well_electrode_data(well_count).electrode_data;
        elec_ids = [electrode_data(:).electrode_id];
        %for elec_r = 1:num_electrode_rows
        
        num_partitions = 1/(num_electrode_rows*num_electrode_cols);
        partition = num_partitions;
        for elec_r = num_electrode_rows:-1:1
            for elec_c = 1:num_electrode_cols
                waitbar(partition, wait_bar, strcat('Saving Plots for ', {' '}, well_ID));
                partition = partition+num_partitions;
                
                
                %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                if isempty(elec_indx)
                    continue
                end
                electrode_count = elec_indx;
                
                if isempty(electrode_data(electrode_count).beat_start_times)
                    continue;
                end
                
                if electrode_data(electrode_count).rejected == 1
                    continue;
                end
                
                
                fig = figure();
                set(fig, 'visible', 'off');
                hold('on')
                plot(electrode_data(electrode_count).ave_wave_time, electrode_data(electrode_count).average_waveform);
                %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                plot(electrode_data(electrode_count).ave_max_depol_time, electrode_data(electrode_count).ave_max_depol_point, 'r.', 'MarkerSize', 20);
                plot(electrode_data(electrode_count).ave_min_depol_time, electrode_data(electrode_count).ave_min_depol_point, 'b.', 'MarkerSize', 20);
                plot(electrode_data(electrode_count).ave_activation_time, electrode_data(electrode_count).average_waveform(electrode_data(electrode_count).ave_wave_time == electrode_data(electrode_count).ave_activation_time), 'k.', 'MarkerSize', 20);

                peak_indx = find(electrode_data(electrode_count).ave_wave_time >= electrode_data(electrode_count).ave_t_wave_peak_time);
                peak_indx = peak_indx(1);
                t_wave_peak = electrode_data(electrode_count).average_waveform(peak_indx);
                plot(electrode_data(electrode_count).ave_t_wave_peak_time, t_wave_peak, 'c.', 'MarkerSize', 20);
                
                legend('signal', 'max depol', 'min depol', 'act. time', 'repol. recovery', 'location', 'northeastoutside')
                title({electrode_data(electrode_count).electrode_id},  'Interpreter', 'none')
                savefig(fullfile(figs_dir,  electrode_data(electrode_count).electrode_id));
                saveas(fig, fullfile(images_dir,  electrode_data(electrode_count).electrode_id), 'png')
                hold('off')
                close(fig)
            end
        end
        
       
        close(wait_bar)
        msgbox(strcat('Saved Plots for', {' '}, well_ID, {' '}, 'to', {' '}, save_dir));
        
        set(well_elec_fig, 'visible', 'on')
    end




    function saveAllB2BButtonPushed(save_button, out_fig, save_dir, num_electrode_rows, num_electrode_cols, save_plots)
        set(out_fig, 'visible', 'off')
        
        num_partitions = 1/(2*num_wells);
        partition = num_partitions;
        wait_bar = waitbar(0, 'Please Wait...');
        for w = 1:num_wells
            well_ID = added_wells(w);
            %electrode_data = well_electrode_data(w, :);
            %electrode_data = well_electrode_data(w).electrode_data;
            
            waitbar(partition, wait_bar, strcat('Saving', {' '}, well_ID));
            partition = partition+num_partitions;
            saveB2BButtonPushed(save_button, '', w, save_dir, well_ID, num_electrode_rows, num_electrode_cols, save_plots, 1);
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
        set(out_fig, 'visible', 'on')
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