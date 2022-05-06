function [Inport] = XLSX_Importer(Data_Path, varargin)
XLSX_Importer_ImportParser = inputParser;

Required_Arg_1_Validation_Function = @(x) (ischar(x) || isstring(x)) && ...
    isscalar(x);
addRequired(XLSX_Importer_ImportParser, "Data_Path",...
    Required_Arg_1_Validation_Function)


parse(XLSX_Importer_ImportParser,Data_Path,varargin)

%% Evaluate XLSX file
Sheet_Names = sheetnames(XLSX_Importer_ImportParser.Results.Data_Path);
fieldnames = matlab.lang.makeValidName(Sheet_Names);

%% Preallocation
Inport = struct;

%% Import
for k1 = 1:numel(fieldnames)
Inport.(fieldnames{k1}) = readtable(...
    XLSX_Importer_ImportParser.Results.Data_Path, ...
    "Sheet", fieldnames(k1));
end
end