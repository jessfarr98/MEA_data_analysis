function [conduction_velocity, model] =  calculatePacedConductionVelocity(well_ID, electrode_data,  num_electrode_rows, num_electrode_cols, conduction_velocity)

    %electrode_count = 1;
    dist_array = [];
    act_array =[];
    elec_ids = [electrode_data(:).electrode_id];
    for er = num_electrode_rows:-1:1
        for ec = num_electrode_cols:-1:1 % Change this and subtract 1 
            
            %elec_id = electrode_data(electrode_count).electrode_id;
            elec_id = strcat(well_ID, '_', num2str(ec), '_', num2str(er));
            

            elec_indx = contains(elec_ids, elec_id);
            elec_indx = find(elec_indx == 1);
            electrode_count = elec_indx;
            
            if isempty(elec_indx)
                %electrode_count = electrode_count + 1;
                continue
            end
            
            if electrode_data(electrode_count).rejected == 1
                %electrode_count = electrode_count + 1;
                continue
            end
            
            %origin electrode = 4,1
            %{
            if ec == 4
                col_dist = 1;
            elseif ec == 3
                col_dist = 2;
            elseif ec == 2
                col_dist = 3;
            elseif ec == 2
                col_dist = 4;
            end
            %}
            
            %%x = y = 350um
            dist = sqrt(((350*(ec-1))^2)+((350*(er-1))^2));
            
                
            if length(electrode_data(electrode_count).activation_times) < 2
                electrode_count = electrode_count + 1;
                continue
            end
            dist_array = [dist_array; dist];
            
            act_array =[act_array; electrode_data(electrode_count).activation_times(2)];
            %electrode_count = electrode_count + 1;
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