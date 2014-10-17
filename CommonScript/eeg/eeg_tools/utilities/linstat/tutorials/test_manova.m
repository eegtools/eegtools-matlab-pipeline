%% TEST_MANOVA

try
    % 2-way with interactions
    % used dog.jmp as an example
    % checked E (sse), H(ssr) and
    % Drug ss(:,:,1),

    load cole_grizzle.mat
    glm_new = encode( y, 3, 2, drug, dep );
    m_new   = manova(glm_new);

    load manova_test_results

    if ~isequal(m_new.ss,m2.ss)
        error( 'unit_tests:manova:ss', 'SSCP matrices for factors not equal');
    end;

    if ~mat_compare(m_new.ssr,m2.ssr)
        error( 'unit_tests:manova:ssr', 'SSCP matrices for regression (H) are not equal');
    end;

    if ~mat_compare(m_new.sse,m2.sse)
        error( 'unit_tests:manova:ss', 'SSCP matrices for error (E) are not equal');
    end;

    disp('passed: manova');
catch
    disp('failed: manova' );
end;