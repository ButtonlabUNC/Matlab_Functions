function [Fit_Results, Fit_fig] = Graph_Fit(x_Data, y_Data, varargin)
%% Input Validation
Graph_Fit_InputParser = inputParser;

Required_Input_1_Validation_Function = @(x) isnumeric(x) && isvector(x);
addRequired(Graph_Fit_InputParser, ...
    "x_Data", Required_Input_1_Validation_Function);

Required_Input_2_Validation_Function = @(x) isnumeric(x) && isvector(x);
addRequired(Graph_Fit_InputParser, ...
    "y_Data", Required_Input_2_Validation_Function)

Optional_Arg_1 = "fit_Type";
Optional_Arg_1_Default_Val = "poly1";
Optional_Arg_1_Valid_Values = [...
    "distribution", "exponential", "fourier", "gaussian", "interpolant", ...
    "polynomial", "power", "rational", "sin", "spline", "interpolant", ...
    "lowess", "polynomial", "poly1", "poly2", "poly3", "poly4", "poly5", ...
    "poly6", "poly7", "poly8", "poly9", "poly21", "poly13", "poly55", ...
    "weibull", "exp1", "exp2", "fourier1", "fourier2", "fourier3", ...
    "fourier4", "fourier5", "fourier6", "fourier7", "fourier8", ...
    "gauss1", "gauss2", "gauss3", "gauss4", "gauss5", "gauss6", ...
    "gauss7", "gauss8", "power1", "power2", "rat02", "rat21", "sin1", ...
    "sin2", "sin3", "sin4", "sin5", "sin6", "sin7", "sin8", ...
    "cubicspline", "smoothingspline"];
Optional_Arg_1_Validation_Function = @(x) ...
    (isstring(x) || ischar(x)) && isscalar(x) && ...
    any(strcmp(x, Optional_Arg_1_Valid_Values));
addParameter(Graph_Fit_InputParser, ...
    Optional_Arg_1, Optional_Arg_1_Default_Val, ...
    Optional_Arg_1_Validation_Function)

Optional_Arg_2 = "Save";
Optional_Arg_2_Default_Val = false;
Optional_Arg_2_Validation_function = @(x) islogical(x) && isscalar(x);
addParameter(Graph_Fit_InputParser, ...
    Optional_Arg_2, Optional_Arg_2_Default_Val, ...
    Optional_Arg_2_Validation_function)

Optional_Arg_3 = "X_Label";
Optional_Arg_3_Default_Val = "X Data";
Optional_Arg_3_Validation_function = @(x) ...
    (isstring(x) || ischar(x)) && isscalar(x);
addParameter(Graph_Fit_InputParser, ...
    Optional_Arg_3, Optional_Arg_3_Default_Val, ...
    Optional_Arg_3_Validation_function)

Optional_Arg_4 = "Y_Label";
Optional_Arg_4_Default_Val = "Y Data";
Optional_Arg_4_Validation_function = @(x) ...
    (isstring(x) || ischar(x)) && isscalar(x);
addParameter(Graph_Fit_InputParser, ...
    Optional_Arg_4, Optional_Arg_4_Default_Val, ...
    Optional_Arg_4_Validation_function)

Optional_Arg_5 = "Title";
Optional_Arg_5_Default_Val = "Data Regreesion";
Optional_Arg_5_Validation_function = @(x) ...
    (isstring(x) || ischar(x)) && isscalar(x);
addParameter(Graph_Fit_InputParser, ...
    Optional_Arg_5, Optional_Arg_5_Default_Val, ...
    Optional_Arg_5_Validation_function)

% Optional_Arg_ = 
% Optional_Arg__Default_Val = 
% Optional_Arg__Validation_function = 
% addParameter(Graph_Fit_InputParser, )


parse(Graph_Fit_InputParser, ...
    x_Data, y_Data, varargin{:})

if numel(Graph_Fit_InputParser.Results.x_Data) ~= numel(Graph_Fit_InputParser.Results.y_Data)
    error("number of independant and dependant data points must be equal")
end

%% Calculation Preparation
Fit_fig = figure("Visible","off");

Regression_Mode = Graph_Fit_InputParser.Results.(Optional_Arg_1);

Independant = Graph_Fit_InputParser.Results.x_Data;
Dependant = Graph_Fit_InputParser.Results.y_Data;

fig_title = Graph_Fit_InputParser.Results.(Optional_Arg_5);
fig_x_label = Graph_Fit_InputParser.Results.(Optional_Arg_3);
fig_y_label = Graph_Fit_InputParser.Results.(Optional_Arg_4);

%% Regression
Fit_Results = fit(Independant, Dependant, Regression_Mode);

%% Plotting
figure(Fit_fig)
scatter(Independant, Dependant)
hold on
plot(Fit_Results)
hold off

xlabel(fig_x_label)
ylabel(fig_y_label)
title(fig_title)

end