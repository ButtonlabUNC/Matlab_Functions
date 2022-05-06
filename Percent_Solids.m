% By Mark Gutay 2022 04 13

% function for calculating the solids of a sample measured using Button
% lab's labview program for weight timecourse. with options for mesh
% subraction and Percent organics calculation with user defineable solvent
% solids.
% inputs are validated for matching number of samples and mesh weights

% this funciton outputs a [sample number x 2 or 3] sized table with columns
% for sample name, percent solids, and, if selected, percent organcis.
% optionaly outputs an expaned table for the all the intermidiate
% calculations.


function [Results, Results_debug] = Percent_Solids(Wet_Path, Dry_Path, varargin)
%% Input Parsing
Percent_Solids_InputParser = inputParser;

Required_Arg_1_Validation_Function = @(x) isstring(x) || ischar(x);         
addRequired(Percent_Solids_InputParser, "Wet_Path", ...
    Required_Arg_1_Validation_Function)                                     % Required input defining the path for the xlsx file containing the wet time course data. must be a string or a character array

Required_Arg_2_Validation_Function = @(x) isstring(x) || ischar(x);
addRequired(Percent_Solids_InputParser, "Dry_Path", ...
    Required_Arg_2_Validation_Function)                                     % Required input defining the path for the xlsx file containing the dry time course data. must be a string or a character array

Optional_Arg_1 = "Mesh_Weight";
Optional_Arg_1_Default_Val = [];
Optional_Arg_1_Validation_Function = @(x) @isnumeric && (height(x) == 1);
addParameter(Percent_Solids_InputParser, Optional_Arg_1, ...
    Optional_Arg_1_Default_Val, Optional_Arg_1_Validation_Function)         % optional input defining mesh weights to be subtracted from calculated weights. must be a numberic horizontal vector with the same number of entries as samples. input is ignored unless "Mesh_Mode" is defined as true

Optional_Arg_2 = "Mesh_Mode";
Optional_Arg_2_Default_Val = false;
Optional_Arg_2_Validation_Function = @(x) islogical(x);
addParameter(Percent_Solids_InputParser, Optional_Arg_2, ...
    Optional_Arg_2_Default_Val, Optional_Arg_2_Validation_Function)         % optional argument inicating if mesh subtraction is desired. must be logical

Optional_Arg_3 = "Percent_Organics";
Optional_Arg_3_Default_Val = false;
Optional_Arg_3_Validation_Function = @(x) islogical(x);
addParameter(Percent_Solids_InputParser, Optional_Arg_3, ...
    Optional_Arg_3_Default_Val, Optional_Arg_3_Validation_Function)         % optional argument indicating if Percent Organics should be Calculated. must be logical

Optional_Arg_4 = "Solvent_Solids";
Optional_Arg_4_Default_Val = 0.9;
Optional_Arg_4_Validation_Function = @(x)...
    isnumeric(x) && isscalar(x);
addParameter(Percent_Solids_InputParser, Optional_Arg_4, ...
    Optional_Arg_4_Default_Val, Optional_Arg_4_Validation_Function)         % optional input allowing user to define solvent percent solids. defaults to 0.9(salt solids of Standard Phosphate Buffered Saline). must be a numeric scalar 


parse(Percent_Solids_InputParser, Wet_Path, Dry_Path, varargin{:})          % parses funcation inputs and inports values
%% Import
[Wet_NUM, Wet_TXT] = xlsread(Percent_Solids_InputParser.Results.Wet_Path);  % inports Wet XLSX data as a numeric and string matrix. where the numeric matrix contains the time course time-force data where empty xlsx cells are NAN while the String matrix contains all the text labels of the xlsx file.
[Dry_NUM, Dry_TXT] = xlsread(Percent_Solids_InputParser.Results.Dry_Path);  % inports Dry XLSX data as a numeric and string matrix. where the numeric matrix contains the time course time-force data where empty xlsx cells are NAN while the String matrix contains all the text labels of the xlsx file.

%% Data Indexing
Wet_Sample_Names = string(Wet_TXT(1,:));                                    % Button lab Labview program records only sample name in row 1. this is used to extract sample name and as referance point for the relative locations of other recorded data
Wet_Column_Index = ~cellfun(@isempty, Wet_Sample_Names);                    % detects non empty cells. used for extracting sample names as reference indecies when finding other data
Wet_Sample_Names(not(Wet_Column_Index)) = [];                               % extracts sample names
Wet_Sample_Names_fig = strrep(Wet_Sample_Names, "_", " ");

Wet_Time_Column_Index = Wet_Column_Index;                                   % Button Lab Labview program records time data for each sample in the same column as the sample name
Wet_Force_Column_Index = false(size(Wet_Time_Column_Index));                % prallocation of logical array for force data
Wet_Force_Column_Index(2:end) = ...
    Wet_Time_Column_Index(1:(width(Wet_Time_Column_Index) - 1));            % Button Lab Labview program records force data for each sample one column to the right of the time data. false logical array of size(Wet_Time_Column_Index) is asigned values of Wet_Time_Column_Index one to the right of Wet_Time_Column_Index

Pan_Weight_Column_Index = Wet_Force_Column_Index;                           % Button Lab Labview program records weight pan weights in the same column as the force data

Wet_Sample_Number = sum(Wet_Column_Index, "all");                           % counts the number of wet samples used to confirm a matching number of dry and wet samples

Dry_Sample_Names = string(Dry_TXT(1,:));                                    % dry sample data is indexed in the same mannor as wet sample data
Dry_Column_Index = ~cellfun(@isempty, Dry_Sample_Names);
Dry_Sample_Names(not(Dry_Column_Index)) = [];
Dry_Sample_Names_fig = strrep(Dry_Sample_Names, "_", " ");

Dry_Time_Column_Index = Dry_Column_Index;
Dry_Force_Column_Index = false(size(Dry_Time_Column_Index));
Dry_Force_Column_Index(2:end) = ...
    Dry_Time_Column_Index(1:(width(Dry_Time_Column_Index) - 1));

Dry_Sample_Number = sum(Dry_Column_Index, "all");                           % counts the number of dry samples used to confirm a matching number of dry and wet samples

Mesh_weight = Percent_Solids_InputParser.Results.(Optional_Arg_1);            % loads mesh weight array from the input parser object in the a double array



%% validating Input Data
if not(Wet_Sample_Number == Dry_Sample_Number)
    error("Number of wet and dry Samples must be equal")                    % compares data confirming the number of samples in dry and wet data are the same otherwise the function errors
end

if Percent_Solids_InputParser.Results.(Optional_Arg_2)
    Mesh_Weight_Number = numel(...
        Percent_Solids_InputParser.Results.(Optional_Arg_1));
    if not( Mesh_Weight_Number == Wet_Sample_Number && Mesh_Weight_Number == Dry_Sample_Number)
        error("Number of mesh weights must be equal to the number of samples") % compares data confirming the number of inputs for mesh weight and sample number are the same otherwise the function errors
    end
end


%% Format Data
Wet_sample_time = Wet_NUM(6:end, Wet_Time_Column_Index);                    % extracts only the time data from wet data into a matrix where each column is one sample's time data
Wet_Sample_Force = Wet_NUM(6:end, Wet_Force_Column_Index);                  % extracts only the force data from wet data into a matrix where each column is one sample's time data
Pan_Weight = Wet_NUM(4, Pan_Weight_Column_Index);                           % extracts the pan weight value. it is always row 4 and in the same column as the the force data

Dry_sample_time = Dry_NUM(6:end, Dry_Time_Column_Index);                    % extracts only the time data from dry data into a matrix where each column is one sample's time data
Dry_Sample_Force = Dry_NUM(6:end, Dry_Force_Column_Index);                  % extracts only the force data from dry data into a matrix where each column is one sample's time data

%% Preallocating Resaults
t_zero_wet_weight = zeros(1, Wet_Sample_Number);
t_infinity_Dry_Weight = zeros(1, Dry_Sample_Number);

%% Wet t zero weight
for k1 = 1:Wet_Sample_Number
    % plots each sample and prompts user to select valid ranges 

    plot(Wet_sample_time(:,k1), Wet_Sample_Force(:,k1));                    % plots wet data for sample with time data as the x and force data as the y axis
    title(strcat("Wet ", Wet_Sample_Names_fig(k1)))
    xlabel('time(s)')
    ylabel('Force (ug)')

    [Wet_Range_UI,~] = ginput(2);                                           % prompts user for valid x range. valid ranges must be aproximately linear with little noise

    Wet_Regression_Range = ...
        find(...
        Wet_sample_time(:,k1) > Wet_Range_UI(1) & ...                       % find indecies for data between the valid x ranges
        Wet_sample_time(:,k1) < Wet_Range_UI(2));

    Wet_Fit = polyfit(...
        Wet_sample_time(Wet_Regression_Range,k1), ...
        Wet_Sample_Force(Wet_Regression_Range,k1), 1);                      % fits data to a linear function. we assume we data is taking only during the linear ranges of drying rate. 

    t_zero_wet_weight(1,k1) = Wet_Fit(2);                                   % saves the y intercept (time zero) force value for a sample

    close gcf                                                               % closes the current figure
end
%% Dry t infinity weight
for k2 = 1:Dry_Sample_Number
    % plots each sample and prompts user to select valid ranges
    
    plot(Dry_sample_time(:,k2), Dry_Sample_Force(:,k2));
    title(strcat("Dry ", Dry_Sample_Names_fig(k2)))
    xlabel('time(s)')
    ylabel('Force (ug)')

    [Dry_Range_UI,~] = ginput(2);                                           % valid ranges are areas which are aproximately flat

    Dry_Regression_Range = ...
        find(...
        Dry_sample_time(:,k2) > Dry_Range_UI(1) & ...
        Dry_sample_time(:,k2) < Dry_Range_UI(2));

    Dry_Fit = polyfit(...
        Dry_sample_time(Dry_Regression_Range,k2), ...
        Dry_Sample_Force(Dry_Regression_Range,k2), 1);

    while mean(diff(Dry_Sample_Force(Dry_Regression_Range,k2)))  >= 0.01    
        % continuiously prompts user to refine selection range until the
        % the slope of the data is aproximately flat

        plot(Dry_sample_time(Dry_Regression_Range,k2), Dry_Sample_Force(Dry_Regression_Range,k2));
        title(Dry_Sample_Names_fig{k2})
        xlabel('time(s)')
        ylabel('Force (ug)')
        [Dry_Range_UI,~] = ginput(2);

        Dry_Regression_Range = ...
            find(...
            Dry_sample_time(:,k2) > Dry_Range_UI(1) & ...
            Dry_sample_time(:,k2) < Dry_Range_UI(2));

        Dry_Fit = polyfit(...
            Dry_sample_time(Dry_Regression_Range,k2), ...
            Dry_Sample_Force(Dry_Regression_Range,k2), 1);
    end
    t_infinity_Dry_Weight(1,k2) = Dry_Fit(2);                               % because the slope of the function is aproximately zero it use linear regression to aproximate the the limit of the data set

    close gcf
end
%% Percent Solids Calculation

t_zero_wet_weight_pan_subtracted = t_zero_wet_weight - Pan_Weight;          % wet time zero weight is adjusted for pan weight 
t_infinity_Dry_Weight_pan_subtracted = t_infinity_Dry_Weight - Pan_Weight;  % dry time infinity is adjusted for pan weight

t_zero = t_zero_wet_weight_pan_subtracted;                                  % set final value for wet weight
t_infinity = t_infinity_Dry_Weight_pan_subtracted;                          % sets final value for dry weight

if Percent_Solids_InputParser.Results.(Optional_Arg_2)
    t_zero_wet_weight_pan_mesh_subtracted = ...
        t_zero_wet_weight_pan_subtracted - Mesh_weight;                     % wet time zero weight adjusted for pan is adjsted for mesh weight
    
    t_infinity_Dry_Weight_pan_mesh_subtracted = ...
        t_infinity_Dry_Weight_pan_subtracted - Mesh_weight;                 % dry time infinity weight is adjusted for mesh wieght

    t_zero = t_zero_wet_weight_pan_mesh_subtracted;                         % final value for wet weight is overwritten to mesh adjusted value
    t_infinity = t_infinity_Dry_Weight_pan_mesh_subtracted;                 % final value for dry weight is overwritten to mesh adjusted value
end

Percent_Solids = ...
    (t_infinity ./ t_zero * 100);                                           % calculates percent solids as the percentage value rather then decimal

if Percent_Solids_InputParser.Results.(Optional_Arg_3)
    Percen_Organics = ...
        Percent_Solids - Percent_Solids_InputParser.Results.(Optional_Arg_4); % calculates percent organics by subtracting the solvent solids form calculated percent solids
end

%% Output Table Generation
% Tables are generated based on input arguments 

if Percent_Solids_InputParser.Results.(Optional_Arg_2) && Percent_Solids_InputParser.Results.(Optional_Arg_3)
    Results = table(...
        transpose(Wet_Sample_Names), transpose(Percent_Solids), ...
        transpose(Percen_Organics), 'VariableNames', [...
        "Sample Name", "Percent Solids", "Percent Organics"]);

    Results_debug = table(...
        transpose(Wet_Sample_Names), transpose(t_zero_wet_weight), ...
        transpose(t_zero_wet_weight_pan_subtracted), ...
        transpose(t_zero_wet_weight_pan_mesh_subtracted), ...
        transpose(Dry_Sample_Names), transpose(t_infinity_Dry_Weight), ...
        transpose(t_infinity_Dry_Weight_pan_subtracted), ...
        transpose(t_infinity_Dry_Weight_pan_mesh_subtracted), ...
        transpose(Percent_Solids), transpose(Percen_Organics), ...
        'VariableNames',[...
        "Wet Sample name", "t = zero weight", ...
        "Wet weight without pan", "Wet Weight Without pan and mesh" ...
        "Dry Sample Name", "t = infinity weight", "Dry weight without pan", ...
        "Dry Weight Without pan and mesh", ...
        "Percent Solids", "Percent Organics"]);

elseif ~Percent_Solids_InputParser.Results.(Optional_Arg_2) && Percent_Solids_InputParser.Results.(Optional_Arg_3)
    Results = table(...
        transpose(Wet_Sample_Names), transpose(Percent_Solids), ...
        transpose(Percen_Organics), 'VariableNames', [...
        "Sample Name", "Percent Solids", "Percent Organics"]);

    Results_debug = table(...
        transpose(Wet_Sample_Names), transpose(t_zero_wet_weight), ...
        transpose(t_zero_wet_weight_pan_subtracted), ...
        transpose(Dry_Sample_Names), transpose(t_infinity_Dry_Weight), ...
        transpose(t_infinity_Dry_Weight_pan_subtracted), ...
        transpose(Percent_Solids), transpose(Percen_Organics), ...
        'VariableNames',[...
        "Wet Sample name", "t = zero weight", "Wet weight without pan"...
        "Dry Sample Name", "t = infinity weight", "Dry weight without pan", ...
        "Percent Solids", "Percent Organics"]);

elseif Percent_Solids_InputParser.Results.(Optional_Arg_2) && ~Percent_Solids_InputParser.Results.(Optional_Arg_3)
    Results = table(...
        transpose(Wet_Sample_Names), transpose(Percent_Solids), ...
        'VariableNames', [...
        "Sample Name", "Percent Solids"]);

    Results_debug = table(...
        transpose(Wet_Sample_Names), transpose(t_zero_wet_weight), ...
        transpose(t_zero_wet_weight_pan_subtracted), ...
        transpose(t_zero_wet_weight_pan_mesh_subtracted), ...
        transpose(Dry_Sample_Names), transpose(t_infinity_Dry_Weight), ...
        transpose(t_infinity_Dry_Weight_pan_subtracted), ...
        transpose(t_infinity_Dry_Weight_pan_mesh_subtracted), ...
        transpose(Percent_Solids), ...
        'VariableNames',[...
        "Wet Sample name", "t = zero weight", ...
        "Wet weight without pan", "Wet Weight Without pan and mesh" ...
        "Dry Sample Name", "t = infinity weight", ...
        "Dry weight without pan", "Dry Weight Without pan and mesh", ...
        "Percent Solids"]);

elseif ~(Percent_Solids_InputParser.Results.(Optional_Arg_2) && Percent_Solids_InputParser.Results.(Optional_Arg_3))
    Results = table(...
        transpose(Wet_Sample_Names), transpose(Percent_Solids), ...
        'VariableNames', ["Sample Name", "Percent Solids"]);

    Results_debug = table(...
        transpose(Wet_Sample_Names), transpose(t_zero_wet_weight), ...
        transpose(t_zero_wet_weight_pan_subtracted), ...
        transpose(Dry_Sample_Names), transpose(t_infinity_Dry_Weight), ...
        transpose(t_infinity_Dry_Weight_pan_subtracted), ...
        transpose(Percent_Solids), ...
        'VariableNames',[...
        "Wet Sample name", "t = zero weight", "Wet weight without pan",  ...
        "Dry Sample Name", "t = infinity weight", "Dry weight without pan", ...
        "Percent Solids"]);
end
end