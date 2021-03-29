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
        ave_depol_slope
        
    end
    
    methods (Static)
        
        
        
    end
    
end