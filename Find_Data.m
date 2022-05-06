function [Path, Name, Folder] = Find_Data(TopFolder, varargin)
% Finds all files immidately below top folder and generates paths for files
% opptionally reports name and containing folder.Find_Data ommits any
% folders, only reporting files.
%
% optional argumen "searchstring" is used to find all files maching only
% that string.
% optional argument "recursively" accepts logical values. when true  
% searchs for searchstring recursively. 

%% Input Parsing
    Find_Data_InputParser = inputParser;
    
    addRequired(Find_Data_InputParser, "TopFolder", @isstring)              % required argument describing top search directory
    
    Optional_Argument_1 = "SearchString";                                   % optoinal input for refining
    Default_SearchString = "*";
    addOptional(Find_Data_InputParser, ...
        Optional_Argument_1, Default_SearchString, @isstring)               % input must be a string

    Optional_Argument_2 = "recursively";                                    % optional argument for enabling recursivity
    Default_Argument_2 = false;
    addParameter(Find_Data_InputParser, ...
        Optional_Argument_2, Default_Argument_2, @islogical)                % argument must be a logical value
    
    parse(Find_Data_InputParser, TopFolder, varargin{:})                    % parses inputs and argument
%% Search Path Creation
     if Find_Data_InputParser.Results.(Optional_Argument_2)                 % adds "\**\" to top directory path so dir will seek files in all sub directories
         top = strcat(Find_Data_InputParser.Results.TopFolder, "\**\");     % other wise only adds "\" so dir only seeks files immidately below top
     else
         top = strcat(Find_Data_InputParser.Results.TopFolder, "\");
     end

    if strcmp(Find_Data_InputParser.Results.(Optional_Argument_1), Default_SearchString) % combines search directory path with search string
        Search_Path = strcat(top, Find_Data_InputParser.Results.(Optional_Argument_1));

    elseif startsWith(Find_Data_InputParser.Results.(Optional_Argument_1), "*")      % this would resault in an error with the dir command and serves to inform the user
            error('search string cannot start with "*"')

    else
        Search_Path = strcat(top, "*", Find_Data_InputParser.Results.(Optional_Argument_1));     
    end 

%% Searches for files
    Files = dir(Search_Path);
    
    Name = transpose({Files.name});                                         % Recordes name column of found files
        Name(transpose([Files.isdir])) = [];                                % ommits files found which are directories

    Folder = transpose({Files.folder});                                     % Records path to directory containing found files
        Folder(transpose([Files.isdir])) = [];                              % ommits paths found which are aimed at directories

    Path = strcat(Folder, "\", Name);                                       % combines paths wih files names
    end
