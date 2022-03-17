mkdir /home/ri/workspace/MATLAB/matfiles/

file_dir = '/home/ri/workspace/MATLAB/matfiles';

input_gTruth = New_gTruth;
file_name = split(input_gTruth.DataSource.Source{1}, '/');
file_name = append(file_name{6}, '.mat');

save(fullfile(file_dir, file_name), 'input_gTruth')