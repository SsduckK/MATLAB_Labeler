file_input = open('/home/ri/workspace/MATLAB_Labeler/test_restoring.mat');
labels_datastore = datastore('/home/ri/workspace/MATLAB/labels');
labels_cluster = labels_datastore.Files;
fileattrib('/home/ri/workspace/MATLAB_Labeler/test_restoring.mat', '+w');
LabelData = file_input.gTruth.LabelData;
LabelDefinition = file_input.gTruth.LabelDefinitions;

for cluster_index = 1:length(labels_cluster)
    labels = fileread(labels_cluster{cluster_index});
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
    
        box_name_number = find(contains(LabelDefinition{:, 5}, box_name));
        box_label_name = LabelDefinition{:, 1}{box_name_number};
        LabelData{:, box_name_number}{cluster_index} = [LabelData{:, box_name_number}{cluster_index}; box_position];
    end
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
        switch line_name
            case '차선'
                LabelData.Line{cluster_index} = [LabelData.Line{cluster_index}; line_point_array];
            case 'RM정지선'
                LabelData.RMStopLine{cluster_index} = [LabelData.RMStopLine{cluster_index}; line_point_array];
        end
    end
end

New_Label_Data = LabelData;

New_gTruth = groundTruth(file_input.gTruth.DataSource, LabelDefinition, New_Label_Data);
