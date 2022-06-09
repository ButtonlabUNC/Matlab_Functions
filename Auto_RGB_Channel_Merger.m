function RGB_Composite_Image = Auto_RGB_Channel_Merger(Selected_Channels, varargin)
%% Input Parsing
Auto_RGB_Channel_merger_InputParser = inputParser;

Required_Arg_1_Validation_Function = @(x) isequal(size(x), [3, 1]) || ...
    isequal(size(x), [1, 3]);
addRequired(Auto_RGB_Channel_merger_InputParser, "Selected_Channels", ...
    Required_Arg_1_Validation_Function)

Optional_Arg_2 = "Color_Channel_multiplier";
Optional_Arg_2_Default_Val = [5; 1; 1];
% Optional_Arg_4_Validation_Function = @(x) isstring(x) || ischar(x) && ...
%     isscalar(x);
addParameter(Auto_RGB_Channel_merger_InputParser, Optional_Arg_2, ...
    Optional_Arg_2_Default_Val)

parse(Auto_RGB_Channel_merger_InputParser, Selected_Channels,  varargin{:})

%% Input actions
Selected_Channels_logic = ...
    Auto_RGB_Channel_merger_InputParser.Results.Selected_Channels;
if Selected_Channels_logic(1)
   [Red_filename,Red_folder] = uigetfile("*.*");
    Red_Channel_Path = strcat(Red_folder, Red_filename);
else
    Red_Channel_Path = '';
end
if Selected_Channels_logic(2)
   [Green_filename,Green_folder] = uigetfile("*.*");
    Green_Channel_Path = strcat(Green_folder, Green_filename);
else
    Green_Channel_Path = '';
end
if Selected_Channels_logic(3)
   [Blue_filename,Blue_folder] = uigetfile("*.*");
    Blue_Channel_Path = strcat(Blue_folder, Blue_filename);
else
    Blue_Channel_Path = '';
end

 RGB_Composite_Image = RGB_Channel_Merger(...
     "Red_Channel_Path", Red_Channel_Path, ...
    "Green_Channel_Path", Green_Channel_Path, ...
    "Blue_Channel_Path", Blue_Channel_Path, ...
    "Color_Channel_multiplier", ...
    Auto_RGB_Channel_merger_InputParser.Results.Color_Channel_multiplier);
end