function run_several_comparisons()
    close('all')
    %compare_stimulus_artifacts(fullfile('Y:', 'Recordings for Jess', 'cardiac paced_paced ME 600us(000).raw'), fullfile('Y:', 'Recordings for Jess', 'cardiac paced_paced ME 600us_artifact eliminator(000).raw'), 'Compare paced paced ME 600us(000))')
    
    %compare_stimulus_artifacts(fullfile('Y:', 'Recordings for Jess', 'cardiac paced_paced ME 2000us(001).raw'), fullfile('Y:', 'Recordings for Jess', 'cardiac paced_paced ME 2000us_artifact eliminator(001).raw'), 'Compare paced paced ME 2000us(001))')
    
    %compare_stimulus_artifacts(fullfile('Y:', 'Recordings for Jess', 'cardiac paced_paced SP 600us(001).raw'), fullfile('Y:', 'Recordings for Jess', 'cardiac paced_paced SP 600us_artifact eliminator(001).raw'), 'Compare paced paced SP 600us(001))')
    
    %compare_stimulus_artifacts(fullfile('Y:', 'Recordings for Jess', 'cardiac standard_paced ME 600us(000).raw'), fullfile('Y:', 'Recordings for Jess', 'cardiac standard_paced ME 600us_artifact eliminator(000).raw'), 'Compare standard paced ME 600us(000))')
    
    %compare_stimulus_artifacts(fullfile('Y:', 'Recordings for Jess', 'cardiac standard_paced ME 2000us(000).raw'), fullfile('Y:', 'Recordings for Jess', 'cardiac standard_paced ME 2000us_artifact eliminator(000).raw'), 'Compare standard paced ME 2000us(000))')
    
    compare_stimulus_artifacts(fullfile('Y:', 'Recordings for Jess', 'cardiac standard_paced SP 600us(001).raw'), fullfile('Y:', 'Recordings for Jess', 'cardiac standard_paced SP 600us_artifact eliminator(001).raw'), 'Compare standard paced SP 600us(001))')
    

end