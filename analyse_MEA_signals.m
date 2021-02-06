function analyse_MEA_signals(input_file, beat_to_beat, spon_paced, well_thresholding, UI)
% analyse_MEA_signals(fullfile('data', '20200526_70-1915_empty(001).raw'), 'off', 'spon', 'on', 1)


%% TO DO 21/01/2021
% cardiac standard paced and cardiac paced paced - analyse both and test if
% visual offsets of slopes show signals were affected by stimulus
% subtraction.

% test diff between 2000us and 600us stims as well.

% test if depol between raw and corrected has been corrupted - time and
% slope of steepest point and comparing between raw and corrected for
% various types of correction. 


%% TO DO:
% stable region yes/no
% yes = Enter the time range or percentage
% no = user selected region: start time - end time and do beat averaging or b2b

% Offset the electrodes so you can see the spikes a bit easier when it does
% the initial display of electrodes overliad

% check plate thresholding functionality mirrors well thresholding

%% TO DO 06/11/2020
% Compute the average waveforms not using the max dv/dt include all beat but store actiavtion times still as time 0 still for conduction maps

% electrode option for average wave analysis since t-waves may be off in golden electrode

% follow CiPA tool golden design and try follow the functionality when you can click a point and it finds the t-wave peak

% average_waveform analysis allow non-stable analysis using an input time frame. The current functionality is for stable analysis

% T-wave analysis start - user selected points easier to use for starting
% FPD calc

% Use better dataset for presentation
%% Question: for well thresholding also prompt for each well the b2b/ave_waveform_duration?


% subplots of ave waveforms and overlaid ones
% warn user if entered time frame is not very stable - inspect bring up the plots to see distribution 


    tic;
    %plot_prompt = 'What would you like to name the directory that stores the plots of the data?\n';
    %plot_dir = prompt_user(plot_prompt, 'dir', 'data');
    
    FileData = AxisFile(input_file);
    AllDataRaw = FileData.DataSets.LoadData;
    
    %Display the user with the plots of each 
    analyse_all_b2b = 'off';
    b2b_time_region1 = NaN;
    b2b_time_region2 = NaN;
    average_waveform_duration = NaN;
    %{
    if strcmpi(beat_to_beat, 'off')
        
        average_waveform_duration = input('What is the approximate duration you would like to use for the window used to compute the average waveform that will be used for depol/t-wave analysis (seconds): ');
            
    elseif strcmpi(beat_to_beat, 'on')
       while(1)
           analyse_all_b2b = input('Would you like to analyse all of the beats or select a time region?: (all, time_region)\n', 's');
           if strcmp(analyse_all_b2b, 'time_region')
               b2b_time_region1 = input('Please enter the first time point to use to perfrom the b2b analysis (seconds): ');
               b2b_time_region2 = input('Please enter the last time point to use to perfrom the b2b analysis (seconds): ');
               break;
           elseif strcmp(analyse_all_b2b, 'all')
               break;
           end
       end
    end
    %}
    if strcmpi(well_thresholding, 'on')
        well_thresholding_analysis(AllDataRaw, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, average_waveform_duration, spon_paced)
        
    else
        stable_ave_analysis = 'unknown';
        plot_ave_dir = NaN;

        b2b_time_region1 = NaN;
        b2b_time_region2 = NaN;
        average_waveform_duration = NaN;
        average_waveform_time1 = NaN;
        average_waveform_time2 = NaN;
        bdt = NaN;

        plate_thresholding_analysis(AllDataRaw, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, average_waveform_duration, spon_paced, bdt, stable_ave_analysis, average_waveform_time1, average_waveform_time2, plot_ave_dir)
        
        
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

function well_thresholding_analysis(AllDataRaw, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, average_waveform_duration, spon_paced)
    shape_data = size(AllDataRaw);
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);

    num_well_rows = 4;
    num_well_cols = 1;
    num_electrode_rows = 2;
    num_electrode_cols = 2;

    total_wells = num_well_rows*num_well_cols;
    well_thresholds = double.empty(total_wells, 0);
    
    stable_ave_analysis = 'unknown';
    plot_ave_dir = NaN;

    well_count = 0;
    well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    for w_r = 1:num_well_rows
        for w_c = 1:num_well_cols

            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            %if strcmp(wellID, 'A01')
            %    continue;
            %end
            well_count = well_count + 1;
            disp(strcat('Displaying well: ', {' '}, wellID))
            sub_plot_count = 1;
            %for e_r = 1:num_electrode_rows

            waveform = 0;
            time_offset = 0;
            for e_r = num_electrode_rows:-1:1
                for e_c = 1:num_electrode_cols
                %for e_c = num_electrode_cols:-1:1
                    WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                    if strcmp(class(WellRawData),'Waveform')
                        %if ~empty(WellRawData)
                        [time, data] = WellRawData.GetTimeVoltageVector;
                        %data = data .* 1000;
                        if waveform == 0
                            all_elecs = figure();
                            plot_cutoff_end_indx = floor(size(time)*0.5);

                        end

                        waveform = 1;
                        electrode_id = strcat(wellID, {'_'}, string(e_c), {'_'}, string(e_r));
                        %disp(electrode_id)

                         plot_time = time(1:plot_cutoff_end_indx)+time_offset;
                         
                         %fig = figure();
                         %subplot(num_electrode_rows, num_electrode_cols, sub_plot_count);
                         %set(fig ,'Visible', 'off');
                         plot(plot_time, data(1:plot_cutoff_end_indx));
                         xlabel('Time (s)');
                         ylabel('Voltage (mV)');
                         hold on;
                         %title(electrode_id);
                         %print(fullfile(plot_dir, electrode_id), '-dbitmap', '-r0');

                         sub_plot_count = sub_plot_count + 1; 
                         time_offset = time_offset+0.015;
                    end
                end
            end
            if waveform == 1
                title(wellID);
                while(1)
                    input_string = strcat('Enter the beat detection threshold for well', {' '}, wellID, ': \n');
                    beat_detection_thresh = input(input_string);

                    threshold_data = ones(plot_cutoff_end_indx);
                    threshold_data(:, 1) = beat_detection_thresh;

                    %hold on;
                    thresh_plot = plot(time(1:plot_cutoff_end_indx), threshold_data);
                    xlabel('Time (s)');
                    ylabel('Voltage (mV)');

                    %beat_detection_thresh = 4E-4;
                    satisfactory_bdt = input('Is the BDT satisfactory?(yes/no):\n', 's');
                    if strcmpi(satisfactory_bdt, 'yes')
                        well_thresholds(well_count) = beat_detection_thresh;
                        break
                    else
                        set(thresh_plot,'Visible','off')
                    end
                end

                b2b_time_region1 = NaN;
                b2b_time_region2 = NaN;
                average_waveform_duration = NaN;
                average_waveform_time1 = NaN;
                average_waveform_time2 = NaN;
                
                %stable_ave_analysis = 'stable';
                if strcmpi(beat_to_beat, 'off')
                    while(1)
                        if strcmp(stable_ave_analysis, 'unknown')
                            stable_ave_analysis = input('Would you like to use the most stable waveform to compute cardiac statistics or average beats from a time region?: (stable, time_region)\n', 's');
                        end
                        if strcmp(stable_ave_analysis, 'stable')
                            average_waveform_duration = input('What is the approximate duration you would like to use for the window used to compute the average waveform that will be used for depol/t-wave analysis (seconds): ');
                            if isnan(plot_ave_dir)
                                plot_ave_dir_prompt = 'Please enter the name of the directory that will store the plots of the waveforms used to calculate the average waveforms for each electrode:\n';
                                plot_ave_dir = prompt_user(plot_ave_dir_prompt, 'dir', 'data');
                            end
                            break;
                        elseif strcmp(stable_ave_analysis, 'time_region')
                            average_waveform_time1 = input('Please enter the first time point from the time frame you would like to use to compute the average waveform: ');
                            average_waveform_time2 = input('Please enter the last time point from the time frame you would like to use to compute the average waveform: ');
                            if isnan(plot_ave_dir)
                                plot_ave_dir_prompt = 'Please enter the name of the directory that will store the plots of the waveforms used to calculate the average waveforms for each electrode:\n';
                                plot_ave_dir = prompt_user(plot_ave_dir_prompt, 'dir', 'data');
                            end
                            break;
                        end
                    end                    
                    
                elseif strcmpi(beat_to_beat, 'on')
                   while(1)
                       analyse_all_b2b = input('Would you like to analyse all of the beats or select a time region?: (all, time_region)\n', 's');
                       if strcmp(analyse_all_b2b, 'time_region')
                           b2b_time_region1 = input('Please enter the first time point to use to perfrom the b2b analysis (seconds): ');
                           b2b_time_region2 = input('Please enter the last time point to use to perfrom the b2b analysis (seconds): ');
                           break;
                       elseif strcmp(analyse_all_b2b, 'all')
                           break;
                       end
                   end
                end
                
                while(1)
                    [electrode_data] = extract_well_threshold_beats(AllDataRaw, wellID, num_well_rows, num_well_cols, num_electrode_cols, num_electrode_rows, well_thresholds, well_dictionary, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, average_waveform_duration, spon_paced, stable_ave_analysis, average_waveform_time1, average_waveform_time2, w_r, w_c, well_count, plot_ave_dir);

                    if strcmpi(beat_to_beat, 'off')
                        if strcmp(stable_ave_analysis, 'stable')
                            min_stdevs = [electrode_data(:).min_stdev];
                            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);

                            window = electrode_data(min_electrode_beat_stdev_indx).window;
                            figure();
                            for i = 1:window

                               %disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_times))
                               %celldisp(electrode_data(min_electrode_beat_stdev_indx).stable_times(i, 1))
                               %pause(666);
                               plot(electrode_data(min_electrode_beat_stdev_indx).stable_times{i, 1}, electrode_data(min_electrode_beat_stdev_indx).stable_waveforms{i, 1});
                               hold on;
                            end
                        end

                        re_run = 0;
                        while(1)
                            change_window = input('Is the time frame used to extract the stable beats acceptable?: (yes/no)\n', 's');
                            if strcmpi(change_window, 'no')
                                re_run = 1;
                                if strcmp(stable_ave_analysis, 'stable')
                                    average_waveform_duration = input('What is the approximate duration you would like to use for the window used to compute the average waveform that will be used for depol/t-wave analysis (seconds): ');
                                else
                                    average_waveform_time1 = input('Please enter the first time point from the time frame you would like to use to compute the average waveform: ');
                                    average_waveform_time2 = input('Please enter the last time point from the time frame you would like to use to compute the average waveform: ');

                                end
                                break;
                            elseif strcmpi(change_window, 'yes')
                                if strcmp(stable_ave_analysis, 'stable')
                                    hold off;
                                    %celldisp(size(electrode_data(min_electrode_beat_stdev_indx).average_waveform));
                                    %pause(100);
                                    figure();
                                    for i = 1:num_electrode_rows*num_electrode_cols
                                        if ~isempty(electrode_data(i).time)
                                            subplot(num_electrode_rows, num_electrode_cols, i)
                                            plot(electrode_data(i).time, electrode_data(i).average_waveform);
                                            title(electrode_data(i).electrode_id);
                                        end
                                    end
                                    
                                    figure();
                                    for i = 1:num_electrode_rows*num_electrode_cols
                                        if ~isempty(electrode_data(i).time)
                                            window = electrode_data(i).window;
                                            subplot(num_electrode_rows, num_electrode_cols, i)
                                            for k = 1:window

                                               %disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_times))
                                               %celldisp(electrode_data(min_electrode_beat_stdev_indx).stable_times(i, 1))
                                               %pause(666);
                                               plot(electrode_data(i).stable_times{k, 1}, electrode_data(i).stable_waveforms{k, 1});
                                               hold on;
                                            end
                                            hold off;
                                            title(electrode_data(i).electrode_id);
                                        end
                                    end
                                    
                                    
                                    
                                    golden_electrode_data = electrode_data(min_electrode_beat_stdev_indx);
                                    figure();
                                    plot(electrode_data(min_electrode_beat_stdev_indx).time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                                    title(strcat(golden_electrode_data.electrode_id, {' '}, 'Average Golden Waveform'));
                                    %disp(electrode_data(min_electrode_beat_stdev_indx).electrode_id)
                                    hold on;
                                    while(1)
                                        golden_electrode_ok = input('Please observe the plots for each electrode. Is the golden electrode displayed the optimal electrode to use for the computaton of cardiac statistics?:(yes/no)\n', 's');
                                        if strcmpi(golden_electrode_ok, 'yes')
                                            break;
                                        elseif strcmpi(golden_electrode_ok, 'no')
                                            golden_electrode = input(strcat('Please enter the electrode_id of the golden electrode for well ', wellID, ':(e.g. A01_1_1)\n'), 's');
                                            elec_ids = [electrode_data(:).electrode_id];
                                            ge_indx = find(strcmp(elec_ids, golden_electrode));
                                            %golden_electrode = electrode_data(ge_indx).electrode_id
                                            if ~isempty(ge_indx)
                                                golden_electrode_data = electrode_data(ge_indx);
                                                hold off;
                                                figure();
                                                plot(golden_electrode_data.time, golden_electrode_data.average_waveform);
                                                title(strcat(golden_electrode_data.electrode_id, {' '}, 'Average Golden Waveform'));
                                                hold on;
                                            end
                                            break;
                                        end
                                    end
                                    
                                    [activation_time, amplitude, max_depol_time, min_depol_time] = rate_analysis(golden_electrode_data.time, golden_electrode_data.average_waveform, 0.1);
                                    [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(golden_electrode_data.time, golden_electrode_data.average_waveform, beat_to_beat, activation_time, NaN, spon_paced, 'down', NaN, NaN, NaN);
                                    disp(strcat('FPD = ', num2str(FPD)));
                                    disp(strcat('Depol amplitude = ', num2str(amplitude)))
                                    t_time_indx = find(golden_electrode_data.time >= t_wave_peak_time);
                                    max_depol = golden_electrode_data.average_waveform(golden_electrode_data.time == max_depol_time);
                                    min_depol = golden_electrode_data.average_waveform(golden_electrode_data.time == min_depol_time);
                                    act_point = golden_electrode_data.average_waveform(golden_electrode_data.time == activation_time);
                                    plot(t_wave_peak_time, golden_electrode_data.average_waveform(t_time_indx(1)), 'ro');
                                    plot(max_depol_time, max_depol, 'ro');
                                    plot(min_depol_time, min_depol, 'ro');
                                    plot(activation_time, act_point, 'ro');
                                    hold off;
                                    %pause(2)
                                elseif strcmp(stable_ave_analysis, 'time_region')
                                    for i = 1:num_electrode_cols*num_electrode_rows
                                        if ~isempty(electrode_data(i).time)
                                            [activation_time, amplitude, max_depol_time, min_depol_time] = rate_analysis(electrode_data(i).time, electrode_data(i).average_waveform, 0.1);
                                            
                                            figure();
                                            plot(electrode_data(i).time, electrode_data(i).average_waveform);
                                            hold on;
                                            [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(electrode_data(i).time, electrode_data(i).average_waveform, beat_to_beat, activation_time, NaN, spon_paced, 'down', NaN, NaN, NaN); 
                                            t_time_indx = find(electrode_data(i).time >= t_wave_peak_time);
                                            plot(t_wave_peak_time, electrode_data(i).average_waveform(t_time_indx(1)), 'ro');
                                            max_depol = electrode_data(i).average_waveform(electrode_data(i).time == max_depol_time);
                                            min_depol = electrode_data(i).average_waveform(electrode_data(i).time == min_depol_time);
                                            act_point = electrode_data(i).average_waveform(electrode_data(i).time == activation_time);
                                            plot(max_depol_time, max_depol, 'ro');
                                            plot(min_depol_time, min_depol, 'ro');
                                            plot(activation_time, act_point, 'ro');
                                            title(strcat('Average Waveform for ',  electrode_data(i).electrode_id));
                                            hold off;
                                            disp(strcat('FPD = ', num2str(FPD)));
                                            disp(strcat('Depol amplitude = ', num2str(amplitude)))
                                            %pause(2)
                                            
                                        end
                                    end
                                end
                                
                                break;
                            end
                        end
            
                        if re_run == 0
                            break;
                        end
                    else
                        break;
                    end
                end
            end
        end
    end

    %{
    well_count = 0;
    for w_r = 1:num_well_rows
        for w_c = 1:num_well_cols

            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            %if strcmp(wellID, 'A01')
            %    continue;
            %end
            well_count = well_count + 1;
            disp(strcat('Displaying well: ', {' '}, wellID))
            while(1)
                [electrode_data] = extract_well_threshold_beats(AllDataRaw, wellID, num_well_rows, num_well_cols, num_electrode_cols, num_electrode_rows, well_thresholds, well_dictionary, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, average_waveform_duration, spon_paced, stable_ave_analysis, average_waveform_time1, average_waveform_time2, w_r, w_c, well_count);

                if strcmpi(beat_to_beat, 'off')
                    if strcmp(stable_ave_analysis, 'stable')
                        min_stdevs = [electrode_data(:).min_stdev];
                        min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);

                        window = electrode_data(min_electrode_beat_stdev_indx).window;
                        figure();
                        for i = 1:window

                           %disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_times))
                           %celldisp(electrode_data(min_electrode_beat_stdev_indx).stable_times(i, 1))
                           %pause(666);
                           plot(electrode_data(min_electrode_beat_stdev_indx).stable_times{i, 1}, electrode_data(min_electrode_beat_stdev_indx).stable_waveforms{i, 1});
                           hold on;
                        end
                    else
                        %make directories that store all the plots for each
                        %electrode per well 
                        disp('make time region plot dir')
                    end

                    re_run = 0;
                    while(1)
                        change_window = input('Is the time frame used to extract the stable beats acceptable?: (yes/no)\n', 's');
                        if strcmpi(change_window, 'no')
                            re_run = 1;
                            if strcmp(stable_ave_analysis, 'stable')
                                average_waveform_duration = input('What is the approximate duration you would like to use for the window used to compute the average waveform that will be used for depol/t-wave analysis (seconds): ');
                            else
                                average_waveform_time1 = input('Please enter the first time point from the time frame you would like to use to compute the average waveform: ');
                                average_waveform_time2 = input('Please enter the last time point from the time frame you would like to use to compute the average waveform: ');

                            end
                            break;
                        elseif strcmpi(change_window, 'yes')
                            if strcmp(stable_ave_analysis, 'stable')
                                hold off;
                                %celldisp(size(electrode_data(min_electrode_beat_stdev_indx).average_waveform));
                                %pause(100);
                                figure();
                                plot(electrode_data(min_electrode_beat_stdev_indx).time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                                title(strcat(wellID, {' '}, 'Average Waveform'));
                                %disp(electrode_data(min_electrode_beat_stdev_indx).electrode_id)
                            else
                                disp('plot ave time frame wave')
                            end
                            break;
                        end
                    end
                    if re_run == 0
                        break;
                    end
                end
            end
        end
    end

    %}
end

function [electrode_data] = extract_well_threshold_beats(AllDataRaw, wellID, num_well_rows, num_well_cols, num_electrode_cols, num_electrode_rows, well_thresholds, well_dictionary, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, average_waveform_duration, spon_paced, stable_ave_analysis, average_waveform_time1, average_waveform_time2, w_r, w_c, well_count, plot_ave_dir)
    
    %well_count = 0;
    %well_electrode_data = [];
    %for w_r = 1:num_well_rows
        %for w_c = 1:num_well_cols
            %if strcmpi(wellID, 'A01')
            %    continue;
            %end
            %well_count = well_count + 1;
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            
            electrode_data = ElectrodeData.empty(num_electrode_cols*num_electrode_rows, 0);

            for j = 1:(num_electrode_cols*num_electrode_rows)
                electrode_data(j).min_stdev = 0;
                electrode_data(j).average_waveform = [];
                electrode_data(j).time = [];
                electrode_data(j).electrode_id = '';
                electrode_data(j).stable_waveforms = {};
                electrode_data(j).stable_times = {};
                electrode_data(j).window = 0;
            end
            electrode_count = 0;

            for e_r = num_electrode_rows:-1:1
                for e_c = 1:num_electrode_cols

                    WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                    if strcmp(class(WellRawData),'Waveform')
                    electrode_id = strcat(wellID, {'_'}, string(e_c), {'_'}, string(e_r));
                    %if ~empty(WellRawData)
                        if strcmpi(beat_to_beat, 'off')
                            electrode_count = electrode_count+1;
                        end
                        [time, data] = WellRawData.GetTimeVoltageVector;

                        [beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods] = extract_beats(wellID, time, data, well_thresholds(well_count), spon_paced, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, stable_ave_analysis, average_waveform_time1, average_waveform_time2, plot_ave_dir, electrode_id);     
                        if strcmpi(beat_to_beat, 'off')
                            if strcmp(stable_ave_analysis, 'stable')
                                [average_waveform_duration, average_waveform, min_stdev, artificial_time_space, electrode_data] = compute_electrode_average_stable_waveform(beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods, time, data, average_waveform_duration, electrode_data, electrode_count, electrode_id, plot_ave_dir, wellID);
                                %{
                                electrode_data(electrode_count).min_stdev = min_stdev;
                                electrode_data(electrode_count).average_waveform = average_waveform;
                                electrode_data(electrode_count).time = artificial_time_space;
                                electrode_data(electrode_count).electrode_id = electrode_id;
                                %}
                            elseif strcmp(stable_ave_analysis, 'time_region')
                                disp('to be implemented')
                                [average_waveform, electrode_data] = compute_average_time_region_waveform(beat_num_array, cycle_length_array, activation_time_array, time, data, electrode_data, electrode_count, electrode_id, beat_periods, beat_start_times, plot_ave_dir, wellID);
                                
                            end
                        end
                    end
                end
                %well_electrode_data = [well_electrode_data; electrode_data];
            end
        %end
    %end


end

function plate_thresholding_analysis(AllDataRaw, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, average_waveform_duration, spon_paced, bdt, stable_ave_analysis, average_waveform_time1, average_waveform_time2, plot_ave_dir)

    if isnan(bdt)
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
    
        
        %stable_ave_analysis = 'stable';
        bdt = input('Enter the beat detection threshold: \n');
    end
        if strcmpi(beat_to_beat, 'off')
            while(1)
                if strcmp(stable_ave_analysis, 'unknown')
                    stable_ave_analysis = input('Would you like to use the most stable waveform to compute cardiac statistics or average beats from a time region?: (stable, time_region)\n', 's');
                end
                if strcmp(stable_ave_analysis, 'stable')
                    average_waveform_duration = input('What is the approximate duration you would like to use for the window used to compute the average waveform that will be used for depol/t-wave analysis (seconds): ');
                    if isnan(plot_ave_dir)
                        plot_ave_dir_prompt = 'Please enter the name of the directory that will store the plots of the waveforms used to calculate the average waveforms for each electrode:\n';
                        plot_ave_dir = prompt_user(plot_ave_dir_prompt, 'dir', 'data');
                    end
                    break;
                elseif strcmp(stable_ave_analysis, 'time_region')
                    average_waveform_time1 = input('Please enter the first time point from the time frame you would like to use to compute the average waveform: ');
                    average_waveform_time2 = input('Please enter the last time point from the time frame you would like to use to compute the average waveform: ');
                    if isnan(plot_ave_dir)
                        plot_ave_dir_prompt = 'Please enter the name of the directory that will store the plots of the waveforms used to calculate the average waveforms for each electrode:\n';
                        plot_ave_dir = prompt_user(plot_ave_dir_prompt, 'dir', 'data');
                    end
                    break;
                end
            end                    

        elseif strcmpi(beat_to_beat, 'on')
           while(1)
               analyse_all_b2b = input('Would you like to analyse all of the beats or select a time region?: (all, time_region)\n', 's');
               if strcmp(analyse_all_b2b, 'time_region')
                   b2b_time_region1 = input('Please enter the first time point to use to perfrom the b2b analysis (seconds): ');
                   b2b_time_region2 = input('Please enter the last time point to use to perfrom the b2b analysis (seconds): ');
                   break;
               elseif strcmp(analyse_all_b2b, 'all')
                   break;
               end
           end
        end
    %end
    
    shape_data = size(AllDataRaw);
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);

    num_well_cols = 1;
    num_well_rows = 4;
    num_electrode_rows = 2;
    num_electrode_cols = 2;
    
    count = 1;
    well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    for w_r = 1:num_well_rows
        for w_c = 1:num_well_cols
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            disp(wellID);
            %for e_r = 1:num_electrode_rows
            if strcmpi(beat_to_beat, 'off')
                electrode_data = ElectrodeData.empty(num_electrode_cols*num_electrode_rows, 0);
                %stable_data = StableWaveforms.empty(num_electrode_cols*num_electrode_rows, 0);
                for j = 1:(num_electrode_cols*num_electrode_rows)
                    electrode_data(j).min_stdev = 0;
                    electrode_data(j).average_waveform = [];
                    electrode_data(j).time = [];
                    electrode_data(j).electrode_id = '';
                    electrode_data(j).stable_waveforms = [];
                    electrode_data(j).stable_times = [];
                    electrode_data(j).window = 0;
                    %stable_data(j).waveform = [];
                    %stable_data(j).time = [];
                end
                
            end
            electrode_count = 0;
            for e_r = num_electrode_rows:-1:1
                for e_c = 1:num_electrode_cols
                %for e_c = num_electrode_cols:-1:1
                WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                    if strcmp(class(WellRawData),'Waveform')
                        %if ~empty(WellRawData)
                        electrode_count = electrode_count+1;
                        electrode_id = strcat(wellID, {'_'}, string(e_c), {'_'}, string(e_r));
                        %disp(electrode_id)
                        [time, data] = WellRawData.GetTimeVoltageVector;
                        %extract_beats(wellID, time, data, beat_detection_thresh, spon_paced,beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2); 
                        [beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods] = extract_beats(wellID, time, data, bdt, spon_paced, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, stable_ave_analysis, average_waveform_time1, average_waveform_time2, plot_ave_dir, electrode_id);     
                        
                        if strcmpi(beat_to_beat, 'off')
                            if strcmp(stable_ave_analysis, 'stable')
                                [average_waveform_duration, average_waveform, min_stdev, artificial_time_space, electrode_data] = compute_electrode_average_stable_waveform(beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods, time, data, average_waveform_duration, electrode_data, electrode_count, electrode_id, plot_ave_dir, wellID);
                                %{
                                electrode_data(electrode_count).min_stdev = min_stdev;
                                electrode_data(electrode_count).average_waveform = average_waveform;
                                electrode_data(electrode_count).time = artificial_time_space;
                                electrode_data(electrode_count).electrode_id = electrode_id;
                                %}
                            elseif strcmp(stable_ave_analysis, 'time_region')
                                %disp('to be implemented')
                                [average_waveform, electrode_data] = compute_average_time_region_waveform(beat_num_array, cycle_length_array, activation_time_array, time, data, electrode_data, electrode_count, electrode_id, beat_periods, beat_start_times, plot_ave_dir, wellID);
                                %[activation_time] = rate_analysis(electrode_data(electrode_count).time, electrode_data(electrode_count).average_waveform, 0.1);
                                %[t_wave_peak] = t_wave_complex_analysis(electrode_data(electrode_count).time, electrode_data(electrode_count).average_waveform, beat_to_beat, activation_time, NaN, spon_paced);
                                
                            end
                        end
                        count = count + 1;
                    end
                end
            end
            if strcmpi(beat_to_beat, 'off')
                if strcmp(stable_ave_analysis, 'stable')
                    
                    %disp(electrode_data(min_electrode_beat_stdev_indx).electrode_id)
                    figure();
                    for i = 1:num_electrode_rows*num_electrode_cols
                        if ~isempty(electrode_data(i).time)
                            subplot(num_electrode_rows, num_electrode_cols, i)
                            plot(electrode_data(i).time, electrode_data(i).average_waveform);
                            title(electrode_data(i).electrode_id);
                        end
                    end

                    figure();
                    for i = 1:num_electrode_rows*num_electrode_cols
                        if ~isempty(electrode_data(i).time)
                            window = electrode_data(i).window;
                            subplot(num_electrode_rows, num_electrode_cols, i)
                            for k = 1:window

                               %disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_times))
                               %celldisp(electrode_data(min_electrode_beat_stdev_indx).stable_times(i, 1))
                               %pause(666);
                               plot(electrode_data(i).stable_times{k, 1}, electrode_data(i).stable_waveforms{k, 1});
                               hold on;
                            end
                            hold off;
                            title(electrode_data(i).electrode_id);
                        end
                    end
                    
                    min_stdevs = [electrode_data(:).min_stdev];
                    min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);
                    golden_electrode_data = electrode_data(min_electrode_beat_stdev_indx);
                    
                    try
                        window = electrode_data(min_electrode_beat_stdev_indx).window;
                    catch
                        disp('No data for electrode');
                        continue;
                    end
                        
                    figure();
                    for i = 1:window

                       %disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_times))
                       %celldisp(electrode_data(min_electrode_beat_stdev_indx).stable_times(i, 1))
                       
                       plot(golden_electrode_data.stable_times{i, 1}, golden_electrode_data.stable_waveforms{i, 1});
                       hold on;
                    end
                    hold off;
                    
                    figure();
                    plot(electrode_data(min_electrode_beat_stdev_indx).time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                    title(strcat(golden_electrode_data.electrode_id, {' '}, 'Average Waveform'));
                    hold on;
                    
                    %celldisp(size(electrode_data(min_electrode_beat_stdev_indx).average_waveform));
                    %pause(100);
                    
                    while(1)
                        golden_electrode_ok = input('Please observe the plot for each electrode. Is the golden electrode displayed the optimal electrode to use for the computaton of cardiac statistics?:(yes/no)\n', 's');
                        if strcmpi(golden_electrode_ok, 'yes')
                            break;
                        elseif strcmpi(golden_electrode_ok, 'no')
                            golden_electrode = input(strcat('Please enter the electrode_id of the golden electrode for well ', wellID, ':(e.g. A01_1_1)\n'), 's');
                            elec_ids = [electrode_data(:).electrode_id];
                            ge_indx = find(strcmp(elec_ids, golden_electrode));
                            %golden_electrode = electrode_data(ge_indx).electrode_id
                            if ~isempty(ge_indx)
                                golden_electrode_data = electrode_data(ge_indx);
                                hold off;
                                figure();
                                plot(golden_electrode_data.time, golden_electrode_data.average_waveform);
                                title(strcat(golden_electrode_data.electrode_id, {' '}, 'Average Waveform'));
                                hold on;
                            end
                            break;
                        end
                        
                    end
                    [activation_time, amplitude, max_depol_time, min_depol_time] = rate_analysis(golden_electrode_data.time, golden_electrode_data.average_waveform, 0.1);
                    [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(golden_electrode_data.time, golden_electrode_data.average_waveform, beat_to_beat, activation_time, NaN, spon_paced, 'down', NaN, NaN, NaN);
                    disp(strcat('FPD = ', num2str(FPD)));
                    disp(strcat('Depol amplitude = ', num2str(amplitude)))
                    t_time_indx = find(golden_electrode_data.time >= t_wave_peak_time);
                    plot(t_wave_peak_time, golden_electrode_data.average_waveform(t_time_indx(1)), 'ro');
                    max_depol = golden_electrode_data.average_waveform(golden_electrode_data.time == max_depol_time);
                    min_depol = golden_electrode_data.average_waveform(golden_electrode_data.time == min_depol_time);
                    act_point = golden_electrode_data.average_waveform(golden_electrode_data.time == activation_time);
                    plot(max_depol_time, max_depol, 'ro');
                    plot(min_depol_time, min_depol, 'ro');
                    plot(activation_time, act_point, 'ro');
                    hold off;
                    %pause(2)
                elseif strcmp(stable_ave_analysis, 'time_region')
                    for i = 1:num_electrode_cols*num_electrode_rows
                        if ~isempty(electrode_data(i).time)
                            [activation_time, amplitude, max_depol_time, min_depol_time] = rate_analysis(electrode_data(i).time, electrode_data(i).average_waveform, 0.1);
                            figure();
                            plot(electrode_data(i).time, electrode_data(i).average_waveform);
                            hold on;
                            
                            title(strcat('Average Waveform for ',  electrode_data(i).electrode_id));
                            
                            [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(electrode_data(i).time, electrode_data(i).average_waveform, beat_to_beat, activation_time, NaN, spon_paced, 'down', NaN, NaN, NaN);
                            t_time_indx = find(electrode_data(i).time >= t_wave_peak_time);
                            plot(t_wave_peak_time, electrode_data(i).average_waveform(t_time_indx(1)), 'ro');
                            max_depol = electrode_data(i).average_waveform(electrode_data(i).time == max_depol_time);
                            min_depol = electrode_data(i).average_waveform(electrode_data(i).time == min_depol_time);
                            act_point = electrode_data(i).average_waveform(electrode_data(i).time == activation_time);
                            plot(max_depol_time, max_depol, 'ro');
                            plot(min_depol_time, min_depol, 'ro');
                            plot(activation_time, act_point, 'ro');
                            disp(strcat('FPD = ', num2str(FPD)));
                            disp(strcat('Depol amplitude = ', num2str(amplitude)))
                            
                            hold off;
                            %pause(2)
                        end
                    end
                end
                
            end
            %{
            while(1)
                %[electrode_data] = extract_well_threshold_beats(AllDataRaw, wellID, num_well_rows, num_well_cols, num_electrode_cols, num_electrode_rows, well_thresholds, well_dictionary, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, average_waveform_duration, spon_paced, stable_ave_analysis, average_waveform_time1, average_waveform_time2, w_r, w_c, well_count, plot_ave_dir);

                if strcmpi(beat_to_beat, 'off')
                    if strcmp(stable_ave_analysis, 'stable')
                        min_stdevs = [electrode_data(:).min_stdev];
                        min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);

                        window = electrode_data(min_electrode_beat_stdev_indx).window;
                        figure();
                        for i = 1:window

                           %disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_times))
                           %celldisp(electrode_data(min_electrode_beat_stdev_indx).stable_times(i, 1))
                           %pause(666);
                           plot(electrode_data(min_electrode_beat_stdev_indx).stable_times{i, 1}, electrode_data(min_electrode_beat_stdev_indx).stable_waveforms{i, 1});
                           hold on;
                        end
                    end
                    re_run = 0;
                    while(1)
                        change_window = input('Is the time frame used to extract the stable beats acceptable?: (yes/no)\n', 's');
                        if strcmpi(change_window, 'no')
                            re_run = 1;
                            %{
                            if strcmp(stable_ave_analysis, 'stable')
                                average_waveform_duration = input('What is the approximate duration you would like to use for the window used to compute the average waveform that will be used for depol/t-wave analysis (seconds): ');
                            else
                                average_waveform_time1 = input('Please enter the first time point from the time frame you would like to use to compute the average waveform: ');
                                average_waveform_time2 = input('Please enter the last time point from the time frame you would like to use to compute the average waveform: ');

                            end
                            %}
                            break;
                        elseif strcmpi(change_window, 'yes')
                            if strcmp(stable_ave_analysis, 'stable')
                                hold off;
                                %celldisp(size(electrode_data(min_electrode_beat_stdev_indx).average_waveform));
                                %pause(100);
                                figure();
                                plot(electrode_data(min_electrode_beat_stdev_indx).time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                                title(strcat(wellID, {' '}, 'Average Waveform'));
                                %disp(electrode_data(min_electrode_beat_stdev_indx).electrode_id)
                            else
                                disp('plot ave time frame wave')
                            end
                            break;
                        end
                    end

                    if re_run == 0
                        break;
                    else
                        if strcmp(stable_ave_analysis, 'stable')
                            [average_waveform_duration, average_waveform, min_stdev, artificial_time_space, electrode_data] = compute_electrode_average_stable_waveform(beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods, time, data, average_waveform_duration, electrode_data, electrode_count, electrode_id, plot_ave_dir, wellID);
                            %{
                            electrode_data(electrode_count).min_stdev = min_stdev;
                            electrode_data(electrode_count).average_waveform = average_waveform;
                            electrode_data(electrode_count).time = artificial_time_space;
                            electrode_data(electrode_count).electrode_id = electrode_id;
                            %}
                        elseif strcmp(stable_ave_analysis, 'time_region')
                            disp('to be implemented')
                            [average_waveform, electrode_data] = compute_average_time_region_waveform(beat_num_array, cycle_length_array, activation_time_array, time, data, electrode_data, electrode_count, electrode_id, beat_periods, beat_start_times, plot_ave_dir, wellID);


                        end
                    end
                end
            end
            %}
           
        end
    end
    %{
    while(1)
        %[electrode_data] = extract_well_threshold_beats(AllDataRaw, wellID, num_well_rows, num_well_cols, num_electrode_cols, num_electrode_rows, well_thresholds, well_dictionary, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, average_waveform_duration, spon_paced);

        if strcmpi(beat_to_beat, 'off')
            min_stdevs = [electrode_data(:).min_stdev];
            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0);
            
            window = electrode_data(min_electrode_beat_stdev_indx).window;
            figure();
            for i = 1:window
               %disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_times))
               %disp(electrode_data(min_electrode_beat_stdev_indx).stable_times(i, 1))
               %pause(666);
               plot(electrode_data(min_electrode_beat_stdev_indx).stable_times{i, 1}, electrode_data(min_electrode_beat_stdev_indx).stable_waveforms{i, 1});
               hold on;
            end
            
            re_run = 0;
            while(1)
                change_window = input('Is the time frame used to extract the stable beats acceptable?: (yes/no)\n', 's');
                if strcmpi(change_window, 'no')
                    re_run = 1;
                    %average_waveform_duration = input('What is the approximate duration you would like to use for the window used to compute the average waveform that will be used for depol/t-wave analysis (seconds): ');
                    break;
                elseif strcmpi(change_window, 'yes')
                    hold off;
                    %disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_data));
                    %pause(100);
                    figure();
                    plot(electrode_data(min_electrode_beat_stdev_indx).time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                    title(strcat(wellID, {' '}, 'Average Waveform'));
                    %disp(electrode_data(min_electrode_beat_stdev_indx).electrode_id)
                    break;
                end
            end
            if re_run == 0
                break;
            else
                plate_thresholding_analysis(AllDataRaw, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, average_waveform_duration, spon_paced)
            end
        end
    end
    %}
end


function [average_waveform_duration, average_waveform, min_stdev, artificial_time_space, electrode_data] = compute_electrode_average_stable_waveform(beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods, time, data, average_waveform_duration, electrode_data, electrode_count, electrode_id, plot_ave_dir, wellID)
    
    % Chnage to using a time frame and then calc percentage 
    %window = floor(size(beat_num_array)*0.25);
    %window = window(1);
    
    total_duration = time(end);
    %window = floor((total_duration/median(cycle_length_array)) / (average_waveform_duration/median(cycle_length_array)))
    %window = round(average_waveform_duration/median(cycle_length_array))
    window = round(average_waveform_duration/median(beat_periods))
    
    size_bna = size(beat_num_array);
    size_bna = size_bna(1);
    if window > size_bna
        average_waveform_duration = input('Error: the window size used to extract the average waveform is larger than the number of beats that were extracted. Please enter a new duration (secs):');
        while(1)
            window = round(average_waveform_duration/median(beat_periods));
            if window <= size_bna && window >1
                break;
            end
        end
    end
    
    
    if window <= 1
        average_waveform_duration = input('Error: the window size used to extract the average waveform is equal to 1. Please enter a new duration (secs):');
        while(1)
            window = round(average_waveform_duration/median(beat_periods));
            if window <= size_bna && window >1
                break;
            end
        end
    end
    std_devs_forward = [];
    std_devs_reverse = [];
    index_start_array = [];
    index_end_array = [];
    final_element = size_bna-1;
    %disp('forward');
    
    for w = 1:final_element
        %disp('window')
        %disp(w)
        end_window = w+window-1;
        if end_window >= final_element
            break
        end
        %disp(end_window)
        std_dev_array = [];
        index_start_array = [index_start_array; w];
        %disp('each element')
        for i = w:end_window
            %disp(i)
            %disp(beat_periods(i))
            std_dev_array = [std_dev_array; beat_periods(i)];
            
        end
        index_end_array = [index_end_array; i];
        std_dev = std(std_dev_array);
        std_devs_forward = [std_devs_forward; std_dev];
        
    end
    index_start_array_rev = [];
    index_end_array_rev = [];
    %disp('reverse')
    for w = final_element:-1:1
        %disp('window')
        %disp(w)
        end_window = w-window+1;
        %disp(end_window)
        std_dev_array_rev = [];
        
        if end_window < 1
            break
        end
        index_end_array_rev = [index_end_array_rev; w];
        %disp('each element')
        for i = w:-1:end_window
            %disp(i)
            
            std_dev_array_rev = [std_dev_array_rev; beat_periods(i)];
            
        end
        index_start_array_rev = [index_start_array_rev; i];
        std_dev = std(std_dev_array_rev);
        std_devs_reverse = [std_devs_forward; std_dev];
        
    end
    
    %disp(std_devs_forward)
    %disp(std_devs_reverse)
    indx_min_window_forward = find(std_devs_forward ~= 0);
    try
        indx_min_window_forward = find(std_devs_forward == min(std_devs_forward(indx_min_window_forward)));
    catch
        disp('FAIL INDX MIN WINDOW');
        disp('indx')
        disp(indx_min_window_forward);
        disp('std devs')
        disp(std_devs_forward)
        disp('cycle lengths')
        disp(cycle_length_array);
        disp('activation times')
        disp(activation_time_array);
        disp('start indxs')
        disp(index_start_array)
        
        pause(100000);
    end
    
    indx_min_window_rev = find(std_devs_reverse ~= 0);
    indx_min_window_rev = find(std_devs_reverse == min(std_devs_reverse(indx_min_window_rev)));
    
    if min(std_devs_forward(indx_min_window_forward))> min(std_devs_reverse(indx_min_window_rev))
        %disp('rev')
        try
            start_indx_min_window = index_start_array_rev(indx_min_window_rev);
            end_indx_min_window = index_end_array_rev(indx_min_window_rev);
            min_stdev = min(std_devs_reverse(indx_min_window_rev));
        catch
            disp('FAIL')
            disp('start array')
            disp(index_start_array_rev)
            disp('end array')
            disp(index_end_array_rev)
            disp('activation times')
            disp(activation_times)
            pause(20000);
        end
    else
        %disp('for')
        try
        %disp(min(std_devs_forward(indx_min_window_forward)))
        %disp(min(std_devs_reverse(indx_min_window_rev)))
            start_indx_min_window = index_start_array(indx_min_window_forward);
            end_indx_min_window = index_end_array(indx_min_window_forward);
            min_stdev = min(std_devs_forward(indx_min_window_forward));
        catch
            disp('FAIL')
            disp('start array')
            disp(index_start_array_forward)
            disp('end array')
            disp(index_end_array_forward)
            disp('activation times')
            disp(activation_time_array)
            pause(2000);
        end
    end

    %disp(indx_min_window)
    %disp(index_start_array)
    
    %start_indx_min_window = index_start_array(indx_min_window);
    %end_indx_min_window = index_end_array(indx_min_window);
    fig = figure();
    set(fig ,'Visible', 'off');
    plot(beat_num_array(start_indx_min_window:end_indx_min_window), beat_periods(start_indx_min_window:end_indx_min_window), 'ro')
    if ~exist(fullfile(plot_ave_dir, wellID, electrode_id), 'dir')
        mkdir(fullfile(plot_ave_dir, wellID, electrode_id));        
    end
    print(fullfile(plot_ave_dir, wellID, electrode_id, 'stable_ave_waveform_beat_periods'), '-dbitmap', '-r0');
    
    
    %% Compute the average beat by overlaying activation times
    %disp('activation times');
    
    average_waveform = [];
    sampling_rate = NaN;
    stable_data = StableWaveforms.empty(window, 0);
    for j = 1:(window)
        stable_data(j).waveform = [];
        stable_data(j).time = [];
    end
    
    wave_form_count = 0;
    %{
    stable_data = StableWaveforms.empty(window, 0);
    for s = 1:window
        stable_data(s).time = [];
        stable_data(s).waveform = [];
    end
    electrode_data(electrode_count).stable_data = stable_data;
    %}
    stable_waves = {};
    stable_times = {};
    for i = (start_indx_min_window+1): end_indx_min_window+1
        %disp(activation_time_array(i));
        %disp(i)
        if i > final_element
            window = window-1;            
            break;
        end
        wave_form_count = wave_form_count + 1;
        prev_activation_time = activation_time_array(i-1);
        activation_time = activation_time_array(i);
        prev_beat_start = beat_start_times(i-1);
        beat_start = beat_start_times(i);
        %disp('prev')
        %disp(prev_activation_time)
        %disp('curr')
        %disp(activation_time)
        indx_prev_act_time = find(time == prev_activation_time);
        indx_prev_beat_time = find(time == prev_beat_start);
        
        indx_act_time = find(time == activation_time);
        indx_beat_time = find(time == beat_start);
        %disp(time(indx_act_time))
        
        %data_array = data(indx_prev_act_time:indx_act_time);
        %time_array = time(indx_prev_act_time:indx_act_time);
        data_array = data(indx_prev_beat_time:indx_beat_time);
        time_array = time(indx_prev_beat_time:indx_beat_time);
        store_data_array = data_array;
        store_time_array = time_array;
        %disp(data_array(1))
        %pause(3)
        if isempty(average_waveform)
            average_waveform = data(indx_prev_beat_time:indx_beat_time); 
            %average_waveform = data(indx_prev_act_time:indx_act_time); 
            sampling_rate = time(2)-time(1);
        else
            size_wf = size(average_waveform);
            %size_data = size(data(indx_prev_act_time:indx_act_time));
            size_data = size(data(indx_prev_beat_time:indx_beat_time));
            
            if size_wf(1) > size_data(1)
                num_extra_elements = size_wf(1) - size_data(1);
                extra_elements = zeros(num_extra_elements, 1);
                ext_ra_elements = Inf(num_extra_elements, 1);
                %pause(10)
                data_array = cat(1, data_array, extra_elements);
                %pause(10)
                time_array = cat(1, time_array, extra_elements);
                store_data_array = cat(1, store_data_array, ext_ra_elements);
                store_time_array = cat(1, store_time_array, ext_ra_elements);
                
            elseif size_data(1) > size_wf(1)
                num_extra_elements = size_data(1) - size_wf(1);
                extra_elements = zeros(num_extra_elements, 1);
                %pause(10)
                average_waveform = cat(1, average_waveform, extra_elements);
                
            end
            %disp(size(average_waveform))
            %disp(size(data_array))
            %celldisp(stable_waves)
        
            %celldisp(stable_waves)
            %pause(110);

            average_waveform = average_waveform + data_array;
        end

        stable_waves = [stable_waves; {store_data_array}];
        stable_times = [stable_times; {store_time_array}];
        
        %disp(size(stable_waves))
        %plot(store_time_array, store_data_array);
        %hold on;
        %stable_data(end+1).time = time(indx_prev_act_time:indx_act_time);
        %stable_data(end+1).waveform = data(indx_prev_act_time:indx_act_time);
    end
    %print(fullfile(plot_ave_dir, wellID, electrode_id, 'overlaid_average_waveforms'), '-dbitmap', '-r0');
    %hold off;
    %pause(10);
    
    %{
    stable_beat_check = input('Do you want to keep the time frame used to extract the stable beats? (yes/no):\n', 's');
    
    if strcmpi(stable_beat_check, 'no')
        average_waveform_duration = input('What is the approximate duration you would like to use for the window used to compute the average waveform that will be used for depol/t-wave analysis (seconds): ');
        [average_waveform_duration] = compute_electrode_average_stable_waveform(beat_num_array, cycle_length_array, activation_time_array, time, data, average_waveform_duration);
    
    else
    %}
    
        average_waveform = average_waveform ./ window;
        len_wf = size(average_waveform);
        artificial_time_space = linspace(0,(sampling_rate*len_wf(1)),len_wf(1));
        fig = figure();
        set(fig ,'Visible', 'off');
        plot(artificial_time_space, average_waveform)
        print(fullfile(plot_ave_dir, wellID, electrode_id, 'average_waveform'), '-dbitmap', '-r0');

        
    %end
    %disp(window);
    electrode_data(electrode_count).min_stdev = min_stdev;
    electrode_data(electrode_count).average_waveform = average_waveform;
    electrode_data(electrode_count).time = artificial_time_space;
    electrode_data(electrode_count).electrode_id = electrode_id;
    electrode_data(electrode_count).stable_waveforms = stable_waves;
    electrode_data(electrode_count).stable_times = stable_times;
    electrode_data(electrode_count).window = window;
    %electrode_data(electrode_count).stable_data = stable_data;
    %disp(electrode_data(electrode_count).stable_data);
end

function [average_waveform, electrode_data] = compute_average_time_region_waveform(beat_num_array, cycle_length_array, activation_time_array, time, data, electrode_data, electrode_count, electrode_id, beat_periods, beat_start_times, plot_ave_dir, wellID)

    average_waveform = [];
    sampling_rate = NaN;    
    wave_form_count = 0;

    stable_waves = {};
    stable_times = {};
    disp(size(beat_periods))
    len = size(beat_periods);
    len = len(1);
    fig = figure();
    set(fig ,'Visible', 'off');
    hold on;
    for i = 2:len
        %disp(activation_time_array(i))
        wave_form_count = wave_form_count + 1;
        prev_activation_time = activation_time_array(i-1);
        activation_time = activation_time_array(i);
        prev_beat_start = beat_start_times(i-1);
        beat_start = beat_start_times(i);

        indx_prev_act_time = find(time == prev_activation_time);
        indx_prev_beat_time = find(time == prev_beat_start);
        
        indx_act_time = find(time == activation_time);
        indx_beat_time = find(time == beat_start);
        
        data_array = data(indx_prev_beat_time:indx_beat_time);
        time_array = time(indx_prev_beat_time:indx_beat_time);
        store_data_array = data_array;
        store_time_array = time_array;
        plot(time_array,data_array);
        
        if isempty(average_waveform)
            average_waveform = data(indx_prev_beat_time:indx_beat_time);  
            sampling_rate = time(2)-time(1);
        else
            size_wf = size(average_waveform);
            size_data = size(data(indx_prev_beat_time:indx_beat_time));
            
            if size_wf(1) > size_data(1)
                num_extra_elements = size_wf(1) - size_data(1);
                extra_elements = zeros(num_extra_elements, 1);
                ext_ra_elements = Inf(num_extra_elements, 1);
                data_array = cat(1, data_array, extra_elements);
                time_array = cat(1, time_array, extra_elements);
               
                store_data_array = cat(1, store_data_array, ext_ra_elements);
                store_time_array = cat(1, store_time_array, ext_ra_elements);
            elseif size_data(1) > size_wf(1)
                num_extra_elements = size_data(1) - size_wf(1);
                extra_elements = zeros(num_extra_elements, 1);
                average_waveform = cat(1, average_waveform, extra_elements);
                
            end
            
            average_waveform = average_waveform + data_array;
        end
        
        stable_waves = [stable_waves; {store_data_array}];
        stable_times = [stable_times; {store_time_array}];
        
    end
    title('overlaid waveforms')
    if ~exist(fullfile(plot_ave_dir, wellID, electrode_id), 'dir')
        mkdir(fullfile(plot_ave_dir, wellID, electrode_id));        
    end
    print(fullfile(plot_ave_dir, wellID, electrode_id, 'overlaid_average_waveforms'), '-dbitmap', '-r0');
    
    hold off;
    
    
    average_waveform = average_waveform ./ len;
    %disp(average_waveform)
    len_wf = size(average_waveform);
    artificial_time_space = linspace(0,(sampling_rate*len_wf(1)),len_wf(1));
    fig = figure();
    set(fig ,'Visible', 'off');
    plot(artificial_time_space, average_waveform)
    title('average waveform ' + wellID + {' '} + electrode_id)
    print(fullfile(plot_ave_dir, wellID, electrode_id, 'average_waveform'), '-dbitmap', '-r0');

    electrode_data(electrode_count).min_stdev = NaN;
    electrode_data(electrode_count).average_waveform = average_waveform;
    electrode_data(electrode_count).time = artificial_time_space;
    electrode_data(electrode_count).electrode_id = electrode_id;
    electrode_data(electrode_count).stable_waveforms = stable_waves;
    electrode_data(electrode_count).stable_times = stable_times;
    electrode_data(electrode_count).window = len;
    %electrode_data(electrode_count).stable_data = stable_data;

end

function [beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods] = extract_beats(wellID, time, data, bdt, spon_paced, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, stable_ave_analysis, average_waveform_time1, average_waveform_time2, plot_ave_dir, electrode_id)

    if strcmpi(beat_to_beat, 'on')
        disp(electrode_id);
        if strcmp(analyse_all_b2b, 'time_region')
            time_region_indx = find(time >= b2b_time_region1 & time <= b2b_time_region2);
            time = time(time_region_indx);
            data = data(time_region_indx);
            
        end
    else
        if strcmp(stable_ave_analysis, 'time_region')
            time_region_indx = find(time >= average_waveform_time1 & time <= average_waveform_time2);
            time = time(time_region_indx);
            data = data(time_region_indx);
        end
    end
    total_duration = time(end);
    
    prev_beat_indx = 1;
    beat_indx = 1;
    
    max_beat_period = 4;
    %max_beat_period = 17;  %seconds
    min_beat_period = 0.2;  %seconds
    post_spike_hold_off = 0.1;   %seconds
    window = 5;
    
    activation_time_array = [];
    beat_num_array = [];
    cycle_length_array = [];
    beat_start_times = [];
    beat_end_times = [];
    beat_periods = [];
    
    
    count = 0;
    t = 0;
    prev_activation_time = 0;
    %for t = 0:window:total_duration
    fail_beat_detection = 0;
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
           if isalmost(bdt, 0, 1E-10)
               disp('end of recording')
               break
           end
           
           % If fails on the first iteration, set the beat index to be back to the first point
           if prev_beat_indx == 1
               beat_indx = 1;
           else
               beat_indx = prev_beat_indx;
           end
           %{
           threshold_data = zeros(size(time(prev_beat_indx:end)));
           threshold_data(:) = bdt;
           disp('fail beat detection, continue')
           figure();
           plot(time(prev_beat_indx:end), data(prev_beat_indx:end));
           hold on;
           plot(time(prev_beat_indx:end), threshold_data);
           hold off;
           %pause(10)
           %}
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
          
          %if prev_beat_indx ~= 1
          beat_indx = prev_beat_indx;
          bdt = bdt/2;
          %window = window*1.5;
          if beat_time(end)+window > total_duration
               break;
          end
          if isalmost(bdt, 0, 1E-5)
             disp('end of recording')
             break
          end
          %else
              %prev_beat_indx = beat_indx;
              %prev_beat_indx = 1
          %end
          t = t - window;
          continue;
       end
       
       if beat_period < min_beat_period
           fail_beat_detection = fail_beat_detection+1;
           
           if fail_beat_detection >= 10
               break;
           end
           disp('bdt has been increased due to beat period being too short')
           
           disp(bdt)
           disp(fail_beat_detection)
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
       fail_beat_detection = 0;
       
       [activation_time, amplitude, max_depol_time, min_depol_time] = rate_analysis(beat_time, beat_data, post_spike_hold_off);
       
       activation_time_array = [activation_time_array; activation_time];
       cycle_length_array = [cycle_length_array; (activation_time-prev_activation_time)];
       beat_num_array = [beat_num_array; count];
       beat_start_times = [beat_start_times; beat_time(1)];
       beat_end_times = [beat_end_times; beat_time(end)];
       beat_periods = [beat_periods; beat_period];
       
       if strcmp(beat_to_beat, 'on')
           if count == 1
               figure();
               hold on;
               plot(beat_time, beat_data)
               %[t_wave_peak, ~] = t_wave_complex_analysis(beat_time, beat_data, beat_to_beat, activation_time, count, spon_paced);
               %FPD = t_wave_peak - activation_time;
               %disp(strcat('FPD = ', num2str(FPD)));
           elseif count >=1 && count < 4
               %FPD = (t_wave_peak+beat_time(1)) - activation_time;
               %disp(strcat('FPD = ', num2str(FPD)));
               plot(beat_time, beat_data)
           elseif count == 4
               plot(beat_time, beat_data)
               title('first 4 extracted beats')
               hold off;
               
               while(1)
                   mono_up_down = input('Would you characterise the T-waves for this well as monophasic upwards or downwards?: (up,down)\n', 's');
                   if strcmpi(mono_up_down, 'up')
                       break;
                   elseif strcmpi(mono_up_down, 'down')
                       break;
                   end
               end
           end
       end
       %pause(3);
       
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
    
    
    if strcmpi(beat_to_beat, 'on')
        for i = 2:length(activation_time_array)
            disp(strcat('Beat no. ', num2str(i)))
            if i == 2
                %figure();
                %plot(time, data);
                %title('First b2b extracted beat');
                %t_wave_peak_seed = input('On inpection of the first 4 extracted beats please enter the time point to use as the estimated peak of the T-wave complex:\n');
                t_wave_search_ratio = input('What duration of the waveforms seem to be dominated by the T-wave complex?:\n');
                figure();
            end
            beat_start = beat_start_times(i);
            %disp(length(beat_start));
            %disp(beat_start)
            %if i == length(activation_time_array)
            %    beat_end = time(end);
            %else
            beat_end = beat_end_times(i);
            %end
            beat_data = data(time >= beat_start & time <= beat_end);
            time_data = time(time >= beat_start & time <= beat_end);
            [activation_time, amplitude, max_depol_time, min_depol_time] = rate_analysis(time_data, beat_data, post_spike_hold_off);
       
            [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(time_data, beat_data, beat_to_beat, activation_time_array(i), i, spon_paced, mono_up_down, NaN, t_wave_search_ratio, post_spike_hold_off);
            %figure();
            %disp(FPD)
            %subplot(ceil(length(beat_start_times)/4), 4, i-1);
            plot(time_data, beat_data);
            hold on;
            %peak_indx = find(beat_data == t_wave_peak);
            %t_wave_peak_time = time_data(peak_indx(1));
            plot(t_wave_peak_time, t_wave_peak, 'ro');
            max_depol = beat_data(time_data == max_depol_time);
            %disp(min_depol_time)
            min_depol = beat_data(time_data == min_depol_time);
            act_point = beat_data(time_data == activation_time);
            plot(max_depol_time, max_depol, 'ro');
            plot(min_depol_time, min_depol, 'ro');
            plot(activation_time, act_point, 'ro');
            title(strcat('t-wave peak marked for electrode ', electrode_id));
            
            disp(strcat('FPD = ', num2str(FPD(1))));
            disp(strcat('Depol amplitude = ', num2str(amplitude)))
            
            %hold off;
            %pause(15);


        end
       
    end
    
    figure();
    plot(beat_num_array, cycle_length_array, 'bo');
    xlabel('Beat Number');
    ylabel('Cycle Length (s)');
    title(strcat('Cycle Length per Beat', {' '}, electrode_id));
    hold off;

    figure();
    plot(beat_num_array, beat_periods, 'bo');
    xlabel('Beat Number');
    ylabel('Beat Period (s)');
    title(strcat('Beat Period per Beat', {' '}, electrode_id));
    hold off;

    figure();
    plot(cycle_length_array(1:end-1), cycle_length_array(2:end), 'bo');
    xlabel('Cycle Length Previous Beat (s)');
    ylabel('Cycle Length (s)');
    title(strcat('Cycle Length vs Previous Beat Cycle Length', {' '}, electrode_id));
    hold off;
    %pause(30);
    
    %{
    if isnan(plot_ave_dir)
        figure();
        plot(beat_num_array, cycle_length_array, 'bo');
        xlabel('Beat Number');
        ylabel('Cycle Length (s)');
        title('Cycle Length per Beat');
        hold off;

        figure();
        plot(beat_num_array, beat_periods, 'bo');
        xlabel('Beat Number');
        ylabel('Beat Period (s)');
        title('Beat Period per Beat');
        hold off;

        figure();
        plot(cycle_length_array(1:end-1), cycle_length_array(2:end), 'bo');
        xlabel('Cycle Length Previous Beat (s)');
        ylabel('Cycle Length (s)');
        title('Cycle Length vs Previous Beat Cycle Length');
        hold off;
    else
        if ~exist(fullfile(plot_ave_dir, wellID, electrode_id), 'dir')
            mkdir(fullfile(plot_ave_dir, wellID, electrode_id))
        end
        fig = figure();
        set(fig ,'Visible', 'off');       
        plot(beat_num_array, cycle_length_array, 'bo');
        xlabel('Beat Number');
        ylabel('Cycle Length (s)');
        title('Cycle Length per Beat');
        print(fullfile(plot_ave_dir, wellID, electrode_id, 'cycle_length_per_beat'), '-dbitmap', '-r0');
        hold off;

        fig = figure();
        set(fig ,'Visible', 'off');  
        plot(beat_num_array, beat_periods, 'bo');
        xlabel('Beat Number');
        ylabel('Beat Period (s)');
        title('Beat Period per Beat');
        print(fullfile(plot_ave_dir, wellID, electrode_id, 'beat_period_per_beat'), '-dbitmap', '-r0');
        hold off;


        fig = figure();
        set(fig ,'Visible', 'off');  
        plot(cycle_length_array(1:end-1), cycle_length_array(2:end), 'bo');
        xlabel('Cycle Length Previous Beat (s)');
        ylabel('Cycle Length (s)');
        title('Cycle Length vs Previous Beat Cycle Length');
        print(fullfile(plot_ave_dir, wellID, electrode_id, 'cycle_length_vs_prev_beat_cl'), '-dbitmap', '-r0');
        hold off;
        
        
    end
    %}   
    
    %Find most stable beat periods
    
    

end

function [activation_time, amplitude, max_depol_time, min_depol_time] = rate_analysis(time, data, post_spike_hold_off)

    % propagation maps:
    % sort the first act time per electrode per well and then calc
    % delta_time between each 
    % Can use diff prop patterns - see statistic compiler. Some are more
    % common than others. Not default, need to be turned on. 
    
    post_spike_hold_off_time = time(1)+post_spike_hold_off;
    pshot_indx = find(time >= post_spike_hold_off_time);
    pshot_indx_offset = pshot_indx(1);
    
    depol_complex_time = time(1:pshot_indx_offset);
    depol_complex_data = data(1:pshot_indx_offset);
    depol_complex_data_derivative = gradient(depol_complex_data);
    %depol_complex_data_derivative = gradient(depol_complex_data_derivative);
    
    activation_time_indx = find(depol_complex_data_derivative == min(depol_complex_data_derivative));
    
    max_depol_point = max(depol_complex_data);
    max_depol_time = time(find(depol_complex_data == max_depol_point));
    
    min_depol_point = min(depol_complex_data);
    min_depol_time = time(find(depol_complex_data == min_depol_point));
    amplitude = max_depol_point - min_depol_point;
    
    if length(min_depol_time) > 1
        min_depol_time = min_depol_time(1);
        
    end
    if length(max_depol_time) > 1
        max_depol_time = max_depol_time(1);
        
    end
    
    %% To further refine the region to isolate the depol complex, perfrom std analysis
    
    %{
    figure()
    hold on;
    plot(depol_complex_time, depol_complex_data);
    %plot(depol_complex_time, depol_complex_data_derivative);
    plot(max_depol_time, max_depol_point, 'ro');
    plot(min_depol_time, min_depol_point, 'ro');
    plot(depol_complex_time(activation_time_indx(1)), depol_complex_data(activation_time_indx(1)), 'ro')
    xlabel('Time (secs)')
    ylabel('Voltage (V)')
    title('Extracted Depol. Complex');
    hold off;
    pause(5);
    %}
    
    activation_time = depol_complex_time(activation_time_indx(1));
    
    %% TO DO calculate max amplitude
    
    

end

function [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(time, data, beat_to_beat, activation_time, beat_no, spon_paced, mono_up_down, t_wave_peak, t_wave_search_duration, post_spike_holdoff)
    
    if strcmpi(beat_to_beat, 'off')
        t_wave_peak_time = input('On inpection of the waveform please enter the time point to use as the peak of the T-wave complex (seconds):\n');
        t_wave_peak = data(time == t_wave_peak_time);
    else
        %{
        %if strcmp(spon_paced, 'paced')
            if beat_no == 1
                %figure();
                %plot(time, data);
                %title('First b2b extracted beat');
                t_wave_peak = input('On inpection of the first 4 extracted beats please enter the time point to use as the estimated peak of the T-wave complex:\n');
            end
        %elseif strcmp(spon_paced, 'spon')
            %disp('beat to beat spontaneous data requires automated T-wave analysis')
            %t_wave_peak = NaN;
            %return;
        %end
        %}
        %t_wave_search_duration = (time(end)-time(1))*t_wave_search_ratio;
        if strcmp(mono_up_down, 'up')
            t_wave_indx = find(time >= time(1)+post_spike_holdoff & time <= time(1)+post_spike_holdoff+(t_wave_search_duration));
            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);
            t_wave_peak = max(t_wave_data);
            t_wave_peak_time = t_wave_time(t_wave_data == t_wave_peak);
        elseif strcmp(mono_up_down, 'down')            
            t_wave_indx = find(time >= time(1)+post_spike_holdoff & time <= time(1)+post_spike_holdoff+(t_wave_search_duration));
            t_wave_time = time(t_wave_indx);
            t_wave_data = data(t_wave_indx);
            t_wave_peak = min(t_wave_data);
            t_wave_peak_time = t_wave_time(t_wave_data == t_wave_peak);
            %t_wave_peak = t_wave_peak(1);
        end  
    end
    
    %disp(activation_time)
    %disp(t_wave_peak_time)
    FPD = t_wave_peak_time - activation_time;
    


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

