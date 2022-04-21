classdef BipolarData
    properties
        electrode_id;
        wave_form;
        time;
        
        activation_times;
        activation_point_array;
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
        depol_slope_array;
        Stims;
        Stim_volts;
        
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
    end
    
    methods (Static)
        
        
        
    end
    
end