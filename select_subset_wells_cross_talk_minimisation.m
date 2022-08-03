function select_subset_wells_cross_talk_minimisation(prompt_cross_talk_fig, RawWellData, Stims, added_wells, num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, bipolar, save_dir, save_base_dir, parameter_input_method)

    %close prompt_cross_talk_fig;
    close all
    close all hidden;
    
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
    
    minimise_wells = [];
    end_selection = 0;
    movegui(wells_fig,'center')
    wells_fig.WindowState = 'maximized';
    
    add_all_button = uibutton(p, 'push', 'BackgroundColor','#d43d3d', 'Text', 'Analyse All Wells', 'Position', [0 ((num_well_rows)*(screen_height/(num_well_rows+1))) (screen_width-200)/(num_well_cols+1) screen_height/(num_well_rows+1)], 'ButtonPushedFcn', @(add_all_button,event) addAllPushed(add_all_button, p));
        
    for w_r = 1:num_well_rows
        
        for w_c = 1:num_well_cols

            
           
            count = count + 1;
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            if ~ismember(wellID, added_wells)
               continue 
            end
            
            %sub_p = uipanel(p, 'BackgroundColor','#d43d3d', 'Title', wellID, 'FontSize', 10,'Position', [((w_c)*((screen_width-200)/(num_well_cols+1))) ((w_r-1)*(screen_height/(num_well_rows+1))) (screen_width-200)/(num_well_cols+1) screen_height/(num_well_rows+1)]);
            add_button = uibutton(p, 'push', 'BackgroundColor','#e68e8e', 'Text', sprintf('Analyse %s', wellID), 'Position',[((w_c)*((screen_width-200)/(num_well_cols+1))) ((w_r-1)*(screen_height/(num_well_rows+1))) (screen_width-200)/(num_well_cols+1) screen_height/(num_well_rows+1)], 'ButtonPushedFcn', @(add_button,event) addWellPushed(add_button, wellID));
            
            
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
                    if ~ismember(wellID, added_wells)
                        continue
                    end
                    if ~isempty(minimise_wells)
                        if ismember(wellID, minimise_wells)
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
                    
                    if ~ismember(wellID, added_wells)
                        continue
                    end
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
            if ~isempty(minimise_wells)
                if ismember(wellID, minimise_wells)
                    set(add_button, 'Text', sprintf('Remove %s', wellID));
                    set(add_button, 'BackgroundColor','#B02727');
                    return
                end
            end
            set(add_button, 'Text', sprintf('Remove %s', wellID));
            set(add_button, 'BackgroundColor','#B02727');
            minimise_wells = [minimise_wells; wellID];
        elseif strcmp(get(add_button, 'Text'), sprintf('Remove %s', wellID))
            set(add_button, 'Text', sprintf('Analyse %s', wellID));
            set(add_button, 'BackgroundColor','#e68e8e');
            minimise_wells = minimise_wells(~contains(minimise_wells, wellID));
        end
        
        
    end

    function runButtonPushed()
        minimise_cross_talk(wells_fig, RawWellData, Stims, added_wells, minimise_wells, num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, bipolar, save_dir, save_base_dir, parameter_input_method);
        
    end


end