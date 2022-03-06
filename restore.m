file_input = open('/home/ri/workspace/MATLAB_Labeler/test_restoring.mat');
labels = fileread('/home/ri/workspace/MATLAB/labels/000026.txt');
fileattrib('/home/ri/workspace/MATLAB_Labeler/test_restoring.mat', '+w');
LabelData = file_input.gTruth.LabelData;
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
    switch box_name
        case '승용차'
            LabelData.Car{1} = [LabelData.Car{1}; box_position];
        case '사람'
            LabelData.Person{1} = [LabelData.Person{1}; box_position];
        case "Dont' Care"
            LabelData.DontCare{1} = [LabelData.DontCare{1}; box_position];
        case '신호등'
            LabelData.TrafficLight{1} = [LabelData.TrafficLight{1}; box_position];
        case 'RM횡단보도'
            LabelData.RMCrossWalk{1} = [LabelData.RMCrossWalk{1}; box_position];
    end
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

New_gTruth = groundTruth(file_input.gTruth.DataSource, file_input.gTruth.LabelDefinitions, New_Label_Data);
