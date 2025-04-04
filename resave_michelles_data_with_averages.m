function resave_michelles_data_with_averages(raw_data_file, results_file)

%MEA_GUI_Load_Analysed_Data(fullfile('Y:', 'Recordings for jess', '20201202_73-0808_empty(006)_premstim_ectopic_beats.raw'), fullfile('data', 'test', 'D02.xls'))    

%%%%%%%%%%%%TO DO:
% conduction velocity model
% ave time region
% GE load script - is it even possible??????
% b2b all or time region




    [save_dir,wellID,ext] = fileparts(results_file);
    
    if strcmp(wellID, 'golden_electrode')
        disp('GE reload TBI');
        return
    end
    %wellID_acccess = replace(wellID, '0', '')
    well_dictionary = {'A', 'B', 'C', 'D', 'E', 'F'};
    
    split_wellID = strsplit(wellID, '0');
    wellID_row = split_wellID{1};
    wellID_col = str2num(split_wellID{2});
    
    wellID_row = find(strcmp(well_dictionary, wellID_row));    
    
    RawFileData = AxisFile(raw_data_file);
    Data = RawFileData.DataSets.LoadData;
    shape_data = size(Data);
    num_well_rows = shape_data(1);
    num_well_cols = shape_data(2);
    num_electrode_rows = shape_data(3);
    num_electrode_cols = shape_data(4);
    
    try
        Stims = sort([RawFileData.StimulationEvents(:).EventTime]);
        [br, bc] = size(Stims);
        Stims = reshape(Stims, [bc br]);
    catch
        Stims = [];
    end
    
    
    
    % Load Data into data structure to pass into the reanalysis GUI
    electrode_data = ElectrodeData.empty(num_electrode_cols*num_electrode_rows, 0);
    for j = 1:(num_electrode_cols*num_electrode_rows)
        electrode_data(j).min_stdev = 0;
        electrode_data(j).average_waveform = [];
        electrode_data(j).ave_wave_time = [];
        electrode_data(j).time = [];
        electrode_data(j).data = [];
        electrode_data(j).filtered_time = [];
        electrode_data(j).filtered_data = [];
        electrode_data(j).filtered_ave_wave_time = [];
        electrode_data(j).filtered_average_waveform = [];
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
        electrode_data(j).t_wave_wavelet_array = [];
        electrode_data(j).t_wave_polynomial_degree_array = [];
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
        electrode_data(j).beat_start_volts = [];


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
        
        electrode_data(j).ave_wave_post_spike_hold_off = nan;
        electrode_data(j).ave_wave_t_wave_offset = nan;
        electrode_data(j).ave_wave_t_wave_duration = nan;
        electrode_data(j).ave_wave_t_wave_shape = nan;
        electrode_data(j).ave_wave_stim_spike_hold_off = nan;
        electrode_data(j).ave_wave_filter_intensity = '';

        electrode_data(j).rejected = 0;

        if ~isempty(Stims)
            electrode_data(j).spon_paced = 'paced';
            spon_paced = 'paced';
        else
            electrode_data(j).spon_paced = 'spon';
            spon_paced = 'spon';
        end

    end
    
    electrode_count = 0;
    sheet_count = 3;
    change_all_data_type = 1;
    beat_to_beat = nan;
    analyse_all_b2b = nan;
    stable_ave_analysis = nan;
    
    electrode_stats_table = readcell(results_file, 'Sheet', 1);
    
    for e_r = num_electrode_rows:-1:1
        for e_c = 1:num_electrode_cols
            electrode_count = electrode_count+1;
            electrode_id = strcat(wellID, {'_'}, string(e_c), {'_'}, string(e_r));
            
            try
                electrode_table = readtable(results_file, 'Sheet', sheet_count);
            catch
                sheet_count = sheet_count+1;
               continue
            end
            [etr, etc] = size(electrode_table);
            if strcmp(spon_paced, 'paced')
                if etc == 22
                    electrode_data(electrode_count).spon_paced = 'paced bdt';
                else
                   change_all_data_type = 0;
                end
            end
            if isnan(beat_to_beat)
                if etr == 1
                    beat_to_beat = 'off';
                    stable_ave_analysis = 'time_region';
                elseif etr == 0
                    
                    electrode_data(electrode_count).time = Data{wellID_row,wellID_col,e_c,e_r}.GetTimeVector;
                    electrode_data(electrode_count).data = Data{wellID_row,wellID_col,e_c,e_r}.GetVoltageVector;
                    electrode_data(electrode_count).electrode_id = electrode_id;
                    
                    electrode_data(electrode_count).rejected = 1;
                    sheet_count = sheet_count+1;
                    continue

                else
                    beat_to_beat = 'on';
                    
                    
                    [etsr, etsc] = size(electrode_stats_table);
                    
                    if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                        %if mod((etsr-10), 12) == 0
                        analyse_all_b2b = 'all';

                        %{
                        if mod((etsr-11), 13) == 0
                            analyse_all_b2b = 'all';

                        else
                            analyse_all_b2b = 'time_region';
                        end
                        %}
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                        %if mod((etsr-13), 15) == 0
                        if mod((etsr-13), 16) == 0
                            analyse_all_b2b = 'all';

                        else
                            analyse_all_b2b = 'time_region';
                        end
                        
                    else
                        %if mod((etsr-10), 15) == 0
                        analyse_all_b2b = 'all';
                        %{
                        if mod((etsr-11), 16) == 0
                            analyse_all_b2b = 'all';

                        else
                            analyse_all_b2b = 'time_region';
                        end
                        %}
                        
                    end
                end
            end
                      
            electrode_data(electrode_count).time = Data{wellID_row,wellID_col,e_c,e_r}.GetTimeVector;
            electrode_data(electrode_count).data = Data{wellID_row,wellID_col,e_c,e_r}.GetVoltageVector;
            electrode_data(electrode_count).electrode_id = electrode_id;

            
            if etr >= 1
                electrode_data(electrode_count).rejected = 0;
            %else
                %electrode_data(electrode_count).rejected = 1;
                %sheet_count = sheet_count+1;
                %continue
            end
            
            
            
            if strcmp(stable_ave_analysis, 'time_region')
                if etr < 1
                    electrode_data(electrode_count).rejected = 1;
                    sheet_count = sheet_count+1;
                    continue
                end

                %{
                    electrode_data(electrode_count).bdt = NaN;
                    electrode_data(electrode_count).min_bp = NaN;
                    electrode_data(electrode_count).max_bp = NaN;
                   
                    electrode_data(electrode_count).post_spike_hold_off = str2num(string(electrode_stats_table{post_spike_indx, 2}));
                    electrode_data(electrode_count).t_wave_offset = str2num(string(electrode_stats_table{t_wave_offset_indx, 2}));
                    electrode_data(electrode_count).t_wave_duration = str2num(string(electrode_stats_table{t_wave_dur_indx, 2}));
                    electrode_data(electrode_count).t_wave_shape = string(electrode_stats_table(t_wave_shape_indx, 2));
                    disp((electrode_data(electrode_count).t_wave_shape))
                    electrode_data(electrode_count).stim_spike_hold_off = str2num(string(electrode_stats_table{stim_spike_indx, 2}));
                    
                    electrode_data(electrode_count).stable_beats_duration = NaN;
                    
                    electrode_data(electrode_count).filter_intensity = string(electrode_stats_table{filter_indx, 2});
                %}
                
                
                if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                    electrode_data(electrode_count).time_region_start = str2num(string(electrode_table{1, 16}));
                    electrode_data(electrode_count).time_region_end = str2num(string(electrode_table{1, 17}));
                    
                    electrode_data(electrode_count).bdt = str2num(string(electrode_table{1, 18}));
                    electrode_data(electrode_count).min_bp = str2num(string(electrode_table{1, 19}));
                    electrode_data(electrode_count).max_bp = str2num(string(electrode_table{1, 20}));
                    electrode_data(electrode_count).post_spike_hold_off = str2num(string(electrode_table{1, 21}));
                    electrode_data(electrode_count).t_wave_offset = str2num(string(electrode_table{1, 22}));
                    electrode_data(electrode_count).t_wave_duration =  str2num(string(electrode_table{1, 23}));
                    electrode_data(electrode_count).t_wave_shape =  (string(electrode_table{1, 24}));
                    
                    electrode_data(electrode_count).filter_intensity =  (string(electrode_table{1, 25}));
                    
                    electrode_data(electrode_count).ave_wave_post_spike_hold_off =  str2num(string(electrode_table{1, 26}));
                    electrode_data(electrode_count).ave_wave_t_wave_duration =  str2num(string(electrode_table{1, 27}));
                    electrode_data(electrode_count).ave_wave_t_wave_offset =  str2num(string(electrode_table{1, 28}));
                    electrode_data(electrode_count).ave_wave_t_wave_shape =  (string(electrode_table{1, 29}));
                    electrode_data(electrode_count).ave_wave_filter_intensity =  (string(electrode_table{1, 30}));

                    
                    electrode_data(electrode_count).ave_t_wave_wavelet = (string(electrode_table{1, 31}));
                    electrode_data(electrode_count).ave_t_wave_polynomial_degree = str2num(string(electrode_table{1, 32}));
                    
                    electrode_data(electrode_count).ave_warning =  (string(electrode_table{1, 33}));

                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array, electrode_data(electrode_count).depol_slope_array,electrode_data(electrode_count).warning_array, electrode_data(electrode_count).filtered_time,electrode_data(electrode_count).filtered_data, electrode_data(electrode_count).t_wave_wavelet_array, electrode_data(electrode_count).t_wave_polynomial_degree_array] = extract_beats_V2(wellID, electrode_data(electrode_count).time, electrode_data(electrode_count).data, electrode_data(electrode_count).bdt, spon_paced, beat_to_beat, analyse_all_b2b, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, stable_ave_analysis, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, 'N/A', electrode_id, electrode_data(electrode_count).t_wave_shape, electrode_data(electrode_count).t_wave_duration, Stims, electrode_data(electrode_count).min_bp, electrode_data(electrode_count).max_bp, electrode_data(electrode_count).post_spike_hold_off, electrode_data(electrode_count).t_wave_offset, nan, electrode_data(electrode_count).filter_intensity);
                    
                    
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                    
                    electrode_data(electrode_count).time_region_start = str2num(string(electrode_table{1, 14}));
                    electrode_data(electrode_count).time_region_end = str2num(string(electrode_table{1, 15}));
                    
                    electrode_data(electrode_count).stim_spike_hold_off = str2num(string(electrode_table{1, 16}));
                    electrode_data(electrode_count).post_spike_hold_off = str2num(string(electrode_table{1, 17}));
                    electrode_data(electrode_count).t_wave_offset = str2num(string(electrode_table{1, 18}));
                    electrode_data(electrode_count).t_wave_duration =  str2num(string(electrode_table{1, 19}));
                    electrode_data(electrode_count).t_wave_shape =  (string(electrode_table{1, 20}));
                    
                    electrode_data(electrode_count).filter_intensity =  (string(electrode_table{1, 21}));
                    
                    electrode_data(electrode_count).ave_wave_stim_spike_hold_off = str2num(string(electrode_table{1, 22}));
                    electrode_data(electrode_count).ave_wave_post_spike_hold_off =  str2num(string(electrode_table{1, 23}));
                    electrode_data(electrode_count).ave_wave_t_wave_duration =  str2num(string(electrode_table{1, 24}));
                    electrode_data(electrode_count).ave_wave_t_wave_offset =  str2num(string(electrode_table{1, 25}));
                    electrode_data(electrode_count).ave_wave_t_wave_shape =  (string(electrode_table{1, 26}));
                    electrode_data(electrode_count).ave_wave_filter_intensity =  (string(electrode_table{1, 27}));
                    
                    electrode_data(electrode_count).ave_t_wave_wavelet = (string(electrode_table{1, 28}));
                    electrode_data(electrode_count).ave_t_wave_polynomial_degree = str2num(string(electrode_table{1, 29}));

                    electrode_data(electrode_count).ave_warning =  (string(electrode_table{1, 30}));
 
                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array, electrode_data(electrode_count).depol_slope_array, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).Stim_volts, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data,electrode_data(electrode_count). t_wave_wavelet_array, electrode_data(electrode_count).t_wave_polynomial_degree_array] = extract_paced_beats(wellID, electrode_data(electrode_count).time, electrode_data(electrode_count).data, electrode_data(electrode_count).bdt, spon_paced, beat_to_beat, analyse_all_b2b, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, stable_ave_analysis, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, 'N/A', electrode_id, electrode_data(electrode_count).t_wave_shape, electrode_data(electrode_count).t_wave_duration, Stims, electrode_data(electrode_count).post_spike_hold_off, electrode_data(electrode_count).stim_spike_hold_off, electrode_data(electrode_count).t_wave_offset, nan, electrode_data(electrode_count).filter_intensity);     
                    
                else
                    electrode_data(electrode_count).time_region_start = str2num(string(electrode_table{1, 14}));
                    electrode_data(electrode_count).time_region_end = str2num(string(electrode_table{1, 15}));
                    
                    electrode_data(electrode_count).bdt = str2num(string(electrode_table{1, 16}));
                    electrode_data(electrode_count).min_bp = str2num(string(electrode_table{1, 17}));
                    electrode_data(electrode_count).max_bp = str2num(string(electrode_table{1, 18}));
                    electrode_data(electrode_count).stim_spike_hold_off = str2num(string(electrode_table{1, 19}));
                    electrode_data(electrode_count).post_spike_hold_off = str2num(string(electrode_table{1, 20}));
                    electrode_data(electrode_count).t_wave_offset = str2num(string(electrode_table{1, 21}));
                    electrode_data(electrode_count).t_wave_duration =  str2num(string(electrode_table{1, 22}));
                    electrode_data(electrode_count).t_wave_shape =  (string(electrode_table{1, 23}));
                    
                    electrode_data(electrode_count).filter_intensity =  (string(electrode_table{1, 24}));
                    
                    electrode_data(electrode_count).ave_wave_stim_spike_hold_off = str2num(string(electrode_table{1, 25}));
                    electrode_data(electrode_count).ave_wave_post_spike_hold_off =  str2num(string(electrode_table{1, 26}));
                    electrode_data(electrode_count).ave_wave_t_wave_duration =  str2num(string(electrode_table{1, 27}));
                    electrode_data(electrode_count).ave_wave_t_wave_offset =  str2num(string(electrode_table{1, 28}));
                    electrode_data(electrode_count).ave_wave_t_wave_shape =  (string(electrode_table{1, 29}));
                    electrode_data(electrode_count).ave_wave_filter_intensity =  (string(electrode_table{1, 30}));
                    
                    electrode_data(electrode_count).ave_t_wave_wavelet = (string(electrode_table{2, 31}));
                    electrode_data(electrode_count).ave_t_wave_polynomial_degree = str2num(string(electrode_table{1, 32}));

                    electrode_data(electrode_count).ave_warning =  (string(electrode_table{1, 33}));
                    
                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array, electrode_data(electrode_count).depol_slope_array, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).Stim_volts, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data, electrode_data(electrode_count).t_wave_wavelet_array, electrode_data(electrode_count).t_wave_polynomial_degree_array] = extract_paced_bdt_beats(wellID, electrode_data(electrode_count).time, electrode_data(electrode_count).data, electrode_data(electrode_count).bdt, spon_paced, beat_to_beat, analyse_all_b2b, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, stable_ave_analysis, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, 'N/A', electrode_id, electrode_data(electrode_count).t_wave_shape, electrode_data(electrode_count).t_wave_duration, electrode_data(electrode_count).Stims, electrode_data(electrode_count).post_spike_hold_off, electrode_data(electrode_count).stim_spike_hold_off, electrode_data(electrode_count).t_wave_offset, nan, electrode_data(electrode_count).min_bp, electrode_data(electrode_count).max_bp, electrode_data(electrode_count).filter_intensity);     
                    
                    
                end
                
                [~, electrode_data] = compute_average_time_region_waveform(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).time, electrode_data(electrode_count).data, electrode_data, electrode_count, electrode_id, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).beat_start_times, 'N/A', wellID, electrode_data(electrode_count).ave_wave_post_spike_hold_off, electrode_data(electrode_count).ave_wave_stim_spike_hold_off, spon_paced, beat_to_beat, electrode_data(electrode_count).ave_wave_t_wave_shape, electrode_data(electrode_count).ave_wave_t_wave_duration, electrode_data(electrode_count).ave_wave_t_wave_offset, nan, electrode_data(electrode_count).ave_wave_filter_intensity, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end);

                
                electrode_data(electrode_count).ave_activation_time = str2num(string(electrode_table{1, 2}));
                electrode_data(electrode_count).ave_activation_point = str2num(string(electrode_table{1, 3}));
                
                electrode_data(electrode_count).ave_min_depol_time = str2num(string(electrode_table{1, 4}));
                electrode_data(electrode_count).ave_min_depol_point = str2num(string(electrode_table{1, 5}));
                
                electrode_data(electrode_count).ave_max_depol_time = str2num(string(electrode_table{1, 6}));
                electrode_data(electrode_count).ave_max_depol_point = str2num(string(electrode_table{1, 7}));
                
                electrode_data(electrode_count).ave_depol_slope = str2num(string(electrode_table{1, 9}));
                
                electrode_data(electrode_count).ave_t_wave_peak_time = str2num(string(electrode_table{1, 10}));
                electrode_data(electrode_count).ave_t_wave_peak = str2num(string(electrode_table{1, 11}));
                
                electrode_data(electrode_count).electrode_id = electrode_id;
                
                
                  
            else
                if etr < 1
                    electrode_data(electrode_count).rejected = 1;
                    %sheet_count = sheet_count+1;
                    %continue
                end
                
                
                %{
                if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                    if strcmp(analyse_all_b2b, 'time_region')
                        conduction_velocity = electrode_stats_table{12, 2};
                        
                        %electrode_stats_indx = (electrode_count-1)*18+13;
                        electrode_stats_indx = (electrode_count-1)*19+14;
                        
                        time_start_indx = electrode_stats_indx+8;
                        time_end_indx = electrode_stats_indx+9;
                        bdt_indx = electrode_stats_indx+10;
                        min_bp_indx = electrode_stats_indx+11;
                        max_bp_indx = electrode_stats_indx+12;
                        post_spike_indx = electrode_stats_indx+13;
                        t_wave_dur_indx = electrode_stats_indx+14;
                        t_wave_offset_indx = electrode_stats_indx+15;
                        t_wave_shape_indx = electrode_stats_indx+16;
                        filter_indx = electrode_stats_indx+17;   
                        
                        electrode_data(electrode_count).time_region_start = str2num(string(electrode_stats_table{time_start_indx, 2}));
                        electrode_data(electrode_count).time_region_end = str2num(string(electrode_stats_table{time_end_indx, 2}));
                    else
                        conduction_velocity = electrode_stats_table{12, 2};
                        %electrode_stats_indx = (electrode_count-1)*16+13;
                        electrode_stats_indx = (electrode_count-1)*17+14;
                        
                        bdt_indx = electrode_stats_indx+8;
                        min_bp_indx = electrode_stats_indx+9;
                        max_bp_indx = electrode_stats_indx+10;
                        post_spike_indx = electrode_stats_indx+11;
                        t_wave_dur_indx = electrode_stats_indx+12;
                        t_wave_offset_indx = electrode_stats_indx+13;
                        t_wave_shape_indx = electrode_stats_indx+14;
                        filter_indx = electrode_stats_indx+15;   
                        
                        electrode_data(electrode_count).time_region_start = NaN;
                        electrode_data(electrode_count).time_region_end = NaN;
                    end
                    
                    
                    electrode_data(electrode_count).bdt = str2num(string(electrode_stats_table{bdt_indx, 2}));
                    electrode_data(electrode_count).min_bp = str2num(string(electrode_stats_table{min_bp_indx, 2}));
                    electrode_data(electrode_count).max_bp = str2num(string(electrode_stats_table{max_bp_indx, 2}));
                    electrode_data(electrode_count).post_spike_hold_off = str2num(string(electrode_stats_table{post_spike_indx, 2}));
                    electrode_data(electrode_count).t_wave_offset = str2num(string(electrode_stats_table{t_wave_offset_indx, 2}));
                    electrode_data(electrode_count).t_wave_duration = str2num(string(electrode_stats_table{t_wave_dur_indx, 2}));
                    electrode_data(electrode_count).t_wave_shape = string(electrode_stats_table{t_wave_shape_indx, 2});
                    
                    electrode_data(electrode_count).stim_spike_hold_off = NaN;
                    
                    electrode_data(electrode_count).stable_beats_duration = NaN;
                    
                    electrode_data(electrode_count).filter_intensity = string(electrode_stats_table{filter_indx, 2});
                    
                    % Reshape arrays 
                    
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                    
                    if strcmp(analyse_all_b2b, 'time_region')
                        conduction_velocity = electrode_stats_table{10, 2};
                        
                        %electrode_stats_indx = (electrode_count-1)*14+11;
                        electrode_stats_indx = (electrode_count-1)*15+12;
                        
                        time_start_indx = electrode_stats_indx+6;
                        time_end_indx = electrode_stats_indx+7;
                        stim_spike_indx = electrode_stats_indx+8;
                        post_spike_indx = electrode_stats_indx+9;
                        t_wave_dur_indx = electrode_stats_indx+10;
                        t_wave_offset_indx = electrode_stats_indx+11;
                        t_wave_shape_indx = electrode_stats_indx+12;
                        filter_indx = electrode_stats_indx+13; 
                        
                        electrode_data(electrode_count).time_region_start = str2num(string(electrode_stats_table{time_start_indx, 2}));
                        electrode_data(electrode_count).time_region_end = str2num(string(electrode_stats_table{time_end_indx, 2}));
                    else
                        conduction_velocity = electrode_stats_table{10, 2};
                        %electrode_stats_indx = (electrode_count-1)*12+11;
                        electrode_stats_indx = (electrode_count-1)*13+12;
                        
                        stim_spike_indx = electrode_stats_indx+6;
                        post_spike_indx = electrode_stats_indx+7;
                        t_wave_dur_indx = electrode_stats_indx+8;
                        t_wave_offset_indx = electrode_stats_indx+9;
                        t_wave_shape_indx = electrode_stats_indx+10;
                        filter_indx = electrode_stats_indx+11;   
                        
                        electrode_data(electrode_count).time_region_start = NaN;
                        electrode_data(electrode_count).time_region_end = NaN;
                    end
                    
                    electrode_data(electrode_count).bdt = NaN;
                    electrode_data(electrode_count).min_bp = NaN;
                    electrode_data(electrode_count).max_bp = NaN;
                   
                    electrode_data(electrode_count).post_spike_hold_off = str2num(string(electrode_stats_table{post_spike_indx, 2}));
                    electrode_data(electrode_count).t_wave_offset = str2num(string(electrode_stats_table{t_wave_offset_indx, 2}));
                    electrode_data(electrode_count).t_wave_duration = str2num(string(electrode_stats_table{t_wave_dur_indx, 2}));
                    electrode_data(electrode_count).t_wave_shape = string(electrode_stats_table(t_wave_shape_indx, 2));
                    disp((electrode_data(electrode_count).t_wave_shape))
                    electrode_data(electrode_count).stim_spike_hold_off = str2num(string(electrode_stats_table{stim_spike_indx, 2}));
                    
                    electrode_data(electrode_count).stable_beats_duration = NaN;
                    
                    electrode_data(electrode_count).filter_intensity = string(electrode_stats_table{filter_indx, 2});
                else
                    if strcmp(analyse_all_b2b, 'time_region')
                        conduction_velocity = electrode_stats_table{10, 2};
                        %electrode_stats_indx = (electrode_count-1)*17+11;
                        electrode_stats_indx = (electrode_count-1)*18+12;
                        
                        time_start_indx = electrode_stats_indx+6;
                        time_end_indx = electrode_stats_indx+7;
                        bdt_indx = electrode_stats_indx+8;
                        min_bp_indx = electrode_stats_indx+9;
                        max_bp_indx = electrode_stats_indx+10;
                        stim_spike_indx = electrode_stats_indx+11;
                        post_spike_indx = electrode_stats_indx+12;
                        t_wave_dur_indx = electrode_stats_indx+13;
                        t_wave_offset_indx = electrode_stats_indx+14;
                        t_wave_shape_indx = electrode_stats_indx+15;
                        filter_indx = electrode_stats_indx+16;   
                        
                        electrode_data(electrode_count).time_region_start = str2num(string(electrode_stats_table{time_start_indx, 2}));
                        electrode_data(electrode_count).time_region_end = str2num(string(electrode_stats_table{time_end_indx, 2}));
                    else
                        conduction_velocity = electrode_stats_table{10, 2};
                        %electrode_stats_indx = (electrode_count-1)*15+11;
                        electrode_stats_indx = (electrode_count-1)*16+12;
                        
                        bdt_indx = electrode_stats_indx+6;
                        min_bp_indx = electrode_stats_indx+7;
                        max_bp_indx = electrode_stats_indx+8;
                        stim_spike_indx = electrode_stats_indx+9;
                        post_spike_indx = electrode_stats_indx+10;
                        t_wave_dur_indx = electrode_stats_indx+11;
                        t_wave_offset_indx = electrode_stats_indx+12;
                        t_wave_shape_indx = electrode_stats_indx+13;
                        filter_indx = electrode_stats_indx+14;   
                        
                        electrode_data(electrode_count).time_region_start = NaN;
                        electrode_data(electrode_count).time_region_end = NaN;
                    end
    
                    
                    electrode_data(electrode_count).bdt = str2num(string(electrode_stats_table{bdt_indx, 2}));
                    electrode_data(electrode_count).min_bp = str2num(string(electrode_stats_table{min_bp_indx, 2}));
                    electrode_data(electrode_count).max_bp = str2num(string(electrode_stats_table{max_bp_indx, 2}));
                    electrode_data(electrode_count).post_spike_hold_off = str2num(string(electrode_stats_table{post_spike_indx, 2}));
                    electrode_data(electrode_count).t_wave_offset = str2num(string(electrode_stats_table{t_wave_offset_indx, 2}));
                    electrode_data(electrode_count).t_wave_duration = str2num(string(electrode_stats_table{t_wave_dur_indx, 2}));
                    electrode_data(electrode_count).t_wave_shape = string(electrode_stats_table{t_wave_shape_indx, 2});
                    electrode_data(electrode_count).stim_spike_hold_off = str2num(string(electrode_stats_table{stim_spike_indx, 2}));
                    
                    
                    electrode_data(electrode_count).stable_beats_duration = NaN;
                    
                    electrode_data(electrode_count).filter_intensity = string(electrode_stats_table{filter_indx, 2});
                end
                %}
                
                
                
                
                %{
                electrode_data(electrode_count).stable_waveforms = {};
                electrode_data(electrode_count).stable_times = {};
                electrode_data(electrode_count).window = 0;
                %}
                
                %'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Beat Start Volts (V)", "Activation Time (s)", "Activation Time Volts (V)", "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "Paced/Ectopic",  "Warnings"]));

                
                beat_num_array = table2array(electrode_table(:, 2));
                [r, c] = size(beat_num_array);
                beat_num_array = reshape(beat_num_array, [c, r]);
                electrode_data(electrode_count).beat_num_array = beat_num_array;
                
                beat_start_times = table2array(electrode_table(:, 3));
                [r, c] = size(beat_start_times);
                beat_start_times = reshape(beat_start_times, [c, r]);
                electrode_data(electrode_count).beat_start_times = beat_start_times;
                
                beat_start_volts = table2array(electrode_table(:, 4));
                [r, c] = size(beat_start_volts);
                beat_start_volts = reshape(beat_start_volts, [c, r]);
                electrode_data(electrode_count).beat_start_volts = beat_start_volts;
                
                activation_times = table2array(electrode_table(:, 5));
                [r, c] = size(activation_times);
                activation_times = reshape(activation_times, [c, r]);
                electrode_data(electrode_count).activation_times = activation_times;
                
                activation_point_array = table2array(electrode_table(:, 6));
                [r, c] = size(activation_point_array);
                activation_point_array = reshape(activation_point_array, [c, r]);
                electrode_data(electrode_count).activation_point_array = activation_point_array;
                
                if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                    indx_offset = 1;
                    
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                    indx_offset = 2;
                    
                else
                    indx_offset = 0;
                    
                end
                
                
                min_depol_time_array = table2array(electrode_table(:, 7+indx_offset)); 
                %min_depol_time_array = table2array(electrode_table(:, 9)); 
                [r, c] = size(min_depol_time_array);
                min_depol_time_array = reshape(min_depol_time_array, [c, r]);
                electrode_data(electrode_count).min_depol_time_array = min_depol_time_array;
                
                min_depol_point_array = table2array(electrode_table(:, 8+indx_offset));
                %min_depol_point_array = table2array(electrode_table(:, 10));
                [r, c] = size(min_depol_point_array);
                min_depol_point_array = reshape(min_depol_point_array, [c, r]);
                electrode_data(electrode_count).min_depol_point_array = min_depol_point_array;
                
                max_depol_time_array = table2array(electrode_table(:, 9+indx_offset));
                %max_depol_time_array = table2array(electrode_table(:, 11));
                [r, c] = size(max_depol_time_array);
                max_depol_time_array = reshape(max_depol_time_array, [c, r]);
                electrode_data(electrode_count).max_depol_time_array = max_depol_time_array;
                
                max_depol_point_array = table2array(electrode_table(:, 10+indx_offset));
                %max_depol_point_array = table2array(electrode_table(:, 12));
                [r, c] = size(max_depol_point_array);
                max_depol_point_array = reshape(max_depol_point_array, [c, r]);
                electrode_data(electrode_count).max_depol_point_array = max_depol_point_array;
                
                depol_slope_array = table2array(electrode_table(:, 12+indx_offset));
                %depol_slope_array = table2array(electrode_table(:, 14));
                [r, c] = size(depol_slope_array);
                depol_slope_array = reshape(depol_slope_array, [c, r]);
                electrode_data(electrode_count).depol_slope_array = depol_slope_array;
                
                t_wave_peak_times = table2array(electrode_table(:, 13+indx_offset));
                %t_wave_peak_times = table2array(electrode_table(:, 15));
                [r, c] = size(t_wave_peak_times);
                t_wave_peak_times = reshape(t_wave_peak_times, [c, r]);
                electrode_data(electrode_count).t_wave_peak_times = t_wave_peak_times;
                
                t_wave_peak_array = table2array(electrode_table(:, 14+indx_offset));
                %t_wave_peak_array = table2array(electrode_table(:, 16));
                [r, c] = size(t_wave_peak_array);
                t_wave_peak_array = reshape(t_wave_peak_array, [c, r]);
                electrode_data(electrode_count).t_wave_peak_array = t_wave_peak_array;
                
                beat_periods = table2array(electrode_table(:, 16+indx_offset));
                %beat_periods = table2array(electrode_table(:, 18));
                [r, c] = size(beat_periods);
                beat_periods = reshape(beat_periods, [c, r]);
                electrode_data(electrode_count).beat_periods = beat_periods;
                
                cycle_length_array = table2array(electrode_table(:, 17+indx_offset));
                %cycle_length_array = table2array(electrode_table(:, 19));
                [r, c] = size(cycle_length_array);
                cycle_length_array = reshape(cycle_length_array, [c, r]);
                electrode_data(electrode_count).cycle_length_array = cycle_length_array;
                
                
          
                %{
                
                beat_num_array = table2array(electrode_table(:, 2));
                [r, c] = size(beat_num_array);
                beat_num_array = reshape(beat_num_array, [c, r]);
                electrode_data(electrode_count).beat_num_array = beat_num_array;
                
                beat_start_times = table2array(electrode_table(:, 3));
                [r, c] = size(beat_start_times);
                beat_start_times = reshape(beat_start_times, [c, r]);
                electrode_data(electrode_count).beat_start_times = beat_start_times;
                
                beat_start_volts = table2array(electrode_table(:, 4));
                [r, c] = size(beat_start_volts);
                beat_start_volts = reshape(beat_start_volts, [c, r]);
                electrode_data(electrode_count).beat_start_volts = beat_start_volts;
                
                activation_times = table2array(electrode_table(:, 5));
                [r, c] = size(activation_times);
                activation_times = reshape(activation_times, [c, r]);
                electrode_data(electrode_count).activation_times = activation_times;
                
                activation_point_array = table2array(electrode_table(:, 6));
                [r, c] = size(activation_point_array);
                activation_point_array = reshape(activation_point_array, [c, r]);
                electrode_data(electrode_count).activation_point_array = activation_point_array;
                
                min_depol_time_array = table2array(electrode_table(:, 7)); 
                [r, c] = size(min_depol_time_array);
                min_depol_time_array = reshape(min_depol_time_array, [c, r]);
                electrode_data(electrode_count).min_depol_time_array = min_depol_time_array;
                
                min_depol_point_array = table2array(electrode_table(:, 8));
                [r, c] = size(min_depol_point_array);
                min_depol_point_array = reshape(min_depol_point_array, [c, r]);
                electrode_data(electrode_count).min_depol_point_array = min_depol_point_array;
                
                max_depol_time_array = table2array(electrode_table(:, 9));
                [r, c] = size(max_depol_time_array);
                max_depol_time_array = reshape(max_depol_time_array, [c, r]);
                electrode_data(electrode_count).max_depol_time_array = max_depol_time_array;
                
                max_depol_point_array = table2array(electrode_table(:, 10));
                [r, c] = size(max_depol_point_array);
                max_depol_point_array = reshape(max_depol_point_array, [c, r]);
                electrode_data(electrode_count).max_depol_point_array = max_depol_point_array;
                
                depol_slope_array = table2array(electrode_table(:, 12));
                [r, c] = size(depol_slope_array);
                depol_slope_array = reshape(depol_slope_array, [c, r]);
                electrode_data(electrode_count).depol_slope_array = depol_slope_array;
                
                t_wave_peak_times = table2array(electrode_table(:, 13));
                [r, c] = size(t_wave_peak_times);
                t_wave_peak_times = reshape(t_wave_peak_times, [c, r]);
                electrode_data(electrode_count).t_wave_peak_times = t_wave_peak_times;
                
                t_wave_peak_array = table2array(electrode_table(:, 14));
                [r, c] = size(t_wave_peak_array);
                t_wave_peak_array = reshape(t_wave_peak_array, [c, r]);
                electrode_data(electrode_count).t_wave_peak_array = t_wave_peak_array;
                
                beat_periods = table2array(electrode_table(:, 16));
                [r, c] = size(beat_periods);
                beat_periods = reshape(beat_periods, [c, r]);
                electrode_data(electrode_count).beat_periods = beat_periods;
                
                cycle_length_array = table2array(electrode_table(:, 17));
                [r, c] = size(cycle_length_array);
                cycle_length_array = reshape(cycle_length_array, [c, r]);
                electrode_data(electrode_count).cycle_length_array = cycle_length_array;
                %}
                %if etc == 21
                
                
                
                if strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                    %wavelet_families = table2array(electrode_table(:, 19));
                    wavelet_families = table2array(electrode_table(:, 20));
                    [r, c] = size(wavelet_families);
                    wavelet_families = reshape(wavelet_families, [c, r]);
                    
                    %polynomial_degrees = table2array(electrode_table(:, 20));
                    polynomial_degrees = table2array(electrode_table(:, 21));
                    [r, c] = size(polynomial_degrees);
                    polynomial_degrees = reshape(polynomial_degrees, [c, r]);
                
                
                    %electrode_data(electrode_count).warning_array = table2array(electrode_table(:, 21));
                    electrode_data(electrode_count).warning_array = table2array(electrode_table(:, 22));
                    [r, c] = size(electrode_data(electrode_count).warning_array);
                    electrode_data(electrode_count).warning_array = reshape(electrode_data(electrode_count).warning_array, [c, r]);
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                    %wavelet_families = table2array(electrode_table(:, 20));
                    wavelet_families = table2array(electrode_table(:, 21));
                    [r, c] = size(wavelet_families);
                    wavelet_families = reshape(wavelet_families, [c, r]);
                    
                    %polynomial_degrees = table2array(electrode_table(:, 21));
                    polynomial_degrees = table2array(electrode_table(:, 22));
                    [r, c] = size(polynomial_degrees);
                    polynomial_degrees = reshape(polynomial_degrees, [c, r]);
                
                    %electrode_data(electrode_count).warning_array = table2array(electrode_table(:, 22));
                    electrode_data(electrode_count).warning_array = table2array(electrode_table(:, 23));
                    [r, c] = size(electrode_data(electrode_count).warning_array);
                    electrode_data(electrode_count).warning_array = reshape(electrode_data(electrode_count).warning_array, [c, r]);
                else
                    wavelet_families = table2array(electrode_table(:, 19));
                    [r, c] = size(wavelet_families);
                    wavelet_families = reshape(wavelet_families, [c, r]);
                    
                    %polynomial_degrees = table2array(electrode_table(:, 21));
                    polynomial_degrees = table2array(electrode_table(:, 20));
                    [r, c] = size(polynomial_degrees);
                    polynomial_degrees = reshape(polynomial_degrees, [c, r]);
                
                    %electrode_data(electrode_count).warning_array = table2array(electrode_table(:, 22));
                    electrode_data(electrode_count).warning_array = table2array(electrode_table(:, 21));
                    [r, c] = size(electrode_data(electrode_count).warning_array);
                    electrode_data(electrode_count).warning_array = reshape(electrode_data(electrode_count).warning_array, [c, r]);
                end 
                
                electrode_data(electrode_count).t_wave_wavelet_array = wavelet_families;
                electrode_data(electrode_count).t_wave_polynomial_degree_array = polynomial_degrees;
                
                %[electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data] = generate_filtered_data_b2b(electrode_data(electrode_count).time, electrode_data(electrode_count).data, beat_start_times, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).filter_intensity, wavelet_families, polynomial_degrees, spon_paced, electrode_data(electrode_count).t_wave_offset, electrode_data(electrode_count).t_wave_duration, electrode_data(electrode_count).t_wave_shape, electrode_data(electrode_count).post_spike_hold_off, electrode_data(electrode_count).stim_spike_hold_off);
                
                %{
                figure();
                hold on;
                plot(electrode_data(electrode_count).time, electrode_data(electrode_count).data)
                plot(electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko')
                plot(electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array*1000, 'co')
                %}
                %hold off;

                if ~strcmp(spon_paced, 'spon')
                    electrode_data(electrode_count).Stims = Stims;
                    [r, c] = size(electrode_data(electrode_count).Stims);
                    electrode_data(electrode_count).Stims = reshape(electrode_data(electrode_count).Stims, [c, r]);
                    
                    Stim_volts = [];
                    for s = 1:length(Stims)
                       stim_indx = find(electrode_data(electrode_count).time >= Stims(s)); 
                       
                       Stim_volts = [Stim_volts electrode_data(electrode_count).data(stim_indx(1))];
                        
                    end
                    electrode_data(electrode_count).Stim_volts = Stim_volts;
                    
                end
                
            end
            
            if strcmp(beat_to_beat, 'on')
                [electrode_data(electrode_count).arrhythmia_indx, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).num_arrhythmic] = arrhythmia_analysis(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).warning_array);
            end
            
            sheet_count = sheet_count+1;
        end
    end
    
    if strcmp(spon_paced, 'paced')
       if change_all_data_type == 1
           spon_paced = 'paced bdt';
           
       end
    end
    
    added_wells = [];
    %wellID_str = strcat(well_dictionary(wellID_row), '0', num2str(wellID_col));
    added_wells = [added_wells; string(wellID)];
    
    bipolar = 'on';
    
    well_electrode_data = WellElectrodeData.empty(1, 0);
    
    disp(wellID)
    if strcmp(beat_to_beat, 'on')
        if strcmp(spon_paced, 'spon')
            [conduction_velocity, model] =  calculateSpontaneousConductionVelocity(wellID, electrode_data,  num_electrode_rows, num_electrode_cols, nan);

        else
            [conduction_velocity, model] =  calculatePacedConductionVelocity(wellID, electrode_data,  num_electrode_rows, num_electrode_cols, nan);

        end
        well_electrode_data(1).conduction_velocity = conduction_velocity;
        well_electrode_data(1).conduction_velocity_model = model;
    
    end
    
    
    well_electrode_data(1).electrode_data = electrode_data;
    well_electrode_data(1).wellID = wellID;
    well_electrode_data(1).rejected_well = 0;
    
    well_electrode_data(1).spon_paced = spon_paced;
    
    %disp(save_dir)
    
    
    
    save_dir = fullfile(save_dir, 'resave_aves_correct_CVs');
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
        
    end
    
    
    
    saveB2BButtonPushed(1, save_dir, wellID, num_electrode_rows, num_electrode_cols, 0, 0, well_electrode_data, 'all', conduction_velocity)
    
    %MEA_GUI_analysis_display_resultsV2(Data, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar, save_dir, 1)
    

end



function saveB2BButtonPushed(well_count, save_dir, well_ID, num_electrode_rows, num_electrode_cols, save_plots, saving_multiple, well_electrode_data, analyse_all_b2b, conduction_velocity)
    %%disp('save b2b')
    %%disp(save_dir)


    disp(strcat('Saving Data for', {' '}, well_ID))
    output_filename = fullfile(save_dir, strcat(well_ID, '.xlsx'));
    if exist(output_filename, 'file')
        try
            delete(output_filename);
        catch
            msgbox(strcat(output_filename, {' '}, 'is open. Please close and try saving again.'))
            %close(wait_bar)
            %set(ge_results_fig, 'visible', 'on')
            return
        end
    end

    if saving_multiple == 0
        %set(well_elec_fig, 'visible', 'off')
        wait_bar = waitbar(0, strcat('Saving Data for ', {' '}, well_ID));

    end

    if save_plots == 1
        if ~exist(fullfile(save_dir, strcat(well_ID, '_figures')), 'dir')
            mkdir(fullfile(save_dir, strcat(well_ID, '_figures')))
        else
            try
                rmdir(fullfile(save_dir, strcat(well_ID, '_figures')), 's')
                mkdir(fullfile(save_dir, strcat(well_ID, '_figures')))
            catch
                msgbox(strcat('A file in', {' '}, fullfile(save_dir, strcat(well_ID, '_figures')), {' '}, 'is open. Please close and try saving again.'))
                if saving_multiple == 0
                    close(wait_bar)
                    %set(well_elec_fig, 'visible', 'on')

                end
                return
            end
        end
        if ~exist(fullfile(save_dir, strcat(well_ID, '_images')), 'dir')
            mkdir(fullfile(save_dir, strcat(well_ID, '_images')))
        else
            try 
                rmdir(fullfile(save_dir, strcat(well_ID, '_images')), 's')
                mkdir(fullfile(save_dir, strcat(well_ID, '_images')))
            catch
                msgbox(strcat('A file in', {' '}, fullfile(save_dir, strcat(well_ID, '_images')), {' '}, 'is open. Please close and try saving again.'))
                if saving_multiple == 0
                    close(wait_bar)
                    %set(well_elec_fig, 'visible', 'on')

                end
                return

            end
        end
    end
    well_FPDs = [];
    well_slopes = [];
    well_amps = [];
    well_bps = [];

    well_sum_FPDs_beats = [];
    well_sum_slopes_beats = [];
    well_sum_amps_beats = [];
    well_sum_bps_beats = [];
    well_sum_act_times_beats = [];
    well_sum_act_volts_beats = [];
    well_sum_max_depol_times_beats = [];
    well_sum_max_depol_volts_beats = [];
    well_sum_min_depol_times_beats = [];
    well_sum_min_depol_volts_beats = [];
    well_sum_t_wave_times_beats = [];
    well_sum_t_wave_volts_beats = [];
    well_sum_cycle_lengths_beats = [];

    sheet_count = 2;
    electrode_data = well_electrode_data(well_count).electrode_data;
    elec_ids = [electrode_data(:).electrode_id];
    average_electrodes = {};
    max_act_elec_id = '';
    max_act_time = nan;
    min_act_elec_id = '';
    min_act_time = nan;
    %for elec_r = 1:num_electrode_rows
    num_partitions = 1/(num_electrode_rows*num_electrode_cols);
    partition = num_partitions;
    sum_arrhythmic_event = 0;
    count_arrhthmic_average_electrode = 0;


    %start_activation_time_array = [];
    for elec_r = num_electrode_rows:-1:1
        for elec_c = 1:num_electrode_cols
            elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
            elec_indx = contains(elec_ids, elec_id);
            elec_indx = find(elec_indx == 1);

            if isempty(elec_indx)

                continue
            end

            electrode_count = elec_indx;

            try
                start_activation_time = electrode_data(electrode_count).activation_times(2);
            catch
                start_activation_time = nan;

            end

            if isempty(min_act_elec_id)
                min_act_elec_id = electrode_data(electrode_count).electrode_id;
                min_act_elec_indx = electrode_count;
                min_act_time = start_activation_time;
            else
                if start_activation_time < min_act_time
                    min_act_time = start_activation_time;
                    min_act_elec_indx = electrode_count;
                    min_act_elec_id = electrode_data(electrode_count).electrode_id;
                end
            end

            %start_activation_time_array = [start_activation_time_array, start_activation_time];

        end
    end

    orig_min_act_electrode_activation_times = electrode_data(min_act_elec_indx).activation_times;

    for elec_r = num_electrode_rows:-1:1
        for elec_c = 1:num_electrode_cols
            if saving_multiple == 0
                waitbar(partition, wait_bar, strcat('Saving Data for ', {' '}, well_ID));
                partition = partition+num_partitions;
            end

            %elec_id = strcat(well_ID, '_', num2str(elec_r), '_', num2str(elec_c));
            elec_id = strcat(well_ID, '_', num2str(elec_c), '_', num2str(elec_r));
            elec_indx = contains(elec_ids, elec_id);
            elec_indx = find(elec_indx == 1);
            if isempty(elec_indx)

                continue
            end

            electrode_count = elec_indx;

            if isempty(electrode_data(electrode_count).beat_start_times)
                %continue;
            end


            sheet_count = sheet_count+1;

            min_act_electrode_activation_times = orig_min_act_electrode_activation_times;

            %electrode_stats_header = {electrode_data(electrode_count).electrode_id, 'Beat No.', 'Beat Start Time (s)', 'Activation Time (s)', 'Depolarisation Spike Amplitude (V)', 'Depolarisation slope', 'T-wave peak Time (s)', 'T-wave peak (V)', 'FPD (s)', 'Beat Period (s)', 'Cycle Length (s)'};

            %t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
            %t_wave_peak_times = 
            %activation_times = electrode_data(electrode_count).activation_times;
            %activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));


            try
                start_activation_time = electrode_data(electrode_count).activation_times(2);
            catch
                start_activation_time = nan;

            end

            if isempty(max_act_elec_id)
                max_act_elec_id = electrode_data(electrode_count).electrode_id;
                max_act_time = start_activation_time;
            else
                if start_activation_time > max_act_time
                    max_act_time = start_activation_time;
                    max_act_elec_id = electrode_data(electrode_count).electrode_id;
                end
            end

            %{
            if isempty(min_act_elec_id)
                min_act_elec_id = electrode_data(electrode_count).electrode_id;
                min_act_time = start_activation_time;
            else
                if start_activation_time < min_act_time
                    min_act_time = start_activation_time;
                    min_act_elec_id = electrode_data(electrode_count).electrode_id;
                end
            end
            %}


            FPDs = [electrode_data(electrode_count).t_wave_peak_times - electrode_data(electrode_count).activation_times];

            amps = [electrode_data(electrode_count).max_depol_point_array - electrode_data(electrode_count).min_depol_point_array];

            slopes = [electrode_data(electrode_count).depol_slope_array];

            bps = [electrode_data(electrode_count).beat_periods];

            well_FPDs = [well_FPDs FPDs];
            well_slopes = [well_slopes slopes];
            well_amps = [well_amps amps];
            well_bps = [well_bps bps];

            nan_FPDs = FPDs(~isnan(FPDs));
            nan_slopes = slopes(~isnan(slopes));
            nan_amps = amps(~isnan(amps));
            nan_bps = bps(~isnan(bps));

            mean_FPD = mean(nan_FPDs);
            mean_slope = mean(nan_slopes);
            mean_amp = mean(nan_amps);
            mean_bp = mean(nan_bps);





            if strcmp(analyse_all_b2b, 'all')
                if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                    FPDc_fridericia = mean_FPD/((mean_bp)^(1/3));
                    FPDc_bazzet = mean_FPD/((mean_bp)^(1/2));

                    headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'FPDc Fridericia (s)'; 'FPDc Bazzet (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};
                    mean_data = [sheet_count; mean_FPD; FPDc_fridericia; FPDc_bazzet; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                    mean_data = num2cell(mean_data);
                    mean_data = vertcat({''}, mean_data);
                    mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape}, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                    %mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity});
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                    headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Stim-spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};
                    mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                    mean_data = num2cell(mean_data);
                    mean_data = vertcat({''}, mean_data);
                    mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                    mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                    headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Stim spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};
                    mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                    mean_data = num2cell(mean_data);
                    mean_data = vertcat({''}, mean_data);
                    mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                    mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                end
            else
            % Beat to beat in a time region
                if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                    FPDc_fridericia = mean_FPD/((mean_bp)^(1/3));
                    FPDc_bazzet = mean_FPD/((mean_bp)^(1/2));
                    headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'FPDc Fridericia (s)'; 'FPDc Bazzet (s)';'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};

                    mean_data = [sheet_count; mean_FPD; FPDc_fridericia; FPDc_bazzet; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];

                    mean_data = num2cell(mean_data);
                    mean_data = vertcat({''}, mean_data);
                    mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                    mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                    headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Stim-spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};
                    mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                    mean_data = num2cell(mean_data);
                    mean_data = vertcat({''}, mean_data);
                    mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                    mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                    headings = {strcat(electrode_data(electrode_count).electrode_id, ':Mean electrode statistics'); 'Sheet'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Time Region Start (s)'; 'Time Region End (s)'; 'Beat Detection Threshold Input (V)'; 'Mininum Beat Period Input (s)'; 'Mininum Beat Period Input (s)'; 'Stim spike hold-off (s)'; 'Post-spike hold-off (s)'; 'T-wave Duration Input (s)'; 'T-wave offset Input (s)'; 'T-wave shape'; 'Filter Intensity'; 'Num Arrhytmic Beats'};
                    mean_data = [sheet_count; mean_FPD; mean_slope; mean_amp; mean_bp; electrode_data(electrode_count).time_region_start; electrode_data(electrode_count).time_region_end; electrode_data(electrode_count).bdt; electrode_data(electrode_count).min_bp; electrode_data(electrode_count).max_bp; electrode_data(electrode_count).stim_spike_hold_off; electrode_data(electrode_count).post_spike_hold_off; electrode_data(electrode_count).t_wave_duration; electrode_data(electrode_count).t_wave_offset];
                    mean_data = num2cell(mean_data);
                    mean_data = vertcat({''}, mean_data);
                    mean_data = vertcat(mean_data, {electrode_data(electrode_count).t_wave_shape});
                    mean_data = vertcat(mean_data, {electrode_data(electrode_count).filter_intensity}, {electrode_data(electrode_count).num_arrhythmic});
                end

            end 

            sum_arrhythmic_event = sum_arrhythmic_event+electrode_data(electrode_count).num_arrhythmic;
            count_arrhthmic_average_electrode = count_arrhthmic_average_electrode+1;

            %cell%disp(mean_data);

            elec_stats = horzcat(headings, mean_data);

            if isempty(average_electrodes)
                average_electrodes = elec_stats;

            else

                average_electrodes = vertcat(average_electrodes, elec_stats);
            end


            beat_num_array = electrode_data(electrode_count).beat_num_array;
            [br, bc] = size(beat_num_array);
            beat_num_array = reshape(beat_num_array, [bc br]);

            beat_start_times = electrode_data(electrode_count).beat_start_times;
            [br, bc] = size(beat_start_times);
            beat_start_times = reshape(beat_start_times, [bc br]);

            beat_start_volts = electrode_data(electrode_count).beat_start_volts;
            [br, bc] = size(beat_start_volts);
            beat_start_volts = reshape(beat_start_volts, [bc br]);

            activation_times = electrode_data(electrode_count).activation_times;
            min_act = min(activation_times);
            orig_activation_times = activation_times;
            [br, bc] = size(activation_times);
            activation_times = reshape(activation_times, [bc br]);

            activation_points = electrode_data(electrode_count).activation_point_array;
            [br, bc] = size(activation_points);
            activation_points = reshape(activation_points, [bc br]);


            max_depol_time_array = electrode_data(electrode_count).max_depol_time_array;
            [br, bc] = size(max_depol_time_array);
            max_depol_time_array = reshape(max_depol_time_array, [bc br]);

            min_depol_time_array = electrode_data(electrode_count).min_depol_time_array;
            [br, bc] = size(min_depol_time_array);
            min_depol_time_array = reshape(min_depol_time_array, [bc br]);

            max_depol_point_array = electrode_data(electrode_count).max_depol_point_array;
            [br, bc] = size(max_depol_point_array);
            max_depol_point_array = reshape(max_depol_point_array, [bc br]);


            min_depol_point_array = electrode_data(electrode_count).min_depol_point_array;
            [br, bc] = size(min_depol_point_array);
            min_depol_point_array = reshape(min_depol_point_array, [bc br]);


            [br, bc] = size(amps);
            amps = reshape(amps, [bc br]);

            [br, bc] = size(slopes);
            slopes = reshape(slopes, [bc br]);


            [br, bc] = size(FPDs);
            FPDs = reshape(FPDs, [bc br]);


            t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
            [br, bc] = size(t_wave_peak_times);
            t_wave_peak_times = reshape(t_wave_peak_times, [bc br]);

            t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
            [br, bc] = size(t_wave_peak_array);
            t_wave_peak_array = reshape(t_wave_peak_array, [bc br]);

            beat_periods = electrode_data(electrode_count).beat_periods;
            [br, bc] = size(beat_periods);
            beat_periods = reshape(beat_periods, [bc br]);


            cycle_length_array = electrode_data(electrode_count).cycle_length_array;
            [br, bc] = size(cycle_length_array);
            cycle_length_array = reshape(cycle_length_array, [bc br]);

            act_sub_min = orig_activation_times - min_act;
            [br, bc] = size(act_sub_min);
            act_sub_min = reshape(act_sub_min, [bc br]);

            wavelet_families = electrode_data(electrode_count).t_wave_wavelet_array;
            [br, bc] = size(wavelet_families);
            wavelet_families = reshape(wavelet_families, [bc br]);


            polynomial_degrees = electrode_data(electrode_count).t_wave_polynomial_degree_array;
            [br, bc] = size(polynomial_degrees);
            polynomial_degrees = reshape(polynomial_degrees, [bc br]);

            warning_array = electrode_data(electrode_count).warning_array;
            [br, bc] = size(warning_array);
            warning_array = reshape(warning_array, [bc br]);

            [ar, ac] = size(activation_times);
            [mr, mc] = size(min_act_electrode_activation_times);
            sub_activation_times = activation_times;
            if ar == 1
                if mr == 1
                    if ac ~= mc
                        if ac > mc
                            add_extra = ac-mc;
                            add_extras_array = zeros(1, add_extra);

                            min_act_electrode_activation_times = [min_act_electrode_activation_times add_extras_array];



                        else
                            add_extra = mc-ac;
                            add_extras_array = zeros(1, add_extra);

                            sub_activation_times = [sub_activation_times add_extras_array];

                        end
                    end
                else
                    if ac ~= mr
                        if ac > mr
                            add_extra = ac-mr;
                            add_extras_array = zeros(add_extra, 1);

                            min_act_electrode_activation_times = [min_act_electrode_activation_times; add_extras_array];

                        else
                            add_extra = mr-ac;
                            add_extras_array = zeros(1, add_extra);

                            sub_activation_times = [sub_activation_times add_extras_array];

                        end
                    end

                end
            else
                if mr == 1
                    if ar ~= mc
                        if ar > mc
                            add_extra = ar-mc;
                            add_extras_array = zeros(1, add_extra);

                            min_act_electrode_activation_times = [min_act_electrode_activation_times add_extras_array];
                        else
                            add_extra = mc-ar;
                            add_extras_array = zeros(add_extra, 1);

                            sub_activation_times = [sub_activation_times; add_extras_array];

                        end
                    end
                else
                    if ar ~= mr
                        if ar > mr
                            add_extra = ar-mr;
                            add_extras_array = zeros(add_extra, 1);

                            min_act_electrode_activation_times = [min_act_electrode_activation_times; add_extras_array];
                        else
                            add_extra = mr-ar;
                            add_extras_array = zeros(add_extra, 1);

                            sub_activation_times = [sub_activation_times; add_extras_array];

                        end
                    end

                end

            end

            [sr, sc] = size(sub_activation_times);
            [mr, mc] = size(min_act_electrode_activation_times);

            if mr == 1
                min_act_electrode_activation_times = reshape(min_act_electrode_activation_times, [mc mr]);
            end

            activation_times_subtract_min_act_electrode_act_times = sub_activation_times - min_act_electrode_activation_times;
            [br, bc] = size(activation_times_subtract_min_act_electrode_act_times);



            if br == 1
                activation_times_subtract_min_act_electrode_act_times = reshape(activation_times_subtract_min_act_electrode_act_times, [bc br]);
            end


            if strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                paced_indxs = ismembertol(beat_start_times, electrode_data(electrode_count).Stims, .00001);
                %paced_indxs = ismembertol(electrode_data(electrode_count).Stims, .03);
                %paced_indxs= find(islamost((beat_start_times, electrode_data(electrode_count).Stims, .03) == 1)
                paced_indxs = find(paced_indxs == 1);



                paced_ectopic_labels = cell(length(beat_start_times), 1);
                paced_ectopic_labels(:) = {"ectopic"};
                paced_ectopic_labels(paced_indxs) = {"paced"};


                electrode_stats_table = table('Size', [length(beat_num_array) 22], 'VariableTypes',["string",  "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double", "double", "double", "double", "double", "double", "double", "string", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Beat Start Volts (V)", "Activation Time (s)", "Activation Time Volts (V)", "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "Paced/Ectopic", "T-wave Denoising Wavelet Family", "T-wave Polynomial Degree", "Warnings"]));

                if electrode_data(electrode_count).rejected == 0

                    if ~isempty(beat_num_array)
                        electrode_stats_table(:, 2) = num2cell(beat_num_array);

                        electrode_stats_table(:, 3) = num2cell(beat_start_times);

                        electrode_stats_table(:, 4) = num2cell(beat_start_volts);

                        electrode_stats_table(:, 5) = num2cell(activation_times);

                        electrode_stats_table(:, 6) = num2cell(activation_points);

                        %electrode_stats_table(:, 7) = num2cell(activation_times_subtract_min_act_electrode_act_times);

                        electrode_stats_table(:, 7) = num2cell(min_depol_time_array);

                        electrode_stats_table(:, 8) = num2cell(min_depol_point_array);

                        electrode_stats_table(:, 9) = num2cell(max_depol_time_array);

                        electrode_stats_table(:, 10) = num2cell(max_depol_point_array);

                        electrode_stats_table(:, 11) = num2cell(amps);

                        electrode_stats_table(:, 12) = num2cell(slopes);

                        electrode_stats_table(:, 13) = num2cell(t_wave_peak_times);

                        electrode_stats_table(:, 14) = num2cell(t_wave_peak_array);

                        electrode_stats_table(:, 15) = num2cell(FPDs);

                        electrode_stats_table(:, 16) = num2cell(beat_periods);

                        electrode_stats_table(:, 17) = num2cell(cycle_length_array);

                        electrode_stats_table(:, 18) = num2cell(act_sub_min);

                        electrode_stats_table(:, 19) = paced_ectopic_labels;

                        electrode_stats_table(:, 20) = wavelet_families;

                        electrode_stats_table(:, 21) = num2cell(polynomial_degrees);

                        electrode_stats_table(:, 22) = warning_array;
                    end
                else
                    %{
                    electrode_stats_table(:, 2) = {};

                    electrode_stats_table(:, 3) = {};

                    electrode_stats_table(:, 4) = {};

                    electrode_stats_table(:, 5) = {};

                    electrode_stats_table(:, 6) = {};

                    electrode_stats_table(:, 7) = {};

                    electrode_stats_table(:, 8) = {};

                    electrode_stats_table(:, 9) = {};

                    electrode_stats_table(:, 10) = {};

                    electrode_stats_table(:, 11) = {};

                    electrode_stats_table(:, 12) = {};

                    electrode_stats_table(:, 13) = {};

                    electrode_stats_table(:, 14) = {};

                    electrode_stats_table(:, 15) = {};

                    electrode_stats_table(:, 16) = {};

                    electrode_stats_table(:, 17) = {};

                    electrode_stats_table(:, 18) = {};

                    electrode_stats_table(:, 19) = {};

                    electrode_stats_table(:, 20) = {};

                    electrode_stats_table(:, 21) = {};

                    electrode_stats_table(:, 22) = {};
                    %}
                end


            elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                if electrode_data(electrode_count).rejected == 0
                    electrode_stats_table = table('Size', [length(beat_num_array) 23], 'VariableTypes',["string", "double", "double",  "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double","double","double","double","double","double", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Beat Start Volts (V)", "Activation Time (s)", "Activation Time Volts (V)", "Activation Time-Stimulus Time (s)","Activation Times-min Elec. Activation Times (s)", "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "T-wave Denoising Wavelet Family", "T-wave Polynomial Degree", "Warnings"]));

                    if ~isempty(beat_num_array)
                        sub_Stims = electrode_data(electrode_count).Stims;
                        [br, bc] = size(sub_Stims);
                        sub_Stims = reshape(sub_Stims, [bc br]);

                        activation_time_stim_offset_array = activation_times- sub_Stims;

                        electrode_stats_table(:, 2) = num2cell(beat_num_array);

                        electrode_stats_table(:, 3) = num2cell(beat_start_times);

                        electrode_stats_table(:, 4) = num2cell(beat_start_volts);

                        electrode_stats_table(:, 5) = num2cell(activation_times);

                        electrode_stats_table(:, 6) = num2cell(activation_points);

                        electrode_stats_table(:, 7) = num2cell(activation_time_stim_offset_array);

                        electrode_stats_table(:, 8) = num2cell(activation_times_subtract_min_act_electrode_act_times);

                        electrode_stats_table(:, 9) = num2cell(min_depol_time_array);

                        electrode_stats_table(:, 10) = num2cell(min_depol_point_array);

                        electrode_stats_table(:, 11) = num2cell(max_depol_time_array);

                        electrode_stats_table(:, 12) = num2cell(max_depol_point_array);

                        electrode_stats_table(:, 13) = num2cell(amps);

                        electrode_stats_table(:, 14) = num2cell(slopes);

                        electrode_stats_table(:, 15) = num2cell(t_wave_peak_times);

                        electrode_stats_table(:, 16) = num2cell(t_wave_peak_array);

                        electrode_stats_table(:, 17) = num2cell(FPDs);

                        electrode_stats_table(:, 18) = num2cell(beat_periods);

                        electrode_stats_table(:, 19) = num2cell(cycle_length_array);

                        electrode_stats_table(:, 20) = num2cell(act_sub_min);

                        electrode_stats_table(:, 21) = wavelet_families;

                        electrode_stats_table(:, 22) = num2cell(polynomial_degrees);

                        electrode_stats_table(:, 23) = warning_array;
                    end
                else
                    electrode_stats_table = table('Size', [0 23], 'VariableTypes',["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double","double","double","double","double","double", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Beat Start Volts (V)", "Activation Time (s)", "Activation Time Volts (V)", "Activation Time-Stimulus Time (s)", "Activation Times-min Elec. Activation Times (s)", "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "T-wave Denoising Wavelet Family", "T-wave Polynomial Degree", "Warnings"]));


                end


            else

            % Spontaneous


                %{
                if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                    Stim_volts = electrode_data(electrode_count).Stim_volts(1:end-1);
                    %[er, ec] = size(Stim_volts)
                    %Stim_volts = reshape(Stim_volts, [ec, er]);

                    Stim_times = electrode_data(electrode_count).Stims(1:end-1);
                    [er, ec] = size(Stim_times);
                    Stim_times = reshape(Stim_times, [ec, er]);

                    electrode_stats_table(:, 3) = num2cell(Stim_times);
                    electrode_stats_table(:, 4) = num2cell(Stim_volts);
                else

                    electrode_stats_table(:, 3) = num2cell(beat_start_times);
                    electrode_stats_table(:, 4) = num2cell(beat_start_volts);
                end
                %}

                if electrode_data(electrode_count).rejected == 0
                    electrode_stats_table = table('Size', [length(beat_num_array) 22], 'VariableTypes',["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double","double","double","double","double","double", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Beat Start Volts (V)", "Activation Time (s)", "Activation Time Volts (V)", "Activation Times-min Elec. Activation Times (s)", "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "T-wave Denoising Wavelet Family", "T-wave Polynomial Degree", "Warnings"]));

                    if ~isempty(beat_num_array)
                        electrode_stats_table(:, 2) = num2cell(beat_num_array);

                        electrode_stats_table(:, 3) = num2cell(beat_start_times);

                        electrode_stats_table(:, 4) = num2cell(beat_start_volts);

                        electrode_stats_table(:, 5) = num2cell(activation_times);

                        electrode_stats_table(:, 6) = num2cell(activation_points);

                        electrode_stats_table(:, 7) = num2cell(activation_times_subtract_min_act_electrode_act_times);

                        electrode_stats_table(:, 8) = num2cell(min_depol_time_array);

                        electrode_stats_table(:, 9) = num2cell(min_depol_point_array);

                        electrode_stats_table(:, 10) = num2cell(max_depol_time_array);

                        electrode_stats_table(:, 11) = num2cell(max_depol_point_array);

                        electrode_stats_table(:, 12) = num2cell(amps);

                        electrode_stats_table(:, 13) = num2cell(slopes);

                        electrode_stats_table(:, 14) = num2cell(t_wave_peak_times);

                        electrode_stats_table(:, 15) = num2cell(t_wave_peak_array);

                        electrode_stats_table(:, 16) = num2cell(FPDs);

                        electrode_stats_table(:, 17) = num2cell(beat_periods);

                        electrode_stats_table(:, 18) = num2cell(cycle_length_array);

                        electrode_stats_table(:, 19) = num2cell(act_sub_min);

                        electrode_stats_table(:, 20) = wavelet_families;

                        electrode_stats_table(:, 21) = num2cell(polynomial_degrees);

                        electrode_stats_table(:, 22) = warning_array;
                    end
                else
                    electrode_stats_table = table('Size', [0 22], 'VariableTypes',["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double","double","double","double","double","double","double", "string", "double", "string"], 'VariableNames', cellstr([electrode_data(electrode_count).electrode_id, "Beat No.", "Beat Start Time (s)", "Beat Start Volts (V)", "Activation Time (s)", "Activation Time Volts (V)", "Activation Times-min Elec. Activation Times (s)", "Min. Depol Time (s)", "Min. Depol Point (V)", "Max. Depol Time (s)", "Max. Depol Point (V)", "Depolarisation Spike Amplitude (V)", "Depolarisation slope (dv/dt)", "T-wave peak Time (s)", "T-wave peak (V)", "FPD (s)", "Beat Period (s)", "Cycle Length (s)", "Activation Time - minimum Activation Time (s)", "T-wave Denoising Wavelet Family", "T-wave Polynomial Degree", "Warnings"]));


                end

            end


            try
                if sheet_count ~= 3
                    fileattrib(output_filename, '-h +w');
                end

                %writecell(electrode_stats, output_filename, 'Sheet', sheet_count);
                writetable(electrode_stats_table, output_filename, 'Sheet', sheet_count);
                fileattrib(output_filename, '+h +w');
            catch
                msgbox(strcat(output_filename, {' '}, 'is open and cannot be written to. Please close it and try saving again.'));
                if saving_multiple == 0
                    close(wait_bar)

                    set(well_elec_fig, 'visible', 'on')


                end
                return
            end

            %{
            if save_plots == 1
                fig = figure();
                set(fig, 'visible', 'off');
                hold('on')
                plot(electrode_data(electrode_count).time, electrode_data(electrode_count).data);
                plot(electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data);
                t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                plot(t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
                plot(electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
                plot(electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);



                if strcmp(electrode_data(electrode_count).spon_paced, 'paced') 


                    plot(electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);
                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                    plot(electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
                    plot(electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);

                else

                    plot(electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);

                end
                %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');

                plot(electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'k.', 'MarkerSize', 20);

                if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                    legend('signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
                    legend('signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'stimulus point', 'activation point', 'location', 'northeastoutside')

                else
                    legend('signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point', 'location', 'northeastoutside')

                end
                title({electrode_data(electrode_count).electrode_id},  'Interpreter', 'none')

                savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  electrode_data(electrode_count).electrode_id));
                saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  electrode_data(electrode_count).electrode_id), 'png')
                hold('off')
                close(fig)

                fig = figure();
                set(fig, 'Visible', 'off')
                beat_num_array = electrode_data(electrode_count).beat_num_array(2:end);
                cycle_length_array = electrode_data(electrode_count).cycle_length_array(2:end);
                plot(beat_num_array, cycle_length_array, 'b.', 'MarkerSize', 20);

                if  ~isempty(electrode_data(electrode_count).arrhythmia_indx)
                    hold('on')
                    plot(beat_num_array(electrode_data(electrode_count).arrhythmia_indx), cycle_length_array(electrode_data(electrode_count).arrhythmia_indx), 'r.', 'MarkerSize', 20);
                    legend('Stable beats', 'Arrhythmic beats', 'location', 'northeastoutside');
                end

                xlabel('Beat Number');
                ylabel('Cycle Length (s)');
                ylim([0 max(cycle_length_array)])
                title(strcat('Cycle Length per Beat', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_beat')));
                saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_beat')), 'png')
                hold('off')
                close(fig)

                fig = figure();
                set(fig, 'Visible', 'off')
                plot(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).beat_periods, 'bo');
                xlabel('Beat Number');
                ylabel('Beat Period (s)');
                ylim([0 max(electrode_data(electrode_count).beat_periods)])
                title(strcat('Beat Period per Beat', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_beat_period_per_beat')));
                saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_beat_period_per_beat')), 'png')
                hold('off')
                close(fig)

                fig = figure();
                set(fig, 'Visible', 'off')
                plot(electrode_data(electrode_count).cycle_length_array(2:end-1), electrode_data(electrode_count).cycle_length_array(3:end), 'b.', 'MarkerSize', 20);
                xlabel('Cycle Length Previous Beat (s)');
                ylabel('Cycle Length (s)');
                title(strcat('Cycle Length vs Previous Beat Cycle Length', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_previous_cycle_length')));
                saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, '_cycle_length_per_previous_cycle_length')), 'png')
                hold('off')
                close(fig)

                t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
                t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
                t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
                t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
                activation_times = electrode_data(electrode_count).activation_times;
                activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                fpd_beats = electrode_data(electrode_count).beat_num_array(~isnan(electrode_data(electrode_count).t_wave_peak_times));
                elec_FPDs = [t_wave_peak_times - activation_times];
                fig = figure();
                set(fig, 'Visible', 'off')
                plot(fpd_beats, elec_FPDs, 'bo');
                xlabel('Beat Number');
                ylabel('FPD (s)');
                ylim([0 max(elec_FPDs)])
                title(strcat('FPD per Beat Num', {' '}, electrode_data(electrode_count).electrode_id),  'Interpreter', 'none');
                savefig(fullfile(save_dir, strcat(well_ID, '_figures'),  strcat(electrode_data(electrode_count).electrode_id, '_FPD_per_beat_number')));
                saveas(fig, fullfile(save_dir, strcat(well_ID, '_images'),  strcat(electrode_data(electrode_count).electrode_id, 'FPD_per_beat_number')), 'png')
                hold('off')
                close(fig)
            end
            %}

            if isempty(well_sum_FPDs_beats)
                nan_zero_FPDs = FPDs;
                nan_zero_FPDs(isnan(nan_zero_FPDs)) = 0;
                count_FPD_electrodes = ~isnan(nan_zero_FPDs);

                nan_zero_slopes = slopes;
                nan_zero_slopes(isnan(nan_zero_slopes)) = 0;
                count_slopes_electrodes = ~isnan(nan_zero_slopes);

                nan_zero_amps = amps;
                nan_zero_amps(isnan(nan_zero_amps)) = 0;
                count_amps_electrodes = ~isnan(nan_zero_amps);

                nan_zero_bps = beat_periods;
                nan_zero_bps(isnan(nan_zero_bps)) = 0;
                count_bps_electrodes = ~isnan(nan_zero_bps);

                nan_zero_act_times = activation_times;
                nan_zero_act_times(isnan(nan_zero_act_times)) = 0;
                count_act_times_electrodes = ~isnan(nan_zero_act_times);

                nan_zero_act_volts = activation_points;
                nan_zero_act_volts(isnan(nan_zero_act_volts)) = 0;
                count_act_volts_electrodes = ~isnan(nan_zero_act_volts);

                nan_zero_max_depol_times = max_depol_time_array;
                nan_zero_max_depol_times(isnan(nan_zero_max_depol_times)) = 0;
                count_max_depol_times_electrodes = ~isnan(nan_zero_max_depol_times);

                nan_zero_max_depol_volts = max_depol_point_array;
                nan_zero_max_depol_volts(isnan(nan_zero_max_depol_volts)) = 0;
                count_max_depol_volts_electrodes = ~isnan(nan_zero_max_depol_volts);

                nan_zero_min_depol_times = min_depol_time_array;
                nan_zero_min_depol_times(isnan(nan_zero_min_depol_times)) = 0;
                count_min_depol_times_electrodes = ~isnan(nan_zero_min_depol_times);

                nan_zero_min_depol_volts = min_depol_point_array;
                nan_zero_min_depol_volts(isnan(nan_zero_min_depol_volts)) = 0;
                count_min_depol_volts_electrodes = ~isnan(nan_zero_min_depol_volts);

                nan_zero_t_wave_times = t_wave_peak_times;
                nan_zero_t_wave_times(isnan(nan_zero_t_wave_times)) = 0;
                count_t_wave_times_electrodes = ~isnan(nan_zero_t_wave_times);

                nan_zero_t_wave_volts = t_wave_peak_array;
                nan_zero_t_wave_volts(isnan(nan_zero_t_wave_volts)) = 0;
                count_t_wave_volts_electrodes = ~isnan(nan_zero_t_wave_volts);

                nan_zero_cycle_lengths = cycle_length_array;
                nan_zero_cycle_lengths(isnan(nan_zero_cycle_lengths)) = 0;
                count_cycle_lengths_electrodes = ~isnan(nan_zero_cycle_lengths);


                well_sum_FPDs_beats = nan_zero_FPDs;
                well_sum_slopes_beats = nan_zero_slopes;
                well_sum_amps_beats = nan_zero_amps;
                well_sum_bps_beats = nan_zero_bps;

                well_sum_act_times_beats = nan_zero_act_times;
                well_sum_act_volts_beats = nan_zero_act_volts;
                well_sum_max_depol_times_beats = nan_zero_max_depol_times;
                well_sum_max_depol_volts_beats = nan_zero_max_depol_volts;
                well_sum_min_depol_times_beats = nan_zero_min_depol_times;
                well_sum_min_depol_volts_beats = nan_zero_min_depol_volts;
                well_sum_t_wave_times_beats = nan_zero_t_wave_times;
                well_sum_t_wave_volts_beats = nan_zero_t_wave_volts;
                well_sum_cycle_lengths_beats = nan_zero_cycle_lengths;

            else
                % Set all nan values to zero
                nan_zero_FPDs = FPDs;
                nan_zero_FPDs(isnan(nan_zero_FPDs)) = 0;


                nan_zero_slopes = slopes;
                nan_zero_slopes(isnan(nan_zero_slopes)) = 0;


                nan_zero_amps = amps;
                nan_zero_amps(isnan(nan_zero_amps)) = 0;


                nan_zero_bps = beat_periods;
                nan_zero_bps(isnan(nan_zero_bps)) = 0;


                nan_zero_act_times = activation_times;
                nan_zero_act_times(isnan(nan_zero_act_times)) = 0;


                nan_zero_act_volts = activation_points;
                nan_zero_act_volts(isnan(nan_zero_act_volts)) = 0;


                nan_zero_max_depol_times = max_depol_time_array;
                nan_zero_max_depol_times(isnan(nan_zero_max_depol_times)) = 0;


                nan_zero_max_depol_volts = max_depol_point_array;
                nan_zero_max_depol_volts(isnan(nan_zero_max_depol_volts)) = 0;


                nan_zero_min_depol_times = min_depol_time_array;
                nan_zero_min_depol_times(isnan(nan_zero_min_depol_times)) = 0;


                nan_zero_min_depol_volts = min_depol_point_array;
                nan_zero_min_depol_volts(isnan(nan_zero_min_depol_volts)) = 0;


                nan_zero_t_wave_times = t_wave_peak_times;
                nan_zero_t_wave_times(isnan(nan_zero_t_wave_times)) = 0;


                nan_zero_t_wave_volts = t_wave_peak_array;
                nan_zero_t_wave_volts(isnan(nan_zero_t_wave_volts)) = 0;


                nan_zero_cycle_lengths = cycle_length_array;
                nan_zero_cycle_lengths(isnan(nan_zero_cycle_lengths)) = 0;

                add_FPD_electrodes = ~isnan(nan_zero_FPDs);
                add_slopes_electrodes = ~isnan(nan_zero_slopes);
                add_amps_electrodes = ~isnan(nan_zero_amps);
                add_bps_electrodes = ~isnan(nan_zero_bps);
                add_act_times_electrodes = ~isnan(nan_zero_act_times);
                add_act_volts_electrodes = ~isnan(nan_zero_act_volts);
                add_max_depol_times_electrodes = ~isnan(nan_zero_max_depol_times);
                add_max_depol_volts_electrodes = ~isnan(nan_zero_max_depol_volts);
                add_min_depol_times_electrodes = ~isnan(nan_zero_min_depol_times);
                add_min_depol_volts_electrodes = ~isnan(nan_zero_min_depol_volts);
                add_t_wave_times_electrodes = ~isnan(nan_zero_t_wave_times);
                add_t_wave_volts_electrodes = ~isnan(nan_zero_t_wave_volts);
                add_cycle_lengths_electrodes = ~isnan(nan_zero_cycle_lengths);

                %Concatenate zero to arrays if some electrodes have additional beats
                [er, ec] = size(nan_zero_FPDs);
                [sr, sc] = size(well_sum_FPDs_beats);
                if er ~= sr
                    if er > sr
                    %Electrode has more beats, need to add zeros to the end of the summation and counts arrays
                        add_extra = er-sr;
                        add_extras_array = zeros(add_extra, 1);

                        well_sum_FPDs_beats = [well_sum_FPDs_beats; add_extras_array];
                        well_sum_slopes_beats = [well_sum_slopes_beats; add_extras_array];
                        well_sum_amps_beats = [well_sum_amps_beats; add_extras_array];
                        well_sum_bps_beats = [well_sum_bps_beats; add_extras_array];
                        well_sum_act_times_beats = [well_sum_act_times_beats; add_extras_array];
                        well_sum_act_volts_beats = [well_sum_act_volts_beats; add_extras_array];
                        well_sum_max_depol_times_beats = [well_sum_max_depol_times_beats; add_extras_array];
                        well_sum_max_depol_volts_beats = [well_sum_max_depol_volts_beats; add_extras_array];
                        well_sum_min_depol_times_beats = [well_sum_min_depol_times_beats; add_extras_array];
                        well_sum_min_depol_volts_beats = [well_sum_min_depol_volts_beats; add_extras_array];
                        well_sum_t_wave_times_beats = [well_sum_t_wave_times_beats; add_extras_array];
                        well_sum_t_wave_volts_beats = [well_sum_t_wave_volts_beats; add_extras_array];
                        well_sum_cycle_lengths_beats = [well_sum_cycle_lengths_beats; add_extras_array];

                        count_FPD_electrodes = [count_FPD_electrodes; add_extras_array];
                        count_slopes_electrodes = [count_slopes_electrodes; add_extras_array];
                        count_amps_electrodes = [count_amps_electrodes; add_extras_array];
                        count_bps_electrodes = [count_bps_electrodes; add_extras_array];
                        count_act_times_electrodes = [count_act_times_electrodes; add_extras_array];
                        count_act_volts_electrodes = [count_act_volts_electrodes; add_extras_array];
                        count_max_depol_times_electrodes = [count_max_depol_times_electrodes; add_extras_array];
                        count_max_depol_volts_electrodes = [count_max_depol_volts_electrodes; add_extras_array];
                        count_min_depol_times_electrodes = [count_min_depol_times_electrodes; add_extras_array];
                        count_min_depol_volts_electrodes = [count_min_depol_volts_electrodes; add_extras_array];
                        count_t_wave_times_electrodes = [count_t_wave_times_electrodes; add_extras_array];
                        count_t_wave_volts_electrodes = [count_t_wave_volts_electrodes; add_extras_array];
                        count_cycle_lengths_electrodes = [count_cycle_lengths_electrodes; add_extras_array];
                    else
                    % Current electrode has less beats than previously saved ones. Need to add zeros to the add arrays and nan_zero_arrays
                        add_extra = sr-er;
                        add_extras_array = zeros(add_extra, 1);

                        nan_zero_FPDs = [nan_zero_FPDs; add_extras_array];
                        nan_zero_slopes = [nan_zero_slopes; add_extras_array];
                        nan_zero_amps = [nan_zero_amps; add_extras_array];
                        nan_zero_bps = [nan_zero_bps; add_extras_array];
                        nan_zero_act_times = [nan_zero_act_times; add_extras_array];
                        nan_zero_act_volts = [nan_zero_act_volts; add_extras_array];
                        nan_zero_max_depol_times = [nan_zero_max_depol_times; add_extras_array];
                        nan_zero_max_depol_volts = [nan_zero_max_depol_volts; add_extras_array];
                        nan_zero_min_depol_times = [nan_zero_min_depol_times; add_extras_array];
                        nan_zero_min_depol_volts = [nan_zero_min_depol_volts; add_extras_array];
                        nan_zero_t_wave_times = [nan_zero_t_wave_times; add_extras_array];
                        nan_zero_t_wave_volts = [nan_zero_t_wave_volts; add_extras_array];
                        nan_zero_cycle_lengths = [nan_zero_cycle_lengths; add_extras_array];

                        add_FPD_electrodes = [add_FPD_electrodes; add_extras_array];
                        add_slopes_electrodes = [add_slopes_electrodes; add_extras_array];
                        add_amps_electrodes = [add_amps_electrodes; add_extras_array];
                        add_bps_electrodes = [add_bps_electrodes; add_extras_array];
                        add_act_times_electrodes = [add_act_times_electrodes; add_extras_array];
                        add_act_volts_electrodes = [add_act_volts_electrodes; add_extras_array];
                        add_max_depol_times_electrodes = [add_max_depol_times_electrodes; add_extras_array];
                        add_max_depol_volts_electrodes = [add_max_depol_volts_electrodes; add_extras_array];
                        add_min_depol_times_electrodes = [add_min_depol_times_electrodes; add_extras_array];
                        add_min_depol_volts_electrodes = [add_min_depol_volts_electrodes; add_extras_array];
                        add_t_wave_times_electrodes = [add_t_wave_times_electrodes; add_extras_array];
                        add_t_wave_volts_electrodes = [add_t_wave_volts_electrodes; add_extras_array];
                        add_cycle_lengths_electrodes = [add_cycle_lengths_electrodes; add_extras_array];

                    end

                end


                well_sum_FPDs_beats = well_sum_FPDs_beats+nan_zero_FPDs;
                well_sum_slopes_beats = well_sum_slopes_beats+nan_zero_slopes;
                well_sum_amps_beats = well_sum_amps_beats+nan_zero_amps;
                well_sum_bps_beats = well_sum_bps_beats+nan_zero_bps;
                well_sum_act_times_beats = well_sum_act_times_beats+nan_zero_act_times;
                well_sum_act_volts_beats = well_sum_act_volts_beats+nan_zero_act_volts;
                well_sum_max_depol_times_beats = well_sum_max_depol_times_beats+nan_zero_max_depol_times;
                well_sum_max_depol_volts_beats = well_sum_max_depol_volts_beats+nan_zero_max_depol_volts;
                well_sum_min_depol_times_beats = well_sum_min_depol_times_beats+nan_zero_min_depol_times;
                well_sum_min_depol_volts_beats = well_sum_min_depol_volts_beats+nan_zero_min_depol_volts;
                well_sum_t_wave_times_beats = well_sum_t_wave_times_beats+nan_zero_t_wave_times;
                well_sum_t_wave_volts_beats = well_sum_t_wave_volts_beats+nan_zero_t_wave_volts;
                well_sum_cycle_lengths_beats = well_sum_cycle_lengths_beats+nan_zero_cycle_lengths;

                count_FPD_electrodes = count_FPD_electrodes+add_FPD_electrodes;
                count_slopes_electrodes = count_slopes_electrodes+add_slopes_electrodes;
                count_amps_electrodes = count_amps_electrodes+add_amps_electrodes;
                count_bps_electrodes = count_bps_electrodes+add_bps_electrodes;
                count_act_times_electrodes = count_act_times_electrodes+add_act_times_electrodes;
                count_act_volts_electrodes = count_act_volts_electrodes+add_act_volts_electrodes;
                count_max_depol_times_electrodes = count_max_depol_times_electrodes+add_max_depol_times_electrodes;
                count_max_depol_volts_electrodes = count_max_depol_volts_electrodes+add_max_depol_volts_electrodes;
                count_min_depol_times_electrodes = count_min_depol_times_electrodes+add_min_depol_times_electrodes;
                count_min_depol_volts_electrodes = count_min_depol_volts_electrodes+add_min_depol_volts_electrodes;
                count_t_wave_times_electrodes = count_t_wave_times_electrodes+add_t_wave_times_electrodes;
                count_t_wave_volts_electrodes = count_t_wave_volts_electrodes+add_t_wave_volts_electrodes;
                count_cycle_lengths_electrodes = count_cycle_lengths_electrodes+add_cycle_lengths_electrodes;
            end
        end
    end


    well_mean_FPDs_beats = well_sum_FPDs_beats./count_FPD_electrodes;
    well_mean_slopes_beats = well_sum_slopes_beats./count_slopes_electrodes;
    well_mean_amps_beats = well_sum_amps_beats./count_amps_electrodes;
    well_mean_bps_beats = well_sum_bps_beats./count_bps_electrodes;
    well_mean_act_times_beats = well_sum_act_times_beats./count_act_times_electrodes;
    well_mean_act_volts_beats = well_sum_act_volts_beats./count_act_volts_electrodes;
    well_mean_max_depol_times_beats = well_sum_max_depol_times_beats./count_max_depol_times_electrodes;
    well_mean_max_depol_volts_beats = well_sum_max_depol_volts_beats./count_max_depol_volts_electrodes;
    well_mean_min_depol_times_beats = well_sum_min_depol_times_beats./count_min_depol_times_electrodes;
    well_mean_min_depol_volts_beats = well_sum_min_depol_volts_beats./count_min_depol_volts_electrodes;
    well_mean_t_wave_times_beats = well_sum_t_wave_times_beats./count_t_wave_times_electrodes;
    well_mean_t_wave_volts_beats = well_sum_t_wave_volts_beats./count_t_wave_volts_electrodes;
    well_mean_cycle_lengths_beats = well_sum_cycle_lengths_beats./count_cycle_lengths_electrodes;



    well_stats_table = table('Size', [length(well_mean_act_times_beats) 14], 'VariableTypes',["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double","double","double"], 'VariableNames', cellstr(["Average stats for each beat across well",  "Ave Activation Time (s)", "Ave Activation Time Volts (V)", "Ave Min. Depol Time (s)", "Ave Min. Depol Point (V)", "Ave Max. Depol Time (s)", "Ave Max. Depol Point (V)", "Ave Depolarisation Spike Amplitude (V)", "Ave Depolarisation slope (dv/dt)", "Ave T-wave peak Time (s)", "Ave T-wave peak (V)", "Ave FPD (s)", "Ave Beat Period (s)", "Ave Cycle Length (s)"]));

    if ~isempty(well_mean_act_times_beats)
        well_stats_table(:, 2) = num2cell(well_mean_act_times_beats);

        well_stats_table(:, 3) = num2cell(well_mean_act_volts_beats);

        well_stats_table(:, 4) = num2cell(well_mean_min_depol_times_beats);

        well_stats_table(:, 5) = num2cell(well_mean_min_depol_volts_beats);

        well_stats_table(:, 6) = num2cell(well_mean_max_depol_times_beats);

        well_stats_table(:, 7) = num2cell(well_mean_max_depol_volts_beats);

        well_stats_table(:, 8) = num2cell(well_mean_amps_beats);

        well_stats_table(:, 9) = num2cell(well_mean_slopes_beats);

        well_stats_table(:, 10) = num2cell(well_mean_t_wave_times_beats);

        well_stats_table(:, 11) = num2cell(well_mean_t_wave_volts_beats);

        well_stats_table(:, 12) = num2cell(well_mean_FPDs_beats);

        well_stats_table(:, 13) = num2cell(well_mean_bps_beats);

        well_stats_table(:, 14) = num2cell(well_mean_cycle_lengths_beats);


    end




    fileattrib(output_filename, '-h +w');

    %writecell(electrode_stats, output_filename, 'Sheet', sheet_count);
    writetable(well_stats_table, output_filename, 'Sheet', 2);
    %fileattrib(output_filename, '+h +w');


    well_FPDs = well_FPDs(~isnan(well_FPDs));
    well_slopes = well_slopes(~isnan(well_slopes));
    well_amps = well_amps(~isnan(well_amps));
    well_bps = well_bps(~isnan(well_bps));

    mean_FPD = mean(well_FPDs);
    mean_slope = mean(well_slopes);
    mean_amp = mean(well_amps);
    mean_bp = mean(well_bps);



    mean_num_arrhythmias = sum_arrhythmic_event/count_arrhthmic_average_electrode;

    
    if strcmp(well_electrode_data(well_count).spon_paced, 'spon')
        FPDc_fridericia = mean_FPD/((mean_bp)^(1/3));
        FPDc_bazzet = mean_FPD/((mean_bp)^(1/2));

        headings = {strcat(well_ID, ': Well-wide statistics'); 'max start activation time (s)'; 'max start activation time electrode id';'min start activation time (s)'; 'min start activation time electrode id'; 'mean FPD (s)'; 'FPDc Fridericia (s)'; 'FPDc Bazzet (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Conduction Velocity (dum/dt)'; 'Average num of Arrhythmic beats per electrode'};

        mean_data1 = [max_act_time]; 
        mean_data2 = [mean_FPD; FPDc_fridericia; FPDc_bazzet; mean_slope; mean_amp; mean_bp; well_electrode_data(well_count).conduction_velocity; mean_num_arrhythmias];
        mean_data1 = num2cell(mean_data1);
        mean_data2 = num2cell(mean_data2);
        mean_data = vertcat({''}, {max_act_time}, {max_act_elec_id}, {min_act_time}, {min_act_elec_id}, mean_data2);
    else

        headings = {strcat(well_ID, ': Well-wide statistics'); 'max start activation time (s)'; 'max start activation time electrode id';'min start activation time (s)'; 'min start activation time electrode id'; 'mean FPD (s)'; 'mean Depolarisation Slope'; 'mean Depolarisation amplitude (V)'; 'mean Beat Period (s)'; 'Conduction Velocity (dum/dt)'; 'Average num of Arrhythmic beats per electrode'};

        mean_data1 = [max_act_time]; 
        mean_data2 = [mean_FPD; mean_slope; mean_amp; mean_bp; well_electrode_data(well_count).conduction_velocity; mean_num_arrhythmias];
        mean_data1 = num2cell(mean_data1);
        mean_data2 = num2cell(mean_data2);
        mean_data = vertcat({''}, {max_act_time}, {max_act_elec_id}, {min_act_time}, {min_act_elec_id}, {mean_FPD}, {mean_slope}, {mean_amp}, {mean_bp}, {conduction_velocity}, {mean_num_arrhythmias});
    end
    well_stats = horzcat(headings, mean_data);
    %max_act_elec_id
    %cell%disp(well_stats);
    well_stats = vertcat(well_stats, average_electrodes);
    %well_stats = cellstr(well_stats)

    %cell%disp(well_stats)

    %xlsxwrite(output_filename, well_stats, 1);
    fileattrib(output_filename, '-h +w');
    writecell(well_stats, output_filename, 'Sheet', 1);

    close(wait_bar)

    fclose('all');

end




