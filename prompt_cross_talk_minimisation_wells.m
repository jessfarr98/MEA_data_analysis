function prompt_cross_talk_minimisation_wells(RawData, Stims, added_wells, num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, bipolar, save_dir, save_base_dir, parameter_input_method)

    close all;
    close all hidden;
    
    prompt_cross_talk_fig = uifigure;

    prompt_cross_talk_fig.Name = 'Choose Cross Talk Wells';

    % Move the window to the center of the screen.
    movegui(prompt_cross_talk_fig,'center')
    
    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
   
    prompt_cross_talk_pan = uipanel(prompt_cross_talk_fig, 'BackgroundColor','#B02727', 'Position', [0 0 screen_width screen_height]);
    set(prompt_cross_talk_pan, 'AutoResizeChildren', 'off');   
    
    check_text = uieditfield(prompt_cross_talk_pan,'Text','Position',[80 310 500 50], 'Value',"Perform Cross Talk Minimisation on all selected wells or a subset?", 'Editable','off');
    all_button = uibutton(prompt_cross_talk_pan,'push','Text', 'All', 'Position',[100 250 50 50], 'ButtonPushedFcn', @(all_button,event) allButtonPushed(all_button, prompt_cross_talk_fig));
    subset_button = uibutton(prompt_cross_talk_pan,'push','Text', 'Subset', 'Position',[150 250 50 50], 'ButtonPushedFcn', @(subset_button,event) subsetButtonPushed(subset_button, prompt_cross_talk_fig));


    function allButtonPushed(all_button, prompt_cross_talk_fig)
        %close prompt_cross_talk_fig
        minimise_cross_talk(prompt_cross_talk_fig, RawData, Stims, added_wells, num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, bipolar, save_dir, save_base_dir, parameter_input_method);

    end

    function subsetButtonPushed(all_button, prompt_cross_talk_fig)

        select_subset_wells_cross_talk_minimisation(prompt_cross_talk_fig, RawData, Stims, added_wells, num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, bipolar, save_dir, save_base_dir, parameter_input_method);
        %minimise_cross_talk(RawData, minimise_wells, beat_to_beat, spon_paced, analyse_all_b2b, stable_ave_analysis, bipolar, save_dir, save_base_dir);

    end

end

