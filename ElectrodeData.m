classdef ElectrodeData
    properties
        min_stdev;
        average_waveform;
        ave_wave_time;
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
        beat_periods;
        t_wave_peak_times;
        t_wave_peak_array;
        max_depol_time_array;
        min_depol_time_array;
        max_depol_point_array;
        min_depol_point_array;
        activation_point_array;
        depol_slope_array;
        Stims;
        ave_max_depol_time;
        ave_min_depol_time;
        ave_max_depol_point;
        ave_min_depol_point;
        ave_activation_time;
        ave_t_wave_peak_time;
        ave_depol_slope;
        ave_warning;
        GE_electrode_indx;
        %inputs
        warning_array;
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
        save_fig
        
        
        
        
    end
    
    methods (Static)
        
        
        
    end
    
end