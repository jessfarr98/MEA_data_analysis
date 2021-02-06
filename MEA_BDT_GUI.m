function MEA_BDT_GUI(raw_file, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis)
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
   num_well_cols = 2;
   num_electrode_rows = 1;
   num_electrode_cols = 1;
   
    
   count = 0;
   well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
   
   
   bdt_fig = uifigure;
   bdt_fig.Name = 'MEA BDT GUI';

   
   p = uipanel(bdt_fig, 'Position', [10 10 1000 1000]);
   p.Scrollable = 'on';
   
   
   
   %ax = uiaxes(bdt_fig);
  
   
   %figure();
   
   
   
   well_bdt_ui_array = [];
   well_bdt_array = [];
   for w_r = 1:num_well_rows
       for w_c = 1:num_well_cols
          count = count + 1;
          wellID = strcat(well_dictionary(w_r), '_0', string(w_c));
          sub_p = uipanel(p, 'Position', [20+((w_r-1)*205) 20+((w_c-1)*205) 220 220]);
          sub_p.Scrollable = 'off';
          sub_p.AutoResizeChildren = 'off';
          sub_ax = subplot(num_well_rows, num_well_cols, count, 'Parent', sub_p);
          
          well_bdt_text = uieditfield(sub_p,'Text', 'Value','BDT', 'Editable','off');
          well_bdt_ui = uieditfield(sub_p,'Text', 'Value', '', 'ValueChangedFcn',@(b2bdropdown,event) changeBDT(well_bdt_array, w_r*w_c));
          well_bdt_ui_array = [well_bdt_ui_array ; well_bdt_ui];
          %well_bdt = well_dt_ui.Value;
          %well_bdt_array = [well_bdt_array; well_bdt];
          %subplot(num_well_rows, num_well_cols, count)
          disp(wellID);
          for e_r = 1:num_electrode_rows
             for e_c = 1:num_electrode_cols
                RawWellData = RawData{w_r, w_c, e_r, e_c};
                if (strcmp(class(RawWellData),'Waveform'))
                    %if ~empty(WellRawData)
                    %disp(num_well_rows*num_well_cols)
                    %disp(count)
                    electrode_id = strcat(wellID, '_', string(e_r), '_', string(e_c));
                    [time, data] = RawWellData.GetTimeVoltageVector;
                    %plot(time, data);
                    plot(sub_ax,time,data);
                    title(wellID);
                    hold on;
                    
                end
             end
          end
          hold off;
       end
   end

   function changeBDT(well_bdt_ui_array, well_num)
       disp('function entered')
       for i = 1:length(well_bdt_ui_array)
           well_bdt_ui_array(i).Value = well_bdt_ui_array(well_num).Value;
           disp('Value')
           disp(well_bdt_ui_array(i).Value)
       end
       
   end
  
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
