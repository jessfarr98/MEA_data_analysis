function analyse_MEA_signals_GUI(AllDataRaw,Stims, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_bdts, well_t_wave_durations, well_t_wave_shapes, well_time_reg_start_array, well_time_reg_end_array, well_stable_dur_array, added_wells, well_min_bp_array, well_max_bp_array, bipolar, post_spike_array, stim_spike_array, well_t_wave_time_array, well_fpd_array, filter_intensity_array, save_dir)
    close all hidden;
    close all;

    %disp('in analysis')
    %disp(spon_paced)
    %disp(beat_to_beat)
    %disp(stable_ave_analysis)
% analyse_MEA_signals(fullfile('data', '20200526_70-1915_empty(001).raw'), 'off', 'spon', 'on', 1)


% TO DO 21/01/2021
% cardiac standard paced and cardiac paced paced - analyse both and test if
% visual offsets of slopes show signals were affected by stimulus
% subtraction.

% test diff between 2000us and 600us stims as well.

% test if depol between raw and corrected has been corrupted - time and
% slope of steepest point and comparing between raw and corrected for
% various types of correction. 


% TO DO:
% stable region yes/no
% yes = Enter the time range or percentage
% no = user selected region: start time - end time and do beat averaging or b2b

% Offset the electrodes so you can see the spikes a bit easier when it does
% the initial display of electrodes overliad

% check plate thresholding functionality mirrors well thresholding

% TO DO 06/11/2020
% Compute the average waveforms not using the max dv/dt include all beat but store actiavtion times still as time 0 still for conduction maps

% electrode option for average wave analysis since t-waves may be off in golden electrode

% follow CiPA tool golden design and try follow the functionality when you can click a point and it finds the t-wave peak

% average_waveform analysis allow non-stable analysis using an input time frame. The current functionality is for stable analysis

% T-wave analysis start - user selected points easier to use for starting
% FPD calc

% Use better dataset for presentation
% Question: for well thresholding also prompt for each well the b2b/ave_waveform_duration?


% subplots of ave waveforms and overlaid ones
% warn user if entered time frame is not very stable - inspect bring up the plots to see distribution 


    tic;
    %plot_prompt = 'What would you like to name the directory that stores the plots of the data?\n';
    %plot_dir = prompt_user(plot_prompt, 'dir', 'data');
    
    %{
    FileData = AxisFile(input_file);
    AllDataRaw = FileData.DataSets.LoadData;
    Stims = [];
    if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
        Stims = sort([FileData.StimulationEvents(:).EventTime]);
    end
    %}

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
    
    well_thresholding = 'on';
    
    if strcmpi(well_thresholding, 'on')
        %disp('well');
        %%disp(well_min_bp_array);
        well_thresholding_analysis(AllDataRaw, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_bdts, well_t_wave_durations, well_t_wave_shapes, well_time_reg_start_array, well_time_reg_end_array, well_stable_dur_array, Stims, [added_wells], well_min_bp_array, well_max_bp_array, bipolar, post_spike_array, stim_spike_array, well_t_wave_time_array, well_fpd_array, filter_intensity_array, save_dir)
        
    else
        plate_thresholding_analysis(AllDataRaw, beat_to_beat, analyse_all_b2b, b2b_time_region1, b2b_time_region2, average_waveform_duration, spon_paced, bdt, stable_ave_analysis, average_waveform_time1, average_waveform_time2, plot_ave_dir)
        
        
    end

    
    elapsed_time_secs = toc;
    elapsed_time_mins = elapsed_time_secs/60;
    elapsed_time_hours = elapsed_time_mins/60;
    %disp(['Total run time was ' num2str(floor(elapsed_time_hours)) ' hours and ' num2str(mod(floor(elapsed_time_mins), 60)) ' minutes.']);
end

function well_thresholding_analysis(AllDataRaw, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_bdts, well_t_wave_durations, well_t_wave_shapes, well_time_reg_start_array, well_time_reg_end_array, well_stable_dur_array, Stims, added_wells, well_min_bp_array, well_max_bp_array, bipolar, post_spike_array, stim_spike_array, well_t_wave_time_array, well_fpd_array, filter_intensity_array, save_dir)
    shape_data = size(AllDataRaw);
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);

    
    %{
    %num_well_rows = 1;
    %num_well_cols = 1;
    num_electrode_rows = 1;
    num_electrode_cols = 1;
    %}

    total_wells = num_well_rows*num_well_cols;
    %well_thresholds = double.empty(total_wells, 0);
    
    %stable_ave_analysis = 'unknown';
    plot_ave_dir = NaN;

    well_count = 0;
    well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    
    %well_electrode_data = [];
    num_analysis_wells = length(added_wells);
    well_electrode_data = WellElectrodeData.empty(num_analysis_wells, 0);
    num_analysed = 1;
    wait_bar = waitbar(0, 'Commencing Analysis');
    num_partitions = 1/(num_analysis_wells*(num_electrode_rows*num_electrode_cols));
    partition = num_partitions;
    for w_r = 1:num_well_rows
        for w_c = 1:num_well_cols
            
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            if ~contains(added_wells, 'all')
                if ~contains(added_wells, wellID)
                    continue;
                end
            end
            
            well_count = well_count + 1;
            %%disp(strcat('Displaying well: ', {' '}, wellID))
            waveform = 0;
            time_offset = 0;
            for e_r = num_electrode_rows:-1:1
                for e_c = 1:num_electrode_cols
                %for e_c = num_electrode_cols:-1:1
                    %WellRawData = AllDataRaw{w_r, w_c, e_r, e_c}; %2/12/2021 was using the NORMAL computer convention of row, col electrode data index accessing, apparntly axis thinks col,row is logical 
                    WellRawData = AllDataRaw{w_r, w_c, e_c, e_r};
                    if strcmp(class(WellRawData),'Waveform')
                        %if ~empty(WellRawData)
                        [time, data] = WellRawData.GetTimeVoltageVector;
                        %data = data .* 1000;
                        waveform = 1;
                        electrode_id = strcat(wellID, {'_'}, string(e_c), {'_'}, string(e_r));

                    end
                end
            end
            if waveform == 1
                % EXTRACT ARRAY VALUES HERE AND FEED INTO ANALYSIS PIPELINE. MOVE DIR PROMPT TO START OF CODE
                %{
                if isnan(plot_ave_dir)
                    plot_ave_dir_prompt = 'Please enter the name of the directory that will store the plots of the waveforms used to calculate the average waveforms for each electrode:\n';
                    plot_ave_dir = prompt_user(plot_ave_dir_prompt, 'dir', 'data');
                end
                %}
                %added_wells_all = [added_wells_all wellID];
                disp(strcat('Analysing', {' '}, wellID));
                
                
                [well_electrode_data, partition] = extract_well_threshold_beats(AllDataRaw, wellID, num_well_rows, num_well_cols, num_electrode_cols, num_electrode_rows, well_bdts, well_dictionary, beat_to_beat, analyse_all_b2b, spon_paced, stable_ave_analysis, well_t_wave_durations, well_t_wave_shapes, well_time_reg_start_array, well_time_reg_end_array, well_stable_dur_array, w_r, w_c, well_count, plot_ave_dir, Stims, well_min_bp_array, well_max_bp_array, bipolar, post_spike_array, stim_spike_array, well_t_wave_time_array, well_fpd_array, filter_intensity_array, well_electrode_data, num_analysed, partition, num_partitions, wait_bar);
                num_analysed = num_analysed+1;
                %{
                if isempty(well_electrode_data)
                    %well_electrode_data = {electrode_data};
                    well_electrode_data = electrode_data;
                else
                    well_electrode_data = [well_electrode_data; electrode_data];
                end
                %}
                %well_electrode_data = 
                %MEA_GUI_analysis_display_results(AllDataRaw, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, electrode_data)
    
                % Command line results output
                %{
                while(1)
                    [electrode_data] = extract_well_threshold_beats(AllDataRaw, wellID, num_well_rows, num_well_cols, num_electrode_cols, num_electrode_rows, well_bdts, well_dictionary, beat_to_beat, analyse_all_b2b, spon_paced, stable_ave_analysis, well_t_wave_durations, well_t_wave_shapes, well_time_reg_start_array, well_time_reg_end_array, well_stable_dur_array, w_r, w_c, well_count, plot_ave_dir, Stims, well_min_bp_array, well_max_bp_array, bipolar);

                    if strcmpi(beat_to_beat, 'off')
                        %disp(stable_ave_analysis)
                        if strcmp(stable_ave_analysis, 'stable')
                            %disp('stable plots');
                            min_stdevs = [electrode_data(:).min_stdev];
                            min_electrode_beat_stdev_indx = find(min_stdevs == min(min_stdevs) & min_stdevs ~= 0, 1);

                            window = electrode_data(min_electrode_beat_stdev_indx).window;
                            figure();
                            for i = 1:window

                               %%disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_times))
                               %cell%disp(electrode_data(min_electrode_beat_stdev_indx).stable_times(i, 1))
                               %pause(666);
                               plot(electrode_data(min_electrode_beat_stdev_indx).stable_times{i, 1}, electrode_data(min_electrode_beat_stdev_indx).stable_waveforms{i, 1});
                               hold on;
                            end
                        end

                        re_run = 0;
                        while(1)
                            
                            change_window = input('Is the time frame used to extract the stable beats acceptable?: (yes/no)\n', 's');
                            %{
                            if strcmpi(change_window, 'no')
                                re_run = 1;
                                if strcmp(stable_ave_analysis, 'stable')
                                    average_waveform_duration = input('What is the approximate duration you would like to use for the window used to compute the average waveform that will be used for depol/t-wave analysis (seconds): ');
                                else
                                    average_waveform_time1 = input('Please enter the first time point from the time frame you would like to use to compute the average waveform: ');
                                    average_waveform_time2 = input('Please enter the last time point from the time frame you would like to use to compute the average waveform: ');

                                end
                                break;
                            %}
                            if strcmpi(change_window, 'yes')
                                if strcmp(stable_ave_analysis, 'stable')
                                    %disp('plot stable elecs and GE');
                                    hold off;
                                    %cell%disp(size(electrode_data(min_electrode_beat_stdev_indx).average_waveform));
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

                                               %%disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_times))
                                               %cell%disp(electrode_data(min_electrode_beat_stdev_indx).stable_times(i, 1))
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
                                    %%disp(electrode_data(min_electrode_beat_stdev_indx).electrode_id)
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
                                    
                                    [activation_time, amplitude, max_depol_time, max_depol, min_depol_time, min_depol] = rate_analysis(golden_electrode_data.time, golden_electrode_data.average_waveform, 0.1, 0.001, spon_paced, golden_electrode_data.time(1), 'GE');
                                    [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(golden_electrode_data.time, golden_electrode_data.average_waveform, beat_to_beat, activation_time, NaN, spon_paced, 'down', NaN, NaN, NaN);
                                    %disp(strcat('FPD = ', num2str(FPD)));
                                    %disp(strcat('Depol amplitude = ', num2str(amplitude)))
                                    t_time_indx = find(golden_electrode_data.time >= t_wave_peak_time);
                                    %max_depol = golden_electrode_data.average_waveform(golden_electrode_data.time == max_depol_time);
                                    %min_depol = golden_electrode_data.average_waveform(golden_electrode_data.time == min_depol_time);
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
                                            [activation_time, amplitude, max_depol_time, max_depol, min_depol_time, min_depol] = rate_analysis(electrode_data(i).time, electrode_data(i).average_waveform, 0.1, 0.001, spon_paced, electrode_data(i).time(1),  electrode_data(i).electrode_id);
                                            
                                            figure();
                                            plot(electrode_data(i).time, electrode_data(i).average_waveform);
                                            hold on;
                                            [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(electrode_data(i).time, electrode_data(i).average_waveform, beat_to_beat, activation_time, NaN, spon_paced, 'down', NaN, NaN, NaN); 
                                            t_time_indx = find(electrode_data(i).time >= t_wave_peak_time);
                                            plot(t_wave_peak_time, electrode_data(i).average_waveform(t_time_indx(1)), 'ro');
                                            %max_depol = electrode_data(i).average_waveform(electrode_data(i).time == max_depol_time);
                                            %min_depol = electrode_data(i).average_waveform(electrode_data(i).time == min_depol_time);
                                            act_point = electrode_data(i).average_waveform(electrode_data(i).time == activation_time);
                                            plot(max_depol_time, max_depol, 'ro');
                                            plot(min_depol_time, min_depol, 'ro');
                                            plot(activation_time, act_point, 'ro');
                                            title(strcat('Average Waveform for ',  electrode_data(i).electrode_id));
                                            hold off;
                                            %disp(strcat('FPD = ', num2str(FPD)));
                                            %disp(strcat('Depol amplitude = ', num2str(amplitude)))
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
                %}
            end
        end
    end
    
    close(wait_bar);
    
    if contains(added_wells, 'all')
       added_wells = added_wells_all; 
    end
    if strcmp(beat_to_beat, 'on')
        MEA_GUI_analysis_display_resultsV2(AllDataRaw, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar, save_dir)
    
    else
        if strcmp(stable_ave_analysis, 'stable')
            MEA_GUI_analysis_display_GE_results(AllDataRaw, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar, save_dir)
    
        else
            
            MEA_GUI_analysis_display_resultsV2(AllDataRaw, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar, save_dir)
    
        end
        
    end
end

function [well_electrode_data, partition] = extract_well_threshold_beats(AllDataRaw, wellID, num_well_rows, num_well_cols, num_electrode_cols, num_electrode_rows, well_bdts, well_dictionary, beat_to_beat, analyse_all_b2b, spon_paced, stable_ave_analysis, well_t_wave_durations, well_t_wave_shapes, well_time_reg_start_array, well_time_reg_end_array, well_stable_dur_array, w_r, w_c, well_count, plot_ave_dir, Stims, well_min_bp_array, well_max_bp_array, bipolar, post_spike_array, stim_spike_array, well_t_wave_time_array, well_fpd_array, filter_intensity_array, well_electrode_data, num_analysed, partition, num_partitions, wait_bar)
    
    wellID = strcat(well_dictionary(w_r), '0', string(w_c));

    %well_electrode_data = WellElectrodeData.empty();
    electrode_data = ElectrodeData.empty(num_electrode_cols*num_electrode_rows, 0);
    
    
    if strcmpi(beat_to_beat, 'off')
        if strcmp(stable_ave_analysis, 'stable')
            min_stdev = nan;
            min_stdev_indx = nan;
        end
    end
    for j = 1:(num_electrode_cols*num_electrode_rows)
        electrode_data(j).min_stdev = 0;
        electrode_data(j).average_waveform = [];
        electrode_data(j).ave_wave_time = [];
        electrode_data(j).time = [];
        electrode_data(j).data = [];
        electrode_data(j).electrode_id = '';
        electrode_data(j).stable_waveforms = {};
        electrode_data(j).stable_times = {};
        electrode_data(j).window = 0;
        electrode_data(j).activation_times = [];
        electrode_data(j).beat_num_array = []; 
        electrode_data(j).cycle_length_array = [];
        electrode_data(j).beat_start_times = [];
        electrode_data(j).beat_periods = [];
        electrode_data(j).t_wave_peak_times = [];
        electrode_data(j).t_wave_peak_array = [];
        electrode_data(j).max_depol_time_array = [];
        electrode_data(j).min_depol_time_array = [];
        electrode_data(j).max_depol_point_array = [];
        electrode_data(j).min_depol_point_array = [];
        electrode_data(j).activation_point_array = [];
        electrode_data(j).Stims = [];
        electrode_data(j).Stim_volts = [];
        electrode_data(j).ave_max_depol_time = 0;
        electrode_data(j).ave_min_depol_time = 0;
        electrode_data(j).ave_max_depol_point = 0;
        electrode_data(j).ave_min_depol_point = 0;
        electrode_data(j).ave_activation_time = 0;
        electrode_data(j).ave_t_wave_peak_time = 0;
        electrode_data(j).ave_depol_slope = 0;
        electrode_data(j).ave_warning = '';
        electrode_data(j).depol_slope_array = [];
        electrode_data(j).warning_array = [];
        
        
        electrode_data(j).bdt = NaN;
        electrode_data(j).min_bp = NaN;
        electrode_data(j).max_bp = NaN;
        electrode_data(j).post_spike_hold_off = NaN;
        electrode_data(j).t_wave_offset = NaN;
        electrode_data(j).t_wave_duration = NaN;
        electrode_data(j).t_wave_shape = '';
        electrode_data(j).stim_spike_hold_off = NaN;
        electrode_data(j).time_region_start = NaN;
        electrode_data(j).time_region_end = NaN;
        electrode_data(j).stable_beats_duration = NaN;
        electrode_data(j).filter_intensity = '';
        
        electrode_data(j).rejected = 0;
        
        electrode_data(j).spon_paced = spon_paced;
        
    end
    electrode_count = 0;

    start_activation_times = [];
    %for e_r = 1:num_electrode_rows
        %for e_c = num_electrode_cols:-1:1
     for e_r = num_electrode_rows:-1:1
         for e_c = 1:num_electrode_cols
            electrode_count = electrode_count+1;
            %WellRawData = AllDataRaw{w_r, w_c, e_r, e_c}; %%2/12/2021 was using the NORMAL computer convention of row, col electrode data index accessing, apparntly axis thinks col,row is logical 
            WellRawData = AllDataRaw{w_r, w_c, e_c, e_r};
            if strcmp(class(WellRawData),'Waveform')
            electrode_id = strcat(wellID, {'_'}, string(e_c), {'_'}, string(e_r));
            disp(strcat('Calculating', {' '}, electrode_id, {' '}, 'Fiducial Points'));
            %if ~empty(WellRawData)
                %if strcmpi(beat_to_beat, 'off')
                    %electrode_count = electrode_count+1;
                %end
                [time, data] = WellRawData.GetTimeVoltageVector;
                %%disp(well_bdts(well_count));
                stim_spike_hold_off = NaN;
                if strcmp(spon_paced, 'spon')
                    bdt = well_bdts(well_count);
                    min_bp = well_min_bp_array(well_count);
                    max_bp = well_max_bp_array(well_count);
                    
                    electrode_data(electrode_count).bdt = bdt;
                    electrode_data(electrode_count).min_bp = min_bp;
                    electrode_data(electrode_count).max_bp = max_bp;
                elseif strcmp(spon_paced, 'paced bdt')
                    bdt = well_bdts(well_count);
                    stim_spike_hold_off = stim_spike_array(well_count);
                    min_bp = well_min_bp_array(well_count);
                    max_bp = well_max_bp_array(well_count);
                    
                    electrode_data(electrode_count).bdt = bdt;
                    electrode_data(electrode_count).min_bp = min_bp;
                    electrode_data(electrode_count).max_bp = max_bp;
                    electrode_data(electrode_count).stim_spike_hold_off = stim_spike_hold_off;
                else 
                    bdt = 'N/A';
                    %disp(stim_spike_array)
                    stim_spike_hold_off = stim_spike_array(well_count);
                    electrode_data(electrode_count).stim_spike_hold_off = stim_spike_hold_off;
                end
                post_spike_hold_off = post_spike_array(well_count);
                
                t_wave_shape = well_t_wave_shapes(well_count);
   
                if t_wave_shape == 1
                    t_wave_shape = 'min';
                elseif t_wave_shape == 2
                    t_wave_shape = 'max';
                elseif t_wave_shape == 3
                    t_wave_shape = 'inflection';
                else
                    t_wave_shape = 'zero crossing';
                end
                
                filter_intensity = filter_intensity_array(well_count);
                if filter_intensity == 1
                    filter_intensity = 'none';
                elseif filter_intensity == 2
                    filter_intensity = 'low';
                elseif filter_intensity == 3
                    filter_intensity = 'medium';
                else
                    filter_intensity = 'strong';
                end
                
                t_wave_duration = well_t_wave_durations(well_count);
                est_peak_time = well_t_wave_time_array(well_count);
                %est_fpd = well_fpd_array(well_count);
                est_fpd = nan;
                
                electrode_data(electrode_count).post_spike_hold_off = post_spike_hold_off;
                electrode_data(electrode_count).t_wave_offset = est_peak_time;
                electrode_data(electrode_count).t_wave_duration = t_wave_duration;
                electrode_data(electrode_count).t_wave_shape = t_wave_shape;
                electrode_data(electrode_count).filter_intensity = filter_intensity;
                
                time_region1 = 'N/A';
                time_region2 = 'N/A';
                if ~isempty(well_time_reg_start_array)
                    time_region1 = well_time_reg_start_array(well_count);
                    time_region2 = well_time_reg_end_array(well_count);
                    
                    electrode_data(electrode_count).time_region_start = time_region1;
                    electrode_data(electrode_count).time_region_end = time_region2;
                end
                if strcmp(spon_paced, 'spon')
                    [beat_num_array, cycle_length_array, activation_time_array, activation_point_array, beat_start_times, beat_periods, t_wave_peak_times, t_wave_peak_array, max_depol_time_array, min_depol_time_array, max_depol_point_array, min_depol_point_array, depol_slope_array, warning_array] = extract_beats(wellID, time, data, bdt, spon_paced, beat_to_beat, analyse_all_b2b, time_region1, time_region2, stable_ave_analysis, time_region1, time_region2, plot_ave_dir, electrode_id, t_wave_shape, t_wave_duration, Stims, min_bp, max_bp, post_spike_hold_off, est_peak_time, est_fpd, filter_intensity);     

                elseif strcmp(spon_paced, 'paced bdt')
                    [beat_num_array, cycle_length_array, activation_time_array, activation_point_array, beat_start_times, beat_periods, t_wave_peak_times, t_wave_peak_array, max_depol_time_array, min_depol_time_array, max_depol_point_array, min_depol_point_array, depol_slope_array, warning_array, Stim_volts] = extract_paced_bdt_beats(wellID, time, data, bdt, spon_paced, beat_to_beat, analyse_all_b2b, time_region1, time_region2, stable_ave_analysis, time_region1, time_region2, plot_ave_dir, electrode_id, t_wave_shape, t_wave_duration, Stims, post_spike_hold_off, stim_spike_hold_off, est_peak_time, est_fpd, min_bp, max_bp, filter_intensity);     
                    electrode_data(electrode_count).Stim_volts = Stim_volts;
                elseif strcmp(spon_paced, 'paced')
                    [beat_num_array, cycle_length_array, activation_time_array, activation_point_array, beat_start_times, beat_periods, t_wave_peak_times, t_wave_peak_array, max_depol_time_array, min_depol_time_array, max_depol_point_array, min_depol_point_array, depol_slope_array, warning_array, Stim_volts] = extract_paced_beats(wellID, time, data, bdt, spon_paced, beat_to_beat, analyse_all_b2b, time_region1, time_region2, stable_ave_analysis, time_region1, time_region2, plot_ave_dir, electrode_id, t_wave_shape, t_wave_duration, Stims, post_spike_hold_off, stim_spike_hold_off, est_peak_time, est_fpd, filter_intensity);     
                    electrode_data(electrode_count).Stim_volts = Stim_volts;
                end

                electrode_data(electrode_count).electrode_id = electrode_id;
                electrode_data(electrode_count).Stims = Stims;
                electrode_data(electrode_count).activation_times = activation_time_array;
                electrode_data(electrode_count).beat_num_array = beat_num_array; 
                electrode_data(electrode_count).cycle_length_array = cycle_length_array;
                electrode_data(electrode_count).beat_start_times = beat_start_times;
                electrode_data(electrode_count).beat_periods = beat_periods;
                electrode_data(electrode_count).t_wave_peak_times = t_wave_peak_times;
                electrode_data(electrode_count).t_wave_peak_array = t_wave_peak_array;
                electrode_data(electrode_count).max_depol_time_array = max_depol_time_array;
                electrode_data(electrode_count).min_depol_time_array = min_depol_time_array;
                electrode_data(electrode_count).max_depol_point_array = max_depol_point_array;
                electrode_data(electrode_count).min_depol_point_array = min_depol_point_array;
                electrode_data(electrode_count).activation_point_array = activation_point_array;
                electrode_data(electrode_count).depol_slope_array = depol_slope_array;
                electrode_data(electrode_count).warning_array = warning_array;
                
                if strcmp(beat_to_beat, 'on')
                    if strcmp (analyse_all_b2b, 'all')
                        electrode_data(electrode_count).time = time;
                        electrode_data(electrode_count).data = data;
                    elseif strcmp(analyse_all_b2b, 'time_region')
                        
                        electrode_data(electrode_count).time = time(find(time>= time_region1 & time<=time_region2));
                        electrode_data(electrode_count).data = data(find(time>= time_region1 & time<=time_region2));
                        
                        
                    end
                else
                    if strcmp (stable_ave_analysis, 'stable')
                        electrode_data(electrode_count).time = time;
                        electrode_data(electrode_count).data = data;
                    elseif strcmp(stable_ave_analysis, 'time_region')
                        
                        electrode_data(electrode_count).time = time(find(time>= time_region1 & time<=time_region2));
                        electrode_data(electrode_count).data = data(find(time>= time_region1 & time<=time_region2));
                        
                    end
                end
                %start_activation_times = [start_activation_times; activation_time_array(2)];

                
                if strcmpi(beat_to_beat, 'off')
                    if strcmp(stable_ave_analysis, 'stable')
                        %disp(strcat('compute', electrode_id,'ave waveform'))
                        electrode_data(electrode_count).stable_beats_duration = well_stable_dur_array(well_count);
                        [average_waveform_duration, average_waveform, elec_min_stdev, artificial_time_space, electrode_data] = compute_electrode_average_stable_waveform(beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods, time, data, well_stable_dur_array(well_count), electrode_data, electrode_count, electrode_id, plot_ave_dir, wellID, post_spike_hold_off, stim_spike_hold_off, spon_paced, beat_to_beat, t_wave_shape, t_wave_duration, est_peak_time, est_fpd, filter_intensity);
                        %{
                        electrode_data(electrode_count).min_stdev = min_stdev;
                        electrode_data(electrode_count).average_waveform = average_waveform;
                        electrode_data(electrode_count).time = artificial_time_space;
                        electrode_data(electrode_count).electrode_id = electrode_id;
                        %}
                        if isnan(min_stdev)
                            min_stdev = elec_min_stdev;
                            min_stdev_indx = electrode_count;
                        else
                            
                        end
                    elseif strcmp(stable_ave_analysis, 'time_region')
                        %%disp('to be implemented')
                        [average_waveform, electrode_data] = compute_average_time_region_waveform(beat_num_array, cycle_length_array, activation_time_array, time, data, electrode_data, electrode_count, electrode_id, beat_periods, beat_start_times, plot_ave_dir, wellID, post_spike_hold_off, stim_spike_hold_off, spon_paced, beat_to_beat, t_wave_shape, t_wave_duration, est_peak_time, est_fpd, filter_intensity);

                    end
                end
                
            end
            %elecrode_count = electrode_count+1;
            waitbar(partition, wait_bar, strcat('Analysing', {' ' }, wellID))
            partition = partition+num_partitions;
        end
        %well_electrode_data = [well_electrode_data; electrode_data];
     end
     [conduction_velocity] = calculateConductionVelocity(electrode_data, num_electrode_rows, num_electrode_cols);
    
    well_electrode_data(num_analysed).electrode_data = electrode_data;
    well_electrode_data(num_analysed).wellID = wellID;
    well_electrode_data(num_analysed).rejected_well = 0;
    well_electrode_data(num_analysed).conduction_velocity = conduction_velocity;
    well_electrode_data(num_analysed).spon_paced = spon_paced;
    if strcmpi(beat_to_beat, 'off')
        if strcmp(stable_ave_analysis, 'stable')
            well_electrode_data(num_analysed).GE_electrode_indx = min_stdev_indx;
        end
    end
    
    %{
    conduction_map(start_activation_times, num_electrode_rows, num_electrode_cols, spon_paced)
    if strcmp(bipolar, 'on')
        calculate_bipolar_electrograms(AllDataRaw, w_r, w_c, num_electrode_rows, num_electrode_cols);

    end
    %}


end


function [average_waveform_duration, average_waveform, min_stdev, artificial_time_space, electrode_data] = compute_electrode_average_stable_waveform(beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods, time, data, average_waveform_duration, electrode_data, electrode_count, electrode_id, plot_ave_dir, wellID, post_spike_hold_off, stim_spike_hold_off, spon_paced, beat_to_beat, t_wave_shape, t_wave_duration, est_peak_time, est_fpd, filter_intensity)
    
    % Chnage to using a time frame and then calc percentage 
    %window = floor(size(beat_num_array)*0.25);
    %window = window(1);
    
    total_duration = time(end);
    %window = floor((total_duration/median(cycle_length_array)) / (average_waveform_duration/median(cycle_length_array)))
    %window = round(average_waveform_duration/median(cycle_length_array))
    window = round(average_waveform_duration/median(beat_periods));
    
    
    size_bna = size(beat_num_array);
    size_bna = size_bna(2);
    if window > size_bna
        input_string = sprintf('Error: the window size used to extract the average waveform is larger than the number of beats that were extracted. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a shorter duration (secs):', average_waveform_duration, median(beat_periods));
        
        while(1)
            
            average_waveform_duration = input(input_string);
            window = round(average_waveform_duration/median(beat_periods));
            if window <= size_bna && window >1
                break;
            else
                if window <= 1
                    input_string = sprintf('Error: the window size used to extract the average waveform is less than or equal to 1. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a longer duration (secs):', average_waveform_duration, median(beat_periods));
                else
                    input_string = sprintf('Error: the window size used to extract the average waveform is larger than the number of beats that were extracted. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a shorter duration (secs):', average_waveform_duration, median(beat_periods));
                    
                end
            end
        end
    end
    
    
    if window <= 1
        input_string = sprintf('Error: the window size used to extract the average waveform is less than or equal to 1. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a longer duration (secs):', average_waveform_duration, median(beat_periods));
        while(1)
            average_waveform_duration = input(input_string);
            window = round(average_waveform_duration/median(beat_periods));
            if window <= size_bna && window >1
                break;
            else
                if window <= 1
                    input_string = sprintf('Error: the window size used to extract the average waveform is less than or equal to 1. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a longer duration (secs):', average_waveform_duration, median(beat_periods));
                else
                    input_string = sprintf('Error: the window size used to extract the average waveform is larger than the number of beats that were extracted. The previous duration was %0.5f (s). The meidan BP is %0.5f (s). Please enter a shorter duration (secs):', average_waveform_duration, median(beat_periods));
                    
                end
            end
        end
    end
    std_devs_forward = [];
    std_devs_reverse = [];
    index_start_array = [];
    index_end_array = [];
    final_element = size_bna-1;
    %%disp('forward');
    
    for w = 1:final_element
        %%disp('window')
        %%disp(w)
        end_window = w+window-1;
        if end_window >= final_element
            break
        end
        %%disp(end_window)
        std_dev_array = [];
        index_start_array = [index_start_array; w];
        %%disp('each element')
        for i = w:end_window
            %%disp(i)
            %%disp(beat_periods(i))
            std_dev_array = [std_dev_array; beat_periods(i)];
            
        end
        index_end_array = [index_end_array; i];
        std_dev = std(std_dev_array);
        std_devs_forward = [std_devs_forward; std_dev];
        
    end
    index_start_array_rev = [];
    index_end_array_rev = [];
    %%disp('reverse')
    for w = final_element:-1:1
        %%disp('window')
        %%disp(w)
        end_window = w-window+1;
        %%disp(end_window)
        std_dev_array_rev = [];
        
        if end_window < 1
            break
        end
        index_end_array_rev = [index_end_array_rev; w];
        %%disp('each element')
        for i = w:-1:end_window
            %%disp(i)
            
            std_dev_array_rev = [std_dev_array_rev; beat_periods(i)];
            
        end
        index_start_array_rev = [index_start_array_rev; i];
        std_dev = std(std_dev_array_rev);
        std_devs_reverse = [std_devs_forward; std_dev];
        
    end
    
    %%disp(std_devs_forward)
    %%disp(std_devs_reverse)
    indx_min_window_forward = find(std_devs_forward ~= 0);
    try
        indx_min_window_forward = find(std_devs_forward == min(std_devs_forward(indx_min_window_forward)));
    catch
        %disp('FAIL INDX MIN WINDOW');
        %disp('indx')
        %disp(indx_min_window_forward);
        %disp('std devs')
        %disp(std_devs_forward)
        %disp('cycle lengths')
        %disp(cycle_length_array);
        %disp('activation times')
        %disp(activation_time_array);
        %disp('start indxs')
        %disp(index_start_array)
        
        pause(100000);
    end
    
    indx_min_window_rev = find(std_devs_reverse ~= 0);
    indx_min_window_rev = find(std_devs_reverse == min(std_devs_reverse(indx_min_window_rev)));
    
    if min(std_devs_forward(indx_min_window_forward))> min(std_devs_reverse(indx_min_window_rev))
        %%disp('rev')
        try
            start_indx_min_window = index_start_array_rev(indx_min_window_rev);
            end_indx_min_window = index_end_array_rev(indx_min_window_rev);
            min_stdev = min(std_devs_reverse(indx_min_window_rev));
        catch
            %disp('FAIL')
            %disp('start array')
            %disp(index_start_array_rev)
            %disp('end array')
            %disp(index_end_array_rev)
            %disp('activation times')
            %disp(activation_times)
            pause(20000);
        end
    else
        %%disp('for')
        try
        %%disp(min(std_devs_forward(indx_min_window_forward)))
        %%disp(min(std_devs_reverse(indx_min_window_rev)))
            start_indx_min_window = index_start_array(indx_min_window_forward);
            end_indx_min_window = index_end_array(indx_min_window_forward);
            min_stdev = min(std_devs_forward(indx_min_window_forward));
        catch
            %disp('FAIL')
            %disp('start array')
            %disp(index_start_array_forward)
            %disp('end array')
            %disp(index_end_array_forward)
            %disp('activation times')
            %disp(activation_time_array)
            pause(2000);
        end
    end

    %%disp(indx_min_window)
    %%disp(index_start_array)
    
    %start_indx_min_window = index_start_array(indx_min_window);
    %end_indx_min_window = index_end_array(indx_min_window);
    %fig = figure();
    %set(fig ,'Visible', 'off');
    %plot(beat_num_array(start_indx_min_window:end_indx_min_window), beat_periods(start_indx_min_window:end_indx_min_window), 'ro')
    %if ~exist(fullfile(plot_ave_dir, wellID, electrode_id), 'dir')
    %    mkdir(fullfile(plot_ave_dir, wellID, electrode_id));        
    %end
    %print(fullfile(plot_ave_dir, wellID, electrode_id, 'stable_ave_waveform_beat_periods'), '-dbitmap', '-r0');
    
    
    % Compute the average beat by overlaying activation times
    %%disp('activation times');
    
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
    stable_act_offsets = {};
    stable_act_offset_indxs = {};
    max_act_offset = nan;
    max_act_offset_indx = nan;
    for i = (start_indx_min_window+1): end_indx_min_window+1
        %%disp(activation_time_array(i));
        %%disp(i)
        if i > final_element
            window = window-1;            
            break;
        end
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
        
        act_indx = find(time_array == prev_activation_time);
        act_offset = prev_activation_time - time_array(1);
        
        
        if isnan(max_act_offset_indx)
            max_act_offset = act_offset;
            max_act_offset_indx = act_indx;
            
        end
        
        if act_offset > max_act_offset
            max_act_offset = act_offset;
            max_act_offset_indx = act_indx;
        end

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


            average_waveform = average_waveform + data_array;
        end

        stable_waves = [stable_waves; {data_array}];
        stable_times = [stable_times; {store_time_array}];
        stable_act_offsets = [stable_act_offsets; {act_offset}];
        stable_act_offset_indxs = [stable_act_offset_indxs; {act_indx}];


    end
    
    
    stable_waves_shape = size(stable_waves);
    
    average_waveform = [];
    for wf = 1:stable_waves_shape(1)
        act_offset_indx = stable_act_offset_indxs(wf, 1);
        act_offset_indx = act_offset_indx{1};
        num_extra_elements = max_act_offset_indx - act_offset_indx;
        if num_extra_elements == 0
            continue
        end
        extra_elements = zeros(num_extra_elements, 1);

        dat = stable_waves(wf, 1);
        dat = dat{1};
        %size_dat_before = size(dat)

        dat = cat(1, extra_elements, dat(1:end-num_extra_elements));
        size_dat_after = length(dat);
        
        size_ave = length(average_waveform);
        
        
        
        
        if isempty(average_waveform)
            average_waveform = dat;
        else
            
            
            if size_ave<size_dat_after
                num_extra_end_elements = size_dat_after-size_ave;

                extra_end_elements = zeros(num_extra_end_elements, 1);
                average_waveform = cat(1, average_waveform, extra_end_elements);
            end

            if size_ave>size_dat_after
                
                num_extra_end_elements = size_ave-size_dat_after;

                extra_end_elements = zeros(num_extra_end_elements, 1);
                dat = cat(1, dat, extra_end_elements);
            end
            average_waveform = average_waveform+dat;
            
        end
        
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


        
    %end
    %%disp(window);
    
    [activation_time, amplitude, max_depol_time, max_depol_point, min_depol_time, min_depol_point, slope, electrode_data(electrode_count).ave_warning] = rate_analysis(artificial_time_space, average_waveform, post_spike_hold_off, stim_spike_hold_off, spon_paced, artificial_time_space(1), electrode_id, filter_intensity, '');
    activation_time_indx = find(artificial_time_space >=max_act_offset);
    activation_time = artificial_time_space(activation_time_indx(1));
    [t_wave_peak_time, t_wave_peak, FPD, electrode_data(electrode_count).ave_warning] = t_wave_complex_analysis(artificial_time_space, average_waveform, beat_to_beat, activation_time, 0, spon_paced, t_wave_shape, NaN, t_wave_duration, post_spike_hold_off, est_peak_time, est_fpd, electrode_id, filter_intensity, electrode_data(electrode_count).ave_warning);
    
    
    
    electrode_data(electrode_count).min_stdev = min_stdev;
    electrode_data(electrode_count).average_waveform = average_waveform;
    electrode_data(electrode_count).ave_wave_time = artificial_time_space;
    electrode_data(electrode_count).electrode_id = electrode_id;
    electrode_data(electrode_count).stable_waveforms = stable_waves;
    electrode_data(electrode_count).stable_times = stable_times;
    electrode_data(electrode_count).window = window;
    electrode_data(electrode_count).ave_max_depol_time = max_depol_time;
    electrode_data(electrode_count).ave_min_depol_time = min_depol_time;
    electrode_data(electrode_count).ave_max_depol_point = max_depol_point;
    electrode_data(electrode_count).ave_min_depol_point = min_depol_point;
    electrode_data(electrode_count).ave_activation_time = activation_time;
    electrode_data(electrode_count).ave_t_wave_peak_time = t_wave_peak_time;
    electrode_data(electrode_count).ave_depol_slope = slope;
    
    %electrode_data(electrode_count).stable_data = stable_data;
    %%disp(electrode_data(electrode_count).stable_data);
end

function [average_waveform, electrode_data] = compute_average_time_region_waveform(beat_num_array, cycle_length_array, activation_time_array, time, data, electrode_data, electrode_count, electrode_id, beat_periods, beat_start_times, plot_ave_dir, wellID, post_spike_hold_off, stim_spike_hold_off, spon_paced, beat_to_beat, t_wave_shape, t_wave_duration, est_peak_time, est_fpd, filter_intensity)

    average_waveform = [];
    sampling_rate = NaN;    
    wave_form_count = 0;

    stable_waves = {};
    stable_times = {};
    stable_act_offsets = {};
    stable_act_offset_indxs = {};
    %disp(size(beat_periods))
    len = size(beat_periods);
    len = len(2);
    %fig = figure();
    %set(fig ,'Visible', 'off');
    %hold on;
    max_act_offset = nan;
    max_act_offset_indx = nan;
    
    min_act_offset = nan;
    min_act_offset_indx = nan;
    
    for i = 2:len
        %%disp(activation_time_array(i))
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
        act_indx = find(time_array == prev_activation_time);
        
        act_offset = prev_activation_time - time_array(1);
        
        
        if isnan(max_act_offset_indx)
            max_act_offset = act_offset;
            max_act_offset_indx = act_indx;
            
            min_act_offset = act_offset;
            min_act_offset_indx = act_indx;
        end
        
        if act_offset > max_act_offset
            max_act_offset = act_offset;
            max_act_offset_indx = act_indx;
        end
        
        if act_offset < min_act_offset
            min_act_offset = act_offset;
            min_act_offset_indx = act_indx;
        end
        time_array = time_array - time_array(1);
        %{
        data_array = data(indx_prev_act_time:indx_act_time);
        time_array = time(indx_prev_act_time:indx_act_time);
        %}
        
        store_data_array = data_array;
        store_time_array = time_array;
        %plot(time_array,data_array);
        
        if isempty(average_waveform)
            average_waveform = data(indx_prev_beat_time:indx_beat_time);
            %average_waveform = data(indx_prev_act_time:indx_act_time);
            sampling_rate = time(2)-time(1);
        else
            size_wf = size(average_waveform);
            size_data = size(data(indx_prev_beat_time:indx_beat_time));
            %size_data = size(data(indx_prev_act_time:indx_act_time));
            
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
        stable_act_offsets = [stable_act_offsets; {act_offset}];
        stable_act_offset_indxs = [stable_act_offset_indxs; {act_indx}];

        
    end

    
    %Overlay waveforms onto an activation point
    stable_waves_shape = size(stable_waves);
    
    max_extra = 0;
    average_waveform = [];
    new_stable_data = [];
    for wf = 1:stable_waves_shape(1)
        
        %stable_times(wf, 1) = stable_times(wf, 1)-min_act;
 
        act_offset_indx = stable_act_offset_indxs(wf, 1);
        act_offset_indx = act_offset_indx{1};
        num_extra_elements = max_act_offset_indx - act_offset_indx;
        if num_extra_elements == 0
            continue
        end
        extra_elements = zeros(num_extra_elements, 1);
        if num_extra_elements > max_extra
            max_extra = num_extra_elements;
        end
        
        time = stable_times(wf, 1);
        dat = stable_waves(wf, 1);
        time = time{1};
        %time = time-min_act_offset;
        dat = dat{1};
        

        dat = cat(1, extra_elements, dat(1:end-num_extra_elements));
        size_dat_after = length(dat);
        new_stable_data = [new_stable_data; {cat(1, extra_elements, dat)}];
        
        
        size_ave = length(average_waveform);
        
        if isempty(average_waveform)
            average_waveform = dat;
        else
            
            
            if size_ave<size_dat_after
                num_extra_end_elements = size_dat_after-size_ave;

                extra_end_elements = zeros(num_extra_end_elements, 1);
                average_waveform = cat(1, average_waveform, extra_end_elements);
            end

            if size_ave>size_dat_after
                
                num_extra_end_elements = size_ave-size_dat_after;

                extra_end_elements = zeros(num_extra_end_elements, 1);
                dat = cat(1, dat, extra_end_elements);
            end
            average_waveform = average_waveform+dat;
            
        end
        %[activation_time, amplitude, max_depol_time, max_depol_point, min_depol_time, min_depol_point, slope, electrode_data(electrode_count).ave_warning] = rate_analysis(time, dat, post_spike_hold_off, stim_spike_hold_off, spon_paced, time(1), electrode_id, filter_intensity, '');
        
        %act_point = dat(find(time == activation_time));
        
        %plot(activation_time, act_point, 'o');
        %plot(time , dat)
    end
    
    
    
    
    average_waveform = average_waveform ./ len;
    %%disp(average_waveform)
    
    len_wf = size(average_waveform);
    artificial_time_space = linspace(0,(sampling_rate*len_wf(1)),len_wf(1));
    
    
    %print(fullfile(plot_ave_dir, wellID, electrode_id, 'average_waveform'), '-dbitmap', '-r0');

    
    [activation_time, amplitude, max_depol_time, max_depol_point, min_depol_time, min_depol_point, slope, electrode_data(electrode_count).ave_warning] = rate_analysis(artificial_time_space, average_waveform, post_spike_hold_off, stim_spike_hold_off, spon_paced, artificial_time_space(1), electrode_id, filter_intensity, '');
    activation_time_indx = find(artificial_time_space >=max_act_offset);
    activation_time = artificial_time_space(activation_time_indx(1));
    [t_wave_peak_time, t_wave_peak, FPD] = t_wave_complex_analysis(artificial_time_space, average_waveform, beat_to_beat, activation_time, 0, spon_paced, t_wave_shape, NaN, t_wave_duration, post_spike_hold_off, est_peak_time, est_fpd, electrode_id, filter_intensity, electrode_data(electrode_count).ave_warning);
    
    
    electrode_data(electrode_count).min_stdev = NaN;
    electrode_data(electrode_count).average_waveform = average_waveform;
    electrode_data(electrode_count).ave_wave_time = artificial_time_space;
    electrode_data(electrode_count).electrode_id = electrode_id;
    electrode_data(electrode_count).stable_waveforms = stable_waves;
    electrode_data(electrode_count).stable_times = stable_times;
    electrode_data(electrode_count).window = len;
    electrode_data(electrode_count).ave_max_depol_time = max_depol_time;
    electrode_data(electrode_count).ave_min_depol_time = min_depol_time;
    electrode_data(electrode_count).ave_max_depol_point = max_depol_point;
    electrode_data(electrode_count).ave_min_depol_point = min_depol_point;
    electrode_data(electrode_count).ave_activation_time = activation_time;
    electrode_data(electrode_count).ave_t_wave_peak_time = t_wave_peak_time;
    electrode_data(electrode_count).ave_depol_slope = slope;
    
    %electrode_data(electrode_count).stable_data = stable_data;

end



function calculate_bipolar_electrograms(AllDataRaw, w_r, w_c, num_electrode_rows, num_electrode_cols)
    
    electrode_pairs = ["1_1:1_4", "2_1:2_4", "3_1:3_4'", "4_2:1_2", "4_3:1_3", "4_4:1_4"];
    electrodes = ["1_1", "1_4", "2_1", "2_4", "3_1", "3_4", "4_2", "1_2", "4_3", "1_3", "4_4"];
    %electrode_data = BipolarData.empty(length(electrodes), 0);
    bipolar_data = BipolarData.empty(length(electrode_pairs), 0);

    for j = 1:(length(electrode_pairs))
        bipolar_data(j).electrode_id = '';
        bipolar_data(j).wave_form = [];
        bipolar_data(j).time = [];
    end
    bipolar_count = 0;
    
    while(1)
        
        if isempty(electrodes)
            break;
        end
        found_init = 0;
        for e_r = 1:num_electrode_rows
            for e_c = num_electrode_cols:-1:1
                electrode_id = strcat(num2str(e_r), '_', num2str(e_c));
                yes_contains = contains(electrodes, electrode_id);
                init_elec = electrodes(yes_contains);
                electrodes = electrodes(~contains(electrodes, electrode_id));
                if ~isempty(init_elec)
                    init_bipolar_e_r = e_r;
                    init_bipolar_e_c = e_c;
                    found_init = 1;
                    %%disp(electrode_id)
                    break;
                end
                %WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
            end
            if found_init == 1
                break;
            end
        end

        found_pair1 = 0;
        found_pair2 = 0;
        for e_r = 1:num_electrode_rows
            
            for e_c = num_electrode_cols:-1:1
                electrode_id = strcat(num2str(e_r), '_', num2str(e_c));
                yes_contains = contains(electrodes, electrode_id);
                init_elec = electrodes(yes_contains);
                if ~isempty(init_elec)
                    if e_r == init_bipolar_e_r && e_c == init_bipolar_e_c
                        continue;
                    end
                    pair1 = strcat(num2str(init_bipolar_e_r),'_',num2str(init_bipolar_e_c),':',num2str(e_r),'_',num2str(e_c));
                    
                    pair2 = strcat(num2str(e_r),'_',num2str(e_c),':',num2str(init_bipolar_e_r),'_',num2str(init_bipolar_e_c));
                    
                    pair1_contains = contains(electrode_pairs, pair1);
                    pair_1_val = electrode_pairs(pair1_contains);
                    
                    pair2_contains = contains(electrode_pairs, pair2);
                    pair_2_val = electrode_pairs(pair2_contains);
                    
                    if ~isempty(pair_1_val)
                        %%disp('adding')
                        %%disp(pair1)
                        found_pair1 = 1;
                        bipolar_count = bipolar_count+1;
                        bipolar_data(bipolar_count).electrode_id = pair1;
                        
                        WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                        [time1, data1] = WellRawData.GetTimeVoltageVector;
                        
                        figure();
                        plot(time1, data1)
                        title(strcat(num2str(init_bipolar_e_r),'_',num2str(init_bipolar_e_c)))
                        
                        
                        
                        InitWellRawData = AllDataRaw{w_r, w_c, init_bipolar_e_r, init_bipolar_e_c};
                        [time2, data2] = InitWellRawData.GetTimeVoltageVector;
                        
                        figure();
                        plot(time2, data2)
                        title(strcat(num2str(e_r),'_',num2str(e_c)))
                        
                        bipolar_data(bipolar_count).wave_form = data1-data2;
                        
                        bipolar_data(bipolar_count).time = time2;
                        
                        electrode_pairs = electrode_pairs(~contains(electrode_pairs, pair1));
                        %break;
                    end
                    if ~isempty(pair_2_val)
                        %%disp('adding')
                        %%disp(pair2)
                        found_pair2 = 1;
                        bipolar_count = bipolar_count+1;
                        bipolar_data(bipolar_count).electrode_id = pair2;
                        
                        WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                        [time1, data1] = WellRawData.GetTimeVoltageVector;
                        
                        figure();
                        plot(time1, data1)
                        title(strcat(num2str(e_r),'_',num2str(e_c)))
                        
                        
                        
                        InitWellRawData = AllDataRaw{w_r, w_c, init_bipolar_e_r, init_bipolar_e_c};
                        [time2, data2] = InitWellRawData.GetTimeVoltageVector;
                        
                        figure();
                        plot(time2, data2)
                        title(strcat(num2str(init_bipolar_e_r),'_',num2str(init_bipolar_e_c)))
                        
                        bipolar_data(bipolar_count).wave_form = data2-data1;
                        
                        bipolar_data(bipolar_count).time = time2;
                        electrode_pairs = electrode_pairs(~contains(electrode_pairs, pair2));
                        %break;
                    end
 
                    
                end
                %WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
            end            
        end
    end
    
    %%disp('remaining pairs')
    %%disp(electrode_pairs)
    %%disp('Plotting')
    for bp = 1:bipolar_count
        %%disp(bipolar_data(bp).electrode_id);
        figure();
        plot(bipolar_data(bp).time, bipolar_data(bp).wave_form);
        title(strcat(bipolar_data(bp).electrode_id, {' '}, 'Bipolar Electrogram'));
        
    end
    

end

function dir_name = prompt_user(filename_prompt, file_dir, data_dir) 
% filename_prompt is the prompt that asks the user what they would like to name the specific file/dir
% file_dir is entered as either 'file' or 'dir' and indicates that the user is being prompted for either a file name or dir name

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
            %disp(['Overwriting' ' ' dir_name]);
            switch file_dir
                case 'dir' 
                    if strcmp(dir_name, data_dir)
                        %disp('Error: Blocked from overwriting the entire data directory.');
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
            %disp(wellID);
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
                        %%disp(electrode_id)
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
                                %%disp('to be implemented')
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
                    
                    %%disp(electrode_data(min_electrode_beat_stdev_indx).electrode_id)
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

                               %%disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_times))
                               %cell%disp(electrode_data(min_electrode_beat_stdev_indx).stable_times(i, 1))
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
                        %disp('No data for electrode');
                        continue;
                    end
                        
                    figure();
                    for i = 1:window

                       %%disp(size(electrode_data(min_electrode_beat_stdev_indx).stable_times))
                       %cell%disp(electrode_data(min_electrode_beat_stdev_indx).stable_times(i, 1))
                       
                       plot(golden_electrode_data.stable_times{i, 1}, golden_electrode_data.stable_waveforms{i, 1});
                       hold on;
                    end
                    hold off;
                    
                    figure();
                    plot(electrode_data(min_electrode_beat_stdev_indx).time, electrode_data(min_electrode_beat_stdev_indx).average_waveform);
                    title(strcat(golden_electrode_data.electrode_id, {' '}, 'Average Waveform'));
                    hold on;
                    
                    %cell%disp(size(electrode_data(min_electrode_beat_stdev_indx).average_waveform));
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
                    %disp(strcat('FPD = ', num2str(FPD)));
                    %disp(strcat('Depol amplitude = ', num2str(amplitude)))
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
                            %disp(strcat('FPD = ', num2str(FPD)));
                            %disp(strcat('Depol amplitude = ', num2str(amplitude)))
                            
                            hold off;
                            %pause(2)
                        end
                    end
                end
                
            end
           
        end
    end
end

