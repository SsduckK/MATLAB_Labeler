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
    label_name = box_data{1};
    x = str2double(box_data{3});
    y = str2double(box_data{2});
    w = str2double(box_data{5});
    h = str2double(box_data{4});
    position = [x y w h];   

    switch label_name
        case '승용차'
            LabelData.Car{1} = position
        case '사람'
            LabelData.Person{1} = position
        case '신호등'
            LabelData.TrafficLight{1} = position
    end
end

New_Label_Data = LabelData;

New_gTruth = groundTruth(file_input.gTruth.DataSource, file_input.gTruth.LabelDefinitions, New_Label_Data);
