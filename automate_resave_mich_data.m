function automate_resave_mich_data()
%fullfile('F:', 'MX', '95-8605', 'paced', '20220603_95-8605_post-drug_paced(000).raw'), fullfile('F:', 'MX', '95-8605', 'paced', 'Matlab_Analysis', 'post-drug_paced'

    %redo_plates(fullfile('F:', 'MX', '95-8605', 'paced', '20220603_95-8605_post-drug_paced(000).raw'), fullfile('F:', 'MX', '95-8605', 'paced', 'Matlab_Analysis', 'post-drug_paced'))

    %redo_plates(fullfile('F:', 'MX', '95-8605', 'paced', '20220603_95-8605_pre-drug_paced(000).raw'), fullfile('F:', 'MX', '95-8605', 'paced', 'Matlab_Analysis', 'pre-drug_paced'))

    %redo_plates(fullfile('F:', 'MX', '95-8605', 'paced', '20220603_95-8605_post-drug_paced_60mins(000).raw'), fullfile('F:', 'MX', '95-8605', 'paced', 'Matlab_Analysis', 'post-drug_paced_60mins'))
    
    %redo_plates(fullfile('F:', 'MX', '96-1851', 'paced', '20220727_96-1851_pre-drug_paced(000).raw'), fullfile('F:', 'MX', '96-1851', 'paced', 'Matlab_Analysis', 'pre-drug_paced'))
    
    redo_plates(fullfile('F:', 'MX', '95-8605', 'spon', '20220603_95-8605_pre-drug_spon(000).raw'), fullfile('F:', 'MX', '95-8605', 'spon', 'Matlab_Analysis', 'pre-drug_spon'))
    
    %redo_plates(fullfile('F:', 'MX', '95-8605', 'spon', '20220603_95-8605_post-drug_paced_60mins(000).raw'), fullfile('F:', 'MX', '95-8605', 'paced', 'Matlab_Analysis', 'vehicle'))
    
end


function redo_plates(raw_data_file, results_files_dir)

    list_xlsx_files = dir(fullfile(results_files_dir, '*.xlsx'));
    
    for f = 1:length(list_xlsx_files)
        disp(list_xlsx_files(f).name)
        resave_michelles_data_with_averages(raw_data_file, fullfile(results_files_dir, list_xlsx_files(f).name))
    end



end