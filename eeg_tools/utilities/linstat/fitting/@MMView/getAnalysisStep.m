function as = getAnalysisStep( v )
% getAnalysisStep - build an analysis step based on the current model and view
%
% Example
%       AnalysisStep NOT yet supported 

mm = setTheta( v.mm, getTheta(v.mm) );
mm = setData( mm, [] );
as = AnalysisStep( [], v.dims, v.view, mm);


