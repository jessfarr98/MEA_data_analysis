function MEA_BDT_PLATE_GUI_V2(RawData, Stims, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, added_wells, bipolar, save_dir, save_base_dir)
%  Create and then hide the UI as it is being constructed.

% TO DO
% Output GUI displaying results for everything with save plots function.  
% t-wave fitting - just pick manually for the ave. picking for S2 beats. Manual analysis more feasible - choose golden electrode and manually analyse. 
% extract data once and feed through scripts to increase speed
% save results
% local vector maps - Georgiadis
% Speed this code up by creating separate file that produces each uifigure for each well and returns required results once it's been submitted - faster than while loop
% Increase robustness - input error handling like no available Stim data for paced data
% Update select wells so it remembers previous clicked well states if clicked again
% heatmaps show more dp's
% bipolar adjacent electrodes 2,2 and 3,2 - single pairs
% beat by beat maximum conduction delay for each well - max diff between act times and then also plot the a.t. for each electrode per beat. 
% make skip well button for this script
% allow average time region to stretch across whole time region
% default input values instead of zero.
% use ratios instead of raw times

% t-wave buttons that allow you to enter a seed start point and then performs the analyses i.e. min point/max point/min dv/dt. 
% fit the t-wave with cubic spline (option only not default).
% rolling average of 11 points to reduce noise. Odd num 5 before and 5
% after each point. Savgol smoothing MATLAB function - select number of points. 
% inflection search 
% min/max
% 0 crossing
% QC with average FPD input from user that then does another t-wave peak picking method if fails

   % Generate the data to plot.   
   %raw_file = fullfile('Y:', 'Recordings for Jess', 'cardiac paced_paced ME 600us(000).raw');
   disp('Generating Input GUI...');
   %disp(stable_ave_analysis);
   close all hidden;
   close all;

   %{
   RawFileData = AxisFile(raw_file);
   
    
     
   RawData = RawFileData.DataSets.LoadData;
   Stims = [];
   if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
       try
           Stims = sort([RawFileData.StimulationEvents(:).EventTime]);
       catch
           spon_paced = 'paced_no_stims';
       end
   end
   %}
   
   shape_data = size(RawData);
    
   num_well_rows = shape_data(1);
   num_well_cols = shape_data(2);
   num_electrode_rows = shape_data(3);
   num_electrode_cols = shape_data(4);
    
   
   added_wells = sort(added_wells);
   %pause(100)
   well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
   if strcmp(added_wells, 'all')
       added_wells_all = [];
       
       %{
       for w_r = 1:num_well_rows
          for w_c = 1:num_well_cols
             wellID = strcat(well_dictionary(w_r), '0', string(w_c));
             added_wells = [added_wells; wellID];
          end
       end
       %}
   end
   
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
   well_t_wave_time_array = [];
   well_t_wave_shape_array = [];
   well_time_reg_start = [];
   well_time_reg_end = [];
   well_stable_dur = [];
   well_fpd_array = [];
   
   well_figure_array = [];
   well_min_bp_array = [];
   well_max_bp_array = [];
   post_spike_array = [];
   stim_spike_array = [];
   filter_intensity_array = [];
   
   well_fig = uifigure;
   well_fig.Name = "PLATE BDT GUI";
   movegui(well_fig,'center');
   well_fig.WindowState = 'maximized';
   
   well_p = uipanel(well_fig, 'BackgroundColor','#f2c2c2', 'Position', [0 0 screen_width screen_height]);

   well_ax = uiaxes(well_p, 'BackgroundColor','#f2c2c2', 'Position', [10 100 screen_width-300 screen_height-200]);
   hold(well_ax, 'on');
   
   found_well = 0;
   for w_r = 1:num_well_rows
       for w_c = 1:num_well_cols
          wellID = strcat(well_dictionary(w_r), '0', string(w_c));

          if ~strcmp(added_wells, 'all')
              if ~contains(added_wells, wellID)
                  continue;
              end
          end
          count = count + 1;

          %time_offset = 0;
          max_voltage = NaN;
          min_voltage = NaN;
          %found_waveform = 0;
          num_well_elec_data = 0;
          for e_r = 1:num_electrode_rows
             for e_c = 1:num_electrode_cols
                RawWellData = RawData{w_r, w_c, e_r, e_c};
                if (strcmp(class(RawWellData),'Waveform'))
                    %if ~empty(WellRawData)
                    %%disp(num_well_rows*num_well_cols)
                    %%disp(count)
                    %found_waveform = 1;
                    electrode_id = strcat(wellID, '_', string(e_r), '_', string(e_c));
                    [time, data] = RawWellData.GetTimeVoltageVector;
                    
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
                    %time_offset = time_offset+0.015;
                    num_well_elec_data = num_well_elec_data+1;
                else
                    %disp(wellID)
                    %disp('no data');
                end
             end
          end
          
          if num_well_elec_data == 0
             %close(well_fig);
             added_wells = setdiff(added_wells, wellID);
             if isempty(added_wells)
                  msgbox('Selected wells have no data to analyse')
                  close(well_fig)
                  return
              end
             continue
          end
          
          found_well = 1;
          if contains(added_wells, 'all')
             added_wells_all = [added_wells_all wellID];
          end
          %hold off;
          
          %hold(well_ax,'off');

       end
        
   end
   if found_well == 0
       
       close(well_fig)
       
   end
   if contains(added_wells, 'all')
      added_wells = added_wells_all;
  end
   
   xlabel(well_ax, 'Seconds (s)');
   ylabel(well_ax, 'Milivolts (mV)');
   
       
   
   return_input_menu_button = uibutton(well_p,'push', 'BackgroundColor', '#B02727', 'Text', 'Return to Main Menu', 'Position',[screen_width-250 360 200 60], 'ButtonPushedFcn', @(return_input_menu_button,event) returnInputMenuPushed());
          
   submit_in_well_button = uibutton(well_p,'push', 'BackgroundColor', '#3dd4d1', 'Text', 'Submit Inputs for Well', 'Position',[screen_width-250 120 200 60], 'ButtonPushedFcn', @(submit_in_well_button,event) submitButtonPushed(submit_in_well_button, well_fig));
   
   set(submit_in_well_button, 'Visible', 'off')

   if strcmp(spon_paced, 'spon') || strcmp(spon_paced, 'paced bdt')
       well_bdt_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'BDT (mV)', 'Position', [10 60 100 40], 'Editable','off');
       well_bdt_ui = uieditfield(well_p, 'numeric', 'Tag', 'BDT','BackgroundColor','#e68e8e', 'Position', [10 10 100 40], 'ValueChangedFcn',@(well_bdt_ui,event) changeBDT(well_bdt_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end)));
   end

   t_wave_up_down_text = uieditfield(well_p, 'Text', 'FontSize', 8,'Value', 'T-wave Peak Analysis', 'Position', [120 60 100 40], 'Editable','off');
   t_wave_up_down_dropdown = uidropdown(well_p, 'FontSize', 8, 'Items', {'minimum', 'maximum', 'inflection'}, 'Position', [120 10 100 40]);
   t_wave_up_down_dropdown.ItemsData = [1 2 3];

   help_button = uibutton(well_p, 'push', 'Text', 'Help', 'Position',[screen_width-200 440 100 60], 'ButtonPushedFcn', @(help_button,event) HelpButtonPushed(t_wave_up_down_dropdown));
     
   t_wave_peak_offset_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'Repol. Time Offset (s)', 'Position', [240 60 100 40], 'Editable','off');
   t_wave_peak_offset_ui = uieditfield(well_p, 'numeric', 'Tag', 'T-Wave Time','BackgroundColor','#e68e8e', 'Position', [240 10 100 40],  'ValueChangedFcn',@(t_wave_peak_offset_ui,event) changeTWaveTime(t_wave_peak_offset_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced, Stims, well_ax, min_voltage, max_voltage));

   t_wave_duration_text = uieditfield(well_p, 'Text', 'FontSize', 8, 'Value', 'T-wave duration (s)', 'Position', [360 60 100 40], 'Editable','off');
   t_wave_duration_ui = uieditfield(well_p, 'numeric', 'Tag', 'T-Wave Dur', 'BackgroundColor','#e68e8e', 'Position', [360 10 100 40],'ValueChangedFcn',@(t_wave_duration_ui,event) changeTWaveDuration(t_wave_duration_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced, Stims, well_ax, min_voltage, max_voltage));

   %est_fpd_text = uieditfield(well_p, 'Text', 'Value', 'Estimated FPD', 'FontSize', 12, 'Position', [480 60 100 40], 'Editable','off');
   %est_fpd_ui = uieditfield(well_p, 'numeric', 'Tag', 'FPD', 'Position', [480 10 100 40], 'FontSize', 12, 'ValueChangedFcn',@(est_fpd_ui,event) changeFPD(est_fpd_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced));

   post_spike_text = uieditfield(well_p, 'Text', 'FontSize', 8, 'Value', 'Post spike hold-off (s)',  'Position', [480 60 100 40], 'Editable','off');
   post_spike_ui = uieditfield(well_p, 'numeric', 'Tag', 'Post-spike', 'BackgroundColor','#e68e8e', 'Position', [480 10 100 40], 'ValueChangedFcn',@(post_spike_ui,event) changePostSpike(post_spike_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced,  Stims, min_voltage, max_voltage, well_ax));

   
   filter_intensity_text = uieditfield(well_p, 'Text', 'FontSize', 8, 'Value', 'Filtering Intensity', 'Position', [600 60 100 40], 'Editable','off');
   filter_intensity_dropdown = uidropdown(well_p, 'Items', {'none', 'low', 'medium', 'strong'}, 'FontSize', 8,'Position', [600 10 100 40]);
   filter_intensity_dropdown.ItemsData = [1 2 3 4];
   
   if strcmp(spon_paced, 'spon')

      min_bp_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'Min. BP (s)', 'Position', [720 60 100 40], 'Editable','off');
      min_bp_ui = uieditfield(well_p, 'numeric', 'Tag', 'Min BP', 'BackgroundColor','#e68e8e', 'Position', [720 10 100 40], 'ValueChangedFcn',@(min_bp_ui,event) changeMinBPDuration(min_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced));

      max_bp_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'Max. BP (s)', 'Position', [840 60 100 40], 'Editable','off');
      max_bp_ui = uieditfield(well_p, 'numeric', 'Tag', 'Max BP', 'BackgroundColor','#e68e8e', 'Position', [840 10 100 40], 'ValueChangedFcn',@(max_bp_ui,event) changeMaxBPDuration(max_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced));

   elseif strcmp(spon_paced, 'paced bdt')
      min_bp_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'Min. BP (s)', 'Position', [720 60 100 40], 'Editable','off');
      min_bp_ui = uieditfield(well_p, 'numeric', 'Tag', 'Min BP', 'BackgroundColor','#e68e8e', 'Position', [720 10 100 40], 'ValueChangedFcn',@(min_bp_ui,event) changeMinBPDuration(min_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced));

      max_bp_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'Max. BP (s)',  'Position', [840 60 100 40], 'Editable','off');
      max_bp_ui = uieditfield(well_p, 'numeric', 'Tag', 'Max BP', 'BackgroundColor','#e68e8e', 'Position', [840 10 100 40], 'ValueChangedFcn',@(max_bp_ui,event) changeMaxBPDuration(max_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced));

      stim_spike_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'Stim. Spike hold-off (s)', 'Position', [960 60 100 40], 'Editable','off');
      stim_spike_ui = uieditfield(well_p, 'numeric', 'Tag', 'Stim spike', 'BackgroundColor','#e68e8e', 'Position', [960 10 100 40],  'ValueChangedFcn',@(stim_spike_ui,event) changeStimSpike(stim_spike_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced, Stims, min_voltage, max_voltage, well_ax));

   elseif strcmp(spon_paced, 'paced') 
      stim_spike_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'Stim. Spike hold-off (s)', 'Position', [720 60 100 40], 'Editable','off');
      stim_spike_ui = uieditfield(well_p, 'numeric', 'Tag', 'Stim spike', 'BackgroundColor','#e68e8e', 'Position', [720 10 100 40],  'ValueChangedFcn',@(stim_spike_ui,event) changeStimSpike(stim_spike_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, time(end), spon_paced, Stims, min_voltage, max_voltage, well_ax));

   end

   %disp(beat_to_beat);
   if strcmp(beat_to_beat, 'on')

      if strcmp(analyse_all_b2b, 'time_region')
          time_start_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'B2B Time region start time (s)',  'Position', [1080 60 100 40], 'Editable','off');
          time_start_ui = uieditfield(well_p, 'numeric', 'Tag', 'Start Time', 'BackgroundColor','#e68e8e', 'Position', [1080 10 100 40],  'ValueChangedFcn',@(time_start_ui,event) changeStartTime(time_start_ui, well_ax, min_voltage, max_voltage, time(end), spon_paced));

          time_end_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'B2B Time region end time (s)', 'Position', [1200 60 100 40], 'Editable','off');
          time_end_ui = uieditfield(well_p, 'numeric', 'Tag', 'End Time', 'BackgroundColor','#e68e8e', 'Position', [1200 10 100 40], 'ValueChangedFcn',@(time_end_ui,event) changeEndTime(time_end_ui, well_ax, min_voltage, max_voltage, time(end), spon_paced));
          set(time_end_ui, 'Value', time(end))
          time_region_plot_data = linspace(min_voltage, max_voltage);
          start_data = ones(length(time_region_plot_data), 1);
          start_data(:,1) = 0;
          end_data = ones(length(time_region_plot_data), 1);
          end_data(:,1) = time(end);
          plot(well_ax, start_data, time_region_plot_data)
          plot(well_ax, end_data, time_region_plot_data)

      end
   else
      if strcmp(stable_ave_analysis, 'time_region')
          time_start_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'Ave. Waveform time region start time (s)', 'Position', [1080 60 100 40], 'Editable','off');
          time_start_ui = uieditfield(well_p, 'numeric', 'Tag', 'Start Time', 'BackgroundColor','#e68e8e', 'Position', [1080 10 100 40],  'ValueChangedFcn',@(time_start_ui,event) changeStartTime(time_start_ui, well_ax, min_voltage, max_voltage, time(end), spon_paced));

          time_end_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'Ave. Waveform time region end time (s)',  'Position', [1200 60 100 40], 'Editable','off');
          time_end_ui = uieditfield(well_p, 'numeric', 'Tag', 'End Time', 'BackgroundColor','#e68e8e', 'Position', [1200 10 100 40],  'ValueChangedFcn',@(time_end_ui,event) changeEndTime(time_end_ui, well_ax, min_voltage, max_voltage, time(end), spon_paced));
          set(time_end_ui, 'Value', time(end))
          time_region_plot_data = linspace(min_voltage, max_voltage);
          start_data = ones(length(time_region_plot_data), 1);
          start_data(:,1) = 0;
          end_data = ones(length(time_region_plot_data), 1);
          end_data(:,1) = time(end);
          plot(well_ax, start_data, time_region_plot_data)
          plot(well_ax, end_data, time_region_plot_data)

      end
      if strcmp(stable_ave_analysis, 'stable')
          %sliding time window to find the elctrode with the most stable beat period and then compute average waveform using this region
          stable_duration_text = uieditfield(well_p,'Text', 'FontSize', 8, 'Value', 'Time Window for GE average waveform (s)', 'Position', [1080 60 100 40], 'Editable','off');
          stable_duration_ui = uieditfield(well_p, 'numeric', 'Tag', 'GE Window', 'BackgroundColor','#e68e8e', 'Position', [1080 10 100 40], 'ValueChangedFcn',@(stable_duration_ui,event) changeGEWindow(stable_duration_ui, well_ax, spon_paced));


      end
   end

   if strcmp(spon_paced, 'spon') ||strcmp(spon_paced, 'paced bdt')
      init_bdt_data = ones(length(time), 1);
      init_bdt_data(:,1) = 0;
      plot(well_ax, time, init_bdt_data);
   end

   while(1)
     pause(0.01)
     if ~ishandle(well_fig)
         return
     end 
     if strcmp(get(well_fig, 'Visible'), 'off')
        break; 
     end
   end
   

   %{
   well_figure_array = [well_figure_array; well_fig];
   post_spike_array = [post_spike_array; get(post_spike_ui, 'Value')];
   well_t_wave_dur_array = [well_t_wave_dur_array; get(t_wave_duration_ui, 'Value')];
   well_t_wave_shape_array = [well_t_wave_shape_array; get(t_wave_up_down_dropdown, 'Value')];
   well_t_wave_time_array = [well_t_wave_time_array; get(t_wave_peak_offset_ui, 'Value')];
   well_fpd_array = [well_fpd_array; get(est_fpd_ui, 'Value')];

   if strcmp(spon_paced, 'spon')
      well_bdt_array = [well_bdt_array; get(well_bdt_ui, 'Value')];
      well_min_bp_array = [well_min_bp_array; get(min_bp_ui, 'Value')];
      well_max_bp_array = [well_max_bp_array; get(max_bp_ui, 'Value')];
   elseif strcmp(spon_paced, 'paced bdt')
      well_bdt_array = [well_bdt_array; get(well_bdt_ui, 'Value')];
      well_min_bp_array = [well_min_bp_array; get(min_bp_ui, 'Value')];
      well_max_bp_array = [well_max_bp_array; get(max_bp_ui, 'Value')];
      stim_spike_array = [stim_spike_array; get(stim_spike_ui, 'Value')];
   else
      stim_spike_array = [stim_spike_array; get(stim_spike_ui, 'Value')];
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
   %disp(size(well_t_wave_shape_array));
   %disp(well_t_wave_shape_array(1, :))
   
   if strcmp(spon_paced, 'spon') || strcmp(spon_paced, 'paced bdt')
      well_bdt_array = well_bdt_array./1000;
   end
     
   %disp(well_min_bp_array);
   %disp(well_max_bp_array);
   %}
   

   post_spike_array = repmat(get(post_spike_ui, 'Value'), length(added_wells));
   well_t_wave_dur_array = repmat(get(t_wave_duration_ui, 'Value'), length(added_wells));
   well_t_wave_shape_array = repmat(get(t_wave_up_down_dropdown, 'Value'), length(added_wells));
   well_t_wave_time_array = repmat(get(t_wave_peak_offset_ui, 'Value'), length(added_wells));
   filter_intensity_array = repmat(get(filter_intensity_dropdown, 'Value'), length(added_wells));
   
   %well_fpd_array = repmat(get(est_fpd_ui, 'Value'), length(added_wells));

   if strcmp(spon_paced, 'spon')
      well_bdt_array = repmat(get(well_bdt_ui, 'Value'), length(added_wells), 1);
      well_min_bp_array = repmat(get(min_bp_ui, 'Value'), length(added_wells), 1);
      well_max_bp_array = repmat(get(max_bp_ui, 'Value'), length(added_wells), 1);
   elseif strcmp(spon_paced, 'paced bdt')
      well_bdt_array = repmat(get(well_bdt_ui, 'Value'), length(added_wells), 1);
      well_min_bp_array = repmat(get(min_bp_ui, 'Value'), length(added_wells), 1);
      well_max_bp_array = repmat(get(max_bp_ui, 'Value'), length(added_wells), 1);
      stim_spike_array = repmat(get(stim_spike_ui, 'Value'), length(added_wells), 1);
   else
      stim_spike_array = repmat(get(stim_spike_ui, 'Value'), length(added_wells), 1);
   end

   if strcmp(beat_to_beat, 'on')
      if strcmp(analyse_all_b2b, 'time_region')
          well_time_reg_start = repmat(get(time_start_ui, 'Value'), length(added_wells), 1);
          well_time_reg_end = repmat(get(time_end_ui, 'Value'), length(added_wells), 1);
      end
   else
      if strcmp(stable_ave_analysis, 'time_region')
          well_time_reg_start = repmat(get(time_start_ui, 'Value'), length(added_wells), 1);
          well_time_reg_end = repmat(get(time_end_ui, 'Value'), length(added_wells));
      elseif strcmp(stable_ave_analysis, 'stable')
          well_stable_dur  = repmat(get(stable_duration_ui, 'Value'), length(added_wells), 1); 

      end
   end

   %disp(size(well_t_wave_shape_array));
   %disp(well_t_wave_shape_array(1, :))
   
   if strcmp(spon_paced, 'spon') || strcmp(spon_paced, 'paced bdt')
      well_bdt_array = well_bdt_array./1000;
   end
     
   %disp(post_spike_array)
   %disp(well_t_wave_dur_array);
   %disp(well_max_bp_array);
   close(well_fig)
   
   analyse_MEA_signals_GUI(RawData, Stims, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_bdt_array, well_t_wave_dur_array, well_t_wave_shape_array, well_time_reg_start, well_time_reg_end, well_stable_dur, added_wells, well_min_bp_array, well_max_bp_array, bipolar, post_spike_array, stim_spike_array, well_t_wave_time_array, well_fpd_array, filter_intensity_array, fullfile(save_dir, save_base_dir))

   function returnInputMenuPushed()
        %MEA_GUI(raw_file, save_dir)
        MEA_GUI_Return(RawData, Stims, save_dir, 0)
   end

   function HelpButtonPushed(t_wave_up_down_dropdown)
        help_fig = uifigure;
        movegui(help_fig,'center');
        help_fig.WindowState = 'maximized';
        
        help_p = uipanel(help_fig, 'BackgroundColor','#f2c2c2', 'Position', [0 0 screen_width screen_height]);
        
        close_help_button = uibutton(help_p, 'push', 'Text', 'close', 'Position',[screen_width-250 50 60 60], 'ButtonPushedFcn', @(close_help_button,event) closeHelpButtonPushed());
     
        if screen_height <= 1200
            im_height = screen_height-80;
            
        else
            
            im_height = 1200;
            
        end
        
        if screen_width <= 800
            im_width = screen_width -300;
        else
            
            im_width = 800;
        end
        im_horz_offset = (screen_width/2)-(im_width/2);
          
        
        
        if strcmp(spon_paced, 'spon')
            if get(t_wave_up_down_dropdown, 'Value') == 1
                im = uiimage(help_p, 'ImageSource', 'spontaneous downwards t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 2
                im = uiimage(help_p, 'ImageSource', 'spontaneous upwards t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 3
                im = uiimage(help_p, 'ImageSource', 'spontaneous polynomial t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            end
        elseif strcmp(spon_paced, 'paced')
            if get(t_wave_up_down_dropdown, 'Value') == 1
                im = uiimage(help_p, 'ImageSource', 'paced data downwards t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 2
                im = uiimage(help_p, 'ImageSource', 'paced data upwards t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 3
                im = uiimage(help_p, 'ImageSource', 'paced data polynomial t-wave png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            end
        elseif strcmp(spon_paced, 'paced bdt')
            if get(t_wave_up_down_dropdown, 'Value') == 1
                im = uiimage(help_p, 'ImageSource', 'paced ectopic downwards png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 2
                im = uiimage(help_p, 'ImageSource', 'paced ectopic upwards png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            elseif get(t_wave_up_down_dropdown, 'Value') == 3
                im = uiimage(help_p, 'ImageSource', 'paced ectopic polynomial png.png', 'Position', [im_horz_offset 20 im_width im_height]);
    
            end
         
            
        end
        
       function closeHelpButtonPushed()
          close(help_fig); 
       end
       
        
   end

   function skipWellButtonPushed(skip_well_button, wellID, well_fig)
        set(well_fig, 'Visible', 'off')
        skip_well = 1;
        added_wells = setdiff(added_wells, wellID);
   end

   function changeBDT(well_bdt_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time)

       % BDT CANNOT be equal to 0. 
       if get(well_bdt_ui, 'Value') == 0
           msgbox('BDT cannot be equal to 0','Oops!');
           set(well_bdt_ui, 'BackgroundColor','#e68e8e')
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           
           well_pan_components = get(well_p, 'Children');
           for i = 1:length(well_pan_components)
           
              well_ui_con = well_pan_components(i);
              if strcmp(string(get(well_ui_con, 'Type')), 'axes')
                 axes_children = get(well_ui_con, 'Children');
           
                 for c = 1:length(axes_children)
                     child_y_data = axes_children(c).YData;
                     if length(child_y_data) ~= 1
                         if child_y_data(1) == child_y_data(:)
                             prev_bdt_plot = axes_children(c);
                             break;
                         end
                     end


                 end
               
                 bdt_data = ones(length(prev_bdt_plot.XData), 1);
                 bdt_data(:,1) = get(well_bdt_ui, 'Value');
                 prev_bdt_plot.YData = bdt_data;
              end
           end
           return;
       end
       
       set(well_bdt_ui, 'BackgroundColor','white')
       
       
       well_pan_components = get(well_p, 'Children');
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       min_BP_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       post_spike_ok = 1;
       stim_spike_ok = 1;
       
       for i = 1:length(well_pan_components)
           
           well_ui_con = well_pan_components(i);
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
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
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
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
           
           if strcmp(string(get(well_ui_con, 'Type')), 'axes')
               axes_children = get(well_ui_con, 'Children');
           
               for c = 1:length(axes_children)
                   child_y_data = axes_children(c).YData;
                   if length(child_y_data) ~= 1
                       if child_y_data(1) == child_y_data(:)
                           prev_bdt_plot = axes_children(c);
                           break;
                       end
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
       if t_wave_time_ok == 1 && fpd_ok == 1 && t_wave_dur_ok == 1 && stim_spike_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && min_BP_ok == 1 && post_spike_ok == 1 && max_BP_ok ==1 && GE_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
   end

    function changeTWaveTime(t_wave_time_offset_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced, Stims, well_ax, min_voltage, max_voltage)
       %disp('change T-wave time')
       %%disp('function entered')
       %%disp(length(well_bdt_ui_array))
       %%disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(t_wave_time_offset_ui, 'Value') == 0
           set(t_wave_time_offset_ui, 'BackgroundColor','#e68e8e')
           msgbox('T-Wave peak time cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           axes_children = get(well_ax, 'Children');
           
           t_wave_y_data = linspace(min_voltage*0.25, max_voltage*0.25);
           for ch = 1:length(axes_children)
              ch_y_data = axes_children(ch).YData;
              ch_x_data = axes_children(ch).XData;
              if size(ch_y_data) == size(t_wave_y_data)
                  delete(axes_children(ch))
              end
           end
           return;
       end
       
       set(t_wave_time_offset_ui, 'BackgroundColor','white')
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       min_BP_ok = 1;
       post_spike_ok = 1;
       post_spike_hold_off = NaN;
       stim_spike_hold_off = NaN;
       stim_spike_ok = 1;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end

           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   t_wave_dur = get(well_ui_con, 'Value');
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
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                  post_spike_hold_off = get(well_ui_con, 'Value');
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                   stim_spike_hold_off = get(well_ui_con, 'Value');
                   stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
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
       if bdt_ok == 1 && fpd_ok == 1 && t_wave_dur_ok == 1 && stim_spike_ok == 1 && start_time_ok == 1 && post_spike_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           %disp('set vis')
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       %disp(post_spike_ok)
       if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
       % Pace analysis uses stim spike holdoff too
           if t_wave_dur_ok == 1
               
               t_wave_start_window = Stims - (t_wave_dur/2) + get(t_wave_time_offset_ui, 'Value');
               t_wave_end_window = Stims + (t_wave_dur/2) + get(t_wave_time_offset_ui, 'Value');
               if t_wave_start_window < Stims + post_spike_hold_off
                   t_wave_start_window = Stims + post_spike_hold_off;
               end
               
               axes_children = get(well_ax, 'Children');
       
               % boxes are smaller magnitudes than max_voltage-min_voltage
               
               % Find all x values equal to t-wave start windows
               found_plot_box = 0;
               
               y_data = linspace(min_voltage*0.25, max_voltage*0.25);
               for c = 1:length(axes_children)
                   child_y_data = axes_children(c).YData;
                   
                   if size(child_y_data) == size(y_data)
                   %if ismember(t_wave_start_window, child_x_data(1, 1))
                       if child_y_data(1) == y_data(1)
                           found_plot_box = 1;
                           break;
                       end
                   end
               end
               
               if found_plot_box == 1
                   for i = 1:length(t_wave_end_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_end_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   for i = 1:length(t_wave_start_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   
                                   child_x_data(:) = t_wave_start_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   
               else
                   hold(well_ax, 'on')
                   
                   for i = 1:length(t_wave_start_window)                       
                       x_start_data = ones(length(y_data), 1);
                       x_end_data = ones(length(y_data), 1);
                       x_start_data(:,1) = t_wave_start_window(i);
                       x_end_data(:,1) = t_wave_end_window(i);
                       plot(well_ax, x_start_data, y_data, 'b')
                       plot(well_ax, x_end_data, y_data, 'b')
                   end
                   hold(well_ax, 'off')
               end

           end
       end
       
       
   end

   function changeTWaveDuration(t_wave_duration_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced, Stims, well_ax, min_voltage, max_voltage)
       %disp('change T-wave duration')
       %%disp('function entered')
       %%disp(length(well_bdt_ui_array))
       %%disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(t_wave_duration_ui, 'Value') == 0
           set(t_wave_duration_ui, 'BackgroundColor','#e68e8e')
           msgbox('T-Wave duration cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           
           axes_children = get(well_ax, 'Children');
           
           t_wave_y_data = linspace(min_voltage*0.25, max_voltage*0.25);
           for ch = 1:length(axes_children)
              ch_y_data = axes_children(ch).YData;
              ch_x_data = axes_children(ch).XData;
              if size(ch_y_data) == size(t_wave_y_data)
                  delete(axes_children(ch))
              end
           end
           return;
       end
       
       set(t_wave_duration_ui, 'BackgroundColor', 'white')
       
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       min_BP_ok = 1;
       post_spike_ok = 1;
       post_spike_hold_off = NaN;
       stim_spike_hold_off = NaN;
       stim_spike_ok = 1;
       t_wave_time_ok = 0;
       fpd_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
    
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end

           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   t_wave_offset = get(well_ui_con, 'Value');
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
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                  post_spike_hold_off = get(well_ui_con, 'Value');
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                   stim_spike_hold_off = get(well_ui_con, 'Value');
                   stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
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
       if bdt_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && stim_spike_ok == 1 && start_time_ok == 1 && post_spike_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           %disp('set vis')
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       %disp(post_spike_ok)
       if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
       % Pace analysis uses stim spike holdoff too
           if t_wave_time_ok == 1 
               
               t_wave_start_window = Stims+ t_wave_offset - (get(t_wave_duration_ui, 'Value')/2);
               t_wave_end_window = Stims+ t_wave_offset + (get(t_wave_duration_ui, 'Value')/2);
               if t_wave_start_window < Stims + post_spike_hold_off
                   t_wave_start_window = Stims + post_spike_hold_off;
               end
               
               axes_children = get(well_ax, 'Children');
       
               % boxes are smaller magnitudes than max_voltage-min_voltage
               
               % Find all x values equal to t-wave start windows
               found_plot_box = 0;
               
               y_data = linspace(min_voltage*0.25, max_voltage*0.25);
               for c = 1:length(axes_children)
                   child_y_data = axes_children(c).YData;
                   
                   if size(child_y_data) == size(y_data)
                   %if ismember(t_wave_start_window, child_x_data(1, 1))
                       if child_y_data(1) == y_data(1)
                           found_plot_box = 1;
                           break;
                       end
                   end
               end
               
               if found_plot_box == 1
                   for i = 1:length(t_wave_end_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_end_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   for i = 1:length(t_wave_start_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   
                                   child_x_data(:) = t_wave_start_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   
               else
                   hold(well_ax, 'on')
                   
                   for i = 1:length(t_wave_start_window)                       
                       x_start_data = ones(length(y_data), 1);
                       x_end_data = ones(length(y_data), 1);
                       x_start_data(:,1) = t_wave_start_window(i);
                       x_end_data(:,1) = t_wave_end_window(i);
                       plot(well_ax, x_start_data, y_data, 'b')
                       plot(well_ax, x_end_data, y_data, 'b')
                   end
                   hold(well_ax, 'off')
               end

           end
       end
       
       
   end

   function changePostSpike(post_spike_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced, Stims, min_voltage, max_voltage, well_ax)
       
       % BDT CANNOT be equal to 0. 
       if get(post_spike_ui, 'Value') == 0
           set(post_spike_ui, 'BackgroundColor','#e68e8e')
           msgbox('Post spike hold-off cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           return;
       end
       
       set(post_spike_ui, 'BackgroundColor', 'white')
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       min_BP_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       t_wave_duration = NaN;
       stim_spike_ok = 1;
       stim_spike_hold_off = NaN;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
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
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_hold_off = get(well_ui_con, 'Value');
                  stim_spike_ok = 0;
               end
           end
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
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
       
       %{
       if strcmp(spon_paced, 'paced')
           if t_wave_ok == 1 && stim_spike_ok == 1
               % replot
               t_wave_start_window = Stims+get(post_spike_ui, 'Value')+stim_spike_hold_off;
               t_wave_end_window = Stims+stim_spike_hold_off+get(post_spike_ui, 'Value')+t_wave_duration;
               
               axes_children = get(well_ax, 'Children');
       
               % boxes are smaller magnitudes than max_voltage-min_voltage
               
               % Find all x values equal to t-wave start windows
               found_plot_box = 0;
               
               y_data = linspace(min_voltage*0.5, max_voltage*0.5);
               for c = 1:length(axes_children)
                   child_y_data = axes_children(c).YData;
                   
                   if size(child_y_data) == size(y_data)
                   %if ismember(t_wave_start_window, child_x_data(1, 1))
                       found_plot_box = 1;
                       break;
                   end
               end
               
               if found_plot_box == 1
                   for i = 1:length(t_wave_end_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_end_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   for i = 1:length(t_wave_start_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_start_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   
               else
                   hold(well_ax, 'on')
                   
                   for i = 1:length(t_wave_start_window)                       
                       x_start_data = ones(length(y_data), 1);
                       x_end_data = ones(length(y_data), 1);
                       x_start_data(:,1) = t_wave_start_window(i);
                       x_end_data(:,1) = t_wave_end_window(i);
                       plot(well_ax, x_start_data, y_data)
                       plot(well_ax, x_end_data, y_data)
                   end
                   hold(well_ax, 'off')
               end

           end
       end
       %}
       
       if bdt_ok == 1 && start_time_ok == 1 && stim_spike_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
   end

    function changeStimSpike(stim_spike_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced, Stims, min_voltage, max_voltage, well_ax)
       
       % BDT CANNOT be equal to 0. 
       if get(stim_spike_ui, 'Value') == 0
           set(stim_spike_ui, 'BackgroundColor','#e68e8e')
           msgbox('Stim spike hold-off cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
              
          axes_children = get(well_ax, 'Children');
           
          t_wave_y_data = linspace(min_voltage*0.25, max_voltage*0.25);
          for ch = 1:length(axes_children)
              ch_y_data = axes_children(ch).YData;
              ch_x_data = axes_children(ch).XData;
              if size(ch_y_data) == size(t_wave_y_data)
                  continue
              end
              if size(ch_y_data) == 1
                  delete(axes_children(ch))
              end
          end

          return;
       end
       
       set(stim_spike_ui, 'BackgroundColor', 'white')
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       min_BP_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       post_spike_ok = 1;
       post_spike_hold_off = NaN;
       t_wave_duration = NaN;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end
          
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
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
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                   post_spike_hold_off = get(well_ui_con, 'Value');
                   post_spike_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
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
       %%disp(spon_paced)
       if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
           % replot
           stim_hold_offs = Stims + get(stim_spike_ui, 'Value');
           stim_hold_off_points = [];
           stim_y_points = [];
           
           axes_children = get(well_ax, 'Children');
           
           t_wave_y_data = linspace(min_voltage*0.25, max_voltage*0.25);
           for i = 1:length(stim_hold_offs)
               for ch = 1:length(axes_children)
                   ch_y_data = axes_children(ch).YData;
                   ch_x_data = axes_children(ch).XData;
                   if size(ch_y_data) == size(t_wave_y_data)
                       continue
                   end
                   if size(ch_y_data) == 1
                       continue
                   else
                       if ch_y_data(1) == ch_y_data(:)    
                          continue 
                       end
                   end
                   x_point = stim_hold_offs(i) + ch_x_data(1);
                   x_indx = find(ch_x_data >= x_point);
                   x_indx = x_indx(1);

                   x_point = ch_x_data(x_indx);
                   y_point = ch_y_data(x_indx);
                   stim_hold_off_points = [stim_hold_off_points; x_point];
                   stim_y_points = [stim_y_points; y_point];
               end
           end
           
           %%disp(stim_hold_off_points)

           % boxes are smaller magnitudes than max_voltage-min_voltage

           % Find all x values equal to t-wave start windows
           found_stim_point = 0;
           
           for c = 1:length(axes_children)
               child_y_data = axes_children(c).YData;

               if size(child_y_data) == 1
               %if ismember(t_wave_start_window, child_x_data(1, 1))
                   
                   if ch_y_data(1) == ch_y_data(:)    
                      continue 
                   end

                   found_stim_point = 1;
                   break;
               end
           end

           if found_stim_point == 1
               for i = 1:length(stim_hold_off_points)
                   for c = 1:length(axes_children)
                       child_y_data = axes_children(c).YData;
                       child_x_data = axes_children(c).XData;

                       %%disp(child_x_data)
                       if size(child_y_data) == size(t_wave_y_data)
                           continue
                       elseif size(child_y_data) == 1
                           if ~ismember(child_x_data(1), stim_hold_off_points)
                               axes_children(c).XData = stim_hold_off_points(i);
                               axes_children(c).YData = stim_y_points(i);
                               %{
                               for ch = 1:length(axes_children)
                                   ch_y_data = axes_children(ch).YData;
                                   ch_x_data = axes_children(ch).XData;
                                   if size(ch_y_data) == size(t_wave_y_data)
                                       continue
                                   end
                                   if size(ch_y_data) == 1
                                       continue
                                   end
                                   x_point = stim_hold_off_points(i);
                                   x_indx = find(ch_x_data >= x_point);
                                   x_indx = x_indx(1);
                                   
                                   y_point = ch_y_data(x_indx)
                                   x_point = ch_x_data(x_indx)
                                   axes_children(c).XData = x_point;
                                   axes_children(c).YData = y_point;
                                   break;
                               end
                               %}
                               
                               break;
                           end
                       end
                   end
               end
               
           else
               hold(well_ax, 'on')

               for i = 1:length(stim_hold_off_points)  
 
                  plot(well_ax, stim_hold_off_points(i), stim_y_points(i), 'r.', 'MarkerSize', 20)                  
                   

               end
               hold(well_ax, 'off')
           end

       end
  

       %{
       if strcmp(spon_paced, 'paced')
           if t_wave_ok == 1 && post_spike_ok == 1
               % replot
               t_wave_start_window = Stims+get(stim_spike_ui, 'Value')+post_spike_hold_off;
               t_wave_end_window = Stims+get(stim_spike_ui, 'Value')+t_wave_duration+post_spike_hold_off;
               
               axes_children = get(well_ax, 'Children');
       
               % boxes are smaller magnitudes than max_voltage-min_voltage
               
               % Find all x values equal to t-wave start windows
               found_plot_box = 0;
               
               y_data = linspace(min_voltage*0.5, max_voltage*0.5);
               for c = 1:length(axes_children)
                   child_y_data = axes_children(c).YData;
                   
                   if size(child_y_data) == size(y_data)
                   %if ismember(t_wave_start_window, child_x_data(1, 1))
                       found_plot_box = 1;
                       break;
                   end
               end
               
               if found_plot_box == 1
                   for i = 1:length(t_wave_end_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_end_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   for i = 1:length(t_wave_start_window)
                       for c = 1:length(axes_children)
                           child_y_data = axes_children(c).YData;
                           child_x_data = axes_children(c).XData;

                           if size(child_y_data) == size(y_data)
                               if ~ismember(child_x_data(1,1), t_wave_start_window) && ~ismember(child_x_data(1,1), t_wave_end_window)
                                   child_x_data(:) = t_wave_start_window(i);
                                   axes_children(c).XData = child_x_data;
                                   break;
                               end
                           end
                       end
                   end
                   
               else
                   hold(well_ax, 'on')
                   
                   for i = 1:length(t_wave_start_window)                       
                       x_start_data = ones(length(y_data), 1);
                       x_end_data = ones(length(y_data), 1);
                       x_start_data(:,1) = t_wave_start_window(i);
                       x_end_data(:,1) = t_wave_end_window(i);
                       plot(well_ax, x_start_data, y_data)
                       plot(well_ax, x_end_data, y_data)
                   end
                   hold(well_ax, 'off')
               end

           end
       end
       %}
       
       if bdt_ok == 1 && start_time_ok == 1 && post_spike_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
       
       
   end

    function changeMinBPDuration(min_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced)
       %%disp('change T-wave duration')
       %%disp('function entered')
       %%disp(length(well_bdt_ui_array))
       %%disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(min_bp_ui, 'Value') == 0
           set(min_bp_ui, 'BackgroundColor','#e68e8e')
           msgbox('Min BP cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           return;
       end
       
       set(min_bp_ui, 'BackgroundColor', 'white')
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       max_BP_ok = 0;
       post_spike_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       stim_spike_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           

           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
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
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
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
       if bdt_ok == 1 && stim_spike_ok == 1 && post_spike_ok == 1 && t_wave_time_ok == 1 && fpd_ok == 1 && t_wave_dur_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && GE_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
    end

    function changeMaxBPDuration(max_bp_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced)
       %%disp('change T-wave duration')
       %%disp('function entered')
       %%disp(length(well_bdt_ui_array))
       %%disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(max_bp_ui, 'Value') == 0
           set(max_bp_ui, 'BackgroundColor','#e68e8e')
           msgbox('Min BP cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           return;
       end
       
       set(max_bp_ui, 'BackgroundColor', 'white')
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       min_BP_ok = 0;
       post_spike_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       stim_spike_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
   
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
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
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
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
            
           if strcmp(string(get(well_ui_con, 'Tag')), 'GE Window')
               if get(well_ui_con, 'Value') == 0
                  GE_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
       end 
       if bdt_ok == 1 && stim_spike_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && post_spike_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
   end

    function changeFPD(fpd_ui, well_p, submit_in_well_button, beat_to_beat, analyse_all_b2b, stable_ave_analysis, orig_end_time, spon_paced)
       %%disp('change T-wave duration')
       %%disp('function entered')
       %%disp(length(well_bdt_ui_array))
       %%disp(get(p, 'Children'))
       
       % BDT CANNOT be equal to 0. 
       if get(fpd_ui, 'Value') == 0
           msgbox('Max BP cannot be equal to 0','Oops!');
           return;
       end
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       start_time_ok = 1;
       end_time_ok = 1;
       GE_ok = 1;
       min_BP_ok = 0;
       max_BP_ok = 0;
       post_spike_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       stim_spike_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
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
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_ok = 0;
               end
           end
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
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
       if bdt_ok == 1 && stim_spike_ok == 1 && max_BP_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && post_spike_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && GE_ok == 1 && min_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
       
   end


   function changeStartTime(time_start_ui, well_ax, min_voltage, max_voltage, orig_end_time, spon_paced)
       if get(time_start_ui, 'Value') >= get(time_end_ui, 'Value')
           set(time_start_ui, 'BackgroundColor','#e68e8e')
           msgbox('Time region start time must be less than the end time.','Oops!');
           set(time_start_ui, 'Value', 0);
           
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           
       else
           set(time_start_ui, 'BackgroundColor', 'white')
       end
       axes_children = get(well_ax, 'Children');
       
       time_region_plots = [];
       ydata = linspace(min_voltage, max_voltage);
       for c = 1:length(axes_children)
           child_x_data = axes_children(c).XData;
           child_y_data = axes_children(c).YData;
           %%disp(child_x_data(1))
           %%disp(floor(child_x_data(1)))
           if size(child_y_data) == size(ydata)
               if child_y_data(1) == ydata(1)
                  time_region_plots = [time_region_plots; axes_children(c)];
               end
               %break;
           end
       end
       
       plot1 = time_region_plots(1);
       plot2 = time_region_plots(2);
       %disp(plot1.XData(1));
       %disp(plot2.XData(1));
       if plot1.XData(1) < plot2.XData(1)
           prev_start_plot = plot1;
       else
           prev_start_plot = plot2;
       end
       %disp(prev_start_plot.XData(1));
       
       %set(prev_start_plot, 'Visible', 'off');
       %hold(well_ax, 'on');
       
       xdata = ones(length(ydata), 1);
       xdata(:,1) = get(time_start_ui, 'Value');
       %plot(well_ax, xdata, ydata)
       %hold(well_ax, 'off');
       prev_start_plot.XData = xdata;
       
       if get(time_start_ui, 'Value') ~= 0
           well_pan_components = get(well_p, 'Children');
           bdt_ok = 1;
           start_time_ok = 1;
           end_time_ok = 1;
           t_wave_time_ok = 0;
           t_wave_dur_ok = 0;
           fpd_ok = 1;
           GE_ok = 1;
           max_BP_ok = 1;
           min_BP_ok = 1;
           post_spike_ok = 1;
           stim_spike_ok = 1;
           for i = 1:length(well_pan_components)
               well_ui_con = well_pan_components(i);
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
                   if get(well_ui_con, 'Value') == 0
                      %set(submit_in_well_button, 'Visible', 'on')
                      bdt_ok = 0;
                   end
               end
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
                   if get(well_ui_con, 'Value') ~= 0 
                       t_wave_time_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
                   if get(well_ui_con, 'Value') ~= 0 
                       t_wave_dur_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
                   if get(well_ui_con, 'Value') == 0
                      fpd_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
                   if get(well_ui_con, 'Value') == 0
                      stim_spike_ok = 0;
                   end
               end
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
                   if get(well_ui_con, 'Value') == 0
                      post_spike_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
                   if get(well_ui_con, 'Value') == 0
                      min_BP_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
                   if get(well_ui_con, 'Value') == 0
                      max_BP_ok = 0;
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
           if bdt_ok == 1 && stim_spike_ok == 1 && post_spike_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && GE_ok == 1
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
           set(time_end_ui, 'BackgroundColor','#e68e8e')
           set(time_end_ui, 'Value', orig_end_time);
           
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
           
           
           
           return;
       else
           set(time_end_ui, 'BackgroundColor','white')
       end
       
       
       axes_children = get(well_ax, 'Children');
       
       time_region_plots = [];
       ydata = linspace(min_voltage, max_voltage);
       for c = 1:length(axes_children)
           child_x_data = axes_children(c).XData;
           child_y_data = axes_children(c).YData;
           if size(child_y_data) == size(ydata)
               if child_y_data(1) == ydata(1)
                  time_region_plots = [time_region_plots; axes_children(c)];
               end
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
       
       xdata = ones(length(ydata), 1);
       xdata(:,1) = get(time_end_ui, 'Value');
       %plot(well_ax, xdata, ydata)
       %hold(well_ax, 'off');
       prev_start_plot.XData = xdata;
       
       if get(time_end_ui, 'Value') ~= orig_end_time
           well_pan_components = get(well_p, 'Children');
           bdt_ok = 1;
           start_time_ok = 1;
           end_time_ok = 1;
           t_wave_time_ok = 0;
           t_wave_dur_ok = 0;
           fpd_ok = 1;
           max_BP_ok = 1;
           min_BP_ok = 1;
           post_spike_ok = 1;
           stim_spike_ok = 1;
           for i = 1:length(well_pan_components)
               well_ui_con = well_pan_components(i);
            
               if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
                   if get(well_ui_con, 'Value') == 0
                      %set(submit_in_well_button, 'Visible', 'on')
                      bdt_ok = 0;
                   end
               end
               
               if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
                   if get(well_ui_con, 'Value') ~= 0 
                       t_wave_time_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
                   if get(well_ui_con, 'Value') ~= 0 
                       t_wave_dur_ok = 1;
                       %set(submit_in_well_button, 'Visible', 'on')
                   end
               end

               if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
                   if get(well_ui_con, 'Value') == 0
                      fpd_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
                   if get(well_ui_con, 'Value') == 0
                      stim_spike_ok = 0;
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
                   if get(well_ui_con, 'Value') == 0
                      post_spike_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
                   if get(well_ui_con, 'Value') == 0
                      max_BP_ok = 0;
                           %set(submit_in_well_button, 'Visible', 'on')
                   end
               end
               if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
                   if get(well_ui_con, 'Value') == 0
                      min_BP_ok = 0;
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
           if bdt_ok == 1 && stim_spike_ok == 1 && post_spike_ok == 1 && max_BP_ok == 1 && min_BP_ok == 1 && start_time_ok == 1 && end_time_ok == 1 && fpd_ok == 1 && t_wave_dur_ok == 1 && t_wave_time_ok == 1 
               %if start_time < end_time
               set(submit_in_well_button, 'Visible', 'on')
               %end
           end
       end
   end

   function changeGEWindow(stable_duration_ui, well_ax, spon_paced)
       % BDT CANNOT be equal to 0. 
       if get(stable_duration_ui, 'Value') == 0
           set(stable_duration_ui, 'BackgroundColor','#e68e8e')
           msgbox('Stable duration cannot be equal to 0','Oops!');
           if strcmp(get(submit_in_well_button, 'Visible'), 'on')
               set(submit_in_well_button, 'Visible', 'off')
           end
       end
       
       set(stable_duration_ui, 'BackgroundColor','white')
       
       well_pan_components = get(well_p, 'Children');
       bdt_ok = 1;
       t_wave_time_ok = 0;
       t_wave_dur_ok = 0;
       fpd_ok = 1;
       GE_ok = 1;
       max_BP_ok = 1;
       min_BP_ok = 1;
       post_spike_ok = 1;
       stim_spike_ok = 1;
       for i = 1:length(well_pan_components)
           well_ui_con = well_pan_components(i);
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'BDT') 
               if get(well_ui_con, 'Value') == 0
                  %set(submit_in_well_button, 'Visible', 'on')
                  bdt_ok = 0;
               end
           end
           
           
           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Time')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_time_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end

           if strcmp(string(get(well_ui_con, 'Tag')), 'T-Wave Dur')
               if get(well_ui_con, 'Value') ~= 0 
                   t_wave_dur_ok = 1;
                   %set(submit_in_well_button, 'Visible', 'on')
               end
           end

           if strcmp(string(get(well_ui_con, 'Tag')), 'FPD')
               if get(well_ui_con, 'Value') == 0
                  fpd_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Stim spike')
               if get(well_ui_con, 'Value') == 0
                  stim_spike_ok = 0;
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Post-spike')
               if get(well_ui_con, 'Value') == 0
                  post_spike_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Max BP')
               if get(well_ui_con, 'Value') == 0
                  max_BP_ok = 0;
                       %set(submit_in_well_button, 'Visible', 'on')
               end
           end
           if strcmp(string(get(well_ui_con, 'Tag')), 'Min BP')
               if get(well_ui_con, 'Value') == 0
                  min_BP_ok = 0;
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
       if bdt_ok == 1 && stim_spike_ok == 1 && post_spike_ok == 1 && fpd_ok == 1 && t_wave_time_ok == 1 && t_wave_dur_ok == 1 && GE_ok == 1 && min_BP_ok == 1 && max_BP_ok == 1
           %if start_time < end_time
           set(submit_in_well_button, 'Visible', 'on')
           %end
       end
       
   end

   function submitButtonPushed(submit_in_well_button, well_fig)
       set(well_fig, 'Visible', 'off')
   end


   function clearAllBDTPushed(clear_all_bdt_button, run_button)
       %%disp('clear BDT');
       % Must remove all BDT plots 
       % Set all BDTs to be zero again
       panel_sub_panels = get(p, 'Children');
      
       for i = 1:length(panel_sub_panels)

           sub_pan = panel_sub_panels(i);
           sub_p_ui_controls = get(sub_pan, 'Children');
           
           for j = 1:length(sub_p_ui_controls)

               if strcmp(string(get(sub_p_ui_controls(j), 'Tag')), 'BDT')    
                   %%disp('BDT');
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
      %disp('run')
      % Go through each subplots inputs and run analysis per parameters
      %analyse_MEA_signals(raw_file, beat_to_beat, 'paced', well_thresholding, 1)
      % Now create GUI with plots and BDT thresholds
   end

   function clearAllTWavesPushed(clear_all_t_wave_durations_button)
       %%disp('clear t-waves pushed')

       panel_sub_panels = get(p, 'Children');
      
       for i = 1:length(panel_sub_panels)

           sub_pan = panel_sub_panels(i);
           sub_p_ui_controls = get(sub_pan, 'Children');
           
           for j = 1:length(sub_p_ui_controls)

               if strcmp(string(get(sub_p_ui_controls(j), 'Tag')), 'T-Wave')    
                   %%disp('BDT');
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
          %%disp(wellID)
          %%disp(sub_p);
          %well_bdt = well_dt_ui.Value;
          %well_bdt_array = [well_bdt_array; well_bdt];
          %subplot(num_well_rows, num_well_cols, count)
          %%disp(wellID);
          %fig = figure();
          time_offset = 0;
          for e_r = 1:num_electrode_rows
             for e_c = 1:num_electrode_cols
                RawWellData = RawData{w_r, w_c, e_r, e_c};
                if (strcmp(class(RawWellData),'Waveform'))
                    %if ~empty(WellRawData)
                    %%disp(num_well_rows*num_well_cols)
                    %%disp(count)
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
                    %disp(wellID)
                    %disp('no data');
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
          %disp('b2b on')
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
          %disp('b2b off')
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
      %disp('worked')
      %disp(b2bdropdown.Value);
      %disp(stable_options_dropdown.Value);
      %disp(b2b_options_dropdown.Value);
      %disp(paced_spon_options_dropdown.Value);
      set(bdt_fig, 'Visible', 'off')
      %analyse_MEA_signals(raw_file, beat_to_beat, 'paced', well_thresholding, 1)
      
      % Now create GUI with plots and BDT thresholds
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
