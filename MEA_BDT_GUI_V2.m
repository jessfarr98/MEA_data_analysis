function MEA_BDT_GUI_V2(raw_file, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar)
%  Create and then hide the UI as it is being constructed.

%% TO DO
% General parameters: post-spike hold-off.
% Output GUI displaying results for everything with save plots function. 
% plots prompt in MEA_GUI 
% rigorous testing
% t-wave fitting
% why depol min/max plot offset?
% extract data once and feed through scripts to increase speed
% save results
% local vector maps - Georgiadis
% Speed this code up by creating separate file that produces each uifigure for each well and returns required results once it's been submitted - faster than while loop
% Increase robustness - input error handling like no available Stim data for paced data
% Paced datasets should be able to show t-wave box when t-wave duration entered and post spike entered
% Update select wells so it remembers previous clicked well states if clicked again
% remove min max BP for paced


   % Generate the data to plot.   
   %raw_file = fullfile('Y:', 'Recordings for Jess', 'cardiac paced_paced ME 600us(000).raw');
   disp('Generating Input GUI...');
   disp(stable_ave_analysis);
   RawFileData = AxisFile(raw_file);
    
   RawData = RawFileData.DataSets.LoadData;

   shape_data = size(RawData);
    
   num_well_rows = shape_data(1);
   num_well_cols = shape_data(2);
   num_electrode_rows = shape_data(3);
   num_electrode_cols = shape_data(4);
    
   %{
   num_well_rows = 1;
   num_well_cols = 1;
   num_electrode_rows = 4;
   num_electrode_cols = 4;
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
   
   %clear_all_bdt_button = uibutton(main_pan,'push','Text', 'Clear All BDTs', 'Position',[screen_width-190, 60, 80, 40], 'ButtonPushedFcn', @(clear_all_bdt_button,event) clearAllBDTPushed(clear_all_bdt_button, run_button));
   %clear_all_t_wave_durations_button = uibutton(main_pan,'push','Text', 'Clear All T-Wave Durations', 'Position',[screen_width-190, 110, 80, 40], 'ButtonPushedFcn', @(clear_all_t_wave_durations_button, event) clearAllTWavesPushed(clear_all_t_wave_durations_button));
   set(run_button, 'Visible', 'off');
   %set(clear_all_bdt_button, 'Visible', 'off');
   %set(clear_all_t_wave_durations_button, 'Visible', 'off');
   
   p = uipanel(main_pan, 'Position', [0 0 screen_width-200 screen_height]);
   p.Scrollable = 'on';   
   set(bdt_fig, 'Visible', 'off')

   well_bdt_array = [];
   well_t_wave_dur_array = [];
   well_t_wave_shape_array = [];
   well_time_reg_start = [];
   well_time_reg_end = [];
   well_stable_dur = [];
   
   well_figure_array = [];
   well_min_bp_array = [];
   well_max_bp_array = [];
   
   for w_r = 1:num_well_rows
       for w_c = 1:num_well_cols
          wellID = strcat(well_dictionary(w_r), '0', string(w_c)); 
          if ~strcmp(added_wells, 'all')
              if ~contains(added_wells, wellID)
                  continue;
              end
          end
          count = count + 1;
                   
          
          well_fig = uifigure;
          well_fig.Name = strcat(wellID, {''}, 'BDT GUI');
          well_p = uipanel(well_fig, 'Position', [0 0 screen_width screen_height]);
          
          well_ax = uiaxes(well_p, 'Position', [10 100 screen_width-300 screen_height-200]);
          hold(well_ax, 'on');
          
          
          time_offset = 0;
          max_voltage = NaN;
          min_voltage = NaN;
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
                    if isnan(max_voltage)
                        max_voltage = max(data);
                    else
                        if max(data) > max_voltage
                            max_voltage = max(data);
                        end
                    end
                    if isnan(min_voltage)
                        min_voltage = min(data);
                        
                    else
                        if min(data) < min_voltage
                            min_voltage = min(data);
                        end
                    end
                    plot(well_ax,time,data);
                    %hold on;
                    %title(sub_ax, wellID);
                    %pause(10)
                    %plot(time, data);
                    time_offset = time_offset+0.015;
                    
                else
                    disp(wellID)
                    disp('no data');
                end
             end
          end
          submit_in_well_button = uibutton(well_p,'push','Text', 'Submit Inputs for Well', 'Position',[screen_width-200 100 200 60], 'ButtonPushedFcn', @(submit_in_well_button,event) submitButtonPushed(submit_in_well_button, well_fig));
          set(submit_in_well_button, 'Visible', 'off')
          
          if strcmp(spon_paced, 'spon')
              well_bdt_text = uieditfield(well_p,'Text', 'Value', strcat(wellID, {' '}, 'BDT'), 'FontSize', 12, 'Position', [10 60 100 40], 'Editable','off');
              well_bdt_ui = uieditfield(well_p, 'numeric', 'Tag', 'BDT', 'Position', [10 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(well_bdt_ui,event) changeBDT(well_bdt_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end)));
          end
          
          t_wave_up_down_text = uieditfield(well_p, 'Text', 'Value', strcat(wellID, {' '}, 'T-wave shape'), 'FontSize', 12,'Position', [120 60 100 40], 'Editable','off');
          t_wave_up_down_dropdown = uidropdown(well_p, 'Items', {'monophasic downwards', 'monophaic upwards', 'biphasic'}, 'FontSize', 12,'Position', [120 10 100 40]);
          t_wave_up_down_dropdown.ItemsData = [1 2 3];
          
          t_wave_duration_text = uieditfield(well_p,'Text', 'Value', strcat(wellID, {' '}, 'T-wave duration'), 'FontSize', 12, 'Position', [240 60 100 40], 'Editable','off');
          t_wave_duration_ui = uieditfield(well_p, 'numeric', 'Tag', 'T-Wave', 'Position', [240 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(t_wave_duration_ui,event) changeTWaveDuration(t_wave_duration_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced));
          
          min_bp_text = uieditfield(well_p,'Text', 'Value', strcat(wellID, {' '}, 'Min. BP'), 'FontSize', 12, 'Position', [360 60 100 40], 'Editable','off');
          min_bp_ui = uieditfield(well_p, 'numeric', 'Tag', 'Min BP', 'Position', [360 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(min_bp_ui,event) changeMinBPDuration(min_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced));
          
          max_bp_text = uieditfield(well_p,'Text', 'Value', strcat(wellID, {' '}, 'Max. BP'), 'FontSize', 12, 'Position', [480 60 100 40], 'Editable','off');
          max_bp_ui = uieditfield(well_p, 'numeric', 'Tag', 'Max BP', 'Position', [480 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(max_bp_ui,event) changeMaxBPDuration(max_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced));
          
          
          disp(beat_to_beat);
          if strcmp(beat_to_beat, 'on')
 
              if strcmp(analyse_all_b2b, 'time_region')
                  time_start_text = uieditfield(well_p,'Text', 'Value', 'B2B Time region start time', 'FontSize', 12, 'Position', [360 60 100 40], 'Editable','off');
                  time_start_ui = uieditfield(well_p, 'numeric', 'Tag', 'Start Time', 'Position', [360 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(time_start_ui,event) changeStartTime(time_start_ui, well_ax, min_voltage, max_voltage, time(end), spon_paced));
                  
                  time_end_text = uieditfield(well_p,'Text', 'Value', 'B2B Time region end time', 'FontSize', 12, 'Position', [480 60 100 40], 'Editable','off');
                  time_end_ui = uieditfield(well_p, 'numeric', 'Tag', 'End Time', 'Position', [480 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(time_end_ui,event) changeEndTime(time_end_ui, well_ax, min_voltage, max_voltage, time(end), spon_paced));
                  set(time_end_ui, 'Value', time(end))
                  time_region_plot_data = linspace(min_voltage, max_voltage, length(data));
                  start_data = ones(length(time), 1);
                  start_data(:,1) = 0;
                  end_data = ones(length(time), 1);
                  end_data(:,1) = time(end);
                  plot(well_ax, start_data, time_region_plot_data)
                  plot(well_ax, end_data, time_region_plot_data)
              
              end
          else
              if strcmp(stable_ave_analysis, 'time_region')
                  time_start_text = uieditfield(well_p,'Text', 'Value', 'Stable Analysis time region start time', 'FontSize', 12, 'Position', [360 60 100 40], 'Editable','off');
                  time_start_ui = uieditfield(well_p, 'numeric', 'Tag', 'Start Time', 'Position', [360 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(time_start_ui,event) changeStartTime(time_start_ui, well_ax, min_voltage, max_voltage, time(end), spon_paced));
                  
                  time_end_text = uieditfield(well_p,'Text', 'Value', 'Stable Analysis time region end time', 'FontSize', 12, 'Position', [480 60 100 40], 'Editable','off');
                  time_end_ui = uieditfield(well_p, 'numeric', 'Tag', 'End Time', 'Position', [480 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(time_end_ui,event) changeEndTime(time_end_ui, well_ax, min_voltage, max_voltage, time(end), spon_paced));
                  set(time_end_ui, 'Value', time(end))
                  time_region_plot_data = linspace(min_voltage, max_voltage, length(data));
                  start_data = ones(length(time), 1);
                  start_data(:,1) = 0;
                  end_data = ones(length(time), 1);
                  end_data(:,1) = time(end);
                  plot(well_ax, start_data, time_region_plot_data)
                  plot(well_ax, end_data, time_region_plot_data)
                  
              end
              if strcmp(stable_ave_analysis, 'stable')
                  %sliding time window to find the elctrode with the most stable beat period and then compute average waveform using this region
                  stable_duration_text = uieditfield(well_p,'Text', 'Value', 'Time Window for GE average waveform', 'FontSize', 12, 'Position', [360 60 100 40], 'Editable','off');
                  stable_duration_ui = uieditfield(well_p, 'numeric', 'Tag', 'GE Window', 'Position', [360 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(stable_duration_ui,event) changeGEWindow(stable_duration_ui, well_ax, spon_paced));
                  
              
              end
          end

          init_bdt_data = ones(length(time), 1);
          init_bdt_data(:,1) = 0;
          plot(well_ax, time, init_bdt_data);
          
         
          
          %hold off;
          
          hold(well_ax,'off');
          

          while(1)
             pause(0.01)
             if strcmp(get(well_fig, 'Visible'), 'off')
                break; 
             end
          end
          
          
          well_figure_array = [well_figure_array; well_fig];
          
          well_t_wave_dur_array = [well_t_wave_dur_array; get(t_wave_duration_ui, 'Value')];
          well_t_wave_shape_array = [well_t_wave_shape_array; get(t_wave_up_down_dropdown, 'Value')];
          well_min_bp_array = [well_min_bp_array; get(min_bp_ui, 'Value')];
          well_max_bp_array = [well_max_bp_array; get(max_bp_ui, 'Value')];
          
          if strcmp(spon_paced, 'spon')
              well_bdt_array = [well_bdt_array; get(well_bdt_ui, 'Value')];
          end
          
          if strcmp(beat_to_beat, 'on')
              if strcmp(analyse_all_b2b, 'time_region')
                  well_time_reg_start = [well_time_reg_start; get(time_start_ui, 'Value')];
                  well_time_reg_end = [well_time_reg_end; get(time_end_ui, 'Value')];
              end
          else
              if strcmp(stable_ave_analysis, 'time_region')
                  well_time_reg_start = [well_time_reg_start; get(time_start_ui, 'Value')];
                  well_time_reg_end = [well_time_reg_end; get(time_end_ui, 'Value')];
              elseif strcmp(stable_ave_analysis, 'stable')
                  well_stable_dur  = [well_stable_dur; get(stable_duration_ui, 'Value')]; 
                  
              end
          end
       end
   end
   
   disp(size(well_t_wave_shape_array));
   disp(well_t_wave_shape_array(1, :))
   
   if strcmp(spon_paced, 'spon')
      well_bdt_array = well_bdt_array./1000;
   end
     
   disp(well_min_bp_array);
   disp(well_max_bp_array);
   
   analyse_MEA_signals_GUI(raw_file, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_bdt_array, well_t_wave_dur_array, well_t_wave_shape_array, well_time_reg_start, well_time_reg_end, well_stable_dur, added_wells, well_min_bp_array, well_max_bp_array, bipolar)

   function changeBDT(well_bdt_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time)

       % BDT CANNOT be equal to 0. 
       if get(well_bdt_ui, 'Value') == 0
           msgbox('BDT cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       t_wave_ok = 0;
       start_time_ok = 1;
       end_time_ok = 1;
       min_BP_ok = 0;
       max_BP_ok = 0;
       for i = 1:length(well_pan_components)
           
           well_ui_con = well_pan_components(i);
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') ~= 0
                  max_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') ~= 0
                  min_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Type')), 'axes')
               axes_children = get(well_ui_con, 'Children');
           
               for c = 1:length(axes_children)
                   child_y_data = axes_children(c).YData;
                   if child_y_data(1) == child_y_data(:)
                       prev_bdt_plot = axes_children(c);
                       break;
                   end


               end
               %set(prev_bdt_plot, 'Visible', 'off');
               bdt_data = ones(length(prev_bdt_plot.XData), 1);
               bdt_data(:,1) = get(well_bdt_ui, 'Value');
               prev_bdt_plot.YData = bdt_data;
               %{
               time_data = linspace(0, prev_bdt_plot.XData(end), length(prev_bdt_plot.XData));
               bdt_data = ones(length(prev_bdt_plot.XData), 1);
               bdt_data(:,1) = get(well_bdt_ui, 'Value');
               hold(well_ui_con, 'on');
               plot(well_ui_con, time_data, bdt_data);
               hold(well_ui_con, 'off');
               %}
           end
       end
       if t_wave_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && min_BP_ok == 1 && max_BP_ok ==1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
   end

   function changeTWaveDuration(t_wave_duration_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced)
       %disp('change T-wave duration')
       %disp('function entered')
       %disp(length(well_bdt_ui_array))
       %disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(t_wave_duration_ui, 'Value') == 0
           msgbox('T-Wave duration cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 0;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 0;
       min_BP_ok = 0;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           if strcmp(spon_paced, 'spon')
               if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
                   if get(well_ui_con, 'Value') ~= 0
                      %set(submit_in_well_button, 'Visible', 'on')
                      bdt_ok = 1;
                   end
               end
           else
               bdt_ok = 1;
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') ~= 0
                  min_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') ~= 0
                  max_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       if bdt_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
   end

    function changeMinBPDuration(min_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced)
       %disp('change T-wave duration')
       %disp('function entered')
       %disp(length(well_bdt_ui_array))
       %disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(min_bp_ui, 'Value') == 0
           msgbox('Min BP cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 0;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 0;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           if strcmp(spon_paced, 'spon')
               if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
                   if get(well_ui_con, 'Value') ~= 0
                      %set(submit_in_well_button, 'Visible', 'on')
                      bdt_ok = 1;
                   end
               end
           else
               bdt_ok = 1;
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') ~= 0
                  max_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       if bdt_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && GE_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
    end

    function changeMaxBPDuration(max_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced)
       %disp('change T-wave duration')
       %disp('function entered')
       %disp(length(well_bdt_ui_array))
       %disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(max_bp_ui, 'Value') == 0
           msgbox('Max BP cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 0;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       min_BP_ok = 0;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           if strcmp(spon_paced, 'spon')
               if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
                   if get(well_ui_con, 'Value') ~= 0
                      %set(submit_in_well_button, 'Visible', 'on')
                      bdt_ok = 1;
                   end
               end
           else
               bdt_ok = 1;
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
               if get(well_ui_con, 'Value') == 0 
                   start_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   start_time = get(well_ui_con, 'Value');
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') ~= 0
                  min_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
               if get(well_ui_con, 'Value') == orig_end_time
                   end_time_ok = 0;
                   %set(submit_in_well_button, 'Visible', 'on')
               else
                   end_time = get(well_ui_con, 'Value');
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       if bdt_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
   end


   function changeStartTime(time_start_ui, well_ax, min_voltage, max_voltage, orig_end_time, spon_paced)
       if get(time_start_ui, 'Value') >= get(time_end_ui, 'Value')
           msgbox('Time region start time must be less than the end time.','Oops!');
           set(time_start_ui, 'Value', 0);
       end
       axes_children = get(well_ax, 'Children');
       
       time_region_plots = [];
       for c = 1:length(axes_children)
           child_x_data = axes_children(c).XData;
           %disp(child_x_data(1))
           %disp(floor(child_x_data(1)))
           if child_x_data(1) == child_x_data(:)
               
               time_region_plots = [time_region_plots; axes_children(c)];
               %break;
           end
       end
       
       plot1 = time_region_plots(1);
       plot2 = time_region_plots(2);
       disp(plot1.XData(1));
       disp(plot2.XData(1));
       if plot1.XData(1) < plot2.XData(1)
           prev_start_plot = plot1;
       else
           prev_start_plot = plot2;
       end
       disp(prev_start_plot.XData(1));
       
       %set(prev_start_plot, 'Visible', 'off');
       %hold(well_ax, 'on');
       ydata = linspace(min_voltage, max_voltage, length(prev_start_plot.YData));
       xdata = ones(length(prev_start_plot.XData), 1);
       xdata(:,1) = get(time_start_ui, 'Value');
       %plot(well_ax, xdata, ydata)
       %hold(well_ax, 'off');
       prev_start_plot.XData = xdata;
       
       if get(time_start_ui, 'Value') ~= 0
           well_pan_components = get(well_p, 'Children');
           bdt_ok = 0;
           start_time_ok = 1;
           end_time_ok = 1;
           t_wave_ok = 0;
           GE_ok = 1;
           max_BP_ok = 0;
           min_BP_ok = 0;
           for i = 1:length(well_pan_components)
               well_ui_con = well_pan_components(i);
               if strcmp(spon_paced, 'spon')
                   if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
                       if get(well_ui_con, 'Value') ~= 0
                          %set(submit_in_well_button, 'Visible', 'on')
                          bdt_ok = 1;
                       end
                   end
               else
                   bdt_ok = 1;
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave') 
                   if get(well_ui_con, 'Value') ~= 0
                      %set(submit_in_well_button, 'Visible', 'on')
                      t_wave_ok = 1;
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
                   if get(well_ui_con, 'Value') ~= 0
                      min_BP_ok = 1;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
                   if get(well_ui_con, 'Value') ~= 0
                      max_BP_ok = 1;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
                   if get(well_ui_con, 'Value') == 0 
                       start_time_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
                   else
                       start_time = get(well_ui_con, 'Value');
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
                   if get(well_ui_con, 'Value') == orig_end_time
                       end_time_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
                   else
                       end_time = get(well_ui_con, 'Value');
                   end
               end
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
                   if get(well_ui_con, 'Value') == 0
                       GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
           end 
           if bdt_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && t_wave_ok == 1 && GE_ok == 1
               %if start_time < end_time
               set(submit_in_well_button, 'Visible', 'on')
               %end
           end
       end
   end

   function changeEndTime(time_end_ui, well_ax, min_voltage, max_voltage, orig_end_time, spon_paced)
       if get(time_start_ui, 'Value') >= get(time_end_ui, 'Value')
           msgbox('Time region end time must be greater than the start time.','Oops!');
           %return;
           set(time_end_ui, 'Value', orig_end_time);
       end
       
       axes_children = get(well_ax, 'Children');
       
       time_region_plots = [];
       for c = 1:length(axes_children)
           child_x_data = axes_children(c).XData;
           if floor(child_x_data(:)) == floor(child_x_data(1))
               time_region_plots = [time_region_plots; axes_children(c)];
               %break;
           end
       end
       
       plot1 = time_region_plots(1);
       plot2 = time_region_plots(2);
       if plot1.XData(1) > plot2.XData(1)
           prev_start_plot = plot1;
       else
           prev_start_plot = plot2;
       
       end
       
       %set(prev_start_plot, 'Visible', 'off');
       %hold(well_ax, 'on');
       ydata = linspace(min_voltage, max_voltage, length(prev_start_plot.YData));
       xdata = ones(length(prev_start_plot.XData), 1);
       xdata(:,1) = get(time_end_ui, 'Value');
       %plot(well_ax, xdata, ydata)
       %hold(well_ax, 'off');
       prev_start_plot.XData = xdata;
       
       if get(time_end_ui, 'Value') ~= orig_end_time
           well_pan_components = get(well_p, 'Children');
           bdt_ok = 0;
           start_time_ok = 1;
           end_time_ok = 1;
           t_wave_ok = 0;
           max_BP_ok = 0;
           min_BP_ok = 0;
           for i = 1:length(well_pan_components)
               well_ui_con = well_pan_components(i);
               if strcmp(spon_paced, 'spon')
                   if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
                       if get(well_ui_con, 'Value') ~= 0
                          %set(submit_in_well_button, 'Visible', 'on')
                          bdt_ok = 1;
                       end
                   end
               else
                   bdt_ok = 1;
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave') 
                   if get(well_ui_con, 'Value') ~= 0
                      %set(submit_in_well_button, 'Visible', 'on')
                      t_wave_ok = 1;
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
                   if get(well_ui_con, 'Value') ~= 0
                      max_BP_ok = 1;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
                   if get(well_ui_con, 'Value') ~= 0
                      min_BP_ok = 1;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Start Time')
                   if get(well_ui_con, 'Value') == 0 
                       start_time_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
                   else
                       start_time = get(well_ui_con, 'Value');
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'End Time')
                   if get(well_ui_con, 'Value') == orig_end_time
                       end_time_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
                   else
                       end_time = get(well_ui_con, 'Value');
                   end
               end
               
              
           end 
           if bdt_ok == 1 && max_BP_ok == 1 && min_BP_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && t_wave_ok == 1 
               %if start_time < end_time
               set(submit_in_well_button, 'Visible', 'on')
               %end
           end
       end
   end

   function changeGEWindow(stable_duration_ui, well_ax, spon_paced)
       % BDT CANNOT be equal to 0. 
       if get(stable_duration_ui, 'Value') == 0
           msgbox('T-Wave duration cannot be equal to 0','Oops!');
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 0;
       t_wave_ok = 0;
       GE_ok = 1;
       max_BP_ok = 0;
       min_BP_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           if strcmp(spon_paced, 'spon')
               if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
                   if get(well_ui_con, 'Value') ~= 0
                      %set(submit_in_well_button, 'Visible', 'on')
                      bdt_ok = 1;
                   end
               end
           else
               bdt_ok = 1;
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave')
               if get(well_ui_con, 'Value') ~= 0
                  t_wave_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') ~= 0
                  max_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') ~= 0
                  min_BP_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       if bdt_ok == 1 && t_wave_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
   end

   function submitButtonPushed(submit_in_well_button, well_fig)
       set(well_fig, 'Visible', 'off')
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
