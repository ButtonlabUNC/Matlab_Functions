function Import = Import_Data(path, name, varargin)
% batch imports data when given a path and name. useful for mostly
% importing multiple files. imports are stored in a single struct and must
% be re asigned if desired. 

% optional argument "type" defines file type to use most optimal routine
% for import. currently supports CSV, XLXS, and mat files


Import =  struct;                                                           % sets destination of imported files to an import struct

%% input parsing
Import_Data_InputParser = inputParser;
Import_Data_InputParser.KeepUnmatched = true;

Path_Validation_Function = @(x) (isstring(x) || ischar(x)) && isvector(x); 
addRequired(Import_Data_InputParser,"path",  Path_Validation_Function)                            % path for all desired Import Files must be a vertical array


Name_Validation_Function = ...
    @(x) ((isstring(x) || ischar(x))) && isvector(x) && numel(x) == numel(path);
addRequired(Import_Data_InputParser, "name", Name_Validation_Function)                            % name for all desired Import Files must be a vertical array equal in size to paths

optional_parameter_1 = "type";              
Default_type = "csv";
Valid_types = ["csv", "xls", "mat"];
Type_Validation_function = ...
    @(x) (isstring(x) || ischar(x)) && ...
          numel(x) == 1 && any(strcmp(x, Valid_types));
addParameter(Import_Data_InputParser, optional_parameter_1, Default_type, Type_Validation_function) % optionally specify type of data to be imported can be csv, xlsx, or mat files

parse(Import_Data_InputParser, path, name, varargin{:})

%% Import
    for k1 = 1:numel(Import_Data_InputParser.Results.path)                                        % import routines for each data type
        if width(Import_Data_InputParser.Results.path) > 1
            Import_Data_InputParser.Results.path = transpose(Import_Data_InputParser.Results.path);
        end
        if width(Import_Data_InputParser.Results.name) > 1
            Import_Data_InputParser.Results.name = transpose(Import_Data_InputParser.Results.name);
        end
        if strcmp(Import_Data_InputParser.Results.(optional_parameter_1), Valid_types(1))
            Temp_Load = readtable(Import_Data_InputParser.Results.path(k1));
            Import.(Import_Data_InputParser.Results.name(k1)) = Temp_Load;
    
        elseif strcmp(Import_Data_InputParser.Results.(optional_parameter_1), Valid_types(2))
            Temp_Load = xlsread(Import_Data_InputParser.Results.path(k1));
            Import.(Import_Data_InputParser.Results.name(k1)) = Temp_Load;
    
        elseif strcmp(Import_Data_InputParser.Results.(optional_parameter_1), Valid_types(3))                       % mat file import if struct is imported fields are moved up on level to reduce number of field names
            Temp_Load = load(Import_Data_InputParser.Results.path(k1));
            Loaded_Fields = fieldnames(Temp_Load);
            if isstruct(Temp_Load)
                Temp_Load = Temp_Load.(Loaded_Fields{1});
                import_fields = fieldnames(Temp_Load);

                for k2 = 1:numel(import_fields)
                    Import.(Import_Data_InputParser.Results.name(k1)).(import_fields{k2}) = ...
                        Temp_Load.(import_fields{k2});
                end
            end
        end    
    end
end