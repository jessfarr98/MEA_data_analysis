function MEA_GUI_display_B2B_results(AllDataRaw, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar, save_dir, reanalysis)
    
    
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
    
    if strcmp(beat_to_beat, 'on')

        close_all_button = uibutton(main_p,'push', 'BackgroundColor', '#B02727', 'Text', 'Close', 'FontColor', 'w', 'Position', [screen_width-180 100 150 50], 'ButtonPushedFcn', @(close_all_button,event) closeAllButtonPushed(close_all_button, out_fig));
        
        save_all_button =  uibutton(main_p,'push', 'BackgroundColor', '#3dd4d1', 'Text', "Save All Data", 'FontColor', 'w', 'Tooltip', "Save All To"+ " " + save_dir, 'Position', [screen_width-180 200 150 50], 'ButtonPushedFcn', @(save_all_button,event) saveAllB2BButtonPushed(save_all_button, out_fig, save_dir, num_electrode_rows, num_electrode_cols, 1));

    
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
        
        %well_elec_fig = uipanel(well_elec_fig);
        
        % left bottom width height
        main_well_pan = uipanel(well_elec_fig, 'BackgroundColor', '#fbeaea', 'Position', [0 0 screen_width screen_height]);
        
        well_p_width = screen_width-300;
        well_p_height = screen_height;
        well_pan = uipanel(main_well_pan, 'BackgroundColor', '#fbeaea', 'Position', [0 0 well_p_width well_p_height]);
        
        %close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed(close_button, well_elec_fig, out_fig));
        

        if strcmp(bipolar, 'on')
            close_y = 10;
        else
            close_y = 110;
        end
            
        
        if num_wells == 1
     
            %results_close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 0 120 50], 'ButtonPushedFcn', @(results_close_button,event) closeAllButtonPushed(results_close_button, well_elec_fig));
            %rejec_well_button = uibutton(main_well_pan,'push','Text', 'Reject Well', 'Position', [screen_width-210 350 120 50], 'ButtonPushedFcn', @(rejec_well_button,event) rejectWellButtonPushed(rejec_well_button, well_elec_fig, out_fig, well_button, well_count));

            results_close_button = uibutton(main_well_pan,'push', 'FontColor', 'w', 'BackgroundColor', '#B02727', 'Text', close_button_title, 'Position', [screen_width-210 close_y 120 30], 'ButtonPushedFcn', @(results_close_button,event) closeAllButtonPushed(results_close_button, well_elec_fig));
            
        else
            results_close_button = uibutton(main_well_pan,'push', 'FontColor', 'w', 'BackgroundColor', '#B02727', 'Text', close_button_title, 'Position', [screen_width-210 close_y 120 30], 'ButtonPushedFcn', @(results_close_button,event) closeResultsButtonPushed(results_close_button, well_elec_fig, out_fig, well_button));
            
            %rejec_well_button = uibutton(main_well_pan,'push','Text', 'Reject Well', 'Position', [screen_width-210 350 120 30], 'ButtonPushedFcn', @(rejec_well_button,event) rejectWellButtonPushed(rejec_well_button, well_elec_fig, out_fig, well_button, well_count));

        end
        
        %info_button = uibutton(main_well_pan,'push','Text', 'Information', 'Position', [screen_width-220 650 120 50], 'ButtonPushedFcn', @(legend_button,event) infoButtonPushed(info_button, beat_to_beat, stable_ave_analysis, bipolar, spon_paced));
        
        if strcmp(beat_to_beat, 'on')

            if strcmp(bipolar, 'on')
                feature_panel = uipanel(main_well_pan, 'ForegroundColor', 'k', 'Position', [screen_width-300 60 300 410]);
                
                bipolar_panel = uipanel(feature_panel, 'ForegroundColor', 'k', 'Title', 'Bipolar Plot Options', 'Position', [0 0 300 80]);
            
                %jEdit = bipolar_panel.JavaObject()
                
                bipolar_button = uibutton(bipolar_panel,'push', 'FontColor', 'k','BackgroundColor', '#f2c2c2', 'Text', well_ID + " " + "Show Bipolar Electrogam Results", 'Position', [20 30 260 30], 'ButtonPushedFcn', @(bipolar_button,event) bipolarButtonPushed(bipolar_button, well_ID, num_electrode_rows, num_electrode_cols));
                adjacent_bipolar_button = uibutton(bipolar_panel,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', well_ID+ " " + "Show Adjacent Bipolar Electrogam Results", 'Position', [20 0 260 30], 'ButtonPushedFcn', @(adjacent_bipolar_button,event) adjacentBipolarButtonPushed(adjacent_bipolar_button, well_ID, num_electrode_rows, num_electrode_cols));
                
                
                reanalyse_panel_y = 100;
                conduction_panel_y = 330;
                complex_panel_y = 200;
                
            else
                feature_panel = uipanel(main_well_pan, 'ForegroundColor', 'k', 'Position', [screen_width-300 160 300 310]);
                
                reanalyse_panel_y = 0;
                conduction_panel_y = 230;
                complex_panel_y = 100;
            end
            
            %save_button = uibutton(main_well_pan,'push',  'BackgroundColor', '#3dd4d1', 'Text', 'Save', 'Position', [screen_width-220 300 100 50], 'ButtonPushedFcn', @(save_button,event) saveB2BButtonPushed(save_button, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, 0));
            
            
            save_results_button = uibutton(main_well_pan,'push',  'BackgroundColor', '#3dd4d1', 'FontColor', 'k', 'Text', 'Save Results', 'Position', [screen_width-200 490 100 30], 'ButtonPushedFcn', @(save_results_button,event) saveB2BButtonPushed(save_results_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, 0, 0));

            %save_plots_button = uibutton(main_well_pan,'push',  'BackgroundColor', '#3dd4d1', 'Text', 'Save Plots', 'Position', [screen_width-200 300 100 50], 'ButtonPushedFcn', @(save_plots_button,event) saveB2BPlotsButtonPushed(save_plots_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols));

            %save_alldata_button = uibutton(main_well_pan,'push',  'BackgroundColor', '#3dd4d1', 'Text', 'Save All Data', 'Position', [screen_width-100 300 100 50], 'ButtonPushedFcn', @(save_alldata_button,event) saveB2BButtonPushed(save_alldata_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, 1, 0));

            %{
            if num_wells == 1
                display_final_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd483', 'Text', 'Accept Analysis', 'Position', [screen_width-220 300 120 50], 'ButtonPushedFcn', @(display_final_button,event) displayFinalB2BButtonPushed(display_final_button, '', well_elec_fig, well_button, bipolar));
            
            else
                display_final_button = uibutton(main_well_pan,'push', 'BackgroundColor', '#3dd483', 'Text', 'Accept Analysis', 'Position', [screen_width-220 300 120 50], 'ButtonPushedFcn', @(display_final_button,event) displayFinalB2BButtonPushed(display_final_button, out_fig, well_elec_fig, well_button, bipolar));
            
            end
            %}
            
            conduction_pan = uipanel(feature_panel, 'ForegroundColor', 'k', 'Title', 'Conduction Assessments', 'Position', [0 conduction_panel_y 300 80]);
            
            assess_conduction_velocity_model_button = uibutton(conduction_pan,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', 'Assess Conduction Velocity Model', 'Position', [30 30 240 30], 'ButtonPushedFcn', @(assess_conduction_velocity_model_button,event) assessConductionVelocityModelButtonPushed(assess_conduction_velocity_model_button, well_elec_fig, well_count, well_ID));
        
            
            heat_map_button = uibutton(conduction_pan,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', well_ID+ " " + "Conduction Map", 'Position', [30 0 120 30], 'ButtonPushedFcn', @(heat_map_button,event) heatMapButtonPushed(heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, 'depol'));

            
            FPD_heat_map_button = uibutton(conduction_pan,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', well_ID+ " " + "FPD Map", 'Position', [150 0 120 30], 'ButtonPushedFcn', @(FPD_heat_map_button,event) heatMapButtonPushed(FPD_heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, 'fpd'));

            
            %reanalyse_button = uibutton(main_well_pan,'push','Text', 'Re-analyse Electrodes', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
            reanalyse_panel = uipanel(feature_panel, 'ForegroundColor', 'k', 'Title', 'Well Reanalysis Options', 'Position', [0 reanalyse_panel_y 300 80]);
            
            
            reanalyse_well_button = uibutton(reanalyse_panel,'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', 'Re-analyse Well', 'Position', [60 30 180 30], 'ButtonPushedFcn', @(reanalyse_well_button,event) reanalyseWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
            
            reanalyse_selected_electrodes_button = uibutton(reanalyse_panel,  'push', 'FontColor', 'k', 'BackgroundColor', '#f2c2c2', 'Text', 'Re-analyse Selected Electrodes', 'Position', [60 0 180 30], 'ButtonPushedFcn', @(reanalyse_selected_electrodes_button,event) reanalyseSelectedElectrodesButtonPushed(reanalyse_selected_electrodes_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
            
            
            
            
       
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
                
                %electrode_count = electrode_count+1;
                if strcmp(beat_to_beat, 'on')
                    %plot all the electrodes analysed data and 
                    % left bottom width height
                    %%disp(electrode_data(electrode_count).electrode_id)
                    if isempty(well_electrode_data(well_count).electrode_data(electrode_count))
                        continue
                        
                    end
                    elec_pan = uipanel(well_pan, 'ForegroundColor', 'k',  'BackgroundColor', '#f2c2c2', 'Title', well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);
                    %elec_pan.HighlightColor  = '#da5858';
                    
                    %props = get(elec_pan, 'HighlightColor')
                    %elec_pan.SetAccess('HighlightColor', public)
                    %set(elec_pan, 'ShadowColor', '#da5858')
                    
                    
                    undo_elec_pan = uipanel(well_pan, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);
                    
                    undo_reject_electrode_button = uibutton(undo_elec_pan,'push','Text', 'Undo Reject Electrode', 'Position', [0 0 well_p_width/num_electrode_cols well_p_height/num_electrode_rows], 'ButtonPushedFcn', @(reject_electrode_button,event) undoRejectElectrodeButtonPushed(elec_pan, undo_elec_pan, electrode_count));

                    set(undo_elec_pan, 'Visible', 'off');
                    
                    elec_ax = uiaxes(elec_pan, 'Position', [10 20 (well_p_width/num_electrode_cols)-20 (well_p_height/num_electrode_rows)-40]);
                    
                    reject_electrode_button = uibutton(elec_pan,'push', 'FontColor', 'w','Text', 'Reject Electrode', 'BackgroundColor', '#B02727', 'Tooltip', 'Reject electrode', 'Position', [0 0 ((well_p_width/num_electrode_cols))/4 20], 'ButtonPushedFcn', @(reject_electrode_button,event) rejectElectrodeButtonPushed(reject_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count, undo_elec_pan));
                    
                    expand_electrode_button = uibutton(elec_pan,'push', 'FontColor', 'w','Text', 'Expanded Plot', 'BackgroundColor', '#bc2929', 'Tooltip', 'View all analysed beats', 'Position', [((well_p_width/num_electrode_cols))/4 0 ((well_p_width/num_electrode_cols))/4 20], 'ButtonPushedFcn', @(expand_electrode_button,event) expandElectrodeButtonPushed(expand_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count));
                    
                    reanalyse_electrode_button = uibutton(elec_pan,'push', 'FontColor', 'w','Text', 'Reanalyse Electrode', 'BackgroundColor', '#d12e2e', 'Tooltip','Reanalyse all beats from this electrode', 'Position', [2*(((well_p_width/num_electrode_cols))/4) 0 ((well_p_width/num_electrode_cols))/4 20], 'ButtonPushedFcn', @(reanalyse_electrode_button,event) reanalyseElectrodeButtonPushed(well_count, elec_id, [], [], [], []));
                    
                    
                    reanalyse_beat_button = uibutton(elec_pan,'push', 'FontColor', 'w','Text', 'Reanalyse Beat', 'BackgroundColor', '#d64343', 'Tooltip', 'Reanalyse or reject a subset of beats from this electrode', 'Position', [3*(((well_p_width/num_electrode_cols))/4) 0 ((well_p_width/num_electrode_cols))/4 20], 'ButtonPushedFcn', @(reanalyse_beat_button,event) reanalyseBeatButtonPushed(well_count, electrode_count, elec_id, elec_ax));
                    
                    
                    hold(elec_ax,'on')

                    MEA_GUI_display_B2B_electrodes(well_electrode_data(well_count).electrode_data, electrode_count, elec_ax)
  
                    
                    if reanalysis == 1
                        if well_electrode_data(well_count).electrode_data(electrode_count).rejected == 1
                            
                            set(undo_elec_pan, 'Visible', 'on');
                            set(elec_pan, 'Visible', 'off');
                            
                        end
                        
                    end
                    
                    hold(elec_ax,'off')

                end
            end
            
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
        
        
        
            
        function expandElectrodeButtonPushed(expand_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, electrode_count)
            expand_elec_fig = uifigure;

            expand_elec_fig.Name = strcat(well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, '_advanced_visualisation');
            expand_elec_fig.Position = [100, 100, screen_width, screen_height];
            expand_elec_fig.AutoResizeChildren = 'off';
            movegui(expand_elec_fig,'center')
            %expand_elec_fig.WindowState = 'maximized';
            
            expand_elec_tabs = uitabgroup(expand_elec_fig,  'Position', [0 0 screen_width screen_height]);
            
            
            expand_elec_panel = uitab(expand_elec_tabs, 'Title', 'Annotated Trace', 'BackgroundColor', '#f2c2c2');
            %expand_elec_panel = uipanel(expand_elec_fig, 'BackgroundColor', '#f2c2c2', 'Position', [0 0 screen_width screen_height]);
                
            expand_elec_p = uipanel(expand_elec_panel, 'BackgroundColor', '#f2c2c2', 'Position', [0 0 well_p_width well_p_height]);

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
                
                input_panel = uipanel(expand_elec_panel, 'Title', 'B2B Input Parameters', 'FontSize', 10, 'Position', [screen_width-275 text_box_height*5+60 250 text_box_height*7+20]);
                results_panel = uipanel(expand_elec_panel,'Title', 'B2B Results', 'FontSize', 10, 'Position', [screen_width-275 text_box_height*1+20 250 text_box_height*4+20]);
                
                elec_bdt_text = uieditfield(input_panel,'Text', 'Value', strcat('BDT = ', num2str(electrode_data(electrode_count).bdt)), 'FontSize', 10, 'Position', [25 text_box_height*6 200 text_box_height], 'Editable','off');
                elec_min_bp_text = uieditfield(input_panel,'Text', 'Value', strcat('min BP = ', num2str(electrode_data(electrode_count).min_bp)), 'FontSize', 10, 'Position', [25 text_box_height*5 200 text_box_height], 'Editable','off');
                elec_max_bp_text = uieditfield(input_panel,'Text', 'Value', strcat('max BP = ', num2str(electrode_data(electrode_count).max_bp)), 'FontSize', 10, 'Position', [25 text_box_height*4 200 text_box_height], 'Editable','off');
         
            elseif strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced bdt')
                text_box_height = screen_height/15;
                
                input_panel = uipanel(expand_elec_panel, 'Title', 'B2B Input Parameters', 'FontSize', 10, 'Position', [screen_width-275 text_box_height*5+60 250 text_box_height*8+20]);
                results_panel = uipanel(expand_elec_panel,'Title', 'B2B Results', 'FontSize', 10, 'Position', [screen_width-275 text_box_height*1+20 250 text_box_height*4+20]);
                
                elec_bdt_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('BDT = ', num2str(electrode_data(electrode_count).bdt)), 'FontSize', 10, 'Position', [25 text_box_height*7 200 text_box_height], 'Editable','off');
                elec_min_bp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('min BP = ', num2str(electrode_data(electrode_count).min_bp)), 'FontSize', 10, 'Position', [25 text_box_height*6 200 text_box_height], 'Editable','off');
                elec_max_bp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('max BP = ', num2str(electrode_data(electrode_count).max_bp)), 'FontSize', 10, 'Position', [25 text_box_height*5 200 text_box_height], 'Editable','off');
                elec_stim_spike_hold_off_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('Stim-spike hold-off = ', num2str(electrode_data(electrode_count).stim_spike_hold_off)), 'FontSize', 10, 'Position', [25 text_box_height*4 200 text_box_height], 'Editable','off');
                
            elseif strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced')
                text_box_height = screen_height/12;
                
                input_panel = uipanel(expand_elec_panel,'Title', 'B2B Input Parameters', 'FontSize', 10, 'Position', [screen_width-275, text_box_height*5+60, 250, text_box_height*5+20]);
                results_panel = uipanel(expand_elec_panel, 'Title',  'B2B Results', 'FontSize', 10, 'Position', [screen_width-275 text_box_height*1+20 250 text_box_height*4+20]);
                
                elec_stim_spike_hold_off_text = uieditfield(input_panel,'Text', 'Value', strcat('Stim-spike hold-off = ', num2str(electrode_data(electrode_count).stim_spike_hold_off)), 'FontSize', 10, 'Position', [25 text_box_height*4 200 text_box_height], 'Editable','off');
                
            end
            
            elec_post_spike_input_text = uieditfield(input_panel,'Text', 'Value', strcat('Post-spike = ', num2str(electrode_data(electrode_count).post_spike_hold_off)), 'FontSize', 10, 'Position', [25 text_box_height*3 200 text_box_height], 'Editable','off');
            elec_t_wave_offset_input_text = uieditfield(input_panel,'Text', 'Value', strcat('T-wave offset = ', num2str(electrode_data(electrode_count).t_wave_offset)), 'FontSize', 10, 'Position', [25 text_box_height*2 200 text_box_height], 'Editable','off');
            elec_t_wave_duration_input_text = uieditfield(input_panel,'Text', 'Value', strcat('T-wave duration = ', num2str(electrode_data(electrode_count).t_wave_duration)), 'FontSize', 10, 'Position', [25 text_box_height*1 200 text_box_height], 'Editable','off');
            elec_t_wave_shape_input_text = uieditfield(input_panel,'Text', 'Value', strcat('T-wave shape = ', electrode_data(electrode_count).t_wave_shape), 'FontSize', 10, 'Position', [25 text_box_height*0 200 text_box_height], 'Editable','off');
            
            
            elec_fpd_text = uieditfield(results_panel,'Text', 'Value', strcat('Mean FPD = ', num2str(elec_mean_FPD)), 'FontSize', 10, 'Position', [25 text_box_height*3 200 text_box_height], 'Editable','off');
            elec_amp_text = uieditfield(results_panel,'Text', 'Value', strcat('Mean Depol. Ampl. = ', num2str(elec_mean_amp)), 'FontSize', 10, 'Position', [25 text_box_height*2 200 text_box_height], 'Editable','off');
            elec_slope_text = uieditfield(results_panel,'Text', 'Value', strcat('Mean Depol. Slope = ', num2str(elec_mean_slope)), 'FontSize', 10, 'Position', [25 text_box_height*1 200 text_box_height], 'Editable','off');
            elec_bp_text = uieditfield(results_panel,'Text', 'Value', strcat('Mean Beat Period =', num2str(elec_mean_bp)), 'FontSize', 10, 'Position', [25 text_box_height*0 200 text_box_height], 'Editable','off');

            %elec_stat_plots_button = uibutton(expand_elec_panel,'push','Text','View Plots', 'BackgroundColor', '#3dd4d1', 'Position', [screen_width-220 text_box_height 200 text_box_height], 'FontSize', 10,'ButtonPushedFcn', @(elec_stat_plots_button,event) statPlotsButtonPushed(elec_stat_plots_button, expand_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, electrode_data(electrode_count)));

            expand_close_button = uibutton(expand_elec_panel,'push','Text', 'Close', 'Position', [screen_width-220 0 120 text_box_height], 'ButtonPushedFcn', @(expand_close_button,event) closeExpandButtonPushed(expand_close_button, expand_elec_fig));

            
            beat_warning_indexes = find(~cellfun(@isempty,electrode_data(electrode_count).warning_array'));
            
            warning_times = [];
            warning_volts = [];
            for i = 1:length(beat_warning_indexes)
                w = beat_warning_indexes(i);
                if beat_warning_indexes(i) == length(electrode_data(electrode_count).beat_start_times)
                    warning_signal_indx = find(electrode_data(electrode_count).time >= electrode_data(electrode_count).beat_start_times(w) & electrode_data(electrode_count).time <= electrode_data(electrode_count).time(end));
                    
                else
                    warning_signal_indx = find(electrode_data(electrode_count).time >= electrode_data(electrode_count).beat_start_times(w) & electrode_data(electrode_count).time <= electrode_data(electrode_count).beat_start_times(w+1));
                    
                    
                end
                warning_times = [warning_times; nan; electrode_data(electrode_count).time(warning_signal_indx)];
                warning_volts = [warning_volts; nan; electrode_data(electrode_count).data(warning_signal_indx)];
                
            end
            
            exp_ax = uiaxes(expand_elec_p, 'Position', [30 30 well_p_width-60 well_p_height-60]);
            hold(exp_ax,'on')
            title(exp_ax, strcat('All Annotated Beats for', {' '}, electrode_data(electrode_count).electrode_id), 'interpreter', 'none')
            plot(exp_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);
            plot(exp_ax, warning_times, warning_volts, 'r');
            plot(exp_ax, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data);
            plot(exp_ax, t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
            plot(exp_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
            plot(exp_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

            %[~, beat_start_volts, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
            %beat_start_volts =  electrode_data(electrode_count).data(beat_start_volts);

            %plot(exp_ax, electrode_data(electrode_count).beat_start_times, beat_start_volts, 'go');

            if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced') 
                        

                plot(exp_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'm.', 'MarkerSize', 20);
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
                if isempty(warning_times)
                    legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'ectopic beat start', 'paced beat start', 'activation point')
                else
                    legend(exp_ax, 'signal', 'problematic beats', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'ectopic beat start', 'paced beat start', 'activation point')
                end
            elseif strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced') 
                if isempty(warning_times)
                    legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'paced beat start', 'activation point')
                else
                    legend(exp_ax, 'signal', 'problematic beats', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'paced beat start', 'activation point')
                end
            else
                if isempty(warning_times)
                    legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point')
                else
                    legend(exp_ax, 'signal', 'problematic beats', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point')
                end

            end
            ylabel(exp_ax, 'Volts (V)')
            xlabel(exp_ax, 'Seconds (s)')
            
            
            hold(exp_ax,'off')
            
            stats_pan = uitab(expand_elec_tabs, 'Title', 'Statistics Plots', 'BackgroundColor', '#f2c2c2');


            plots_p = uipanel(stats_pan, 'BackgroundColor', '#f2c2c2', 'Position', [0 0 well_p_width well_p_height-50]);

            stats_close_button = uibutton(stats_pan,'push','Text', 'Close', 'Position', [screen_width-220 0 120 text_box_height], 'ButtonPushedFcn', @(stats_close_button,event) closeSingleFig(stats_close_button, expand_elec_fig));

            % BASED ON THE CYCLE LENGTHS PERFROM ARRHYTHMIA ANALYSIS

            %[arrhythmia_indx] = arrhythmia_analysis(electrode_data.beat_num_array(2:end), electrode_data.cycle_length_array(2:end));
            if ~isempty(electrode_data(electrode_count).arrhythmia_indx)
                %disp('detected arrhythmia!')
                arrhythmia_text = uieditfield(stats_pan,'Text', 'Value', strcat('Arrhthmic Event Detected Between Beats:', num2str(electrode_data(electrode_count).arrhythmia_indx(1)), '-', num2str(electrode_data(electrode_count).arrhythmia_indx(end))), 'FontSize', 10, 'Position', [screen_width-275 text_box_height+10 250 text_box_height], 'Editable','off');

            end

            description_panel = uipanel(plots_p,'Title', 'Plot Descriptions', 'Position', [well_p_width/2 30 well_p_width/2 (well_p_height-50)/3-50]);
            description_text = uitextarea(description_panel, 'Position', [0 0 well_p_width/2 (well_p_height-50)/3-70], 'Value', {'The cycle length vs previous cycle length plot displays cycle length variability in traces. Can be used to detect some types of arrhythmias.'; ...
                '';...
                'Cycle Length values are the time distances between each activation point. The first beat does not contain a cycle length value as there is no prior beat. These plots are used to detect arrhythmic events in the experiment.';...
                '';...
                %'Beat Periods are the time distances between each consecutive beat''s start point. For paced data this is the stimulus point and for spontaneous beats this is the point corresponding to the voltage that exceeds the beat detection threshold.';...
                %'';...
                'The FPD or the field potential duration is the distance between each activation time and the point of repolarisation for each beat.'});


            clcl_ax = uiaxes(plots_p, 'BackgroundColor', '#f2c2c2', 'Position', [0 0 well_p_width/2 (well_p_height-50)/3]);
            plot(clcl_ax, electrode_data(electrode_count).cycle_length_array(2:end-1), electrode_data(electrode_count).cycle_length_array(3:end), 'b.', 'MarkerSize', 20);
            xlabel(clcl_ax,'Cycle Length Previous Beat (s)');
            ylabel(clcl_ax,'Cycle Length (s)');
            ylim(clcl_ax, [0.9*min(electrode_data(electrode_count).cycle_length_array(2:end)) 1.1*max(electrode_data(electrode_count).cycle_length_array(2:end))])
            xlim(clcl_ax, [0.9*min(electrode_data(electrode_count).cycle_length_array(2:end)) 1.1*max(electrode_data(electrode_count).cycle_length_array(2:end))])
            title(clcl_ax, strcat('Cycle Length vs Previous Beat Cycle Length', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');


            cl_ax = uiaxes(plots_p, 'BackgroundColor', '#f2c2c2', 'Position', [0 (well_p_height-50)/3 well_p_width (well_p_height-50)/3]);
            beat_num_array = electrode_data(electrode_count).beat_num_array(1:end);
            cycle_length_array = electrode_data(electrode_count).cycle_length_array(1:end);
            cycle_length_array = [nan, cycle_length_array];
            plot(cl_ax, beat_num_array(1:end), cycle_length_array, 'b.', 'MarkerSize', 20);
            if  ~isempty(electrode_data(electrode_count).arrhythmia_indx)
                hold(cl_ax, 'on')
                plot(cl_ax, beat_num_array(electrode_data(electrode_count).arrhythmia_indx), cycle_length_array(electrode_data(electrode_count).arrhythmia_indx), 'r.', 'MarkerSize', 20);
            end
            xlabel(cl_ax, 'Beat Number');
            ylabel(cl_ax,'Cycle Length (s)');
            ylim(cl_ax, [0 max(cycle_length_array)])
            xlim(cl_ax, [0, beat_num_array(end)]);
            title(cl_ax, strcat('Cycle Length per Beat', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');

            %{
            bp_ax = uiaxes(plots_p, 'BackgroundColor', '#f2c2c2', 'Position', [0 2*((well_p_height-50)/4) well_p_width (well_p_height-50)/4]);
            plot(bp_ax, electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).beat_periods, 'b.', 'MarkerSize', 20);
            xlabel(bp_ax,'Beat Number');
            ylabel(bp_ax,'Beat Period (s)');
            ylim(bp_ax, [0 max(electrode_data(electrode_count).beat_periods)])
            title(bp_ax, strcat('Beat Period per Beat', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
            %}


            t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
            t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
            t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
            t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
            activation_times = electrode_data(electrode_count).activation_times;
            activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
            fpd_beats = electrode_data(electrode_count).beat_num_array(~isnan(electrode_data(electrode_count).t_wave_peak_times));
            elec_FPDs = [t_wave_peak_times - activation_times];
            fpd_ax = uiaxes(plots_p, 'BackgroundColor', '#f2c2c2', 'Position', [0 2*((well_p_height-50)/3) well_p_width (well_p_height-50)/3]);
            plot(fpd_ax, fpd_beats, elec_FPDs, 'b.', 'MarkerSize', 20);
            xlabel(fpd_ax,'Beat Number');
            ylabel(fpd_ax,'FPD (s)');
            ylim(fpd_ax, [0 max(elec_FPDs)])
            title(fpd_ax, strcat('FPD per Beat Num', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');

            
            function closeExpandButtonPushed(expand_close_button, expand_elec_fig)
                
                %set(expand_elec_fig, 'Visible', 'off');
                delete(expand_close_button)
                close(expand_elec_fig)
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
        
        function assessConductionVelocityModelButtonPushed(assess_conduction_velocity_model_button, well_elec_fig, well_count, well_ID)
        
            conduction_velocity_figure = uifigure;
            conduction_velocity_figure.Name = 'Conduction Velocity Model';
            movegui(conduction_velocity_figure,'center')
            conduction_velocity_figure.WindowState = 'maximized';
            con_vel_panel = uipanel(conduction_velocity_figure, 'BackgroundColor', '#fbeaea', 'Position', [0 0 screen_width screen_height]);
            close_con_vel_button = uibutton(con_vel_panel,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_con_vel_button,event) closeSingleFig(close_con_vel_button, conduction_velocity_figure));

            
            
            %if strcmp(well_electrode_data(well_count).spon_paced, 'spon')
                el_count = 1;
                dist_array = [];
                %act_array = one(num_electrode_rows*num_electrode_cols);
                act_array = [];
                electrode_ids = [];
                el_ids = [well_electrode_data(well_count).electrode_data(:).electrode_id];
                well_ID = well_electrode_data(well_count).wellID;
                for er = num_electrode_rows:-1:1
                    for ec = num_electrode_cols:-1:1
                        elec_id = strcat(well_ID, '_', num2str(ec), '_', num2str(er));
                        
                        e_indx = contains(el_ids, elec_id);
                        e_indx = find(e_indx == 1);
                        el_count = e_indx;

                        if isempty(elec_id)
                            continue
                        end
                        
                        
                        if well_electrode_data(well_count).electrode_data(el_count).rejected == 1
                            continue
                        end
                        act_array = [act_array; well_electrode_data(well_count).electrode_data(el_count).activation_times(2)];
                        electrode_ids = [electrode_ids; elec_id];
                        %el_count = el_count + 1;

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
                        elec_id = strcat(well_ID, '_', num2str(ec), '_', num2str(er));

                        e_indx = contains(el_ids, elec_id);
                        e_indx = find(e_indx == 1);
                        el_count = e_indx;
                        
                        if isempty(el_count)
                            continue
                        end
                        if well_electrode_data(well_count).electrode_data(el_count).rejected == 1
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
                        %el_count = el_count + 1;
                    end
                end
            %{
            else
                %el_count = 1;
                dist_array = [];
                act_array =[];
                el_ids = [well_electrode_data(well_count).electrode_data(:).electrode_id];
                for er = num_electrode_rows:-1:1
                    for ec = num_electrode_cols:-1:1
                        elec_id = strcat(well_ID, '_', num2str(ec), '_', num2str(er))
                        e_indx = contains(el_ids, elec_id);
                        e_indx = find(e_indx == 1);
                        el_count = e_indx;
                        
                        
                        if isempty(el_count)
                            continue
                        end
                        if well_electrode_data(well_count).electrode_data(el_count).rejected == 1
                            continue
                        end
                        
                        dist_ec = 5-ec
                        er
                        
                        dist = sqrt(((350*(dist_ec-1))^2)+((350*(er-1))^2))


                        if length(well_electrode_data(well_count).electrode_data(el_count).activation_times) < 2
                            continue
                        end
                        dist_array = [dist_array; dist];

                        well_electrode_data(well_count).electrode_data(el_count).activation_times(2)
                        act_array =[act_array; well_electrode_data(well_count).electrode_data(el_count).activation_times(2)];
                        %el_count = el_count + 1;
                    end
                end
            end
            %}
            if isempty(dist_array)
                close(conduction_velocity_figure)
                return
            end
            
            conduction_velocity = well_electrode_data(well_count).conduction_velocity;
            
            display_con_vel = sprintf('Conduction Velocity = %f', conduction_velocity);
            
            %display_units = sprintf('%im', '\mu');
            display_units = '(dμm/dt)';
            
            display_con_vel= display_con_vel+" "+ display_units;
            
            conduction_velocity_text = uieditfield(con_vel_panel,'Text', 'Value', display_con_vel+" ", 'FontSize', 12, 'Position', [screen_width-280 150 260 50], 'Editable','off');
    
            lin_eqn = fittype(sprintf('(1/%f)*x+b', conduction_velocity));
    
            %model = fit(dist_array, act_array, lin_eqn)
            model = well_electrode_data(well_count).conduction_velocity_model;
            
            if reanalysis == 0
                plot_model = (model.m)*dist_array+model.b;
            else
                plot_model = (1/conduction_velocity)*dist_array+model.b;
            end

            con_vel_ax = uiaxes(con_vel_panel, 'BackgroundColor', '#fbeaea', 'Position', [0 0 well_p_width well_p_height]);
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
            
            
            reanalyse_button = uibutton(reanalyse_beat_panel,'push','Text', 'Reanalyse Beats',  'BackgroundColor', '#3dd4d1', 'Position', [210 50 100 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseSelectedBeats(reanalyse_button, reanalyse_beat_fig, electrode_count));
            remove_button = uibutton(reanalyse_beat_panel,'push','Text', 'Remove Beats',  'BackgroundColor', '#3dd4d1', 'Position', [210 0 100 50], 'ButtonPushedFcn', @(remove_button,event) removeSelectedBeats(remove_button, reanalyse_beat_fig, electrode_count));
            

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
            
            function reanalyseSelectedBeats(reanalyse_button, reanalyse_beat_fig, electrode_count)
                
                negative_skip = 'n/a';
                reanalysed_post_spike = nan;
                
                if strcmp(get(range_button, 'visible'), 'off')
                % Analysing beat indexes 
                    
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
                    
                    
                    if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'spon')
                    %Spontaneous data needs to be offset by the post-spike hold off to allow whole beta range to be analysed with bdt 
                        negative_skip = 'no';
                        if well_electrode_data(well_count).electrode_data(electrode_count).bdt < 0
                            disp('Whole electrode negative bdt');
                           reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(start_indx);

                           if reanalyse_time_region_start - well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off > well_electrode_data(well_count).electrode_data(electrode_count).time(1)
                               negative_skip = 'yes';
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
                               split_one = strsplit(first_beat_warning{1}, 'BDT=');
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
                        if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced')
                            reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).Stims(start_indx);

                            reanalyse_time_region_end = well_electrode_data(well_count).electrode_data(electrode_count).Stims(end_indx);
                            
                        else
                            reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(start_indx);

                            reanalyse_time_region_end = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(end_indx);
                        end
                       
                    end
                else
                    if strcmp(get(time_range_button, 'visible'), 'off')
                    % Analysing beats within an entered time range
                        start_beat = get(beats_range_1_ui, 'value');
                        end_beat = get(beats_range_2_ui, 'value');
                        
                        
                        
                        if start_beat > end_beat
                            msgbox('Start beat entered as time after end beat. Choose new values please');

                            set(beats_range_1_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(1));
                            set(beats_range_2_ui, 'value', well_electrode_data(well_count).electrode_data(electrode_count).time(end));
                            return
                        end
                        
                        % Find the indexes
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
                       
                        % Find the time points that correspond to the indexes. 
                        if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'spon')
                        %Spontaneous data needs to be offset by the post-spike hold off to allow whole beta range to be analysed with bdt 
                            negative_skip = 'no';
                            if well_electrode_data(well_count).electrode_data(electrode_count).bdt < 0
                                
                                disp('Whole electrode negative bdt');
                               reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(start_indx);

                               if reanalyse_time_region_start - well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off > well_electrode_data(well_count).electrode_data(electrode_count).time(1)
                                   negative_skip = 'yes';
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
                                   split_one = strsplit(first_beat_warning{1}, 'BDT=');
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
                        %Paced and paced bdt just being indexed based off the raw start time. 
                        % Paced BDT needs to be ensured that the test isnt
                        % 
                            if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced')
                                reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).Stims(start_indx);

                                reanalyse_time_region_end = well_electrode_data(well_count).electrode_data(electrode_count).Stims(end_indx);
                            else
                                reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(start_indx);

                                reanalyse_time_region_end = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(end_indx);
                            end

                        end
                        
            
                    else
                        % Anlyse just one beat entered as an index
                        beat_num = get(beat_num_ui, 'value');
                        start_indx = beat_num;
                        if beat_num == length(well_electrode_data(well_count).electrode_data(electrode_count).beat_num_array)
                            end_indx = beat_num;
                        else
                            end_indx = beat_num+1;
                        end
                        
                        if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'spon')
                        %Spontaneous data needs to be offset by the post-spike hold off to allow whole beta range to be analysed with bdt 
                            negative_skip = 'no';
                            if well_electrode_data(well_count).electrode_data(electrode_count).bdt < 0
                                disp('Whole electrode negative bdt');
                               reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(start_indx);

                               if reanalyse_time_region_start - well_electrode_data(well_count).electrode_data(electrode_count).post_spike_hold_off > well_electrode_data(well_count).electrode_data(electrode_count).time(1)
                                   negative_skip = 'yes';
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
                                   split_one = strsplit(first_beat_warning{1}, 'BDT=');
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
                            if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced')
                                reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).Stims(start_indx);

                                reanalyse_time_region_end = well_electrode_data(well_count).electrode_data(electrode_count).Stims(end_indx);
                                
                            else
                                reanalyse_time_region_start = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(start_indx);

                                reanalyse_time_region_end = well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(end_indx);
                            end
                        end
                    
                    end
                end
                
                
                
                %{
                reanalyse_time_region_start = start_beat;

                reanalyse_time_region_end = end_beat;
                %}
                    
                
                [well_electrode_data(well_count)] = reanalyse_selected_beatsV2(well_electrode_data(well_count), electrode_count, num_electrode_rows, num_electrode_cols, well_elec_fig, elec_ax, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, reanalyse_time_region_start, reanalyse_time_region_end, start_indx, end_indx, reanalyse_beat_fig, negative_skip, reanalysed_post_spike);
 
            end

            
            function removeSelectedBeats(remove_button, reanalyse_beat_fig, electrode_count)
                
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
        

        function heatMapButtonPushed(heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, map_type)

            %set(well_elec_fig, 'Visible', 'off')
            
            hmap_prompt_fig = uifigure;
            hmap_prompt_pan = uipanel(hmap_prompt_fig, 'Position', [0 0 screen_width screen_height]);
            
            beat_num_text = uieditfield(hmap_prompt_pan,'Text', 'FontSize', 12, 'Value', 'Reanalyse Beat Number', 'Position', [10 150 200 40], 'Editable','off');
            beat_num_ui = uieditfield(hmap_prompt_pan, 'numeric', 'Tag', 'Num Beat Patterns', 'Position', [10 100 200 40], 'FontSize', 12, 'Value', 1, 'ValueChangedFcn', @(beat_num_ui,event) changedNumBeats(beat_num_ui));
            
            beats_range_1_text = uieditfield(hmap_prompt_pan,'Text', 'FontSize', 12, 'Value', 'Start Beat Range', 'Position', [10 150 150 40], 'Editable','off');
            beats_time_range_1_text = uieditfield(hmap_prompt_pan,'Text', 'FontSize', 12, 'Value', 'Beat Time Range Start (s)', 'Position', [10 150 150 40], 'Editable','off');
            beats_range_1_ui = uieditfield(hmap_prompt_pan, 'numeric', 'Tag', 'Start Beat Range', 'Position', [10 100 150 40], 'FontSize', 12, 'Value', 1, 'ValueChangedFcn', @(beats_range_1_ui,event) changedNumBeats(beats_range_1_ui));
            
            beats_range_2_text = uieditfield(hmap_prompt_pan,'Text', 'FontSize', 12, 'Value', 'End Beat Range', 'Position', [160 150 150 40], 'Editable','off');
            beats_time_range_2_text = uieditfield(hmap_prompt_pan,'Text', 'FontSize', 12, 'Value', 'Beat Time Range End (s)', 'Position', [160 150 150 40], 'Editable','off');
            beats_range_2_ui = uieditfield(hmap_prompt_pan, 'numeric', 'Tag', 'End Beat Range', 'Position', [160 100 150 40], 'FontSize', 12, 'Value', 1, 'ValueChangedFcn', @(beats_range_2_ui,event) changedNumBeats(beats_range_2_ui));
            
            
            %if strcmp(map_type, 'depol')
            go_button = uibutton(hmap_prompt_pan,'push','Text', 'Go',  'BackgroundColor', '#3dd4d1', 'Position', [210 50 100 50], 'ButtonPushedFcn', @(go_button,event) conductionMapGo(go_button, map_type));
            %elseif strcmp(map_type, 'fpd')
                
            %    go_button = uibutton(hmap_prompt_pan,'push','Text', 'Go',  'BackgroundColor', '#3dd4d1', 'Position', [210 50 100 50], 'ButtonPushedFcn', @(go_button,event) conductionMapGo(go_button));
            %end
            

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

            function changedNumBeats(ui)
                if strcmp(get(time_range_button, 'visible'), 'on')
                    % Means assessing beat number/index
                    
                    min_beat_count  = nan;
                    e_count = 0;
                    for ee_r = 1:num_electrode_rows
                        for ee_c = 1:num_electrode_cols
                            e_count = e_count+1;
                            if isnan(min_beat_count)
                                if ~isempty(well_electrode_data(well_count).electrode_data(e_count).beat_start_times)
                                    
                                    min_beat_count = length(well_electrode_data(well_count).electrode_data(e_count).beat_start_times);
                                    
                                end
                            else
                                if ~isempty(well_electrode_data(well_count).electrode_data(e_count).beat_start_times)
                                   if length(well_electrode_data(well_count).electrode_data(e_count).beat_start_times) < min_beat_count
                                       min_beat_count = length(well_electrode_data(well_count).electrode_data(e_count).beat_start_times);
                                   end
                                end
                                
                            end
                            
                            
                        end
                    end
                    
                    if get(ui, 'Value') > min_beat_count
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
            
            function conductionMapGo(go_button, map_type)
                
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
                        num_hm_beats = get(beat_num_ui, 'value');
                        start_beat = 1;
                        end_beat = get(beat_num_ui, 'value');
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
                                if strcmp(map_type, 'depol')
                                    act_times = elec_data.activation_times;
                                elseif strcmp(map_type, 'fpd')
                                    act_times = elec_data.t_wave_peak_times - elec_data.activation_times;
                                    
                                end
                                
                                if length(elec_data.activation_times) < n
                                    act_time = nan;
                                else
                                    if strcmp(map_type, 'depol')
                                        act_time = act_times(n);
                                    elseif strcmp(map_type, 'fpd')
                                        act_time = act_times(n);
                                        
                                    end
                                end
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
                conduction_map_GUI4(start_activation_times, num_electrode_rows, num_electrode_cols, spon_paced, well_elec_fig, hmap_prompt_fig, num_hm_beats, start_beat, map_type, 0)
            end
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
        
        
        if exist(fullfile(save_dir, strcat(well_electrode_data(well_count).wellID, '.xlsx')), 'file')
            %disp('yeah')
            delete(fullfile(save_dir, strcat(well_electrode_data(well_count).wellID, '.xlsx')))
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

    

    function saveB2BButtonPushed(save_button, well_elec_fig, well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, save_plots, saving_multiple)
        %%disp('save b2b')
        %%disp(save_dir)
        
        
        disp(strcat('Saving Data for', {' '}, well_ID))
        output_filename = fullfile(save_dir, strcat(well_ID, '.xlsx'));
        if exist(output_filename, 'file')
            try
                delete(output_filename);
            catch
                msgbox(strcat(output_filename, {' '}, 'is open. Please close and try saving again.'))
                %close(wait_bar)
                %set(ge_results_fig, 'visible', 'on')
                return
            end
        end
        
        if saving_multiple == 0
            %set(well_elec_fig, 'visible', 'off')
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
        
        well_sum_FPDs_beats = [];
        well_sum_slopes_beats = [];
        well_sum_amps_beats = [];
        well_sum_bps_beats = [];
        well_sum_act_times_beats = [];
        well_sum_act_volts_beats = [];
        well_sum_max_depol_times_beats = [];
        well_sum_max_depol_volts_beats = [];
        well_sum_min_depol_times_beats = [];
        well_sum_min_depol_volts_beats = [];
        well_sum_t_wave_times_beats = [];
        well_sum_t_wave_volts_beats = [];
        well_sum_cycle_lengths_beats = [];
        
        sheet_count = 2;
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
        sum_arrhythmic_event = 0;
        count_arrhthmic_average_electrode = 0;
        
        
        %start_activation_time_array = [];
        for elec_r = num_electrode_rows:-1:1
            for elec_c = 1:num_electrode_cols
                elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                
                if isempty(elec_indx)

                    continue
                end
                
                electrode_count = elec_indx;
                
                try
                    start_activation_time = electrode_data(electrode_count).activation_times(2);
                catch
                    start_activation_time = nan;
                    
                end
                
                if isempty(min_act_elec_id)
                    min_act_elec_id = electrode_data(electrode_count).electrode_id;
                    min_act_elec_indx = electrode_count;
                    min_act_time = start_activation_time;
                else
                    if start_activation_time < min_act_time
                        min_act_time = start_activation_time;
                        min_act_elec_indx = electrode_count;
                        min_act_elec_id = electrode_data(electrode_count).electrode_id;
                    end
                end
                
                %start_activation_time_array = [start_activation_time_array, start_activation_time];
                
            end
        end
        
        orig_min_act_electrode_activation_times = electrode_data(min_act_elec_indx).activation_times;
        
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
                    %continue;
                end
                
                
                sheet_count = sheet_count+1;
                
                min_act_electrode_activation_times = orig_min_act_electrode_activation_times;
                
                %electrode_stats_header = {electrode_data(electrode_count).electrode_id, 'Beat No.', 'Beat Start Time (s)', 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Cycle Length (s)'};
                
                %t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                %t_wave_peak_times = 
                %activation_times = electrode_data(electrode_count).activation_times;
                %activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                
                
                try
                    start_activation_time = electrode_data(electrode_count).activation_times(2);
                catch
                    start_activation_time = nan;
                    
                end
                
                if isempty(max_act_elec_id)
                    max_act_elec_id = electrode_data(electrode_count).electrode_id;
                    max_act_time = start_activation_time;
                else
                    if start_activation_time > max_act_time
                        max_act_time = start_activation_time;
                        max_act_elec_id = electrode_data(electrode_count).electrode_id;
                    end
                end
                
                %{
                if isempty(min_act_elec_id)
                    min_act_elec_id = electrode_data(electrode_count).electrode_id;
                    min_act_time = start_activation_time;
                else
                    if start_activation_time < min_act_time
                        min_act_time = start_activation_time;
                        min_act_elec_id = electrode_data(electrode_count).electrode_id;
                    end
                end
                %}
                
                
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
                        FPDc_fridericia = mean_FPD/((mean_bp)^(1/3));
                        FPDc_bazzet = mean_FPD/((mean_bp)^(1/2));
                        
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'FPDc Fridericia (s)'; 'FPDc Bazzet (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};
                        mean_data = [sheet_count; mean_FPD; FPDc_fridericia; FPDc_bazzet; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape}, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                        %mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Stim-spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Stim spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                    end
                else
                % Beat to beat in a time region
                    if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                        FPDc_fridericia = mean_FPD/((mean_bp)^(1/3));
                        FPDc_bazzet = mean_FPD/((mean_bp)^(1/2));
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'FPDc Fridericia (s)'; 'FPDc Bazzet (s)';'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};
                        
                        mean_data = [sheet_count; mean_FPD; FPDc_fridericia; FPDc_bazzet; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Stim-spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                        headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Stim spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};
                        mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                        mean_data = num2cell(mean_data);
                        mean_data = vertcat({''}, mean_data);
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                        mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                    end

                end 
                
                sum_arrhythmic_event = sum_arrhythmic_event+electrode_data(electrode_count).num_arrhythmic;
                count_arrhthmic_average_electrode = count_arrhthmic_average_electrode+1;
                
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
                
                beat_start_volts = electrode_data(electrode_count).beat_start_volts;
                [br, bc] = size(beat_start_volts);
                beat_start_volts = reshape(beat_start_volts, [bc br]);
                
                activation_times = electrode_data(electrode_count).activation_times;
                min_act = min(activation_times);
                orig_activation_times = activation_times;
                [br, bc] = size(activation_times);
                activation_times = reshape(activation_times, [bc br]);
                
                activation_points = electrode_data(electrode_count).activation_point_array;
                [br, bc] = size(activation_points);
                activation_points = reshape(activation_points, [bc br]);

                
                max_depol_time_array = electrode_data(electrode_count).max_depol_time_array;
                [br, bc] = size(max_depol_time_array);
                max_depol_time_array = reshape(max_depol_time_array, [bc br]);
                
                min_depol_time_array = electrode_data(electrode_count).min_depol_time_array;
                [br, bc] = size(min_depol_time_array);
                min_depol_time_array = reshape(min_depol_time_array, [bc br]);
                
                max_depol_point_array = electrode_data(electrode_count).max_depol_point_array;
                [br, bc] = size(max_depol_point_array);
                max_depol_point_array = reshape(max_depol_point_array, [bc br]);
                
                
                min_depol_point_array = electrode_data(electrode_count).min_depol_point_array;
                [br, bc] = size(min_depol_point_array);
                min_depol_point_array = reshape(min_depol_point_array, [bc br]);
                
                
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
                
                wavelet_families = electrode_data(electrode_count).t_wave_wavelet_array;
                [br, bc] = size(wavelet_families);
                wavelet_families = reshape(wavelet_families, [bc br]);
                
                
                polynomial_degrees = electrode_data(electrode_count).t_wave_polynomial_degree_array;
                [br, bc] = size(polynomial_degrees);
                polynomial_degrees = reshape(polynomial_degrees, [bc br]);

                warning_array = electrode_data(electrode_count).warning_array;
                [br, bc] = size(warning_array);
                warning_array = reshape(warning_array, [bc br]);
                
                [ar, ac] = size(activation_times);
                [mr, mc] = size(min_act_electrode_activation_times);
                sub_activation_times = activation_times;
                
                %{
                if ar == 1
                    if mr == 1
                        if ac ~= mc
                            if ac > mc
                                add_extra = ac-mc;
                                add_extras_array = zeros(1, add_extra);
                                
                                min_act_electrode_activation_times = [min_act_electrode_activation_times add_extras_array];
                                
                                
                                
                            else
                                add_extra = mc-ac;
                                add_extras_array = zeros(1, add_extra);
                                
                                sub_activation_times = [sub_activation_times add_extras_array];
                                
                            end
                        end
                    else
                        if ac ~= mr
                            if ac > mr
                                add_extra = ac-mr;
                                add_extras_array = zeros(add_extra, 1);
                                
                                min_act_electrode_activation_times = [min_act_electrode_activation_times; add_extras_array];
                                
                            else
                                add_extra = mr-ac;
                                add_extras_array = zeros(1, add_extra);
                                
                                sub_activation_times = [sub_activation_times add_extras_array];
                                
                            end
                        end
                        
                    end
                else
                    if mr == 1
                        if ar ~= mc
                            if ar > mc
                                add_extra = ar-mc;
                                add_extras_array = zeros(1, add_extra);
                                
                                min_act_electrode_activation_times = [min_act_electrode_activation_times add_extras_array];
                            else
                                add_extra = mc-ar;
                                add_extras_array = zeros(add_extra, 1);
                                
                                sub_activation_times = [sub_activation_times; add_extras_array];
                                
                            end
                        end
                    else
                        if ar ~= mr
                            if ar > mr
                                add_extra = ar-mr;
                                add_extras_array = zeros(add_extra, 1);
                                
                                min_act_electrode_activation_times = [min_act_electrode_activation_times; add_extras_array];
                            else
                                add_extra = mr-ar;
                                add_extras_array = zeros(add_extra, 1);
                                
                                sub_activation_times = [sub_activation_times; add_extras_array];
                                
                            end
                        end
                        
                    end
                    
                end
                
                %}
                
                if ar == 1
                    if mr == 1
                        if ac ~= mc
                            min_act_electrode_activation_times = zeros(1, ac);
                            min_act_electrode_activation_times(:) = nan;

                        end
                    else
                        if ac ~= mr
                            min_act_electrode_activation_times = zeros(1, ac);
                            min_act_electrode_activation_times(:) = nan;
                        end
                        
                    end
                else
                    if mr == 1
                        if ar ~= mc
                            min_act_electrode_activation_times = zeros(1, ar);
                            min_act_electrode_activation_times(:) = nan;
                        end
                    else
                        if ar ~= mr
                            min_act_electrode_activation_times = zeros(1, rc);
                            min_act_electrode_activation_times(:) = nan;
                        end
                        
                    end
                    
                end
                
                [sr, sc] = size(sub_activation_times);
                [mr, mc] = size(min_act_electrode_activation_times);
                
                if mr == 1
                    min_act_electrode_activation_times = reshape(min_act_electrode_activation_times, [mc mr]);
                end
                
                activation_times_subtract_min_act_electrode_act_times = sub_activation_times - min_act_electrode_activation_times;
                [br, bc] = size(activation_times_subtract_min_act_electrode_act_times);
                
                
                if br == 1
                    activation_times_subtract_min_act_electrode_act_times = reshape(activation_times_subtract_min_act_electrode_act_times, [bc br]);
                end
                
                
                if strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                    paced_indxs = ismembertol(beat_start_times, electrode_data(electrode_count).Stims, .00001);
                    %paced_indxs = ismembertol(electrode_data(electrode_count).Stims, .03);
                    %paced_indxs= find(islamost((beat_start_times, electrode_data(electrode_count).Stims, .03) == 1)
                    paced_indxs = find(paced_indxs == 1);
                    
                    
                    
                    paced_ectopic_labels = cell(length(beat_start_times), 1);
                    paced_ectopic_labels(:) = {"ectopic"};
                    paced_ectopic_labels(paced_indxs) = {"paced"};
                    
                    
                    electrode_stats_table = table('Size', [length(beat_num_array) 22], 'VariableTypes',["string",  "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double", "double", "double", "double", "double", "double", "double", "string", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Beat Start Volts (V)", "Activation Time (s)", "Activation Time Volts (V)", "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "Paced/Ectopic", "T-wave Denoising Wavelet Family", "T-wave Polynomial Degree", "Warnings"]));

                    if electrode_data(electrode_count).rejected == 0
                        
                        if ~isempty(beat_num_array)
                            electrode_stats_table(:, 2) = num2cell(beat_num_array);

                            electrode_stats_table(:, 3) = num2cell(beat_start_times);

                            electrode_stats_table(:, 4) = num2cell(beat_start_volts);

                            electrode_stats_table(:, 5) = num2cell(activation_times);

                            electrode_stats_table(:, 6) = num2cell(activation_points);
                            
                            %electrode_stats_table(:, 7) = num2cell(activation_times_subtract_min_act_electrode_act_times);

                            electrode_stats_table(:, 7) = num2cell(min_depol_time_array);

                            electrode_stats_table(:, 8) = num2cell(min_depol_point_array);

                            electrode_stats_table(:, 9) = num2cell(max_depol_time_array);

                            electrode_stats_table(:, 10) = num2cell(max_depol_point_array);

                            electrode_stats_table(:, 11) = num2cell(amps);

                            electrode_stats_table(:, 12) = num2cell(slopes);

                            electrode_stats_table(:, 13) = num2cell(t_wave_peak_times);

                            electrode_stats_table(:, 14) = num2cell(t_wave_peak_array);

                            electrode_stats_table(:, 15) = num2cell(FPDs);

                            electrode_stats_table(:, 16) = num2cell(beat_periods);

                            electrode_stats_table(:, 17) = num2cell(cycle_length_array);

                            electrode_stats_table(:, 18) = num2cell(act_sub_min);

                            electrode_stats_table(:, 19) = paced_ectopic_labels;

                            electrode_stats_table(:, 20) = wavelet_families;

                            electrode_stats_table(:, 21) = num2cell(polynomial_degrees);

                            electrode_stats_table(:, 22) = warning_array;
                        end
                    else
                        %{
                        electrode_stats_table(:, 2) = {};

                        electrode_stats_table(:, 3) = {};

                        electrode_stats_table(:, 4) = {};

                        electrode_stats_table(:, 5) = {};

                        electrode_stats_table(:, 6) = {};

                        electrode_stats_table(:, 7) = {};

                        electrode_stats_table(:, 8) = {};

                        electrode_stats_table(:, 9) = {};

                        electrode_stats_table(:, 10) = {};

                        electrode_stats_table(:, 11) = {};

                        electrode_stats_table(:, 12) = {};

                        electrode_stats_table(:, 13) = {};

                        electrode_stats_table(:, 14) = {};

                        electrode_stats_table(:, 15) = {};

                        electrode_stats_table(:, 16) = {};

                        electrode_stats_table(:, 17) = {};

                        electrode_stats_table(:, 18) = {};

                        electrode_stats_table(:, 19) = {};

                        electrode_stats_table(:, 20) = {};

                        electrode_stats_table(:, 21) = {};

                        electrode_stats_table(:, 22) = {};
                        %}
                    end
                    
                    
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                    if electrode_data(electrode_count).rejected == 0
                        electrode_stats_table = table('Size', [length(beat_num_array) 23], 'VariableTypes',["string", "double", "double",  "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double","double","double","double","double","double", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Beat Start Volts (V)", "Activation Time (s)", "Activation Time Volts (V)", "Activation Time-Stimulus Time (s)","Activation Times-min Elec. Activation Times (s)", "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "T-wave Denoising Wavelet Family", "T-wave Polynomial Degree", "Warnings"]));

                        if ~isempty(beat_num_array)
                            sub_Stims = electrode_data(electrode_count).Stims;
                            [br, bc] = size(sub_Stims);
                            sub_Stims = reshape(sub_Stims, [bc br]);
                            
                            activation_time_stim_offset_array = activation_times- sub_Stims;
                            
                            electrode_stats_table(:, 2) = num2cell(beat_num_array);

                            electrode_stats_table(:, 3) = num2cell(beat_start_times);

                            electrode_stats_table(:, 4) = num2cell(beat_start_volts);

                            electrode_stats_table(:, 5) = num2cell(activation_times);

                            electrode_stats_table(:, 6) = num2cell(activation_points);
                            
                            electrode_stats_table(:, 7) = num2cell(activation_time_stim_offset_array);
                            
                            electrode_stats_table(:, 8) = num2cell(activation_times_subtract_min_act_electrode_act_times);

                            electrode_stats_table(:, 9) = num2cell(min_depol_time_array);

                            electrode_stats_table(:, 10) = num2cell(min_depol_point_array);

                            electrode_stats_table(:, 11) = num2cell(max_depol_time_array);

                            electrode_stats_table(:, 12) = num2cell(max_depol_point_array);

                            electrode_stats_table(:, 13) = num2cell(amps);

                            electrode_stats_table(:, 14) = num2cell(slopes);

                            electrode_stats_table(:, 15) = num2cell(t_wave_peak_times);

                            electrode_stats_table(:, 16) = num2cell(t_wave_peak_array);

                            electrode_stats_table(:, 17) = num2cell(FPDs);

                            electrode_stats_table(:, 18) = num2cell(beat_periods);

                            cycle_length_array = [nan; cycle_length_array];
                            disp(size(beat_periods))
                            disp(size(cycle_length_array))
                            electrode_stats_table(:, 19) = num2cell(cycle_length_array);

                            electrode_stats_table(:, 20) = num2cell(act_sub_min);

                            electrode_stats_table(:, 21) = wavelet_families;

                            electrode_stats_table(:, 22) = num2cell(polynomial_degrees);

                            electrode_stats_table(:, 23) = warning_array;
                        end
                    else
                        electrode_stats_table = table('Size', [0 23], 'VariableTypes',["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double","double","double","double","double","double", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Beat Start Volts (V)", "Activation Time (s)", "Activation Time Volts (V)", "Activation Time-Stimulus Time (s)", "Activation Times-min Elec. Activation Times (s)", "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "T-wave Denoising Wavelet Family", "T-wave Polynomial Degree", "Warnings"]));

 
                    end
                    
                    
                else
                    
                % Spontaneous
                    
                    
                    %{
                    if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                        Stim_volts = electrode_data(electrode_count).Stim_volts(1:end-1);
                        %[er, ec] = size(Stim_volts)
                        %Stim_volts = reshape(Stim_volts, [ec, er]);
                        
                        Stim_times = electrode_data(electrode_count).Stims(1:end-1);
                        [er, ec] = size(Stim_times);
                        Stim_times = reshape(Stim_times, [ec, er]);
                        
                        electrode_stats_table(:, 3) = num2cell(Stim_times);
                        electrode_stats_table(:, 4) = num2cell(Stim_volts);
                    else
                    
                        electrode_stats_table(:, 3) = num2cell(beat_start_times);
                        electrode_stats_table(:, 4) = num2cell(beat_start_volts);
                    end
                    %}
                    
                    if electrode_data(electrode_count).rejected == 0
                        
                        electrode_stats_table = table('Size', [length(beat_num_array) 22], 'VariableTypes',["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double","double","double","double","double","double", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Beat Start Volts (V)", "Activation Time (s)", "Activation Time Volts (V)", "Activation Times-min Elec. Activation Times (s)", "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "T-wave Denoising Wavelet Family", "T-wave Polynomial Degree", "Warnings"]));

                        if ~isempty(beat_num_array)
                            electrode_stats_table(:, 2) = num2cell(beat_num_array);

                            electrode_stats_table(:, 3) = num2cell(beat_start_times);

                            electrode_stats_table(:, 4) = num2cell(beat_start_volts);

                            electrode_stats_table(:, 5) = num2cell(activation_times);

                            electrode_stats_table(:, 6) = num2cell(activation_points);
                            
                            disp(size(activation_points))
                            disp(size(activation_times_subtract_min_act_electrode_act_times))
                            
                            
                            electrode_stats_table(:, 7) = num2cell(activation_times_subtract_min_act_electrode_act_times);

                            electrode_stats_table(:, 8) = num2cell(min_depol_time_array);

                            electrode_stats_table(:, 9) = num2cell(min_depol_point_array);

                            electrode_stats_table(:, 10) = num2cell(max_depol_time_array);

                            electrode_stats_table(:, 11) = num2cell(max_depol_point_array);

                            electrode_stats_table(:, 12) = num2cell(amps);

                            electrode_stats_table(:, 13) = num2cell(slopes);

                            electrode_stats_table(:, 14) = num2cell(t_wave_peak_times);

                            electrode_stats_table(:, 15) = num2cell(t_wave_peak_array);

                            electrode_stats_table(:, 16) = num2cell(FPDs);

                            electrode_stats_table(:, 17) = num2cell(beat_periods);

                            cycle_length_array = [nan; cycle_length_array];
                            electrode_stats_table(:, 18) = num2cell(cycle_length_array);

                            electrode_stats_table(:, 19) = num2cell(act_sub_min);

                            electrode_stats_table(:, 20) = wavelet_families;

                            electrode_stats_table(:, 21) = num2cell(polynomial_degrees);

                            electrode_stats_table(:, 22) = warning_array;
                        end
                    else
                        electrode_stats_table = table('Size', [0 22], 'VariableTypes',["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double","double","double","double","double","double","double", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Beat Start Volts (V)", "Activation Time (s)", "Activation Time Volts (V)", "Activation Times-min Elec. Activation Times (s)", "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "T-wave Denoising Wavelet Family", "T-wave Polynomial Degree", "Warnings"]));


                    end
                    
                end
                                 
                
                try
                    if sheet_count ~= 3
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
                
                %{
                if save_plots == 1
                    fig = figure();
                    set(fig, 'visible', 'off');
                    hold('on')
                    plot(electrode_data(electrode_count).time, electrode_data(electrode_count).data);
                    plot(electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data);
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
                        legend('signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                        legend('signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                    else
                        legend('signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point', 'location', 'northeastoutside')

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
                %}
                
                if isempty(well_sum_FPDs_beats)
                    nan_zero_FPDs = FPDs;
                    nan_zero_FPDs(isnan(nan_zero_FPDs)) = 0;
                    count_FPD_electrodes = ~isnan(nan_zero_FPDs);
                    
                    nan_zero_slopes = slopes;
                    nan_zero_slopes(isnan(nan_zero_slopes)) = 0;
                    count_slopes_electrodes = ~isnan(nan_zero_slopes);
                    
                    nan_zero_amps = amps;
                    nan_zero_amps(isnan(nan_zero_amps)) = 0;
                    count_amps_electrodes = ~isnan(nan_zero_amps);
                    
                    nan_zero_bps = beat_periods;
                    nan_zero_bps(isnan(nan_zero_bps)) = 0;
                    count_bps_electrodes = ~isnan(nan_zero_bps);
                    
                    nan_zero_act_times = activation_times;
                    nan_zero_act_times(isnan(nan_zero_act_times)) = 0;
                    count_act_times_electrodes = ~isnan(nan_zero_act_times);
                    
                    nan_zero_act_volts = activation_points;
                    nan_zero_act_volts(isnan(nan_zero_act_volts)) = 0;
                    count_act_volts_electrodes = ~isnan(nan_zero_act_volts);
                    
                    nan_zero_max_depol_times = max_depol_time_array;
                    nan_zero_max_depol_times(isnan(nan_zero_max_depol_times)) = 0;
                    count_max_depol_times_electrodes = ~isnan(nan_zero_max_depol_times);
                    
                    nan_zero_max_depol_volts = max_depol_point_array;
                    nan_zero_max_depol_volts(isnan(nan_zero_max_depol_volts)) = 0;
                    count_max_depol_volts_electrodes = ~isnan(nan_zero_max_depol_volts);
                    
                    nan_zero_min_depol_times = min_depol_time_array;
                    nan_zero_min_depol_times(isnan(nan_zero_min_depol_times)) = 0;
                    count_min_depol_times_electrodes = ~isnan(nan_zero_min_depol_times);
                    
                    nan_zero_min_depol_volts = min_depol_point_array;
                    nan_zero_min_depol_volts(isnan(nan_zero_min_depol_volts)) = 0;
                    count_min_depol_volts_electrodes = ~isnan(nan_zero_min_depol_volts);
                    
                    nan_zero_t_wave_times = t_wave_peak_times;
                    nan_zero_t_wave_times(isnan(nan_zero_t_wave_times)) = 0;
                    count_t_wave_times_electrodes = ~isnan(nan_zero_t_wave_times);
                    
                    nan_zero_t_wave_volts = t_wave_peak_array;
                    nan_zero_t_wave_volts(isnan(nan_zero_t_wave_volts)) = 0;
                    count_t_wave_volts_electrodes = ~isnan(nan_zero_t_wave_volts);
                    
                    nan_zero_cycle_lengths = cycle_length_array;
                    nan_zero_cycle_lengths(isnan(nan_zero_cycle_lengths)) = 0;
                    count_cycle_lengths_electrodes = ~isnan(nan_zero_cycle_lengths);
                    
                    
                    well_sum_FPDs_beats = nan_zero_FPDs;
                    well_sum_slopes_beats = nan_zero_slopes;
                    well_sum_amps_beats = nan_zero_amps;
                    well_sum_bps_beats = nan_zero_bps;
                    
                    well_sum_act_times_beats = nan_zero_act_times;
                    well_sum_act_volts_beats = nan_zero_act_volts;
                    well_sum_max_depol_times_beats = nan_zero_max_depol_times;
                    well_sum_max_depol_volts_beats = nan_zero_max_depol_volts;
                    well_sum_min_depol_times_beats = nan_zero_min_depol_times;
                    well_sum_min_depol_volts_beats = nan_zero_min_depol_volts;
                    well_sum_t_wave_times_beats = nan_zero_t_wave_times;
                    well_sum_t_wave_volts_beats = nan_zero_t_wave_volts;
                    well_sum_cycle_lengths_beats = nan_zero_cycle_lengths;
                    
                else
                    % Set all nan values to zero
                    nan_zero_FPDs = FPDs;
                    nan_zero_FPDs(isnan(nan_zero_FPDs)) = 0;
                    
                    
                    nan_zero_slopes = slopes;
                    nan_zero_slopes(isnan(nan_zero_slopes)) = 0;
                    
                    
                    nan_zero_amps = amps;
                    nan_zero_amps(isnan(nan_zero_amps)) = 0;
                    
                    
                    nan_zero_bps = beat_periods;
                    nan_zero_bps(isnan(nan_zero_bps)) = 0;
                    
                    
                    nan_zero_act_times = activation_times;
                    nan_zero_act_times(isnan(nan_zero_act_times)) = 0;
                    
                    
                    nan_zero_act_volts = activation_points;
                    nan_zero_act_volts(isnan(nan_zero_act_volts)) = 0;
                    
                    
                    nan_zero_max_depol_times = max_depol_time_array;
                    nan_zero_max_depol_times(isnan(nan_zero_max_depol_times)) = 0;
                    
                    
                    nan_zero_max_depol_volts = max_depol_point_array;
                    nan_zero_max_depol_volts(isnan(nan_zero_max_depol_volts)) = 0;
                    
                    
                    nan_zero_min_depol_times = min_depol_time_array;
                    nan_zero_min_depol_times(isnan(nan_zero_min_depol_times)) = 0;
                    
                    
                    nan_zero_min_depol_volts = min_depol_point_array;
                    nan_zero_min_depol_volts(isnan(nan_zero_min_depol_volts)) = 0;
                    
                    
                    nan_zero_t_wave_times = t_wave_peak_times;
                    nan_zero_t_wave_times(isnan(nan_zero_t_wave_times)) = 0;
                    
                    
                    nan_zero_t_wave_volts = t_wave_peak_array;
                    nan_zero_t_wave_volts(isnan(nan_zero_t_wave_volts)) = 0;
                    
                    
                    nan_zero_cycle_lengths = cycle_length_array;
                    nan_zero_cycle_lengths(isnan(nan_zero_cycle_lengths)) = 0;
                    
                    add_FPD_electrodes = ~isnan(nan_zero_FPDs);
                    add_slopes_electrodes = ~isnan(nan_zero_slopes);
                    add_amps_electrodes = ~isnan(nan_zero_amps);
                    add_bps_electrodes = ~isnan(nan_zero_bps);
                    add_act_times_electrodes = ~isnan(nan_zero_act_times);
                    add_act_volts_electrodes = ~isnan(nan_zero_act_volts);
                    add_max_depol_times_electrodes = ~isnan(nan_zero_max_depol_times);
                    add_max_depol_volts_electrodes = ~isnan(nan_zero_max_depol_volts);
                    add_min_depol_times_electrodes = ~isnan(nan_zero_min_depol_times);
                    add_min_depol_volts_electrodes = ~isnan(nan_zero_min_depol_volts);
                    add_t_wave_times_electrodes = ~isnan(nan_zero_t_wave_times);
                    add_t_wave_volts_electrodes = ~isnan(nan_zero_t_wave_volts);
                    add_cycle_lengths_electrodes = ~isnan(nan_zero_cycle_lengths);
                    
                    %Concatenate zero to arrays if some electrodes have additional beats
                    [er, ec] = size(nan_zero_FPDs);
                    [sr, sc] = size(well_sum_FPDs_beats);
                    if er ~= sr
                        if er > sr
                        %Electrode has more beats, need to add zeros to the end of the summation and counts arrays
                            add_extra = er-sr;
                            add_extras_array = zeros(add_extra, 1);

                            well_sum_FPDs_beats = [well_sum_FPDs_beats; add_extras_array];
                            well_sum_slopes_beats = [well_sum_slopes_beats; add_extras_array];
                            well_sum_amps_beats = [well_sum_amps_beats; add_extras_array];
                            well_sum_bps_beats = [well_sum_bps_beats; add_extras_array];
                            well_sum_act_times_beats = [well_sum_act_times_beats; add_extras_array];
                            well_sum_act_volts_beats = [well_sum_act_volts_beats; add_extras_array];
                            well_sum_max_depol_times_beats = [well_sum_max_depol_times_beats; add_extras_array];
                            well_sum_max_depol_volts_beats = [well_sum_max_depol_volts_beats; add_extras_array];
                            well_sum_min_depol_times_beats = [well_sum_min_depol_times_beats; add_extras_array];
                            well_sum_min_depol_volts_beats = [well_sum_min_depol_volts_beats; add_extras_array];
                            well_sum_t_wave_times_beats = [well_sum_t_wave_times_beats; add_extras_array];
                            well_sum_t_wave_volts_beats = [well_sum_t_wave_volts_beats; add_extras_array];
                            well_sum_cycle_lengths_beats = [well_sum_cycle_lengths_beats; add_extras_array];

                            count_FPD_electrodes = [count_FPD_electrodes; add_extras_array];
                            count_slopes_electrodes = [count_slopes_electrodes; add_extras_array];
                            count_amps_electrodes = [count_amps_electrodes; add_extras_array];
                            count_bps_electrodes = [count_bps_electrodes; add_extras_array];
                            count_act_times_electrodes = [count_act_times_electrodes; add_extras_array];
                            count_act_volts_electrodes = [count_act_volts_electrodes; add_extras_array];
                            count_max_depol_times_electrodes = [count_max_depol_times_electrodes; add_extras_array];
                            count_max_depol_volts_electrodes = [count_max_depol_volts_electrodes; add_extras_array];
                            count_min_depol_times_electrodes = [count_min_depol_times_electrodes; add_extras_array];
                            count_min_depol_volts_electrodes = [count_min_depol_volts_electrodes; add_extras_array];
                            count_t_wave_times_electrodes = [count_t_wave_times_electrodes; add_extras_array];
                            count_t_wave_volts_electrodes = [count_t_wave_volts_electrodes; add_extras_array];
                            count_cycle_lengths_electrodes = [count_cycle_lengths_electrodes; add_extras_array];
                        else
                        % Current electrode has less beats than previously saved ones. Need to add zeros to the add arrays and nan_zero_arrays
                            add_extra = sr-er;
                            add_extras_array = zeros(add_extra, 1);
                            
                            nan_zero_FPDs = [nan_zero_FPDs; add_extras_array];
                            nan_zero_slopes = [nan_zero_slopes; add_extras_array];
                            nan_zero_amps = [nan_zero_amps; add_extras_array];
                            nan_zero_bps = [nan_zero_bps; add_extras_array];
                            nan_zero_act_times = [nan_zero_act_times; add_extras_array];
                            nan_zero_act_volts = [nan_zero_act_volts; add_extras_array];
                            nan_zero_max_depol_times = [nan_zero_max_depol_times; add_extras_array];
                            nan_zero_max_depol_volts = [nan_zero_max_depol_volts; add_extras_array];
                            nan_zero_min_depol_times = [nan_zero_min_depol_times; add_extras_array];
                            nan_zero_min_depol_volts = [nan_zero_min_depol_volts; add_extras_array];
                            nan_zero_t_wave_times = [nan_zero_t_wave_times; add_extras_array];
                            nan_zero_t_wave_volts = [nan_zero_t_wave_volts; add_extras_array];
                            nan_zero_cycle_lengths = [nan_zero_cycle_lengths; add_extras_array];

                            add_FPD_electrodes = [add_FPD_electrodes; add_extras_array];
                            add_slopes_electrodes = [add_slopes_electrodes; add_extras_array];
                            add_amps_electrodes = [add_amps_electrodes; add_extras_array];
                            add_bps_electrodes = [add_bps_electrodes; add_extras_array];
                            add_act_times_electrodes = [add_act_times_electrodes; add_extras_array];
                            add_act_volts_electrodes = [add_act_volts_electrodes; add_extras_array];
                            add_max_depol_times_electrodes = [add_max_depol_times_electrodes; add_extras_array];
                            add_max_depol_volts_electrodes = [add_max_depol_volts_electrodes; add_extras_array];
                            add_min_depol_times_electrodes = [add_min_depol_times_electrodes; add_extras_array];
                            add_min_depol_volts_electrodes = [add_min_depol_volts_electrodes; add_extras_array];
                            add_t_wave_times_electrodes = [add_t_wave_times_electrodes; add_extras_array];
                            add_t_wave_volts_electrodes = [add_t_wave_volts_electrodes; add_extras_array];
                            add_cycle_lengths_electrodes = [add_cycle_lengths_electrodes; add_extras_array];
                            
                        end
                        
                    end
                    
                    
                    well_sum_FPDs_beats = well_sum_FPDs_beats+nan_zero_FPDs;
                    well_sum_slopes_beats = well_sum_slopes_beats+nan_zero_slopes;
                    well_sum_amps_beats = well_sum_amps_beats+nan_zero_amps;
                    well_sum_bps_beats = well_sum_bps_beats+nan_zero_bps;
                    well_sum_act_times_beats = well_sum_act_times_beats+nan_zero_act_times;
                    well_sum_act_volts_beats = well_sum_act_volts_beats+nan_zero_act_volts;
                    well_sum_max_depol_times_beats = well_sum_max_depol_times_beats+nan_zero_max_depol_times;
                    well_sum_max_depol_volts_beats = well_sum_max_depol_volts_beats+nan_zero_max_depol_volts;
                    well_sum_min_depol_times_beats = well_sum_min_depol_times_beats+nan_zero_min_depol_times;
                    well_sum_min_depol_volts_beats = well_sum_min_depol_volts_beats+nan_zero_min_depol_volts;
                    well_sum_t_wave_times_beats = well_sum_t_wave_times_beats+nan_zero_t_wave_times;
                    well_sum_t_wave_volts_beats = well_sum_t_wave_volts_beats+nan_zero_t_wave_volts;
                    well_sum_cycle_lengths_beats = well_sum_cycle_lengths_beats+nan_zero_cycle_lengths;
                    
                    count_FPD_electrodes = count_FPD_electrodes+add_FPD_electrodes;
                    count_slopes_electrodes = count_slopes_electrodes+add_slopes_electrodes;
                    count_amps_electrodes = count_amps_electrodes+add_amps_electrodes;
                    count_bps_electrodes = count_bps_electrodes+add_bps_electrodes;
                    count_act_times_electrodes = count_act_times_electrodes+add_act_times_electrodes;
                    count_act_volts_electrodes = count_act_volts_electrodes+add_act_volts_electrodes;
                    count_max_depol_times_electrodes = count_max_depol_times_electrodes+add_max_depol_times_electrodes;
                    count_max_depol_volts_electrodes = count_max_depol_volts_electrodes+add_max_depol_volts_electrodes;
                    count_min_depol_times_electrodes = count_min_depol_times_electrodes+add_min_depol_times_electrodes;
                    count_min_depol_volts_electrodes = count_min_depol_volts_electrodes+add_min_depol_volts_electrodes;
                    count_t_wave_times_electrodes = count_t_wave_times_electrodes+add_t_wave_times_electrodes;
                    count_t_wave_volts_electrodes = count_t_wave_volts_electrodes+add_t_wave_volts_electrodes;
                    count_cycle_lengths_electrodes = count_cycle_lengths_electrodes+add_cycle_lengths_electrodes;
                end
            end
        end
        
        
        well_mean_FPDs_beats = well_sum_FPDs_beats./count_FPD_electrodes;
        well_mean_slopes_beats = well_sum_slopes_beats./count_slopes_electrodes;
        well_mean_amps_beats = well_sum_amps_beats./count_amps_electrodes;
        well_mean_bps_beats = well_sum_bps_beats./count_bps_electrodes;
        well_mean_act_times_beats = well_sum_act_times_beats./count_act_times_electrodes;
        well_mean_act_volts_beats = well_sum_act_volts_beats./count_act_volts_electrodes;
        well_mean_max_depol_times_beats = well_sum_max_depol_times_beats./count_max_depol_times_electrodes;
        well_mean_max_depol_volts_beats = well_sum_max_depol_volts_beats./count_max_depol_volts_electrodes;
        well_mean_min_depol_times_beats = well_sum_min_depol_times_beats./count_min_depol_times_electrodes;
        well_mean_min_depol_volts_beats = well_sum_min_depol_volts_beats./count_min_depol_volts_electrodes;
        well_mean_t_wave_times_beats = well_sum_t_wave_times_beats./count_t_wave_times_electrodes;
        well_mean_t_wave_volts_beats = well_sum_t_wave_volts_beats./count_t_wave_volts_electrodes;
        well_mean_cycle_lengths_beats = well_sum_cycle_lengths_beats./count_cycle_lengths_electrodes;
        
       
        
        well_stats_table = table('Size', [length(well_mean_act_times_beats) 14], 'VariableTypes',["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double","double"], 'VariableNames', cellstr(["Average stats for each beat across well",  "Ave Activation Time (s)", "Ave Activation Time Volts (V)", "Ave Min. Depol Time (s)", "Ave Min. Depol Point (V)", "Ave Max. Depol Time (s)", "Ave Max. Depol Point (V)", "Ave Depolarisation Spike Amplitude (V)", "Ave Depolarisation slope (dv/dt)", "Ave T-wave peak Time (s)", "Ave T-wave peak (V)", "Ave FPD (s)", "Ave Beat Period (s)", "Ave Cycle Length (s)"]));

        if ~isempty(well_mean_act_times_beats)
            well_stats_table(:, 2) = num2cell(well_mean_act_times_beats);

            well_stats_table(:, 3) = num2cell(well_mean_act_volts_beats);

            well_stats_table(:, 4) = num2cell(well_mean_min_depol_times_beats);

            well_stats_table(:, 5) = num2cell(well_mean_min_depol_volts_beats);

            well_stats_table(:, 6) = num2cell(well_mean_max_depol_times_beats);

            well_stats_table(:, 7) = num2cell(well_mean_max_depol_volts_beats);

            well_stats_table(:, 8) = num2cell(well_mean_amps_beats);

            well_stats_table(:, 9) = num2cell(well_mean_slopes_beats);

            well_stats_table(:, 10) = num2cell(well_mean_t_wave_times_beats);

            well_stats_table(:, 11) = num2cell(well_mean_t_wave_volts_beats);

            well_stats_table(:, 12) = num2cell(well_mean_FPDs_beats);

            well_stats_table(:, 13) = num2cell(well_mean_bps_beats);

            well_stats_table(:, 14) = num2cell(well_mean_cycle_lengths_beats);

            
        end

        
        
        
        fileattrib(output_filename, '-h +w');

        %writecell(electrode_stats, output_filename, 'Sheet', sheet_count);
        writetable(well_stats_table, output_filename, 'Sheet', 2);
        %fileattrib(output_filename, '+h +w');
        
        
        well_FPDs = well_FPDs(~isnan(well_FPDs));
        well_slopes = well_slopes(~isnan(well_slopes));
        well_amps = well_amps(~isnan(well_amps));
        well_bps = well_bps(~isnan(well_bps));
        
        mean_FPD = mean(well_FPDs);
        mean_slope = mean(well_slopes);
        mean_amp = mean(well_amps);
        mean_bp = mean(well_bps);
        
        
        
        mean_num_arrhythmias = sum_arrhythmic_event/count_arrhthmic_average_electrode;
        
        if strcmp(well_electrode_data(well_count).spon_paced, 'spon')
            FPDc_fridericia = mean_FPD/((mean_bp)^(1/3));
            FPDc_bazzet = mean_FPD/((mean_bp)^(1/2));
            
            headings = {strcat(well_ID, ': Well-wide statistics'); 'max start activation time (s)'; 'max start activation time electrode id';'min start activation time (s)'; 'min start activation time electrode id'; 'mean FPD (s)'; 'FPDc Fridericia (s)'; 'FPDc Bazzet (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Conduction Velocity (dum/dt)'; 'Average num of Arrhythmic beats per electrode'};

            mean_data1 = [max_act_time]; 
            mean_data2 = [mean_FPD; FPDc_fridericia; FPDc_bazzet; mean_slope; mean_amp; mean_bp; well_electrode_data(well_count).conduction_velocity; mean_num_arrhythmias];
            mean_data1 = num2cell(mean_data1);
            mean_data2 = num2cell(mean_data2);
            mean_data = vertcat({''}, {max_act_time}, {max_act_elec_id}, {min_act_time}, {min_act_elec_id}, mean_data2);
        else
        
            headings = {strcat(well_ID, ': Well-wide statistics'); 'max start activation time (s)'; 'max start activation time electrode id';'min start activation time (s)'; 'min start activation time electrode id'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Conduction Velocity (dum/dt)'; 'Average num of Arrhythmic beats per electrode'};

            mean_data1 = [max_act_time]; 
            mean_data2 = [mean_FPD; mean_slope; mean_amp; mean_bp; well_electrode_data(well_count).conduction_velocity; mean_num_arrhythmias];
            mean_data1 = num2cell(mean_data1);
            mean_data2 = num2cell(mean_data2);
            mean_data = vertcat({''}, {max_act_time}, {max_act_elec_id}, {min_act_time}, {min_act_elec_id}, mean_data2);
        end
        
        well_stats = horzcat(headings, mean_data);
        %max_act_elec_id
        %cell%disp(well_stats);
        well_stats = vertcat(well_stats, average_electrodes);
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
        
        fclose('all');

    end
    

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
                plot(electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data);
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
                    legend('signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                    legend('signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                else
                    legend('signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point', 'location', 'northeastoutside')

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
    

end