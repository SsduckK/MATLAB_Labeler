DATASET_ROOT = '/home/ri/workspace/Sample_Result_22.03.11/220209/magok/2022-02-09-19-53-05';
IMAGE_ROOT = fullfile(DATASET_ROOT, '/image');
LABEL_ROOT = fullfile(DATASET_ROOT, '/labels');
DEFINITION_ROOT = '/home/ri/workspace/MATLAB/line1Definition.mat';
DST_MAT_PATH = '/home/ri/workspace/MATLAB/matfiles';

reconstruct_label_data(IMAGE_ROOT, DEFINITION_ROOT, LABEL_ROOT, DST_MAT_PATH)


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
        labels = split(labels, '---');
        labels_box = split(labels{1}, newline);
        
        for box_index = 2:length(labels_box)
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

            for line_point = 2:length(line_list)
                if length(line_list) == 3
                    continue
                end
                x = line_list{line_point}(1);
                y = line_list{line_point}(2);
                line_point_array = [line_point_array; x y];
            end
            
            line_name_number = find(strcmp(label_definition{:, 5}, line_name));
            line_label_name = label_definition{:, 1}{line_name_number};
            template_table{:, line_name_number}{file_idx} = [template_table{:, line_name_number}{file_idx}; line_point_array];
        end
    end

    data_file = template_table;
end

function save_gtruth_file(ground_truth, dst_mat_path)
    dir_name = split(ground_truth.DataSource.Source{1}, '/');
    dir_name = dir_name{6};
    if ~exist(fullfile(dst_mat_path, dir_name))
        mkdir(fullfile(dst_mat_path, dir_name))
    end
    time = split(datestr(datetime('now')), ' ');
    time = time{2};
    output_mat = append(dir_name, '_', string(time));
    save(fullfile(dst_mat_path, dir_name, output_mat), 'ground_truth')
end