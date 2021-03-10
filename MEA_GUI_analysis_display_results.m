function MEA_GUI_analysis_display_results(AllDataRaw, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar)
    %% Save button in each plot to allow users to save plots to directory of choice (start directory)
    %% Close buttons for each pop-up window that doesn't require user interaction
    
    %% b2b = 'on'
    
    %% display GUI with button for each well and when pressed displays plots for each electrode /
    %% heat map button - shows heatmap in new window that can be closed /
    %% display well and electrode statistics like mean FPD etc. 
    %% if bipolar on = bipolar button to show plots and results /
    
    %% b2b = 'off'
    
    %% Golden electrode
    %% 3 uis for each well - show electrode stable waveforms button, show ave waveforms for each elec button, change GE dropdown /
    %% no dropdown nominated = dropdown menu for electrode options for new GE /
    %% Accept GE's button
    %% Enter T-wave peak times for all wells and continue button appears along with statistics
    %% Display statistics and GE for each well
    %% heatmap buttons and bipolar buttons on the well panels in this GUI
    
    %% Electrode time region ave waveforms
    %% buttons for each well /
    %% well button pressed display all electrodes and t-wave peak time uitexts
    %% Continue button and statistics appear when all entered. 
    %% heatmap and bipolar buttons available when each well clicked and shows electrodes ave waveforms
    
    %% ISSUES
    % reformat b2b electrodes so correct
    % update electrode_data for heat map code
    
       
    shape_data = size(AllDataRaw);
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);

    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3)
    screen_height = screen_size(4)
    
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
    
    
    button_panel_width = screen_width-200
    
    button_width = button_panel_width/num_button_cols
    button_height = screen_height/num_button_rows
    
    out_fig = uifigure;
    out_fig.Name = 'MEA Results';
    % left bottom width height
    main_p = uipanel(out_fig, 'Position', [0 0 screen_width screen_height]);
    close_all_button = uibutton(main_p,'push','Text', 'Close', 'Position', [screen_width-180 100 120 50], 'ButtonPushedFcn', @(close_all_button,event) closeAllButtonPushed(close_all_button, out_fig));
         
    
    main_pan = uipanel(main_p, 'Position', [0 0 button_panel_width screen_height]);
    
    %global electrode_data;
    if num_button_rows > 1
        button_count = 1;
        stop_add = 0;
        for r = 1:num_button_rows
           for c = 1: num_button_cols
               if button_count > num_wells
                   stop_add = 1;
                   break;
               end
               wellID = added_wells(button_count)
               button_panel = uipanel(main_pan, 'Position', [((c-1)*button_width) ((r-1)*button_height) button_width button_height]);
               
               
               if strcmp(beat_to_beat, 'off')
                   if strcmp(stable_ave_analysis, 'stable')
                        electrode_options = [];
                        for e_r = 1:num_electrode_rows
                           for e_c = 1:num_electrode_cols
                               electrode_id = strcat(wellID, {' '}, num2str(e_r),'_',num2str(e_c));
                               electrode_options = [electrode_options; electrode_id];
                           end
                        end
                        celldisp(electrode_options)
                        
                        stable_button = uibutton(button_panel,'push','Text', strcat(wellID, {' '}, 'Show Electrode Stable Waveforms'), 'Position', [0 0 button_width/3 button_height/3], 'ButtonPushedFcn', @(stable_button,event) stableElectrodesButtonPushed(stable_button, added_wells, well_electrode_data(button_count, :)));
                        average_button = uibutton(button_panel,'push','Text', strcat(wellID, {' '}, 'Show Electrode Average Waveforms'), 'Position', [button_width/3 0 button_width/3 button_height/3], 'ButtonPushedFcn', @(average_button,event) averageElectrodesButtonPushed(average_button, added_wells, well_electrode_data(button_count, :)));
                        
                        change_GE_text = uieditfield(button_panel,'Text','Position',[2*(button_width/3) (button_height/3)/2 button_width/3 (button_height/3)/2], 'Value',strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Editable','off');
                    
                        change_GE_dropdown = uidropdown(button_panel, 'Items', electrode_options,'Position',[2*(button_width/3) 0 button_width/3 (button_height/3)/2]);
                        set(change_GE_text, 'Visible', 'off');
                        set(change_GE_dropdown, 'Visible', 'off');

                        change_GE_button = uibutton(button_panel,'push','Text', strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Position', [2*(button_width/3) 0 button_width/3 button_height/3], 'ButtonPushedFcn', @(change_GE_button,event) changeGEButtonPushed(change_GE_button, added_wells, change_GE_text, change_GE_dropdown));

                        %{
                        change_GE_text = uieditfield(button_panel,'Text','Position',[2*(button_width/3) (button_height/3)/2 button_width/3 (button_height/3)/2], 'Value',strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Editable','off');
                        change_GE_dropdown = uidropdown(button_panel, 'Items', electrode_options,'Position',[2*(button_width/3) 0 button_width/3 (button_height/3)/2]);
                        %change_GE_dropdown.ItemsData = [1 2];
                        %}
                   else
                        %global electrode_data;
                        well_button = uibutton(button_panel,'push','Text', wellID, 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, well_electrode_data(button_count, :), num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));
                   
                   end
               else
                   %global electrode_data;
                   well_button = uibutton(button_panel,'push','Text', wellID, 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, well_electrode_data(button_count, :), num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));
               
               end
               button_count = button_count + 1;
           end
           if stop_add == 1
               break;
           end
        end
    else
        for b = 1:num_wells
            wellID = added_wells(b)
            button_panel = uipanel(main_pan, 'Position', [((b-1)*button_width) 0 button_width button_height]);
                
            if strcmp(beat_to_beat, 'off')
               if strcmp(stable_ave_analysis, 'stable')
                    electrode_options = [];
                    for e_r = 1:num_electrode_rows
                       for e_c = 1:num_electrode_cols
                           disp('elec')
                           disp(e_r)
                           disp(e_c)
                           electrode_id = strcat(wellID, {' '}, num2str(e_r),'_',num2str(e_c));
                           electrode_options = [electrode_options; electrode_id];
                       end
                    end
                    disp(electrode_options)
                    
                    stable_button = uibutton(button_panel,'push','Text', strcat(wellID, {' '}, 'Show Electrode Stable Waveforms'), 'Position', [0 0 button_width/3 button_height/3], 'ButtonPushedFcn', @(stable_button,event) stableElectrodesButtonPushed(stable_button, added_wells, well_electrode_data(b, :)));
                    average_button = uibutton(button_panel,'push','Text', strcat(wellID, {' '}, 'Show Electrode Average Waveforms'), 'Position', [button_width/3 0 button_width/3 button_height/3], 'ButtonPushedFcn', @(average_button,event) averageElectrodesButtonPushed(average_button, added_wells, well_electrode_data(b, :)));
                    
                    change_GE_text = uieditfield(button_panel,'Text','Position',[2*(button_width/3) (button_height/3)/2 button_width/3 (button_height/3)/2], 'Value',strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Editable','off');
                    
                    change_GE_dropdown = uidropdown(button_panel, 'Items', electrode_options,'Position',[2*(button_width/3) 0 button_width/3 (button_height/3)/2]);
                    
                    
                    set(change_GE_text, 'Visible', 'off');
                    set(change_GE_dropdown, 'Visible', 'off');
                    
                    change_GE_button = uibutton(button_panel,'push','Text', strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Position', [2*(button_width/3) 0 button_width/3 button_height/3], 'ButtonPushedFcn', @(change_GE_button,event) changeGEButtonPushed(change_GE_button, added_wells, change_GE_text, change_GE_dropdown));
                    
                    
                    %{
                    change_GE_text = uieditfield(button_panel,'Text','Position',[2*(button_width/3) (button_height/3)/2 button_width/3 (button_height/3)/2], 'Value',strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Editable','off');
                    
                    change_GE_dropdown = uidropdown(button_panel, 'Items', electrode_options,'Position',[2*(button_width/3) 0 button_width/3 (button_height/3)/2]);
                    
                    %change_GE_dropdown.ItemsData = [1 2];
                    %}
               else
                    well_button = uibutton(button_panel,'push','Text', wellID, 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, well_electrode_data(b, :), num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));

               end
            else

                well_button = uibutton(button_panel,'push','Text', wellID, 'Position', [0 0 button_width button_height], 'ButtonPushedFcn', @(well_button,event) wellButtonPushed(well_button, added_wells, well_electrode_data(b, :), num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig));
            end
        end
    end
  
    %{
    for wells = 1:length(added_wells)
        
    end
    %}
    %{
    
    shape_data = size(AllDataRaw);
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);

    well_count = 0;
    well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    
    disp(well_electrode_data)
    disp(size(well_electrode_data))
    for w_r = 1:num_well_rows
        for w_c = 1:num_well_cols
            
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            if ~contains(added_wells, 'all')
                if ~contains(added_wells, wellID)
                    continue;
                end
            end
            
            well_count = well_count + 1;
            electrode_count = 0;
           
            for e_r = num_electrode_rows:-1:1
                for e_c = 1:num_electrode_cols
                    WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                    if strcmp(class(WellRawData),'Waveform')
                        [time, data] = WellRawData.GetTimeVoltageVector;
                        electrode_count = electrode_count+1;
                        electrode_id = strcat(wellID, {'_'}, string(e_c), {'_'}, string(e_r));
                        
                        electrode_data = well_electrode_data(well_count, electrode_count);
                        disp(strcat(num2str(well_count), '_', num2str(electrode_count)));
                        disp(electrode_data.activation_times)
                    end
                end
            end
            
       
        end
    end
    %}
    
    function wellButtonPushed(well_button, added_wells, electrode_data, num_electrode_rows, num_electrode_cols, beat_to_beat, stable_ave_analysis, bipolar, spon_paced, out_fig)
        set(out_fig, 'Visible', 'off')
        well_ID = get(well_button, 'Text');
        disp(well_ID)
        disp(contains(added_wells, well_ID))
        
        
        
        %electrode_data = electrod_e_data;
        disp(size(electrode_data))
        
        well_elec_fig = uifigure;
        well_elec_fig.Name = strcat(well_ID, '_', 'Electrode Results');
        % left bottom width height
        main_well_pan = uipanel(well_elec_fig, 'Position', [0 0 screen_width screen_height]);
        
        well_p_width = screen_width-300;
        well_pan = uipanel(main_well_pan, 'Position', [0 0 well_p_width screen_height]);
        
        if strcmp(bipolar, 'on')
            bipolar_button = uibutton(main_well_pan,'push','Text', strcat(well_ID, {' '}, 'Show Bipolar Electrogam Results'), 'Position', [screen_width-220 300 180 50], 'ButtonPushedFcn', @(bipolar_button,event) bipolarButtonPushed(bipolar_button, well_ID, num_electrode_rows, num_electrode_cols));
          
        end
        
        heat_map_button = uibutton(main_well_pan,'push','Text', strcat(well_ID, {' '}, 'Show Heat Map'), 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(heat_map_button,event) heatMapButtonPushed(heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced));
         
        close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed(close_button, well_elec_fig, out_fig));
        
        reanalyse_button = uibutton(main_well_pan,'push','Text', 'Re-analyse well', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
        electrode_count = 0;
        for elec_r = num_electrode_rows:-1:1
            for elec_c = 1:num_electrode_cols
                electrode_count = electrode_count+1;
                if strcmp(beat_to_beat, 'on')
                    %plot all the electrodes analysed data and 
                    % left bottom width height
                    disp(electrode_data(electrode_count).electrode_id)
                    elec_pan = uipanel(well_pan, 'Title', electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(screen_height/num_electrode_rows) well_p_width/num_electrode_cols screen_height/num_electrode_rows]);
                    
                    elec_ax = uiaxes(elec_pan, 'Position', [0 0 (well_p_width/num_electrode_cols)-25 (screen_height/num_electrode_rows)-20]);
                    
                    hold(elec_ax,'on')
                    plot(elec_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);
                    plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                    plot(elec_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'ro');
                    plot(elec_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'bo');
                    plot(elec_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'go');
                    
                    if strcmp(spon_paced, 'paced')
                        %stim_indx = find(electrode_data(electrode_count).time == electrode_data(electrode_count).Stims)
                        [in, stim_indx, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
                        %disp(in)
                        %disp(electrode_data(electrode_count).Stims)
                        Stim_points = electrode_data(electrode_count).data(stim_indx);
                        %disp(length(Stim_points))
                        %disp(length(electrode_data(electrode_count).Stims))
                        %Stim_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).time == electrode_data(electrode_count).Stims));
                        
                        plot(elec_ax, electrode_data(electrode_count).beat_start_times, Stim_points, 'ko');
                    end
                    %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                    plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                    hold(elec_ax,'off')
                else
                    if strcmp(stable_ave_analysis, 'time_region')                        
                        elec_pan = uipanel(well_pan, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(screen_height/num_electrode_rows) well_p_width/num_electrode_cols screen_height/num_electrode_rows]);
                    
                        elec_ax = uiaxes(elec_pan, 'Position', [0 0 (well_p_width/num_electrode_cols)-25 (screen_height/num_electrode_rows)-20]);
                        hold(elec_ax,'on')
                        plot(elec_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);
                        plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                        plot(elec_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'ro');
                        plot(elec_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'bo');
                        plot(elec_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'go');

                        %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                        plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                        hold(elec_ax,'off')
                    end
                end
            end
        end
        
        function reanalyseButtonPushed(reanalyse_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
            set(well_elec_fig, 'Visible', 'off')

            reanalyse_fig = uifigure;
            reanalyse_pan = uipanel(reanalyse_fig, 'Position', [0 0 screen_width screen_height]);
            submit_reanalyse_button = uibutton(reanalyse_pan, 'push','Text', 'Submit Electrodes', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(submit_reanalyse_button,event) submitReanalyseButtonPushed(submit_reanalyse_button, well_elec_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));

            reanalyse_width = screen_width-300;
            ra_pan = uipanel(reanalyse_pan, 'Position', [0 0 reanalyse_width screen_height]);

            elec_count = 0;

            reanalyse_electrodes = [];
            for el_r = num_electrode_rows:-1:1
                for el_c = 1:num_electrode_cols
                    elec_count = elec_count+1;
                        ra_elec_pan = uipanel(ra_pan, 'Title', electrode_data(elec_count).electrode_id, 'Position', [(el_c-1)*(reanalyse_width/num_electrode_cols) (el_r-1)*(screen_height/num_electrode_rows) reanalyse_width/num_electrode_cols screen_height/num_electrode_rows]);
                        ra_elec_button = uibutton(ra_elec_pan, 'push','Text', 'Reanalyse', 'Position', [0 0 reanalyse_width/num_electrode_cols screen_height/num_electrode_rows], 'ButtonPushedFcn', @(ra_elec_button,event) reanalyseElectrodeButtonPushed(ra_elec_button, electrode_data(elec_count).electrode_id));


                end
            end

            function reanalyseElectrodeButtonPushed(ra_elec_button, electrode_id)
                set(ra_elec_button, 'Visible', 'off');
                reanalyse_electrodes = [reanalyse_electrodes; electrode_id];
            end

            function submitReanalyseButtonPushed(submit_reanalyse_button, well_elec_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
                set(reanalyse_fig, 'Visible', 'off')
                [electrode_data, re_count] = electrode_analysis(electrode_data, num_electrode_rows, num_electrode_cols, reanalyse_electrodes, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis);
                disp(electrode_data(re_count).activation_times(2))
            end

        end

        function heatMapButtonPushed(heat_map_button, well_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced)
            disp('conduction maps');
            disp(well_ID)
            %set(well_elec_fig, 'Visible', 'off')
            start_activation_times = [];
            %disp(size(electrode_data))
            for e = 1:num_electrode_rows*num_electrode_cols
                %disp(e);
                elec_data = electrode_data(1,e);
                act_times = elec_data.activation_times;
                start_activation_times = [start_activation_times; act_times(2)];
            end
            disp(start_activation_times);
            conduction_map_GUI(start_activation_times, num_electrode_rows, num_electrode_cols, spon_paced, well_elec_fig)

        end

        function bipolarButtonPushed(bipolar_button, well_ID, num_electrode_rows, num_electrode_cols)
            disp('bipolar')
            disp(well_ID)
            calculate_bipolar_electrograms_GUI(electrode_data, num_electrode_rows, num_electrode_cols)

        end

        function closeButtonPushed(close_button, well_elec_fig, out_fig)
            set(well_elec_fig, 'Visible', 'off');

            set(out_fig, 'Visible', 'on');
        end

    end


    function  closeAllButtonPushed(close_all_button, out_fig)
        set(out_fig, 'Visible', 'off');
    end

    function stableElectrodesButtonPushed(stable_button, added_wells)
        well_ID = get(stable_button, 'Text');
        well_ID = regexp(well_ID, ' ', 'split');
        well_ID = well_ID{1};
        %disp(well_ID)
        %disp(contains(added_wells, well_ID))
    end

    function averageElectrodesButtonPushed(average_button, added_wells)
        well_ID = get(average_button, 'Text');
        well_ID = regexp(well_ID, ' ', 'split');
        well_ID = well_ID{1};
        %disp(well_ID)
        %disp(contains(added_wells, well_ID))
    end

    function changeGEButtonPushed(change_GE_button, added_wells, change_GE_text, change_GE_dropdown)
        well_ID = get(change_GE_button, 'Text');
        well_ID = regexp(well_ID, ' ', 'split');
        well_ID = well_ID{2};
        %disp(well_ID)
        %disp(contains(added_wells, well_ID))
        
        set(change_GE_button, 'Visible', 'off');
        set(change_GE_text, 'Visible', 'on');
        set(change_GE_dropdown, 'Visible', 'on');
        
    end

    

end