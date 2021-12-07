function reformat_MEA_statistics(input_folder, input_file)


    file_path = fullfile(input_folder, input_file);
    
    output_folder = fullfile(input_folder, 'Analysed Files');
    
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    input_file_parts = regexp(input_file, '\.', 'split');
    file_name = input_file_parts{1,1};
    file_name = strcat(file_name, '.xls')
    
    output_filename = fullfile(output_folder, file_name)
    
    class(output_filename)
    %% Needs to be xls format
    %return;
    opts = delimitedTextImportOptions("NumVariables", 49);

    % Specify range and delimiter
    opts.DataLines = [1, Inf];
    opts.Delimiter = ",";

    % Specify file level properties
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";

    % Import the data
    
    data = readtable(file_path, opts);

    %% Convert to output type
    data = table2cell(data);
    %numIdx = cellfun(@(x) ~isnan(str2double(x)), data);
    %data(numIdx) = cellfun(@(x) {str2double(x)}, data(numIdx));
    

    %% Clear temporary variables
    clear opts
    all_data = data;
    [total_rows, total_cols] = size(all_data);
    %all_range = strcat('A1:', 'A', num2str(total_rows))
    xlswrite(output_filename, all_data, 1);
    
    data = data(:, 1:12);    
    
    
    sync_indxs = cellfun(@(x) contains(x, 'Synchronized beats for well'), data);
    
    empty_indxs = cellfun(@(x) isempty(x), data);
    
    %the row numbers of when the data starts
    sync_i = find(sync_indxs == 1);
    
    empty_i = find(empty_indxs == 1);
    empty_i_gr = find(empty_i > sync_i(1));
    end_syncr = empty_i(empty_i_gr(1));
    
    sync_stats = data(sync_i:end_syncr-1, :);
    
    % Column 5 has BPs
    % Columns 9, 10, 11 has conduction vel, 2point cv, propagation delay
    [result_sync_data] = analyse_synchronized(sync_stats, sync_i);
    
    len_syncr = end_syncr-sync_i;
    syncr_range = strcat('A1:', 'A', num2str(len_syncr));
    xlswrite(output_filename, result_sync_data, 2);
    % Electrode data
    
    elec_indxs = cellfun(@(x) contains(x, 'electrode'), data);
            
    %the row numbers of when the data starts
    e_i = find(elec_indxs == 1);    
    
    prev_row = e_i(1);
    elec_count = 1;
    for elec = 2:length(e_i)
        row = e_i(elec);
        electrode_statistics = data(prev_row:row-1, :);
        [electrode_results_data] = analyse_electrode(electrode_statistics);
        %celldisp(electrode_results_data(:,4))
        xlswrite(output_filename, electrode_results_data, 2+elec_count);
        %pause(20)
        prev_row = row;
        elec_count = elec_count+1;
    end
       
   
end

function [output_data] = analyse_electrode(data)
    numIdx = cellfun(@(x) ~isnan(str2double(x)), data);
    data(numIdx) = cellfun(@(x) {str2double(x)}, data(numIdx));
    
    %use beat periods
    orig_data = data(1:end-1,:);
    data = data(3:end-1,:);
    %celldisp(data(:, 5))
    %celldisp(orig_data(1, :));
    beat_periods = cell2mat(data(:, 4));
    
    
    fpds = data(1:end,5);
    [fpd_rows, fpd_cols] = size(fpds);
    for r = 1:fpd_rows
       for c = 1:fpd_cols
           if strcmp(fpds{r,c}, 'NaN')
              %disp('nan') 
              fpds{r,c} = 0;
           end
       end
    end
    
    fpds = cell2mat(fpds);
    
    amplitudes = data(1:end,2);
    [amp_rows, amp_cols] = size(amplitudes);
    for r = 1:amp_rows
       for c = 1:amp_cols
           if strcmp(amplitudes{r,c}, 'NaN')
              %disp('nan') 
              amplitudes{r,c} = 0;
           end
       end
    end
    
    amplitudes = cell2mat(amplitudes);
    
    slopes = data(1:end,3);
    [slope_rows, slope_cols] = size(slopes);
    for r = 1:slope_rows
       for c = 1:slope_cols
           if strcmp(slopes{r,c}, 'NaN')
              %disp('nan') 
              slopes{r,c} = 0;
           end
       end
    end
    
    slopes = cell2mat(slopes);
    
    %% S2s at bp <0.95
    %% Report both S2 and beat before 
    %% report raw values and subtractions just in the S2 row
    %% everything except beat period is shifted down one column which must be considered
    
    arrival_times = cell2mat(data(:, 10));    
    
    bp_almost_one = isalmost(beat_periods, 1.0001, 0.0001);
    
    S2_indxs = [];
    for i = 2:length(bp_almost_one)
        if bp_almost_one(i) == 0 && bp_almost_one(i-1) == 1
            S2_indxs = [S2_indxs; i];
        end
    end
    
    sub_fpds = [];
    sub_arrival_times = [];
    sub_amplitudes = [];
    sub_slopes = [];
    for S2_indx = 1:length(S2_indxs)
        row_num = S2_indxs(S2_indx);
        sub_fpds = [sub_fpds; {fpds(row_num)-fpds(row_num-1)}];
        sub_arrival_times = [sub_arrival_times; {arrival_times(row_num) - arrival_times(row_num-1)}];
        sub_amplitudes = [sub_amplitudes; {amplitudes(row_num) - amplitudes(row_num-1)}];
        sub_slopes = [sub_slopes; {slopes(row_num) - slopes(row_num-1)}];
    end
    
    output_data = data(S2_indxs, :);
    output_data = vertcat(orig_data(1:2, :), output_data);
    
    [num_rows, num_cols] = size(output_data);
    sub_rows = length(sub_fpds);
    %cv_rows = length(c_vs);
        
    extra_rows = num_rows-sub_rows;
    
    append_fpd_empty = [];
    append_at_empty = [];
    append_amp_empty = [];
    append_sl_empty = [];
    for i = 1:extra_rows
        if i == 2
            append_fpd_empty = [append_fpd_empty; {'S2-S1 FPD (ms)'}];
            append_at_empty = [append_at_empty; {'S2-S1 Arrival Time (ms)'}];
            append_amp_empty = [append_amp_empty; {'S2-S1 Amplitude(mV)'}];
            append_sl_empty = [append_sl_empty; {'S2-S1 Spike Slope (V/s)'}];
        else
            append_fpd_empty = [append_fpd_empty; {''}];
            append_at_empty = [append_at_empty; {''}];
            append_amp_empty = [append_amp_empty; {''}];
            append_sl_empty = [append_sl_empty; {''}];
        end
    end
    
    sub_fpds = vertcat(append_fpd_empty, sub_fpds);
    sub_arrival_times = vertcat(append_at_empty, sub_arrival_times); 
    sub_amplitudes = vertcat(append_amp_empty, sub_amplitudes);
    sub_slopes = vertcat(append_sl_empty, sub_slopes); 
    
    output_data = horzcat(output_data, sub_fpds);
    output_data = horzcat(output_data, sub_arrival_times);
    output_data = horzcat(output_data, sub_amplitudes);
    output_data = horzcat(output_data, sub_slopes);
    
    %{
    %disp(beat_periods(S2_indxs))
    all_fpds = {};
    all_arrival_times = {};
    for S2_indx = length(S2_indxs):-1:1
        sub_fpds = [];
        sub_arrival_times = [];
        
        if S2_indx == 1
            for i = S2_indxs(S2_indx)-1:-1:2
                sub_fpds = [sub_fpds; {fpds(i)-fpds(i-1)}];
                sub_arrival_times = [sub_arrival_times; {arrival_times(i) - arrival_times(i-1)}];
            end
        elseif S2_indx == length(S2_indxs)
            for i = length(fpds):-1:S2_indxs(S2_indx)
                sub_fpds = [sub_fpds; {fpds(i)-fpds(i-1)}];
                sub_arrival_times = [sub_arrival_times; {arrival_times(i) - arrival_times(i-1)}];
            end
            
            for i = S2_indxs(S2_indx)-1:-1:S2_indxs(S2_indx-1)
                sub_fpds = [sub_fpds; {fpds(i)-fpds(i-1)}];
                sub_arrival_times = [sub_arrival_times; {arrival_times(i) - arrival_times(i-1)}];
            end
            
        else
            for i = S2_indxs(S2_indx)-1:-1:S2_indxs(S2_indx-1)
                sub_fpds = [sub_fpds; {fpds(i)-fpds(i-1)}];
                sub_arrival_times = [sub_arrival_times; {arrival_times(i) - arrival_times(i-1)}];
            end
        end
        all_fpds = vertcat(all_fpds, sub_fpds);
        all_arrival_times = vertcat(all_arrival_times, sub_arrival_times);
        
    end
    
    
    all_fpds = all_fpds(end:-1:1);
    all_arrival_times = all_arrival_times(end:-1:1);
    
    [num_rows, num_cols] = size(orig_data);
    sub_rows = length(all_fpds);
        
    extra_rows = num_rows-sub_rows;
    
    append_fpd_empty = [];
    append_at_empty = [];
    for i = 1:extra_rows
        if i == 2
            append_fpd_empty = [append_fpd_empty; {'S2-S1 FPD (ms)'}];
            append_at_empty = [append_at_empty; {'S2-S1 Arrival Time (ms)'}];
        else
            append_fpd_empty = [append_fpd_empty; {''}];
            append_at_empty = [append_at_empty; {''}];
        end
    end
    
    all_fpds = vertcat(append_fpd_empty, all_fpds);
    all_arrival_times = vertcat(append_at_empty, all_arrival_times); 
    
    orig_data = horzcat(orig_data, all_fpds);
    orig_data = horzcat(orig_data, all_arrival_times);
    %celldisp(orig_data(:, 14));
    disp(size(orig_data))
    %}
    
    
end


function [output_data] = analyse_synchronized(data, sync_i)
    numIdx = cellfun(@(x) ~isnan(str2double(x)), data);
    data(numIdx) = cellfun(@(x) {str2double(x)}, data(numIdx));
    
    orig_data = data;
    data = data(3:end, :);
    %celldisp(orig_data(1, :));
    beat_periods = cell2mat(data(:, 5));
    c_vs = cell2mat(data(:, 9));
    two_point_c_vs = cell2mat(data(:, 10));
    max_prop_delay = cell2mat(data(:, 11));
    
    
    bp_almost_one = isalmost(beat_periods, 1.0001, 0.0001);
    
    S2_indxs = [];
    for i = 2:length(bp_almost_one)
        if bp_almost_one(i) == 0 && bp_almost_one(i-1) == 1
            S2_indxs = [S2_indxs; i];
        end
    end
    
    %output_array = {};
    sub_cvs = [];
    sub_2point_cvs = [];
    sub_max_prop_delays = [];
    for S2_indx = 1:length(S2_indxs)
        row_num = S2_indxs(S2_indx);
        sub_cvs = [sub_cvs; {c_vs(row_num)-c_vs(row_num-1)}];
        sub_2point_cvs = [sub_2point_cvs; {two_point_c_vs(row_num) - two_point_c_vs(row_num-1)}];
        sub_max_prop_delays = [sub_max_prop_delays; {max_prop_delay(row_num) - max_prop_delay(row_num-1)}];
        
    end
    
    output_data = data(S2_indxs, :);
    output_data = vertcat(orig_data(1:2, :), output_data);
    
    [num_rows, num_cols] = size(output_data);
    sub_rows = length(sub_cvs);
    cv_rows = length(c_vs);
        
    extra_rows = num_rows-sub_rows;
    
    append_cv_empty = [];
    append_tp_empty = [];
    append_mp_empty = [];
    for i = 1:extra_rows
        if i == 2
            append_cv_empty = [append_cv_empty; {'S2-S1 Conduction Velocity (mm/ms)'}];
            append_tp_empty = [append_tp_empty; {'S2-S1 Two-Point Conduction Velocity (mm/ms)'}];
            append_mp_empty = [append_mp_empty; {'S2-S1 Maximum Propagation Delay (ms)'}];
        else
            append_cv_empty = [append_cv_empty; {''}];
            append_tp_empty = [append_tp_empty; {''}];
            append_mp_empty = [append_mp_empty; {''}];
        end
    end
    
    sub_cvs = vertcat(append_cv_empty, sub_cvs);
    sub_2point_cvs = vertcat(append_tp_empty, sub_2point_cvs);
    sub_max_prop_delays = vertcat(append_mp_empty, sub_max_prop_delays);   
    
    output_data = horzcat(output_data, sub_cvs);
    output_data = horzcat(output_data, sub_2point_cvs);
    output_data = horzcat(output_data, sub_max_prop_delays);
    
    %{
    all_sub_cvs = {};
    all_sub_2point_cvs = {};
    all_max_prop_delays = {};
    for S2_indx = length(S2_indxs):-1:1
        sub_c_vs = [];
        sub_two_point_c_vs = [];
        sub_max_prop_delay = [];
        disp(S2_indx)
        %disp(S2_indxs(S2_indx))
        if S2_indx == 1
            disp('start')
            for i = S2_indxs(S2_indx)-1:-1:2
                disp(strcat(num2str(i), '-', num2str(i-1)))
                sub_c_vs = [sub_c_vs; {c_vs(i)-c_vs(i-1)}];
                sub_two_point_c_vs = [sub_two_point_c_vs; {two_point_c_vs(i) - two_point_c_vs(i-1)}];
                sub_max_prop_delay = [sub_max_prop_delay; {max_prop_delay(i) - max_prop_delay(i-1)}];
            end
        elseif S2_indx == length(S2_indxs)
            disp('end')
            for i = length(c_vs):-1:S2_indxs(S2_indx)
                disp(strcat(num2str(i), '-', num2str(i-1)))
                sub_c_vs = [sub_c_vs; {c_vs(i)-c_vs(i-1)}];
                sub_two_point_c_vs = [sub_two_point_c_vs; {two_point_c_vs(i) - two_point_c_vs(i-1)}];
                sub_max_prop_delay = [sub_max_prop_delay; {max_prop_delay(i) - max_prop_delay(i-1)}];
            end
            
            for i = S2_indxs(S2_indx)-1:-1:S2_indxs(S2_indx-1)
                disp(strcat(num2str(i), '-', num2str(i-1)))
                sub_c_vs = [sub_c_vs; {c_vs(i)-c_vs(i-1)}];
                sub_two_point_c_vs = [sub_two_point_c_vs; {two_point_c_vs(i) - two_point_c_vs(i-1)}];
                sub_max_prop_delay = [sub_max_prop_delay; {max_prop_delay(i) - max_prop_delay(i-1)}];
            end
            
        else
            disp('middle')
            for i = S2_indxs(S2_indx)-1:-1:S2_indxs(S2_indx-1)
                disp(strcat(num2str(i), '-', num2str(i-1)))
                sub_c_vs = [sub_c_vs; {c_vs(i)-c_vs(i-1)}];
                sub_two_point_c_vs = [sub_two_point_c_vs; {two_point_c_vs(i) - two_point_c_vs(i-1)}];
                sub_max_prop_delay = [sub_max_prop_delay; {max_prop_delay(i) - max_prop_delay(i-1)}];
            end
        end
        %disp(sub_c_vs)
        all_sub_cvs = vertcat(all_sub_cvs, sub_c_vs);
        all_sub_2point_cvs = vertcat(all_sub_2point_cvs, sub_two_point_c_vs);
        all_max_prop_delays = vertcat(all_max_prop_delays, sub_max_prop_delay);
        
    end
    
    
    all_sub_cvs = all_sub_cvs(end:-1:1);
    all_sub_2point_cvs = all_sub_2point_cvs(end:-1:1);
    all_max_prop_delays = all_max_prop_delays(end:-1:1);
    
    [num_rows, num_cols] = size(orig_data);
    sub_rows = length(all_sub_cvs);
    cv_rows = length(c_vs);
        
    extra_rows = num_rows-sub_rows;
    
    append_cv_empty = [];
    append_tp_empty = [];
    append_mp_empty = [];
    for i = 1:extra_rows
        if i == 2
            append_cv_empty = [append_cv_empty; {'S2-S1 Conduction Velocity (mm/ms)'}];
            append_tp_empty = [append_tp_empty; {'S2-S1 Two-Point Conduction Velocity (mm/ms)'}];
            append_mp_empty = [append_mp_empty; {'S2-S1 Maximum Propagation Delay (ms)'}];
        else
            append_cv_empty = [append_cv_empty; {''}];
            append_tp_empty = [append_tp_empty; {''}];
            append_mp_empty = [append_mp_empty; {''}];
        end
    end
    
    all_sub_cvs = vertcat(append_cv_empty, all_sub_cvs);
    all_sub_2point_cvs = vertcat(append_tp_empty, all_sub_2point_cvs);
    all_max_prop_delays = vertcat(append_mp_empty, all_max_prop_delays);   
    
    orig_data = horzcat(orig_data, all_sub_cvs);
    orig_data = horzcat(orig_data, all_sub_2point_cvs);
    orig_data = horzcat(orig_data, all_max_prop_delays);
    
    %celldisp(orig_data)
    %}
end