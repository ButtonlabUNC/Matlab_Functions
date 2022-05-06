% By Mark Gutay 2022 04 13

% highly automated percent solids function with options for mesh weight
% subtraction and percent organics with definable solvent. define dir for
% ease of use.

function [Result, Result_debug] = Auto_Percent_Solids(Dir,varargin)

if ismac
error("funciton only supported on Windows OS")                              % script relies on "uigetfile" to for defining file paths. as of 2022 04 13 matlab version R2022a this function only works on windows operating systems
end

Auto_Percent_Solids_inputparser = inputParser;                              % creats inputparser object

Required_Arg_1_Validation = @(x) (ischar(x) || isstring(x)) ;               % dir must be a string or character array
addRequired(Auto_Percent_Solids_inputparser, ...
    "Dir", Required_Arg_1_Validation)

Optional_Arg_1 = "Mesh_Mode";
Optional_Arg_1_Default_Val = false;
Optional_Arg_1_Validation_Function = @(x) islogical(x);
addParameter(Auto_Percent_Solids_inputparser, ...
    Optional_Arg_1, Optional_Arg_1_Default_Val, ...
    Optional_Arg_1_Validation_Function)                                     % Mesh_Mode is an optional argument specifying if the script must find values for mesh weights. must be a logical value                                                                            
    
Optional_Arg_2 = "Percent_Organics";
Optional_Arg_2_Default_Val = false;
Optional_Arg_2_Default_Validation_Function = @(x) islogical(x);
addParameter(Auto_Percent_Solids_inputparser, ...
    Optional_Arg_2, Optional_Arg_2_Default_Val, ...
    Optional_Arg_2_Default_Validation_Function)                             % Percent_Organics is an optional argument specifying if the script must calculate percent organics using user specified or default solvent solids value. must be a logical value
                                                                            

Optional_Arg_3 = "Solvent_Solids";
Optional_Arg_3_Default_Val = 0.9;                                           % must be equal to the Percent_Solids function value for variable "Solvent_Solids" function or it will overwrite
Optoinal_Arg_3_Validation_Function = @(x)...
    isnumeric(x) && isscalar(x);
addParameter(Auto_Percent_Solids_inputparser, ...
    Optional_Arg_3, Optional_Arg_3_Default_Val, ...
    Optoinal_Arg_3_Validation_Function)                                     % Solvent_Solids is an optional argument specifying value for the solvent solids variable will default to 0.9(PBS salt solids). must be a numeric scalar                                                     

parse(Auto_Percent_Solids_inputparser, Dir, varargin{:});                   % parses the function inputs and validates based on Validation functions. check variable(s) *_Validation_Function for more informatin

[Wet_File, Wet_Dir] = ...
    uigetfile(strcat(...
        Auto_Percent_Solids_inputparser.Results.Dir,'\*.xlsx'));            % prompts user to select a file using a file browser window
    Wet_Path = strcat(Wet_Dir,Wet_File);                                    % combines parent Dir and file name to make a valid file path

[Dry_File, Dry_Dir] = ...
    uigetfile(strcat(...
        Auto_Percent_Solids_inputparser.Results.Dir,'\*.xlsx'));            % prompts user to select a file using a file browser window
    Dry_Path = strcat(Dry_Dir, Dry_File);                                   % combines parent Dir and file name to make a valid file path

   
if Auto_Percent_Solids_inputparser.Results.(Optional_Arg_1)                        % only prompts user to select xlsx file containing mesh weight data
mesh_weight_path = uigetfile('*.xlsx');                                     % prompts user to select a file using a file browser window
    mesh_weight = xlsread(mesh_weight_path);                                % combines parent Dir and file name to make a valid file path
end

Solvent_Solids =  Auto_Percent_Solids_inputparser.Results.(Optional_Arg_3);   % Separates data for passing into sub function

%% Passing inputs 
% passes discovered paths and input arguments in to the default
% Percent_Solids function. With correct optional argument syntax for
% Percent_Solids fucntion

if Auto_Percent_Solids_inputparser.Results.(Optional_Arg_1) && Auto_Percent_Solids_inputparser.Results.(Optional_Arg_2) 
% Mesh subtraction and Percent Organics additional calculations
[Result, Result_debug] = Percent_Solids(...
    Wet_Path, Dry_Path, ...
    "Mesh_Weight", mesh_weight, "Mesh_Mode", true, ...
    "Percent_Organics", true, ...
    "Solvent_Solids", Solvent_Solids);

elseif Auto_Percent_Solids_inputparser.Results.(Optional_Arg_1) && ~Auto_Percent_Solids_inputparser.Results.(Optional_Arg_2)
% only mesh subraction without Percent Ogranics additional calculations
    [Result, Result_debug] = Percent_Solids(...
    Wet_Path, Dry_Path, ...
    "Mesh_Weight", mesh_weight, "Mesh_Mode", true);

elseif ~Auto_Percent_Solids_inputparser.Results.(Optional_Arg_1) && Auto_Percent_Solids_inputparser.Results.(Optional_Arg_2)
% only Percent Organics without mesh subtraction additional calculation
    [Result, Result_debug] = Percent_Solids(...
    Wet_Path, Dry_Path, ...
    "Percent_Organics", true, ...
    "Solvent_Solids", Solvent_Solids);

elseif ~(Auto_Percent_Solids_inputparser.Results.Mesh_Mode && Auto_Percent_Solids_inputparser.Results.(Optional_Arg_2))
% no Mesh subtraction nor Percent Organics additional calcultion
    [Result, Result_debug] = Percent_Solids(...
    Wet_Path, Dry_Path);


end