file_input = open('/home/ri/workspace/MATLAB_Labeler/test_restoring.mat');
fileattrib('/home/ri/workspace/MATLAB_Labeler/test_restoring.mat', '+w')
LabelData = file_input.gTruth.LabelData

LabelData.Person{1} = [936 618 40 9]

New_Label_Data = LabelData

New_gTruth = groundTruth(file_input.gTruth.DataSource, file_input.gTruth.LabelDefinitions, New_Label_Data)