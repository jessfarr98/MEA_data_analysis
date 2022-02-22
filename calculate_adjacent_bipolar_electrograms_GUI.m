function calculate_adjacent_bipolar_electrograms_GUI(electrode_data, num_electrode_rows, num_electrode_cols)
    
    %electrode_pairs = ["1_1:1_2", "1_3:1_4", "2_1:2_2", "2_3:2_4", "3_1:3_2", "3_3:3_4", "4_1:4_2", "4_3:4_4"];
    electrode_pairs = ["1_1->2_1", "3_1->4_1", "1_2->2_2", "3_2->4_2", "1_3->2_3", "3_3->4_3", "1_4->2_4", "3_4->4_4"];
    
   
    %electrodes = ["1_1", "1_2", "1_3", "1_4", "2_1", "2_2", "2_3", "2_4", "3_1", "3_2", "3_3", "3_4", "4_1", "4_2", "4_3", "4_4"];
    electrodes = ["1_1", "2_1", "3_1", "4_1", "1_2", "2_2", "3_2", "4_2", "1_3", "2_3", "3_3", "4_3", "1_4", "2_4", "3_4", "4_4"];
    
    
    %electrode_data = BipolarData.empty(length(electrodes), 0);
    bipolar_data = BipolarData.empty(length(electrode_pairs), 0);

    for j = 1:(length(electrode_pairs))
        bipolar_data(j).electrode_id = '';
        bipolar_data(j).wave_form = [];
        bipolar_data(j).time = [];
    end
    bipolar_count = 0;
    
    while(1)
        
        if isempty(electrodes)
            break;
        end
        found_init = 0;
        
        init_count = 0;
        electrode_count = 0;
        %for e_r = 1:num_electrode_rows
        %    for e_c = num_electrode_cols:-1:1
        for e_r = num_electrode_rows:-1:1
            for e_c = 1:num_electrode_cols
                electrode_count = electrode_count+1;
                %electrode_id = strcat(num2str(e_r), '_', num2str(e_c));
                electrode_id = strcat(num2str(e_c), '_', num2str(e_r));
                yes_contains = contains(electrodes, electrode_id);
                init_elec = electrodes(yes_contains);
                electrodes = electrodes(~contains(electrodes, electrode_id));
                if ~isempty(init_elec)
                    init_bipolar_e_r = e_r;
                    init_bipolar_e_c = e_c;
                    init_count = electrode_count;
                    found_init = 1;
                    %disp(electrode_id)
                    break;
                end
                %WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
            end
            if found_init == 1
                break;
            end
        end

        found_pair1 = 0;
        found_pair2 = 0;
        
        electrode_count = 0;
        %for e_r = 1:num_electrode_rows
        %    for e_c = num_electrode_cols:-1:1
        for e_r = num_electrode_rows:-1:1
            for e_c = 1:num_electrode_cols
                electrode_count = electrode_count+1;
                %electrode_id = strcat(num2str(e_r), '_', num2str(e_c));
                electrode_id = strcat(num2str(e_c), '_', num2str(e_r));
                yes_contains = contains(electrodes, electrode_id);
                init_elec = electrodes(yes_contains);
                if ~isempty(init_elec)
                    if e_r == init_bipolar_e_r && e_c == init_bipolar_e_c
                        continue;
                    end
                    %pair1 = strcat(num2str(init_bipolar_e_r),'_',num2str(init_bipolar_e_c),':',num2str(e_r),'_',num2str(e_c));
                    pair1 = strcat(num2str(init_bipolar_e_c),'_',num2str(init_bipolar_e_r),'->',num2str(e_c),'_',num2str(e_r));
                    
                    
                    %pair2 = strcat(num2str(e_r),'_',num2str(e_c),':',num2str(init_bipolar_e_r),'_',num2str(init_bipolar_e_c));
                    pair2 = strcat(num2str(e_c),'_',num2str(e_r),'->',num2str(init_bipolar_e_c),'_',num2str(init_bipolar_e_r));
                    
                    
                    pair1_contains = contains(electrode_pairs, pair1);
                    pair_1_val = electrode_pairs(pair1_contains);
                    
                    pair2_contains = contains(electrode_pairs, pair2);
                    pair_2_val = electrode_pairs(pair2_contains);
                    
                    if ~isempty(pair_1_val)
                        %disp('adding')
                        %disp(pair1)
                        found_pair1 = 1;
                        bipolar_count = bipolar_count+1;
                        bipolar_data(bipolar_count).electrode_id = pair1;
                        
                        %WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                        %[time1, data1] = WellRawData.GetTimeVoltageVector;
                        time1 = electrode_data(electrode_count).time;
                        data1 = electrode_data(electrode_count).data;
                        
                        if isempty(time1)
                            electrodes = electrodes(~contains(electrodes, electrode_id));
                            continue;
                        end
                        
                        %{
                        figure();
                        plot(time1, data1)
                        title(strcat(num2str(init_bipolar_e_r),'_',num2str(init_bipolar_e_c)))
                        %}
                        
                        
                        %InitWellRawData = AllDataRaw{w_r, w_c, init_bipolar_e_r, init_bipolar_e_c};
                        %[time2, data2] = InitWellRawData.GetTimeVoltageVector;
                        time2 = electrode_data(init_count).time;
                        data2 = electrode_data(init_count).data;
                        
                        if isempty(time2)
                            electrodes = electrodes(~contains(electrodes, electrode_id));
                            continue;
                        end
                        
                        %{
                        figure();
                        plot(time2, data2)
                        title(strcat(num2str(e_r),'_',num2str(e_c)))
                        %}
                        
                        bipolar_data(bipolar_count).wave_form = data1-data2;
                        
                        bipolar_data(bipolar_count).time = time2;
                        
                        
                        
                        electrode_pairs = electrode_pairs(~contains(electrode_pairs, pair1));
                        %break;
                    end
                    if ~isempty(pair_2_val)
                        %disp('adding')
                        %disp(pair2)
                        found_pair2 = 1;
                        bipolar_count = bipolar_count+1;
                        bipolar_data(bipolar_count).electrode_id = pair2;
                        
                        %WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
                        %[time1, data1] = WellRawData.GetTimeVoltageVector;
                        time1 = electrode_data(electrode_count).time;
                        data1 = electrode_data(electrode_count).data;
                        
                        if isempty(time1)
                            electrodes = electrodes(~contains(electrodes, electrode_id));
                            continue;
                        end
                        
                        %{
                        figure();
                        plot(time1, data1)
                        title(strcat(num2str(e_r),'_',num2str(e_c)))
                        %}
                        
                        %InitWellRawData = AllDataRaw{w_r, w_c, init_bipolar_e_r, init_bipolar_e_c};
                        %[time2, data2] = InitWellRawData.GetTimeVoltageVector;
                        time2 = electrode_data(init_count).time;
                        data2 = electrode_data(init_count).data;
                        
                        if isempty(time2)
                            electrodes = electrodes(~contains(electrodes, electrode_id));
                            continue;
                        end
                        
                        %{
                        figure();
                        plot(time2, data2)
                        title(strcat(num2str(init_bipolar_e_r),'_',num2str(init_bipolar_e_c)))
                        %}
                        
                        bipolar_data(bipolar_count).wave_form = data2-data1;
                        
                        bipolar_data(bipolar_count).time = time2;
                        electrode_pairs = electrode_pairs(~contains(electrode_pairs, pair2));
                        %break;
                    end
 
                    
                end
                %WellRawData = AllDataRaw{w_r, w_c, e_r, e_c};
            end            
        end
    end
    
    %disp('remaining pairs')
    %disp(electrode_pairs)
    %disp('Plotting')
    
    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    
    bipolar_fig = uifigure;
    movegui(bipolar_fig,'center')
    main_p = uipanel(bipolar_fig, 'Position', [0 0 screen_width screen_height]);
    
    close_button = uibutton(main_p,'push','Text', 'Close', 'Position', [screen_width-180 100 120 50], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed(close_button, bipolar_fig));
     
    plots_width = screen_width - 200;
    
    plots_p = uipanel(main_p, 'Position', [0 0 plots_width screen_height]);
    
    %2 columns
    %3 rows
    %1 2
    %3 4
    %5 6
    for bp = 1:bipolar_count
        %disp(bipolar_data(bp).electrode_id);
        %figure();
        bp_row = ceil(bp/2);
        bp_col = mod(bp,2);
        if bp_col == 0
            bp_col = 2;
        end
        
        bp_pan = uipanel(plots_p, 'Title', bipolar_data(bp).electrode_id, 'Position', [(bp_col-1)*plots_width/2 (bp_row-1)*screen_height/4 plots_width/2 screen_height/4]);
                    
        bp_ax = uiaxes(bp_pan, 'Position', [0 0 plots_width/2 screen_height/4]);
                    
        plot(bp_ax, bipolar_data(bp).time, bipolar_data(bp).wave_form);
        %title(bp_ax, bipolar_data(bp).electrode_id)
        %title(strcat(bipolar_data(bp).electrode_id, {' '}, 'Bipolar Electrogram'));
        
    end
    bipolar_fig.WindowState = 'maximized';
    
    function closeButtonPushed(close_button, bipolar_fig)
        set(bipolar_fig, 'Visible', 'off');
    end
    

end