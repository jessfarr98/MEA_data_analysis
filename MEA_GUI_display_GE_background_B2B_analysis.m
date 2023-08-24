function MEA_GUI_display_GE_background_B2B_analysis(expand_elec_panel, exp_ax, electrode_data, electrode_count)
    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    
    t_wave_peak_times = electrode_data(electrode_count).t_wave_peak_times;
    t_wave_peak_times = t_wave_peak_times(~isnan(t_wave_peak_times));
    t_wave_peak_array = electrode_data(electrode_count).t_wave_peak_array;
    t_wave_peak_array = t_wave_peak_array(~isnan(t_wave_peak_array));
    activation_times = electrode_data(electrode_count).activation_times;
    activation_times = activation_times(~isnan(electrode_data(electrode_count).t_wave_peak_times));
    elec_FPDs = [t_wave_peak_times - activation_times];


    if strcmp(electrode_data(electrode_count).spon_paced, 'spon')
        text_box_height = screen_height/14;

        elec_bdt_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('BDT = ', num2str(electrode_data(electrode_count).bdt)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*12 200 text_box_height], 'Editable','off');
        elec_min_bp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('min BP = ', num2str(electrode_data(electrode_count).min_bp)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*11 200 text_box_height], 'Editable','off');
        elec_max_bp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('max BP = ', num2str(electrode_data(electrode_count).max_bp)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*10 200 text_box_height], 'Editable','off');

    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
        text_box_height = screen_height/15;

        elec_bdt_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('BDT = ', num2str(electrode_data(electrode_count).bdt)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*13 200 text_box_height], 'Editable','off');
        elec_min_bp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('min BP = ', num2str(electrode_data(electrode_count).min_bp)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*12 200 text_box_height], 'Editable','off');
        elec_max_bp_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('max BP = ', num2str(electrode_data(electrode_count).max_bp)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*11 200 text_box_height], 'Editable','off');
        elec_stim_spike_hold_off_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('Stim-spike hold-off = ', num2str(electrode_data(electrode_count).stim_spike_hold_off)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*10 200 text_box_height], 'Editable','off');

    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
        text_box_height = screen_height/12;

        elec_stim_spike_hold_off_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('Stim-spike hold-off = ', num2str(electrode_data(electrode_count).stim_spike_hold_off)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*10 200 text_box_height], 'Editable','off');

    end

    elec_post_spike_input_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('Post-spike = ', num2str(electrode_data(electrode_count).post_spike_hold_off)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*9 200 text_box_height], 'Editable','off');
    elec_t_wave_offset_input_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('T-wave offset = ', num2str(electrode_data(electrode_count).t_wave_offset)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*8 200 text_box_height], 'Editable','off');
    elec_t_wave_duration_input_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('T-wave duration = ', num2str(electrode_data(electrode_count).t_wave_duration)), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*7 200 text_box_height], 'Editable','off');
    elec_t_wave_shape_input_text = uieditfield(expand_elec_panel,'Text', 'Value', strcat('T-wave shape = ', electrode_data(electrode_count).t_wave_shape), 'FontSize', 10, 'Position', [screen_width-220 text_box_height*6 200 text_box_height], 'Editable','off');

    hold(exp_ax,'on')
    plot(exp_ax, electrode_data(electrode_count).time, electrode_data(electrode_count).data);


    win = electrode_data(electrode_count).window;

    for ks = 1:win
       plot(exp_ax, electrode_data(electrode_count).stable_times{ks, 1}, electrode_data(electrode_count).stable_waveforms{ks, 1}, 'color','#cc3399');

    end



    plot(exp_ax, electrode_data(electrode_count).filtered_time, electrode_data(electrode_count).filtered_data);
    plot(exp_ax, t_wave_peak_times, t_wave_peak_array, 'c.', 'MarkerSize', 20);
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

    if strcmp(electrode_data(electrode_count).spon_paced, 'paced bdt')
        legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'ectopic beat start', 'paced beat start', 'activation point')
    elseif strcmp(electrode_data(electrode_count).spon_paced, 'paced')
        legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'paced beat start', 'activation point')

    else
        legend(exp_ax, 'signal', 'filtered signal', 'T-wave peak', 'max depol.', 'min depol.', 'beat start', 'activation point')

    end
    hold(exp_ax,'off')


end