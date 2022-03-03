function MEA_GUI_Preview_Data(num_well_rows, num_well_cols, num_electrode_rows, num_electrode_cols, RawData)
    screen_size = get(groot, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4)-100;
    
    
    preview_wells_fig = uifigure;
    preview_wells_fig.Name = 'Select MEA Wells';
    movegui(preview_wells_fig,'center')
    preview_wells_fig.WindowState = 'maximized';
    % left bottom width height
    main_pan = uipanel(preview_wells_fig,  'BackgroundColor','#B02727', 'Position', [0 0 screen_width screen_height]);
    %main_pan.Scrollable = 'on';
    
    close_button = uibutton(main_pan,'push','Text', 'Close', 'Position',[screen_width-190 10 80 40], 'ButtonPushedFcn', @(close_button,event) closeButtonPushed());
   
    
    p = uipanel(main_pan, 'BackgroundColor','#d43d3d', 'Position', [0 0 screen_width-200 screen_height]);
    %p.Scrollable = 'on';  
    
    count = 0;
    well_dictionary = ['A', 'B', 'C', 'D', 'E', 'F'];
    
    end_well_view = 0;
    for w_r = 1:num_well_rows
        for w_c = 1:num_well_cols
            %RawWellData = RawData{w_r, w_c, :, :};
            count = count + 1;
            wellID = strcat(well_dictionary(w_r), '0', string(w_c));
            %sub_p = uipanel(p, 'BackgroundColor','#d43d3d', 'Title', wellID, 'FontSize', 10,'Position', [((w_c-1)*((screen_width-200)/num_well_cols)) ((w_r-1)*(screen_height/num_well_rows)) (screen_width-200)/num_well_cols screen_height/num_well_rows]);
            
            view_button = uibutton(p, 'push', 'BackgroundColor','#e68e8e', 'Text', sprintf('View %s Data', wellID), 'Position',[((w_c-1)*((screen_width-200)/num_well_cols)) ((w_r-1)*(screen_height/num_well_rows)) (screen_width-200)/num_well_cols screen_height/num_well_rows], 'ButtonPushedFcn', @(view_button,event) viewWellPushed(view_button, wellID, w_r, w_c, screen_width, screen_height, num_electrode_rows, num_electrode_cols));
            
            
        end
    end
    
    while(1)
        pause(0.001);
        if end_well_view == 1

            close(preview_wells_fig);
            return
        end
    end
    
    
    
    function viewWellPushed(add_button, wellID, w_r, w_c, screen_width, screen_height, num_electrode_rows, num_electrode_cols)
        %set(add_button, 'Visible', 'off');
        %set(remove_button, 'Visible', 'on');
        
        %preview_electrodes_fig = uifigure;
        %preview_electrodes_fig.Name = strcat('Preview_', wellID);
        %main_prev_pan = uipanel(preview_electrodes_fig, 'Position', [0 0 screen_width screen_height]);
        %main_prev_pan.Scrollable = 'on';

        well_fig = uifigure;
        movegui(well_fig,'center')
        well_fig.WindowState = 'maximized';
        well_fig.Name = strcat(wellID, {''}, 'BDT GUI');
        well_p = uipanel(well_fig, 'BackgroundColor','#d43d3d', 'Position', [0 0 screen_width screen_height]);
        
        close_well_button = uibutton(well_p,'push','Text', 'Close', 'Position',[screen_width-190 10 80 40], 'ButtonPushedFcn', @(close_well_button,event) closeWellButtonPushed(well_fig));

        well_ax = uiaxes(well_p, 'BackgroundColor','#d43d3d', 'Position', [10 100 screen_width-300 screen_height-200]);
        hold(well_ax, 'on');

        end_view = 0;

        time_offset = 0;
        max_voltage = NaN;
        min_voltage = NaN;
        for e_r = 1:num_electrode_rows
           for e_c = 1:num_electrode_cols
              RawWellData = RawData{w_r, w_c, e_r, e_c};

              if (strcmp(class(RawWellData),'Waveform'))
                  %if ~empty(WellRawData)
                  %disp(num_well_rows*num_well_cols)
                  %disp(count)
                  %electrode_id = strcat(wellID, '_', string(e_r), '_', string(e_c));
                  [time, data] = RawWellData.GetTimeVoltageVector;

                  time = time + time_offset;

                  data = data*1000;
                  %plot(time, data);
                  if isnan(max_voltage)
                      max_voltage = max(data);
                  else
                      if max(data) > max_voltage
                          max_voltage = max(data);
                      end
                  end
                  if isnan(min_voltage)
                      min_voltage = min(data);

                  else
                      if min(data) < min_voltage
                          min_voltage = min(data);
                      end
                  end
                  plot(well_ax,time(1:20:end),data(1:20:end));
                  %hold on;
                  %title(sub_ax, wellID);
                  %pause(10)
                  %plot(time, data);
                  time_offset = time_offset+0.015;

              else
                  %disp(wellID)
                  %disp('no data');
              end
           end
           xlabel(well_ax, 'Seconds (s)')
           ylabel(well_ax, 'milivolts (mV)')
        end
        
        while(1)
            pause(0.001);
            if end_view == 1

                close(well_fig);
                return
            end
        end
         
        
        function closeWellButtonPushed(well_fig)
            %set(well_fig, 'Visible', 'off')
            end_view = 1;
        end 
     end
 
 
  

    %{
    function removeWellPushed(remove_button, wellID, add_button)
        set(add_button, 'Visible', 'on');
        set(remove_button, 'Visible', 'off');
        added_wells = added_wells(~contains(added_wells, wellID));
    end
    %}

    function closeButtonPushed()
        %set(preview_wells_fig, 'Visible', 'off');
        end_well_view = 1;
        
    end


end