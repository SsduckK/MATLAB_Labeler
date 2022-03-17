file_input = open('/home/ri/workspace/MATLAB_Labeler/test_restoring.mat');
variableNames = {'Category', 'y', 'x', 'h', 'w', 'dist_'};
TextscanFormats = {'%s', '%f', '%f','%f','%f','%f'};
labels_datastore = datastore('/home/ri/workspace/Sample_Result_22.03.11/220209/magok/2022-02-09-19-54-16/label/', ...
    'TextscanFormats', TextscanFormats, 'ReadVariablenames', false, 'VariableNames', variableNames);
label_files = labels_datastore.Files;
fileattrib('/home/ri/workspace/MATLAB_Labeler/test_restoring.mat', '+w');
LabelData = file_input.gTruth.LabelData;
LabelDefinition = file_input.gTruth.LabelDefinitions;

for file_idx = 1:length(label_files)
    labels = fileread(label_files{file_idx});
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
    
        box_name_number = find(strcmp(LabelDefinition{:, 5}, box_name));
        box_label_name = LabelDefinition{:, 1}{box_name_number};
        LabelData{:, box_name_number}{file_idx} = [LabelData{:, box_name_number}{file_idx}; box_position];
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
            x = line_list{line_point}(1);
            y = line_list{line_point}(2);
            line_point_array = [line_point_array; x y];
        end
        
        line_name_number = find(strcmp(LabelDefinition{:, 5}, line_name));
        line_label_name = LabelDefinition{:, 1}{line_name_number};
        LabelData{:, line_name_number}{file_idx} = [LabelData{:, line_name_number}{file_idx}; line_point_array];
    end
end

New_Label_Data = LabelData;

New_gTruth = groundTruth(file_input.gTruth.DataSource, LabelDefinition, New_Label_Data);
