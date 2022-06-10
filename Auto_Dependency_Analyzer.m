function Dependencies  = Auto_Dependency_Analyzer
[Filename, Dir] = uigetfile;

File_Path = string(strcat(Dir,Filename));

Dependencies = Dependency_Analyzer(File_Path);
end