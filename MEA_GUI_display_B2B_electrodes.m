function MEA_GUI_display_B2B_electrodes(electrode_data, electrode_count, elec_ax)
    disp('in MEA_GUI_display_B2B_electrodes')
    hold(elec_ax,'on');
    if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
        num_beats = length(electrode_data(electrode_count).beat_start_times);
    elseif strcmp(electrode_data(electrode_count).spon_paced, 'spon')

        num_beats = length(electrode_data(electrode_count).beat_start_times);
    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
        %num_beats = length(electrode_data(electrode_count).beat_start_times);
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

        if strcmp(electrode_data(electrode_count).spon_paced, 'paced')
            time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
            time_end = electrode_data(electrode_count).beat_start_times(mid_beat+1);

            time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
            time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);



            %plot(elec_ax, electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'mo');

            plot(elec_ax, electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

            %if reanalysis == 0
            filtered_time_reg_start_indx = find(electrode_data(electrode_count).filtered_time >= time_start);
            filtered_time_reg_end_indx = find(electrode_data(electrode_count).filtered_time >= time_end);

            if ~isempty(filtered_time_reg_start_indx)
                plot(elec_ax,electrode_data(electrode_count).filtered_time(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)), electrode_data(electrode_count).filtered_data(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)));
            end
                %end

            %plot(elec_ax, electrode_data(electrode_count).Stims(mid_beat), electrode_data(electrode_count).Stim_volts(mid_beat), 'm.', 'MarkerSize', 20);
            plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat), electrode_data(electrode_count).beat_start_volts(mid_beat), 'm.', 'MarkerSize', 20);

        elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
            %{
            time_start = electrode_data(electrode_count).beat_start_times(mid_beat);
            time_end = electrode_data(electrode_count).beat_start_times(mid_beat+1);

            time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
            time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);


            plot(elec_ax,well_electrode_data(well_count). electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

            plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat), electrode_data(electrode_count).data(time_reg_start_indx(1)), 'go');

            %}
            time_start = ectopic_plus_stims(mid_beat);
            time_end = ectopic_plus_stims(mid_beat+1);



            if ismember(electrode_data(electrode_count).beat_start_times , time_start)
                if electrode_data(electrode_count).bdt < 0
                    time_start = time_start - electrode_data(electrode_count).post_spike_hold_off;
                end
                time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
                time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);



                plot(elec_ax,electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

                %if reanalysis == 0
                filtered_time_reg_start_indx = find(electrode_data(electrode_count).filtered_time >= time_start);
                filtered_time_reg_end_indx = find(electrode_data(electrode_count).filtered_time >= time_end);


                plot(elec_ax,electrode_data(electrode_count).filtered_time(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)), electrode_data(electrode_count).filtered_data(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)));

                %end

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
            %{
            if electrode_data(electrode_count).bdt < 0
                time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-electrode_data(electrode_count).post_spike_hold_off;

            else
                time_start = electrode_data(electrode_count).beat_start_times(mid_beat);

            end
            %}
            if electrode_data(electrode_count).beat_start_times(mid_beat) - electrode_data(electrode_count).post_spike_hold_off > electrode_data(electrode_count).time(1)

                time_start = electrode_data(electrode_count).beat_start_times(mid_beat)-electrode_data(electrode_count).post_spike_hold_off;
            else

                time_start = electrode_data(electrode_count).beat_start_times(mid_beat);

            end 

            time_end = electrode_data(electrode_count).beat_start_times(mid_beat+1);

            time_reg_start_indx = find(electrode_data(electrode_count).time >= time_start);
            time_reg_end_indx = find(electrode_data(electrode_count).time >= time_end);



            plot(elec_ax,electrode_data(electrode_count).time(time_reg_start_indx(1):time_reg_end_indx(1)), electrode_data(electrode_count).data(time_reg_start_indx(1):time_reg_end_indx(1)));

            %if reanalysis == 0
            filtered_time_reg_start_indx = find(electrode_data(electrode_count).filtered_time >= time_start);
            filtered_time_reg_end_indx = find(electrode_data(electrode_count).filtered_time >= time_end);

            plot(elec_ax,electrode_data(electrode_count).filtered_time(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)), electrode_data(electrode_count).filtered_data(filtered_time_reg_start_indx(1):filtered_time_reg_end_indx(1)));

            %end
            %plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat), electrode_data(electrode_count).data(time_reg_start_indx(1)), 'g.', 'MarkerSize', 20);


            plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat), electrode_data(electrode_count).beat_start_volts(mid_beat), 'g.', 'MarkerSize', 20);


        end


        %if strcmp(spon_paced, 'paced bdt')

        %disp(electrode_data(electrode_count).t_wave_peak_times)

        t_wave_indx = find(electrode_data(electrode_count).t_wave_peak_times >= time_start);
        if length(t_wave_indx) > 1
            t_wave_indx = t_wave_indx(1);
            t_wave_peak_time = electrode_data(electrode_count).t_wave_peak_times(t_wave_indx);
            t_wave_p = electrode_data(electrode_count).t_wave_peak_array(t_wave_indx);
            if ~isnan(t_wave_peak_time) && ~isnan(t_wave_p)
                plot(elec_ax, t_wave_peak_time, t_wave_p, 'c.', 'MarkerSize', 35);
            end
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

        %plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat), electrode_data(electrode_count).data(time_reg_start_indx(1)), 'go');


        %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');

        act_indx = find(electrode_data(electrode_count).activation_times >= time_start);
        
        if ~isempty(act_indx)
            act_indx = act_indx(1);
            plot(elec_ax, electrode_data(electrode_count).activation_times(act_indx), electrode_data(electrode_count).activation_point_array(act_indx), 'k.', 'MarkerSize', 20);
        end
         %{
        else
            t_wave_peak_time = electrode_data(electrode_count).t_wave_peak_times(mid_beat);
            t_wave_p = electrode_data(electrode_count).t_wave_peak_array(mid_beat);
            if ~isnan(t_wave_peak_time) && ~isnan(t_wave_p)
                plot(elec_ax, t_wave_peak_time, t_wave_p, 'co');
            end
            plot(elec_ax, electrode_data(electrode_count).max_depol_time_array(mid_beat), electrode_data(electrode_count).max_depol_point_array(mid_beat), 'ro');
            plot(elec_ax, electrode_data(electrode_count).min_depol_time_array(mid_beat), electrode_data(electrode_count).min_depol_point_array(mid_beat), 'bo');

            %plot(elec_ax, electrode_data(electrode_count).beat_start_times(mid_beat), electrode_data(electrode_count).data(time_reg_start_indx(1)), 'go');


            %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
            plot(elec_ax, electrode_data(electrode_count).activation_times(mid_beat), electrode_data(electrode_count).activation_point_array(mid_beat), 'ko');

        end
         %}
    else
        plot(elec_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);

        t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
        t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
        t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
        t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
        plot(elec_ax, t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
        plot(elec_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
        plot(elec_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

        %[~, beat_start_volts, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
        %beat_start_volts = electrode_data(electrode_count).data(beat_start_volts);


        if strcmp(electrode_data(electrode_count).spon_paced, 'paced')

            plot(elec_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'm.', 'MarkerSize', 20);

        elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
            plot(elec_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
            plot(elec_ax, electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);

        else
            plot(elec_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);



        end
        %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');

        plot(elec_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'k.', 'MarkerSize', 20);

        % Zoom in on beat in the middle

    end
    hold(elec_ax,'off');


end