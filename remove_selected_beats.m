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
            
            electrode_data(electrode_count).beat_periods = [electrode_data(electrode_count).beat_periods(1:start_indx-1) electrode_data(electrode_count).beat_periods(end_indx:end)];
            electrode_data(electrode_count).t_wave_peak_times = [electrode_data(electrode_count).t_wave_peak_times(1:start_indx-1) electrode_data(electrode_count).t_wave_peak_times(end_indx:end)];

            electrode_data(electrode_count).t_wave_peak_array = [electrode_data(electrode_count).t_wave_peak_array(1:start_indx-1) electrode_data(electrode_count).t_wave_peak_array(end_indx:end)];
            electrode_data(electrode_count).max_depol_time_array = [electrode_data(electrode_count).max_depol_time_array(1:start_indx-1) electrode_data(electrode_count).max_depol_time_array(end_indx:end)];
            electrode_data(electrode_count).min_depol_time_array = [electrode_data(electrode_count).min_depol_time_array(1:start_indx-1) electrode_data(electrode_count).min_depol_time_array(end_indx:end)];
            electrode_data(electrode_count).max_depol_point_array = [electrode_data(electrode_count).max_depol_point_array(1:start_indx-1) electrode_data(electrode_count).max_depol_point_array(end_indx:end)];
            electrode_data(electrode_count).min_depol_point_array = [electrode_data(electrode_count).min_depol_point_array(1:start_indx-1) electrode_data(electrode_count).min_depol_point_array(end_indx:end)];
            electrode_data(electrode_count).depol_slope_array = [electrode_data(electrode_count).depol_slope_array(1:start_indx-1) electrode_data(electrode_count).depol_slope_array(end_indx:end)];
            electrode_data(electrode_count).warning_array = [electrode_data(electrode_count).warning_array(1:start_indx-1) electrode_data(electrode_count).warning_array(end_indx:end)];

            electrode_data(electrode_count).t_wave_wavelet_array = [electrode_data(electrode_count).t_wave_wavelet_array(1:start_indx-1) electrode_data(electrode_count).t_wave_wavelet_array(end_indx:end)];
            electrode_data(electrode_count).t_wave_polynomial_degree_array = [electrode_data(electrode_count).t_wave_polynomial_degree_array(1:start_indx-1) electrode_data(electrode_count).t_wave_polynomial_degree_array(end_indx:end)];

            %[electrode_data(electrode_count).Stims(1:start_indx-1)] = size();
            
            if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                replot_stims = [electrode_data(electrode_count).Stims(1:start_indx-1) electrode_data(electrode_count).Stims(end_indx:end)];
                %disp(electrode_data(electrode_count).Stim_volts(1:start_indx-1))
                replot_stim_volts = [electrode_data(electrode_count).Stim_volts(1:start_indx-1) electrode_data(electrode_count).Stim_volts(end_indx:end)];

            else
                electrode_data(electrode_count).beat_start_times = [electrode_data(electrode_count).beat_start_times(1:start_indx-1) electrode_data(electrode_count).beat_start_times(end_indx:end)];
                electrode_data(electrode_count).beat_start_volts = [electrode_data(electrode_count).beat_start_volts(1:start_indx-1) electrode_data(electrode_count).beat_start_volts(end_indx:end)];

            end
        else
            
            electrode_data(electrode_count).beat_num_array = electrode_data(electrode_count).beat_num_array(1:start_indx-1);

            electrode_data(electrode_count).cycle_length_array = electrode_data(electrode_count).cycle_length_array(1:start_indx-1);
            electrode_data(electrode_count).activation_times = electrode_data(electrode_count).activation_times(1:start_indx-1);
            electrode_data(electrode_count).activation_point_array = electrode_data(electrode_count).activation_point_array(1:start_indx-1);
            
            electrode_data(electrode_count).beat_periods = electrode_data(electrode_count).beat_periods(1:start_indx-1);
            electrode_data(electrode_count).t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times(1:start_indx-1);

            electrode_data(electrode_count).t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array(1:start_indx-1);
            electrode_data(electrode_count).max_depol_time_array = electrode_data(electrode_count).max_depol_time_array(1:start_indx-1);
            electrode_data(electrode_count).min_depol_time_array = electrode_data(electrode_count).min_depol_time_array(1:start_indx-1);
            electrode_data(electrode_count).max_depol_point_array = electrode_data(electrode_count).max_depol_point_array(1:start_indx-1);
            electrode_data(electrode_count).min_depol_point_array = electrode_data(electrode_count).min_depol_point_array(1:start_indx-1);
            electrode_data(electrode_count).depol_slope_array = electrode_data(electrode_count).depol_slope_array(1:start_indx-1);
            electrode_data(electrode_count).warning_array = electrode_data(electrode_count).warning_array(1:start_indx-1);
            electrode_data(electrode_count).t_wave_wavelet_array = electrode_data(electrode_count).t_wave_wavelet_array(1:start_indx-1);
            electrode_data(electrode_count).t_wave_polynomial_degree_array = electrode_data(electrode_count).t_wave_polynomial_degree_array(1:start_indx-1);


            
            if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                replot_stims = electrode_data(electrode_count).Stims(1:start_indx-1);
                replot_stim_volts = electrode_data(electrode_count).Stim_volts(1:start_indx-1);
            else
                electrode_data(electrode_count).beat_start_times = electrode_data(electrode_count).beat_start_times(1:start_indx-1);
                electrode_data(electrode_count).beat_start_volts = electrode_data(electrode_count).beat_start_volts(1:start_indx-1);
                
            end
            
            
        end
    else
        if end_indx ~= electrode_data(electrode_count).beat_num_array(end)
            electrode_data(electrode_count).beat_num_array = (electrode_data(electrode_count).beat_num_array(end_indx:end))-start_indx;

            electrode_data(electrode_count).cycle_length_array = electrode_data(electrode_count).cycle_length_array(end_indx:end);
            electrode_data(electrode_count).activation_times = electrode_data(electrode_count).activation_times(end_indx:end);
            electrode_data(electrode_count).activation_point_array =  electrode_data(electrode_count).activation_point_array(end_indx:end);
            
            electrode_data(electrode_count).beat_periods = electrode_data(electrode_count).beat_periods(end_indx:end);
            electrode_data(electrode_count).t_wave_peak_times =  electrode_data(electrode_count).t_wave_peak_times(end_indx:end);

            electrode_data(electrode_count).t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array(end_indx:end);
            electrode_data(electrode_count).max_depol_time_array = electrode_data(electrode_count).max_depol_time_array(end_indx:end);
            electrode_data(electrode_count).min_depol_time_array = electrode_data(electrode_count).min_depol_time_array(end_indx:end);
            electrode_data(electrode_count).max_depol_point_array = electrode_data(electrode_count).max_depol_point_array(end_indx:end);
            electrode_data(electrode_count).min_depol_point_array = electrode_data(electrode_count).min_depol_point_array(end_indx:end);
            electrode_data(electrode_count).depol_slope_array = electrode_data(electrode_count).depol_slope_array(end_indx:end);
            electrode_data(electrode_count).warning_array = electrode_data(electrode_count).warning_array(end_indx:end);
            electrode_data(electrode_count).t_wave_wavelet_array = electrode_data(electrode_count).t_wave_wavelet_array(end_indx:end);
            electrode_data(electrode_count).t_wave_polynomial_degree_array = electrode_data(electrode_count).t_wave_polynomial_degree_array(end_indx:end);

            if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                replot_stims = electrode_data(electrode_count).Stims(end_indx:end);
                replot_stim_volts = electrode_data(electrode_count).Stim_volts(end_indx:end);
            else
                electrode_data(electrode_count).beat_start_times = electrode_data(electrode_count).beat_start_times(end_indx:end);
                electrode_data(electrode_count).beat_start_volts = electrode_data(electrode_count).beat_start_volts(end_indx:end);
                
            end
        
        else
            electrode_data(electrode_count).beat_num_array = [];

            electrode_data(electrode_count).cycle_length_array = [];
            electrode_data(electrode_count).activation_times = [];
            electrode_data(electrode_count).activation_point_array = [];
            
            electrode_data(electrode_count).beat_periods = [];
            electrode_data(electrode_count).t_wave_peak_times = [];

            electrode_data(electrode_count).t_wave_peak_array = [];
            electrode_data(electrode_count).max_depol_time_array = [];
            electrode_data(electrode_count).min_depol_time_array = [];
            electrode_data(electrode_count).max_depol_point_array = [];
            electrode_data(electrode_count).min_depol_point_array = [];
            electrode_data(electrode_count).depol_slope_array =[];
            electrode_data(electrode_count).warning_array = [];
            electrode_data(electrode_count).t_wave_wavelet_array = [];
            electrode_data(electrode_count).t_wave_polynomial_degree_array = [];

            if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
                replot_stims = [];
                replot_stim_volts = [];
            else
                electrode_data(electrode_count).beat_start_times = [];
                electrode_data(electrode_count).beat_start_volts = [];
                
            end
            
            
        end
    end
    
    start_plot_indx = find(electrode_data(electrode_count).time >= reanalyse_time_region_start);
    start_plot_indx = start_plot_indx(1);
    end_plot_indx = find(electrode_data(electrode_count).time >= reanalyse_time_region_end);
    end_plot_indx = end_plot_indx(1);
    
    filtered_start_indx = find(electrode_data(electrode_count).filtered_time >= electrode_data(electrode_count).time(start_plot_indx));
    
    
    filtered_end_indx = find(electrode_data(electrode_count).filtered_time <= electrode_data(electrode_count).time(end_plot_indx));
    
    
    
    
    if ~isempty(filtered_start_indx)
        if ~isempty(filtered_end_indx)
            filtered_start_indx = filtered_start_indx(1);
            filtered_end_indx = filtered_end_indx(end);
    
            
            
            [otr, otc] = size(electrode_data(electrode_count).filtered_time);

            [odr, odc] = size(electrode_data(electrode_count).filtered_data);

            if otc ~= 1
                electrode_data(electrode_count).filtered_time = reshape(electrode_data(electrode_count).filtered_time, [otc, otr]);

            end

            if odc ~= 1
                electrode_data(electrode_count).filtered_data = reshape(electrode_data(electrode_count).filtered_data, [odc, odr]);

            end


            if filtered_start_indx ~= 1

                if end_plot_indx ~= length(electrode_data(electrode_count).filtered_data)
                    electrode_data(electrode_count).filtered_time = [electrode_data(electrode_count).filtered_time(1:filtered_start_indx-1); electrode_data(electrode_count).filtered_time(filtered_end_indx+1:end)];
                    electrode_data(electrode_count).filtered_data = [electrode_data(electrode_count).filtered_data(1:filtered_start_indx-1); electrode_data(electrode_count).filtered_data(filtered_end_indx+1:end)];

                else
                    electrode_data(electrode_count).filtered_time = electrode_data(electrode_count).filtered_time(1:filtered_start_indx-1);
                    electrode_data(electrode_count).filtered_data = electrode_data(electrode_count).filtered_data(1:filtered_start_indx-1);

                end
            else
                if end_plot_indx ~= length(electrode_data(electrode_count).filtered_data)

                    electrode_data(electrode_count).filtered_time = electrode_data(electrode_count).filtered_time(filtered_end_indx+1:end);
                    electrode_data(electrode_count).filtered_data = electrode_data(electrode_count).filtered_data(filtered_end_indx+1:end);

                else
                    electrode_data(electrode_count).filtered_time = [];
                    electrode_data(electrode_count).filtered_data = [];

                end

            end
        else
            electrode_data(electrode_count).filtered_time = [];
            electrode_data(electrode_count).filtered_data = [];
        end
    else
        if isempty(filtered_end_indx)
            electrode_data(electrode_count).filtered_time = [];
            electrode_data(electrode_count).filtered_data = [];
            
        end
    end
        
    cla(elec_ax);
    hold(elec_ax, 'on')

    if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
        num_beats = length(electrode_data(electrode_count).Stims);
    elseif strcmp(electrode_data(electrode_count).spon_paced, 'spon')

        num_beats = length(electrode_data(electrode_count).beat_start_times);
    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
        %num_beats = length(well_electrode_data(well_count).electrode_data(electrode_count).beat_start_times);
        [sr, sc] = size(electrode_data(electrode_count).Stims);
        [br, bc] = size(electrode_data(electrode_count).beat_start_times);

        if bc == 1 && sc ~= 1
            electrode_data(electrode_count).beat_start_times = reshape(electrode_data(electrode_count).beat_start_times, [bc br]);
        end
        if sc == 1 && bc ~= 1
            electrode_data(electrode_count).beat_start_times = reshape(electrode_data(electrode_count).beat_start_times, [bc br]);
        end
        try 
            ectopic_plus_stims = [electrode_data(electrode_count).beat_start_times electrode_data(electrode_count).Stims];
        catch
            ectopic_plus_stims = [electrode_data(electrode_count).beat_start_times; electrode_data(electrode_count).Stims];

        end
        ectopic_plus_stims = sort(ectopic_plus_stims);
        ectopic_plus_stims = uniquetol(ectopic_plus_stims);
        num_beats = length(ectopic_plus_stims);
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

        elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
            time_start = ectopic_plus_stims(mid_beat);
            time_end = ectopic_plus_stims(mid_beat+1);



            if ismember(electrode_data(electrode_count).beat_start_times , time_start)
                beat_warning = electrode_data(electrode_count).warning_array{mid_beat};
                if ~isempty(beat_warning)
                    beat_warning = beat_warning{1};
                end

                if contains(beat_warning, 'Reanalysed')
                    split_one = strsplit(beat_warning, 'BDT=');
                    split_two = strsplit(split_one{1, 2}, ',');
                    reanalysed_bdt = str2num(split_two{1});

                    if reanalysed_bdt < 0
                       postspike_tag = split_two{2};
                       split_postspike = strsplit(postspike_tag, '=');
                       re_analysed_post_spike = str2num(split_postspike{2});
                       post_spike_subtracted = re_analysed_post_spike;
                       time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-re_analysed_post_spike;

                       if time_start < electrode_data(electrode_count).time(1)
                           time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
                       end

                    else
                        %time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
                        if electrode_data(electrode_count).beat_start_times(mid_beat) - electrode_data(electrode_count).post_spike_hold_off > electrode_data(electrode_count).time(1)

                            time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-electrode_data(electrode_count).post_spike_hold_off;
                        else

                            time_start = electrode_data(electrode_count).beat_start_times(mid_beat);

                        end 

                    end

                else
                    %time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
                    if electrode_data(electrode_count).beat_start_times(mid_beat) - electrode_data(electrode_count).post_spike_hold_off > electrode_data(electrode_count).time(1)

                        time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-electrode_data(electrode_count).post_spike_hold_off;
                    else

                        time_start = electrode_data(electrode_count).beat_start_times(mid_beat);

                    end 

                end
                time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
                time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);

                filtered_time_reg_start_indx = find(electrode_data(electrode_count).filtered_time >= time_start);
                filtered_time_reg_end_indx = find(electrode_data(electrode_count).filtered_time >= time_end);

                

                plot(elec_ax,electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

                if ~isempty(filtered_time_reg_start_indx)
                    plot(elec_ax,electrode_data(electrode_count).filtered_time(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)), electrode_data(electrode_count).filtered_data(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)));
                end

                plot(elec_ax, ectopic_plus_stims(mid_beat), electrode_data(electrode_count).data(time_reg_start_indx(1)), 'g.', 'MarkerSize', 20);

            else
                time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
                time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);

                filtered_time_reg_start_indx = find(electrode_data(electrode_count).filtered_time >= time_start);
                filtered_time_reg_end_indx = find(electrode_data(electrode_count).filtered_time >= time_end);


                plot(elec_ax,electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

                if ~isempty(filtered_time_reg_start_indx)
                    plot(elec_ax,electrode_data(electrode_count).filtered_time(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)), electrode_data(electrode_count).filtered_data(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)));
                end

                plot(elec_ax, ectopic_plus_stims(mid_beat), electrode_data(electrode_count).data(time_reg_start_indx(1)), 'm.', 'MarkerSize', 20);

            end
        else
         
            beat_warning = electrode_data(electrode_count).warning_array{mid_beat};
            if ~isempty(beat_warning)
                beat_warning = beat_warning{1};
            end

            if contains(beat_warning, 'Reanalysed')
                split_one = strsplit(beat_warning, 'BDT=');
                split_two = strsplit(split_one{1, 2}, ',');
                reanalysed_bdt = str2num(split_two{1});

                if reanalysed_bdt < 0
                   postspike_tag = split_two{2};
                   split_postspike = strsplit(postspike_tag, '=');
                   re_analysed_post_spike = str2num(split_postspike{2});
                   post_spike_subtracted = re_analysed_post_spike;
                   time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-re_analysed_post_spike;
                   
                   if time_start < electrode_data(electrode_count).time(1)
                       time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
                   end

                else
                    %time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
                    if electrode_data(electrode_count).beat_start_times(mid_beat) - electrode_data(electrode_count).post_spike_hold_off > electrode_data(electrode_count).time(1)

                        time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-electrode_data(electrode_count).post_spike_hold_off;
                    else

                        time_start = electrode_data(electrode_count).beat_start_times(mid_beat);

                    end 


                end


            else
                %time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
                if electrode_data(electrode_count).beat_start_times(mid_beat) - electrode_data(electrode_count).post_spike_hold_off > electrode_data(electrode_count).time(1)

                    time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-electrode_data(electrode_count).post_spike_hold_off;
                else

                    time_start = electrode_data(electrode_count).beat_start_times(mid_beat);

                end 

            end
            
            %time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
            time_end = electrode_data(electrode_count).beat_start_times(mid_beat+1);

            time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
            time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);
            
            filtered_time_reg_start_indx = find(electrode_data(electrode_count).filtered_time >= time_start);
            filtered_time_reg_end_indx = find(electrode_data(electrode_count).filtered_time >= time_end);

            
            plot(elec_ax, electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));
            
            if ~isempty(filtered_time_reg_start_indx)
                plot(elec_ax,electrode_data(electrode_count).filtered_time(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)), electrode_data(electrode_count).filtered_data(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)));
            end

            plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat),  electrode_data(electrode_count).beat_start_volts(mid_beat), 'g.', 'MarkerSize', 20);

        end


        t_wave_indx = find(electrode_data(electrode_count).t_wave_peak_times >= time_start);
        t_wave_indx = t_wave_indx(1);
        t_wave_peak_time = electrode_data(electrode_count).t_wave_peak_times(t_wave_indx);
        t_wave_p = electrode_data(electrode_count).t_wave_peak_array(t_wave_indx);
        if ~isnan(t_wave_peak_time) && ~isnan(t_wave_p)
            plot(elec_ax, t_wave_peak_time, t_wave_p, 'c.', 'MarkerSize', 20);
        end

        max_depol_indx = find(electrode_data(electrode_count).max_depol_time_array >= time_start);
        if ~isempty(max_depol_indx)
            max_depol_indx = max_depol_indx(1);
            plot(elec_ax, electrode_data(electrode_count).max_depol_time_array(max_depol_indx), electrode_data(electrode_count).max_depol_point_array(max_depol_indx), 'r.', 'MarkerSize', 20);
        end
        
        
        min_depol_indx = find(electrode_data(electrode_count).min_depol_time_array >= time_start);
        
        if ~isempty(max_depol_indx)
            min_depol_indx = min_depol_indx(1);
            plot(elec_ax, electrode_data(electrode_count).min_depol_time_array(min_depol_indx), electrode_data(electrode_count).min_depol_point_array(min_depol_indx), 'b.', 'MarkerSize', 20);
        end

        act_indx = find(electrode_data(electrode_count).activation_times >= time_start);
        
        if ~isempty(act_indx)
            act_indx = act_indx(1);
            plot(elec_ax, electrode_data(electrode_count).activation_times(act_indx), electrode_data(electrode_count).activation_point_array(act_indx), 'k.', 'MarkerSize', 20);
        end

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

    [electrode_data(electrode_count).arrhythmia_indx, electrode_data(electrode_count).warning_array, electrode_data(electrode_count).num_arrhythmic] = arrhythmia_analysis(electrode_data(electrode_count).beat_num_array, electrode_data(electrode_count).cycle_length_array, electrode_data(electrode_count).warning_array);
                

    well_electrode_data.electrode_data = electrode_data;
    if strcmp(spon_paced, 'spon')
        [well_electrode_data.conduction_velocity, well_electrode_data.conduction_velocity_model] = calculateSpontaneousConductionVelocity(well_electrode_data.wellID, electrode_data,  num_electrode_rows, num_electrode_cols, nan);
    
    else
        [well_electrode_data.conduction_velocity, well_electrode_data.conduction_velocity_model] = calculatePacedConductionVelocity(well_electrode_data.wellID, electrode_data,  num_electrode_rows, num_electrode_cols, nan);
    
    end
    set(well_elec_fig, 'visible', 'on')
end