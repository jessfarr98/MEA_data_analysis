function [added_wells] = MEA_GUI_select_wells(num_well_rows, num_well_cols)
    

    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4)-100;
    
    
    wells_fig = uifigure;
    wells_fig.Name = 'Select MEA Wells';
    % left bottom width height
    main_pan = uipanel(wells_fig, 'Position', [0 0 screen_width screen_height]);
    main_pan.Scrollable = 'on';
    
    run_button = uibutton(main_pan,'push','Text', 'Select Wells', 'Position',[screen_width-190 10 80 40], 'ButtonPushedFcn', @(run_button,event) runButtonPushed());
   
    
    p = uipanel(main_pan, 'Position', [0 0 screen_width-200 screen_height]);
    p.Scrollable = 'on';  
    
    count = 0;
    well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    
    added_wells = [];
    end_selection = 0;
    for w_r = 1:num_well_rows
        for w_c = 1:num_well_cols
          
            count = count + 1;
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            sub_p = uipanel(p, 'Title', wellID, 'FontSize', 10,'Position', [((w_c-1)*((screen_width-200)/num_well_cols)) ((w_r-1)*(screen_height/num_well_rows)) (screen_width-200)/num_well_cols screen_height/num_well_rows]);
            add_button = uibutton(sub_p, 'push','Text', 'Add 2 Analysis', 'Position',[2 15 ((screen_width-200)/num_well_cols)-10 (screen_height/num_well_rows)-19], 'ButtonPushedFcn', @(add_button,event) addWellPushed(add_button, wellID));
            
            
        end
    end
    disp(added_wells);
    
    while(1)
        pause(0.001);
        if end_selection == 1
            disp(added_wells);
            if isempty(added_wells)
                added_wells = 'all';
            end
            return
        end
    end
    
    function addWellPushed(add_button, wellID)
        %set(add_button, 'Visible', 'off');
        %set(remove_button, 'Visible', 'on');
        if strcmp(get(add_button, 'Text'), 'Add 2 Analysis')
            set(add_button, 'Text', 'Remove from Analysis');
            added_wells = [added_wells; wellID];
        elseif strcmp(get(add_button, 'Text'), 'Remove from Analysis')
            set(add_button, 'Text', 'Add 2 Analysis');
            added_wells = added_wells(~contains(added_wells, wellID));
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