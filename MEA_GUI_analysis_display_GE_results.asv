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
    movegui(out_fig,'center')
    out_fig.WindowState = 'maximized';
    % left bottom width height
    main_p = uipanel(out_fig, 'BackgroundColor', '#e68e8e', 'Position', [0 0 screen_width screen_height]);
    
    close_all_button = uibutton(main_p,'push', 'BackgroundColor', '#B02727', 'Text', 'Close', 'Position', [screen_width-180 100 120 50], 'ButtonPushedFcn', @(close_all_button,event) closeAllButtonPushed(close_all_button, out_fig));
    accept_GE_button = uibutton(main_p,'push', 'BackgroundColor', '#3dd4d1','Text', 'Accept Golden Electrodes', 'Position', [screen_width-180 200 120 50], 'ButtonPushedFcn', @(accept_GE_button,event) acceptGEButtonPushed(accept_GE_button, out_fig));
            
    
    
    main_pan = uipanel(main_p, 'Title', 'Review Well Results', 'Position', [0 0 button_panel_width screen_height-40]);
    
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
                stable_button = uibutton(button_panel,'push','BackgroundColor', '#B02727', 'Text', strcat(wellID, {' '}, 'Show Electrode Stable Waveforms'), 'Position', [0 0 button_width/3 button_height], 'ButtonPushedFcn', @(stable_button,event) stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(button_count).electrode_data, change_GE_dropdown));
                average_button = uibutton(button_panel,'push','BackgroundColor', '#d43d3d', 'Text', strcat(wellID, {' '}, 'Show Electrode Average Waveforms'), 'Position', [button_width/3 0 button_width/3 button_height], 'ButtonPushedFcn', @(average_button,event) averageElectrodesButtonPushed(average_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(button_count).electrode_data, change_GE_dropdown));

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

            change_GE_button = uibutton(button_panel,'push','BackgroundColor', '#e37f7f', 'Text', strcat('Change', {' '}, wellID, {' '},'Golden Electrode'), 'Position', [2*(button_width/3) 0 button_width/3 button_height], 'ButtonPushedFcn', @(change_GE_button,event) changeGEButtonPushed(change_GE_button, added_wells, change_GE_text, change_GE_dropdown, button_panel));

            %stable_button = uibutton(button_panel,'push','BackgroundColor', '#B02727', 'Text', strcat(wellID, {' '}, 'Show Electrode Stable Waveforms'), 'Position', [0 0 button_width/3 button_height], 'ButtonPushedFcn', @(stable_button,event) stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(b, :), change_GE_dropdown));
            %average_button = uibutton(button_panel,'push','BackgroundColor', '#d43d3d', 'Text', strcat(wellID, {' '}, 'Show Electrode Average Waveforms'), 'Position', [button_width/3 0 button_width/3 button_height], 'ButtonPushedFcn', @(average_button,event) averageElectrodesButtonPushed(average_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(b, :), change_GE_dropdown));
            stable_button = uibutton(button_panel,'push','BackgroundColor', '#B02727', 'Text', strcat(wellID, {' '}, 'Show Electrode Stable Waveforms'), 'Position', [0 0 button_width/3 button_height], 'ButtonPushedFcn', @(stable_button,event) stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(b).electrode_data, change_GE_dropdown));
            average_button = uibutton(button_panel,'push','BackgroundColor', '#d43d3d', 'Text', strcat(wellID, {' '}, 'Show Electrode Average Waveforms'), 'Position', [button_width/3 0 button_width/3 button_height], 'ButtonPushedFcn', @(average_button,event) averageElectrodesButtonPushed(average_button, added_wells, num_electrode_rows, num_electrode_cols, well_electrode_data(b).electrode_data, change_GE_dropdown));
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

    function stableElectrodesButtonPushed(stable_button, added_wells, num_electrode_rows, num_electrode_cols, electrode_data, change_GE_dropdown)
        well_ID = get(stable_button, 'Text');
        well_ID = regexp(well_ID, ' ', 'split');
        well_ID = well_ID{1};
        
        well_elec_fig = uifigure;
        movegui(well_elec_fig,'center')
        well_elec_fig.WindowState = 'maximized';
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
            non_zero_stddevs = find(min_stdevs ~=0);
            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
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
                %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
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
        %%disp(well_ID)
        
        well_elec_fig = uifigure;
        movegui(well_elec_fig,'center')
        well_elec_fig.WindowState = 'maximized';
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
            non_zero_stddevs = find(min_stdevs ~=0);
            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs(non_zero_stddevs)), 1);
        end
        GE_pan = uipanel(main_well_pan, 'Title', "Golden Electrode" + " " + electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position', [well_p_width screen_height-450 300 300]);
        
        GE_ax = uiaxes(GE_pan, 'Position', [0 0 300 300]);
        
        
        hold(GE_ax,'on')
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
        %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'ro');
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'bo');
        plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time == electrode_data(min_electrode_beat_stdev_indx).ave_activation_time), 'ko');
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
                %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
                elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
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
                    plot(elec_ax, electrode_data(electrode_count).ave_activation_time, electrode_data(electrode_count).average_waveform(electrode_data(electrode_count).ave_wave_time == electrode_data(electrode_count).ave_activation_time), 'ko');
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
        view_overlaid_button = uibutton(main_well_pan,'push','Text', 'View Overlaid Plots', 'Position', [screen_width-220 200 120 50], 'ButtonPushedFcn', @(view_overlaid_button,event) viewOverlaidButtonPushed(view_overlaid_button, well_elec_fig, min_electrode_beat_stdev_indx));
        
        
        
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
                            plot_col = '#e9b316';
                        else
                            plot_col = 'blue';
                        end
                        plot(overlaid_ax, electrode_data(electrode_count).ave_wave_time-electrode_data(electrode_count).ave_activation_time, electrode_data(electrode_count).average_waveform, 'Color', plot_col);
                        %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                        plot(overlaid_ax, electrode_data(electrode_count).ave_max_depol_time-electrode_data(electrode_count).ave_activation_time, electrode_data(electrode_count).ave_max_depol_point, 'ro');
                        plot(overlaid_ax, electrode_data(electrode_count).ave_min_depol_time-electrode_data(electrode_count).ave_activation_time, electrode_data(electrode_count).ave_min_depol_point, 'bo');
                        
                        
                        plot(overlaid_ax, 0, electrode_data(electrode_count).average_waveform(electrode_data(electrode_count).ave_wave_time == electrode_data(electrode_count).ave_activation_time), 'ko');
                        peak_indx = find(electrode_data(electrode_count).ave_wave_time >= electrode_data(electrode_count).ave_t_wave_peak_time);
                        peak_indx = peak_indx(1);
                        t_wave_peak = electrode_data(electrode_count).average_waveform(peak_indx);

                        plot(overlaid_ax, electrode_data(electrode_count).ave_t_wave_peak_time-electrode_data(electrode_count).ave_activation_time, t_wave_peak, 'co');
                    end
                end
            end
            hold(overlaid_ax, 'off')
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
        ge_results_fig.WindowState = 'maximized';
        ge_results_fig.Name = 'Golden Electrode Results';
        % left bottom width height
        main_ge_pan = uipanel(ge_results_fig, 'Position', [0 0 screen_width screen_height]);
        
        back_GE_button = uibutton(main_ge_pan,'push','Text', 'Back', 'Position', [screen_width-220 450 100 50], 'ButtonPushedFcn', @(back_GE_button,event) backButtonPushed(ge_results_fig, out_fig));
            
        %display_results_button = uibutton(main_ge_pan,'push', 'BackgroundColor', '#3dd483','Text', 'Show Results', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(display_results_button,event) displayGEResultsPushed(display_results_button, ge_results_fig));
        
        save_button = uibutton(main_ge_pan,'push',  'BackgroundColor', '#3dd4d1', 'Text', 'Save', 'Position', [screen_width-220 300 100 50], 'ButtonPushedFcn', @(save_button,event) saveGEPushed(save_button, ge_results_fig, save_dir, num_electrode_rows, num_electrode_cols, dropdown_array));
        close_button = uibutton(main_ge_pan,'push','Text', 'Close', 'Position', [screen_width-220 50 120 50], 'ButtonPushedFcn', @(close_button,event) closeAllButtonPushed(close_button, ge_results_fig));
            
        
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
                   
                   ge_panel = uipanel(ge_pan, 'Title', electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position',[((ge_c-1)*button_w) ((ge_r-1)*button_h) button_w button_h]);
                   
                   GE_ax = uiaxes(ge_panel,  'Position', [0 40 button_w button_h-40]);
                   
                   hold(GE_ax,'on')
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                   %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'ro');
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'bo');
                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time == electrode_data(min_electrode_beat_stdev_indx).ave_activation_time), 'ko');

                   peak_indx = find(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time >= electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time);
                   peak_indx = peak_indx(1);
                   t_wave_peak = electrode_data(min_electrode_beat_stdev_indx).average_waveform(peak_indx);

                   plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, t_wave_peak, 'co');

                   %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
                   %plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');
                   hold(GE_ax,'off')
                   undo_reject_ge_panel = uipanel(ge_pan, 'Title', electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position', [((ge_c-1)*button_w) ((ge_r-1)*button_h) button_w button_h]);
                   undo_reject_well_button = uibutton(undo_reject_ge_panel,'push','Text', 'Undo Reject Well', 'Position', [0 0 button_w button_h], 'ButtonPushedFcn', @(undo_reject_well_button,event) undoRejectGEWellPushed(undo_reject_ge_panel, ge_panel, ge_count, undo_reject_ge_panel));
                   if well_electrode_data(ge_count).rejected_well == 1
                        set(undo_reject_ge_panel, 'visible', 'on')
                   else
                        set(undo_reject_ge_panel, 'visible', 'off')
                   end
                
                   t_wave_time_text = uieditfield(ge_panel,'Text', 'Value', 'T-wave Peak Time', 'FontSize', 8, 'Position', [0 0 (button_w/2)-25 20], 'Editable','off');
                   t_wave_time_ui = uieditfield(ge_panel, 'numeric', 'Tag', 'T-Wave', 'Position', [button_w/2 0 (button_w/2)-25 20], 'FontSize', 8, 'ValueChangedFcn',@(t_wave_time_ui,event) changeGETWaveTime(t_wave_time_ui, GE_ax, ge_count, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform, min_electrode_beat_stdev_indx));

                   manual_t_wave_button = uibutton(ge_panel,'push','Text', 'Manual T-Wave Peak Input', 'Position', [0 20 (button_w/2)-25 20], 'ButtonPushedFcn', @(manual_t_wave_button,event) manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui));
                   
                   reject_well_button = uibutton(ge_panel,'push','Text', 'Reject Well', 'Position', [(button_w/2)-25 20 (button_w/2)-25 20], 'ButtonPushedFcn', @(reject_well_button,event) rejectGEWellPushed(reject_well_button, ge_panel, ge_count, undo_reject_ge_panel));
                   
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
                
                ge_panel = uipanel(ge_pan, 'Title', electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position', [((ge-1)*button_w) 0 button_w button_h]);
                
                GE_ax = uiaxes(ge_panel,  'Position', [0 40 button_w button_h-40]);
                
                hold(GE_ax,'on')
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'ro');
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'bo');
                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time == electrode_data(min_electrode_beat_stdev_indx).ave_activation_time), 'ko');

                peak_indx = find(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time >= electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time);
                peak_indx = peak_indx(1);
                t_wave_peak = electrode_data(min_electrode_beat_stdev_indx).average_waveform(peak_indx);

                plot(GE_ax, electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, t_wave_peak, 'co');

                t_wave_time_text = uieditfield(ge_panel,'Text', 'Value', 'T-wave Peak Time', 'FontSize', 8, 'Position', [0 0 (button_w/2)-25 20], 'Editable','off');
                t_wave_time_ui = uieditfield(ge_panel, 'numeric', 'Tag', 'T-Wave', 'Position', [button_w/2 0 (button_w/2)-25 20], 'FontSize', 8, 'ValueChangedFcn',@(t_wave_time_ui,event) changeGETWaveTime(t_wave_time_ui, GE_ax, ge, electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform, min_electrode_beat_stdev_indx));

                undo_reject_ge_panel = uipanel(ge_pan, 'Title', electrode_data(min_electrode_beat_stdev_indx).electrode_id, 'Position', [((ge-1)*button_w) 0 button_w button_h]);
                undo_reject_well_button = uibutton(undo_reject_ge_panel,'push','Text', 'Undo Reject Well', 'Position', [0 0 button_w button_h], 'ButtonPushedFcn', @(undo_reject_well_button,event) undoRejectGEWellPushed(undo_reject_ge_panel, ge_panel, ge, undo_reject_ge_panel));
                if well_electrode_data(ge).rejected_well == 1
                    set(undo_reject_ge_panel, 'visible', 'on')
                else
                    set(undo_reject_ge_panel, 'visible', 'off')
                end
                
               
                manual_t_wave_button = uibutton(ge_panel,'push','Text', 'Manual T-Wave Peak Input', 'Position', [0 20 (button_w/2)-25 20], 'ButtonPushedFcn', @(manual_t_wave_button,event) manualTwavePeakButtonPushed(manual_t_wave_button, t_wave_time_text, t_wave_time_ui));
                reject_well_button = uibutton(ge_panel,'push','Text', 'Reject Well', 'Position', [(button_w/2)-25 20 (button_w/2)-25 20], 'ButtonPushedFcn', @(reject_well_button,event) rejectGEWellPushed(reject_well_button, ge_panel, ge, undo_reject_ge_panel));
                   
                
                
                
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

                plot(GE_ax, get(t_wave_time_ui, 'Value'), t_wave_peak, 'co');
                hold(GE_ax, 'off')

            else
                t_wave_plot.XData = get(t_wave_time_ui, 'Value');
                t_wave_plot.YData = t_wave_peak;
            end
            well_electrode_data(well_count).electrode_data(electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
            %electrode_data(electrode_count).ave_t_wave_peak_time = get(t_wave_time_ui, 'Value');
            
        end 
        
        function reanalyseGEButtonPushed(reanalyse_button, ge_results_fig, num_electrode_rows, num_electrode_cols, ge_pan, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis)

            set(ge_results_fig, 'Visible', 'off')

            reanalyse_fig = uifigure;
            movegui(reanalyse_fig,'center')
            reanalyse_fig.WindowState = 'maximized';
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
                        ra_elec_pan = uipanel(ra_pan, 'Title', re_well_ID, 'Position', [(re_ge_c-1)*(reanalyse_width/num_button_cols) (re_ge_r-1)*(reanalyse_height/num_button_rows) reanalyse_width/num_button_cols reanalyse_height/num_button_rows]);
                        if well_electrode_data(re_ge_count).rejected_well == 1
                            re_ge_count = re_ge_count+1;
                            continue
                        end
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
                    ra_elec_pan = uipanel(ra_pan, 'Title', re_well_ID, 'Position', [(re_ge-1)*(reanalyse_width/num_button_cols) 0 reanalyse_width/num_button_cols reanalyse_height]);
                    if well_electrode_data(re_ge).rejected_well == 1
                        continue
                    end
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
                %set(reanalyse_fig, 'Visible', 'off')
                close(reanalyse_fig)
                if isempty(electrode_data)
                   return; 
                end
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
        if ~exist(fullfile(save_dir, 'figures'), 'dir')
            mkdir(fullfile(save_dir, 'figures'))
        else
            rmdir(fullfile(save_dir, 'figures'), 's')
            mkdir(fullfile(save_dir, 'figures'))
        end
        if ~exist(fullfile(save_dir, 'images'), 'dir')
            mkdir(fullfile(save_dir, 'images'))
        else
            rmdir(fullfile(save_dir, 'images'), 's')
            mkdir(fullfile(save_dir, 'images'))
        end
        well_FPDs = [];
        well_slopes = [];
        well_amps = [];
        well_bps = [];
        
        sheet_count = 1;
        num_partitions = 1/(num_wells);
        partition = num_partitions;
        
        for w = 1:num_wells
            if well_electrode_data(w).rejected_well == 1
                continue
            end
            
            waitbar(partition, wait_bar, strcat('Saving Data for ', {' '}, well_electrode_data(w).wellID));
            partition = partition+num_partitions;
            
            
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
            %cell%disp(elec_id_column)
            elec_id_column = vertcat(electrode_data(min_electrode_beat_stdev_indx).electrode_id, elec_id_column);
            
            if strcmp(spon_paced, 'spon')

                stable_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).stable_beats_duration]);
                stable_duration_array = vertcat('Stable Beats Duration (s)', stable_duration_array);

                bdt_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).bdt]);
                bdt_array = vertcat('Beat Detection Threshold Input (V)', bdt_array);

                min_bp_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).min_bp]);
                min_bp_array = vertcat('Mininum Beat Period Input (s)', min_bp_array);

                max_bp_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).max_bp]);
                max_bp_array = vertcat('Maximum Beat Period Input (s)', max_bp_array);

                post_spike_hold_off_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).post_spike_hold_off]);
                post_spike_hold_off_array = vertcat('Post-spike hold-off (s)', post_spike_hold_off_array);

                t_wave_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_duration]);
                t_wave_duration_array = vertcat('T-wave Duration Input (s)', t_wave_duration_array);

                t_wave_offset_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_offset]);
                t_wave_offset_array = vertcat('T-wave offset Input (s)', t_wave_offset_array);

                %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                t_wave_shape_array = vertcat('T-wave Shape', {electrode_data(min_electrode_beat_stdev_indx).t_wave_shape});

                filter_intensity_array = vertcat('Filter Intensity', {electrode_data(min_electrode_beat_stdev_indx).filter_intensity});
                
                warning_array = vertcat('Warnings', {electrode_data(min_electrode_beat_stdev_indx).ave_warning});

                electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, stable_duration_array, bdt_array, min_bp_array, max_bp_array, post_spike_hold_off_array, t_wave_duration_array, t_wave_offset_array, t_wave_shape_array, filter_intensity_array, warning_array);

            elseif strcmp(spon_paced, 'paced')
                stable_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).stable_beats_duration]);
                stable_duration_array = vertcat('Stable Beats Duration (s)', stable_duration_array);

                stim_spike_hold_off_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).stim_spike_hold_off]);
                stim_spike_hold_off_array = vertcat('Stim-spike hold-off (s)', stim_spike_hold_off_array);

                post_spike_hold_off_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).post_spike_hold_off]);
                post_spike_hold_off_array = vertcat('Post-spike hold-off (s)', post_spike_hold_off_array);

                t_wave_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_duration]);
                t_wave_duration_array = vertcat('T-wave Duration Input (s)', t_wave_duration_array);

                t_wave_offset_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_offset]);
                t_wave_offset_array = vertcat('T-wave offset Input (s)', t_wave_offset_array);

                %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                t_wave_shape_array = vertcat('T-wave Shape', {electrode_data(min_electrode_beat_stdev_indx).t_wave_shape});
                
                filter_intensity_array = vertcat('Filter Intensity', {electrode_data(min_electrode_beat_stdev_indx).filter_intensity});

                warning_array = vertcat('Warnings', {electrode_data(min_electrode_beat_stdev_indx).ave_warning});

                electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, stable_duration_array, stim_spike_hold_off_array, post_spike_hold_off_array, t_wave_duration_array, t_wave_offset_array, t_wave_shape_array, filter_intensity_array, warning_array);


            elseif strcmp(spon_paced, 'paced bdt')
                stable_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).stable_beats_duration]);
                stable_duration_array = vertcat('Stable Beats Duration (s)', stable_duration_array);

                bdt_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).bdt]);
                bdt_array = vertcat('Beat Detection Threshold Input (V)', bdt_array);

                min_bp_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).min_bp]);
                min_bp_array = vertcat('Mininum Beat Period Input (s)', min_bp_array);

                max_bp_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).max_bp]);
                max_bp_array = vertcat('Maximum Beat Period Input (s)', max_bp_array);

                stim_spike_hold_off_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).stim_spike_hold_off]);
                stim_spike_hold_off_array = vertcat('Stim-spike hold-off (s)', stim_spike_hold_off_array);

                post_spike_hold_off_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).post_spike_hold_off]);
                post_spike_hold_off_array = vertcat('Post-spike hold-off (s)', post_spike_hold_off_array);

                t_wave_duration_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_duration]);
                t_wave_duration_array = vertcat('T-wave Duration Input (s)', t_wave_duration_array);

                t_wave_offset_array = num2cell([electrode_data(min_electrode_beat_stdev_indx).t_wave_offset]);
                t_wave_offset_array = vertcat('T-wave offset Input (s)', t_wave_offset_array);

                %t_wave_shape_array = num2cell([electrode_data(electrode_count).t_wave_shape]);
                t_wave_shape_array = vertcat('T-wave Shape', {electrode_data(min_electrode_beat_stdev_indx).t_wave_shape});
                
                filter_intensity_array = vertcat('Filter Intensity', {electrode_data(min_electrode_beat_stdev_indx).filter_intensity});

                warning_array = vertcat('Warnings', {electrode_data(min_electrode_beat_stdev_indx).ave_warning});

                
                electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods, stable_duration_array, bdt_array, min_bp_array, max_bp_array, stim_spike_hold_off_array, post_spike_hold_off_array, t_wave_duration_array, t_wave_offset_array, t_wave_shape_array, filter_intensity_array, warning_array);

            end
          


            %electrode_stats = horzcat(elec_id_column, activation_times, amps, slopes, t_wave_peak_times, t_wave_peak_array, FPDs, beat_periods);
            %electrode_stats = {[elec_id_column] [beat_num_array] [beat_start_times] [activation_times] [amps] [slopes] [t_wave_peak_times] [t_wave_peak_array] [FPDs] [beat_periods] [cycle_length_array]};
            %electrode_stats = {electrode_stats_header;electrode_stats};

            electrode_stats = cellstr(electrode_stats);

            % all_data must be a cell array
            %xlswrite(output_filename, electrode_stats, sheet_count);
            
            if sheet_count ~= 2
                fileattrib(output_filename, '-h +w');
            end
            writecell(electrode_stats, output_filename, 'Sheet', sheet_count);
            fileattrib(output_filename, '+h +w');
            
            fig = figure();
            set(fig, 'visible', 'off');
            hold('on')
            plot(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
            %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
            plot(electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_max_depol_point, 'ro');
            plot(electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_time, electrode_data(min_electrode_beat_stdev_indx).ave_min_depol_point, 'bo');
            plot(electrode_data(min_electrode_beat_stdev_indx).ave_activation_time, electrode_data(min_electrode_beat_stdev_indx).average_waveform(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time == electrode_data(min_electrode_beat_stdev_indx).ave_activation_time), 'ko');

            peak_indx = find(electrode_data(min_electrode_beat_stdev_indx).ave_wave_time >= electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time);
            peak_indx = peak_indx(1);
            t_wave_peak = electrode_data(min_electrode_beat_stdev_indx).average_waveform(peak_indx);
            plot(electrode_data(min_electrode_beat_stdev_indx).ave_t_wave_peak_time, t_wave_peak, 'co');

            legend('signal', 'max depol', 'min depol', 'act. time', 'repol. recovery', 'location', 'northeastoutside')
            title({electrode_data(min_electrode_beat_stdev_indx).electrode_id},  'Interpreter', 'none')
            savefig(fullfile(save_dir, 'figures',  electrode_data(min_electrode_beat_stdev_indx).electrode_id));
            saveas(fig, fullfile(save_dir, 'images',  electrode_data(min_electrode_beat_stdev_indx).electrode_id), 'png')
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
        
        headings = {'Analysis Wide Statistics'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'};
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
        
        close(wait_bar)
        msgbox(strcat('Saved Golden Electrode Results', {' '}, 'to', {' '}, output_filename));
        set(ge_results_fig, 'visible', 'on')
    end

    

end