function MEA_GUI_Return(RawData, Stims, save_dir, skipped_data)
%  Create and then hide the UI as it is being constructed.
    
   close all hidden;
   close all;
   
   warning ('off', 'all');
   
   %raw_file = fullfile(save_dir, raw_file);
   %disp('Extracting data from .raw file, one moment please...')

   %RawFileData = AxisFile(raw_file);


   %RawData = RawFileData.DataSets.LoadData;

   if skipped_data == 1
       msgbox('Skipped all data. Returning to main menu')
   end
   

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
   
   start_pan = uipanel(start_fig, 'BackgroundColor','#B02727', 'Position', [0 0 screen_width screen_height]);
   set(start_pan, 'AutoResizeChildren', 'off');   
   
   %p = uipanel(fig,'Position',[20 20 196 135]);
   
   beat_to_beat = '';
   %well_thresholding = '';
   
   im = uiimage(start_pan,'ImageSource','Logo - Victor Chang Cardiac Research Institute.jpg', 'Position', [40 40 750 600]);
   
   select_wells_button = uibutton(start_pan,'push','Text', 'Choose Custom Wells', 'Position',[810, 570, 140, 22], 'ButtonPushedFcn', @(select_wells_button,event) chooseWellsPushed(select_wells_button, num_well_rows, num_well_cols));
   
   preview_data_button = uibutton(start_pan,'push','Text', 'Preview Data', 'Position',[810, 540, 140, 22], 'ButtonPushedFcn', @(preview_data_button,event) previewDataPushed(preview_data_button, num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, RawData));
   
   added_wells = 'all';
   %well_thresh_text  = (p, 'Style','text','String','Well Specific Thresholding',... 'Position',[325,90,60,15]);
   %well_thresh_text = uieditfield(fig,'Text','Position',[410 90 140 22], 'Value','Well Thresholding');
   %well_thresh_dropdown = uidropdown(fig, 'Items', {'on', 'off'},'Position',[410 65 140 22], 'ValueChangedFcn',@(well_thresh_dropdown,event) well_thresh_popup_menu_Callback(well_thresh_dropdown, well_thresholding));

   bipolar_text = uieditfield(start_pan,'Text','Position',[810 450 140 25], 'Value','Calculate Bipolar Electrogram', 'Editable','off');
   bipolar_dropdown = uidropdown(start_pan, 'Items', {'on', 'off'},'Position',[810 420 140 25]);
   bipolar_dropdown.ItemsData = [1 2];
   
   b2b_options_text = uieditfield(start_pan,'Text','Position',[810 390 140 25], 'Value','Beat2Beat Options', 'Editable','off');
   b2b_options_dropdown = uidropdown(start_pan, 'Items', {'all', 'time region'},'Position',[810 360 140 25]);
   b2b_options_dropdown.ItemsData = [1 2];
   
   stable_options_text = uieditfield(start_pan,'Text','Position',[810 330 140 25], 'Value','Stable/Average', 'Editable','off');
   stable_options_dropdown = uidropdown(start_pan, 'Items', {'golden electrode', 'elec. time-region ave'},'Position',[810 300 140 25]);
   stable_options_dropdown.ItemsData = [1 2];
   set(stable_options_text,'Visible','off')
   set(stable_options_dropdown,'Visible','off')
   
   %b2btext  = uidropdown(fig, 'Style','text','String','Beat2Beat Analysis',... 'Position',[325,90,60,15]);
   b2btext = uieditfield(start_pan,'Text','Position',[810 270 140 25], 'Value','Beat2Beat', 'Editable','off');
   b2bdropdown = uidropdown(start_pan, 'Items', {'on', 'off'}, 'Position',[810 240 140 25], 'ValueChangedFcn',@(b2bdropdown,event) b2bdropdown_menu_Callback(b2bdropdown, beat_to_beat, start_fig, b2b_options_text, b2b_options_dropdown, stable_options_text, stable_options_dropdown, bipolar_text, bipolar_dropdown));
   b2bdropdown.ItemsData = [1 2];
   
   paced_spon_text = uieditfield(start_pan,'Text','Position',[810 210 140 25], 'Value','Paced/Paced with Ectopic Beats', 'Editable','off');
   paced_spon_options_dropdown = uidropdown(start_pan, 'Items', {'paced', 'paced+ectopic'},'Position',[810 180 140 25]);
   paced_spon_options_dropdown.ItemsData = [1 2];
   
   set(paced_spon_text, 'Visible', 'off');
   set(paced_spon_options_dropdown, 'Visible', 'off');
   
   %{
   try
       Stims = sort([RawFileData.StimulationEvents(:).EventTime]);
   catch
       Stims = [];
   end
   %}

   if ~isempty(Stims)
       set(paced_spon_text, 'Visible', 'on');
       set(paced_spon_options_dropdown, 'Visible', 'on');
       
   end
   
   plate_well_text = uieditfield(start_pan,'Text','Position',[810 150 140 25], 'Value','Unique/General Well Anlaysis Inputs', 'Editable','off');
   plate_well_options_dropdown = uidropdown(start_pan, 'Items', {'unique', 'general'},'Position',[810 120 140 25]);
   plate_well_options_dropdown.ItemsData = [1 2];
   
   
   cross_talk_text = uieditfield(start_pan,'Text','Position',[810 90 140 25], 'Value','Minimise Cross-talk', 'Editable','off');
   cross_talk_options_dropdown = uidropdown(start_pan, 'Items', {'no', 'yes'},'Position',[810 60 140 25]);
   cross_talk_options_dropdown.ItemsData = [1 2];
   
   instructions_button = uibutton(start_pan,'push','Text', 'Instructions', 'Position',[810, 20, 140, 22], 'ButtonPushedFcn', @(instructions_button,event) instructionsButtonPushed(instructions_button, start_fig));
   
   
   
   run_button = uibutton(start_pan,'push','Text', 'Choose Well Inputs (Visual)', 'BackgroundColor', '#3dd4d1', 'Position',[810, 630, 180, 22], 'ButtonPushedFcn', @(run_button,event) runButtonPushed(run_button, RawData, Stims, b2b_options_dropdown, stable_options_dropdown, b2bdropdown, paced_spon_options_dropdown, start_fig, bipolar_dropdown, plate_well_options_dropdown, cross_talk_options_dropdown, save_dir));
   set(run_button, 'Visible', 'off')
   
   run_fast_button = uibutton(start_pan,'push','Text', 'Choose Well Inputs (Fast)', 'BackgroundColor', '#3dd4d1', 'Position',[810, 600, 180, 22], 'ButtonPushedFcn', @(run_fast_button,event) runFastButtonPushed(run_fast_button, RawData, Stims, b2b_options_dropdown, stable_options_dropdown, b2bdropdown, paced_spon_options_dropdown, start_fig, bipolar_dropdown, plate_well_options_dropdown, cross_talk_options_dropdown, save_dir));
   set(run_fast_button, 'Visible', 'off')
   
   plots_text = uieditfield(start_pan,'Text','Position',[810 510 140 25], 'Value','Enter Save Data Directory Name', 'Editable','off');
   plots_input_ui = uieditfield(start_pan,'Text','Position',[810 480 140 25], 'ValueChangedFcn',@(plots_input_ui,event) changePlotsDir(plots_input_ui, start_fig, save_dir, run_button, run_fast_button));
   
   start_fig.WindowState = 'maximized';
   
   function instructionsButtonPushed(instructions_button, start_fig)
       set(start_fig, 'visible', 'off');
       
       instructions_fig = uifigure;
       movegui(instructions_fig,'center')
       instructions_fig.WindowState = 'maximized';
       
       instr_pan = uipanel(instructions_fig, 'BackgroundColor','#B02727', 'Position', [0 0 screen_width screen_height]);
       close_instructions_button = uibutton(instr_pan,'push','Text', 'Back', 'Position',[screen_width-120, 100, 100, 60], 'ButtonPushedFcn', @(close_instructions_button,event) closeInstructionsButtonPushed());
   
       
       textarea = uitextarea(instr_pan, 'Position', [0 0 screen_width-150 screen_height-100], 'Value',{'It is recommended to look at recordings via the Preview Data button to select wells via the Choose Custom Wells button that require similar analysis inputs to allow quicker analyses to be performed. Changing the Plate/Well Thresholding dropdown to Plate will allow each of these wells to be combined in the next input menu to quickly choose analysis inputs that work for each of the selected wells. If Custom wells is not selected then the entire plate will be analysed. To engage in more curated analyses, keeping the Plate/Well Thresholding drowdown at the Well option will allow each well to be individually inspected and have unique inputs designated for its analysis.', ' ', 'When the Beat2Beat option is set to on, this will determine the fiducial points of each beat in the entire recording for each electrode. The output file will contain statistics reported for each detected beat for each electrode as well as average statistics for each electrode and the well. To focus on particular time ranges of the recording the Beat2Beat Options drop down can be set to time region.', ' ', 'If the Beat2Beat Option is set to off then the menu will display a new dropdown that allows users to choose if they want to base their analyses off the golden electrode, which is the averaged waveform from the elctrode that has the most stable set of consecutive beats within a selected time window. The number of waveforms to investigate are extracted by dividing the entered time window by the average beat period of the recording. The stdev of te BPs are then compared and the electrode with the lowest stdev is selected as the golden electrode. If the user opts for the average waveform analysis then they will be required to enter a time range in the analysis input menu. The output will then be an average waveform for each electrode that is calculated by averaging the detected beats between the selected time range.'});
       %textarea.Scrollable = 'on';
       
       function closeInstructionsButtonPushed()
           close(instructions_fig)
           set(start_fig, 'visible', 'on');
           
       end
   end
   function b2bdropdown_menu_Callback(b2bdropdown,beat_to_beat, start_fig, b2b_options_text, b2b_options_dropdown, stable_options_text, stable_options_dropdown, bipolar_text, bipolar_dropdown) 
      beat_to_beat = b2bdropdown.Value;
      if beat_to_beat == 1
          %disp('b2b on')
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
          %disp('b2b off')
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

   function runButtonPushed(run_button, RawData, Stims, b2b_options_dropdown, stable_options_dropdown, b2bdropdown, paced_spon_options_dropdown, start_fig, bipolarDropdown, plate_well_options_dropdown, cross_talk_options_dropdown, save_dir)
      %disp('worked')
      %disp(b2bdropdown.Value);
      %disp(stable_options_dropdown.Value);
      %disp(b2b_options_dropdown.Value);
      %disp(paced_spon_options_dropdown.Value);
      
      %disp(added_wells);
      
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
      
      if strcmp(get(paced_spon_options_dropdown, 'Visible'), 'on')
          if paced_spon_options_dropdown.Value == 1
              spon_paced = 'paced';

          elseif paced_spon_options_dropdown.Value == 2
              spon_paced = 'paced bdt';
          end
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
      
      %{
      Stims = [];
      if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
           try
               Stims = sort([RawFileData.StimulationEvents(:).EventTime]);
           catch
               spon_paced = 'paced_no_stims';
           end
      end
      %}
      
      if contains(added_wells, 'all')
         added_wells_all = [];
         well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
         for w_r = 1:num_well_rows
           for w_c = 1:num_well_cols
              wellID = strcat(well_dictionary(w_r), '0', string(w_c));
              well_data = 0;
              for e_r = 1:num_electrode_rows
                 for e_c = 1:num_electrode_cols
                    RawWellData = RawData{w_r, w_c, e_r, e_c};
                    if (strcmp(class(RawWellData),'Waveform'))
                        well_data = 1;
                        break
                    end
                    
                 end
                 if well_data == 1
                     added_wells_all = [added_wells_all wellID];
                     break
                 end
              end
              
           end
         end
         added_wells = added_wells_all;
      end
      
      

      set(start_fig, 'Visible', 'off')
      %analyse_MEA_signals(raw_file, beat_to_beat, 'paced', well_thresholding, 1)
      if cross_talk_options_dropdown.Value == 2
          if plate_well_options_dropdown.Value == 1
              parameter_input_method = 'unique';
          else
              parameter_input_method = 'general';
          end
          prompt_cross_talk_minimisation_wells(RawData,Stims, added_wells, num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, bipolar, save_dir, get(plots_input_ui, 'Value'), parameter_input_method)
      else
          %analyse_MEA_signals(raw_file, beat_to_beat, 'paced', well_thresholding, 1)
          if plate_well_options_dropdown.Value == 1
              MEA_BDT_GUI_V2(RawData,Stims, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, save_dir, get(plots_input_ui, 'Value'), [], [], '')

          else
              MEA_BDT_PLATE_GUI_V2(RawData,Stims, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, save_dir, get(plots_input_ui, 'Value'), [], [], '')

          end
      end
          
   end

   function runFastButtonPushed(run_fast_button, RawData, Stims, b2b_options_dropdown, stable_options_dropdown, b2bdropdown, paced_spon_options_dropdown, start_fig, bipolarDropdown, plate_well_options_dropdown, cross_talk_options_dropdown, save_dir)
      %disp('worked')
      %disp(b2bdropdown.Value);
      %disp(stable_options_dropdown.Value);
      %disp(b2b_options_dropdown.Value);
      %disp(paced_spon_options_dropdown.Value);
      
      %disp(added_wells);
      
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
      
      %{
      if paced_spon_options_dropdown.Value == 1
          spon_paced = 'paced';
         
      elseif paced_spon_options_dropdown.Value == 2
          spon_paced = 'spon';
      else
          spon_paced = 'paced bdt';
      end
      %}
      if strcmp(get(paced_spon_options_dropdown, 'Visible'), 'on')
          if paced_spon_options_dropdown.Value == 1
              spon_paced = 'paced';

          elseif paced_spon_options_dropdown.Value == 2
              spon_paced = 'paced bdt';
          end
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
      
      %{
      Stims = [];
      if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
           try
               Stims = sort([RawFileData.StimulationEvents(:).EventTime]);
           catch
               spon_paced = 'paced_no_stims';
           end
      end
      %}

      set(start_fig, 'Visible', 'off')
      %analyse_MEA_signals(raw_file, beat_to_beat, 'paced', well_thresholding, 1)
      if contains(added_wells, 'all')
         added_wells_all = [];
         well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
         for w_r = 1:num_well_rows
           for w_c = 1:num_well_cols
              wellID = strcat(well_dictionary(w_r), '0', string(w_c));
              well_data = 0;
              for e_r = 1:num_electrode_rows
                 for e_c = 1:num_electrode_cols
                    RawWellData = RawData{w_r, w_c, e_r, e_c};
                    if (strcmp(class(RawWellData),'Waveform'))
                        well_data = 1;
                        break
                    end
                    
                 end
                 if well_data == 1
                     added_wells_all = [added_wells_all wellID];
                     break
                 end
              end
              
           end
         end
         added_wells = added_wells_all;
      end
      
      if cross_talk_options_dropdown.Value == 2

          parameter_input_method = 'fast';
          
          prompt_cross_talk_minimisation_wells(RawData, Stims, added_wells, num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, bipolar, save_dir, get(plots_input_ui, 'Value'), parameter_input_method)
      else
          if plate_well_options_dropdown.Value == 1
              MEA_GUI_FAST_THRESHOLD_INPUTS(RawData, Stims, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, save_dir, get(plots_input_ui, 'Value'), [], [], '')

          else
              MEA_GUI_FAST_THRESHOLD_INPUTS(RawData, Stims, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, save_dir, get(plots_input_ui, 'Value'), [], [], '')

          end
      end
      
      
   end

   function chooseWellsPushed(select_wells_buttons, num_well_rows, num_well_cols)
       %disp('TBI');
       
       added_wells = MEA_GUI_select_wells(num_well_rows, num_well_cols);
       %disp(added_wells);
   end

   function dir_name = prompt_user(plots_input_ui, file_dir, data_dir, start_fig, run_button, run_fast_button) 
    % filename_prompt is the prompt that asks the user what they would like to name the specific file/dir
    % file_dir is entered as either 'file' or 'dir' and indicates that the user is being prompted for either a file name or dir name
        
        dir_name = get(plots_input_ui, 'Value');
        %dir_name = input(filename_prompt, 's');
        
        if strcmp(dir_name, '')
            disp('NO')
            set(run_button, 'Visible', 'off');
            set(run_fast_button, 'Visible', 'off');
            return;
        end
        
        spaces = regexp(dir_name, '^\s*$', 'match');
        
        if ~isempty(spaces)
            disp('NO');
            set(plots_input_ui, 'Value', '');
            set(run_button, 'Visible', 'off');
            set(run_fast_button, 'Visible', 'off');
            return;
        end
        
        [spaces_end, toks] = regexp(dir_name, '^([\w*\s{0,1}\w*]+[^\s])(\s+)$', 'match', 'tokens');
        
        
        if ~isempty(spaces_end)
            set(plots_input_ui, 'Value', toks{1}{1});
            dir_name = toks{1}{1};
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
                    if screen_width > 150
                        text_box_width = screen_width-150;
                    else
                        text_box_width = 500;
                    end
                    check_text = uieditfield(check_pan,'Text','Position',[80 300 text_box_width 22], 'Value',"The selected directory name"+ " "+ dir_name+" "+ "already exists, do you wish to overwrite?", 'Editable','off');
                    yes_button = uibutton(check_pan,'push','Text', 'Yes', 'Position',[100 250 50 22], 'ButtonPushedFcn', @(yes_button,event) yesButtonPushed(yes_button, start_fig, check_fig, run_button, run_fast_button));
                    no_button = uibutton(check_pan,'push','Text', 'No', 'Position',[150 250 50 22], 'ButtonPushedFcn', @(no_button,event) noButtonPushed(no_button, start_fig, check_fig, plots_input_ui));
                    keep_button = uibutton(check_pan,'push','Text', 'Keep', 'Position',[200 250 50 22], 'ButtonPushedFcn', @(keep_button,event) keepButtonPushed(keep_button, start_fig, check_fig, run_button, run_fast_button));
                    
                    
                    
                    
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
                        %disp(dir_name)
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
                %disp(dir_name)
                mkdir(dir_name);
                set(run_button, 'Visible', 'on')
                set(run_fast_button, 'Visible', 'on')
                %disp('mkdir')
            end
        end
        
       function yesButtonPushed(yes_button, start_fig, check_fig, run_button, run_fast_button)
           check = 'yes';
           
           set(check_fig, 'Visible', 'off');
           set(start_fig, 'Visible', 'on');
           set(run_button, 'Visible', 'on');
           set(run_fast_button, 'Visible', 'on')
       end
       
       
       function noButtonPushed(no_button, start_fig, check_fig, plots_input_ui)
           check = 'no';
           set(check_fig, 'Visible', 'off');
           set(start_fig, 'Visible', 'on');
           set(plots_input_ui, 'Value', '');
           
       end
       
       function keepButtonPushed(keep_button, start_fig, check_fig, run_button, run_fast_button)
           check = 'keep';
           set(check_fig, 'Visible', 'off');
           set(start_fig, 'Visible', 'on');
           set(run_button, 'Visible', 'on');
           set(run_fast_button, 'Visible', 'on')
           %set(plots_input_ui, 'Value', '');
           
       end
   end

   
   function changePlotsDir(plots_input_ui, start_fig, save_dir, run_button, run_fast_button)
        prompt_user(plots_input_ui, 'dir', save_dir, start_fig, run_button, run_fast_button);
   end

   function previewDataPushed(preview_data_button, num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, RawData)
       MEA_GUI_Preview_Data(num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, RawData);

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
