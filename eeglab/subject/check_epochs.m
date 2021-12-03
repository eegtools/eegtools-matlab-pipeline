if (strcmp(project.paths.script.project, ...
        'C:\behaviourPlatform\VisuoHaptic\claudio\Loc_Bis_Bimodale_eeg\processing\MATLAB\' ))
    if exist('test_Loc_Bis_Bimodale_eeg4','file')
%         test_Loc_Bis_Bimodale_eeg2;
%           test_Loc_Bis_Bimodale_eeg3;
test_Loc_Bis_Bimodale_eeg4;
    end
end


% if (strcmp(project.paths.script.project, ...
%         'C:\behaviourPlatform\VisuoHaptic\claudio\lateblind_abbi\' ))
%     if exist('test_lateblind_abbi_pre2','file')
%         test_lateblind_abbi_pre2;
%     end
%     if exist('test_lateblind_abbi_post3','file')
%         test_lateblind_abbi_post3;
%     end
% end


% if (strcmp(project.paths.script.project, ...
%         'C:\behaviourPlatform\VisuoHaptic\claudio\lateblind_abbi\' ))
%     if exist('test_lateblind_abbi_pre2_brainstorm','file')
%         test_lateblind_abbi_pre2_brainstorm;
%     end
%     if exist('test_lateblind_abbi_pre2_brainstorm','file')
%         test_lateblind_abbi_post3_brainstorm;
%     end
% end


% if (strcmp(project.paths.script.project, ...
%         'C:\behaviourPlatform\VisuoHaptic\claudio\lateblind_abbi\' ))
%     if exist('test_lateblind_abbi_pre2_cluster','file')
%         test_lateblind_abbi_pre2_cluster;
%     end
%     if exist('test_lateblind_abbi_post3_cluster','file')
%         test_lateblind_abbi_post3_cluster;
%     end
% end


if (strcmp(project.paths.script.project, ...
        'C:\behaviourPlatform\VisuoHaptic\claudio\lateblind_abbi\' ))
    if exist('test_lateblind_abbi_pre3_brainstorm','file')
        test_lateblind_abbi_pre3_brainstorm;
    end
    if exist('test_lateblind_abbi_post4_brainstorm','file')
        test_lateblind_abbi_post4_brainstorm;
    end
end



%% old
if strcmp(project.paths.script.project,'C:\behaviourPlatform\VisuoHaptic\claudio\acop\')
    test_acop6_raw_viola
end



if strcmp(project.paths.script.project,'C:\behaviourPlatform\VisuoHaptic\claudio\bisezione_s_eb\')
    test_bisezione_s
    test_bisezione_eb
    % test_bisezione_s_barinstorm
    % test_bisezione_eb_brainstrorm
end



if strcmp(project.paths.script.project,'C:\behaviourPlatform\VisuoHaptic\claudio\bisezione_led_sordi_udenti\')
    test_bisezione_h_barinstorm
    test_bisezione_d_brainstrorm
end





if strcmp(project.paths.script.project,'C:\behaviourPlatform\VisuoHaptic\claudio\bisezione_fronte_retro_eeg\')
    testfr2_fronte
    %     testfr2_retro
end




if strcmp(project.paths.script.project,'C:\behaviourPlatform\VisuoHaptic\claudio\Bisezione_Bimodale_eeg\processing\MATLAB\')
%     test_bis_bimodale;
%         test_bis_bimodale2;
% test_bis_bimodale4;
% test_bis_bimodale4_brainstorm;
% test_bis_bimodale5_brainstorm;
% test_bis_bimodale7_brainstorm; % ok provo passare a versione 8 a aumentare un po' i temporali
% a destra, da vedere qiuesto scala 5 di source
% NO  test_bis_bimodale8_brainstorm; NO meglio il 7
% test_bis_bimodale5; s2 riduce att risp s1 nell'altra corteccia

% test_bis_bimodale9_brainstorm; % ok mappette e tutta analisis di scalpo provoa vedere se riesco a tiraree indiretro sorgenti temporali
test_bis_bimodale8;
end

if strcmp(project.paths.script.project, 'C:\behaviourPlatform\VisuoHaptic\claudio\bisezione_led_controlli\')...
% test_bisezione_lb_led5_pre_contatenati;
% test_bisezione_lb_led6_pre_contatenati;
% test_bisezione_lb_xx_pre_contatenati;
% test_bisezione_lb_led_raw_ws_uvip10_pre_concatenati;
% test_bisezione_lb_led4_pre_conc;
% test_bisezione_lb_led3_pc
% test_controlli_bs2_equal_occ3_pc;
% test_bisezione_lb_led_raw_ws_uvip4_pc ... no ha coda ma ha secondo picco
% e troppo quadrato
% test_bisezione_lb_led2_pc ...no! molto lontano manca secondo picco
% test_bisezione_lb_led_raw_ws_uvip9_pc
% test_bisezione_lb_led_raw_ws_uvip8_pc
% test_bisezione_lb_led_raw_ws_uvip7_pc
% test_bisezione_lb_led5_bs_pre_conc
% test_bisezione_lb_led4_pc
% test_bisezione_lb_led3_pc
% test_bisezione_lb_led5_pre_concatenati
% test_controlli_bs2_equal_occ3_pc
% test_bisezione_lb_led6_pre_contatenati
% test_controlli_bs2_equal_occ2_pc
% test_bisezione_lb_led3_pc
% test_bisezione_lb_led2_pc
% test_bisezione_lb_led4_bs_pc
% test_bisezione_lb_led4_ms_pc
% test_bisezione_lb_led4_conc
% test_bisezione_lb_led4_pc
% test_bisezione_lb_led4_conc
% test_bisezione_lb_led4_conc2
% test_bisezione_lb_led4_conc3
% test_bisezione_lb_led4_conc4
% test_bisezione_lb_led4_conc5
% test_bisezione_lb_led4_conc6
% test_bisezione_lb_led4_conc7
% test_bisezione_lb_led4_conc8
% test_bisezione_lb_led4_conc9
test_bisezione_lb_led4_conc10


end
























































































% test_lb8_ms_ok_mappette_anche_s1_curve_meno_smooth_conflitto
% test_lb8_ms_ok_mappette_anche_s1_curve_conflitto
% test_lb8_ms_ok_mappette_anche_s1_conflitto
% test_lb8_ms_ok_mappette_conflitto
% test_lb8_mappette_conflitto
% test_lb8_ms_ok_mappette_anche_s1_curve_regola_smooth_conflitto;


% if (strcmp(project.paths.script.project, 'C:\behaviourPlatform\VisuoHaptic\claudio\lateblind_abbi\'))
% % test_lateblind_abbi_pre;
% % test_lateblind_abbi_post;
% test_lateblind_abbi_post2;
% end





if (strcmp(project.paths.script.project, 'C:\behaviourPlatform\VisuoHaptic\claudio\Bisezione_tattile_eeg\'))
test_bisezione_s4;
end




































































































