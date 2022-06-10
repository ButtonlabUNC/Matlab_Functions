% By Mark Gutay
% Function to quicky find dependencies for functions or scripts by using
% windows file explorder to select file of intrest

function Dependencies  = Dependency_Analyzer(File_Path)
%% Input Validation
Dependency_Analyzer_InputParser = inputParser;

Required_Input_1_Validation_Function = @(x) (ischar(x) || isstring(x)) ...
    && isscalar(x);
addRequired(Dependency_Analyzer_InputParser, ...
    "Path", Required_Input_1_Validation_Function)

parse(Dependency_Analyzer_InputParser, File_Path)
%% Operation
files = Dependency_Analyzer_InputParser.Results.Path;

[~, pList] = matlab.codetools.requiredFilesAndProducts(files);

Dependencies = pList.Name;
end
