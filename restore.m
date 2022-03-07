file_input = open('/home/ri/workspace/MATLAB_Labeler/test_restoring.mat');
labels = fileread('/home/ri/workspace/MATLAB/labels/000126.txt');
fileattrib('/home/ri/workspace/MATLAB_Labeler/test_restoring.mat', '+w');
LabelData = file_input.gTruth.LabelData;
LabelDefinition = file_input.gTruth.LabelDefinitions;
labels = split(labels, '---');
labels_box = split(labels{1}, newline);
labels_line = jsondecode(labels{2});

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
    LabelData{:, box_name_number}{1} = [LabelData{:, box_name_number}{1}; box_position];
end

for line_index = 1:length(labels_line)
    line_list = labels_line{line_index};
    line_name = labels_line{line_index}{1};
    line_point_array = [];
    for line_point = 2:length(line_list)
        x = line_list{line_point}(1);
        y = line_list{line_point}(2);
        line_point_array = [line_point_array; x y]
    end
    switch line_name
        case '차선'
            LabelData.Line{1} = [LabelData.Line{1}; line_point_array];
        case 'RM정지선'
            LabelData.RMStopLine{1} = [LabelData.RMStopLine{1}; line_point_array];
    end
end

New_Label_Data = LabelData;

New_gTruth = groundTruth(file_input.gTruth.DataSource, LabelDefinition, New_Label_Data);
