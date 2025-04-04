function conduction_map_GUI4(all_activation_times, num_electrode_rows, num_electrode_cols, spon_paced, well_elec_fig, hmap_prompt_fig, num_beats, start_beat, map_type, ave_waves)
    % Calculate dx/dt for each electrode wrt. electrode in bottom left corner. 
    if ave_waves == 0
        close(hmap_prompt_fig)
    end
    
    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    
    screen_width = 1700;
    screen_height = 1300;
    
    con_fig = uifigure;
    
    con_pan = uipanel(con_fig, 'Position', [0 0 screen_width screen_height-20], 'BackgroundColor', '#fbeaea');
    movegui(con_fig,'center')
    
    close_button = uibutton(con_pan,'push','Text', 'Close', 'Position', [screen_width-160 100 120 50], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed(close_button, well_elec_fig, con_fig));
         

    
    fig_width = screen_width-200;
    fig_pan = uipanel(con_pan, 'Position', [0 0 fig_width screen_height], 'BackgroundColor', '#fbeaea');
    
    con_fig.Position = [0, 0, screen_width, screen_height];
    set(con_fig, 'AutoResizeChildren', 'off'); 
    
    %{
    act_base_pan = uipanel(fig_pan, 'Title','Start Activation Times','Position', [0 0 fig_width/2 screen_height-80]);
    
    act_main_pan = uipanel(act_base_pan, 'Position', [0 0 fig_width/2 screen_height-100]);
    


    dt_base_pan = uipanel(fig_pan, 'Title','Start Act Times-min Act Time','Position',[fig_width/2 0 fig_width/2 screen_height-80]);
    
    dt_main_pan = uipanel(dt_base_pan, 'Position',[0 0 fig_width/2 screen_height-100]);
    %}

    if strcmp(map_type, 'depol')
        dt_base_pan = uipanel(fig_pan, 'Title','Start Act Times-min Act Time','Position',[0 0 fig_width screen_height-80]);
    else
        dt_base_pan = uipanel(fig_pan, 'Title','FPD Isochrone Maps','Position',[0 0 fig_width screen_height-80]);
    end
    
    dt_main_pan = uipanel(dt_base_pan, 'Position',[0 0 fig_width screen_height-100]);
    
    
    wait_bar = waitbar(0, 'Generating isochrome maps');
    num_partitions = 1/(num_beats);
    partition = num_partitions;
    max_c_lim = nan;
    min_c_lim = nan;
    
    dt_struct_array = [];
    for n = 1:num_beats
        %waitbar(partition, wait_bar, strcat('Loading Beat No.', {' '}, num2str(n+start_beat-1)));
        %partition = partition + num_partitions;
        
        activation_times = [all_activation_times{n, :}];
        
        
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
            max_act = max(activation_times);
            
            min_dt = nan;
            max_dt = nan;
            %for e_r = 1:num_electrode_rows
            for e_r = num_electrode_rows:-1:1
                %for e_c = num_electrode_cols:-1:1
                for e_c = 1:num_electrode_cols
                    if e_r == 4 && e_c == 1
                        dx = 0;
                        if strcmp(map_type, 'depol')
                            dt = activation_times(count)-min_act;
                        elseif strcmp(map_type, 'fpd')
                            dt = activation_times(count);
                            
                        end
                    else
                        dx = sqrt(e_r^2 + e_c^2);
                        if strcmp(map_type, 'depol')
                            dt = activation_times(count)-min_act;
                        elseif strcmp(map_type, 'fpd')
                            dt = activation_times(count);
                            
                        end
                    end
                    
                    if isnan(min_dt)
                        max_dt = dt;
                        min_dt = dt;
                    else
                        
                        if dt > max_dt
                            max_dt = dt;
                        end
                        
                        if dt < min_dt
                            min_dt = dt;
                        end
                    end 
                    %num2str(e_r)
                    e_id = strcat(num2str(e_c),{' '},num2str(e_r));
                    %dt = round(dt, 2, 'significant');

                    dx_array = [dx_array; dx];
                    dt_array = [dt_array; dt];
                    electrode_ids = [electrode_ids; e_id];
                    count = count+1;
                end
            end

        elseif strcmp(spon_paced, 'spon')
            min_act = min(activation_times);
            max_act = max(activation_times);
            min_act_indx = find(activation_times == min_act, 1);
            
            min_dt = nan;
            max_dt = nan;

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
                        if strcmp(map_type, 'depol')
                            dt = activation_times(count)-activation_times(min_act_indx(1));
                        else
                            dt = activation_times(count);
                        end
                    else
                        dx = sqrt(e_r^2 + e_c^2);
                        if strcmp(map_type, 'depol')
                            dt = activation_times(count)-activation_times(min_act_indx(1));
                        else
                            dt = activation_times(count);
                        end
                    end
                    %dt = round(dt, 2, 'significant');
                    %num2str(e_r)
                    if isnan(min_dt)
                        max_dt = dt;
                        min_dt = dt;
                    else
                        
                        if dt > max_dt
                            max_dt = dt;
                        end
                        
                        if dt < min_dt
                            min_dt = dt;
                        end
                    end 
                    e_id = strcat(num2str(e_c),{' '},num2str(e_r));


                    dx_array = [dx_array; dx];
                    dt_array = [dt_array; dt];
                    electrode_ids = [electrode_ids; e_id];
                    count = count+1;
                end
            end
        end
        if isnan(max_c_lim)
            
            max_c_lim = max_dt;
            min_c_lim = min_dt;
        else
            if max_dt > max_c_lim
                max_c_lim = max_dt;
            end
            if min_dt < min_c_lim
                
                min_c_lim = min_dt;
            end
            
        end


        activation_times = reshape(activation_times, [num_electrode_cols, num_electrode_rows]);

        dt_array = reshape(dt_array, [num_electrode_rows, num_electrode_cols]);


        electrode_ids = reshape(electrode_ids, [num_electrode_cols, num_electrode_rows]);


        xlabels = {'1', '2', '3', '4'};
        ylabels = {'4', '3', '2', '1'};

        X = [1 2 3 4];
        Y = [4 3 2 1];

        if max_act == min_act
            level_diff = 2000;
        else
            level_diff = 10/(max_act-min_act);
        end
        
        if level_diff > 2000
            level_diff = 2000;
        end


        %{
        if num_beats <= 5
            %disp((((fig_width/2)-10)/num_beats)*(num_beats-1))
            %act_pan = uipanel(act_main_pan, 'Position', [(((fig_width/2)-10)/num_beats)*(n-1) 0 ((fig_width/2)-10)/num_beats screen_height-10]);
            
            
            %{
            act_ax = uiaxes(act_main_pan, 'Position', [(((fig_width/2)-10)/num_beats)*(n-1) 0 ((fig_width/2)-10)/num_beats screen_height-200]);
            contourf(act_ax, X, Y, transpose(activation_times), level_diff, 'LineStyle', 'none')
            colorbar(act_ax)      
            colormap(act_ax, hsv)
           
            
            
            
            %dt_pan = uipanel(dt_main_pan, 'Position', [(((fig_width/2)-10)/num_beats)*(n-1) 0 ((fig_width/2)-10)/num_beats screen_height-10]);
            dt_ax = uiaxes(dt_main_pan, 'Position', [(((fig_width/2)-10)/num_beats)*(n-1) 0 ((fig_width/2)-10)/num_beats screen_height-200]);
            %heatmap(dt_pan, xlabels, ylabels, transpose(dt_array));
            
            contourf(dt_ax, X,Y, transpose(dt_array), level_diff, 'LineStyle', 'none')
            
            tick_array = [];
  
            for tick = min_dt:(max_dt-min_dt)/7:max_dt
                
               tick_array = [tick_array, tick];
            end
          
            %tick_array = [tick_array, max_dt]
            %tick_array = round(tick_array, 3, 'significant');
            %colorbar(dt_ax, 'TickLabels', tick_array, 'Limits', [min_dt max_dt], 'Ticks', [0, (screen_height-200)/7, (screen_height-200)/6, (screen_height-200)/5, (screen_height-200)/4, (screen_height-200)/3, (screen_height-200)/2, (screen_height-200)/1])
            
            colorbar(dt_ax, 'TickLabels', tick_array, 'Limits', [min_dt max_dt], 'Ticks', tick_array);
            
            
            %colorbar(dt_ax, 'LimitsMode', 'manual','TickLabels', [min_dt:(max_dt-min_dt)/7:max_dt])
            colormap(dt_ax, hsv)
            %}
            
            dt_ax = uiaxes(dt_main_pan, 'Position', [(((fig_width)-10)/num_beats)*(n-1) 0 ((fig_width)-10)/num_beats screen_height-200]);
            %heatmap(dt_pan, xlabels, ylabels, transpose(dt_array));
            
            contourf(dt_ax, X,Y, transpose(dt_array), level_diff, 'LineStyle', 'none')
            
            tick_array = [];
  
            for tick = min_dt:(max_dt-min_dt)/7:max_dt
                
               tick_array = [tick_array, tick];
            end
          
            colorbar(dt_ax, 'TickLabels', tick_array, 'Limits', [min_dt max_dt], 'Ticks', tick_array);
            colormap(dt_ax, hsv)
            title(dt_ax, strcat('Propagation map for beat No.', {' '}, num2str(n+start_beat-1), {' '}, '(min activation time = ', {' '}, num2str(min_act), ')'))
        else

            n_rows = ceil(num_beats/5);
   
            row_num = floor(n/5);
            
            row_num = n_rows-row_num;
            
            col_num = mod(n,5);
            if col_num == 0
                col_num = 5;
                row_num = row_num+1;
            end
            
            %act_pan = uipanel(act_main_pan, 'Position', [(((fig_width/2)-10)/5)*(col_num-1) ((screen_height-100)/n_rows)*(row_num-1) ((fig_width/2)-10)/5 (screen_height-100)/n_rows]);
            
            %{
            act_ax = uiaxes(act_main_pan, 'Position', [(((fig_width/2)-10)/5)*(col_num-1) (((screen_height-110)/n_rows))*(row_num-1) ((fig_width/2)-10)/5 ((screen_height-110)/n_rows)]);
            contourf(act_ax, X, Y, transpose(activation_times), level_diff, 'LineStyle', 'none')
            colorbar(act_ax)      
            colormap(act_ax, hsv)

            %dt_pan = uipanel(dt_main_pan, 'Position', [(((fig_width/2)-10)/5)*(col_num-1) ((screen_height-100)/n_rows)*(row_num-1) ((fig_width/2)-10)/5 (screen_height-100)/n_rows]);
            dt_ax = uiaxes(dt_main_pan, 'Position', [(((fig_width/2)-10)/5)*(col_num-1) (((screen_height-110)/n_rows))*(row_num-1) ((fig_width/2)-10)/5 ((screen_height-110)/n_rows)]);
            %heatmap(dt_pan, xlabels, ylabels, transpose(dt_array));
            
            contourf(dt_ax, X,Y, transpose(dt_array), level_diff, 'LineStyle', 'none')
            tick_array = [];
            for tick = min_dt:(max_dt-min_dt)/7:max_dt
                
               tick_array = [tick_array, tick];
            end

            colorbar(dt_ax, 'TickLabels', tick_array, 'Limits', [min_dt max_dt], 'Ticks', tick_array);
            colormap(dt_ax, hsv)
             
            %}
            
            dt_ax = uiaxes(dt_main_pan, 'Position', [(((fig_width)-10)/5)*(col_num-1) (((screen_height-110)/n_rows))*(row_num-1) ((fig_width)-10)/5 ((screen_height-110)/n_rows)]);
            
            contourf(dt_ax, X,Y, transpose(dt_array), level_diff, 'LineStyle', 'none')
            tick_array = [];
            for tick = min_dt:(max_dt-min_dt)/7:max_dt
                
               tick_array = [tick_array, tick];
            end

            colorbar(dt_ax, 'TickLabels', tick_array, 'Limits', [min_dt max_dt], 'Ticks', tick_array);
            colormap(dt_ax, hsv)
            title(dt_ax, strcat('Propagation map for beat No.', {' '}, num2str(n+start_beat-1), {' '}, '(min activation time = ', {' '}, num2str(min_act), ')'))
            
        end
        %}
        
        
        dt_struct.dt = dt_array;
        dt_struct.level_diff = level_diff;
        dt_struct.min_act = min_act;
        dt_struct_array = [dt_struct_array; dt_struct];

    end
    
    tick_array = [];
    for tick = min_c_lim:(max_c_lim-min_c_lim)/7:max_c_lim

       tick_array = [tick_array, tick];
    end

    for n = 1:num_beats
        waitbar(partition, wait_bar, strcat('Loading Beat No.', {' '}, num2str(n+start_beat-1)));
        
        partition = partition + num_partitions;
        
        min_act = dt_struct_array(n).min_act;
        dt_array = dt_struct_array(n).dt;
        level_diff = dt_struct_array(n).level_diff;
        if num_beats <= 5

            
            dt_ax = uiaxes(dt_main_pan, 'Position', [(((fig_width)-10)/num_beats)*(n-1) 0 ((fig_width)-10)/num_beats screen_height-200]);
            %heatmap(dt_pan, xlabels, ylabels, transpose(dt_array));
            
            contourf(dt_ax, X,Y, transpose(dt_array), level_diff, 'LineStyle', 'none')
            
          
            colorbar(dt_ax, 'TickLabels', tick_array, 'Ticks', tick_array, 'Limits', [min_c_lim max_c_lim]);
            colormap(dt_ax, jet)
            caxis(dt_ax, [min_c_lim max_c_lim])
            if strcmp(map_type, 'depol')
                title(dt_ax, strcat('Propagation map for beat No.', {' '}, num2str(n+start_beat-1), {' '}, '(min activation time = ', {' '}, num2str(min_act), ')'), 'FontSize', 8)
            else
                
                title(dt_ax, strcat('FPD Isochrone map for beat No.', {' '}, num2str(n+start_beat-1), {' '}, '(min FPD = ', {' '}, num2str(min_act), ')'),  'FontSize', 8)
            end
        else

            n_rows = ceil(num_beats/5);
   
            row_num = floor(n/5);
            
            row_num = n_rows-row_num;
            
            col_num = mod(n,5);
            if col_num == 0
                col_num = 5;
                row_num = row_num+1;
            end
            
            
            dt_ax = uiaxes(dt_main_pan, 'Position', [(((fig_width)-10)/5)*(col_num-1) (((screen_height-110)/n_rows))*(row_num-1) ((fig_width)-10)/5 ((screen_height-110)/n_rows)]);
            
            contourf(dt_ax, X,Y, transpose(dt_array), level_diff, 'LineStyle', 'none')

            colorbar(dt_ax, 'TickLabels', tick_array, 'Ticks', tick_array, 'Limits', [min_c_lim max_c_lim]);
            colormap(dt_ax, jet)
            caxis(dt_ax, [min_c_lim max_c_lim])
            if strcmp(map_type, 'depol')
                title(dt_ax, strcat('Propagation map for beat No.', {' '}, num2str(n+start_beat-1), {' '}, '(min activation time = ', {' '}, num2str(min_act), ')'),  'FontSize', 8)
            else
                
                title(dt_ax, strcat('FPD Isochrone map for beat No.', {' '}, num2str(n+start_beat-1), {' '}, '(min FPD = ', {' '}, num2str(min_act), ')'),  'FontSize', 8)
            end
            
            
        end
        
        
    end
    %caxis()
    
    %{
    ax_children = get(dt_main_pan, 'children');
    
    pause(10)
    max_c_lim
    min_c_lim
    tick_array = [];
    for tick = min_c_lim:(max_c_lim-min_c_lim)/7:max_c_lim

       tick_array = [tick_array, tick];
    end
    for c = 1:length(ax_children)
        ax = ax_children(c);
        

        colorbar(ax, 'TickLabels', tick_array, 'Limits', [min_c_lim max_c_lim], 'Ticks', tick_array);
        caxis(ax, [min_c_lim max_c_lim]);
        
    end
    %}
    
    close(wait_bar);

    %set(con_fig, 'Visible', 'on')

    %full_spectrum_button = uibutton(con_pan,'push','Text', 'Full Spectrum', 'Position', [screen_width-180 200 120 50], 'ButtonPushedFcn', @(full_spectrum_button,event) fullSpectrumPushed(full_spectrum_button, act_main_pan, dt_main_pan));
    full_spectrum_button = uibutton(con_pan,'push','Text', 'Full Spectrum', 'Position', [screen_width-180 200 120 50], 'ButtonPushedFcn', @(full_spectrum_button,event) fullSpectrumPushed(full_spectrum_button, '', dt_main_pan, tick_array));
    
    set(full_spectrum_button, 'Visible', 'off')
    
    %RG_colourblind_button = uibutton(con_pan,'push','Text', 'RG ColourBlind Friendly', 'Position', [screen_width-180 200 120 50], 'ButtonPushedFcn', @(RG_colourblind_button,event) RGColourBlindPushed(RG_colourblind_button, act_main_pan, dt_main_pan));
    %RG_colourblind_button = uibutton(con_pan,'push','Text', 'RG ColourBlind Friendly', 'Position', [screen_width-180 200 120 50], 'ButtonPushedFcn', @(RG_colourblind_button,event) RGColourBlindPushed(RG_colourblind_button, '', dt_main_pan, tick_array));
    
    
    %con_fig.WindowState = 'maximized';
    
    %{
    if num_beats > 1
        act_video_button = uibutton(con_pan,'push','Text', 'Activation Times Video', 'Position', [screen_width-180 300 120 50], 'ButtonPushedFcn', @(act_video_button,event) ActVideoPushed(act_video_button, act_main_pan));
    
        
    end
    %}
    
    %set(con_fig, 'Visible', 'on')

    
    
    function closeButtonPushed(close_button, well_elec_fig, con_fig)
        %set(con_fig, 'Visible', 'off');
        delete(close_button);
        close(con_fig);
        %set(well_elec_fig, 'Visible', 'on');
    end

    function RGColourBlindPushed(RG_colourblind_button, act_main_pan, dt_main_pan, tick_array)
        
        custom_map = [];
        
        
        og = 0.17;

        % transition shades
        for ogt = og:0.01:1
            custom_map = [custom_map; 1 ogt 0];
        end

        %yellow
        for yc = 0:0.01:1
            if isempty(custom_map)
                custom_map = [1 1 yc];
            else
                custom_map = [custom_map; 1 1 yc];
            end
        end

        %cyan
        for cc = 1:-0.01:0

            custom_map = [custom_map; cc 1 1];

        end

        %blue
        for bc = 1:-0.01:0

            custom_map = [custom_map; 0 bc 1];

        end

        %black
        for bb = 1:-0.01:0
            custom_map = [custom_map; 0 0 bb];

        end
        set(RG_colourblind_button, 'Visible', 'off')
        set(full_spectrum_button, 'Visible', 'on')
        
        
  
        %act_axes = get(act_main_pan, 'Children');
        dt_axes = get(dt_main_pan, 'Children');
        for a = 1:length(dt_axes)
            %colormap(act_axes(a), custom_map)
            colormap(dt_axes(a), custom_map)
            %colorbar(dt_axes(a), 'TickLabels', tick_array, 'Ticks', tick_array, 'Limits', [min_c_lim max_c_lim]);
            %colorbar(dt_axes(a), 'TickLabels', tick_array, 'Ticks', tick_array, 'Limits', [min_c_lim max_c_lim]);
            
            %caxis(dt_axes(a), [min_c_lim max_c_lim])
            
        end
        
        
        
    end

    function  fullSpectrumPushed(full_spectrum_button, act_main_pan, dt_main_pan,tick_array)
        set(full_spectrum_button, 'Visible', 'off')
        set(RG_colourblind_button, 'Visible', 'on')
        
        %act_axes = get(act_main_pan, 'Children');
        dt_axes = get(dt_main_pan, 'Children');
        
        for a = 1:length(dt_axes)
            %colormap(act_axes(a), hsv)
            colormap(dt_axes(a), jet)
            %colorbar(dt_axes(a), 'TickLabels', tick_array, 'Ticks', tick_array, 'Limits', [min_c_lim max_c_lim]);
            %caxis(dt_axes(a), [min_c_lim max_c_lim])
        end
        
        
    end

    function  ActVideoPushed(act_video_button, act_main_pan)

        
        act_axes = get(act_main_pan, 'Children');
        custom_map = [];
        
        
        og = 0.17;

        % transition shades
        for ogt = og:0.01:1
            custom_map = [custom_map; 1 ogt 0];
        end

        %yellow
        for yc = 0:0.01:1
            if isempty(custom_map)
                custom_map = [1 1 yc];
            else
                custom_map = [custom_map; 1 1 yc];
            end
        end

        %cyan
        for cc = 1:-0.01:0

            custom_map = [custom_map; cc 1 1];

        end

        %blue
        for bc = 1:-0.01:0

            custom_map = [custom_map; 0 bc 1];

        end

        %black
        for bb = 1:-0.01:0
            custom_map = [custom_map; 0 0 bb];

        end
        
        act_vid_figure = uifigure;
        movegui(act_vid_figure, 'center');
        act_vid_figure.WindowState = 'maximized';
        act_vid_pan = uipanel(act_vid_figure, 'Position', [0 0 screen_width screen_height-20]);
        close_act_vid_button = uibutton(act_vid_figure,'push','Text', 'Close', 'Position', [screen_width-180 100 120 50], 'ButtonPushedFcn', @(close_act_vid_button,event) closeButtonPushed(close_act_vid_button, '', act_vid_figure));
        %fig = figure;
        for a = 1:length(dt_axes)
            
            %ax = copygraphics(act_axes(a));
            %ax.Parent = act_vid_pan;
            %disp(get(act_axes(a).properties));
            %properties(act_axes(a))
            
            axobjs = get(act_axes(a), 'children');
            
            properties(axobjs)
            
            %cmap = act_axes(a).Colormap;
            %zgrid = act_axes(a).ZGrid
            

            act_vid_ax = uiaxes(act_vid_pan, 'Position', [0 0 screen_width-500 screen_height-20]);
            contourf(act_vid_ax, axobjs.XData, axobjs.YData, axobjs.ZData, axobjs.LabelSpacing, 'linestyle', 'none')
            
            if strcmp(get(RG_colourblind_button, 'Visible'), 'off')
                colormap(act_vid_ax, custom_map)
                
            else
                colormap(act_vid_ax, hsv)
                
            end
            %colormap(act_vid_ax, cmap)
            pause(1)
            
        end

        
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