file_dir = "/home/ri/workspace/MATLAB/matfiles/220209/220209.1.mat";
input_data = load(file_dir);

file_name = split(file_dir, '/');
file_name = file_name{end};

dst_dir = '/home/ri/workspace/MATLAB/mat2txt/';
mkdir(dst_dir, file_name);

source = input_data.input_gTruth.DataSource.Source;
label_definition = input_data.input_gTruth.LabelDefinitions;
label_data = input_data.input_gTruth.LabelData;

name_src = strcat(file_name, '_Source.txt');
name_def = strcat(file_name, '_Definition.txt');
name_dat = strcat(file_name, '_Data.txt');

writecell(source, strcat(dst_dir, file_name, '/',  name_src))
writetable(label_definition, strcat(dst_dir, file_name, '/', name_def))
writetable(label_data, strcat(dst_dir, file_name, '/', name_dat))
