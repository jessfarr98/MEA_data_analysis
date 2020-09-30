function analyse_MEA_signals(input_file, window, beat_detection_thresh, beat_by_beat)
% analyse_MEA_signals(fullfile('data', '20200526_70-1915_empty(000).raw'), 1, 300*E-3)

    plot_prompt = 'What would you like to name the directory that stores the plots of the data?\n';
    plot_dir = prompt_user(plot_prompt, 'dir', 'data');
    
    FileData = AxisFile(input_file);
    AllDataRaw = FileData.DataSets.LoadData;
        
    %Dummy test ensuring a function can access the other files
    
    
    [time, data] = AllDataRaw{6, 1, 1, 1}.GetTimeVoltageVector;
    %figure(1);
    %plot(time, data);
    %plot(data, time);
    %xlabel('Time (secs)')
    %ylabel('Voltage (V)');
    %title('Continuous MEA waveform')
    
    %disp(size(AllDataRaw))
    extract_beats(time, data, window, beat_detection_thresh)
          
    
    
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
end

function [beat_period, fpd] = extract_beats(time, data, window, bdt)
    total_duration = time(end);
    
    prev_beat_indx = 1;
    beat_indx = 1;
    max_beat_period = 1.5;  %seconds
    min_beat_period = 0.5;  %seconds
    post_spike_hold_off = 0.3;   %seconds
    
    
    %% New approach: while(1) until final element of the segment being analysed is past the duration
    %%               Find the first beat in the window frame
    count = 0;
    for t = 0:window:total_duration
       %disp(t+window)
       %Use the beat detection threshold to determine the regions that need
       %to be analysed
       
       %Take segments of data from each window to search for the next beat 
       %if beat_indx == 1
       if t == 0
          %wind_indx = find(time >= 0 & time <= window);  
          wind_indx = find(time >= t & time <= t+window);
       else
          %wind_indx = find(time >= time(beat_indx) & time <= (time(beat_indx)+window)); 
          wind_indx = find(time >= t & time <= t+window);
       end
       disp('start search window')
       disp(wind_indx(1))
       disp('end search window')
       disp(wind_indx(end))
       
       t_ime = time(wind_indx);
       d_ata = data(wind_indx);
       figure()
       plot(t_ime, d_ata);
       title('window to be analysed')
       hold off;
       
       %disp(max(d_ata))
       try
           %{
           post_spike_hold_off_time = t_ime(1)+post_spike_hold_off;
           pshot_indx = find(t_ime >= post_spike_hold_off_time);
           disp('start post hold off region');
           disp(pshot_indx(1))
           disp('end post hold off region');
           disp(pshot_indx(end))
           
           figure();
           plot(t_ime(pshot_indx), d_ata(pshot_indx))
           
           %}
           
           %beat_indx = find(d_ata(pshot_indx) >= bdt);
           beat_indx = find(d_ata >= bdt);
           cross_threshold_indx = beat_indx(1);
           beat_indx = beat_indx(1)+wind_indx(1)-1;
           disp('beat')
           disp(beat_indx)
           disp('prev')
           disp(prev_beat_indx)

       catch
           prev_beat_indx = beat_indx;
           disp('continue')
           disp(count)
           if count == 0
               
           end
           continue;
       end
       
       %% Between 10 and 12 seconds 2 beats are being picked up as one
       
       beat_time = time(prev_beat_indx:beat_indx);
       beat_data = data(prev_beat_indx:beat_indx);
       %disp(max(beat_data)) 
       
       %% Trim and then scale and set back to time zero for each beat
       %% Start small degrees of freedom [1-100], polyfits keep trying and do a survey of error plots, do the optimisation curve thing minimised error analysis 
       %% Try training and test sets too. Separate the whole datasets so use 80% of the beat signals as the 20%
       
       try
          beat_period = beat_time(end) - beat_time(1);
       catch
          prev_beat_indx = beat_indx;
          continue;
       end
       
       %{
       if beat_period > max_beat_period
       %Check there is only one beat period.
          bdt = bdt*0.9;
          disp('bdt has been reduced due to beat period being too long')
          disp(bdt)
          pause(15);
          close('all');
          continue;
       end
       
       if beat_period < min_beat_period
          bdt = bdt*1.1;
          disp('bdt has been increased due to beat period being too short')
          disp(bdt)
          pause(15);
          close('all');
          continue;
       end
       
       %}
       
       %Now fit the data and find the peak of the t-wave then use this to
       %find FPD
       %{
       min_signal = min(beat_data);
       min_indx = find(beat_data == min_signal);
       beat_data = beat_data(min_indx:end);
       beat_time = beat_time(min_indx:end);
       %}
       
       %beat_time = beat_time - beat_time(1);
       %beat_data = beat_data * 1e4;
       %[poly_f, delta] = polyfit(beat_time, beat_data, 15);
       %fit = polyval(poly_f, beat_time);
       %disp(size(fit))
       %disp(size(beat_time))
       %disp(delta.normr);
       
       
       threshold_data = zeros(size(beat_time));
       threshold_data(:) = bdt;
       
       
       figure();
       plot(beat_time, beat_data);
       hold on;
       plot(beat_time, threshold_data);
       xlabel('Time (secs)')
       ylabel('Voltage (V)')
       title('Extracted Beat');
       %hold on;
       %plot(beat_time, fit);
       %pause(5);
       %close(gcf)
       hold off;
       
       %{
       figure();
       plot(time(wind_indx), data(wind_indx));
       hold on;
       plot(t_ime(beat_indx), d_ata(beat_indx), 'ro');
       hold off;
       pause(10);
       close(gcf)
       %}
       
       prev_beat_indx = beat_indx;
       count = count + 1;
       pause(5);
       %close('all');
    end
    disp(count);

    % 0.0005
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