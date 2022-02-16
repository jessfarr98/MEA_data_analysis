function [well_electrode_data] = remove_selected_beats(well_electrode_data, electrode_count, num_electrode_rows, num_electrode_cols, well_elec_fig, elec_ax, spon_paced, beat_to_beat, analyse_all_b2b, stable_ave_analysis, reanalyse_time_region_start, reanalyse_time_region_end, start_indx, end_indx, reanalyse_beat_fig)
  
    set(well_elec_fig, 'visible', 'off')
    close(reanalyse_beat_fig);
    
    
    electrode_data = well_electrode_data.electrode_data;

    if start_indx ~=1
        if end_indx ~= electrode_data(electrode_count).beat_num_array(end)
            
            electrode_data(electrode_count).beat_num_array = [electrode_data(electrode_count).beat_num_array(1:start_indx-1) (electrode_data(electrode_count).beat_num_array(end_indx:end))-start_indx];

            electrode_data(electrode_count).cycle_length_array = [electrode_data(electrode_count).cycle_length_array(1:start_indx-1) electrode_data(electrode_count).cycle_length_array(end_indx:end)];
            electrode_data(electrode_count).activation_times = [electrode_data(electrode_count).activation_times(1:start_indx-1) electrode_data(electrode_count).activation_times(end_indx:end)];
            electrode_data(electrode_count).activation_point_array = [electrode_data(electrode_count).activation_point_array(1:start_indx-1) electrode_data(electrode_count).activation_point_array(end_indx:end)];
            electrode_data(electrode_count).beat_start_times = [electrode_data(electrode_count).beat_start_times(1:start_indx-1) electrode_data(electrode_count).beat_start_times(end_indx:end)];
            electrode_data(electrode_count).beat_start_volts = [electrode_data(electrode_count).beat_start_volts(1:start_indx-1) electrode_data(electrode_count).beat_start_volts(end_indx:end)];
            electrode_data(electrode_count).beat_periods = [electrode_data(electrode_count).beat_periods(1:start_indx-1) electrode_data(electrode_count).beat_periods(end_indx:end)];
            electrode_data(electrode_count).t_wave_peak_times = [electrode_data(electrode_count).t_wave_peak_times(1:start_indx-1) electrode_data(electrode_count).t_wave_peak_times(end_indx:end)];

            electrode_data(electrode_count).t_wave_peak_array = [electrode_data(electrode_count).t_wave_peak_array(1:start_indx-1) electrode_data(electrode_count).t_wave_peak_array(end_indx:end)];
            electrode_data(electrode_count).max_depol_time_array = [electrode_data(electrode_count).max_depol_time_array(1:start_indx-1) electrode_data(electrode_count).max_depol_time_array(end_indx:end)];
            electrode_data(electrode_count).min_depol_time_array = [electrode_data(electrode_count).min_depol_time_array(1:start_indx-1) electrode_data(electrode_count).min_depol_time_array(end_indx:end)];
            electrode_data(electrode_count).max_depol_point_array = [electrode_data(electrode_count).max_depol_point_array(1:start_indx-1) electrode_data(electrode_count).max_depol_point_array(end_indx:end)];
            electrode_data(electrode_count).min_depol_point_array = [electrode_data(electrode_count).min_depol_point_array(1:start_indx-1) electrode_data(electrode_count).min_depol_point_array(end_indx:end)];
            electrode_data(electrode_count).depol_slope_array = [electrode_data(electrode_count).depol_slope_array(1:start_indx-1) electrode_data(electrode_count).depol_slope_array(end_indx:end)];
            electrode_data(electrode_count).warning_array = [electrode_data(electrode_count).warning_array(1:start_indx-1) electrode_data(electrode_count).warning_array(end_indx:end)];

            
            %[electrode_data(electrode_count).Stims(1:start_indx-1)] = size();
            
            if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                replot_stims = [electrode_data(electrode_count).Stims(1:start_indx-1) electrode_data(electrode_count).Stims(end_indx:end)];
                %disp(electrode_data(electrode_count).Stim_volts(1:start_indx-1))
                replot_stim_volts = [electrode_data(electrode_count).Stim_volts(1:start_indx-1); electrode_data(electrode_count).Stim_volts(end_indx:end)];

            end
        else
            
            electrode_data(electrode_count).beat_num_array = electrode_data(electrode_count).beat_num_array(1:start_indx-1);

            electrode_data(electrode_count).cycle_length_array = electrode_data(electrode_count).cycle_length_array(1:start_indx-1);
            electrode_data(electrode_count).activation_times = electrode_data(electrode_count).activation_times(1:start_indx-1);
            electrode_data(electrode_count).activation_point_array = electrode_data(electrode_count).activation_point_array(1:start_indx-1);
            electrode_data(electrode_count).beat_start_times = electrode_data(electrode_count).beat_start_times(1:start_indx-1);
            electrode_data(electrode_count).beat_start_volts = electrode_data(electrode_count).beat_start_volts(1:start_indx-1);
            electrode_data(electrode_count).beat_periods = electrode_data(electrode_count).beat_periods(1:start_indx-1);
            electrode_data(electrode_count).t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times(1:start_indx-1);

            electrode_data(electrode_count).t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array(1:start_indx-1);
            electrode_data(electrode_count).max_depol_time_array = electrode_data(electrode_count).max_depol_time_array(1:start_indx-1);
            electrode_data(electrode_count).min_depol_time_array = electrode_data(electrode_count).min_depol_time_array(1:start_indx-1);
            electrode_data(electrode_count).max_depol_point_array = electrode_data(electrode_count).max_depol_point_array(1:start_indx-1);
            electrode_data(electrode_count).min_depol_point_array = electrode_data(electrode_count).min_depol_point_array(1:start_indx-1);
            electrode_data(electrode_count).depol_slope_array = electrode_data(electrode_count).depol_slope_array(1:start_indx-1);
            electrode_data(electrode_count).warning_array = electrode_data(electrode_count).warning_array(1:start_indx-1);

            if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                replot_stims = electrode_data(electrode_count).Stims(1:start_indx-1);
                replot_stim_volts = electrode_data(electrode_count).Stim_volts(1:start_indx-1);

            end
            
            
        end
    else
        if end_indx ~= electrode_data(electrode_count).beat_num_array(end)
            electrode_data(electrode_count).beat_num_array = (electrode_data(electrode_count).beat_num_array(end_indx:end))-start_indx;

            electrode_data(electrode_count).cycle_length_array = electrode_data(electrode_count).cycle_length_array(end_indx:end);
            electrode_data(electrode_count).activation_times = electrode_data(electrode_count).activation_times(end_indx:end);
            electrode_data(electrode_count).activation_point_array =  electrode_data(electrode_count).activation_point_array(end_indx:end);
            electrode_data(electrode_count).beat_start_times = electrode_data(electrode_count).beat_start_times(end_indx:end);
            electrode_data(electrode_count).beat_start_volts = electrode_data(electrode_count).beat_start_volts(end_indx:end);
            electrode_data(electrode_count).beat_periods = electrode_data(electrode_count).beat_periods(end_indx:end);
            electrode_data(electrode_count).t_wave_peak_times =  electrode_data(electrode_count).t_wave_peak_times(end_indx:end);

            electrode_data(electrode_count).t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array(end_indx:end);
            electrode_data(electrode_count).max_depol_time_array = electrode_data(electrode_count).max_depol_time_array(end_indx:end);
            electrode_data(electrode_count).min_depol_time_array = electrode_data(electrode_count).min_depol_time_array(end_indx:end);
            electrode_data(electrode_count).max_depol_point_array = electrode_data(electrode_count).max_depol_point_array(end_indx:end);
            electrode_data(electrode_count).min_depol_point_array = electrode_data(electrode_count).min_depol_point_array(end_indx:end);
            electrode_data(electrode_count).depol_slope_array = electrode_data(electrode_count).depol_slope_array(end_indx:end);
            electrode_data(electrode_count).warning_array = electrode_data(electrode_count).warning_array(end_indx:end);

            if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                replot_stims = electrode_data(electrode_count).Stims(end_indx:end);
                replot_stim_volts = electrode_data(electrode_count).Stim_volts(end_indx:end);

            end
        
        else
            electrode_data(electrode_count).beat_num_array = [];

            electrode_data(electrode_count).cycle_length_array = [];
            electrode_data(electrode_count).activation_times = [];
            electrode_data(electrode_count).activation_point_array = [];
            electrode_data(electrode_count).beat_start_times = [];
            electrode_data(electrode_count).beat_start_volts = [];
            electrode_data(electrode_count).beat_periods = [];
            electrode_data(electrode_count).t_wave_peak_times = [];

            electrode_data(electrode_count).t_wave_peak_array = [];
            electrode_data(electrode_count).max_depol_time_array = [];
            electrode_data(electrode_count).min_depol_time_array = [];
            electrode_data(electrode_count).max_depol_point_array = [];
            electrode_data(electrode_count).min_depol_point_array = [];
            electrode_data(electrode_count).depol_slope_array =[];
            electrode_data(electrode_count).warning_array = [];

            if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                replot_stims = [];
                replot_stim_volts = [];
            end
            
            
        end
    end
        
        
    cla(elec_ax);
    hold(elec_ax, 'on')

    if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
        num_beats = length(replot_stims);
    else

        num_beats = length(electrode_data(electrode_count).beat_start_times);
    end

    if num_beats > 4    

        mid_beat = floor(num_beats/2);
        %elec_ax.XLim = [electrode_data(electrode_count).beat_start_times(mid_beat) electrode_data(electrode_count).beat_start_times(mid_beat+1)];

        if strcmp(spon_paced, 'paced')
            time_start = electrode_data(electrode_count).Stims(mid_beat);
            time_end = electrode_data(electrode_count).Stims(mid_beat+1);

            time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
            time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);
            %plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).Stims, well_electrode_data(well_count).electrode_data(electrode_count).Stim_volts, 'mo');

            plot(elec_ax, electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));


            plot(elec_ax, electrode_data(electrode_count).Stims(mid_beat), electrode_data(electrode_count).Stim_volts(mid_beat), 'm.', 'MarkerSize', 20);

        elseif strcmp(spon_paced, 'paced bdt')
            time_start = ectopic_plus_stims(mid_beat);
            time_end = ectopic_plus_stims(mid_beat+1);

            time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
            time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);


            plot(elec_ax, electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

            if ismember(electrode_data(electrode_count).beat_start_times , time_start)
                plot(elec_ax, ectopic_plus_stims(mid_beat), electrode_data(electrode_count).data(time_reg_start_indx(1)), 'g.', 'MarkerSize', 20);

            else
                plot(elec_ax, ectopic_plus_stims(mid_beat), electrode_data(electrode_count).data(time_reg_start_indx(1)), 'm.', 'MarkerSize', 20);

            end
        else
            if electrode_data(electrode_count).bdt < 0
                time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-electrode_data(electrode_count).post_spike_hold_off;

            else
                time_start = electrode_data(electrode_count).beat_start_times(mid_beat);

            end
            %time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
            time_end = electrode_data(electrode_count).beat_start_times(mid_beat+1);

            time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
            time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);


            plot(elec_ax, electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

            plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat),  electrode_data(electrode_count).data(time_reg_start_indx(1)), 'g.', 'MarkerSize', 20);

        end



        t_wave_indx = find(electrode_data(electrode_count).t_wave_peak_times >= time_start);
        t_wave_indx = t_wave_indx(1);
        t_wave_peak_time = electrode_data(electrode_count).t_wave_peak_times(t_wave_indx);
        t_wave_p = electrode_data(electrode_count).t_wave_peak_array(t_wave_indx);
        if ~isnan(t_wave_peak_time) && ~isnan(t_wave_p)
            plot(elec_ax, t_wave_peak_time, t_wave_p, 'c.', 'MarkerSize', 20);
        end

        max_depol_indx = find(electrode_data(electrode_count).max_depol_time_array >= time_start);
        max_depol_indx = max_depol_indx(1);

        min_depol_indx = find(electrode_data(electrode_count).min_depol_time_array >= time_start);
        min_depol_indx = min_depol_indx(1);
        plot(elec_ax, electrode_data(electrode_count).max_depol_time_array(max_depol_indx), electrode_data(electrode_count).max_depol_point_array(max_depol_indx), 'r.', 'MarkerSize', 20);
        plot(elec_ax, electrode_data(electrode_count).min_depol_time_array(min_depol_indx), electrode_data(electrode_count).min_depol_point_array(min_depol_indx), 'b.', 'MarkerSize', 20);


        act_indx = find(electrode_data(electrode_count).activation_times >= time_start);
        act_indx = act_indx(1);
        plot(elec_ax, electrode_data(electrode_count).activation_times(act_indx), electrode_data(electrode_count).activation_point_array(act_indx), 'k.', 'MarkerSize', 20);


    else
        plot(elec_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);

        t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
        t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
        t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
        t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
        plot(elec_ax, t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
        plot(elec_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
        plot(elec_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

        %[~, beat_start_volts, ~] = intersect(well_electrode_data(well_count).electrode_data(electrode_count).time, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
        %beat_start_volts = well_electrode_data(well_count).electrode_data(electrode_count).data(beat_start_volts);


        if strcmp(spon_paced, 'paced')

            plot(elec_ax, electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);

        elseif strcmp(spon_paced, 'paced bdt')
            plot(elec_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
            plot(elec_ax, electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);

        else
            plot(elec_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);

        end
        %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');

        plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'k.', 'MarkerSize', 20);

        % Zoom in on beat in the middle
    end

    hold(elec_ax,'off')

    [electrode_data(electrode_count).arrhythmia_indx, electrode_data(electrode_count).warning_array] = arrhythmia_analysis(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).warning_array);
                

    well_electrode_data.electrode_data = electrode_data;
    if strcmp(spon_paced, 'spon')
        [well_electrode_data.conduction_velocity, well_electrode_data.conduction_velocity_model] = calculateSpontaneousConductionVelocity(electrode_data,  num_electrode_rows, num_electrode_cols);
    
    else
        [well_electrode_data.conduction_velocity, well_electrode_data.conduction_velocity_model] = calculatePacedConductionVelocity(electrode_data,  num_electrode_rows, num_electrode_cols);
    
    end
    set(well_elec_fig, 'visible', 'on')
end