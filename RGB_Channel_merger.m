function RGB_Composite_Image = RGB_Channel_merger(varargin)
%% Input Parsing
RGB_Channel_merger_InputParser = inputParser;

Optional_Arg_1 = "Red_Channel_Path";
Optional_Arg_1_Default_Val = '';
% Optional_Arg_1_Validation_Function = @(x) isstring(x) || ischar(x) && ...
%     isscalar(x);
addParameter(RGB_Channel_merger_InputParser, Optional_Arg_1, ...
    Optional_Arg_1_Default_Val)

Optional_Arg_2 = "Green_Channel_Path";
Optional_Arg_2_Default_Val = '';
% Optional_Arg_2_Validation_Function = @(x) isstring(x) || ischar(x) && ...
%     isscalar(x);
addParameter(RGB_Channel_merger_InputParser, Optional_Arg_2, ...
    Optional_Arg_2_Default_Val)

Optional_Arg_3 = "Blue_Channel_Path";
Optional_Arg_3_Default_Val = '';
% Optional_Arg_3_Validation_Function = @(x) isstring(x) || ischar(x) && ...
%     isscalar(x);
addParameter(RGB_Channel_merger_InputParser, Optional_Arg_3, ...
    Optional_Arg_3_Default_Val)

Optional_Arg_4 = "Color_Channel_multiplier";
Optional_Arg_4_Default_Val = [5; 1; 1];
% Optional_Arg_4_Validation_Function = @(x) isstring(x) || ischar(x) && ...
%     isscalar(x);
addParameter(RGB_Channel_merger_InputParser, Optional_Arg_4, ...
    Optional_Arg_4_Default_Val)

parse(RGB_Channel_merger_InputParser, varargin{:})

%% Input catagorization
Color_Channel_multiplier = ...
    RGB_Channel_merger_InputParser.Results.Color_Channel_multiplier;

Channel_Paths = { ...
    RGB_Channel_merger_InputParser.Results.Red_Channel_Path; ...
    RGB_Channel_merger_InputParser.Results.Green_Channel_Path; ...
    RGB_Channel_merger_InputParser.Results.Blue_Channel_Path};

if isempty(Channel_Paths)
error("no Color Channel Paths sepcified")
end

Specified_Paths = ~cellfun(@isempty, Channel_Paths);
Image_Size = ...
    size(imread(string(Channel_Paths(find(Specified_Paths, 1, 'first')))));

%% Import
if Specified_Paths(1)
    Red_Channel = ...
        Color_Channel_multiplier(1) * imread(string(Channel_Paths(1)));
else
    Red_Channel = uint16(zeros(Image_Size));
end
if Specified_Paths(2)
    Green_Channel = ...
        Color_Channel_multiplier(2) * imread(string(Channel_Paths(2)));
else
    Green_Channel = uint16(zeros(Image_Size));
end
if Specified_Paths(3)
    Blue_Channel = ...
        Color_Channel_multiplier(3) * imreadstring((Channel_Paths(3)));
else
    Blue_Channel = uint16(zeros(Image_Size));
end

%% Combining Channels
RGB_Composite_Image = cat(3, Red_Channel, Green_Channel, Blue_Channel);
end