function [conduction_velocity] =  calculateConductionVelocity(electrode_data,  num_electrode_rows, num_electrode_cols)

    conduction_velocity = 0;
    electrode_count = 1;
    dist_array = [];
    act_array =[];
    for er = num_electrode_rows:-1:1
        for ec = num_electrode_cols:-1:1
            elec_id = electrode_data(electrode_count).electrode_id;
            
            if isempty(elec_id)
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
            dist = sqrt(((350*ec)^2)+((350*er)^2));
            
                
            if length(electrode_data(electrode_count).activation_times) < 2
                continue
            end
            dist_array = [dist_array; dist];
            
            act_array =[act_array; electrode_data(electrode_count).activation_times(2)];
            electrode_count = electrode_count + 1;
        end
    end

    
    lin_eqn = fittype('m*x+b');
    
    model = fit(dist_array, act_array, lin_eqn);
    
    conduction_velocity = 1/model.m;
    
    
end