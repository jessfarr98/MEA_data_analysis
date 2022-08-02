function MEA_GUI_Load_Analysed_Data(raw_data_file, results_file)
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
            
            electrode_table = readtable(results_file, 'Sheet', sheet_count);
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
                        if mod((etsr-11), 13) == 0
                            analyse_all_b2b = 'all';

                        else
                            analyse_all_b2b = 'time_region';
                        end
                    elseif strcmp(electrode_data(electrode_count).spon_paced, 'spon')
                        %if mod((etsr-13), 15) == 0
                        if mod((etsr-13), 16) == 0
                            analyse_all_b2b = 'all';

                        else
                            analyse_all_b2b = 'time_region';
                        end
                        
                    else
                        %if mod((etsr-10), 15) == 0
                        if mod((etsr-11), 16) == 0
                            analyse_all_b2b = 'all';

                        else
                            analyse_all_b2b = 'time_region';
                        end
                        
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
                    wavelet_families = table2array(electrode_table(:, 20));
                    [r, c] = size(wavelet_families);
                    wavelet_families = reshape(wavelet_families, [c, r]);
                    
                    %polynomial_degrees = table2array(electrode_table(:, 21));
                    polynomial_degrees = table2array(electrode_table(:, 21));
                    [r, c] = size(polynomial_degrees);
                    polynomial_degrees = reshape(polynomial_degrees, [c, r]);
                
                    %electrode_data(electrode_count).warning_array = table2array(electrode_table(:, 22));
                    electrode_data(electrode_count).warning_array = table2array(electrode_table(:, 22));
                    [r, c] = size(electrode_data(electrode_count).warning_array);
                    electrode_data(electrode_count).warning_array = reshape(electrode_data(electrode_count).warning_array, [c, r]);
                end 
                
                electrode_data(electrode_count).t_wave_wavelet_array = wavelet_families;
                electrode_data(electrode_count).t_wave_polynomial_degree_array = polynomial_degrees;
                
                
                
                [electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data] = generate_filtered_data_b2b(electrode_data(electrode_count).time, electrode_data(electrode_count).data, beat_start_times, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).filter_intensity, wavelet_families, polynomial_degrees, spon_paced, electrode_data(electrode_count).t_wave_offset, electrode_data(electrode_count).t_wave_duration, electrode_data(electrode_count).t_wave_shape, electrode_data(electrode_count).post_spike_hold_off, electrode_data(electrode_count).stim_spike_hold_off);
                
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
    
    
    if strcmp(beat_to_beat, 'on')
        if strcmp(spon_paced, 'spon')
            [conduction_velocity, model] =  calculateSpontaneousConductionVelocity(electrode_data,  num_electrode_rows, num_electrode_cols, conduction_velocity);

        else
            [conduction_velocity, model] =  calculatePacedConductionVelocity(electrode_data,  num_electrode_rows, num_electrode_cols, conduction_velocity);

        end
        well_electrode_data(1).conduction_velocity = conduction_velocity;
        well_electrode_data(1).conduction_velocity_model = model;
    
    end
    
    
    well_electrode_data(1).electrode_data = electrode_data;
    well_electrode_data(1).wellID = wellID;
    well_electrode_data(1).rejected_well = 0;
    
    well_electrode_data(1).spon_paced = spon_paced;
    
               
    
    MEA_GUI_analysis_display_resultsV2(Data, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar, save_dir, 1)
    

end





function [filtered_time, filtered_data] = generate_filtered_data_b2b(time, data, beat_start_times, warning_array, filter_intensity, wavelet_families, polynomial_degrees, spon_paced, est_peak_time, t_wave_search_duration, t_wave_shape, post_spike_hold_off, stim_spike_hold_off)
    

    % TO DO:
    % separate reanalysed beat parameters

    orig_est_peak_time = est_peak_time;
    orig_t_wave_duration = t_wave_search_duration;
    orig_post_spike_holdoff = post_spike_hold_off;
    orig_stim_spike_hold_off = stim_spike_hold_off;
    orig_t_wave_shape = t_wave_shape;
    
    filtered_time = [];
    filtered_data = [];
    
    
    for b = 1:length(beat_start_times)
        
        if b == length(beat_start_times)
            b_t = beat_start_times(b);
            b_t_end = time(end);
        else
            b_end = b+1;
            b_t = beat_start_times(b);
            b_t_end = beat_start_times(b_end);
        end

        
        
        beat_indx = find(b_t <= time & time <= b_t_end);
        beat_time = time(beat_indx);
        beat_data = data(beat_indx);
        
        est_peak_time = orig_est_peak_time;
        t_wave_search_duration = orig_t_wave_duration;
        post_spike_hold_off = orig_post_spike_holdoff;
        stim_spike_hold_off = orig_stim_spike_hold_off;
        t_wave_shape = orig_t_wave_shape;
        
        
        warning = warning_array{b};
        if ~isempty(warning)
            if contains(warning, 'Reanalysed')
               split_one = strsplit(first_beat_warning{1}, ',');
               split_two = strsplit(split_one{1, 2}, ',');

           end
        end
        
        % Depol filtration
        
        if post_spike_hold_off >= beat_time(end)-beat_time(1)
            post_spike_hold_off = beat_time(end)-beat_time(1)/10;
        end

        if strcmp(spon_paced, 'spon')
            iters = 1;
            while(1)
                post_spike_hold_off_time = time(1)+post_spike_hold_off;
                pshot_indx = find(time >= post_spike_hold_off_time);
                if length(pshot_indx)>=1
                    pshot_indx_offset = pshot_indx(1);
                    break;

                end
                post_spike_hold_off = post_spike_hold_off*0.9;
                iters = iters+1;
                if iters == 20
                    pshot_indx_offset = length(time);
                    break;
                end
            end
            depol_complex_time = beat_time(1:pshot_indx_offset);
            depol_complex_data = beat_data(1:pshot_indx_offset);
        elseif strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
            start_time_indx = find(time >= time(1)+stim_spike_hold_off);

            %start_time_indx(1)
            iters = 1;
            while(1)
                post_spike_hold_off_time = beat_time(1)+post_spike_hold_off;
                pshot_indx = find(beat_time >= post_spike_hold_off_time);
                if length(pshot_indx)>=1
                    pshot_indx_offset = pshot_indx(1);
                    break;
                end
                post_spike_hold_off = post_spike_hold_off*0.9;
                iters = iters+1;
                if iters == 20
                    pshot_indx_offset = length(beat_time);
                    break;
                end
            end
            try
                depol_complex_time = beat_time(start_time_indx(1):pshot_indx_offset);
                depol_complex_data = beat_data(start_time_indx(1):pshot_indx_offset);
                %{
                disp(length(depol_complex_time))
                disp('depol start')
                disp(depol_complex_time(1))
                disp('depol end')
                disp(depol_complex_time(end))
                %}

                % make it require at least 40 elements so strong filtering can be applied if opted for
                if length(depol_complex_time) < 40
                    depol_complex_time = time;
                    depol_complex_data = data;
                end
            catch 
                %disp('catch')
                depol_complex_time = time(1:pshot_indx_offset);
                depol_complex_data = data(1:pshot_indx_offset);
                %disp(length(depol_complex_time))
                % make it require at least 40 elements so strong filtering can be applied if opted for
                if length(depol_complex_time) < 40
                    %disp('all')
                    depol_complex_time = time;
                    depol_complex_data = data;
                end
            end

        end
    

        %depol_complex_data_derivative = gradient(depol_complex_data_derivative);

        %activation_time_indx = find(depol_complex_data_derivative == min(depol_complex_data_derivative));
        %activation_time_indx = find(abs(depol_complex_data_derivative) == max(abs(depol_complex_data_derivative)));

        max_depol_point = max(depol_complex_data);
        indx_max_depol_point = find(depol_complex_data == max_depol_point);
        indx_max_depol_point = indx_max_depol_point(1);

        min_depol_point = min(depol_complex_data);
        indx_min_depol_point = find(depol_complex_data == min_depol_point);
        indx_min_depol_point = indx_min_depol_point(1);
        
        [dr, dc] = size(depol_complex_data);
        [tr, tc] = size(depol_complex_time);
        
        %figure();
        %plot(depol_complex_time, depol_complex_data);
        
        if strcmp(filter_intensity, 'none')
            filtration_rate = 1;
        elseif strcmp(filter_intensity, 'low')
            filtration_rate = 5;
        elseif strcmp(filter_intensity, 'medium')
            filtration_rate = 10;
        else
            filtration_rate = 20;
        end
    
        if indx_min_depol_point < indx_max_depol_point
        
            
            activation_filtration_rate  = filtration_rate;
            activation_filter_intensity = filter_intensity;
            
            while(1)
                if (length(depol_complex_data(indx_min_depol_point:indx_max_depol_point))/activation_filtration_rate) >= 5
                    break
                else
                    if strcmp(activation_filter_intensity, 'none')
                        break;
                    elseif strcmp(activation_filter_intensity, 'low')
                        %filtration_rate = 5;
                        activation_filtration_rate  = 1;
                        activation_filter_intensity = 'none';
                    elseif strcmp(activation_filter_intensity, 'medium')
                        %filtration_rate = 10;
                        activation_filtration_rate  = 5;
                        activation_filter_intensity = 'low';
                    else
                        %filtration_rate = 10;
                        activation_filtration_rate  = 10;
                        activation_filter_intensity = 'medium';
                    end

                end
            end
            

            if dc == 1
                depol_filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:activation_filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:filtration_rate:end));
                %filtered_data = depol_complex_data(1:filtration_rate:indx_min_depol_point);

            else


                depol_filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:activation_filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:filtration_rate:end));

            end

            if tc == 1
                depol_filtered_time = vertcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:activation_filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:filtration_rate:end));

            else
                depol_filtered_time = horzcat(depol_complex_time(1:filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:activation_filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:filtration_rate:end));

            end




            %{
            poly_time = depol_complex_time_filtered - depol_complex_time_filtered(1);
            best_p_degree = 21;

            pfit = polyfit(poly_time,filtered_data,best_p_degree);
            filtered_data = polyval(pfit, poly_time);
            %}

        else
            
            activation_filtration_rate  = filtration_rate;
            activation_filter_intensity = filter_intensity;
            
            while(1)
                if (length(depol_complex_data(indx_max_depol_point:indx_min_depol_point))/activation_filtration_rate) >= 5
                    break
                else
                    if strcmp(activation_filter_intensity, 'none')
                        break;
                    elseif strcmp(activation_filter_intensity, 'low')
                        %filtration_rate = 5;
                        activation_filtration_rate  = 1;
                        activation_filter_intensity = 'none';
                    elseif strcmp(activation_filter_intensity, 'medium')
                        %filtration_rate = 10;
                        activation_filtration_rate  = 5;
                        activation_filter_intensity = 'low';
                    else
                        %filtration_rate = 10;
                        activation_filtration_rate  = 10;
                        activation_filter_intensity = 'medium';
                    end

                end
            end
            
            if dc == 1
                depol_filtered_data = vertcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:activation_filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:filtration_rate:end));
            else
                depol_filtered_data = horzcat(depol_complex_data(1:filtration_rate:indx_max_depol_point), depol_complex_data(indx_max_depol_point:activation_filtration_rate:indx_min_depol_point), depol_complex_data(indx_min_depol_point:filtration_rate:end));

            end

            if tc == 1

                depol_filtered_time = vertcat(depol_complex_time(1:filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:activation_filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:filtration_rate:end));

            else

                depol_filtered_time = horzcat(depol_complex_time(1:filtration_rate:indx_max_depol_point), depol_complex_time(indx_max_depol_point:activation_filtration_rate:indx_min_depol_point), depol_complex_time(indx_min_depol_point:filtration_rate:end));

            end

            %depol_complex_time_filtered = depol_complex_time;

            %filtered_data = wdenoise(depol_complex_data,'Wavelet', 'sym8', 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');



 



            %{

            poly_time = depol_complex_time_filtered - depol_complex_time_filtered(1);
            best_p_degree = 21;

            pfit = polyfit(poly_time,filtered_data,best_p_degree);
            filtered_data = polyval(pfit, poly_time);
            %}



        end
        
        depol_polynomial = depol_filtered_data;
        
        %T-wave filtration
        
        wavelet_family = wavelet_families{b};
        p_degree = polynomial_degrees(b);
        
        if isempty(wavelet_family)
            continue
        end
        
        if isnan(p_degree)
            continue
        end
        
        if est_peak_time >= beat_time(end)-beat_time(1)
                
            est_peak_time = est_peak_time*beat_time(end)-beat_time(1)/4;

        end
        if t_wave_search_duration >= beat_time(end)-beat_time(1)

            t_wave_search_duration = est_peak_time*beat_time(end)-beat_time(1)/5;

        end
        if post_spike_hold_off >= beat_time(end)-beat_time(1)
            post_spike_hold_off = beat_time(end)-beat_time(1)/10;
        end
        lower = beat_time(1)+ est_peak_time - t_wave_search_duration/2;
        upper = beat_time(1)+ est_peak_time + t_wave_search_duration/2;


        if lower < beat_time(1)+post_spike_hold_off
            lower = beat_time(1)+post_spike_hold_off;
        end

        if lower >= beat_time(end)
            lower = beat_time(1)+post_spike_hold_off;
        end         

        if upper > beat_time(end)
            upper = beat_time(end)-post_spike_hold_off;
        end

        if lower >= upper
            lower = beat_time(1)+post_spike_hold_off;
        end
        
        %This failed for seaky
        t_wave_indx = find(beat_time >= lower & beat_time <= upper);

        t_wave_time = beat_time(t_wave_indx);
        t_wave_data = beat_data(t_wave_indx);

        if strcmp(t_wave_shape, 'inflection') || strcmp(t_wave_shape, 'zero crossing')
            t_wave_max_indx = find(t_wave_data == max(t_wave_data), 1);
            t_wave_min_indx = find(t_wave_data == min(t_wave_data), 1);

            t_wave_max_time = t_wave_time(t_wave_max_indx);

            t_wave_min_time = t_wave_time(t_wave_min_indx);


            filtration_rate = 20;


            [dr, dc] = size(t_wave_data);
            [tr, tc] = size(t_wave_time);

            if t_wave_min_indx < t_wave_max_indx
                
                
                if dc == 1
                    t_wave_data_filtered = vertcat(t_wave_data(1:filtration_rate:t_wave_min_indx), t_wave_data(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_data(t_wave_max_indx:filtration_rate:end));

                else


                    t_wave_data_filtered = horzcat(t_wave_data(1:filtration_rate:t_wave_min_indx), t_wave_data(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_data(t_wave_max_indx:filtration_rate:end));

                end
                
                if tc == 1
                    t_wave_time_filtered = vertcat(t_wave_time(1:filtration_rate:t_wave_min_indx), t_wave_time(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_time(t_wave_max_indx:filtration_rate:end));

                else
                    t_wave_time_filtered = horzcat(t_wave_time(1:filtration_rate:t_wave_min_indx), t_wave_time(t_wave_min_indx+1:filtration_rate:t_wave_max_indx-1), t_wave_time(t_wave_max_indx:filtration_rate:end));

                end
            else
                if dc == 1
                    t_wave_data_filtered = vertcat(t_wave_data(1:filtration_rate:t_wave_max_indx), t_wave_data(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_data(t_wave_min_indx:filtration_rate:end));

                else

                    t_wave_data_filtered = horzcat(t_wave_data(1:filtration_rate:t_wave_max_indx), t_wave_data(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_data(t_wave_min_indx:filtration_rate:end));

                end
                
                if tc == 1
                    t_wave_time_filtered = vertcat(t_wave_time(1:filtration_rate:t_wave_max_indx), t_wave_time(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_time(t_wave_min_indx:filtration_rate:end));

                else

                    t_wave_time_filtered = horzcat(t_wave_time(1:filtration_rate:t_wave_max_indx), t_wave_time(t_wave_max_indx+1:filtration_rate:t_wave_min_indx-1), t_wave_time(t_wave_min_indx:filtration_rate:end));

                end
                
                
            end
        else
            t_wave_time_filtered = t_wave_time(1:20:end);
            t_wave_data_filtered = t_wave_data(1:20:end);
        
        end
        
        t_wave_data_filtered = wdenoise(t_wave_data_filtered,'Wavelet', wavelet_family, 'DenoisingMethod', 'Bayes', 'ThresholdRule', 'Soft', 'NoiseEstimate', 'LevelDependent');
        
        poly_time = t_wave_time_filtered - t_wave_time_filtered(1);
        
        pfit = polyfit(poly_time, t_wave_data_filtered, p_degree);
        polynomial = polyval(pfit, poly_time);
        
        polynomial_time = t_wave_time_filtered;

        
        %if ~strcmp(filter_intensity, 'none')
           if strcmp(filter_intensity, 'low')
              filtration_rate = 5;
          elseif strcmp(filter_intensity, 'medium')
              filtration_rate = 10;
          else
              filtration_rate = 20;
           end

           [dr, dc] = size(beat_data);
           [tr, tc] = size(beat_time);

           [ptr, ptc] = size(polynomial_time);
           [pr, pc] = size(polynomial);
           [pdr, pdc] = size(depol_polynomial);

           if indx_min_depol_point < indx_max_depol_point


               if tc == 1
                   if ptr == 1
                       polynomial_time = reshape(polynomial_time, [ptc, ptr]);

                   end
                   %filtered_time = [filtered_time; nan; beat_time(1:filtration_rate:indx_min_depol_point); beat_time(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1); beat_time(indx_max_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial_time];
                    filtered_time = [filtered_time; nan; depol_filtered_time; nan; polynomial_time];

               else
                   if ptc == 1
                       polynomial_time = reshape(polynomial_time, [ptc, ptr]);

                   end
                   filtered_time = [filtered_time nan depol_filtered_time nan polynomial_time];

               end 


               if dc == 1
                   if pr == 1
                       polynomial = reshape(polynomial, [pc, pr]);

                   end
                   %filtered_data  = [filtered_data; nan; beat_data(1:filtration_rate:indx_min_depol_point); beat_data(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1); beat_data(indx_max_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial];
                    filtered_data  = [filtered_data; nan; depol_polynomial; nan; polynomial];

               else
                   if pc == 1
                       polynomial = reshape(polynomial, [pc, pr]);

                   end
                   %filtered_data  = [filtered_data nan beat_data(1:filtration_rate:indx_min_depol_point) beat_data(indx_min_depol_point+1:filtration_rate:indx_max_depol_point-1) beat_data(indx_max_depol_point:filtration_rate:pshot_indx_offset) nan polynomial];
                    filtered_data  = [filtered_data nan depol_polynomial nan polynomial];

               end

           else
               if tc == 1
                   if ptr == 1
                       polynomial_time = reshape(polynomial_time, [ptc, ptr]);

                   end
                   filtered_time = [filtered_time; nan; depol_filtered_time; nan; polynomial_time];

               else
                   if ptc == 1
                       polynomial_time = reshape(polynomial_time, [ptc, ptr]);

                   end
                   filtered_time = [filtered_time nan depol_filtered_time nan polynomial_time];

               end

               if dc == 1
                   if pr == 1
                       polynomial = reshape(polynomial, [pc, pr]);

                   end
                   %filtered_data  = [filtered_data; nan; beat_data(1:filtration_rate:indx_max_depol_point); beat_data(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1); beat_data(indx_min_depol_point:filtration_rate:pshot_indx_offset); nan; polynomial];
                    filtered_data  = [filtered_data; nan; depol_polynomial; nan; polynomial];

               else
                   if pc == 1
                       polynomial = reshape(polynomial, [pc, pr]);

                   end
                   %filtered_data  = [filtered_data nan beat_data(1:filtration_rate:indx_max_depol_point) beat_data(indx_max_depol_point+1:filtration_rate:indx_min_depol_point-1) beat_data(indx_min_depol_point:filtration_rate:pshot_indx_offset) nan polynomial];
                    filtered_data  = [filtered_data nan depol_polynomial nan polynomial];


               end


           end

        %{
       else
           [dr, dc] = size(beat_data);
           [tr, tc] = size(beat_time);

           [ptr, ptc] = size(polynomial_time);
           [pr, pc] = size(polynomial);
           if tc == 1
               if ptr == 1
                   polynomial_time = reshape(polynomial_time, [ptc, ptr]);

               end
               filtered_time = [filtered_time; nan; polynomial_time];

           else
               if ptc == 1
                   polynomial_time = reshape(polynomial_time, [ptc, ptr]);

               end
               filtered_time = [filtered_time nan polynomial_time];

           end 

           if dc == 1
               if pr == 1
                   polynomial = reshape(polynomial, [pc, pr]);

               end
               filtered_data  = [filtered_data; nan; polynomial];

           else
               if pc == 1
                   polynomial = reshape(polynomial, [pc, pr]);

               end
               filtered_data  = [filtered_data nan polynomial];
           end


        end
        %}
        
    end


end