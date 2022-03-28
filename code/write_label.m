% TODO: 실제 라벨 파일로 테스트 하기 -> done
SRC_MAT_FILE = '/home/ri/workspace/MATLAB/matfiles/220209/220209.1.mat';
write_labels_to_text(SRC_MAT_FILE)

function mat_file_path = write_labels_to_text(mat_file_path)
    file_input = open(mat_file_path);
    gTruth = file_input.input_gTruth;
    [numRows, numCols] = size(gTruth.LabelData);

    % for each file
    for row = 1:numRows
        file_path = gTruth.DataSource.Source{row};
        name = split(file_path, "/");
        file_name = split(name{end}, ".");
        % TODO: 이미지 파일 경로에서 image -> label 로 바꿔서 경로 생성 -> done
        % 폴더가 없으면 폴더 만들기
        label_path = replace(file_path, 'image', 'labels');
        label_path = extractBefore(label_path, file_name{1});
        if ~exist(label_path, "dir")
            mkdir(label_path)
        end
        file_output = [label_path, file_name{1}, '.txt'];
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
        CheckLineStatus = 0;
        AnyLine = 0;
        for col = 1:numCols
            Data = Rows(:, col);
            LabelName = gTruth.LabelDefinitions.Description{col};
            if((isempty(Data.(1){1})) || (~iscell(Data.(1){1})))
                continue
            end
    
            [numLinecell, non] = size(Data.(1){1});
            if CheckLineStatus == 0
                fprintf(fid, '[');
            elseif CheckLineStatus == 1
                fprintf(fid, ',');
            end
            CheckLineStatus = 0;
            for countLine = 1:numLinecell
                temp_value1 = jsonencode(round(Data.(1){1}{countLine}, 2));
                temp_value2 = string(temp_value1(2:end));
                fprintf(fid, '["%s", %s', LabelName, temp_value2);
    
                if countLine ~= numLinecell
                    fprintf(fid, ',');
                end
            end
            CheckLineStatus = CheckLineStatus + 1;
            AnyLine = 1;
        end
    
        if AnyLine == 1
            fprintf(fid, ']');
        end
    end
end
