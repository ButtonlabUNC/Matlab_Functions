function [Result, Result_debug] = Auto_Percent_Organics(Dir,varargin)

if ismac  
error("funciton only supported on Windows OS")                              % script relies on "uigetfile" to for defining file paths. as of 2022 04 13 matlab version R2022a this function only works on windows operating systems
end

Auto_Percent_Organics_inputparser = inputParser;                              % creats inputparser object

Required_Arg_1_Validation = @(x) (ischar(x) || isstring(x)) ;               % dir must be a string or character array
addRequired(Auto_Percent_Organics_inputparser, ...
    "Dir", Required_Arg_1_Validation)

Optional_Arg_1 = "Mesh_Mode";
Optional_Arg_1_Default_Val = false;
Optional_Arg_1_Validation_Function = @(x) islogical(x);
addParameter(Auto_Percent_Organics_inputparser, ...
    Optional_Arg_1, Optional_Arg_1_Default_Val, ...
    Optional_Arg_1_Validation_Function)                                     % Mesh_Mode is an optional argument specifying if the script must find values for mesh weights. must be a logical value                                                                            
    
Optional_Arg_2 = "Percent_Organics";
Optional_Arg_2_Default_Val = false;
Optional_Arg_2_Default_Validation_Function = @(x) islogical(x);
addParameter(Auto_Percent_Organics_inputparser, ...
    Optional_Arg_2, Optional_Arg_2_Default_Val, ...
    Optional_Arg_2_Default_Validation_Function)                             % Percent_Organics is an optional argument specifying if the script must calculate percent organics using user specified or default solvent solids value. must be a logical value
                                                                            

Optional_Arg_3 = "Solvent_Solids";
Optional_Arg_3_Default_Val = 0.9;                                           % must be equal to the Percent_Solids function value for variable "Solvent_Solids" function or it will overwrite
Optoinal_Arg_3_Validation_Function = @(x)...
    isnumeric(x) && isscalar(x);
addParameter(Auto_Percent_Organics_inputparser, ...
    Optional_Arg_3, Optional_Arg_3_Default_Val, ...
    Optoinal_Arg_3_Validation_Function)                                     % Solvent_Solids is an optional argument specifying value for the solvent solids variable will default to 0.9(PBS salt solids). must be a numeric scalar                                                     

parse(Auto_Percent_Organics_inputparser, Dir, varargin{:});                   % parses the function inputs and validates based on Validation functions. check variable(s) *_Validation_Function for more informatin

[Result, Result_debug] = Auto_Percent_Solids(Dir,"Percent_Organics", true, ...
     "Mesh_Mode", Auto_Percent_Organics_inputparser.Results.Mesh_Mode, ...
    "Percent_Organics", Auto_Percent_Organics_inputparser.Results.Percent_Organics);

end
