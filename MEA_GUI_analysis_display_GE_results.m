function MEA_GUI_analysis_display_GE_results(AllDataRaw, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar, save_dir)
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
       
    %added_wells = sort(added_wells)
    shape_data = size(AllDataRaw);
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);

    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    
    screen_width = 1700;
    screen_height = 956;
    
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
    button_height = (screen_height)/num_button_rows;
    
    out_fig = uifigure;
    out_fig.Name = 'MEA Results';
    movegui(out_fig,'center')
    %out_fig.WindowState = 'maximized';
    out_fig.Position = [100, 100, screen_width, screen_height];
    % left bottom width height
    main_p = uipanel(out_fig, 'BackgroundColor', '#e68e8e', 'Position', [0 0 screen_width screen_height]);
    
    close_all_button = uibutton(main_p,'push', 'BackgroundColor', '#B02727', 'Fontcolor', 'w', 'Text', 'Close', 'Position', [screen_width-160 100 120 50], 'ButtonPushedFcn', @(close_all_button,event) closeAllButtonPushed(close_all_button, out_fig));
    accept_GE_button = uibutton(main_p,'push', 'BackgroundColor', '#3dd4d1', 'Fontcolor', 'w', 'Text', 'Accept Golden Electrodes', 'Position', [screen_width-190 200 180 50], 'ButtonPushedFcn', @(accept_GE_button,event) acceptGEButtonPushed(accept_GE_button, out_fig));
            
    
    
    main_pan = uipanel(main_p, 'Title', 'Review Well Results', 'Position', [0 0 button_panel_width screen_height]);
    
    %global electrode_data;
    dropdown_array = [];
    change_GE_text_array = [];
    change_GE_dropdown_array = [];
    change_GE_button_array = [];
    stable_button_array = [];
    average_button_array = [];
    
    panel_array = GePanels.empty(num_wells, 0);
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
               

                if well_electrode_data(button_count).rejected_well == 1
                    continue
                end
                electrode_options = [];
                %for e_r = 1:num_electrode_rows
                el_count = 0;
                for e_r = num_electrode_rows:-1:1
                   for e_c = 1:num_electrode_cols
                       %electrode_id = strcat(wellID, '_', num2str(e_r),'_',num2str(e_c));
                       el_count = el_count+1;
                       %if (well_electrode_data(button_count, el_count).electrode_id == "")
                       if (well_electrode_data(button_count).electrode_data(el_count).electrode_id == "")
                           continue
                       end
                       electrode_id = strcat(wellID, '_', num2str(e_c),'_',num2str(e_r));
                       electrode_options = [electrode_options; electrode_id];
                   end
                end
                %cell%disp(electrode_options)


                change_GE_text = uieditfield(button_panel,'Text', 'BackgroundColor', '#e37f7f', 'Position',[2*(button_width/3) (button_height)/2 button_width/6 (button_height)/2], 'Value',"Change" + " " + wellID + " " + "Golden Electrode", 'Editable','off');

                change_GE_dropdown = uidropdown(button_panel, 'BackgroundColor', '#e37f7f', 'Items', electrode_options,'Position',[2*(button_width/3) 0 button_width/6 (button_height)/2]);
                set(change_GE_text, 'Visible', 'off');
                set(change_GE_dropdown, 'Visible', 'off');

                dropdown_array = [dropdown_array; change_GE_dropdown];

                change_GE_button = uibutton(button_panel,'push','BackgroundColor', '#e37f7f', 'Text', "Change" + " " + wellID + " " + "Golden Electrode", 'Position', [2*(button_width/3) 0 button_width/3 button_height], 'ButtonPushedFcn', @(change_GE_button,event) changeGEButtonPushed(change_GE_button, added_wells, change_GE_text, change_GE_dropdown, button_panel));

                %stable_button = uibutton(button_panel,'push','BackgroundColor', '#B02727', 'Text', strcat(wellID, {' '}, 'Show Electrode Stable Waveforms'), 'Position', [0 0 button_width/3 button_height], 'ButtonPushedFcn', @(stable_button,event) stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(button_count, :), change_GE_dropdown));
                %average_button = uibutton(button_panel,'push','BackgroundColor', '#d43d3d', 'Text', strcat(wellID, {' '}, 'Show Electrode Average Waveforms'), 'Position', [button_width/3 0 button_width/3 button_height], 'ButtonPushedFcn', @(average_button,event) averageElectrodesButtonPushed(average_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(button_count, :), change_GE_dropdown));
                stable_button = uibutton(button_panel,'push','BackgroundColor', '#B02727', 'Text', strcat(wellID, {' '}, 'Show Electrode Stable Waveforms'), 'Position', [0 0 button_width/3 button_height], 'ButtonPushedFcn', @(stable_button,event) stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(button_count).electrode_data, change_GE_dropdown, button_count));
                average_button = uibutton(button_panel,'push','BackgroundColor', '#d43d3d', 'Text', strcat(wellID, {' '}, 'Show Electrode Average Waveforms'), 'Position', [button_width/3 0 button_width/3 button_height], 'ButtonPushedFcn', @(average_button,event) averageElectrodesButtonPushed(average_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(button_count).electrode_data, change_GE_dropdown, button_count));

                %{
                change_GE_text_array = [change_GE_text_array; ];
                %change_GE_dropdown_array = [];
                change_GE_button_array = [change_GE_button_array; ];
                stable_button_array = [];
                average_button_array = [];
                %}
                panel_array(button_count).panel = button_panel;
                button_count = button_count + 1;
           end
           if stop_add == 1
               break;
           end
        end
    else
        for b = 1:num_wells
            wellID = added_wells(b);
            button_panel = uipanel(main_pan, 'BackgroundColor', '#d43d3d', 'Position', [((b-1)*button_width) 0 button_width button_height]);

            if well_electrode_data(b).rejected_well == 1
                continue
            end
            electrode_options = [];
            %for e_r = 1:num_electrode_rows
            el_count = 0;
            for e_r = num_electrode_rows:-1:1
               for e_c = 1:num_electrode_cols
                   %%disp('elec')
                   %%disp(e_r)
                   %%disp(e_c)
                   el_count = el_count+1;
                   %if (well_electrode_data(b, el_count).electrode_id == "")
                   if (well_electrode_data(b).electrode_data(el_count).electrode_id == "")
                       continue
                   end
                   %Computer way of labelling - row, column
                   %electrode_id = strcat(wellID, '_', num2str(e_r),'_',num2str(e_c));
                   electrode_id = strcat(wellID, '_', num2str(e_c),'_',num2str(e_r));


                   electrode_options = [electrode_options; electrode_id];
               end
            end
            %%disp(electrode_options)


            change_GE_text = uieditfield(button_panel,'Text', 'BackgroundColor', '#e37f7f', 'Position',[2*(button_width/3) (button_height)/2 button_width/6 (button_height)/2], 'Value',strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Editable','off');

            change_GE_dropdown = uidropdown(button_panel, 'BackgroundColor', '#e37f7f', 'Items', electrode_options,'Position',[2*(button_width/3) 0 button_width/6 (button_height)/2]);


            set(change_GE_text, 'Visible', 'off');
            set(change_GE_dropdown, 'Visible', 'off');

            dropdown_array = [dropdown_array; change_GE_dropdown];

            change_GE_button = uibutton(button_panel,'push','BackgroundColor', '#e37f7f', 'Fontcolor', 'w', 'Text', strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Position', [2*(button_width/3) 0 button_width/3 button_height], 'ButtonPushedFcn', @(change_GE_button,event) changeGEButtonPushed(change_GE_button, added_wells, change_GE_text, change_GE_dropdown, button_panel));

            %stable_button = uibutton(button_panel,'push','BackgroundColor', '#B02727', 'Text', strcat(wellID, {' '}, 'Show Electrode Stable Waveforms'), 'Position', [0 0 button_width/3 button_height], 'ButtonPushedFcn', @(stable_button,event) stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(b, :), change_GE_dropdown));
            %average_button = uibutton(button_panel,'push','BackgroundColor', '#d43d3d', 'Text', strcat(wellID, {' '}, 'Show Electrode Average Waveforms'), 'Position', [button_width/3 0 button_width/3 button_height], 'ButtonPushedFcn', @(average_button,event) averageElectrodesButtonPushed(average_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(b, :), change_GE_dropdown));
            stable_button = uibutton(button_panel,'push','BackgroundColor', '#B02727', 'Fontcolor', 'w', 'Text', strcat(wellID, {' '}, 'Show Electrode Stable Waveforms'), 'Position', [0 0 button_width/3 button_height], 'ButtonPushedFcn', @(stable_button,event) stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(b).electrode_data, change_GE_dropdown, b));
            average_button = uibutton(button_panel,'push','BackgroundColor', '#d43d3d', 'Fontcolor', 'w', 'Text', strcat(wellID, {' '}, 'Show Electrode Average Waveforms'), 'Position', [button_width/3 0 button_width/3 button_height], 'ButtonPushedFcn', @(average_button,event) averageElectrodesButtonPushed(average_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(b).electrode_data, change_GE_dropdown, b));
            panel_array(b).panel = button_panel;

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
        close all hidden;
        close all;
        clear;
    end

    function stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, electrode_data, change_GE_dropdown, well_count)
        well_ID = get(stable_button, 'Text');
        well_ID = regexp(well_ID, ' ', 'split');
        well_ID = well_ID{1};
        
        electrode_data = well_electrode_data(well_count).electrode_data;
        
        well_elec_fig = uifigure;
        movegui(well_elec_fig,'center')
        %well_elec_fig.WindowState = 'maximized';
        well_elec_fig.Position = [100, 100, screen_width, screen_height];
        well_elec_fig.Name = strcat(well_ID, '_', 'Stable_Waveforms');
        % left bottom width height
        main_well_pan = uipanel(well_elec_fig, 'BackgroundColor', '#fbeaea', 'Position', [0 0 screen_width screen_height]);
        
        well_p_width = screen_width-300;
        well_p_height = screen_height -100;
        well_pan = uipanel(main_well_pan, 'Position', [0 0 well_p_width well_p_height]);
        
        if strcmp(get(change_GE_dropdown, 'Visible'), 'on')
            new_ge = get(change_GE_dropdown, 'Value');
            min_stdevs = contains([electrode_data(:).electrode_id], new_ge);
            min_electrode_beat_stdev_indx = find(min_stdevs == 1);
        else
            min_stdevs = [electrode_data(:).min_stdev];
            non_zero_stddevs = find(min_stdevs ~=0);
            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
        end
        GE_pan = uipanel(main_well_pan, 'Title', "Golden Electrode" + " " +electrode_data(min_electrode_beat_stdev_indx).electrode_id,  'BackgroundColor', '#f2c2c2', 'Position', [well_p_width screen_height-450 300 320]); 
        GE_ax = uiaxes(GE_pan, 'Position', [0 0 300 300]);
        
        MEA_GUI_display_GE_stable_waveform(GE_ax, electrode_data(min_electrode_beat_stdev_indx))
        %{
        hold(GE_ax, 'on')
        window = electrode_data(min_electrode_beat_stdev_indx).window;
        for k = 1:window
           plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).stable_times{k, 1}, electrode_data(min_electrode_beat_stdev_indx).stable_waveforms{k, 1});
           stable_time = electrode_data(min_electrode_beat_stdev_indx).stable_times{k, 1};
           stable_act_time_indx = find(electrode_data(min_electrode_beat_stdev_indx).activation_times >= stable_time(1));
           stable_act_time_indx = stable_act_time_indx(1);

           plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).activation_times(stable_act_time_indx), electrode_data(min_electrode_beat_stdev_indx).activation_point_array(stable_act_time_indx), 'k.', 'MarkerSize', 20)
        end
        hold(GE_ax, 'off');
        %}
        
        reanalyse_well_button = uibutton(main_well_pan,'push','Text', 'Re-analyse All Background Traces', 'Position', [screen_width-275 120 250 50], 'ButtonPushedFcn', @(reanalyse_well_button,event) reanalyseWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, GE_ax, GE_pan, change_GE_dropdown));
        
        
        close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeStableGUIsPushed(close_button, well_elec_fig, out_fig));
        
        
        
        electrode_count = 0;
        elec_ids = [electrode_data(:).electrode_id];
        for elec_r = num_electrode_rows:-1:1
            for elec_c = 1:num_electrode_cols
                %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                electrode_count = elec_indx;
                %electrode_count = electrode_count+1;
                if ~isempty(electrode_data(electrode_count))
                    elec_pan = uipanel(well_pan,  'BackgroundColor', '#f2c2c2', 'Title', electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);
                    elec_ax = uiaxes(elec_pan, 'Position', [10 20 (well_p_width/num_electrode_cols)-20 (well_p_height/num_electrode_rows)-40]);
                    
                    %{
                    window = electrode_data(electrode_count).window;
                    elec_pan = uipanel(well_pan,  'BackgroundColor', '#f2c2c2', 'Title', electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);

                    elec_ax = uiaxes(elec_pan, 'Position', [10 20 (well_p_width/num_electrode_cols)-20 (well_p_height/num_electrode_rows)-40]);
                    
                    hold(elec_ax, 'on')
                    for k = 1:window
                       plot(elec_ax, electrode_data(electrode_count).stable_times{k, 1}, electrode_data(electrode_count).stable_waveforms{k, 1});
                       stable_time = electrode_data(electrode_count).stable_times{k, 1};
                       stable_act_time_indx = find(electrode_data(electrode_count).activation_times >= stable_time(1));
                       stable_act_time_indx = stable_act_time_indx(1);
                       
                       plot(elec_ax, electrode_data(electrode_count).activation_times(stable_act_time_indx), electrode_data(electrode_count).activation_point_array(stable_act_time_indx), 'k.', 'MarkerSize', 20)
                       
                       
                    end
                    hold(elec_ax, 'off');
                    %}
                    MEA_GUI_display_GE_stable_waveform(elec_ax, electrode_data(electrode_count))
                end
                expand_background_signals_button = uibutton(elec_pan,'push','Text', 'Expand Background Beats', 'BackgroundColor', '#B02727', 'Fontcolor', 'w', 'Position', [0 0 ((well_p_width/num_electrode_cols)-25)/2 20], 'ButtonPushedFcn', @(expand_background_signals_button,event) expandAllTimeRegionDataButtonPushed(expand_background_signals_button, num_electrode_rows, num_electrode_cols, elec_pan, well_count, electrode_count, GE_ax, GE_pan, change_GE_dropdown));
                        
            end
        end
        
        
        function closeStableGUIsPushed(close_button, well_elec_fig, out_fig)
            close(well_elec_fig)
            open_figs = findall(groot,'Type','figure');
            for o = 1:length(open_figs)
                if contains(get(open_figs(o), 'name'), 'Background Beats')
                    close(open_figs(o))
                end
            end
            
            
        end
        
        function reanalyseWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, GE_ax, GE_pan, change_GE_dropdown)
            set(well_elec_fig, 'Visible', 'off')
            %[well_electrode_data(well_count, :)] = reanalyse_b2b_well_analysis(electrode_data, num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID);
            [well_electrode_data(well_count)] = reanalyse_b2b_well_analysis(well_electrode_data(well_count), num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, GE_ax, GE_pan, change_GE_dropdown, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID, ['all']);
            
            %electrode_data = well_electrode_data(well_count).electrode_data;
        end
        
        function expandAllTimeRegionDataButtonPushed(expand_electrode_button, num_electrode_rows, num_electrode_cols, elec_pan, well_count, electrode_count, GE_ax, GE_pan, change_GE_dropdown)
            expand_elec_fig = uifigure;
            expand_elec_fig.Name = 'Background Beats_'+well_electrode_data(well_count).electrode_data(electrode_count).electrode_id;
            movegui(expand_elec_fig,'center')
            expand_elec_fig.WindowState = 'maximized';
            expand_elec_panel = uipanel(expand_elec_fig, 'BackgroundColor', '#fbeaea', 'Position', [0 0 screen_width screen_height]);
                
            expand_elec_p = uipanel(expand_elec_panel, 'BackgroundColor', '#f2c2c2', 'Position', [0 0 well_p_width well_p_height]);

            electrode_data = well_electrode_data(well_count).electrode_data;
            
            %{
            t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
            t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
            t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
            t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
            activation_times = electrode_data(electrode_count).activation_times;
            activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
            elec_FPDs = [t_wave_peak_times - activation_times];
           

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
            
            %}
            
            if strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'spon')
                text_box_height = screen_height/14;
                

            elseif strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced bdt')
                text_box_height = screen_height/15;

            elseif strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced')
                text_box_height = screen_height/12;
                
   
            end
              
            expand_close_button = uibutton(expand_elec_panel,'push','Text', 'Close', 'FontSize', 10,'Position', [screen_width-220 0 120 text_box_height], 'ButtonPushedFcn', @(expand_close_button,event) closeExpandButtonPushed(expand_close_button, expand_elec_fig));

            exp_ax = uiaxes(expand_elec_p, 'Position', [0 50 well_p_width well_p_height-50]);
            
            MEA_GUI_display_GE_background_B2B_analysis(expand_elec_panel, exp_ax, electrode_data, electrode_count)
            
            %{
            hold(exp_ax,'on')
            plot(exp_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);

            
            win = electrode_data(electrode_count).window;

            for ks = 1:win
               plot(exp_ax, electrode_data(electrode_count).stable_times{ks, 1}, electrode_data(electrode_count).stable_waveforms{ks, 1}, 'color','#cc3399');

            end
            
            
            
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
                legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'ectopic beat start', 'paced beat start', 'activation point')
            elseif strcmp(well_electrode_data(well_count).electrode_data(electrode_count).spon_paced, 'paced')
                legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'paced beat start', 'activation point')

            else
                legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point')

            end
            hold(exp_ax,'off')
            %}
            
            reanalyse_background_button = uibutton(expand_elec_panel,'push', 'Text', 'Reanalyse Trace', 'Position', [screen_width-220 text_box_height*2 120 text_box_height], 'ButtonPushedFcn', @(reanalyse_background_button,event) reanalyseElectrodeButtonPushed(well_count, electrode_data(electrode_count).electrode_id, exp_ax, expand_elec_panel, GE_ax, GE_pan, change_GE_dropdown));
               
            
            function closeExpandButtonPushed(expand_close_button, expand_elec_fig)
                
                %set(expand_elec_fig, 'Visible', 'off');
                delete(expand_close_button)
                close(expand_elec_fig)
            end

        end
        
        function reanalyseElectrodeButtonPushed(well_count, elec_id, exp_ax, expand_elec_panel, GE_ax, GE_pan, change_GE_dropdown)
            
            [well_electrode_data(well_count)] = electrode_analysis(well_electrode_data(well_count), num_electrode_rows, num_electrode_cols, elec_id, well_elec_fig, well_pan, exp_ax, expand_elec_panel, GE_ax, GE_pan, change_GE_dropdown, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis);
                
        end
    end

    function averageElectrodesButtonPushed(average_button, added_wells, num_electrode_rows, num_electrode_cols, electrode_data, change_GE_dropdown, well_count)
        well_ID = get(average_button, 'Text');
        well_ID = regexp(well_ID, ' ', 'split');
        well_ID = well_ID{1};
        %%disp(well_ID)
        
        electrode_data = well_electrode_data(well_count).electrode_data;
        well_elec_fig = uifigure;
        movegui(well_elec_fig,'center')
        %well_elec_fig.WindowState = 'maximized';
        well_elec_fig.Position = [100, 100, screen_width, screen_height];
        well_elec_fig.Name = strcat(well_ID, '_', 'Electrode Results');
        % left bottom width height
        main_well_pan = uipanel(well_elec_fig, 'BackgroundColor', '#fbeaea', 'Position', [0 0 screen_width screen_height]);
        
        well_p_width = screen_width-300;
        well_p_height = screen_height -100;
        well_pan = uipanel(main_well_pan, 'Position', [0 0 well_p_width well_p_height]);
        
        
        if strcmp(get(change_GE_dropdown, 'Visible'), 'on')
            new_ge = get(change_GE_dropdown, 'Value');
            min_stdevs = contains([electrode_data(:).electrode_id], new_ge);
            min_electrode_beat_stdev_indx = find(min_stdevs == 1);
        else
            min_stdevs = [electrode_data(:).min_stdev];
            non_zero_stddevs = find(min_stdevs ~=0);
            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
        end
        GE_pan = uipanel(main_well_pan, 'BackgroundColor', '#f2c2c2', 'Title', "Golden Electrode" + " " + electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position', [well_p_width screen_height-450 300 320]);
        
        GE_ax = uiaxes(GE_pan, 'Position', [0 0 300 300]);
        
        
        hold(GE_ax,'on')
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).filtered_ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).filtered_average_waveform);
        %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'r.', 'MarkerSize', 20);
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'b.', 'MarkerSize', 20);
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).ave_activation_point, 'k.', 'MarkerSize', 20);

        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak, 'c.', 'MarkerSize', 20);
        %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
        %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
        hold(GE_ax,'off')
        
        depol_zoom_button = uibutton(main_well_pan,'push','Text', 'Expand Depol. Complexes', 'Position', [screen_width-220 350 150 50], 'ButtonPushedFcn', @(depol_zoom_button,event) depolZoomButtonPushed(depol_zoom_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, GE_ax));
        
        repol_zoom_button = uibutton(main_well_pan,'push','Text', 'Expand Repol. Complexes', 'Position', [screen_width-220 400 150 50], 'ButtonPushedFcn', @(repol_zoom_button,event) repolZoomButtonPushed(repol_zoom_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, GE_ax));
        
        restore_full_beat_button = uibutton(main_well_pan,'push','Text', 'Restore Full Beat', 'Position', [screen_width-220 450 150 50], 'ButtonPushedFcn', @(restore_full_beat_button,event) restoreBeatButtonPushed(restore_full_beat_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, GE_ax));
        set(restore_full_beat_button, 'visible', 'off')
        
        reanalyse_well_button = uibutton(main_well_pan,'push','Text', 'Re-analyse Well', 'Position', [screen_width-220 100 120 50], 'ButtonPushedFcn', @(reanalyse_well_button,event) reanalyseAverageWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, GE_ax, electrode_data(min_electrode_beat_stdev_indx).electrode_id));
        
        
        close_button = uibutton(main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed(close_button, well_elec_fig, out_fig));
        
        electrode_count = 0;
        elec_ids = [electrode_data(:).electrode_id];
        
   
        for elec_r = num_electrode_rows:-1:1
            for elec_c = 1:num_electrode_cols
                %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
                elec_indx = contains(elec_ids, elec_id);
                elec_indx = find(elec_indx == 1);
                electrode_count = elec_indx;
                if ~isempty(electrode_data(electrode_count).average_waveform)
                    
                    elec_pan = uipanel(well_pan, 'BackgroundColor', '#f2c2c2', 'Title', electrode_data(electrode_count).electrode_id, 'Position', [(elec_c-1)*(well_p_width/num_electrode_cols) (elec_r-1)*(well_p_height/num_electrode_rows) well_p_width/num_electrode_cols well_p_height/num_electrode_rows]);

                    reanalyse_electrode_button = uibutton(elec_pan,'push', 'BackgroundColor', '#B02727', 'Fontcolor', 'w', 'Text', 'Reanalyse', 'Position', [0 0 ((well_p_width/num_electrode_cols)-25)/4 20], 'ButtonPushedFcn', @(reanalyse_electrode_button,event) reanalyseAverageElectrodeButtonPushed(well_count, elec_id, GE_ax, electrode_data(min_electrode_beat_stdev_indx).electrode_id));
                    
                    elec_ax = uiaxes(elec_pan, 'Position', [10 20 (well_p_width/num_electrode_cols)-20 (well_p_height/num_electrode_rows)-40]);
                    
                    hold(elec_ax,'on')
                    plot(elec_ax, electrode_data(electrode_count).ave_wave_time, electrode_data(electrode_count).average_waveform);
                    plot(elec_ax, electrode_data(electrode_count).filtered_ave_wave_time, electrode_data(electrode_count).filtered_average_waveform);
                    %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                    plot(elec_ax, electrode_data(electrode_count).ave_max_depol_time, electrode_data(electrode_count).ave_max_depol_point, 'r.', 'MarkerSize', 20);
                    plot(elec_ax, electrode_data(electrode_count).ave_min_depol_time, electrode_data(electrode_count).ave_min_depol_point, 'b.', 'MarkerSize', 20);
                    plot(elec_ax, electrode_data(electrode_count).ave_activation_time, electrode_data(electrode_count).ave_activation_point, 'k.', 'MarkerSize', 20);

                    plot(elec_ax, electrode_data(electrode_count).ave_t_wave_peak_time, electrode_data(electrode_count).ave_t_wave_peak, 'c.', 'MarkerSize', 20);

                    %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                    %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                    hold(elec_ax,'off')
                    
                    
                end
            end
        end
        view_overlaid_button = uibutton(main_well_pan,'push','Text', 'View Overlaid Plots', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(view_overlaid_button,event) viewOverlaidButtonPushed(view_overlaid_button, well_elec_fig, min_electrode_beat_stdev_indx));
        
        
        function reanalyseAverageElectrodeButtonPushed(well_count, elec_id, GE_ax, GE_electrode_id)
            [well_electrode_data(well_count).electrode_data] = electrode_time_region_analysis(well_electrode_data(well_count).electrode_data, num_electrode_rows, num_electrode_cols, elec_id, well_elec_fig, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, GE_ax, GE_electrode_id);
        
        end
        
        function reanalyseAverageWellButtonPushed(reanalyse_well_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, GE_ax, GE_electrode_id)
            set(well_elec_fig, 'Visible', 'off')
            [well_electrode_data(well_count).electrode_data] = reanalyse_time_region_well(well_electrode_data(well_count).electrode_data, num_electrode_rows, num_electrode_cols, well_elec_fig, well_pan, GE_ax, GE_electrode_id, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, well_ID, ['all']);
            
            %electrode_data = well_electrode_data(well_count).electrode_data;
        end
        
        function viewOverlaidButtonPushed(view_overlaid_button, well_elec_fig, ge_indx)
            set(well_elec_fig, 'visible', 'off')
            overlaid_well_elec_fig = uifigure;
            movegui(overlaid_well_elec_fig,'center')
            overlaid_well_elec_fig.WindowState = 'maximized';
            overlaid_well_elec_fig.Name = strcat(well_ID, '_', 'Overlaid Electrode Results');
            % left bottom width height
            overlaid_main_well_pan = uipanel(overlaid_well_elec_fig, 'Position', [0 0 screen_width screen_height]);
            close_overlaid_button = uibutton(overlaid_main_well_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_overlaid_button,event) closeButtonPushed(close_overlaid_button, overlaid_well_elec_fig, well_elec_fig));

            overlaid_well_pan = uipanel(overlaid_main_well_pan, 'Position', [0 0 well_p_width well_p_height]);
            overlaid_ax = uiaxes(overlaid_well_pan, 'Position', [0 0 well_p_width well_p_height]);
            
            electrode_count = 0;
            elec_ids = [electrode_data(:).electrode_id];
            max_act = max([electrode_data(:).ave_activation_time]); 
            hold(overlaid_ax, 'on')
            for elec_r = num_electrode_rows:-1:1
                for elec_c = 1:num_electrode_cols
                    %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                    elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
                    elec_indx = contains(elec_ids, elec_id);
                    elec_indx = find(elec_indx == 1);
                    electrode_count = elec_indx;
                    if ~isempty(electrode_data(electrode_count))

                        if electrode_count == ge_indx
                            %plot_col = '#e9b316';
                            continue
                        else
                            plot_col = 'blue';
                        end
                        p1 = plot(overlaid_ax, electrode_data(electrode_count).ave_wave_time+(max_act-electrode_data(electrode_count).ave_activation_time), electrode_data(electrode_count).average_waveform, 'Color', plot_col, 'LineWidth',1);
                        %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                        plot(overlaid_ax, electrode_data(electrode_count).ave_max_depol_time+(max_act-electrode_data(electrode_count).ave_activation_time), electrode_data(electrode_count).ave_max_depol_point, 'r.', 'MarkerSize', 20);
                        plot(overlaid_ax, electrode_data(electrode_count).ave_min_depol_time+(max_act-electrode_data(electrode_count).ave_activation_time), electrode_data(electrode_count).ave_min_depol_point, 'b.', 'MarkerSize', 20);
                        
                        
                        plot(overlaid_ax, electrode_data(electrode_count).ave_activation_time+(max_act-electrode_data(electrode_count).ave_activation_time), electrode_data(electrode_count).ave_activation_point, 'k.', 'MarkerSize', 20);

                        plot(overlaid_ax, electrode_data(electrode_count).ave_t_wave_peak_time+(max_act-electrode_data(electrode_count).ave_activation_time), electrode_data(electrode_count).ave_t_wave_peak, 'c.', 'MarkerSize', 20);
                    end
                end
            end
            p2 = plot(overlaid_ax, electrode_data(ge_indx).ave_wave_time+(max_act-electrode_data(ge_indx).ave_activation_time), electrode_data(ge_indx).average_waveform, 'Color', '#e9b316', 'LineWidth',3);
            %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
            plot(overlaid_ax, electrode_data(ge_indx).ave_max_depol_time+(max_act-electrode_data(ge_indx).ave_activation_time), electrode_data(ge_indx).ave_max_depol_point, 'r.', 'MarkerSize', 20);
            plot(overlaid_ax, electrode_data(ge_indx).ave_min_depol_time+(max_act-electrode_data(ge_indx).ave_activation_time), electrode_data(ge_indx).ave_min_depol_point, 'b.', 'MarkerSize', 20);


            plot(overlaid_ax, electrode_data(ge_indx).ave_activation_time+(max_act-electrode_data(ge_indx).ave_activation_time), electrode_data(ge_indx).ave_activation_point, 'k.', 'MarkerSize', 20);
            

            plot(overlaid_ax, electrode_data(ge_indx).ave_t_wave_peak_time+(max_act-electrode_data(ge_indx).ave_activation_time), electrode_data(ge_indx).ave_t_wave_peak, 'c.', 'MarkerSize', 20);
            legend(overlaid_ax, [p1, p2], {'Averaged Electrodes', 'Golden Electrode'})
            
            hold(overlaid_ax, 'off')
        end
        
        
        function depolZoomButtonPushed(depol_zoom_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, GE_ax)
            well_panel_children = get(well_pan, 'Children');
            
            if strcmp(get(change_GE_dropdown, 'Visible'), 'on')
                new_ge = get(change_GE_dropdown, 'Value');
                min_stdevs = contains([electrode_data(:).electrode_id], new_ge);
                min_electrode_beat_stdev_indx = find(min_stdevs == 1);
            else
                min_stdevs = [electrode_data(:).min_stdev];
                non_zero_stddevs = find(min_stdevs ~=0);
                min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
            end
            
            axes_children = get(GE_ax, 'children');

            post_spike_hold_off = well_electrode_data(well_count).electrode_data(min_electrode_beat_stdev_indx).ave_wave_post_spike_hold_off;
                                  
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

            set(GE_ax, 'xlim', [full_beat_x(1) full_beat_x(1)+post_spike_hold_off])
            
            
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

                    if isempty(well_electrode_data(well_count).electrode_data(electrode_count).average_waveform)
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
                                    
                                   

                                    post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_post_spike_hold_off;
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
 
                                    set(electrode_panel_children(elec_panel_child), 'xlim', [full_beat_x(1) full_beat_x(1)+post_spike_hold_off])
                                    
                                end
                            end
                        end
                    end
                end
            end
            %disp(axes_array)
            
            set(restore_full_beat_button, 'visible', 'on')
            
        end
        
        
        function repolZoomButtonPushed(repol_zoom_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, GE_ax)
            well_panel_children = get(well_pan, 'Children');
            
            if strcmp(get(change_GE_dropdown, 'Visible'), 'on')
                new_ge = get(change_GE_dropdown, 'Value');
                min_stdevs = contains([electrode_data(:).electrode_id], new_ge);
                min_electrode_beat_stdev_indx = find(min_stdevs == 1);
            else
                min_stdevs = [electrode_data(:).min_stdev];
                non_zero_stddevs = find(min_stdevs ~=0);
                min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
            end
            
            axes_children = get(GE_ax, 'children');
            post_spike_hold_off = well_electrode_data(well_count).electrode_data(min_electrode_beat_stdev_indx).ave_wave_post_spike_hold_off;
            t_wave_duration = well_electrode_data(well_count).electrode_data(min_electrode_beat_stdev_indx).ave_wave_t_wave_duration;


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
            axis_time_start = full_beat_x(1);

            for plot_child = 1:length(axes_children)
                x_data = axes_children(plot_child).XData;
                if length(x_data) == 1
                    if x_data > axis_time_start+post_spike_hold_off
                        set(GE_ax, 'xlim', [x_data-(t_wave_duration/2) x_data+(t_wave_duration/2)])

                    end
                    %set(electrode_panel_children(elec_panel_child), 'xlim', [x_data(1) x_data(1)+post_spike_hold_off])
                end
            end
            
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

                    if isempty(well_electrode_data(well_count).electrode_data(electrode_count).average_waveform)
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
                                    post_spike_hold_off = well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_post_spike_hold_off;
                                    t_wave_duration = well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_t_wave_duration;
                                    
                                    
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
            set(restore_full_beat_button, 'visible', 'on')
            
        end
        
        function restoreBeatButtonPushed(restore_full_beat_button, well_elec_fig, num_electrode_rows, num_electrode_cols, well_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, GE_ax)
           well_panel_children = get(well_pan, 'Children');
            
            axes_array = [];
            electrode_count = 0;
            electrode_ids = [well_electrode_data(well_count).electrode_data(:).electrode_id];
            
            if strcmp(get(change_GE_dropdown, 'Visible'), 'on')
                new_ge = get(change_GE_dropdown, 'Value');
                min_stdevs = contains([electrode_data(:).electrode_id], new_ge);
                min_electrode_beat_stdev_indx = find(min_stdevs == 1);
            else
                min_stdevs = [electrode_data(:).min_stdev];
                non_zero_stddevs = find(min_stdevs ~=0);
                min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
            end
            
            axes_children = get(GE_ax, 'children');
 
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

            set(GE_ax, 'xlim', [full_beat_x(1) full_beat_x(end)])


            
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

                    if isempty(well_electrode_data(well_count).electrode_data(electrode_count).average_waveform)
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

                                    set(electrode_panel_children(elec_panel_child), 'xlim', [full_beat_x(1) full_beat_x(end)])

                                    
                                end
                            end
                        end
                    end
                end
            end
            set(restore_full_beat_button, 'visible', 'off')
        end
    
    end

    function changeGEButtonPushed(change_GE_button, added_wells, change_GE_text, change_GE_dropdown, button_panel)
        well_ID = get(change_GE_button, 'Text');
        well_ID = regexp(well_ID, ' ', 'split');
        well_ID = well_ID{2};
        %%disp(well_ID)
        %%disp(contains(added_wells, well_ID))
        
        set(change_GE_button, 'Visible', 'off');
        set(change_GE_text, 'Visible', 'on');
        set(change_GE_dropdown, 'Visible', 'on');
        
        reset_GE_button = uibutton(button_panel,'push', 'BackgroundColor', '#e37f7f', 'Text', 'Reset Golden Electrode', 'Position', [2*(button_width/3)+(button_width/6) (button_height)/2 button_width/6 (button_height)/2], 'ButtonPushedFcn', @(reset_GE_button,event)resetGEButtonPushed(reset_GE_button, added_wells, change_GE_dropdown, change_GE_text, change_GE_button));
            
        %undo_skip_button = uibutton(button_panel,'push', 'BackgroundColor', '#e37f7f', 'Text', 'uNDO Skip Well', 'Position', [0 0 button_width (button_height)], 'ButtonPushedFcn', @(reset_GE_button,event)skipWellGEButtonPushed(reset_GE_button, added_wells, change_GE_dropdown, change_GE_text, change_GE_button));          
        %set(undo_skip_button, 'visible', 'off');
        
        %skip_well_GE_button = uibutton(button_panel,'push', 'BackgroundColor', '#e37f7f', 'Text', 'Skip Well', 'Position', [0 0 button_width (button_height)], 'ButtonPushedFcn', @(reset_GE_button,event)skipWellGEButtonPushed(reset_GE_button, added_wells, change_GE_dropdown, change_GE_text, change_GE_button));
                        
        
    end

    function resetGEButtonPushed(reset_GE_button, added_wells, change_GE_dropdown, change_GE_text, change_GE_button)
        set(change_GE_button, 'Visible', 'on');
        set(change_GE_text, 'Visible', 'off');
        set(change_GE_dropdown, 'Visible', 'off');
        set(reset_GE_button, 'Visible', 'off');
    end



    function acceptGEButtonPushed(accept_GE_button, out_fig)
        % dropdown selections
        % t-wave input 
        % 
        set(out_fig, 'Visible', 'off');
                
        ge_results_fig = uifigure;
        movegui(ge_results_fig,'center')
        %ge_results_fig.WindowState = 'maximized';
        ge_results_fig.Position = [100, 100, screen_width, screen_height];
        ge_results_fig.Name = 'Golden Electrode Results';
        % left bottom width height
        main_ge_pan = uipanel(ge_results_fig, 'BackgroundColor', '#fbeaea', 'Position', [0 0 screen_width screen_height]);
        
        back_GE_button = uibutton(main_ge_pan,'push','Text', 'Back', 'Position', [screen_width-200 550 100 50], 'ButtonPushedFcn', @(back_GE_button,event) backButtonPushed(ge_results_fig, out_fig));
            
        %display_results_button = uibutton(main_ge_pan,'push', 'BackgroundColor', '#3dd483','Text', 'Show Results', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(display_results_button,event) displayGEResultsPushed(display_results_button, ge_results_fig));
        
        save_button = uibutton(main_ge_pan,'push',  'BackgroundColor', '#3dd4d1', 'Text', 'Save', 'Position', [screen_width-210 250 100 50], 'ButtonPushedFcn', @(save_button,event) saveGEPushed(save_button, ge_results_fig, save_dir, num_electrode_rows, num_electrode_cols, dropdown_array));
        close_button = uibutton(main_ge_pan,'push','Text', 'Close', 'FontColor', 'w', 'BackgroundColor', '#B02727','Position', [screen_width-210 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeAllButtonPushed(close_button, ge_results_fig));
            
        
        well_p_width = screen_width-300;
        well_p_height = screen_height -100;
        ge_pan = uipanel(main_ge_pan, 'Position', [0 0 well_p_width well_p_height]);
        
        reanalyse_button = uibutton(main_ge_pan,'push','Text', 'Re-analyse Electrodes', 'Position', [screen_width-250 150 200 50], 'ButtonPushedFcn', @(reanalyse_button,event) reanalyseGEButtonPushed(reanalyse_button, ge_results_fig, num_electrode_rows, num_electrode_cols, ge_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));
        
        depol_zoom_button = uibutton(main_ge_pan,'push','Text', 'Expand Depol. Complexes', 'Position', [screen_width-220 350 150 50], 'ButtonPushedFcn', @(depol_zoom_button,event) depolGEZoomButtonPushed(depol_zoom_button, num_electrode_rows, num_electrode_cols, ge_pan));
        
        repol_zoom_button = uibutton(main_ge_pan,'push','Text', 'Expand Repol. Complexes', 'Position', [screen_width-220 400 150 50], 'ButtonPushedFcn', @(repol_zoom_button,event) repolGEZoomButtonPushed(repol_zoom_button, num_electrode_rows, num_electrode_cols, ge_pan));
        
        restore_full_beat_button = uibutton(main_ge_pan,'push','Text', 'Restore Full Beat', 'Position', [screen_width-220 450 150 50], 'ButtonPushedFcn', @(restore_full_beat_button,event) restoreGEBeatButtonPushed(restore_full_beat_button, num_electrode_rows, num_electrode_cols, ge_pan));
        set(restore_full_beat_button, 'visible', 'off')
        
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
                   
                   electrode_data = well_electrode_data(ge_count).electrode_data;
                   
                   non_empty_elec_data = find([electrode_data(:).electrode_id] ~= "");
                   
                   if strcmp(get(drop_down, 'Visible'), 'off')
                        min_stdevs = [electrode_data(:).min_stdev];
                        non_zero_stddevs = find(min_stdevs ~=0);
                        min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
                   else
                        new_ge = get(drop_down, 'Value');
                        new_ge_indx = contains([electrode_data(:).electrode_id], new_ge);
                        min_electrode_beat_stdev_indx = find(new_ge_indx == 1);
                   end
                   
                   ge_panel = uipanel(ge_pan, 'BackgroundColor', '#f2c2c2', 'Title', electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position',[((ge_c-1)*button_w) ((ge_r-1)*button_h) button_w button_h]);
                   
                   GE_ax = uiaxes(ge_panel,  'Position', [5 40 button_w-10 button_h-60]);
                   
                   hold(GE_ax,'on')
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).filtered_ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).filtered_average_waveform);
                   %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'r.', 'MarkerSize', 20);
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'b.', 'MarkerSize', 20);
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time == electrode_data(min_electrode_beat_stdev_indx).ave_activation_time), 'k.', 'MarkerSize', 20);

                   peak_indx = find(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time >= electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time);
                   peak_indx = peak_indx(1);
                   t_wave_peak = electrode_data(min_electrode_beat_stdev_indx).average_waveform(peak_indx);

                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, t_wave_peak, 'c.', 'MarkerSize', 20);

                   GE_dur =  electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(end)- electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(1);
                   xlim(GE_ax, [electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(1)-0.1*GE_dur,  electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(end)+0.1*GE_dur]);
                   
                   %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                   %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                   hold(GE_ax,'off')
                   undo_reject_ge_panel = uipanel(ge_pan, 'Title', electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'BackgroundColor', '#f2c2c2', 'Position', [((ge_c-1)*button_w) ((ge_r-1)*button_h) button_w button_h]);
                   undo_reject_well_button = uibutton(undo_reject_ge_panel,'push','Text', 'Undo Reject Well', 'BackgroundColor', '#B02727', 'Fontcolor', 'w', 'Position', [0 0 button_w button_h], 'ButtonPushedFcn', @(undo_reject_well_button,event) undoRejectGEWellPushed(undo_reject_ge_panel, ge_panel, ge_count, undo_reject_ge_panel));
                   if well_electrode_data(ge_count).rejected_well == 1
                        set(undo_reject_ge_panel, 'visible', 'on')
                   else
                        set(undo_reject_ge_panel, 'visible', 'off')
                   end
                
                   t_wave_time_text = uieditfield(ge_panel,'Text', 'Value', 'T-wave Peak Time', 'Position', [0 0 (button_w/2) 20], 'Editable','off');
                   t_wave_time_ui = uieditfield(ge_panel, 'numeric', 'Tag', 'T-Wave', 'Position', [button_w/2 0 (button_w/2) 20], 'ValueChangedFcn',@(t_wave_time_ui,event) changeGETWaveTime(t_wave_time_ui, GE_ax, ge_count, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform, min_electrode_beat_stdev_indx));

                   manual_t_wave_button = uibutton(ge_panel,'push','Text', 'Manual T-Wave Peak Input', 'BackgroundColor', '#B02727', 'Fontcolor', 'w', 'Position', [0 20 (button_w/2) 20], 'ButtonPushedFcn', @(manual_t_wave_button,event) manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui));
                   
                   reject_well_button = uibutton(ge_panel,'push','Text', 'Reject Well', 'Position', [(button_w/2) 20 (button_w/2) 20], 'BackgroundColor', '#d64343','Fontcolor', 'w', 'ButtonPushedFcn', @(reject_well_button,event) rejectGEWellPushed(reject_well_button, ge_panel, ge_count, undo_reject_ge_panel));
                   
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
                electrode_data = well_electrode_data(ge).electrode_data;

                %disp([electrode_data(:).electrode_id])
                non_empty_elec_data = find([electrode_data(:).electrode_id] ~= "");
                %electrode_data = electrode_data(non_empty_elec_data);
                
                if strcmp(get(drop_down, 'Visible'), 'off')
                    min_stdevs = [electrode_data(:).min_stdev];
                    non_zero_stddevs = find(min_stdevs ~=0);
                    min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
                else
                    new_ge = get(drop_down, 'Value');
                    new_ge_indx = contains([electrode_data(:).electrode_id], new_ge);
                    min_electrode_beat_stdev_indx = find(new_ge_indx == 1);
                end
                
                ge_panel = uipanel(ge_pan,'BackgroundColor', '#f2c2c2', 'Title', electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position', [((ge-1)*button_w) 0 button_w button_h]);
                
                GE_ax = uiaxes(ge_panel,  'Position', [5 40 button_w-10 button_h-60]);
                
                hold(GE_ax,'on')
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).filtered_ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).filtered_average_waveform);
                %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'r.', 'MarkerSize', 20);
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'b.', 'MarkerSize', 20);
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).ave_activation_point, 'k.', 'MarkerSize', 20);


                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak, 'c.', 'MarkerSize', 20);

                t_wave_time_text = uieditfield(ge_panel,'Text', 'Value', 'T-wave Peak Time', 'Position', [0 0 (button_w/2) 20], 'Editable','off');
                t_wave_time_ui = uieditfield(ge_panel, 'numeric', 'Tag', 'T-Wave', 'Position', [button_w/2 0 (button_w/2) 20], 'ValueChangedFcn',@(t_wave_time_ui,event) changeGETWaveTime(t_wave_time_ui, GE_ax, ge, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform, min_electrode_beat_stdev_indx));

                GE_dur =  electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(end)- electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(1);
                xlim(GE_ax, [electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(1)-0.1*GE_dur,  electrode_data(min_electrode_beat_stdev_indx).ave_wave_time(end)+0.1*GE_dur]);
                
                undo_reject_ge_panel = uipanel(ge_pan,  'BackgroundColor', '#f2c2c2', 'Title', strcat(electrode_data(min_electrode_beat_stdev_indx).electrode_id, '_rejected'), 'Position', [((ge-1)*button_w) 0 button_w button_h]);
                undo_reject_well_button = uibutton(undo_reject_ge_panel,'push', 'BackgroundColor', '#B02727',  'Fontcolor', 'w', 'Text', 'Undo Reject Well', 'Position', [0 0 button_w button_h], 'ButtonPushedFcn', @(undo_reject_well_button,event) undoRejectGEWellPushed(undo_reject_ge_panel, ge_panel, ge, undo_reject_ge_panel));
                if well_electrode_data(ge).rejected_well == 1
                    set(undo_reject_ge_panel, 'visible', 'on')
                else
                    set(undo_reject_ge_panel, 'visible', 'off')
                end
                
               
                manual_t_wave_button = uibutton(ge_panel,'push','Text', 'Manual T-Wave Peak Input', 'BackgroundColor', '#B02727', 'Fontcolor', 'w', 'Position', [0 20 (button_w/2) 20], 'ButtonPushedFcn', @(manual_t_wave_button,event) manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui));
                reject_well_button = uibutton(ge_panel,'push','Text', 'Reject Well', 'Position', [(button_w/2) 20 (button_w/2) 20], 'BackgroundColor', '#d64343','Fontcolor', 'w', 'ButtonPushedFcn', @(reject_well_button,event) rejectGEWellPushed(reject_well_button, ge_panel, ge, undo_reject_ge_panel));
                   
                
                
                
                set(t_wave_time_text, 'Visible', 'off')
                set(t_wave_time_ui, 'Visible', 'off')
                %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                hold(GE_ax,'off')
            end
        end
        
        function rejectGEWellPushed(reject_well_button, review_ge_panel, i, undo_reject_ge_panel)

            set(panel_array(1,i).panel, 'visible', 'off')
            set(review_ge_panel, 'visible', 'off')
            set(undo_reject_ge_panel, 'visible', 'on')
            well_electrode_data(i).rejected_well = 1;
        end
        
        function undoRejectGEWellPushed(reject_well_button, review_ge_panel, i, undo_reject_ge_panel)
            set(panel_array(i).panel, 'visible', 'on')
            set(review_ge_panel, 'visible', 'on')
            set(undo_reject_ge_panel, 'visible', 'off')
            well_electrode_data(i).rejected_well = 0;
        end

        function changeGETWaveTime(t_wave_time_ui, GE_ax, well_count, time, data, electrode_count)
             max_depol_time = well_electrode_data(well_count).electrode_data(electrode_count).ave_max_depol_time;
             min_depol_time = well_electrode_data(well_count).electrode_data(electrode_count).ave_min_depol_time;
             act_time = well_electrode_data(well_count).electrode_data(electrode_count).ave_activation_time;
            
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

                plot(GE_ax, get(t_wave_time_ui, 'Value'), t_wave_peak, 'c.', 'MarkerSize', 20);
                hold(GE_ax, 'off')

            else
                t_wave_plot.XData = get(t_wave_time_ui, 'Value');
                t_wave_plot.YData = t_wave_peak;
            end
            well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
            %electrode_data(electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
            
        end 
        
        function depolGEZoomButtonPushed(depol_zoom_button, num_electrode_rows, num_electrode_cols, well_pan)
            well_panel_children = get(well_pan, 'Children');
            
  
            for w = 1:num_wells
                for well_panel_child = 1:length(well_panel_children)

                    if isempty(well_panel_children(well_panel_child))
                       continue 
                    end
                    
                    if strcmp(get(dropdown_array(w), 'visible'), 'on')
                        ge_electrode = get(dropdown_array(w), 'value');
                        ge_indx = find(strcmp(ge_electrode, [well_electrode_data(w).electrode_data(:).electrode_id]) == 1);
                    else   
                        ge_indx = well_electrode_data(w).GE_electrode_indx;
                    end
                    if strcmp(get(well_panel_children(well_panel_child), 'Title'), well_electrode_data(w).electrode_data(ge_indx).electrode_id)

                        electrode_panel_children = get(well_panel_children(well_panel_child), 'Children');

                        for elec_panel_child = 1:length(electrode_panel_children)

                            if strcmp(string(get(electrode_panel_children(elec_panel_child), 'Type')), 'axes')
                                %disp(electrode_panel_children(elec_panel_child))
                                % Change the view of the panel
                                axes_children = get(electrode_panel_children(elec_panel_child), 'children');
                                post_spike_hold_off = well_electrode_data(w).electrode_data(ge_indx).ave_wave_post_spike_hold_off;

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

                                set(electrode_panel_children(elec_panel_child), 'xlim', [full_beat_x(1) full_beat_x(1)+post_spike_hold_off])


                            end
                        end
                    end
                end
            end
                
            %disp(axes_array)
            
            set(restore_full_beat_button, 'visible', 'on')
            
        end
        
        
        function repolGEZoomButtonPushed(repol_zoom_button, num_electrode_rows, num_electrode_cols, well_pan)
            well_panel_children = get(well_pan, 'Children');
            for w = 1:num_wells
                for well_panel_child = 1:length(well_panel_children)

                    if isempty(well_panel_children(well_panel_child))
                       continue 
                    end
                    
                    if strcmp(get(dropdown_array(w), 'visible'), 'on')
                        ge_electrode = get(dropdown_array(w), 'value');
                        ge_indx = find(strcmp(ge_electrode, [well_electrode_data(w).electrode_data(:).electrode_id]) == 1);
                    else   
                        ge_indx = well_electrode_data(w).GE_electrode_indx;
                    end

                    if strcmp(get(well_panel_children(well_panel_child), 'Title'), well_electrode_data(w).electrode_data(ge_indx).electrode_id)
                        electrode_panel_children = get(well_panel_children(well_panel_child), 'Children');

                        for elec_panel_child = 1:length(electrode_panel_children)

                            if strcmp(string(get(electrode_panel_children(elec_panel_child), 'Type')), 'axes')
                                %disp(electrode_panel_children(elec_panel_child))
                                % Change the view of the panel

                                axes_children = get(electrode_panel_children(elec_panel_child), 'children');
                                post_spike_hold_off = well_electrode_data(w).electrode_data(ge_indx).ave_wave_post_spike_hold_off;
                                t_wave_duration = well_electrode_data(w).electrode_data(ge_indx).ave_wave_t_wave_duration;

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
           
            set(restore_full_beat_button, 'visible', 'on')
            
        end
        
        function restoreGEBeatButtonPushed(restore_full_beat_button, num_electrode_rows, num_electrode_cols, well_pan)
           well_panel_children = get(well_pan, 'Children');
           
            
            for w = 1:num_wells
                for well_panel_child = 1:length(well_panel_children)

                    if isempty(well_panel_children(well_panel_child))
                       continue 
                    end
                    
                    if strcmp(get(dropdown_array(w), 'visible'), 'on')
                        ge_electrode = get(dropdown_array(w), 'value');
                        ge_indx = find(strcmp(ge_electrode, [well_electrode_data(w).electrode_data(:).electrode_id]) == 1);
                    else   
                        ge_indx = well_electrode_data(w).GE_electrode_indx;
                    end
                    if strcmp(get(well_panel_children(well_panel_child), 'Title'), well_electrode_data(w).electrode_data(ge_indx).electrode_id)
                            
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

                                set(electrode_panel_children(elec_panel_child), 'xlim', [full_beat_x(1) full_beat_x(end)])


                            end
                        end
                    end
                end
            end
            set(restore_full_beat_button, 'visible', 'off')
        end
        
        function reanalyseGEButtonPushed(reanalyse_button, ge_results_fig, num_electrode_rows, num_electrode_cols, ge_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)

            set(ge_results_fig, 'Visible', 'off')

            reanalyse_fig = uifigure;
            movegui(reanalyse_fig,'center')
            reanalyse_fig.WindowState = 'maximized';
            reanalyse_pan = uipanel(reanalyse_fig, 'BackgroundColor','#d43d3d', 'Position', [0 0 screen_width screen_height]);
            submit_reanalyse_button = uibutton(reanalyse_pan, 'push','Text', 'Submit Electrodes', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(submit_reanalyse_button,event) submitReanalyseButtonPushed(submit_reanalyse_button, ge_results_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis));

            reanalyse_width = screen_width-300;
            reanalyse_height = screen_height -100;
            ra_pan = uipanel(reanalyse_pan, 'BackgroundColor','#B02727', 'Position', [0 0 reanalyse_width reanalyse_height]);

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

                       electro_data = well_electrode_data(re_ge_count).electrode_data;
                       if strcmp(get(drop_down, 'Visible'), 'off')
                            min_stdevs = [electro_data(:).min_stdev];
                            non_zero_stddevs = find(min_stdevs ~=0);
                            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
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
                        ra_elec_pan = uipanel(ra_pan, 'Title', re_well_ID, 'BackgroundColor','#d43d3d', 'Position', [(re_ge_c-1)*(reanalyse_width/num_button_cols) (re_ge_r-1)*(reanalyse_height/num_button_rows) reanalyse_width/num_button_cols reanalyse_height/num_button_rows]);
                        if well_electrode_data(re_ge_count).rejected_well == 1
                            re_ge_count = re_ge_count+1;
                            continue
                        end
                        ra_elec_button = uibutton(ra_elec_pan, 'push', 'BackgroundColor','#e68e8e','Text', strcat('Reanalyse', {' '}, re_well_ID), 'Position', [0 0 reanalyse_width/num_button_cols reanalyse_height/num_button_rows], 'ButtonPushedFcn', @(ra_elec_button,event) reanalyseElectrodeButtonPushed(ra_elec_button, electro_data(min_electrode_beat_stdev_indx).electrode_id), re_well_ID);

                        re_ge_count = re_ge_count+1;
                   end
                   if re_stop_ge_add == 1
                       break;
                   end
                end
            else
            
                for re_ge = 1:num_wells
                    
                    drop_down = dropdown_array(re_ge);
                    electro_data = well_electrode_data(re_ge);
                    
                    drop_down = dropdown_array(re_ge);
                    re_well_ID = added_wells(re_ge);

                    electro_data = well_electrode_data(re_ge).electrode_data;
                    if strcmp(get(drop_down, 'Visible'), 'off')
                        min_stdevs = [electro_data(:).min_stdev];
                        non_zero_stddevs = find(min_stdevs ~=0);
                        min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
                    else
                        new_ge = get(drop_down, 'Value');
                        new_ge_indx = contains([electro_data(:).electrode_id], new_ge);
                        min_electrode_beat_stdev_indx = find(new_ge_indx == 1);
                    end

                    ge_pan_children = get(ge_pan, 'Children');
                    for gp = 1:length(ge_pan_children)
                        %%disp('title');
                        %%disp(get(ge_pan_children(gp), 'Title'))
                        if strcmp(get(ge_pan_children(gp), 'Title'), electro_data(min_electrode_beat_stdev_indx).electrode_id)
                            reanalyse_panels = [reanalyse_panels; ge_pan_children(gp)];
                        end
                    end
                    %elec_count = elec_count+1;
                    ra_elec_pan = uipanel(ra_pan, 'Title', re_well_ID, 'BackgroundColor','#d43d3d', 'Position', [(re_ge-1)*(reanalyse_width/num_button_cols) 0 reanalyse_width/num_button_cols reanalyse_height]);
                    if well_electrode_data(re_ge).rejected_well == 1
                        continue
                    end
                    ra_elec_button = uibutton(ra_elec_pan, 'push', 'BackgroundColor','#e68e8e','Text', strcat('Reanalyse', {' '}, re_well_ID), 'Position', [0 0 reanalyse_width/num_button_cols reanalyse_height], 'ButtonPushedFcn', @(ra_elec_button,event) reanalyseElectrodeButtonPushed(ra_elec_button, electro_data(min_electrode_beat_stdev_indx).electrode_id, re_well_ID));

                end

            end
            function reanalyseElectrodeButtonPushed(ra_elec_button, electrode_id, re_well_ID)
                if strcmp(get(ra_elec_button, 'Text'), strcat('Reanalyse', {' '}, re_well_ID))
                    set(ra_elec_button, 'Text', 'Undo');
                    set(ra_elec_button, 'BackgroundColor','#B02727')
                    reanalyse_electrodes = [reanalyse_electrodes; electrode_id];
                elseif strcmp(get(ra_elec_button, 'Text'), 'Undo')
                    set(ra_elec_button, 'Text', strcat('Reanalyse', {' '}, re_well_ID));
                    set(ra_elec_button, 'BackgroundColor','#e68e8e')
                    reanalyse_electrodes = reanalyse_electrodes(~contains(reanalyse_electrodes, electrode_id));
                end
            end
            
            

            function submitReanalyseButtonPushed(submit_reanalyse_button, ge_results_fig, reanalyse_fig, num_electrode_rows, num_electrode_cols, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)
                %set(reanalyse_fig, 'Visible', 'off')
                close(reanalyse_fig)
                if isempty(electrode_data)
                   return; 
                end
                disp(reanalyse_electrodes)
                [well_electrode_data] = electrode_GE_analysis(well_electrode_data, num_electrode_rows, num_electrode_cols, reanalyse_electrodes, ge_results_fig, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, num_wells, reanalyse_panels);
                %%disp(electrode_data(re_count).activation_times(2))
            end

        end
        
        
    end
    

    function manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui)
        set(t_wave_time_text, 'Visible', 'on');
        set(t_wave_time_ui, 'Visible', 'on');
        set(manual_t_wave_button, 'Visible', 'off');
            
    end

    

    function saveGEPushed(save_button, ge_results_fig, save_dir, num_electrode_rows, num_electrode_cols, dropdown_array)
        disp('Saving Golden Electrode Data')
        wait_bar = waitbar(0, 'Saving GE Data');
        
        
        set(ge_results_fig, 'visible', 'off')
        output_filename = fullfile(save_dir, strcat('golden_electrode_results.xls'));
        if exist(output_filename, 'file')
            try
                delete(output_filename);
            catch
                msgbox(strcat(output_filename, {' '}, 'is open. Please close and try saving again.'))
                close(wait_bar)
                set(ge_results_fig, 'visible', 'on')
                return
            end
        end
        
        if ~exist(fullfile(save_dir, 'GE_figures'), 'dir')
            mkdir(fullfile(save_dir, 'GE_figures'))
        else
            try
                rmdir(fullfile(save_dir, 'GE_figures'), 's')
                mkdir(fullfile(save_dir, 'GE_figures'))
            catch
                msgbox(strcat('A file in', {' '}, fullfile(save_dir, '_figures'), {' '}, 'is open. Please close and try saving again.'))
                close(wait_bar)
                set(ge_results_fig, 'visible', 'on')
                return
            end
        end
        if ~exist(fullfile(save_dir, 'GE_images'), 'dir')
            mkdir(fullfile(save_dir, 'GE_images'))
        else
            try
                rmdir(fullfile(save_dir, 'GE_images'), 's')
                mkdir(fullfile(save_dir, 'GE_images'))
            catch
                msgbox(strcat('A file in', {' '}, fullfile(save_dir, '_images'), {' '}, 'is open. Please close and try saving again.'))
                close(wait_bar)
                set(ge_results_fig, 'visible', 'on')
                return
                
            end
        end
        well_FPDs = [];
        well_slopes = [];
        well_amps = [];
        well_bps = [];
        
        sheet_count = 1;
        num_partitions = 1/(num_wells);
        partition = num_partitions;
        
        for w = 1:num_wells
            
            
            waitbar(partition, wait_bar, strcat('Saving Data for ', {' '}, well_electrode_data(w).wellID));
            partition = partition+num_partitions;
            
            if well_electrode_data(w).rejected_well == 1
                continue
            end
            electrode_data = well_electrode_data(w).electrode_data;
            drop_down = dropdown_array(w);
            if strcmp(get(drop_down, 'Visible'), 'off')
                min_stdevs = [electrode_data(:).min_stdev];
                non_zero_stddevs = find(min_stdevs ~=0);
                min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
            
            else
                new_ge = get(drop_down, 'Value');
                new_ge_indx = contains([electrode_data(:).electrode_id], new_ge);
                min_electrode_beat_stdev_indx = find(new_ge_indx == 1);
            end
            sheet_count = sheet_count+1;
            %electrode_stats_header = {electrode_data(electrode_count).electrode_id, 'Beat No.', 'Beat Start Time (s)', 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Cycle Length (s)'};
    
            %disp(min_electrode_beat_stdev_indx)
            
            t_wave_peak_times = electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time;
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
            
            activation_point = electrode_data(min_electrode_beat_stdev_indx).ave_activation_point;
            [br, bc] = size(activation_point);
            activation_point = reshape(activation_point, [bc br]);
            activation_point = num2cell([activation_point]);
            

            [br, bc] = size(amps);
            amps = reshape(amps, [bc br]);
            amps = num2cell([amps]);

            [br, bc] = size(slopes);
            slopes = reshape(slopes, [bc br]);
            slopes = num2cell([slopes]);
            
            min_depol_time = electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time;
            [br, bc] = size(min_depol_time);
            min_depol_time = reshape(min_depol_time, [bc br]);
            min_depol_time = num2cell([min_depol_time]);

            min_depol_point = electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point;
            [br, bc] = size(min_depol_point);
            min_depol_point = reshape(min_depol_point, [bc br]);
            min_depol_point = num2cell([min_depol_point]);

            max_depol_time = electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time;
            [br, bc] = size(max_depol_time);
            max_depol_time = reshape(max_depol_time, [bc br]);
            max_depol_time = num2cell([max_depol_time]);

            max_depol_point = electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point;
            [br, bc] = size(max_depol_point);
            max_depol_point = reshape(max_depol_point, [bc br]);
            max_depol_point = num2cell([max_depol_point]);


            t_wave_peak_times = electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time;
            [br, bc] = size(t_wave_peak_times);
            t_wave_peak_times = reshape(t_wave_peak_times, [bc br]);
            t_wave_peak_times = num2cell([t_wave_peak_times]);
                
            t_wave_peak_array = electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak;
            [br, bc] = size(t_wave_peak_array);
            t_wave_peak_array = reshape(t_wave_peak_array, [bc br]);
            t_wave_peak_array = num2cell([t_wave_peak_array]);

            [br, bc] = size(FPDs);
            FPDs = reshape(FPDs, [bc br]);
            FPD_num = FPDs;
            FPDs = num2cell([FPDs]);

            [br, bc] = size(bps);
            beat_periods = reshape(bps, [bc br]);
            bp_num = beat_periods;
            beat_periods = num2cell([beat_periods]);
            
            ave_wave_post_spike_hold_off_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).ave_wave_post_spike_hold_off]);
                    
                    
            ave_wave_t_wave_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).ave_wave_t_wave_duration]);


            ave_wave_t_wave_offset_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).ave_wave_t_wave_offset]);


            %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
            ave_wave_t_wave_shape_array = {electrode_data(min_electrode_beat_stdev_indx).ave_wave_t_wave_shape};


            ave_wave_filter_intensity_array = {electrode_data(min_electrode_beat_stdev_indx).ave_wave_filter_intensity};
            
            wavelet_family = {electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_wavelet};
                    
            polynomial_degree = num2cell(electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_polynomial_degree);
            
            
            if strcmp(spon_paced, 'spon')

                stable_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).stable_beats_duration]);

                bdt_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).bdt]);

                min_bp_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).min_bp]);

                max_bp_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).max_bp]);

                post_spike_hold_off_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).post_spike_hold_off]);

                t_wave_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_duration]);

                t_wave_offset_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_offset]);

                %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                t_wave_shape_array = {electrode_data(min_electrode_beat_stdev_indx).t_wave_shape};

                filter_intensity_array = {electrode_data(min_electrode_beat_stdev_indx).filter_intensity};
                
                warning_array = {electrode_data(min_electrode_beat_stdev_indx).ave_warning};
                
                FPDc_fridericia = FPD_num/((bp_num)^(1/3));
                FPDc_bazzet = FPD_num/((bp_num)^(1/2));

                %electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, stable_duration_array, bdt_array, min_bp_array, max_bp_array, post_spike_hold_off_array, t_wave_duration_array, t_wave_offset_array, t_wave_shape_array, filter_intensity_array, warning_array);
                
                if well_electrode_data(w).rejected_well == 0
                    electrode_stats_table = table('Size', [1, 32], 'VariableTypes', ["string", "double",  "double", "double",  "double", "double",  "double",  "double", "double",  "double", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string","double",  "double",  "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)',  'FPDc Fridericia (s)', 'FPDc Bazzet (s)', 'Beat Period (s)', 'Stable Beats Duration (s)', 'Beat Wide Beat Detection Threshold Input (V)', 'Beat Wide Mininum Beat Period Input (s)', 'Beat Wide Maximum Beat Period Input (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'GE Beat Post-spike hold-off (s)', 'GE Beat T-wave Duration Input (s)', 'GE Beat T-wave offset Input (s)', 'GE Beat T-wave Shape', 'GE Beat Filter Intensity', "GE Beat T-wave Denoising Wavelet Family", "GE Beat T-wave Polynomial Degree", 'Warnings']));
                    
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

                    electrode_stats_table(:, 16) = stable_duration_array;

                    electrode_stats_table(:, 17) = bdt_array;
                    electrode_stats_table(:, 18) = min_bp_array;
                    electrode_stats_table(:, 19) = max_bp_array;
                    electrode_stats_table(:, 20) = post_spike_hold_off_array;
                    electrode_stats_table(:, 21) = t_wave_duration_array;
                    electrode_stats_table(:, 22) = t_wave_offset_array;
                    electrode_stats_table(:, 23) = t_wave_shape_array;
                    electrode_stats_table(:, 24) = filter_intensity_array;

                    electrode_stats_table(:, 25) = ave_wave_post_spike_hold_off_array;
                    electrode_stats_table(:, 26) = ave_wave_t_wave_duration_array;
                    electrode_stats_table(:, 27) = ave_wave_t_wave_offset_array;
                    electrode_stats_table(:, 28) = ave_wave_t_wave_shape_array;
                    electrode_stats_table(:, 29) = ave_wave_filter_intensity_array;

                    electrode_stats_table(:, 30) = wavelet_family;
                    electrode_stats_table(:, 31) = polynomial_degree;

                    electrode_stats_table(:, 32) = warning_array;
                else
                    electrode_stats_table = table('Size', [0, 32], 'VariableTypes', ["string", "double",  "double", "double",  "double", "double",  "double",  "double", "double",  "double", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string","double",  "double",  "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)',  'FPDc Fridericia (s)', 'FPDc Bazzet (s)', 'Beat Period (s)', 'Stable Beats Duration (s)', 'Beat Wide Beat Detection Threshold Input (V)', 'Beat Wide Mininum Beat Period Input (s)', 'Beat Wide Maximum Beat Period Input (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'GE Beat Post-spike hold-off (s)', 'GE Beat T-wave Duration Input (s)', 'GE Beat T-wave offset Input (s)', 'GE Beat T-wave Shape', 'GE Beat Filter Intensity', "GE Beat T-wave Denoising Wavelet Family", "GE Beat T-wave Polynomial Degree", 'Warnings']));
                    
                end
                
                
            elseif strcmp(spon_paced, 'paced')
                stable_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).stable_beats_duration]);

                stim_spike_hold_off_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).stim_spike_hold_off]);

                post_spike_hold_off_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).post_spike_hold_off]);

                t_wave_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_duration]);

                t_wave_offset_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_offset]);

                %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                t_wave_shape_array = {electrode_data(min_electrode_beat_stdev_indx).t_wave_shape};
                
                filter_intensity_array = {electrode_data(min_electrode_beat_stdev_indx).filter_intensity};
                
                ave_wave_stim_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_stim_spike_hold_off]);

                warning_array = {electrode_data(min_electrode_beat_stdev_indx).ave_warning};

                %electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, stable_duration_array, stim_spike_hold_off_array, post_spike_hold_off_array, t_wave_duration_array, t_wave_offset_array, t_wave_shape_array, filter_intensity_array, warning_array);

                if well_electrode_data(w).rejected_well == 0
                    electrode_stats_table = table('Size', [1, 29], 'VariableTypes', ["string", "double",  "double",  "double", "double",  "double", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string", "double",  "double",  "double",  "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Stable Beats Duration (s)', 'Beat Wide Stim-spike hold-off (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'GE Beat Stim-spike hold-off (s)', 'GE Beat Post-spike hold-off (s)', 'GE Beat T-wave Duration Input (s)', 'GE Beat T-wave offset Input (s)', 'GE Beat  T-wave Shape', 'GE Beat Filter Intensity', "GE Beat T-wave Denoising Wavelet Family", "GE Beat T-wave Polynomial Degree", 'Warnings']));

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

                    electrode_stats_table(:, 14) = stable_duration_array;
                    electrode_stats_table(:, 15) = stim_spike_hold_off_array;
                    electrode_stats_table(:, 16) = post_spike_hold_off_array;
                    electrode_stats_table(:, 17) = t_wave_duration_array;
                    electrode_stats_table(:, 18) = t_wave_offset_array;
                    electrode_stats_table(:, 19) = t_wave_shape_array;
                    electrode_stats_table(:, 20) = filter_intensity_array;

                    electrode_stats_table(:, 21) = ave_wave_stim_spike_hold_off_array;
                    electrode_stats_table(:, 22) = ave_wave_post_spike_hold_off_array;
                    electrode_stats_table(:, 23) = ave_wave_t_wave_duration_array;
                    electrode_stats_table(:, 24) = ave_wave_t_wave_offset_array;
                    electrode_stats_table(:, 25) = ave_wave_t_wave_shape_array;
                    electrode_stats_table(:, 26) = ave_wave_filter_intensity_array;

                    electrode_stats_table(:, 27) = wavelet_family;
                    electrode_stats_table(:, 28) = polynomial_degree;

                    electrode_stats_table(:, 29) = warning_array;
                else
                    electrode_stats_table = table('Size', [0, 29], 'VariableTypes', ["string", "double",  "double",  "double", "double",  "double", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string", "double",  "double",  "double",  "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Stable Beats Duration (s)', 'Beat Wide Stim-spike hold-off (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'GE Beat Stim-spike hold-off (s)', 'GE Beat Post-spike hold-off (s)', 'GE Beat T-wave Duration Input (s)', 'GE Beat T-wave offset Input (s)', 'GE Beat  T-wave Shape', 'GE Beat Filter Intensity', "GE Beat T-wave Denoising Wavelet Family", "GE Beat T-wave Polynomial Degree", 'Warnings']));

                    
                end

            elseif strcmp(spon_paced, 'paced bdt')
                stable_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).stable_beats_duration]);

                bdt_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).bdt]);
                
                min_bp_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).min_bp]);

                max_bp_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).max_bp]);

                stim_spike_hold_off_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).stim_spike_hold_off]);

                post_spike_hold_off_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).post_spike_hold_off]);

                t_wave_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_duration]);

                t_wave_offset_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_offset]);

                %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                t_wave_shape_array = {electrode_data(min_electrode_beat_stdev_indx).t_wave_shape};
                
                filter_intensity_array = {electrode_data(min_electrode_beat_stdev_indx).filter_intensity};
                
                ave_wave_stim_spike_hold_off_array = num2cell([well_electrode_data(well_count).electrode_data(electrode_count).ave_wave_stim_spike_hold_off]);

                warning_array = {electrode_data(min_electrode_beat_stdev_indx).ave_warning};

                
                %electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, stable_duration_array, bdt_array, min_bp_array, max_bp_array, stim_spike_hold_off_array, post_spike_hold_off_array, t_wave_duration_array, t_wave_offset_array, t_wave_shape_array, filter_intensity_array, warning_array);
                if well_electrode_data(w).rejected_well == 0
                    electrode_stats_table = table('Size', [1, 32], 'VariableTypes', ["string", "double",  "double",  "double", "double",  "double", "double", "double",  "double", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string", "double",  "double",  "double",  "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Time Region Start (s)', 'Time Region End (s)', 'Beat Wide Beat Detection Threshold Input (V)', 'Beat Wide Mininum Beat Period Input (s)', 'Beat Wide Maximum Beat Period Input (s)', 'Beat Wide Stim-spike hold-off (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'GE Beat Stim-spike hold-off (s)', 'GE Beat Post-spike hold-off (s)', 'GE Beat T-wave Duration Input (s)', 'GE Beat T-wave offset Input (s)', 'GE Beat T-wave Shape', 'GE Beat Filter Intensity', "GE Beat T-wave Denoising Wavelet Family", "GE Beat T-wave Polynomial Degree", 'Warnings']));

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

                    electrode_stats_table(:, 14) = stable_duration_array;
                    electrode_stats_table(:, 15) = bdt_array; 
                    electrode_stats_table(:, 16) = min_bp_array; 
                    electrode_stats_table(:, 17) = max_bp_array; 
                    electrode_stats_table(:, 18) = stim_spike_hold_off_array;
                    electrode_stats_table(:, 19) = post_spike_hold_off_array;
                    electrode_stats_table(:, 20) = t_wave_duration_array;
                    electrode_stats_table(:, 21) = t_wave_offset_array;
                    electrode_stats_table(:, 22) = t_wave_shape_array;
                    electrode_stats_table(:, 23) = filter_intensity_array;

                    electrode_stats_table(:, 24) = ave_wave_stim_spike_hold_off_array;
                    electrode_stats_table(:, 25) = ave_wave_post_spike_hold_off_array;
                    electrode_stats_table(:, 26) = ave_wave_t_wave_duration_array;
                    electrode_stats_table(:, 27) = ave_wave_t_wave_offset_array;
                    electrode_stats_table(:, 28) = ave_wave_t_wave_shape_array;
                    electrode_stats_table(:, 29) = ave_wave_filter_intensity_array;

                    electrode_stats_table(:, 30) = wavelet_family;
                    electrode_stats_table(:, 31) = polynomial_degree;

                    electrode_stats_table(:, 32) = warning_array;
                else
                    electrode_stats_table = table('Size', [0, 32], 'VariableTypes', ["string", "double",  "double",  "double", "double",  "double", "double", "double",  "double", "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double",  "double", "string", "string", "double",  "double",  "double",  "double", "string", "string", "string", "double", "string"], 'VariableNames', cellstr([well_electrode_data(well_count).electrode_data(electrode_count).electrode_id, 'Activation Time (s)', 'Activation Point (V)', "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Time Region Start (s)', 'Time Region End (s)', 'Beat Wide Beat Detection Threshold Input (V)', 'Beat Wide Mininum Beat Period Input (s)', 'Beat Wide Maximum Beat Period Input (s)', 'Beat Wide Stim-spike hold-off (s)', 'Beat Wide Post-spike hold-off (s)', 'Beat Wide T-wave Duration Input (s)', 'Beat Wide T-wave offset Input (s)', 'Beat Wide T-wave Shape', 'Beat Wide Filter Intensity', 'GE Beat Stim-spike hold-off (s)', 'GE Beat Post-spike hold-off (s)', 'GE Beat T-wave Duration Input (s)', 'GE Beat T-wave offset Input (s)', 'GE Beat T-wave Shape', 'GE Beat Filter Intensity', "GE Beat T-wave Denoising Wavelet Family", "GE Beat T-wave Polynomial Degree", 'Warnings']));

                    
                end
            end
          


            %electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods);
            %electrode_stats = {[elec_id_column] [beat_num_array] [beat_start_times] [activation_times] [amps] [slopes] [t_wave_peak_times] [t_wave_peak_array] [FPDs] [beat_periods] [cycle_length_array]};
            %electrode_stats = {electrode_stats_header;electrode_stats};


            % all_data must be a cell array
            %xlswrite(output_filename, electrode_stats, sheet_count);
            
            
            %writecell(electrode_stats, output_filename, 'Sheet', sheet_count);
            
            
            try 
                if sheet_count ~= 2
                    fileattrib(output_filename, '-h +w');
                end
                
                writetable(electrode_stats_table, output_filename, 'Sheet', sheet_count);
                fileattrib(output_filename, '+h +w');
                
            catch
                msgbox(strcat(output_filename, {' '}, 'is open and cannot be written to. Please close it and try saving again.'));
                close(wait_bar)

                set(ge_results_fig, 'visible', 'on')
                return
            end
            
            fig = figure();
            set(fig, 'visible', 'off');
            hold('on')
            plot(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
            %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
            plot(electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'r.', 'MarkerSize', 20);
            plot(electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'b.', 'MarkerSize', 20);
            plot(electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time == electrode_data(min_electrode_beat_stdev_indx).ave_activation_time), 'k.', 'MarkerSize', 20);

            peak_indx = find(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time >= electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time);
            peak_indx = peak_indx(1);
            t_wave_peak = electrode_data(min_electrode_beat_stdev_indx).average_waveform(peak_indx);
            plot(electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, t_wave_peak, 'c.', 'MarkerSize', 20);

            legend('signal', 'max depol', 'min depol', 'act. time', 'repol. recovery', 'location', 'northeastoutside')
            title({electrode_data(min_electrode_beat_stdev_indx).electrode_id},  'Interpreter', 'none')
            savefig(fullfile(save_dir, 'GE_figures',  electrode_data(min_electrode_beat_stdev_indx).electrode_id));
            saveas(fig, fullfile(save_dir, 'GE_images',  electrode_data(min_electrode_beat_stdev_indx).electrode_id), 'png')
            hold('off')
            close(fig)
        end
        
        well_FPDs = well_FPDs(~isnan(well_FPDs));
        well_slopes = well_slopes(~isnan(well_slopes));
        well_amps = well_amps(~isnan(well_amps));
        well_bps = well_bps(~isnan(well_bps));
        
        mean_FPD = mean(well_FPDs);
        mean_slope = mean(well_slopes);
        mean_amp = mean(well_amps);
        mean_bp = mean(well_bps);
        
        if strcmp(well_electrode_data(w).spon_paced, 'spon')
            FPDc_fridericia = mean_FPD/((mean_bp)^(1/3));
            FPDc_bazzet = mean_FPD/((mean_bp)^(1/2));
            
            headings = {'Analysis Wide Statistics'; 'mean FPD (s)'; 'FPDc Fridericia (s)'; 'FPDc Bazzet (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
            mean_data = [mean_FPD; FPDc_fridericia; FPDc_bazzet; mean_slope; mean_amp; mean_bp];
            
        else
        
            headings = {'Analysis Wide Statistics'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
            mean_data = [mean_FPD; mean_slope; mean_amp; mean_bp];
            
        end
        
        mean_data = num2cell(mean_data);
        mean_data = vertcat({''}, mean_data);
        %cell%disp(mean_data);
        
        well_stats = horzcat(headings, mean_data);
        %well_stats = cellstr(well_stats)
        
        %cell%disp(well_stats)
        
        %xlswrite(output_filename, well_stats, 1);
        fileattrib(output_filename, '-h +w');
        writecell(well_stats, output_filename, 'Sheet', 1);
        
        close(wait_bar)
        msgbox(strcat('Saved Golden Electrode Results', {' '}, 'to', {' '}, output_filename));
        set(ge_results_fig, 'visible', 'on')
    end

    

end