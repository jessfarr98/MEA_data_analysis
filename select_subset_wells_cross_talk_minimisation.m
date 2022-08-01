function select_subset_wells_cross_talk_minimisation(RawWellData, added_wells, num_well_rows, num_well_cols)

    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4)-100;
    
    
    wells_fig = uifigure;
    wells_fig.Name = 'Select MEA Wells';
    % left bottom width height
    main_pan = uipanel(wells_fig, 'BackgroundColor','#B02727', 'Position', [0 0 screen_width screen_height]);
    %main_pan.Scrollable = 'on';
    
    run_button = uibutton(main_pan, 'push','Text', 'Select Wells', 'Position',[screen_width-190 10 80 40], 'ButtonPushedFcn', @(run_button,event) runButtonPushed());
   
    
    p = uipanel(main_pan, 'BackgroundColor','#d43d3d', 'Position', [0 0 screen_width-200 screen_height]);
    %p.Scrollable = 'on';  
    
    count = 0;
    well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    
    added_wells = [];
    end_selection = 0;
    movegui(wells_fig,'center')
    wells_fig.WindowState = 'maximized';
    
    add_all_button = uibutton(p, 'push', 'BackgroundColor','#d43d3d', 'Text', 'Analyse All Wells', 'Position', [0 ((num_well_rows)*(screen_height/(num_well_rows+1))) (screen_width-200)/(num_well_cols+1) screen_height/(num_well_rows+1)], 'ButtonPushedFcn', @(add_all_button,event) addAllPushed(add_all_button, p));
        
    for w_r = 1:num_well_rows
        
        %sub_row_p = uipanel(p, 'BackgroundColor','#d43d3d', 'Title', sprintf('Add all in row %c', well_dictionary(w_r)), 'FontSize', 10,'Position', [0 ((w_r-1)*(screen_height/(num_well_rows+1))) (screen_width-200)/(num_well_cols+1) screen_height/(num_well_rows+1)]);
        add_row_button = uibutton(p, 'push', 'BackgroundColor','#dc6161', 'Text', sprintf('Analyse Row %c', well_dictionary(w_r)), 'Position', [0 ((w_r-1)*(screen_height/(num_well_rows+1))) (screen_width-200)/(num_well_cols+1) screen_height/(num_well_rows+1)], 'ButtonPushedFcn', @(add_row_button,event) addRowPushed(add_row_button, w_r, p));
            
        for w_c = 1:num_well_cols

            
            
            %%sub_col_p = uipanel(p, 'BackgroundColor','#d43d3d', 'Title', sprintf('Add all in column %d', w_c), 'FontSize', 10,'Position', [((w_c)*((screen_width-200)/(num_well_cols+1))) (screen_height-(screen_height/(num_well_rows+1))) (screen_width-200)/(num_well_cols+1) screen_height/(num_well_rows+1)]);
            add_col_button = uibutton(p, 'push', 'BackgroundColor','#dc6161', 'Text', sprintf('Analyse Column %d', w_c), 'Position', [((w_c)*((screen_width-200)/(num_well_cols+1))) (screen_height-(screen_height/(num_well_rows+1))) (screen_width-200)/(num_well_cols+1) screen_height/(num_well_rows+1)], 'ButtonPushedFcn', @(add_col_button,event) addColPushed(add_col_button, w_c, p));
          
            count = count + 1;
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            %sub_p = uipanel(p, 'BackgroundColor','#d43d3d', 'Title', wellID, 'FontSize', 10,'Position', [((w_c)*((screen_width-200)/(num_well_cols+1))) ((w_r-1)*(screen_height/(num_well_rows+1))) (screen_width-200)/(num_well_cols+1) screen_height/(num_well_rows+1)]);
            add_button = uibutton(p, 'push', 'BackgroundColor','#e68e8e', 'Text', sprintf('Analyse %s', wellID), 'Position',[((w_c)*((screen_width-200)/(num_well_cols+1))) ((w_r-1)*(screen_height/(num_well_rows+1))) (screen_width-200)/(num_well_cols+1) screen_height/(num_well_rows+1)], 'ButtonPushedFcn', @(add_button,event) addWellPushed(add_button, wellID));
            
            
        end
    end
    
    




end