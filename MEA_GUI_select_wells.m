function [added_wells] = MEA_GUI_select_wells(num_well_rows, num_well_cols)
    

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
    
    
    
    while(1)
        pause(0.001);
        if end_selection == 1
            disp(added_wells);
            if isempty(added_wells)
                added_wells = 'all';
            end
            close(wells_fig);
            return
        end
    end
    
    function addAllPushed(add_all_button, panel)
        panel_children = get(panel, 'children');
            
        titles = get(panel_children, 'text');
        
        if strcmp(get(add_all_button, 'Text'), 'Analyse All Wells')
            set(add_all_button, 'Text', 'Remove All Wells');
            set(add_all_button, 'BackgroundColor','#B02727');
            
            for w_r = 1:num_well_rows
                for w_c = 1:num_well_cols
                    wellID = strcat(well_dictionary(w_r), '0', string(w_c));
                    if ~isempty(added_wells)
                        if ismember(wellID, added_wells)
                           continue; 
                        end
                    end
                    %added_wells = [added_wells; wellID];
                    button_indx = find(contains(titles, wellID));
                    button = panel_children(button_indx);

                    if ismember('Analyse', get(button, 'text'))

                        addWellPushed(button, wellID)

                    end

                end
            end
        else
            set(add_all_button, 'Text', 'Analyse All Wells');
            set(add_all_button, 'BackgroundColor','#d43d3d');
            
            for w_r = 1:num_well_rows
                for w_c = 1:num_well_cols
                    wellID = strcat(well_dictionary(w_r), '0', string(w_c));
                    
                    %added_wells = [added_wells; wellID];
                    button_indx = find(contains(titles, wellID));
                    button = panel_children(button_indx);

                    if ismember('Remove', get(button, 'text'))

                        addWellPushed(button, wellID)

                    end

                end
            end
        end
        
    end
    
    function addWellPushed(add_button, wellID)
        %set(add_button, 'Visible', 'off');
        %set(remove_button, 'Visible', 'on');
        if strcmp(get(add_button, 'Text'), sprintf('Analyse %s', wellID))
            if ~isempty(added_wells)
                if ismember(wellID, added_wells)
                    set(add_button, 'Text', sprintf('Remove %s', wellID));
                    set(add_button, 'BackgroundColor','#B02727');
                    return
                end
            end
            set(add_button, 'Text', sprintf('Remove %s', wellID));
            set(add_button, 'BackgroundColor','#B02727');
            added_wells = [added_wells; wellID];
        elseif strcmp(get(add_button, 'Text'), sprintf('Remove %s', wellID))
            set(add_button, 'Text', sprintf('Analyse %s', wellID));
            set(add_button, 'BackgroundColor','#e68e8e');
            added_wells = added_wells(~contains(added_wells, wellID));
        end
        
        
    end
    function addColPushed(add_button, col, panel)
        %set(add_button, 'Visible', 'off');
        %set(remove_button, 'Visible', 'on');
        panel_children = get(panel, 'children');
            
        titles = get(panel_children, 'text');
        if strcmp(get(add_button, 'Text'), sprintf('Analyse Column %d', col))
            set(add_button, 'Text', sprintf('Remove Column %d', col));
            set(add_button, 'BackgroundColor','#B02727');
            
            for w_r = 1:num_well_rows
                wellID = strcat(well_dictionary(w_r), '0', string(col));
                if ~isempty(added_wells)
                    if ismember(wellID, added_wells)
                       continue; 
                    end
                end
                %added_wells = [added_wells; wellID];
                button_indx = find(contains(titles, wellID));
                button = panel_children(button_indx);
                
                if ismember('Analyse', get(button, 'text'))
                    
                    addWellPushed(button, wellID)
                    
                end
                
            end
        elseif strcmp(get(add_button, 'Text'), sprintf('Remove Column %d', col))
            set(add_button, 'Text', sprintf('Analyse Column %d', col));
            set(add_button, 'BackgroundColor','#dc6161');
            for w_r = 1:num_well_rows
                wellID = strcat(well_dictionary(w_r), '0', string(col));
                button_indx = find(contains(titles, wellID));
                button = panel_children(button_indx);
                
                if ismember('Remove', get(button, 'text'))
                    
                    addWellPushed(button, wellID)
                    
                end
                %added_wells = added_wells(~contains(added_wells, wellID));
            end
        end
        
        
    end
    function addRowPushed(add_button, row, panel)
        %set(add_button, 'Visible', 'off');
        %set(remove_button, 'Visible', 'on');
        
        panel_children = get(panel, 'children');
            
        titles = get(panel_children, 'text');
        if strcmp(get(add_button, 'Text'), sprintf('Analyse Row %c', well_dictionary(row)))
            set(add_button, 'Text', sprintf('Remove Row %c', well_dictionary(row)));
            set(add_button, 'BackgroundColor','#B02727');
            
            
            %titles = titles(~contains(titles, 'Row'));
            %titles = titles(~contains(titles, 'Column'));
            
            
            for w_c = 1:num_well_cols
                wellID = strcat(well_dictionary(row), '0', string(w_c));
                if ~isempty(added_wells)
                    if ismember(wellID, added_wells)
                       continue; 
                    end
                end
                button_indx = find(contains(titles, wellID));
                button = panel_children(button_indx);
                
                if ismember('Analyse', get(button, 'text'))
                    
                    addWellPushed(button, wellID)
                    
                end
                
                
                
                %added_wells = [added_wells; wellID];
                
                %addWellPushed(add_button, wellID)
            end
        elseif strcmp(get(add_button, 'Text'), sprintf('Remove Row %c', well_dictionary(row)))
            set(add_button, 'Text', sprintf('Analyse Row %c', well_dictionary(row)));
            set(add_button, 'BackgroundColor','#dc6161');
            
            for w_c = 1:num_well_cols
                wellID = strcat(well_dictionary(row), '0', string(w_c));
                
                button_indx = find(contains(titles, wellID));
                button = panel_children(button_indx);
                
                if ismember('Remove', get(button, 'text'))
                    
                    addWellPushed(button, wellID)
                    
                end
                %added_wells = added_wells(~contains(added_wells, wellID));
            end
        end
        
        
    end

    %{
    function removeWellPushed(remove_button, wellID, add_button)
        set(add_button, 'Visible', 'on');
        set(remove_button, 'Visible', 'off');
        added_wells = added_wells(~contains(added_wells, wellID));
    end
    %}

    function runButtonPushed()
        set(wells_fig, 'Visible', 'off');
        end_selection = 1;
        
    end

end