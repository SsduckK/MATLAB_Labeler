# restore.m

- 작성되어있는 txt 파일을 기반으로 이미지에 라벨을 그림
-  Matlab Image Labeler에서 추출한 gTruth는 구조가 복잡하여 이를 직접 구현하는 것이 난점이었으나 하단에 후술될 트릭으로 해결
- 본 구조는 save_label에서 만들어 낸 csv --- json 구조를 기반으로 복원한다.
  - 활용된 원리를 기반으로 하면 다른 구조에도 적용 가능



### 사전 작업

- 사용할 LabelDefinition을 미리 생성해둔다.

### 본문

#### 경로 설정

```matlab
DATASET_ROOT = '/home/ri/workspace/Sample_Result_22.03.11/220209/magok/2022-02-09-19-53-05';
IMAGE_ROOT = fullfile(DATASET_ROOT, '/image');
LABEL_ROOT = fullfile(DATASET_ROOT, '/labels');
DEFINITION_ROOT = '/home/ri/workspace/MATLAB/line1Definition.mat';
DST_MAT_PATH = '/home/ri/workspace/MATLAB/matfiles';
```

- DATASET_ROOT - 이미지 및 라벨 파일이 들어있는 경로
- IMAGE, LABEL_ROOT - DATSET 하위에 존재하는 이미지, 라벨 폴더 경로
- DEFINITION_ROOT - 사전 생성해둔 LabelDefinition
- DST_MAT_PATH - mat 파일을 저장할 경로



#### reconstruct_label_data

```matlab
function ground_truth = reconstruct_label_data(image_path, definition_path, label_path, dst_mat_path)
    source_files = list_image_files(image_path);
    label_definition = read_label_definition(definition_path);
    label_data = read_label_data(image_path, definition_path, label_path);
    ground_truth = groundTruth(source_files, label_definition, label_data);
    save_gtruth_file(ground_truth, dst_mat_path)
end
```

- ground_truth 를 반환하는 함수
- 다수의 다른 함수들로 구성되어있으며 각각의 함수들은 하단에 설명
- image_path - 이미지 경로, definition_path - LabelDefinition의 경로, label_path - 라벨 경로, dst_mat_path - 저장할 파일의 경로
- 여기서 ground truth를 생성해서 저장하며, ground_truth를 반환하는 이유는 잘못된 부분이 생성되었는지 확인하기 위함



#### list_image_files

```matlab
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
```

- source_files를 반환하는 list_image_files 함수. image_path를 입력으로 받음
- 사용할 이미지들을 모음

- data_source에 image_path 하의 모든 jpg 파일들을 입력받음
- 경로 /파일 명으로 셀 구조로 data에 저장
- groundTruthDataSource를 통해 data를 source_files라는 DataSource 형식으로 저장



#### read_label_definition

```matlab
function definition_file = read_label_definition(definition_path)
    definition = open(definition_path);
    definition_file = definition.labelDefs;
end
```

- definition_file을 반환하는 read_label_definition 함수. definition_path를 입력으로 받음
- LabelDefinition을 definition_file에 저장



#### read_label_data

##### 세팅

```matlab
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
```

- data_file을 반환하는 read_label_data 함수. image_path, def_path, label_path를 입력으로 받음
- 라벨을 읽어 table에 입력한다.
- datastore를 통해 다수의 라벨들을 하나로 묶으며 labels_files에 labels_datastore 안에서 파일명만 저장한다.
  - datastore 함수를 이용하면 파일 명만 저장되는 것이 아니라 경로 및 각종 속성들까지 같이 저장되므로, 우리가 필요한 파일명만 따로 꺼내서 저장한다.
  - Datastore를 만들 때 파일을 읽어올 방식과 변수들을 사전에 지정한다.
    - TextscanFormats - Category, y, x, h, w, dist_ 를 읽어오므로 이에 맞는 포맷을 미리 지정해준다.
    - Readvariablenames를 false로 함으로 인해 우리가 지정한 변수명들을 수동으로 사용할 수 있게 해준다.
    - variableNames에서 변수명들을 지정하고 사용하도록 한다.
  - 이 부분은 최상단에 Category, y, x, h, w, dist_ 이들이 없을 떄 수행되며 만약 존재한다면 하단의 코드를 수정할 필요 존재
    - box 정리, 차선에서 **로 표시한 부분이 이에 해당하는 부분이며 만약 Category...가 없으면 범위를 2가 아니라 1로 수정해서 실행시켜야 한다.

- label_definition의 행의 갯수가 table의 열의 갯수가 되고, 이미지의 갯수가 table의 행의 갯수가 된다.

- templabe_table에 구한 행, 열로 빈 table을 저장하며 이때 변수 명은 label_definition을 따른다.



##### box 라벨 정리

```matlab
for file_idx = 1:length(labels_files)	//(1)번 for라 함. 마지막에 end 존재
    labels = fileread(labels_files{file_idx});	//파일마다 수행 
    labels = split(labels, '---');			  // --- 로 split 하여 csv, json을 나눔
    labels_box = split(labels{1}, newline);	  // csv를 labels_box에 입력
    
    for box_index = 2:length(labels_box)		//각각의 labelbox에 대해 수행	**
        box_data = split(labels_box(box_index), ',');	//', '로 나누어진 정보를 읽기 위함
        if isempty(box_data{1})		//labelbox가 없을 때
            continue
        end
        box_name = box_data{1};		//box의 클래스
        x = str2double(box_data{3});	//y, x, h, w로 배치된 것을 x, y, w, h에 각각 대입
        y = str2double(box_data{2});	//이 때 string으로 읽어오므로 str2double을 통해 실수로 바꿔줌
        w = str2double(box_data{5});
        h = str2double(box_data{4});
        box_position = [x y w h];		
    
        box_name_number = find(strcmp(LabelDefinition{:, 5}, box_name));  //description으로부터 Name 번호 찾기
        box_label_name = LabelDefinition{:, 1}{box_name_number};	//Name 번호로 Name 찾기
        LabelData{:, box_name_number}{file_idx} = \
           [LabelData{:, box_name_number}{file_idx}; box_position];	//데이터 입력
    end
```

- 각각의 파일들 중 ---을 기준으로 해서 csv 형태로 작성된 박스를 처리하는 영역
- 입력받은 csv 파일은 ', '를 기준으로 분류, y, x, h, w, dist 값을 입력받는다.

- string으로 읽어오므로 double로 바꿔서 x, y, w, h 자리에 맞게 저장을 하며 double matrix로 저장한다.
- Definition의 5번째 열은 description이 저장되어있는 열이며, Label 저장을 할 때 이 열의 내용을 이름으로 하여 저장하였기 때문에 Description을 통해 Label의 Name을 찾아낸다.

- LabelData 에서 분류는 열로 구분되므로 LabelData에 찾은 box number를 통해 구한 분류의 위치에 box position을 추가하여 box를 작성한다.



##### 박스, 라인 구분

```matlab
    if labels{2} == newline		//차선이 없을 때의 시행되는 영역
        continue
    else
        labels_line = jsondecode(labels{2});
    end
```

- label을 ---으로 split 한 결과의 두 번째 구조에는 json으로 작성되어있는 string이 저장되어 있다.
- 만약 이미지에 차선이 없을 경우 이 부분이 작성된 것이 없으므로 비어있을 것이다.
- json 구조가 존재하면 jsonencode를 써서 json 형식으로 string을 변환한 후 labels_line에 저장한다



##### 차선

```matlab
	for line_index = 1:length(labels_line)
        line_list = labels_line{line_index};
        line_name = labels_line{line_index}{1};		//line의 이름을 저장
        line_point_array = [];		//cell 구조로 저장된 line을 담기 위한 matrix
        for line_point = 2:length(line_list)	//line_list의 두번째 부터 point가 찍힘	**	
            if length(line_list) == 3
            	continue
            end	
            x = line_list{line_point}(1);
            y = line_list{line_point}(2);
            line_point_array = [line_point_array; x y];	//point들을 저장
        end
        
        line_name_number = find(strcmp(LabelDefinition{:, 5}, line_name));	//box의 Description으로부터
        line_label_name = LabelDefinition{:, 1}{line_name_number};			//Name을 찾는 과정과 동일
        LabelData{:, line_name_number}{file_idx} =
           [LabelData{:, line_name_number}{file_idx}; line_point_array];	
    end
end	//(1)번 for의 end
```

- label에서 ---을 기준으로 해서 json 형태로 작성된 라인을 처리하는 영역
- MATLAB Image Labeler에서 line 타입은 cell 형태로 저장되므로 cell 구조를 이용하기 위해 line_point_array라는 변수를 생성하여 활용한다.
- Line 타입은 같은 선 상의 point들이 하나의 matrix 구조로 저장되어 있으므로, 이를 위한 matrix를 line_point_array라고 지정하여 저장한다.
  - line_point_array에 저장된 point들이 모여 하나의 선을 구성한다.
  - 같은 종류의 선들이 모여 하나의 cell 아래에 저장되어있다.
- line_list의 길이가 3일 경우 차선, 하나의 포인트(x, y)를 나타낼 때 이다.
  - 하나의 포인트는 무시하므로 continue를 통해 무시한다.

- 이러한 과정이 읽어온 매 파일마다 반복된다.



#### save_gtruth_file

```matlab
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
```

- ground_truth, dst_mat_path를 입력받는 save_gtruth_file.
- 완성한 groundtruth를 mat파일 형식으로 저장한다.

- 저장 경로는 dst_mat_path 하의 dir_name이다.
  - 여기서 dir_name은 Source의 저장 년/월/일이다.

- 만약 폴더가 존재하지 않을 경우 지정된 경로에 파일을 만든다.
- time에 HH:MM:SS 형식으로 현재 시각을 저장하여 mat 파일의 버전을 관리한다.
