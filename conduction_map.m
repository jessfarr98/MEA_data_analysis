function conduction_map(activation_times, num_electrode_rows, num_electrode_cols, spon_paced)
    %% Calculate dx/dt for each electrode wrt. electrode in bottom left corner. 
    
    conduction_velocities = [];
    
    init_e_r = 1;
    init_e_c = 1;
    dx_array = [];
    dt_array = [];
    count = 1;
    electrode_ids = [];
    disp(activation_times);
    
    %% 4_1 is the stim electrode
    %% for spontaneous the origin electrode is the one with earliest activation time.
    %% negative values possible QC
    %% Plot activation times.
    
    %% WRONG - NEED TO TAKE FIRST ACTIVATION TIME FROM FIRST BEAT FOR EACH ELECTRODE AND THEN CALL THIS FUNCTION
    
    % 4_1 is the pacing electrode
    quiver_X = [];
    quiver_Y = [];
    quiver_U = [];
    quiver_V = [];
    if strcmp(spon_paced, 'paced')
        %% Need to do this locally not with origin electrode
        for e_r = 1:num_electrode_rows
            for e_c = num_electrode_cols:-1:1
                % For each electrode find it's adjacent electrodes travelling from bottom right to top left
                % If bottom left (1,1) just calculate (e-r,e_c+1)
                % If bottom row (e_r == 1) just calculate (e_r+1, e_c), (e_r, e_c)
                % If top left ignore
                %dx = sqrt(e_r^2 + e_c^2);
                %dt = activation_times(count)-activation_times(13);
                e_id = strcat(num2str(e_r),{' '},num2str(e_c));
                electrode_ids = [electrode_ids; e_id];
                if e_c == 1
                
                    if e_r == 1
                        % Bottom left - just calculate (e_r, e_c+1)
                        disp('bottom left')
                        disp(e_r)
                        disp(e_c)
                        %above
                        adj_row = e_r;
                        adj_col = e_c+1;
                        
                        [quiver_X, quiver_Y, quiver_U, quiver_V] = calculate_vector(quiver_X, quiver_Y, quiver_U, quiver_V, e_r, e_c, activation_times, count, adj_col, adj_row);
                        
                    else
                       % General bottom row case
                       disp('bottom row general')
                       disp(e_r)
                       disp(e_c)
                       % above
                       adj_row = e_r
                       adj_col = e_c+1
                        
                       [quiver_X, quiver_Y, quiver_U, quiver_V] = calculate_vector(quiver_X, quiver_Y, quiver_U, quiver_V, e_r, e_c, activation_times, count, adj_col, adj_row);
                        
                       %north west 
                       adj_row = e_r-1
                       adj_col = e_c+1
                        
                       [quiver_X, quiver_Y, quiver_U, quiver_V] = calculate_vector(quiver_X, quiver_Y, quiver_U, quiver_V, e_r, e_c, activation_times, count, adj_col, adj_row);
                        
                       
                       %left
                       adj_row = e_r-1
                       adj_col = e_c
                        
                       [quiver_X, quiver_Y, quiver_U, quiver_V] = calculate_vector(quiver_X, quiver_Y, quiver_U, quiver_V, e_r, e_c, activation_times, count, adj_col, adj_row);
                        
                        
                    end
                else
                    if e_c == 4
                       % top row
                       if e_r == 1
                           disp('top left')
                           disp(e_r)
                           disp(e_c)
                          % Top left
                          continue; 
                       elseif e_r == 4
                           % Top right
                           disp('top right')
                           disp(e_r)
                           disp(e_c)
                           %left
                           adj_row = e_r-1
                           adj_col = e_c

                           [quiver_X, quiver_Y, quiver_U, quiver_V] = calculate_vector(quiver_X, quiver_Y, quiver_U, quiver_V, e_r, e_c, activation_times, count, adj_col, adj_row);

                       else
                           % General top row case
                           disp('general top case')
                           disp(e_r)
                           disp(e_c)
                           %left
                           adj_row = e_r-1
                           adj_col = e_c

                           [quiver_X, quiver_Y, quiver_U, quiver_V] = calculate_vector(quiver_X, quiver_Y, quiver_U, quiver_V, e_r, e_c, activation_times, count, adj_col, adj_row);

                           
                       end
                    else
                       % General case
                       % above
                       if e_r == 1
                           %left hand case
                           disp('Left column')
                           disp(e_r)
                           disp(e_c)
                           
                           %above
                           adj_row = e_r
                           adj_col = e_c+1

                           [quiver_X, quiver_Y, quiver_U, quiver_V] = calculate_vector(quiver_X, quiver_Y, quiver_U, quiver_V, e_r, e_c, activation_times, count, adj_col, adj_row);

                           
                       else
                           disp('general case')
                           disp(e_r)
                           disp(e_c)
                           
                           %above
                           adj_row = e_r
                           adj_col = e_c+1

                           [quiver_X, quiver_Y, quiver_U, quiver_V] = calculate_vector(quiver_X, quiver_Y, quiver_U, quiver_V, e_r, e_c, activation_times, count, adj_col, adj_row);

                           %north west 
                           adj_row = e_r-1
                           adj_col = e_c+1

                           [quiver_X, quiver_Y, quiver_U, quiver_V] = calculate_vector(quiver_X, quiver_Y, quiver_U, quiver_V, e_r, e_c, activation_times, count, adj_col, adj_row);


                           %left
                           adj_row = e_r-1;
                           adj_col = e_c;

                           [quiver_X, quiver_Y, quiver_U, quiver_V] = calculate_vector(quiver_X, quiver_Y, quiver_U, quiver_V, e_r, e_c, activation_times, count, adj_col, adj_row);
                       end
                       
                    end
                end
                count = count+1;
            end
        end
        
        %{
        % Origin electrode analysis
        for e_r = 1:num_electrode_rows
            for e_c = num_electrode_cols:-1:1
                if e_r == 4 && e_c == 1
                    dx = 0;
                    dt = 1;
                else
                    dx = sqrt(e_r^2 + e_c^2);
                    dt = activation_times(count)-activation_times(13);
                end
                %num2str(e_r)
                e_id = strcat(num2str(e_r),{' '},num2str(e_c));


                dx_array = [dx_array; dx];
                dt_array = [dt_array; dt];
                electrode_ids = [electrode_ids; e_id];
                count = count+1;
            end
        end
        %}
    elseif strcmp(spon_paced, 'spon')
        min_act = min(activation_times);
        min_act_indx = find(activation_times == min_act)
        
        init_e_c = mod(min_act_indx, 4);
        init_e_r = (min_act_indx-init_e_c)/4;
        init_e_r = init_e_r+1;
        if init_e_r == 0
            init_e_r =1;
        end
        if init_e_c == 1
            init_e_c = 4;
        elseif init_e_c == 2
            init_e_c = 3;
        elseif init_e_c == 3
            init_e_c = 2;
        elseif init_e_c == 0
            init_e_c = 1;
        end
        disp('init_e_r');
        disp(init_e_r);
        disp('init_e_c');
        disp(init_e_c);
        for e_r = 1:num_electrode_rows
            for e_c = num_electrode_cols:-1:1
                if e_r == init_e_r && e_c == init_e_c
                    disp('count');
                    disp(count);
                    dx = 0;
                    dt = activation_times(count)-activation_times(13);
                else
                    dx = sqrt(e_r^2 + e_c^2);
                    dt = activation_times(count)-activation_times(13);
                end
                %num2str(e_r)
                e_id = strcat(num2str(e_r),{' '},num2str(e_c));


                dx_array = [dx_array; dx];
                dt_array = [dt_array; dt];
                electrode_ids = [electrode_ids; e_id];
                count = count+1;
            end
        end
    end
    
    conduction_velocities = dx_array./dt_array;
    
    activation_times = reshape(activation_times, [num_electrode_rows, num_electrode_cols]);
    %{
    disp('conduction velocities b4 reshape')
    disp(conduction_velocities);
    
    conduction_velocities = reshape(conduction_velocities, [num_electrode_rows, num_electrode_cols]);
    
    disp('conduction velocities after reshape')
    disp(conduction_velocities);
    
    disp('dx')
    disp(dx_array)
    
    disp('dt b4 reshape')
    disp(dt_array)
    
    dt_array = reshape(dt_array, [num_electrode_rows, num_electrode_cols]);
    
    disp('dt b4 reshape')
    disp(dt_array)
    %}
    
    disp('elec ids b4 reshape');
    disp(electrode_ids);
    
    electrode_ids = reshape(electrode_ids, [num_electrode_rows, num_electrode_cols]);
    
    disp('elec ids after reshape');
    disp(electrode_ids);
    
    xlabels = {'1', '2', '3', '4'};
    ylabels = {'4', '3', '2', '1'};
    %heatmap(xlabels, ylabels, conduction_velocities);
    
    %quiv_ax = figure();
    %{
    tiledlayout(1,1)
    quiv_ax = nexttile;
    quiver(quiv_ax, quiver_X, quiver_Y, quiver_U, quiver_V)
    hold off;
    %}
    
    h_fig = figure();
    heatmap(h_fig, xlabels, ylabels, activation_times);
    %hold off;
    
    %{
    disp('X')
    disp(quiver_X)
    disp('Y')
    disp(quiver_Y)
    disp('U')
    disp(quiver_U)
    disp('V')
    disp(quiver_V)
    %}
    
    
    


end

function [quiver_X, quiver_Y, quiver_U, quiver_V] = calculate_vector(quiver_X, quiver_Y, quiver_U, quiver_V, e_r, e_c, activation_times, count, adj_col, adj_row)
    
    if adj_col == 1
        add_e_c = 4;
    elseif adj_col == 2
        add_e_c = 3;
    elseif adj_col == 3
        add_e_c = 2;
    elseif adj_col == 4
        add_e_c = 1;
    end

    dt = activation_times(adj_row*add_e_c)- activation_times(count);
    

    quiver_X = [quiver_X; e_r];
    quiver_Y = [quiver_Y; e_c];
    if adj_row == e_r
        X = 0;
    elseif adj_row < e_r
        X = -1;
    end
    if adj_col == e_c
        Y = 0;
    elseif adj_col > e_c
        Y = 1;
    end
    
    dx = sqrt((X)^2 + (Y)^2);    
    %v = dx/dt;
    v = dt;
    if isinf(v)
        disp('inf')
    end
    quiver_U = [quiver_U; v*X];
    quiver_V = [quiver_V; v*Y];

end