
function Figure_Bach_Converter(path, varargin)

p = inputParser;

Required_Arg_1_Validator_Function = @(x) ...
    (ischar(x) || isstring(x)) && isvector(x) && contains(x,".fig");
addRequired(p, "path", Required_Arg_1_Validator_Function)

Optional_Arg_1 = "filetype";
Optional_Arg_1_Default_Type = "jpeg";
Optional_Arg_1_Valid_Types = [...
    "jpeg";"png";"meta";"bmpmono";"hdf";"pbm";"pcxmono";"pgm"];
Optional_Arg_1_Type_Validation_Function = @(x) ...
    (ischar(x) || isstring(x)) && numel(x) == 1 && ...
    any(strcmp(x,Optional_Arg_1_Valid_Types));
addOptional(p, Optional_Arg_1, Optional_Arg_1_Default_Type, Optional_Arg_1_Type_Validation_Function)

parse(p,path , varargin{:})

file_extension_table = ...
    ["jpeg",".jpg"; ...
    "png",".png"; ...
    "meta",".emf"; ...
    "bmpmono",".bmp"; ...
    "hdf",".hdf"; ...
    "pbm",".pbm"; ...
    "pcxmono",".pcx"; ...
    "pgm",".pgm"];

export_type = p.Results.filetype;
export_extension = file_extension_table( ...
    strcmp(export_type,file_extension_table(:,1)), 2);

Paths = p.Results.path;
Save_Paths = strrep(Paths, ".fig", export_extension);


for k1 = 1:numel(p.Results.path)
    myfig = openfig(p.Results.path(k1), "invisible");
    saveas(myfig, Save_Paths, export_type)
    close(myfig)
end

end