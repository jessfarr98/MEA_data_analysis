classdef ElectrodeData
    properties
        min_stdev;
        average_waveform;
        ave_wave_time;
        filtered_ave_wave_time;
        filtered_average_waveform;
        filtered_time;
        filtered_data;
        time;
        data;
        electrode_id;
        %stable_data;
        stable_waveforms;
        stable_times;
        window;
        activation_times;
        beat_num_array; 
        cycle_length_array;
        beat_start_times;
        beat_start_volts;
        beat_periods;
        t_wave_peak_times;
        t_wave_peak_array;
        t_wave_wavelet_array;
        t_wave_polynomial_degree_array;
        max_depol_time_array;
        min_depol_time_array;
        max_depol_point_array;
        min_depol_point_array;
        activation_point_array;
        depol_slope_array;
        Stims;
        Stim_volts;
        ave_max_depol_time;
        ave_min_depol_time;
        ave_max_depol_point;
        ave_min_depol_point;
        ave_activation_time;
        ave_activation_point;
        ave_t_wave_peak_time;
        ave_t_wave_peak;
        ave_depol_slope;
        ave_t_wave_wavelet;
        ave_t_wave_polynomial_degree;
        ave_warning;
        GE_electrode_indx;
        %inputs
        warning_array;
        arrhythmia_indx;
        bdt;
        min_bp;
        max_bp;
        post_spike_hold_off;
        t_wave_offset;
        t_wave_duration;
        t_wave_shape;
        stim_spike_hold_off;
        time_region_start;
        time_region_end;
        stable_beats_duration;
        filter_intensity;
        rejected;
        save_fig;
        spon_paced;
        %ave_wave_bdt;
        %ave_wave_min_bp;
        %ave_wave_max_bp;
        ave_wave_post_spike_hold_off;
        ave_wave_t_wave_offset;
        ave_wave_t_wave_duration;
        ave_wave_t_wave_shape;
        ave_wave_stim_spike_hold_off;
        ave_wave_time_region_start;
        ave_wave_time_region_end;
        ave_wave_stable_beats_duration;
        ave_wave_filter_intensity;
        num_arrhythmic;
        
        
        
        
    end
    
    methods (Static)
        
        
        
    end
    
end