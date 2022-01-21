file_input = open('home/ri/workspace/MATLAB/SamplegTruth.mat');

mkdir labels

gTruth = file_input.gTruth;
[numRows, numCols] = size(gTruth.LabelData);

% for each file
for row = 1:numRows
    name = split(gTruth.DataSource.Source{row}, "/");
    file_name = split(name{end}, ".");
    file_output = ['labels/', file_name{1}, '.txt'];
    fid = fopen(file_output, "w");

    fprintf(fid, 'Category, y, x, h, w, dist.\n');
    Rows = gTruth.LabelData(row, :);
    for col = 1:numCols
        Data = Rows(:, col);
        LabelName = gTruth.LabelDefinitions.Description{col};
        if((isempty(Data.(1){1})) || (iscell(Data.(1){1})))
            continue
        end
        [numbox, non] = size(Data.(1){1});

        for count = 1:numbox
            bbox = Data.(1){1, 1}(count, :);
            fprintf(fid, "%s, %d, %d, %d, %d, %1.3f\n", ...
                LabelName, bbox(:, 2), bbox(:, 1), bbox(:, 4), bbox(:, 3), 0);
        end
    end

    fprintf(fid, "---\n");

    for col = 1:numCols
        Data = Rows(:, col);
        LabelName = gTruth.LabelDefinitions.Description{col};
        if((isempty(Data.(1){1})) || (~iscell(Data.(1){1})))
            continue
        end

        [numLinecell, non] = size(Data.(1){1});
        Linecell = [];
        fprintf(fid, '[');
        for countLine = 1:numLinecell
            lane = round(Data.(1){1}{countLine}, 2);

            temp_value1 = jsonencode(round(Data.(1){1}{countLine}, 2));
            temp_value2 = string(temp_value1(2:end));
            fprintf(fid, '["차선%d", %s', countLine, temp_value2);

            if countLine == numLinecell
                fprintf(fid, ']');
            else
                fprintf(fid, ', ');
            end
        end
    end
end

