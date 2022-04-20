function MEA_GUI_Load_GE_Data(raw_data_file, results_file)

    [save_dir,~,ext] = fileparts(results_file);
    
    
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
    
    
    
    
    sheet_count = 2;
    change_all_data_type = 1;
    beat_to_beat = 'off';
    analyse_all_b2b = nan;
    stable_ave_analysis = 'stable';
    
    
    [~, sheets] = xlsfinfo(results_file);
    %sheets = sheetnames(DATA.name);
    num_wells = length(sheets);
    
    electrode_stats_table = readcell(results_file, 'Sheet', 1);
    
    well_electrode_data = WellElectrodeData.empty(num_wells-1, 0);
    added_wells = [];
    
    for w = 2:num_wells
        electrode_count = 0;
        electrode_table = readtable(results_file, 'Sheet', sheet_count);
        
        %wellID = electrode_table{1, 1}
        
        
        wellID = electrode_table.Properties.VariableNames{1};
        
        GE_electrode = wellID;
        
        well_parts = strsplit(wellID, '_');
        wellID = well_parts{1};
        
        
        well_dictionary = {'A', 'B', 'C', 'D', 'E', 'F'};
    
        split_wellID = strsplit(wellID, '0');
        wellID_row = split_wellID{1};
        wellID_col = str2num(split_wellID{2});

        wellID_row = find(strcmp(well_dictionary, wellID_row));    
        
        min_stdev = nan;
        %continue
        
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
        for e_r = num_electrode_rows:-1:1
            
            
            for e_c = 1:num_electrode_cols
                electrode_count = electrode_count+1;


                electrode_id = strcat(wellID, {'_'}, string(e_c), {'_'}, string(e_r));

                %{
                if strcmp(GE_electrode, electrode_id)
                    
                    well_electrode_data(w-1).GE_electrode_indx = electrode_count;
                end
                %}
                [etr, etc] = size(electrode_table);
                if strcmp(spon_paced, 'paced')
                    if etc == 25
                        electrode_data(electrode_count).spon_paced = 'paced bdt';
                    else
                       change_all_data_type = 0;
                    end
                end

                electrode_data(electrode_count).time = Data{wellID_row,wellID_col,e_c,e_r}.GetTimeVector;
                electrode_data(electrode_count).data = Data{wellID_row,wellID_col,e_c,e_r}.GetVoltageVector;
                electrode_data(electrode_count).electrode_id = electrode_id;

                if strcmp(electrode_data(electrode_count).spon_paced, 'spon')

                    electrode_data(electrode_count).stable_beats_duration = str2num(string(electrode_table{1, 16}));

                    electrode_data(electrode_count).bdt = str2num(string(electrode_table{1, 17}));
                    electrode_data(electrode_count).min_bp = str2num(string(electrode_table{1, 18}));
                    electrode_data(electrode_count).max_bp = str2num(string(electrode_table{1, 19}));
                    electrode_data(electrode_count).post_spike_hold_off = str2num(string(electrode_table{1, 20}));
                    electrode_data(electrode_count).t_wave_offset = str2num(string(electrode_table{1, 21}));
                    electrode_data(electrode_count).t_wave_duration =  str2num(string(electrode_table{1, 22}));
                    electrode_data(electrode_count).t_wave_shape =  (string(electrode_table{1, 23}));

                    electrode_data(electrode_count).filter_intensity =  (string(electrode_table{1, 24}));

                    electrode_data(electrode_count).ave_wave_post_spike_hold_off =  str2num(string(electrode_table{1, 25}));
                    electrode_data(electrode_count).ave_wave_t_wave_duration =  str2num(string(electrode_table{1, 26}));
                    electrode_data(electrode_count).ave_wave_t_wave_offset =  str2num(string(electrode_table{1, 27}));
                    electrode_data(electrode_count).ave_wave_t_wave_shape =  (string(electrode_table{1, 28}));
                    electrode_data(electrode_count).ave_wave_filter_intensity =  (string(electrode_table{1, 29}));


                    electrode_data(electrode_count).ave_t_wave_wavelet = (string(electrode_table{1, 30}));
                    electrode_data(electrode_count).ave_t_wave_polynomial_degree = str2num(string(electrode_table{1, 31}));

                    electrode_data(electrode_count).ave_warning =  (string(electrode_table{1, 32}));

                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array, electrode_data(electrode_count).depol_slope_array,electrode_data(electrode_count).warning_array, electrode_data(electrode_count).filtered_time,electrode_data(electrode_count).filtered_data, electrode_data(electrode_count).t_wave_wavelet_array, electrode_data(electrode_count).t_wave_polynomial_degree_array] = extract_beats_V2(wellID, electrode_data(electrode_count).time, electrode_data(electrode_count).data, electrode_data(electrode_count).bdt, spon_paced, beat_to_beat, analyse_all_b2b, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, stable_ave_analysis, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, 'N/A', electrode_id, electrode_data(electrode_count).t_wave_shape, electrode_data(electrode_count).t_wave_duration, Stims, electrode_data(electrode_count).min_bp, electrode_data(electrode_count).max_bp, electrode_data(electrode_count).post_spike_hold_off, electrode_data(electrode_count).t_wave_offset, nan, electrode_data(electrode_count).filter_intensity);


                elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')

                    electrode_data(electrode_count).stable_beats_duration = str2num(string(electrode_table{1, 14}));

                    electrode_data(electrode_count).stim_spike_hold_off = str2num(string(electrode_table{1, 15}));
                    electrode_data(electrode_count).post_spike_hold_off = str2num(string(electrode_table{1, 16}));
                    electrode_data(electrode_count).t_wave_offset = str2num(string(electrode_table{1, 17}));
                    electrode_data(electrode_count).t_wave_duration =  str2num(string(electrode_table{1, 18}));
                    electrode_data(electrode_count).t_wave_shape =  (string(electrode_table{1, 19}));

                    electrode_data(electrode_count).filter_intensity =  (string(electrode_table{1, 21}));

                    electrode_data(electrode_count).ave_wave_stim_spike_hold_off = str2num(string(electrode_table{1, 21}));
                    electrode_data(electrode_count).ave_wave_post_spike_hold_off =  str2num(string(electrode_table{1, 22}));
                    electrode_data(electrode_count).ave_wave_t_wave_duration =  str2num(string(electrode_table{1, 23}));
                    electrode_data(electrode_count).ave_wave_t_wave_offset =  str2num(string(electrode_table{1, 24}));
                    electrode_data(electrode_count).ave_wave_t_wave_shape =  (string(electrode_table{1, 25}));
                    electrode_data(electrode_count).ave_wave_filter_intensity =  (string(electrode_table{1, 26}));

                    electrode_data(electrode_count).ave_t_wave_wavelet = (string(electrode_table{1, 27}));
                    electrode_data(electrode_count).ave_t_wave_polynomial_degree = str2num(string(electrode_table{1, 28}));

                    electrode_data(electrode_count).ave_warning =  (string(electrode_table{1, 29}));

                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array, electrode_data(electrode_count).depol_slope_array, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).Stim_volts, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data,electrode_data(electrode_count). t_wave_wavelet_array, electrode_data(electrode_count).t_wave_polynomial_degree_array] = extract_paced_beats(wellID, electrode_data(electrode_count).time, electrode_data(electrode_count).data, electrode_data(electrode_count).bdt, spon_paced, beat_to_beat, analyse_all_b2b, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, stable_ave_analysis, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, 'N/A', electrode_id, electrode_data(electrode_count).t_wave_shape, electrode_data(electrode_count).t_wave_duration, Stims, electrode_data(electrode_count).post_spike_hold_off, electrode_data(electrode_count).stim_spike_hold_off, electrode_data(electrode_count).t_wave_offset, nan, electrode_data(electrode_count).filter_intensity);     

                else
                    electrode_data(electrode_count).stable_beats_duration = str2num(string(electrode_table{1, 14}));

                    electrode_data(electrode_count).bdt = str2num(string(electrode_table{1, 15}));
                    electrode_data(electrode_count).min_bp = str2num(string(electrode_table{1, 16}));
                    electrode_data(electrode_count).max_bp = str2num(string(electrode_table{1, 17}));
                    electrode_data(electrode_count).stim_spike_hold_off = str2num(string(electrode_table{1, 18}));
                    electrode_data(electrode_count).post_spike_hold_off = str2num(string(electrode_table{1, 19}));
                    electrode_data(electrode_count).t_wave_offset = str2num(string(electrode_table{1, 20}));
                    electrode_data(electrode_count).t_wave_duration =  str2num(string(electrode_table{1, 21}));
                    electrode_data(electrode_count).t_wave_shape =  (string(electrode_table{1, 22}));

                    electrode_data(electrode_count).filter_intensity =  (string(electrode_table{1, 23}));

                    electrode_data(electrode_count).ave_wave_stim_spike_hold_off = str2num(string(electrode_table{1, 24}));
                    electrode_data(electrode_count).ave_wave_post_spike_hold_off =  str2num(string(electrode_table{1, 25}));
                    electrode_data(electrode_count).ave_wave_t_wave_duration =  str2num(string(electrode_table{1, 26}));
                    electrode_data(electrode_count).ave_wave_t_wave_offset =  str2num(string(electrode_table{1, 27}));
                    electrode_data(electrode_count).ave_wave_t_wave_shape =  (string(electrode_table{1, 28}));
                    electrode_data(electrode_count).ave_wave_filter_intensity =  (string(electrode_table{1, 29}));

                    electrode_data(electrode_count).ave_t_wave_wavelet = (string(electrode_table{2, 30}));
                    electrode_data(electrode_count).ave_t_wave_polynomial_degree = str2num(string(electrode_table{1, 31}));

                    electrode_data(electrode_count).ave_warning =  (string(electrode_table{1, 32}));

                    [electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).max_depol_point_array, electrode_data(electrode_count).min_depol_point_array, electrode_data(electrode_count).depol_slope_array, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).Stim_volts, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data, electrode_data(electrode_count).t_wave_wavelet_array, electrode_data(electrode_count).t_wave_polynomial_degree_array] = extract_paced_bdt_beats(wellID, electrode_data(electrode_count).time, electrode_data(electrode_count).data, electrode_data(electrode_count).bdt, spon_paced, beat_to_beat, analyse_all_b2b, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, stable_ave_analysis, electrode_data(electrode_count).time_region_start, electrode_data(electrode_count).time_region_end, 'N/A', electrode_id, electrode_data(electrode_count).t_wave_shape, electrode_data(electrode_count).t_wave_duration, electrode_data(electrode_count).Stims, electrode_data(electrode_count).post_spike_hold_off, electrode_data(electrode_count).stim_spike_hold_off, electrode_data(electrode_count).t_wave_offset, nan, electrode_data(electrode_count).min_bp, electrode_data(electrode_count).max_bp, electrode_data(electrode_count).filter_intensity);     


                end
                electrode_data(electrode_count).electrode_id = electrode_id;

                %[average_waveform_duration, average_waveform, elec_min_stdev, artificial_time_space, electrode_data] = compute_electrode_average_stable_waveform(beat_num_array, cycle_length_array, activation_time_array, beat_start_times, beat_periods, time, data, well_stable_dur_array(well_count), electrode_data, electrode_count, electrode_id, plot_ave_dir, wellID, post_spike_hold_off, stim_spike_hold_off, spon_paced, beat_to_beat, t_wave_shape, t_wave_duration, est_peak_time, est_fpd, filter_intensity);


                [average_waveform_duration, average_waveform, elec_min_stdev, artificial_time_space, electrode_data] = compute_electrode_average_stable_waveform(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_periods, electrode_data(electrode_count).time, electrode_data(electrode_count).data, electrode_data(electrode_count).stable_beats_duration, electrode_data, electrode_count, electrode_id, 'N/A', wellID, electrode_data(electrode_count).ave_wave_post_spike_hold_off, electrode_data(electrode_count).ave_wave_stim_spike_hold_off, spon_paced, beat_to_beat, electrode_data(electrode_count).ave_wave_t_wave_shape, electrode_data(electrode_count).ave_wave_t_wave_duration, electrode_data(electrode_count).ave_wave_t_wave_offset, nan, electrode_data(electrode_count).ave_wave_filter_intensity);

                if isnan(min_stdev)
                    min_stdev = elec_min_stdev;
                    min_stdev_indx = electrode_count;
                else
                    if elec_min_stdev < min_stdev
                        min_stdev = elec_min_stdev;
                        min_stdev_indx = electrode_count;

                    end

                end
                


            end
        end
        if strcmp(spon_paced, 'paced')
           if change_all_data_type == 1
               spon_paced = 'paced bdt';

           end
        end
        
        electrode_data(min_stdev_indx).ave_activation_time = str2num(string(electrode_table{1, 2}));
        electrode_data(min_stdev_indx).ave_activation_point = str2num(string(electrode_table{1, 3}));

        electrode_data(min_stdev_indx).ave_min_depol_time = str2num(string(electrode_table{1, 4}));
        electrode_data(min_stdev_indx).ave_min_depol_point = str2num(string(electrode_table{1, 5}));

        electrode_data(min_stdev_indx).ave_max_depol_time = str2num(string(electrode_table{1, 6}));
        electrode_data(min_stdev_indx).ave_max_depol_point = str2num(string(electrode_table{1, 7}));

        electrode_data(min_stdev_indx).ave_depol_slope = str2num(string(electrode_table{1, 9}));

        electrode_data(min_stdev_indx).ave_t_wave_peak_time = str2num(string(electrode_table{1, 10}));
        electrode_data(min_stdev_indx).ave_t_wave_peak = str2num(string(electrode_table{1, 11}));

        


        %wellID_str = strcat(well_dictionary(wellID_row), '0', num2str(wellID_col));
        added_wells = [added_wells; string(wellID)];

        bipolar = 'on';

        well_electrode_data(w-1).GE_electrode_indx = min_stdev_indx;
        well_electrode_data(w-1).electrode_data = electrode_data;
        well_electrode_data(w-1).wellID = wellID;
        well_electrode_data(w-1).rejected_well = 0;

        well_electrode_data(w-1).spon_paced = spon_paced;
        sheet_count = sheet_count+1;
    end

    
    
    
    
    MEA_GUI_analysis_display_GE_results(Data, num_well_rows, num_well_cols, beat_to_beat, analyse_all_b2b, stable_ave_analysis, spon_paced, well_electrode_data, Stims, added_wells, bipolar, save_dir)






end