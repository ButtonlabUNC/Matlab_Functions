function Batch_RGB_Channel_Merger(Selected_Channels, Channel_Sequence, varargin)
%% Input Parsing
Batch_RGB_Channel_merger_InputParser = inputParser;

Required_Arg_1_Validation_Function = @(x) islogical(x) && ...
    isequal(size(x), [3, 1]) || isequal(size(x), [1, 3]);
addRequired(Batch_RGB_Channel_merger_InputParser, "Selected_Channels", ...
    Required_Arg_1_Validation_Function)

Required_Arg_2_Validation_Function = @(x) isnumeric(x) && ...
    (isequal(size(x), [3, 1]) || isequal(size(x), [1, 3]));
addRequired(Batch_RGB_Channel_merger_InputParser, "Channel_Sequence", ...
    Required_Arg_2_Validation_Function)

Optional_Arg_1 = "Color_Channel_multiplier";
Optional_Arg_1_Default_Val = [5; 1; 1];
addParameter(Batch_RGB_Channel_merger_InputParser, Optional_Arg_1, ...
    Optional_Arg_1_Default_Val)

Optional_Argument_2 = "Search_String";                                       % optoinal input for refining
Default_SearchString = "*";
addParameter(Batch_RGB_Channel_merger_InputParser, ...
    Optional_Argument_2, Default_SearchString, @isstring)                   % input must be a string

Optional_Argument_3 = "recursively";                                        % optional argument for enabling recursivity
Default_Argument_3 = false;
addParameter(Batch_RGB_Channel_merger_InputParser, ...
    Optional_Argument_3, Default_Argument_3, @islogical)                    % argument must be a logical value

Optional_Arg_4 = "File_Names";
Optional_Arg_4_Default_Val = '';
addParameter(Batch_RGB_Channel_merger_InputParser, ...
    Optional_Arg_4, Optional_Arg_4_Default_Val)

Optional_Arg_5 = "Save_File_Type";
Optional_Arg_5_Default_Val = '.tif';
Optional_Arg_5_Valid_Types = [ ...
    '.tif', '.png', '.jpeg'];
Optional_Arg_5_Validation_Function = ...
    @(x) (isstring(x) || ischar(x)) && ...
    ismember(x, Optional_Arg_5_Valid_Types);
addParameter(Batch_RGB_Channel_merger_InputParser, ...
    Optional_Arg_5, Optional_Arg_5_Default_Val, ...
    Optional_Arg_5_Validation_Function)

parse(Batch_RGB_Channel_merger_InputParser, Selected_Channels,  ...
    Channel_Sequence, varargin{:})

%% Finding Data
Top_Folder = uigetdir(pwd,"Select Top Directory of Data");

[Data_Paths, Data_Names] = Find_Data(Top_Folder, ...
"Search_String", Batch_RGB_Channel_merger_InputParser.Results.Search_String, ...
"recursively", Batch_RGB_Channel_merger_InputParser.Results.recursively);

Data_Names = extractBefore(Data_Names, ".");

%% Indexing Data
Selected_Channels = ...
    Batch_RGB_Channel_merger_InputParser.Results.Selected_Channels;
number_of_Channels = ...
    sum(Selected_Channels, 'all');
number_of_Composites = numel(Data_Paths);
Channel_Sequence = ...
    Batch_RGB_Channel_merger_InputParser.Results.Channel_Sequence;
if rem(number_of_Composites, number_of_Channels) ~= 0 
    error("Refine Indexing. The number of detected files not divisable by the number of selected files")
end
if Selected_Channels(1)
    Red_Channel_Paths = ...
        Data_Paths(Channel_Sequence(1):number_of_Channels:end, :);
end
if Selected_Channels(2)
    Green_Channel_Paths = ...
        Data_Paths(Channel_Sequence(2):number_of_Channels:end, :);
end
if Selected_Channels(3)
    Blue_Channel_Paths = ...
        Data_Paths(Channel_Sequence(3):number_of_Channels:end, :);
end
%% Name Generation
Composite_Image_Save_Names = ...
    Batch_RGB_Channel_merger_InputParser.Results.File_Names;

if isempty(Composite_Image_Save_Names)
    Naming_Channel = find(Selected_Channels, 1, 'first');
    Composite_Image_Save_Names = Data_Names(...
        Channel_Sequence(Naming_Channel):number_of_Channels:end, :);
end
 Composite_Image_Save_Names = strcat(...
     Top_Folder, "\", string(Composite_Image_Save_Names), ...
     Batch_RGB_Channel_merger_InputParser.Results.Save_File_Type);
%% Passing Data Merger
RGB_Channel_Merger_input = cell([number_of_Composites,1]);

Input_Argument = {};

for k1 = 1 : number_of_Composites
if Selected_Channels(1)
    Input_Argument = ...
        [Input_Argument, {["Red_Channel_Path"], [Red_Channel_Paths(k1)]}];
end
if Selected_Channels(2)
    Input_Argument = ...
        [Input_Argument, {["Green_Channel_Path"], [Green_Channel_Paths(k1)]}];
end
if Selected_Channels(3)
    Input_Argument = ...
        [Input_Argument, ["Blue_Channel_Path", Blue_Channel_Paths(k1)]];
end
Input_Argument = [Input_Argument, {...
    ["Color_Channel_multiplier"], ...
    [Batch_RGB_Channel_merger_InputParser.Results.Color_Channel_multiplier]}];

RGB_Channel_Merger_input(k1) = {Input_Argument};

Input_Argument = {};
end
%% Merging images
for k2 = 1 : number_of_Composites
RGB_Composite_Image = RGB_Channel_Merger(RGB_Channel_Merger_input{k2}{:});
imwrite(RGB_Composite_Image, Composite_Image_Save_Names(k2))
end


a = "test";

end
