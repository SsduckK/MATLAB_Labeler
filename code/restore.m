DATASET_ROOT = '/home/ri/1st_5000_data/1st_result/220209/magok';
%IMAGE_ROOT = fullfile(DATASET_ROOT, '/image');
%LABEL_ROOT = fullfile(DATASET_ROOT, '/label');
DEFINITION_ROOT = '/home/ri/workspace/MATLAB/line4Definition.mat';
DST_MAT_PATH = '/home/ri/workspace/MATLAB/';

data_path = dir(DATASET_ROOT);
for input = 3:size(data_path)
    path = data_path(input).name;
    data_dir = fullfile(DATASET_ROOT, path);
    IMAGE_ROOT = fullfile(data_dir, '/image');
    LABEL_ROOT = fullfile(data_dir, '/label');
    reconstruct_label_data(IMAGE_ROOT, DEFINITION_ROOT, LABEL_ROOT, DST_MAT_PATH)
end
%save_original(DATASET_ROOT)


function ground_truth = reconstruct_label_data(image_path, definition_path, label_path, dst_mat_path)
    source_files = list_image_files(image_path);
    label_definition = read_label_definition(definition_path);
    label_data = read_label_data(image_path, definition_path, label_path);
    ground_truth = groundTruth(source_files, label_definition, label_data);
    save_gtruth_file(ground_truth, dst_mat_path)
end


function source_files = list_image_files(image_path)
    data_source = dir(fullfile(image_path, '*.jpg'));
    data = [];
    for i = 1:length(data_source)
        image_name = strcat(data_source(i).folder, '/', data_source(i).name);
        data = [data; image_name];
        data = cellstr(data);
    end
    source_files = groundTruthDataSource(data);
end


function definition_file = read_label_definition(definition_path)
    definition = open(definition_path);
    definition_file = definition.labelDefs;
end


function data_file = read_label_data(image_path, def_path, label_path)
    variableNames = {'Category', 'y', 'x', 'h', 'w', 'dist_'};
    TextscanFormats = {'%s', '%f', '%f','%f','%f','%f'};
    labels_datastore = datastore(label_path, 'TextscanFormats', TextscanFormats, ...
        'ReadVariablenames', false, 'VariableNames', variableNames);
    label_files = labels_datastore.Files;

    label_definition = read_label_definition(def_path);
    [template_x, non] = size(list_image_files(image_path).Source);
    [non, template_y] = size(transpose(label_definition.Name));

    template_table = cell2table(cell(template_x, template_y), 'VariableNames',label_definition.Name);

    for file_idx = 1:length(label_files)
        labels = fileread(label_files{file_idx});
        label_files{file_idx};
        labels = split(labels, '---');
        labels_box = split(labels{1}, newline);
        
        for box_index = 1:length(labels_box)
            box_data = split(labels_box(box_index), ',');
            if isempty(box_data{1})
                continue
            end
            box_name = box_data{1};
            x = str2double(box_data{3});
            y = str2double(box_data{2});
            w = str2double(box_data{5});
            h = str2double(box_data{4});
            box_position = [x y w h];
        
            box_name_number = find(strcmp(label_definition{:, 5}, box_name));
            box_label_name = label_definition{:, 1}{box_name_number};
            template_table{:, box_name_number}{file_idx} = [template_table{:, box_name_number}{file_idx}; box_position];
        end
    
        % if there is no lane
        if labels{2} == newline
            continue
        else
            labels_line = jsondecode(labels{2});
        end

        for line_index = 1:length(labels_line)
            line_list = labels_line{line_index};
            line_name = labels_line{line_index}{1};
            line_point_array = [];
            perfect_line = [];
            for line_point = 2:length(line_list)
                if length(line_list) == 3
                    continue
                end
                x = line_list{line_point}(1);
                y = line_list{line_point}(2);
                line_point_array = [line_point_array; x y];
            end
            
            perfect_line = [perfect_line; {line_point_array}];
            line_name_number = find(strcmp(label_definition{:, 5}, line_name));
            template_table{:, line_name_number}{file_idx} = [template_table{:, line_name_number}{file_idx}; perfect_line];
        end

    end

    data_file = template_table;
end

function save_gtruth_file(ground_truth, dst_mat_path)
    dir_name = split(ground_truth.DataSource.Source{1}, '/');
    dir_name = dir_name{8};
    save_path = fullfile(dst_mat_path, 'matfiles', dir_name);
    if ~exist(save_path)
        mkdir(save_path)
    end
    time = split(datestr(datetime('now')), ' ');
    time = time{2};
    output_mat = append(dir_name, '_', string(time));
    save(fullfile(save_path, output_mat), 'ground_truth')
end

function save_original(input_data_path)
    zip_path = fullfile(input_data_path, 'original');
    input_data_name = split(input_data_path, '/');
    input_data_name = append(input_data_name{end}, '_origin');
    if ~exist(zip_path)
        mkdir(zip_path)
        zip(fullfile(zip_path, input_data_name), zip_path, input_data_path);
    end
end
