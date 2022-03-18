mkdir /home/ri/workspace/MATLAB/matfiles/

file_dir = '/home/ri/workspace/MATLAB/matfiles';
input_gTruth = New_gTruth;
version = [];
input_files = split(input_gTruth.DataSource.Source{1}, '/');
input_files = input_files{6};

file_directory = dir(file_dir);

if length(file_directory) >= 3
    for files_idx = 3:length(file_directory)
        if(contains(file_directory(files_idx).name, input_files))
            file_name = split(file_directory(files_idx).name, '.');
            file_version = str2double(file_name{2});
            if ~isnan(file_version)
                version = [version; file_version];
            end
        end
    end
else
    version = 0;
end

newest_version = max(version) + 1;

output_file_name = append(input_files, '.', string(newest_version), '.mat');
save(fullfile(file_dir, output_file_name), 'input_gTruth')
