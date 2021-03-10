classdef ElectrodeData
    properties
        min_stdev;
        average_waveform;
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
        Stims
    end
    
    methods (Static)
        
        
        
    end
    
end