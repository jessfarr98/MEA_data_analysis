function [conduction_velocity, model] =  calculateSpontaneousConductionVelocity(electrode_data,  num_electrode_rows, num_electrode_cols, conduction_velocity)
    
    electrode_count = 1;
    dist_array = [];
    %act_array = one(num_electrode_rows*num_electrode_cols);
    act_array =[];
    electrode_ids = [];
    for er = num_electrode_rows:-1:1
        for ec = num_electrode_cols:-1:1
            elec_id = electrode_data(electrode_count).electrode_id;
            
            if isempty(elec_id)
                electrode_count = electrode_count + 1;
                continue
            end
            if electrode_data(electrode_count).rejected == 1
                electrode_count = electrode_count + 1;
                continue
            end
            act_array = [act_array; electrode_data(electrode_count).activation_times(2)];
            electrode_ids = [electrode_ids; elec_id];
            electrode_count = electrode_count + 1;
            
        end
    end
    min_act_indx = find(act_array == min(act_array));
    origin_electrode = electrode_ids(min_act_indx(1));
    
    split_orig_elec = strsplit(origin_electrode, '_');
    origin_elec_row = str2num(split_orig_elec{2});
    origin_elec_col = str2num(split_orig_elec{3});

    electrode_count = 1;
    act_array =[];
    for er = num_electrode_rows:-1:1
        for ec = 1:num_electrode_cols
            elec_id = electrode_data(electrode_count).electrode_id;
            
            if isempty(elec_id)
                electrode_count = electrode_count + 1;
                continue
            end
            if electrode_data(electrode_count).rejected == 1
                electrode_count = electrode_count + 1;
                continue
            end
            
            %%x = y = 350um
            split_elec = strsplit(elec_id, '_');
            elec_row = str2num(split_elec{2});
            elec_col = str2num(split_elec{3});
            
            if elec_row < origin_elec_row
                row_dist = origin_elec_row - elec_row;
                
            else
                row_dist = elec_row - origin_elec_row;
            end
            
            
            if elec_col < origin_elec_col
                col_dist = origin_elec_col - elec_col;
            else
                col_dist = elec_col - origin_elec_col;
                
            end
            
            dist = sqrt(((350*col_dist)^2)+((350*row_dist)^2));
            
                
            if length(electrode_data(electrode_count).activation_times) < 2
                electrode_count = electrode_count + 1;
                continue
            end
            dist_array = [dist_array; dist];
            
            act_array =[act_array; electrode_data(electrode_count).activation_times(2)];
            electrode_count = electrode_count + 1;
        end
    end

    
    if isempty(dist_array)
        conduction_velocity = nan;
        model = nan;
        return
    end
    
    if isnan(conduction_velocity)
        lin_eqn = fittype('m*x+b');

        model = fit(dist_array, act_array, lin_eqn);

        conduction_velocity = 1/model.m;
    else
        % only set when reanalysing saved data
        lin_eqn = fittype(sprintf('(1/%f)*x+b', conduction_velocity));

        model = fit(dist_array, act_array, lin_eqn);
        
    end
    
end