function conduction_map_GUI2(activation_times, num_electrode_rows, num_electrode_cols, spon_paced, well_elec_fig)
    % Calculate dx/dt for each electrode wrt. electrode in bottom left corner. 
    
    conduction_velocities = [];
    
    init_e_r = 1;
    init_e_c = 1;
    dx_array = [];
    dt_array = [];
    count = 1;
    electrode_ids = [];
    %disp(activation_times);
    
    % 4_1 is the stim electrode
    % for spontaneous the origin electrode is the one with earliest activation time.
    % negative values possible QC
    % Plot activation times.
    
    % WRONG - NEED TO TAKE FIRST ACTIVATION TIME FROM FIRST BEAT FOR EACH ELECTRODE AND THEN CALL THIS FUNCTION
    
    % 4_1 is the pacing electrode
    quiver_X = [];
    quiver_Y = [];
    quiver_U = [];
    quiver_V = [];
    if strcmp(spon_paced, 'paced') || strcmp(spon_paced, 'paced bdt')
        
        % Origin electrode analysis
        min_act = min(activation_times);
        %for e_r = 1:num_electrode_rows
        for e_r = num_electrode_rows:-1:1
            %for e_c = num_electrode_cols:-1:1
            for e_c = 1:num_electrode_cols
                if e_r == 4 && e_c == 1
                    dx = 0;
                    dt = activation_times(count)-min_act;
                else
                    dx = sqrt(e_r^2 + e_c^2);
                    dt = activation_times(count)-min_act;
                end
                %num2str(e_r)
                e_id = strcat(num2str(e_c),{' '},num2str(e_r));


                dx_array = [dx_array; dx];
                dt_array = [dt_array; dt];
                electrode_ids = [electrode_ids; e_id];
                count = count+1;
            end
        end
        
    elseif strcmp(spon_paced, 'spon')
        min_act = min(activation_times);
        min_act_indx = find(activation_times == min_act);
        
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

        for e_r = num_electrode_rows:-1:1
            %for e_c = num_electrode_cols:-1:1
            for e_c = 1:num_electrode_cols
                if e_r == init_e_r && e_c == init_e_c
                    %disp('count');
                    %disp(count);
                    dx = 0;
                    dt = activation_times(count)-activation_times(min_act_indx);
                else
                    dx = sqrt(e_r^2 + e_c^2);
                    dt = activation_times(count)-activation_times(min_act_indx);
                end
                %num2str(e_r)
                e_id = strcat(num2str(e_c),{' '},num2str(e_r));


                dx_array = [dx_array; dx];
                dt_array = [dt_array; dt];
                electrode_ids = [electrode_ids; e_id];
                count = count+1;
            end
        end
    end
    
    
    activation_times = reshape(activation_times, [num_electrode_cols, num_electrode_rows]);
    
    dt_array = reshape(dt_array, [num_electrode_rows, num_electrode_cols]);
    
    
    electrode_ids = reshape(electrode_ids, [num_electrode_cols, num_electrode_rows]);

    
    xlabels = {'1', '2', '3', '4'};
    ylabels = {'4', '3', '2', '1'};
    
    X = [1 2 3 4];
    Y = [4 3 2 1];
    
    % custom colour map code but try defaults
    
    %{
    construct a custom color map
    cmapG = [linspace(0,1,32)'; linspace(1,1,32)'];
    cmapB = [linspace(0,1,32)'; linspace(1,0,32)'];
    cmapR = [linspace(1,1,32)'; linspace(1,0,32)'];
    axR1.Colormap = [cmapR, cmapG, cmapB];
    axR1.CLim = [-1 1];
    %}

    
    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    
    
    con_fig = uifigure;
    con_pan = uipanel(con_fig, 'Position', [0 0 screen_width screen_height]);
    movegui(con_fig,'center')
    
    close_button = uibutton(con_pan,'push','Text', 'Close', 'Position', [screen_width-180 100 120 50], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed(close_button, well_elec_fig, con_fig));
         
    fig_width = screen_width-200;
    fig_pan = uipanel(con_pan, 'Position', [0 0 fig_width screen_height]);
    
    act_pan = uipanel(fig_pan, 'Title','Start Activation Times','Position', [0 0 fig_width/2 screen_height-100]);
    act_ax = uiaxes(act_pan, 'Position', [0 0 (fig_width/2)-10 screen_height-10]);
    contourf(act_ax, X, Y, transpose(activation_times), 'LineStyle', 'none')
    colorbar(act_ax)      
    colormap(act_ax, jet)
    %h_fig = figure();
    %heatmap(act_pan, xlabels, ylabels, transpose(activation_times), 'Colormap',summer);

    
    dt_pan = uipanel(fig_pan, 'Title','Start Act Times-min Act Time','Position',[fig_width/2 0 fig_width/2 screen_height-100]);
    dt_ax = uiaxes(dt_pan, 'Position', [0 0 (fig_width/2)-10 screen_height-10]);
    %heatmap(dt_pan, xlabels, ylabels, transpose(dt_array));
    con_fig.WindowState = 'maximized';
    contourf(dt_ax, X,Y, transpose(dt_array), 'LineStyle', 'none')
    colorbar(dt_ax)
    colormap(dt_ax, jet)
    %hold off;
    
    
    
    function closeButtonPushed(close_button, well_elec_fig, con_fig)
        %set(con_fig, 'Visible', 'off');
        delete(close_button);
        close(con_fig);
        %set(well_elec_fig, 'Visible', 'on');
    end

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
        %disp('inf')
    end
    quiver_U = [quiver_U; v*X];
    quiver_V = [quiver_V; v*Y];

end