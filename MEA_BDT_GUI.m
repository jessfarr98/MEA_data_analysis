function MEA_BDT_GUI(raw_file, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis)
%  Create and then hide the UI as it is being constructed.

%% TO DO
% Run button
% General parameters like max and min beat period, post-spike hold-off.
% Increase scroll capacity past screen limits



    %{
   f = figure('Visible','off','Position',[360,500,450,285]);
   
   % Construct the components.
    hsurf    = uicontrol('Style','pushbutton',...
                 'String','Surf','Position',[315,220,70,25],...
                 'Callback',@surfbutton_Callback);


    ha = axes('Units','pixels','Position',[50,60,200,185]);
    align(hsurf,'Center','None');

   
   % Make the UI visible.
   % Initialize the UI.
   % Change units to normalized so components resize automatically.
   f.Units = 'normalized';
   ha.Units = 'normalized';
   hsurf.Units = 'normalized';
   %}

   % Generate the data to plot.   
   %raw_file = fullfile('Y:', 'Recordings for Jess', 'cardiac paced_paced ME 600us(000).raw');
   RawFileData = AxisFile(raw_file);
    
   RawData = RawFileData.DataSets.LoadData;

   shape_data = size(RawData);
    
   num_well_rows = shape_data(1);
   num_well_cols = shape_data(2);
   num_electrode_rows = shape_data(3);
   num_electrode_cols = shape_data(4);
    
   %{
   num_well_rows = 1;
   num_well_cols = 2;
   num_electrode_rows = 1;
   num_electrode_cols = 1;
   %}
    
   screen_size = get(groot, 'ScreenSize');
   screen_width = screen_size(3);
   screen_height = screen_size(4)-100;
   
   
   count = 0;
   well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
   
   
   bdt_fig = uifigure;
   bdt_fig.Name = 'MEA BDT GUI';
   % left bottom width height
   main_pan = uipanel(bdt_fig, 'Position', [0 0 screen_width screen_height]);
   main_pan.Scrollable = 'on';
   
   run_button = uibutton(main_pan,'push','Text', 'Run MEA Analysis', 'Position',[screen_width-190 10 80 40], 'ButtonPushedFcn', @(run_button,event) runButtonPushed(run_button));
   clear_all_bdt_button = uibutton(main_pan,'push','Text', 'Clear All BDTs', 'Position',[screen_width-190, 60, 80, 40], 'ButtonPushedFcn', @(clear_all_bdt_button,event) clearAllBDTPushed(clear_all_bdt_button, run_button));
   clear_all_t_wave_durations_button = uibutton(main_pan,'push','Text', 'Clear All T-Wave Durations', 'Position',[screen_width-190, 110, 80, 40], 'ButtonPushedFcn', @(clear_all_t_wave_durations_button, event) clearAllTWavesPushed(clear_all_t_wave_durations_button));
   set(run_button, 'Visible', 'off');
   set(clear_all_bdt_button, 'Visible', 'off');
   set(clear_all_t_wave_durations_button, 'Visible', 'off');
   
   p = uipanel(main_pan, 'Position', [0 0 screen_width-200 screen_height]);
   p.Scrollable = 'on';   
   
   %ax = uiaxes(bdt_fig);
   
   %figure();
   
   well_bdt_ui_array = [];
   well_bdt_array = [];
   sub_panel_array = [];
   well_bdt_text_array = [];
   
   
   for w_r = 1:num_well_rows
       for w_c = 1:num_well_cols
          count = count + 1;
          wellID = strcat(well_dictionary(w_r), '_0', string(w_c));
          %
          disp(wellID)
          % left bottom width height
          disp(screen_height/num_well_rows);
          sub_p = uipanel(p, 'Title', wellID, 'FontSize', 10,'Position', [((w_c-1)*((screen_width-200)/num_well_cols)) ((w_r-1)*(screen_height/num_well_rows)) (screen_width-200)/num_well_cols screen_height/num_well_rows]);
          disp(strcat('X coord', string(((w_c-1)*((screen_width-200)/num_well_cols)))));
          disp(strcat('Y coord', string(((w_r-1)*(screen_height/num_well_rows)))));
          sub_p.Scrollable = 'off';
          sub_p.AutoResizeChildren = 'off';
          sub_ax = uiaxes(sub_p, 'Position', [2 15 ((screen_width-200)/num_well_cols)-10 (screen_height/num_well_rows)-19]);
          hold(sub_ax,'on');
          %disp(wellID)
          %disp(sub_p);
          
          sub_panel_array = [sub_panel_array; sub_p];
          
          well_bdt_text = uieditfield(sub_p,'Text', 'Value', strcat(wellID, {' '}, 'BDT'), 'FontSize', 5, 'Position', [2 12 ((screen_width-200)/num_well_cols)/3 10], 'Editable','off');
          well_bdt_ui = uieditfield(sub_p, 'numeric', 'Tag', 'BDT', 'Position', [2 2 ((screen_width-200)/num_well_cols)/3 10], 'FontSize', 5, 'ValueChangedFcn',@(well_bdt_ui,event) changeBDT(well_bdt_ui, well_bdt_array, w_r*w_c, p, clear_all_bdt_button, run_button));
          
          t_wave_up_down_text = uieditfield(sub_p, 'Text', 'Value', strcat(wellID, {' '}, 'T-wave shape'), 'FontSize', 5,'Position', [(((screen_width-200)/num_well_cols)/3)+2 12 ((screen_width-200)/num_well_cols)/3 10], 'Editable','off');
          t_wave_up_down_dropdown = uidropdown(sub_p, 'Items', {'monophasic downwards', 'monophaic upwards', 'biphasic'}, 'FontSize', 5,'Position', [(((screen_width-200)/num_well_cols)/3)+2 2 ((screen_width-200)/num_well_cols)/3 10]);
          t_wave_up_down_dropdown.ItemsData = [1 2 3];
          %well_bdt_ui_array = [well_bdt_ui_array ; well_bdt_ui];
          
          t_wave_duration_text = uieditfield(sub_p,'Text', 'Value', strcat(wellID, {' '}, 'T-wave duration'), 'FontSize', 7, 'Position', [(((screen_width-200)/num_well_cols)/3)*2+2 12 ((screen_width-200)/num_well_cols)/3 10], 'Editable','off');
          t_wave_duration_ui = uieditfield(sub_p, 'numeric', 'Tag', 'T-Wave', 'Position', [(((screen_width-200)/num_well_cols)/3)*2+2 2 ((screen_width-200)/num_well_cols)/3 10], 'FontSize', 7, 'ValueChangedFcn',@(t_wave_duration_ui,event) changeTWaveDuration(t_wave_duration_ui, p, clear_all_t_wave_durations_button, run_button));
          
          time_offset = 0;
          for e_r = 1:num_electrode_rows
             for e_c = 1:num_electrode_cols
                RawWellData = RawData{w_r, w_c, e_r, e_c};
                if (strcmp(class(RawWellData),'Waveform'))
                    %if ~empty(WellRawData)
                    %disp(num_well_rows*num_well_cols)
                    %disp(count)
                    electrode_id = strcat(wellID, '_', string(e_r), '_', string(e_c));
                    [time, data] = RawWellData.GetTimeVoltageVector;
                    time = time + time_offset;
                    data = data*1000;
                    %plot(time, data);
                    plot(sub_ax,time,data);
                    %title(sub_ax, wellID);
                    %pause(10)
                    %plot(time, data);
                    time_offset = time_offset+0.015;
                    %hold on;
                else
                    disp(wellID)
                    disp('no data');
                end
             end
          end
          hold(sub_ax,'off');
          %well_bdt = well_dt_ui.Value;
          %well_bdt_array = [well_bdt_array; well_bdt];
          %subplot(num_well_rows, num_well_cols, count)
       end
   end
   %disp('Plotting')
   
   function changeBDT(well_bdt_ui, well_bdt_ui_array, well_num, p, clear_all_bdt_button, run_button)
       %disp('function entered')
       %disp(length(well_bdt_ui_array))
       %disp(get(p, 'Children'))
       
       %% BDT CANNOT be equal to 0. 
       if get(well_bdt_ui, 'Value') == 0
           msgbox('BDT cannot be equal to 0','Oops!');
           return;
       end
       
       panel_sub_panels = get(p, 'Children');
       found_zero = 0;
       for i = 1:length(panel_sub_panels)
           %{
           well_bdt_ui_array(i).Value = well_bdt_ui_array(well_num).Value;
           disp('Value')
           disp(well_bdt_ui_array(i).Value)
           %}
           sub_pan = panel_sub_panels(i);
           sub_p_ui_controls = get(sub_pan, 'Children');
           
           %disp(sub_p_ui_controls);
           %disp(get(well_bdt_ui, 'Value'));
           for j = 1:length(sub_p_ui_controls)
               %{
               if ~strcmp(string(get(sub_p_ui_controls(j), 'Value')), 'BDT')
                   set(sub_p_ui_controls(j), 'Value', get(well_bdt_ui, 'Value'));
                   
               end
               %}
               %disp(get(sub_p_ui_controls(j), 'Value'))
               %disp(sub_p_ui_controls(j))
               %disp('type')
               %disp(get(sub_p_ui_controls(j), 'Type'))
               %if strcmp(string(get(sub_p_ui_controls(j), 'Type')), 'uinumericeditfield')
               if strcmp(string(get(sub_p_ui_controls(j), 'Tag')), 'BDT')    
                   disp('BDT');
                   bdt_ui_ctrl = sub_p_ui_controls(j);
                   
                   if (get(bdt_ui_ctrl, 'Value')) == 0
                      found_zero = 1;
                      set(bdt_ui_ctrl, 'Value', get(well_bdt_ui, 'Value'));
                      set(clear_all_bdt_button, 'Visible', 'on');
                      set(run_button, 'Visible', 'on');
                   end
                   %disp('value');
                   %disp(get(sub_p_ui_controls(j), 'Value'))
                   %if strcmp(get(sub_p_ui_controls(j), 'Value'), 'BDT') == 0
                   %{
                   if ~contains(get(sub_p_ui_controls(j), 'Value'), 'BDT') && ~contains(get(sub_p_ui_controls(j), 'Value'), 'T-wave')
                      %disp('set bdt')
                      bdt_ui_ctrl = sub_p_ui_controls(j);
                      %{
                      if strcmp(get(sub_p_ui_controls(j), 'Value'), '')
                         set(sub_p_ui_controls(j), 'Value', get(well_bdt_ui, 'Value'));
                      end
                      %}
                   end   
                   %}

               elseif strcmp(string(get(sub_p_ui_controls(j), 'Type')), 'axes')
                   
                   axes_ctrl = sub_p_ui_controls(j);
                   
               end
           end
           %disp('value')
           %disp(get(bdt_ui_ctrl, 'Value'));
           %{
           if (get(bdt_ui_ctrl, 'Value')) == 0
              found_zero = 1;
              set(bdt_ui_ctrl, 'Value', get(well_bdt_ui, 'Value'));
           end
           %}
           %disp('axes')
           %disp(axes_ctrl)
           
           if found_zero == 1
               axes_children = get(axes_ctrl, 'Children');
               %disp(length(axes_children(1).XData));
               time_data = linspace(0, axes_children(1).XData(end), length(axes_children(1).XData));
               bdt_data = ones(length(axes_children(1).XData), 1);
               %disp(get(well_bdt_ui, 'Value'));
               %disp(size(bdt_data))
               bdt_data(:,1) = get(well_bdt_ui, 'Value');
               hold(axes_ctrl, 'on');
               plot(axes_ctrl, time_data, bdt_data);
               hold(axes_ctrl, 'off');
           end
           
           
       end
       
       if found_zero == 0
           % Create BDT plot for just this well
           
           well_ui_parents = get(well_bdt_ui, 'Parent');
           sub_p_ui_controls = get(well_ui_parents, 'Children');
           
           %disp(sub_p_ui_controls);
           %disp(get(well_bdt_ui, 'Value'));
           for j = 1:length(sub_p_ui_controls)
               %{
               if ~strcmp(string(get(sub_p_ui_controls(j), 'Value')), 'BDT')
                   set(sub_p_ui_controls(j), 'Value', get(well_bdt_ui, 'Value'));
                   
               end
               %}
               %disp(get(sub_p_ui_controls(j), 'Value'))
               %disp(sub_p_ui_controls(j))
               %disp('type')
               %disp(get(sub_p_ui_controls(j), 'Type'))
               

               if strcmp(string(get(sub_p_ui_controls(j), 'Type')), 'axes')
                   
                   axes_ctrl = sub_p_ui_controls(j);
                   
               end
           end
           %disp('value')
           %disp(get(bdt_ui_ctrl, 'Value'));
           %{
           if (get(bdt_ui_ctrl, 'Value')) == 0
              found_zero = 1;
              set(bdt_ui_ctrl, 'Value', get(well_bdt_ui, 'Value'));
           end
           %}
           %disp('axes')
           %disp(axes_ctrl)
           
           axes_children = get(axes_ctrl, 'Children');
           
           for c = 1:length(axes_children)
               child_y_data = axes_children(c).YData;
               if child_y_data(1) == child_y_data(:)
                   prev_bdt_plot = axes_children(c);
                   break;
               end
               
               
           end
           set(prev_bdt_plot, 'Visible', 'off');
           
           %disp(length(axes_children(1).XData));
           time_data = linspace(0, axes_children(1).XData(end), length(axes_children(1).XData));
           bdt_data = ones(length(axes_children(1).XData), 1);
           %disp(get(well_bdt_ui, 'Value'));
           %disp(size(bdt_data))
           bdt_data(:,1) = get(well_bdt_ui, 'Value');
           hold(axes_ctrl, 'on');
           plot(axes_ctrl, time_data, bdt_data);
           hold(axes_ctrl, 'off');
           
       end
       
   end

   function changeTWaveDuration(t_wave_duration_ui, p, clear_all_t_wave_durations_button, run_button)
       %disp('change T-wave duration')
       %disp('function entered')
       %disp(length(well_bdt_ui_array))
       %disp(get(p, 'Children'))
       
       %% BDT CANNOT be equal to 0. 
       if get(t_wave_duration_ui, 'Value') == 0
           msgbox('T-Wave duration cannot be equal to 0','Oops!');
           return;
       end
       
       panel_sub_panels = get(p, 'Children');
       for i = 1:length(panel_sub_panels)
           
           sub_pan = panel_sub_panels(i);
           sub_p_ui_controls = get(sub_pan, 'Children');
           
           for j = 1:length(sub_p_ui_controls)
               if strcmp(string(get(sub_p_ui_controls(j), 'Tag')), 'T-Wave')    
                   t_wave_ui_ctrl = sub_p_ui_controls(j);
                   
                   if (get(t_wave_ui_ctrl, 'Value')) == 0
                      set(t_wave_ui_ctrl, 'Value', get(t_wave_duration_ui, 'Value'));
                      set(clear_all_t_wave_durations_button, 'Visible', 'on');
                      set(run_button, 'Visible', 'on');
                   end
               end


           end
           
           
       end
       
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

   function runButtonPushed(run_button)
      disp('run')
      %% Go through each subplots inputs and run analysis per parameters
      %analyse_MEA_signals(raw_file, beat_to_beat, 'paced', well_thresholding, 1)
      %% Now create GUI with plots and BDT thresholds
   end

   function clearAllTWavesPushed(clear_all_t_wave_durations_button)
       %disp('clear t-waves pushed')

       panel_sub_panels = get(p, 'Children');
      
       for i = 1:length(panel_sub_panels)

           sub_pan = panel_sub_panels(i);
           sub_p_ui_controls = get(sub_pan, 'Children');
           
           for j = 1:length(sub_p_ui_controls)

               if strcmp(string(get(sub_p_ui_controls(j), 'Tag')), 'T-Wave')    
                   %disp('BDT');
                   bdt_ui_ctrl = sub_p_ui_controls(j);
  
                   set(bdt_ui_ctrl, 'Value', 0);
                   set(clear_all_t_wave_durations_button, 'Visible', 'off');
                   set(run_button, 'Visible', 'off');
                   
               end
           end
           
                      
       end
       
   end
   %{
   count = 0;
   for w_r = 1:num_well_rows
       for w_c = 1:num_well_cols
          count = count + 1;
          wellID = strcat(well_dictionary(w_r), '_0', string(w_c));
          
          sub_p = sub_panel_array(w_r*w_c);
          sub_ax = uiaxes(sub_p, 'Position', [10 60 160 130]);
          hold(sub_ax,'on');
          %sub_ax = subplot(num_well_rows, num_well_cols, count, 'Parent', sub_p, 'Position', [10 50 160 120]);
          %disp(wellID)
          %disp(sub_p);
          %well_bdt = well_dt_ui.Value;
          %well_bdt_array = [well_bdt_array; well_bdt];
          %subplot(num_well_rows, num_well_cols, count)
          %disp(wellID);
          %fig = figure();
          time_offset = 0;
          for e_r = 1:num_electrode_rows
             for e_c = 1:num_electrode_cols
                RawWellData = RawData{w_r, w_c, e_r, e_c};
                if (strcmp(class(RawWellData),'Waveform'))
                    %if ~empty(WellRawData)
                    %disp(num_well_rows*num_well_cols)
                    %disp(count)
                    electrode_id = strcat(wellID, '_', string(e_r), '_', string(e_c));
                    [time, data] = RawWellData.GetTimeVoltageVector;
                    time = time + time_offset;
                    data = data*1000;
                    %plot(time, data);
                    plot(sub_ax,time,data);
                    title(sub_ax, wellID);
                    %pause(10)
                    %plot(time, data);
                    time_offset = time_offset+0.015;
                    hold on;
                else
                    disp(wellID)
                    disp('no data');
                end
             end
          end
          hold(sub_ax,'off');
       end
   end
   %}

   
  
   %plot(ax,time,data);
   
   
   %{
   % Move the window to the center of the screen.
   movegui(bdt_fig,'center')
   
   %p = uipanel(fig,'Position',[20 20 196 135]);
   
   beat_to_beat = '';
   well_thresholding = '';
   
   b2b_options_text = uieditfield(bdt_fig,'Text','Position',[410 230 140 22], 'Value','Beat2Beat Options');
   b2b_options_dropdown = uidropdown(bdt_fig, 'Items', {'all', 'time region'},'Position',[410 205 140 22], 'ValueChangedFcn',@(b2bdropdown,event) b2bdropdown_menu_Callback(b2bdropdown, beat_to_beat));
   b2b_options_dropdown.ItemsData = [1 2];
   
   stable_options_text = uieditfield(bdt_fig,'Text','Position',[410 180 140 22], 'Value','Stable/Average');
   stable_options_dropdown = uidropdown(bdt_fig, 'Items', {'golden electrode', 'average'},'Position',[410 155 140 22], 'ValueChangedFcn',@(b2bdropdown,event) b2bdropdown_menu_Callback(b2bdropdown, beat_to_beat));
   stable_options_dropdown.ItemsData = [1 2];
   set(stable_options_text,'Visible','off')
   set(stable_options_dropdown,'Visible','off')
   
   %b2btext  = uidropdown(fig, 'Style','text','String','Beat2Beat Analysis',... 'Position',[325,90,60,15]);
   b2btext = uieditfield(bdt_fig,'Text','Position',[410 140 140 22], 'Value','Beat2Beat');
   b2bdropdown = uidropdown(bdt_fig, 'Items', {'on', 'off'}, 'Position',[410 115 140 22], 'ValueChangedFcn',@(b2bdropdown,event) b2bdropdown_menu_Callback(b2bdropdown, beat_to_beat, bdt_fig, b2b_options_text, b2b_options_dropdown, stable_options_text, stable_options_dropdown));
   b2bdropdown.ItemsData = [1 2];
   
   paced_spon_text = uieditfield(bdt_fig,'Text','Position',[410 90 140 22], 'Value','Paced/Spontaneous');
   paced_spon_options_dropdown = uidropdown(bdt_fig, 'Items', {'paced', 'spontaneous'},'Position',[410 65 140 22], 'ValueChangedFcn',@(b2bdropdown,event) b2bdropdown_menu_Callback(b2bdropdown, beat_to_beat));
   paced_spon_options_dropdown.ItemsData = [1 2];
     
   %well_thresh_text  = (p, 'Style','text','String','Well Specific Thresholding',... 'Position',[325,90,60,15]);
   %well_thresh_text = uieditfield(fig,'Text','Position',[410 90 140 22], 'Value','Well Thresholding');
   %well_thresh_dropdown = uidropdown(fig, 'Items', {'on', 'off'},'Position',[410 65 140 22], 'ValueChangedFcn',@(well_thresh_dropdown,event) well_thresh_popup_menu_Callback(well_thresh_dropdown, well_thresholding));

   run_button = uibutton(bdt_fig,'push','Text', 'Run Analysis', 'Position',[410, 380, 140, 22], 'ButtonPushedFcn', @(run_button,event) runButtonPushed(run_button, raw_file, b2b_options_dropdown, stable_options_dropdown, b2bdropdown, paced_spon_options_dropdown, bdt_fig));
   
   function b2bdropdown_menu_Callback(b2bdropdown,beat_to_beat, bdt_fig, b2b_options_text, b2b_options_dropdown, stable_options_text, stable_options_dropdown) 
      beat_to_beat = b2bdropdown.Value;
      if beat_to_beat == 1
          disp('b2b on')
          beat_to_beat = 'on';
          set(b2b_options_text,'Visible','on')
          set(b2b_options_dropdown,'Visible','on')
          
          set(stable_options_text,'Visible','off')
          set(stable_options_dropdown,'Visible','off')
          
          %try and make it dynamically add this if it can
          %{
          bdt_fig.b2b_options_text = uieditfield(bdt_fig,'Text','Position',[410 90 140 22], 'Value','Beat2Beat Options');
          bdt_fig.b2b_options_dropdown = uidropdown(bdt_fig, 'Items', {'all', 'time region'},'Position',[410 65 140 22], 'ValueChangedFcn',@(b2bdropdown,event) b2bdropdown_menu_Callback(b2bdropdown, beat_to_beat));
          %}
      else
          disp('b2b off')
          set(b2b_options_text,'Visible','off')
          set(b2b_options_dropdown,'Visible','off')
          
          set(stable_options_text,'Visible','on')
          set(stable_options_dropdown,'Visible','on')
          
      end
              
   end

   %{
   function well_thresh_popup_menu_Callback(well_thresh_dropdown,well_thresholding) 
      % Determine the selected data set.
      well_thresholding = well_thresh_dropdown.Value;
   end
   %}

   function runButtonPushed(run_button, raw_file, b2b_options_dropdown, stable_options_dropdown, b2bdropdown, paced_spon_options_dropdown, bdt_fig)
      disp('worked')
      disp(b2bdropdown.Value);
      disp(stable_options_dropdown.Value);
      disp(b2b_options_dropdown.Value);
      disp(paced_spon_options_dropdown.Value);
      set(bdt_fig, 'Visible', 'off')
      %analyse_MEA_signals(raw_file, beat_to_beat, 'paced', well_thresholding, 1)
      
      %% Now create GUI with plots and BDT thresholds
   end
   %}
   
end





%{
APP DESIGN
MENU
- Enter desired file location when running app in inputs
- dropdowns for paced/spon, b2b, well_thresh
- RUN button

-- IDEA: REMOVE WELL_THRESHOLDING OPTIONAL - USERS REQUIRED TO ENTER BDT FOR ALL WELLS.
 All boxes start out empty then once the user types into the
 first box it fills out the rest. After this the user can then edit as they
 see fit without it auto-entering the text boxes for the rest of the wells.

RUN INITIALISATION MENU 
- Present with subplots for each well - electrodes overlaid
- Underneath each panel is a type-in box to write the BDT, T-wave up/down, T-wave search duration for each well
- CONTINUE button - when pressed it then extracts the beats

-- beat to beat = 'on'
    CREATE DROPDOWN WITH:
    - analyse 'all'
        no further additions
    - analyse 'time_region'
        additional text boxes for time regions - auto enters after editing
        first box
-- beat_to_beat = 'off'
    CREATE DROPDOWN WITH:
    - 'stable'
    - 'average'















%}
