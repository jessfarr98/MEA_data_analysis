function MEA_GUI_display_ave_waveform(electrode_data, electrode_count, adv_elec_panel, adv_ax)
    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    screen_height = screen_height - 100;
    
    electrode_data = electrode_data(electrode_count);
    elec_FPD = electrode_data.ave_t_wave_peak_time - electrode_data.ave_activation_time;
    elec_amplitude = electrode_data.ave_max_depol_point - electrode_data.ave_min_depol_point;
    elec_slope = electrode_data.ave_depol_slope;

    if length(electrode_data.ave_wave_time) >= 1
        elec_bp = electrode_data.ave_wave_time(end) - electrode_data.ave_wave_time(1);
    else
        elec_bp = nan;
    end


    if ~strcmp(electrode_data.spon_paced, 'spon')

        text_box_height = screen_height/12;

        inputs_panel = uipanel(adv_elec_panel, 'title', 'Ave Wave Analysis Parameter Inputs', 'Position', [screen_width-275 text_box_height*5+100 250 text_box_height*5+60]);

        elec_stim_spike_hold_off_text = uieditfield(inputs_panel,'Text', 'Value', strcat('Stim-spike hold-off = ', num2str(electrode_data.ave_wave_stim_spike_hold_off)), 'FontSize', 10, 'Position', [25 text_box_height*4+20 200 text_box_height], 'Editable','off');

    else
        text_box_height = screen_height/11;

        inputs_panel = uipanel(adv_elec_panel, 'title', 'Ave Wave Analysis Parameter Inputs', 'Position', [screen_width-275 text_box_height*5+100 250 text_box_height*4+60]);

    end

    results_panel = uipanel(adv_elec_panel, 'title', 'Ave Wave Stats', 'Position', [screen_width-275 text_box_height*1+20 250 text_box_height*4+60]);


    elec_post_spike_input_text = uieditfield(inputs_panel,'Text', 'Value', "Post-spike ="+" "+num2str(electrode_data.ave_wave_post_spike_hold_off)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*3+20 200 text_box_height], 'Editable','off');
    elec_t_wave_offset_input_text = uieditfield(inputs_panel,'Text', 'Value', "T-wave offset ="+" "+num2str(electrode_data.ave_wave_t_wave_offset)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*2+20 200 text_box_height], 'Editable','off');
    elec_t_wave_duration_input_text = uieditfield(inputs_panel,'Text', 'Value', "T-wave duration ="+" "+num2str(electrode_data.ave_wave_t_wave_duration)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*1+20 200 text_box_height], 'Editable','off');
    elec_t_wave_shape_input_text = uieditfield(inputs_panel,'Text', 'Value', "T-wave shape = "+" "+electrode_data.ave_wave_t_wave_shape, 'FontSize', 10, 'Position', [25 text_box_height*0+20 200 text_box_height], 'Editable','off');

    %elec_stat_plots_button = uibutton(adv_elec_panel,'push','Text','View Plots', 'Position', [screen_width-220 200 120 50], 'FontSize', 6,'ButtonPushedFcn', @(elec_stat_plots_button,event) statPlotsButtonPushed(elec_stat_plots_button, adv_elec_fig, well_ID, num_electrode_rows, num_electrode_cols, spon_paced, electrode_data));
    elec_fpd_text = uieditfield(results_panel,'Text', 'Value', "FPD = "+" " +num2str(elec_FPD)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*3+20 200 text_box_height], 'Editable','off');
    elec_amp_text = uieditfield(results_panel,'Text', 'Value', "Depol. Amplitude = "+ " " + num2str(elec_amplitude)+" "+"(V)", 'FontSize', 10, 'Position', [25 text_box_height*2+20 200 text_box_height], 'Editable','off');
    elec_slope_text = uieditfield(results_panel,'Text', 'Value', "Depol. Slope = "+ " "+ num2str(elec_slope)+" "+"(dV/dt)", 'FontSize', 10, 'Position', [25 text_box_height*1+20 200 text_box_height], 'Editable','off');
    elec_bp_text = uieditfield(results_panel,'Text', 'Value', "Beat Period = " + " " + num2str(elec_bp)+" "+"(s)", 'FontSize', 10, 'Position', [25 text_box_height*0+20 200 text_box_height], 'Editable','off');

    hold(adv_ax,'on')
    plot(adv_ax, electrode_data.ave_wave_time, electrode_data.average_waveform);
    plot(adv_ax, electrode_data.filtered_ave_wave_time, electrode_data.filtered_average_waveform);
    %plot(elec_ax, electrode_data(electrode_count).t_wave_peak_times, electrode_data(electrode_count).t_wave_peak_array, 'co');
    plot(adv_ax, electrode_data.ave_max_depol_time, electrode_data.ave_max_depol_point, 'r.', 'MarkerSize', 20);
    plot(adv_ax, electrode_data.ave_min_depol_time, electrode_data.ave_min_depol_point, 'b.', 'MarkerSize', 20);
    plot(adv_ax, electrode_data.ave_activation_time, electrode_data.average_waveform(electrode_data.ave_wave_time == electrode_data.ave_activation_time), 'k.', 'MarkerSize', 20);

    elec_peak_indx = find(electrode_data.ave_wave_time >= electrode_data.ave_t_wave_peak_time);

    if length(elec_peak_indx) >= 1
        elec_peak_indx = elec_peak_indx(1);
        elec_t_wave_peak = electrode_data.average_waveform(elec_peak_indx);
        plot(adv_ax, electrode_data.ave_t_wave_peak_time, elec_t_wave_peak, 'c.', 'MarkerSize', 20);
    end

    ave_wave_dur = electrode_data.ave_wave_time(end)-electrode_data.ave_wave_time(1);
    xlim(adv_ax, [electrode_data.ave_wave_time(1)-0.1*ave_wave_dur, electrode_data.ave_wave_time(end)+0.1*ave_wave_dur])
    ylabel(adv_ax, 'Volts (V)')
    xlabel(adv_ax, 'Seconds (s)')
    title(adv_ax, strcat(electrode_data.electrode_id, {' '}, 'Annotated Average Waveform'), 'interpreter', 'none');
    legend(adv_ax, 'signal', 'filtered signal', 'max depol.', 'min depol.', 'activation point', 'T-wave peak')
    
    hold(adv_ax,'off')
    
end