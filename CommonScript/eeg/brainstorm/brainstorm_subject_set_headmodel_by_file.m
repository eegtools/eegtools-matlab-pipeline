function headmodel_id = brainstorm_subject_set_headmodel_by_file(protocol_name, subj_name, headmodel_file)

    headmodel_id = 0;
    iProtocol = brainstorm_protocol_open(protocol_name);
    [sStudy, iStudy, iData] = bst_get('DefaultStudy', subj_name);
    num_hm=length(sStudy.HeadModel);
    for hm=1:num_hm
        if strcmp([subj_name '/@default_study/' headmodel_file], sStudy.HeadModel(hm).FileName)
            sStudy.iHeadModel=hm;
            headmodel_id = hm;
            bst_set('Study',iStudy,sStudy);
            break;
        end
    end
end
