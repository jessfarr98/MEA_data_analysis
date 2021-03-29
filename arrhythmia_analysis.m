function [arrhythmia_indx] = arrhythmia_analysis(beat_num_array, cycle_length_array)
    %% POSSIBLE INDEXING BUG
    prev_cycle = cycle_length_array(1);
    mean_cl = mean(cycle_length_array);
    arrhythmia_indx = [];
    window = 1;

    for i = 2:length(cycle_length_array)
        cycle = cycle_length_array(i);
        % see if there are any adjacent beats with high stdev
        %% use % difference instead.
        
        %cycle_stdev = std([prev_cycle cycle]);
        diff = abs(cycle - prev_cycle);
        
        if diff > 0.25*cycle
            %disp(i-1)
            %disp(i)
            %disp('arrhythmia at:');
            arrhythmia_indx = [arrhythmia_indx (i-1)];
            arrhythmia_indx = [arrhythmia_indx (i)];
            [arrhythmia_indx] = intersect(arrhythmia_indx, beat_num_array);
            %pause(5)
            start = i;
            window = i+1;
            if window > length(cycle_length_array)
                break;
            end
            
            %disp('find friends')
            while(1)
                %for k = start:i+window
                w_c = cycle_length_array(start);
                w_c_next = cycle_length_array(window);
                %start 
                %window
                %cycle_stdev = std([w_c w_c_next]);
                diff = abs(w_c_next-w_c);
                
                if diff > 0.25*w_c
                    
                    arrhythmia_indx = [arrhythmia_indx start];
                    arrhythmia_indx = [arrhythmia_indx window];
                    [arrhythmia_indx] = intersect(arrhythmia_indx, beat_num_array);
                    %disp('arrhythmia at:');
                    start = window;
                    window = window+1;
                    if window > length(cycle_length_array)
                        break;
                    end
                else
                    break;
                end
                %end
            end
        end
        prev_cycle = cycle;
    end

    [arrhythmia_indx] = intersect(arrhythmia_indx, beat_num_array);
    arrhythmia_indx = sort(arrhythmia_indx);
    
end