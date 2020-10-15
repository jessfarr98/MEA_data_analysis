function analyse_MEA_signals(input_file, beat_by_beat, spon_paced, well_thresholding, UI)
% analyse_MEA_signals(fullfile('data', '20200526_70-1915_empty(000).raw'), 1, 300*E-3)

    tic;
    %plot_prompt = 'What would you like to name the directory that stores the plots of the data?\n';
    %plot_dir = prompt_user(plot_prompt, 'dir', 'data');
    
    FileData = AxisFile(input_file);
    AllDataRaw = FileData.DataSets.LoadData;
    
    %Display the user with the plots of each 


    if strcmpi(well_thresholding, 'on')

        shape_data = size(AllDataRaw);
        num_well_rows = shape_data(1);
        num_well_cols = shape_data(2);
        num_electrode_rows = shape_data(3);
        num_electrode_cols = shape_data(4);
        
        num_well_rows = 2;
        num_well_cols = 1;
        
        total_wells = num_well_rows*num_well_cols;
        well_thresholds = double.empty(total_wells, 0);

        well_count = 0;
        well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
        for w_r = 1:num_well_rows
            for w_c = 1:num_well_cols
                
                wellID = strcat(well_dictionary(w_r), '0', string(w_c));
                if strcmp(wellID, 'A01')
                    continue;
                end
                well_count = well_count + 1;
                disp(strcat('Displaying well: ', {' '}, wellID))
                sub_plot_count = 1;
                %for e_r = 1:num_electrode_rows
                
                waveform = 0;
                for e_r = num_electrode_rows:-1:1
                    for e_c = 1:num_electrode_cols
                    %for e_c = num_electrode_cols:-1:1
                        WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                        if strcmp(class(WellRawData),'Waveform')
                            %if ~empty(WellRawData)
                            [time, data] = WellRawData.GetTimeVoltageVector;
                            %data = data .* 1000;
                            if waveform == 0
                                figure()
                                plot_cutoff_end_indx = floor(size(time)*0.15);
                                
                            end
                               
                            waveform = 1;
                            electrode_id = strcat(wellID, {' '}, string(e_c), {' '}, string(e_r));
                            %disp(electrode_id)
                            

                             %fig = figure();
                             %subplot(num_electrode_rows, num_electrode_cols, sub_plot_count);
                             %set(fig ,'Visible', 'off');
                             plot(time(1:plot_cutoff_end_indx), data(1:plot_cutoff_end_indx));
                             xlabel('Time (s)');
                             ylabel('Voltage (mV)');
                             hold on;
                             %title(electrode_id);
                             %print(fullfile(plot_dir, electrode_id), '-dbitmap', '-r0');

                             sub_plot_count = sub_plot_count + 1; 

                        end
                    end
                end
                if waveform == 1
                    title(wellID);
                    input_string = strcat('Enter the beat detection threshold for well', {' '}, wellID, ': \n');
                    beat_detection_thresh = input(input_string);
                    %beat_detection_thresh = 4E-4;
                    well_thresholds(well_count) = beat_detection_thresh;
                    hold off;
                end
            end
        end


        well_count = 0;
        for w_r = 1:num_well_rows
            for w_c = 1:num_well_cols
                if wellID == 'A01'
                    continue
                end
                well_count = well_count + 1;
                wellID = strcat(well_dictionary(w_r), '0', string(w_c));

                for e_r = num_electrode_rows:-1:1
                    for e_c = 1:num_electrode_cols
                        WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                        if strcmp(class(WellRawData),'Waveform')
                        %if ~empty(WellRawData)
                            [time, data] = WellRawData.GetTimeVoltageVector;

                            extract_beats(time, data, well_thresholds(well_count), spon_paced);                             

                        end
                    end
                end
            end
        end
    else
        
        view_sample_well = input('Would you like to view an example well to choose the beat detection threshold?(yes/no):\n', 's');
        if strcmpi(view_sample_well, 'yes')
            [time, data] = AllDataRaw{6, 1, 1, 1}.GetTimeVoltageVector;
            figure();
            plot(time, data);
            %plot(data, time);
            xlabel('Time (secs)')
            ylabel('Voltage (V)');
            title('MEA waveform')
        end
        
        beat_detection_thresh = input('Enter the beat detection threshold: \n');
        shape_data = size(AllDataRaw);
        num_well_rows = shape_data(1);
        num_well_cols = shape_data(2);
        num_electrode_rows = shape_data(3);
        num_electrode_cols = shape_data(4);

        count = 1;
        well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
        for w_r = 1:num_well_rows
            for w_c = 1:num_well_cols
                wellID = strcat(well_dictionary(w_r), '0', string(w_c));
                disp(wellID);
                %for e_r = 1:num_electrode_rows
                for e_r = num_electrode_rows:-1:1
                    for e_c = 1:num_electrode_cols
                    %for e_c = num_electrode_cols:-1:1
                    WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                        if strcmp(class(WellRawData),'Waveform')
                            %if ~empty(WellRawData)
                            electrode_id = strcat(wellID, {' '}, string(e_c), {' '}, string(e_r));
                            disp(electrode_id)
                            [time, data] = WellRawData.GetTimeVoltageVector;
                            extract_beats(time, data, beat_detection_thresh, spon_paced);  
                            count = count + 1;
                        end
                    end
                end
            end
        end
        
    end

    
    %{
    [time, data] = AllDataRaw{6, 1, 1, 1}.GetTimeVoltageVector;
    figure();
    plot(time, data);
    %plot(data, time);
    xlabel('Time (secs)')
    ylabel('Voltage (V)');
    title('MEA waveform')
    
    beat_detection_thresh = input('Enter the beat detection threshold: \n');
    
    %disp(size(AllDataRaw))
    extract_beats(time, data, beat_detection_thresh, spon_paced)
    %}  
    
    %This bit of code is to be used to the high throughput data analysis
    
    %disp(size(AllDataRaw));
    %{
    shape_data = size(AllDataRaw);
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);
    
   
    count = 1;
    well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    disp(well_dictionary(1))
    for w_r = 1:num_well_rows
        for w_c = 1:num_well_cols
           wellID = strcat(well_dictionary(w_r), '_0', string(w_c));
           disp(wellID)
           for e_r = 1:num_electrode_rows
              for e_c = 1:num_electrode_cols
                 WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                 if strcmp(class(WellRawData),'Waveform')
                     %if ~empty(WellRawData)
                     file_name = strcat(wellID, '_', string(e_r), '_', string(e_c));
                     disp(file_name)
                     [time, data] = WellRawData.GetTimeVoltageVector;

                     fig = figure();
                     set(fig ,'Visible', 'off');
                     plot(time, data);
                     xlabel('Time');
                     ylabel('Voltage');
                     print(fullfile(plot_dir, file_name), '-dbitmap', '-r0');
                     count = count + 1;
                 end
              end
           end
        end
    end
    %}
    elapsed_time_secs = toc;
    elapsed_time_mins = elapsed_time_secs/60;
    elapsed_time_hours = elapsed_time_mins/60;
    disp(['Total run time was ' num2str(floor(elapsed_time_hours)) ' hours and ' num2str(mod(floor(elapsed_time_mins), 60)) ' minutes.']);
end

function extract_beats(time, data, bdt, spon_paced)

    total_duration = time(end);
    
    prev_beat_indx = 1;
    beat_indx = 1;
    
    max_beat_period = 17;  %seconds
    min_beat_period = 0.2;  %seconds
    post_spike_hold_off = 0.1;   %seconds
    window = 2.2;
    
    activation_time_array = [];
    beat_num_array = [];
    cycle_length_array = [];
    %% New approach: while(1) until final element of the segment being analysed is past the duration
    %%               Find the first beat in the window frame
    count = 0;
    t = 0;
    prev_activation_time = 0;
    %for t = 0:window:total_duration
    while(1)
       %disp(t+window)
       %Use the beat detection threshold to determine the regions that need
       %to be analysed
       
       if (time(prev_beat_indx)+window) > total_duration
           break;
       end           
           
       %Take segments of data from each window to search for the next beat 
       if beat_indx == 1
       %if t == 0
           wind_indx = find(time >= 0 & time <= total_duration);  
          %wind_indx = find(time >= 0 & time <= window);  
          %wind_indx = find(time >= t & time <= t+window);
       else
          wind_indx = find(time >= time(prev_beat_indx) & time <= total_duration); 
          %wind_indx = find(time >= time(prev_beat_indx) & time <= (time(prev_beat_indx)+window)); 
          %wind_indx = find(time >= t & time <= t+window);
       end
       
       t_ime = time(wind_indx);
       d_ata = data(wind_indx);

       try 
           post_spike_hold_off_time = t_ime(1)+post_spike_hold_off;
           pshot_indx = find(t_ime >= post_spike_hold_off_time);
           pshot_indx_offset = pshot_indx(1);
                      
           beat_indx = find(d_ata(pshot_indx) >= bdt);
           beat_indx = beat_indx(1)+wind_indx(1)-1+pshot_indx_offset;

       catch
         
           %Update the beat detection threshold
           bdt = bdt*0.8;
           
           % If fails on the first iteration, set the beat index to be back to the first point
           if prev_beat_indx == 1
               beat_indx = 1;
           else
               beat_indx = prev_beat_indx;
           end
           disp('fail beat detection, continue')
           t = t - window;
           continue;
       end
       
       %% Between 10 and 12 seconds 2 beats are being picked up as one
       
       beat_time = time(prev_beat_indx:beat_indx);
       beat_data = data(prev_beat_indx:beat_indx);
       
       %% Trim and then scale and set back to time zero for each beat
       %% Start small degrees of freedom [1-100], polyfits keep trying and do a survey of error plots, do the optimisation curve thing minimised error analysis 
       %% Try training and test sets too. Separate the whole datasets so use 80% of the beat signals as the 20%
       
       try
          beat_period = beat_time(end) - beat_time(1);
       catch
          beat_indx = prev_beat_indx;
          continue;
       end
       
       disp(strcat('Beat period = ', num2str(beat_period)));
       disp(strcat('Beat start time = ', num2str(beat_time(1))));
       disp(strcat('Beat end time = ', num2str(beat_time(end))));
       
       if beat_period > max_beat_period
       %Check there is only one beat period.
          disp('bdt has been reduced due to beat period being too long')
          disp(bdt)
          
          if prev_beat_indx ~= 1
              beat_indx = prev_beat_indx;
              bdt = bdt/2;
              %window = window*1.5;
              if beat_time(end)+window > total_duration
                   break;
               end
          else
              prev_beat_indx = beat_indx;
          end
          t = t - window;
          continue;
       end
       
       if beat_period < min_beat_period
           disp('bdt has been increased due to beat period being too short')
           disp(bdt)
           %{
           threshold_data = zeros(size(beat_time));
           threshold_data(:) = bdt;
           figure();
           plot(beat_time, beat_data);
           hold on;
           plot(beat_time, threshold_data);
           xlabel('Time (secs)')
           ylabel('Voltage (V)')
           title('Extracted Beat');
           pause(3)
           %}
           if prev_beat_indx ~= 1
               beat_indx = prev_beat_indx;
               bdt = bdt*5;
               
               disp(beat_time(end))
               disp(window)
               disp(total_duration)
               if beat_time(end)+window > total_duration
                   break;
               end
           else
               %Generally the first bit of the recording is short so assume this is time 0
               prev_beat_indx = beat_indx;
           end
           t = t - window;
           continue;
       end
            
       [activation_time] = depolarisation_complex_analysis(beat_time, beat_data, post_spike_hold_off);
       
       activation_time_array = [activation_time_array; activation_time];
       cycle_length_array = [cycle_length_array; (activation_time-prev_activation_time)];
       beat_num_array = [beat_num_array; count];
       
       
       
       %{
       threshold_data = zeros(size(beat_time));
       threshold_data(:) = bdt;
       
       figure();
       plot(beat_time, beat_data);
       hold on;
       plot(beat_time, threshold_data);
       xlabel('Time (secs)')
       ylabel('Voltage (V)')
       title('Extracted Beat');
       pause(5);
       %}
             

       prev_activation_time = activation_time;
       prev_beat_indx = beat_indx;
       count = count + 1;
       t = t + window;
    end
    disp(strcat('Total Duration = ', {' '}, string(total_duration)))
    disp(count);
    
    
    figure();
    plot(beat_num_array, cycle_length_array, 'bo');
    xlabel('Beat Number');
    ylabel('Cycle Length (s)');
    title('Cycle Length per Beat');
    hold off;
    
    figure();
    plot(cycle_length_array(1:end-1), cycle_length_array(2:end), 'bo');
    xlabel('Cycle Length Previous Beat (s)');
    ylabel('Cycle Length (s)');
    title('Cycle Length vs Previous Beat Cycle Length');
    hold off;
    

end

function [activation_time] = depolarisation_complex_analysis(time, data, post_spike_hold_off)
    post_spike_hold_off_time = time(1)+post_spike_hold_off;
    pshot_indx = find(time >= post_spike_hold_off_time);
    pshot_indx_offset = pshot_indx(1);
    
    depol_complex_time = time(1:pshot_indx_offset);
    depol_complex_data = data(1:pshot_indx_offset);
    depol_complex_data_derivative = gradient(depol_complex_data);
    %depol_complex_data_derivative = gradient(depol_complex_data_derivative);
    
    activation_time_indx = find(depol_complex_data_derivative == min(depol_complex_data_derivative));
    
    %% To further refine the region to isolate the depol complex, perfrom std analysis
    
    %{
    figure()
    hold on;
    plot(depol_complex_time, depol_complex_data);
    plot(depol_complex_time, depol_complex_data_derivative);
    plot(depol_complex_time(activation_time_indx(1)), depol_complex_data(activation_time_indx(1)), 'ro')
    xlabel('Time (secs)')
    ylabel('Voltage (V)')
    title('Extracted Beat');
    pause(2);
    %}
    activation_time = depol_complex_time(activation_time_indx(1));
    
    %% TO DO calculate max amplitude
    
    

end

function t_wave_complex_analysis(time, data)


end

function extract_beat_linear_fit(time, data, window)
    total_duration = 100;
    window = 1;
    for  w = 1:window:total_duration
       if t == 0
          wind_indx = find(time >= t & time <= (t+window));  
      
       else
         wind_indx = find(time >= t & time <= (t+window));  
       end
       %disp('index of window')
       %disp(wind_indx(1))
       
       t_ime = time(wind_indx);
       d_ata = data(wind_indx);
    end

end



function dir_name = prompt_user(filename_prompt, file_dir, data_dir) 
%% filename_prompt is the prompt that asks the user what they would like to name the specific file/dir
%% file_dir is entered as either 'file' or 'dir' and indicates that the user is being prompted for either a file name or dir name

    dir_name = input(filename_prompt, 's');
    
    % Embed the new files and directory in data directory so analyses are grouped
    dir_name = fullfile(data_dir, dir_name);
    
    % Check that the filename has .csv on the end so the script doesn't die when it before writing the csv file
    if strcmp(file_dir, 'file')
        if ~contains(dir_name, '.csv')
            dir_name = strcat(dir_name, '.csv');
        end
    end
    
    if exist(dir_name, file_dir)
        % yes and no are the only valid entries. Loop continues if any other string is entered 
        changed_name = 0;
        while (1)
            check = input ('The selected directory name already exists, do you wish to continue? If so data will be lost (yes/no):\n', 's');
            if strcmpi(check, 'yes')
                break;
            elseif strcmpi(check, 'no')
                dir_name = input(filename_prompt, 's');
                dir_name = fullfile(data_dir, dir_name);
                if ~exist(dir_name, file_dir)
                    changed_name = 1;
                    break;
                end
            end
        end
        if changed_name == 0
            disp(['Overwriting' ' ' dir_name]);
            switch file_dir
                case 'dir' 
                    if strcmp(dir_name, data_dir)
                        disp('Error: Blocked from overwriting the entire data directory.');
                        dir_name = prompt_user(filename_prompt, file_dir, parent_dir);  
                    end
                    rmdir (dir_name, 's');
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
    if strcmp(file_dir, 'dir')
        mkdir(dir_name);
    end
end