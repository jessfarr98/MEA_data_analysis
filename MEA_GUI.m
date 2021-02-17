function MEA_GUI(raw_file)
%  Create and then hide the UI as it is being constructed.

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
    
   num_well_rows = 1;
   num_well_cols = 1;
   num_electrode_rows = 1;
   num_electrode_cols = 1;
    
   count = 1;
   well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    
   for w_r = 1:num_well_rows
       for w_c = 1:num_well_cols
          wellID = strcat(well_dictionary(w_r), '_0', string(w_c));
          for e_r = 1:num_electrode_rows
             for e_c = 1:num_electrode_cols
                RawWellData = RawData{w_r, w_c, e_r, e_c};
                if (strcmp(class(RawWellData),'Waveform'))
                    %if ~empty(WellRawData)
                    electrode_id = strcat(wellID, '_', string(e_r), '_', string(e_c));
                    [time, data] = RawWellData.GetTimeVoltageVector;
                    count = count + 1;
                end
             end
          end
       end
   end

   start_fig = uifigure;
   ax = uiaxes(start_fig);

   plot(ax,time,data);
   
   start_fig.Name = 'MEA GUI';

   % Move the window to the center of the screen.
   movegui(start_fig,'center')
   
   %p = uipanel(fig,'Position',[20 20 196 135]);
   
   beat_to_beat = '';
   %well_thresholding = '';
   
   b2b_options_text = uieditfield(start_fig,'Text','Position',[410 230 140 22], 'Value','Beat2Beat Options', 'Editable','off');
   b2b_options_dropdown = uidropdown(start_fig, 'Items', {'all', 'time region'},'Position',[410 205 140 22]);
   b2b_options_dropdown.ItemsData = [1 2];
   
   stable_options_text = uieditfield(start_fig,'Text','Position',[410 180 140 22], 'Value','Stable/Average', 'Editable','off');
   stable_options_dropdown = uidropdown(start_fig, 'Items', {'golden electrode', 'average'},'Position',[410 155 140 22]);
   stable_options_dropdown.ItemsData = [1 2];
   set(stable_options_text,'Visible','off')
   set(stable_options_dropdown,'Visible','off')
   
   %b2btext  = uidropdown(fig, 'Style','text','String','Beat2Beat Analysis',... 'Position',[325,90,60,15]);
   b2btext = uieditfield(start_fig,'Text','Position',[410 140 140 22], 'Value','Beat2Beat', 'Editable','off');
   b2bdropdown = uidropdown(start_fig, 'Items', {'on', 'off'}, 'Position',[410 115 140 22], 'ValueChangedFcn',@(b2bdropdown,event) b2bdropdown_menu_Callback(b2bdropdown, beat_to_beat, start_fig, b2b_options_text, b2b_options_dropdown, stable_options_text, stable_options_dropdown));
   b2bdropdown.ItemsData = [1 2];
   
   paced_spon_text = uieditfield(start_fig,'Text','Position',[410 90 140 22], 'Value','Paced/Spontaneous', 'Editable','off');
   paced_spon_options_dropdown = uidropdown(start_fig, 'Items', {'paced', 'spontaneous'},'Position',[410 65 140 22]);
   paced_spon_options_dropdown.ItemsData = [1 2];
     
   %well_thresh_text  = (p, 'Style','text','String','Well Specific Thresholding',... 'Position',[325,90,60,15]);
   %well_thresh_text = uieditfield(fig,'Text','Position',[410 90 140 22], 'Value','Well Thresholding');
   %well_thresh_dropdown = uidropdown(fig, 'Items', {'on', 'off'},'Position',[410 65 140 22], 'ValueChangedFcn',@(well_thresh_dropdown,event) well_thresh_popup_menu_Callback(well_thresh_dropdown, well_thresholding));

   run_button = uibutton(start_fig,'push','Text', 'Choose Well Inputs', 'Position',[410, 380, 140, 22], 'ButtonPushedFcn', @(run_button,event) runButtonPushed(run_button, raw_file, b2b_options_dropdown, stable_options_dropdown, b2bdropdown, paced_spon_options_dropdown, start_fig));
   
   function b2bdropdown_menu_Callback(b2bdropdown,beat_to_beat, start_fig, b2b_options_text, b2b_options_dropdown, stable_options_text, stable_options_dropdown) 
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
          start_fig.b2b_options_text = uieditfield(start_fig,'Text','Position',[410 90 140 22], 'Value','Beat2Beat Options');
          start_fig.b2b_options_dropdown = uidropdown(start_fig, 'Items', {'all', 'time region'},'Position',[410 65 140 22], 'ValueChangedFcn',@(b2bdropdown,event) b2bdropdown_menu_Callback(b2bdropdown, beat_to_beat));
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

   function runButtonPushed(run_button, raw_file, b2b_options_dropdown, stable_options_dropdown, b2bdropdown, paced_spon_options_dropdown, start_fig)
      disp('worked')
      disp(b2bdropdown.Value);
      disp(stable_options_dropdown.Value);
      disp(b2b_options_dropdown.Value);
      disp(paced_spon_options_dropdown.Value);
      
      
      if b2bdropdown.Value == 1
          beat_to_beat = 'on';
      else
          beat_to_beat = 'off';
      end
      
      if paced_spon_options_dropdown.Value == 1
          spon_paced = 'paced';
         
      else
          spon_paced = 'spon';
      end
      
      if b2b_options_dropdown.Value == 1
          analyse_all_b2b = 'all';
      else
          analyse_all_b2b = 'time_region';
      end
      
      if stable_options_dropdown.Value == 1
          stable_ave_analysis = 'stable';
      else
          stable_ave_analysis = 'time_region';
      end
      
      set(start_fig, 'Visible', 'off')
      %analyse_MEA_signals(raw_file, beat_to_beat, 'paced', well_thresholding, 1)
      MEA_BDT_GUI_V2(raw_file, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis)
      %% Now create GUI with plots and BDT thresholds
   end
   
   
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
