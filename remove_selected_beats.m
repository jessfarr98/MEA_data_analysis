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
            electrode_data(electrode_count).beat_periods = [electrode_data(electrode_count).beat_periods(1:start_indx-1) electrode_data(electrode_count).beat_periods(end_indx:end)];
            electrode_data(electrode_count).t_wave_peak_times = [electrode_data(electrode_count).t_wave_peak_times(1:start_indx-1) electrode_data(electrode_count).t_wave_peak_times(end_indx:end)];

            electrode_data(electrode_count).t_wave_peak_array = [electrode_data(electrode_count).t_wave_peak_array(1:start_indx-1) electrode_data(electrode_count).t_wave_peak_array(end_indx:end)];
            electrode_data(electrode_count).max_depol_time_array = [electrode_data(electrode_count).max_depol_time_array(1:start_indx-1) electrode_data(electrode_count).max_depol_time_array(end_indx:end)];
            electrode_data(electrode_count).min_depol_time_array = [electrode_data(electrode_count).min_depol_time_array(1:start_indx-1) electrode_data(electrode_count).min_depol_time_array(end_indx:end)];
            electrode_data(electrode_count).max_depol_point_array = [electrode_data(electrode_count).max_depol_point_array(1:start_indx-1) electrode_data(electrode_count).max_depol_point_array(end_indx:end)];
            electrode_data(electrode_count).min_depol_point_array = [electrode_data(electrode_count).min_depol_point_array(1:start_indx-1) electrode_data(electrode_count).min_depol_point_array(end_indx:end)];
            electrode_data(electrode_count).depol_slope_array = [electrode_data(electrode_count).depol_slope_array(1:start_indx-1) electrode_data(electrode_count).depol_slope_array(end_indx:end)];
            electrode_data(electrode_count).warning_array = [electrode_data(electrode_count).warning_array(1:start_indx-1) electrode_data(electrode_count).warning_array(end_indx:end)];

            if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                replot_stims = [electrode_data(electrode_count).Stims(1:start_indx-1) electrode_data(electrode_count).Stims(end_indx:end)];
                replot_stim_volts = [electrode_data(electrode_count).Stim_volts(1:start_indx-1) electrode_data(electrode_count).Stim_volts(end_indx:end)];

            end
        else
            
            electrode_data(electrode_count).beat_num_array = electrode_data(electrode_count).beat_num_array(1:start_indx-1);

            electrode_data(electrode_count).cycle_length_array = electrode_data(electrode_count).cycle_length_array(1:start_indx-1);
            electrode_data(electrode_count).activation_times = electrode_data(electrode_count).activation_times(1:start_indx-1);
            electrode_data(electrode_count).activation_point_array = electrode_data(electrode_count).activation_point_array(1:start_indx-1);
            electrode_data(electrode_count).beat_start_times = electrode_data(electrode_count).beat_start_times(1:start_indx-1);
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

        if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
            time_start = replot_stims(mid_beat);
            time_end = replot_stims(mid_beat+1);

            time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
            time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);
            %plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).Stims, well_electrode_data(well_count).electrode_data(electrode_count).Stim_volts, 'mo');

            plot(elec_ax, electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));


            plot(elec_ax, replot_stims(mid_beat), replot_stim_volts(mid_beat), 'mo');

        elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
            time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
            time_end = electrode_data(electrode_count).beat_start_times(mid_beat+1);

            time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
            time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);


            plot(elec_ax, electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

            plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat), electrode_data(electrode_count).data(time_reg_start_indx(1)), 'go');

        else
            time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
            time_end = electrode_data(electrode_count).beat_start_times(mid_beat+1);

            time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
            time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);


            plot(elec_ax,electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

            plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat),electrode_data(electrode_count).data(time_reg_start_indx(1)), 'go');

        end



        t_wave_peak_time = electrode_data(electrode_count).t_wave_peak_times(mid_beat);
        t_wave_p = electrode_data(electrode_count).t_wave_peak_array(mid_beat);
        if ~isnan(t_wave_peak_time) && ~isnan(t_wave_p)
            plot(elec_ax, t_wave_peak_time, t_wave_p, 'co');
        end
        plot(elec_ax, electrode_data(electrode_count).max_depol_time_array(mid_beat), electrode_data(electrode_count).max_depol_point_array(mid_beat), 'ro');
        plot(elec_ax, electrode_data(electrode_count).min_depol_time_array(mid_beat), electrode_data(electrode_count).min_depol_point_array(mid_beat), 'bo');

        %plot(elec_ax, well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times(mid_beat), well_electrode_data(well_count).electrode_data(electrode_count).data(time_reg_start_indx(1)), 'go');


        %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
        plot(elec_ax, electrode_data(electrode_count).activation_times(mid_beat), electrode_data(electrode_count).activation_point_array(mid_beat), 'ko');


    else
        plot(elec_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);

        t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
        t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
        t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
        t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
        plot(elec_ax, t_wave_peak_times, t_wave_peak_array, 'co');
        plot(elec_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'ro');
        plot(elec_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'bo');

        [~, beat_start_volts, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
        beat_start_volts = electrode_data(electrode_count).data(beat_start_volts);


        if strcmp(electrode_data(electrode_count).spon_paced, 'paced')

            plot(elec_ax, replot_stims, replot_stim_volts, 'mo');

        elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
            plot(elec_ax, electrode_data(electrode_count).beat_start_times, beat_start_volts, 'go');
            plot(elec_ax, electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'mo');

        else
            plot(elec_ax, electrode_data(electrode_count).beat_start_times, beat_start_volts, 'go');



        end
        %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');

        plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'ko');

        % Zoom in on beat in the middle

    end

    hold(elec_ax,'off')


    well_electrode_data.electrode_data = electrode_data;
    well_electrode_data.conduction_velocity = calculateConductionVelocity(electrode_data,  num_electrode_rows, num_electrode_cols);
    
    set(well_elec_fig, 'visible', 'on')
end