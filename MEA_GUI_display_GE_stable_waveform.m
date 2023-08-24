function MEA_GUI_display_GE_stable_waveform(ax, electrode_data)

    hold(ax, 'on')
    window = electrode_data.window;
    for k = 1:window
       plot(ax, electrode_data.stable_times{k, 1}, electrode_data.stable_waveforms{k, 1});
       stable_time = electrode_data.stable_times{k, 1};
       stable_act_time_indx = find(electrode_data.activation_times >= stable_time(1));
       stable_act_time_indx = stable_act_time_indx(1);

       plot(ax, electrode_data.activation_times(stable_act_time_indx), electrode_data.activation_point_array(stable_act_time_indx), 'k.', 'MarkerSize', 20)
    end
    hold(ax, 'off');

    




end