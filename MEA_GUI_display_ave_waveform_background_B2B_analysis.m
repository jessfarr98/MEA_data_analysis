function MEA_GUI_display_ave_waveform_background_B2B_analysis(electrode_data, electrode_count, expand_elec_panel, exp_ax)
    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    screen_height = screen_height - 100;
    
    t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
    t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
    t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
    t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
    activation_times = electrode_data(electrode_count).activation_times;
    activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
    elec_FPDs = [t_wave_peak_times - activation_times];


    if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
        text_box_height = screen_height/14;

        input_panel = uipanel(expand_elec_panel, 'Title', 'Background B2B Analysis Parameter Inputs', 'Position', [screen_width-275 text_box_height*6 250 text_box_height*4+60]);

        elec_bdt_text = uieditfield(input_panel,'Text', 'Value', "BDT ="+" "+num2str(electrode_data(electrode_count).bdt)+" "+"(V)", 'FontSize', 10, 'Position', [25 text_box_height*3+20 200 text_box_height], 'Editable','off');
        elec_min_bp_text = uieditfield(input_panel,'Text', 'Value', "min BP ="+" "+num2str(electrode_data(electrode_count).min_bp)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*2+20 200 text_box_height], 'Editable','off');
        elec_max_bp_text = uieditfield(input_panel,'Text', 'Value', "max BP ="+" "+num2str(electrode_data(electrode_count).max_bp)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*1+20 200 text_box_height], 'Editable','off');

    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
        text_box_height = screen_height/15;

        input_panel = uipanel(expand_elec_panel, 'Title', 'Background B2B Analysis Parameter Inputs', 'Position', [screen_width-275 text_box_height*6 250 text_box_height*5+60]);

        elec_bdt_text = uieditfield(input_panel,'Text', 'Value', "BDT ="+" "+num2str(electrode_data(electrode_count).bdt)+" "+"(V)", 'FontSize', 10, 'Position', [25 text_box_height*4+20 200 text_box_height], 'Editable','off');
        elec_min_bp_text = uieditfield(input_panel,'Text', 'Value', "min BP ="+" "+num2str(electrode_data(electrode_count).min_bp)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*3+20 200 text_box_height], 'Editable','off');
        elec_max_bp_text = uieditfield(input_panel,'Text', 'Value', "max BP ="+" "+num2str(electrode_data(electrode_count).max_bp)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*2+20 200 text_box_height], 'Editable','off');
        elec_stim_spike_hold_off_text = uieditfield(input_panel,'Text', 'Value', "Stim-spike hold-off ="+" "+num2str(electrode_data(electrode_count).stim_spike_hold_off)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*1+20 200 text_box_height], 'Editable','off');

    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
        text_box_height = screen_height/12;

        input_panel = uipanel(expand_elec_panel, 'Title', 'Background B2B Analysis Parameter Inputs', 'Position', [screen_width-275 text_box_height*6 250 text_box_height*2+60]);

        elec_stim_spike_hold_off_text = uieditfield(input_panel,'Text', 'Value', "Stim-spike hold-off ="+" "+num2str(electrode_data(electrode_count).stim_spike_hold_off)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*1+20 200 text_box_height], 'Editable','off');

    end

    elec_post_spike_input_text = uieditfield(input_panel,'Text', 'Value', "Post-spike ="+" "+num2str(electrode_data(electrode_count).post_spike_hold_off)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*0+20 200 text_box_height], 'Editable','off');

    %{
    elec_t_wave_offset_input_text = uieditfield(input_panel,'Text', 'Value', strcat('T-wave offset = ', num2str(electrode_data(electrode_count).t_wave_offset)), 'FontSize', 10, 'Position', [25 text_box_height*2+20 200 text_box_height], 'Editable','off');
    elec_t_wave_duration_input_text = uieditfield(input_panel,'Text', 'Value', strcat('T-wave duration = ', num2str(electrode_data(electrode_count).t_wave_duration)), 'FontSize', 10, 'Position', [25 text_box_height*1+20 200 text_box_height], 'Editable','off');
    elec_t_wave_shape_input_text = uieditfield(input_panel,'Text', 'Value', strcat('T-wave shape = ', electrode_data(electrode_count).t_wave_shape), 'FontSize', 10, 'Position', [25 text_box_height*0+20 200 text_box_height], 'Editable','off');
    %}
            
    
    hold(exp_ax,'on')
    plot(exp_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);

    ave_wave_region_indx = find(electrode_data(electrode_count).beat_start_times >= electrode_data(electrode_count).time_region_start & electrode_data(electrode_count).beat_start_times <= electrode_data(electrode_count).time_region_end);
    ave_waves_beat_starts = electrode_data(electrode_count).beat_start_times(ave_wave_region_indx);
    ave_waves_beat_starts = [ave_waves_beat_starts, electrode_data(electrode_count).beat_start_times(ave_wave_region_indx(end)+1)];
    ave_waveform_indxs = find(electrode_data(electrode_count).time >= ave_waves_beat_starts(1) & electrode_data(electrode_count).time <= ave_waves_beat_starts(end));

    plot(exp_ax, electrode_data(electrode_count).time(ave_waveform_indxs), electrode_data(electrode_count).data(ave_waveform_indxs), 'color', '#cc3399')

    plot(exp_ax, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data);

    %plot(exp_ax, t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
    plot(exp_ax, electrode_data(electrode_count).max_depol_time_array, electrode_data(electrode_count).max_depol_point_array, 'r.', 'MarkerSize', 20);
    plot(exp_ax, electrode_data(electrode_count).min_depol_time_array, electrode_data(electrode_count).min_depol_point_array, 'b.', 'MarkerSize', 20);

    %[~, beat_start_volts, ~] = intersect(electrode_data(electrode_count).time, electrode_data(electrode_count).beat_start_times);
    %beat_start_volts =  electrode_data(electrode_count).data(beat_start_volts);

    %plot(exp_ax, electrode_data(electrode_count).beat_start_times, beat_start_volts, 'go');

    if strcmp(electrode_data(electrode_count).spon_paced, 'paced') 


        plot(exp_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'm.', 'MarkerSize', 20);
    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')

        plot(exp_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);
        plot(exp_ax, electrode_data(electrode_count).Stims, electrode_data(electrode_count).Stim_volts, 'm.', 'MarkerSize', 20);

    else

        plot(exp_ax, electrode_data(electrode_count).beat_start_times, electrode_data(electrode_count).beat_start_volts, 'g.', 'MarkerSize', 20);

    end
    % Need slope value

    %disp(electrode_data(electrode_count).beat_start_volts)
    %disp(electrode_data(electrode_count).activation_point_array);
    %activation_points = electrode_data(electrode_count).data(find(electrode_data(electrode_count).activation_times), 'ko');
    plot(exp_ax, electrode_data(electrode_count).activation_times, electrode_data(electrode_count).activation_point_array, 'k.', 'MarkerSize', 20);

    ylabel(exp_ax, 'Volts (V)')
    xlabel(exp_ax, 'Seconds (s)')
    title(exp_ax, strcat(electrode_data(electrode_count).electrode_id, {' '}, 'Annotated Background B2B Beats'), 'interpreter', 'none');

    if strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
        if isempty(electrode_data(electrode_count).filtered_data)
            legend(exp_ax, 'signal', 'ave wave beats', 'max depol.', 'min depol.', 'ectopic beat start', 'paced beat start', 'activation point')
        else
            legend(exp_ax, 'signal', 'ave wave beats', 'filtered signal', 'max depol.', 'min depol.', 'ectopic beat start', 'paced beat start', 'activation point')
        end
    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced') 
        if isempty(electrode_data(electrode_count).filtered_data)
            legend(exp_ax, 'signal', 'ave wave beats', 'max depol.', 'min depol.', 'paced beat start', 'activation point')
        else
            legend(exp_ax, 'signal', 'ave wave beats', 'filtered signal',  'max depol.', 'min depol.', 'paced beat start', 'activation point')
        end

    else
        if isempty(electrode_data(electrode_count).filtered_data)
            legend(exp_ax, 'signal', 'ave wave beats', 'max depol.', 'min depol.', 'beat start', 'activation point')
        else
            legend(exp_ax, 'signal', 'ave wave beats', 'filtered signal', 'max depol.', 'min depol.', 'beat start', 'activation point')
        end

    end
    hold(exp_ax,'off')
end