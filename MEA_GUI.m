function MEA_GUI(raw_file)
%  Create and then hide the UI as it is being constructed.
    close('all');

   RawFileData = AxisFile(raw_file);
    
   RawData = RawFileData.DataSets.LoadData;

   shape_data = size(RawData);
    
   num_well_rows = shape_data(1);
   num_well_cols = shape_data(2);
   num_electrode_rows = shape_data(3);
   num_electrode_cols = shape_data(4);
    
   
   screen_size = get(groot, 'ScreenSize');
   screen_width = screen_size(3);
   screen_height = screen_size(4);
   
   start_fig = uifigure;

   start_fig.Name = 'MEA GUI';

   % Move the window to the center of the screen.
   movegui(start_fig,'center')
   
   start_pan = uipanel(start_fig, 'Position', [0 0 screen_width screen_height]);
   set(start_pan, 'AutoResizeChildren', 'off');
   
   
   %p = uipanel(fig,'Position',[20 20 196 135]);
   
   beat_to_beat = '';
   %well_thresholding = '';
   
   im = uiimage(start_pan,'ImageSource','Logo - Victor Chang Cardiac Research Institute.jpg', 'Position', [0 90 400 200]);
   
   
   select_wells_button = uibutton(start_pan,'push','Text', 'Choose Custom Wells', 'Position',[410, 440, 140, 22], 'ButtonPushedFcn', @(select_wells_button,event) chooseWellsPushed(select_wells_button, num_well_rows, num_well_cols));
   
   
   
   added_wells = 'all';
   %well_thresh_text  = (p, 'Style','text','String','Well Specific Thresholding',... 'Position',[325,90,60,15]);
   %well_thresh_text = uieditfield(fig,'Text','Position',[410 90 140 22], 'Value','Well Thresholding');
   %well_thresh_dropdown = uidropdown(fig, 'Items', {'on', 'off'},'Position',[410 65 140 22], 'ValueChangedFcn',@(well_thresh_dropdown,event) well_thresh_popup_menu_Callback(well_thresh_dropdown, well_thresholding));

   bipolar_text = uieditfield(start_pan,'Text','Position',[410 350 140 25], 'Value','Calculate Bipolar Electrogram', 'Editable','off');
   bipolar_dropdown = uidropdown(start_pan, 'Items', {'on', 'off'},'Position',[410 320 140 25]);
   bipolar_dropdown.ItemsData = [1 2];
   
   b2b_options_text = uieditfield(start_pan,'Text','Position',[410 290 140 25], 'Value','Beat2Beat Options', 'Editable','off');
   b2b_options_dropdown = uidropdown(start_pan, 'Items', {'all', 'time region'},'Position',[410 260 140 25]);
   b2b_options_dropdown.ItemsData = [1 2];
   
   stable_options_text = uieditfield(start_pan,'Text','Position',[410 230 140 25], 'Value','Stable/Average', 'Editable','off');
   stable_options_dropdown = uidropdown(start_pan, 'Items', {'golden electrode', 'elec. time-region ave'},'Position',[410 200 140 25]);
   stable_options_dropdown.ItemsData = [1 2];
   set(stable_options_text,'Visible','off')
   set(stable_options_dropdown,'Visible','off')
   
   %b2btext  = uidropdown(fig, 'Style','text','String','Beat2Beat Analysis',... 'Position',[325,90,60,15]);
   b2btext = uieditfield(start_pan,'Text','Position',[410 170 140 25], 'Value','Beat2Beat', 'Editable','off');
   b2bdropdown = uidropdown(start_pan, 'Items', {'on', 'off'}, 'Position',[410 140 140 25], 'ValueChangedFcn',@(b2bdropdown,event) b2bdropdown_menu_Callback(b2bdropdown, beat_to_beat, start_fig, b2b_options_text, b2b_options_dropdown, stable_options_text, stable_options_dropdown, bipolar_text, bipolar_dropdown));
   b2bdropdown.ItemsData = [1 2];
   
   
   paced_spon_text = uieditfield(start_pan,'Text','Position',[410 110 140 25], 'Value','Paced/Spontaneous', 'Editable','off');
   paced_spon_options_dropdown = uidropdown(start_pan, 'Items', {'paced', 'spontaneous', 'paced bdt'},'Position',[410 80 140 25]);
   paced_spon_options_dropdown.ItemsData = [1 2 3];
   
   plate_well_text = uieditfield(start_pan,'Text','Position',[410 50 140 25], 'Value','Plate/Well Thresholding', 'Editable','off');
   plate_well_options_dropdown = uidropdown(start_pan, 'Items', {'well', 'plate', 'paced bdt'},'Position',[410 20 140 25]);
   plate_well_options_dropdown.ItemsData = [1 2];
   
   
     
   run_button = uibutton(start_pan,'push','Text', 'Choose Well Inputs', 'Position',[410, 470, 140, 22], 'ButtonPushedFcn', @(run_button,event) runButtonPushed(run_button, raw_file, b2b_options_dropdown, stable_options_dropdown, b2bdropdown, paced_spon_options_dropdown, start_fig, bipolar_dropdown, plate_well_options_dropdown));
   set(run_button, 'Visible', 'off')
   
   plots_text = uieditfield(start_pan,'Text','Position',[410 410 140 25], 'Value','Enter Save Data Directory Name', 'Editable','off');
   plots_input_ui = uieditfield(start_pan,'Text','Position',[410 380 140 25], 'ValueChangedFcn',@(plots_input_ui,event) changePlotsDir(plots_input_ui, start_fig, run_button));
   
   
   function b2bdropdown_menu_Callback(b2bdropdown,beat_to_beat, start_fig, b2b_options_text, b2b_options_dropdown, stable_options_text, stable_options_dropdown, bipolar_text, bipolar_dropdown) 
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
          
          set(bipolar_text, 'Visible', 'off')
          set(bipolar_dropdown, 'Visible', 'off')
          
      end
              
   end

   %{
   function well_thresh_popup_menu_Callback(well_thresh_dropdown,well_thresholding) 
      % Determine the selected data set.
      well_thresholding = well_thresh_dropdown.Value;
   end
   %}

   function runButtonPushed(run_button, raw_file, b2b_options_dropdown, stable_options_dropdown, b2bdropdown, paced_spon_options_dropdown, start_fig, bipolarDropdown, plate_well_options_dropdown)
      disp('worked')
      disp(b2bdropdown.Value);
      disp(stable_options_dropdown.Value);
      disp(b2b_options_dropdown.Value);
      disp(paced_spon_options_dropdown.Value);
      
      disp(added_wells);
      
      if b2bdropdown.Value == 1
          beat_to_beat = 'on';
      else
          beat_to_beat = 'off';
      end
      
      if bipolarDropdown.Value == 1
          bipolar = 'on';
      else
          bipolar = 'off';
      end
      
      if paced_spon_options_dropdown.Value == 1
          spon_paced = 'paced';
         
      elseif paced_spon_options_dropdown.Value == 2
          spon_paced = 'spon';
      else
          spon_paced = 'paced bdt';
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
      if plate_well_options_dropdown.Value == 1
          MEA_BDT_GUI_V2(raw_file, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, fullfile('data', get(plots_input_ui, 'Value')))
      
      else
          MEA_BDT_PLATE_GUI_V2(raw_file, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, fullfile('data', get(plots_input_ui, 'Value')))
      
      end
          
   end

   function chooseWellsPushed(select_wells_buttons, num_well_rows, num_well_cols)
       %disp('TBI');
       
       added_wells = MEA_GUI_select_wells(num_well_rows, num_well_cols);
       %disp(added_wells);
   end

   function dir_name = prompt_user(plots_input_ui, file_dir, data_dir, start_fig, run_button) 
    %% filename_prompt is the prompt that asks the user what they would like to name the specific file/dir
    %% file_dir is entered as either 'file' or 'dir' and indicates that the user is being prompted for either a file name or dir name
        
        dir_name = get(plots_input_ui, 'Value');
        %dir_name = input(filename_prompt, 's');
        
        if strcmp(dir_name, '')
            disp('NO')
            set(run_button, 'Visible', 'off');
            return;
        end
        
        spaces = regexp(dir_name, '^\s*$', 'match');
        
        if ~isempty(spaces)
            disp('NO');
            set(plots_input_ui, 'Value', '');
            set(run_button, 'Visible', 'off');
            return;
        end
            
            
        
        % Embed the new files and directory in data directory so analyses are grouped
        dir_name = fullfile(data_dir, dir_name);

        % Check that the filename has .csv on the end so the script doesn't die when it before writing the csv file
        if strcmp(file_dir, 'file')
            if ~contains(dir_name, '.csv')
                dir_name = strcat(dir_name, '.csv');
            end
        end

        check = '';
        if exist(dir_name, file_dir)
            % yes and no are the only valid entries. Loop continues if any other string is entered 
            changed_name = 0;
            %while (1)
                %check = input ('The selected directory name already exists, do you wish to continue? If so data will be lost (yes/no):\n', 's');
                %while(1)
                    
                    set(start_fig, 'Visible', 'off');
                    
                    check_fig = uifigure;
                    check_pan = uipanel(check_fig, 'Position', [0 0 screen_width screen_height]);
                    check_text = uieditfield(check_pan,'Text','Position',[80 300 500 22], 'Value',"The selected directory name"+ " "+ dir_name+" "+ "already exists, do you wish to overwrite?", 'Editable','off');
                    yes_button = uibutton(check_pan,'push','Text', 'Yes', 'Position',[100 250 50 22], 'ButtonPushedFcn', @(yes_button,event) yesButtonPushed(yes_button, start_fig, check_fig, run_button));
                    no_button = uibutton(check_pan,'push','Text', 'No', 'Position',[150 250 50 22], 'ButtonPushedFcn', @(no_button,event) noButtonPushed(no_button, start_fig, check_fig, plots_input_ui));
                    
                    while(1)
                        pause(0.01);
                        if strcmp(get(check_fig, 'Visible'), 'off')
                            %set(start_fig, 'Visible', 'on');
                            break;
                        end
                    end
                    %}
                
                %end
                
                %{
                if strcmpi(check, 'yes')
                    break;
                elseif strcmpi(check, 'no')
                    disp('do not overwrite');
                    %{
                    dir_name = input(filename_prompt, 's');
                    dir_name = fullfile(data_dir, dir_name);
                    if ~exist(dir_name, file_dir)
                        changed_name = 1;
                        break;
                    end
                    %}
                    
                end
                %}
                
            %end
            
            %if changed_name == 0
            if strcmp(check, 'yes')
                disp(['Overwriting' ' ' dir_name]);
                switch file_dir
                    case 'dir' 
                        if strcmp(dir_name, data_dir)
                            %disp('Error: Blocked from overwriting the entire data directory.');
                            %dir_name = prompt_user(filename_prompt, file_dir, parent_dir); 
                            disp('cannot be empty')
                            return;
                        end
                        rmdir (dir_name, 's');
                        %disp('rmdir')
                    case 'file'
                        % Check that the file is open. If fopen returns -1 alert the user to close the file and throw an error
                        fid = fopen(dir_name, 'w');
                        if fid < 0
                            error('Warning. The selected filename is open in another application and therefore cannot be overwritten. Please close and start run the script again.');
                        end 
                        fclose(fid);
                        delete dir_name;
                end
            end
        end
        if strcmp(check, '') ||  strcmp(check, 'yes')
            if strcmp(file_dir, 'dir')
                
                mkdir(dir_name);
                set(run_button, 'Visible', 'on')
                %disp('mkdir')
            end
        end
        
       function yesButtonPushed(yes_button, start_fig, check_fig, run_button)
           check = 'yes';
           
           set(check_fig, 'Visible', 'off');
           set(start_fig, 'Visible', 'on');
           set(run_button, 'Visible', 'on')
       end
       
       
       function noButtonPushed(no_button, start_fig, check_fig, plots_input_ui)
           check = 'no';
           set(check_fig, 'Visible', 'off');
           set(start_fig, 'Visible', 'on');
           set(plots_input_ui, 'Value', '');
           
       end
   end

   
   
   function changePlotsDir(plots_input_ui, start_fig, run_button)
        prompt_user(plots_input_ui, 'dir', 'data', start_fig, run_button);
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
