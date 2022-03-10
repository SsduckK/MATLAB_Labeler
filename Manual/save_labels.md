# save_label

- matlab image labeler를 이용하여 만든 gTruth를 기반으로 라벨 데이터를 정리한다.
  - 라벨 데이터는 rectangle과 line 두 가지를 저장한다.
- gTruth 데이터의 구조는 README에 작성하였으므로 생략

- 데이터의 저장 형식은 csv와 JSON 이 동시에 저장되는 txt로 --- 라는 문자열을 기준으로 위는 csv, 아래는 JSON이다.
  - rectangle을 csv로 저장하고 line을 JSON으로 기록된다.
    - csv
    - \---
    - JSON
  - JSON 의 경우[["라인", [x1, y1], [x2, y2]],["라인", [x1, y1], [x2, y2]]]와 같은 형식으로 저장된다.
- 해당\_이미지의\_이름.txt 으로 각각의 파일이 저장된다.



```matlab
file_input = open('export한 gTruth.mat 파일의 경로');

mkdir labels	//labels 폴더를 만듦

gTruth = file_input.gTruth;
[numRows, numCols] = size(gTruth.LabelData); //LabelData의 크기
```

- file_input 에 image labeler에서 export 한 gTruth.mat 파일을 입력한다.
- labels 폴더는 우리가 txt 파일을 저장할 경로이다.
- 처음 mat 파일을 불러오면 gTruth 하나의 객체만 존재한다. 우리가 필요한 것은 gTruth 내부의 값들이므로 gTruth라는 변수에 file_input.gTruth를 통해서 gTruth 내부의 접근을 하게 한다.
- numRows = LabelData의 행, numCols에 LabelData의 열을 입력한다.



```matlab
for row = 1:numRows			//---->(1)번 for 라고 임시로 명명. 코드의 마지막에 end가 있음
    name = split(gTruth.DataSource.Source{row}, "/");	
    file_name = split(name{end}, ".");
    file_output = ['labels/', file_name{1}, '.txt'];	//이미지를 불러와서 label/이미지_이름.txt로 저장
    fid = fopen(file_output, "w");				

    fprintf(fid, 'Category, y, x, h, w, dist.\n');	//fprint를 이용 파일 명을 생성, string을 입력
    Rows = gTruth.LabelData(row, :);	//LabelData의 행마다 수행
```

- LabelData에서 행별로 이미지가 변하므로 행별로 for를 수행한다. - 이미지마다 수행
- DataSource에서 이미지의 순서 = LabelData에서 이미지의 순서 이므로 이미지의 이름을 가져오기 위해서 DataSource에서 파일 경로로부터 이미지의 이름을 따와서 이를 file_output에 labels/이미지_이름.txt로 저장한다.
  - xxx/yyy/zzz.jpg 라는 이미지 파일일 때 / split 을 이용해 xxx, yyy, zzz.jpg 으로 나눈 후 name에 저장. => name{end}에는 zzz.jpg
  - file_name에 zzz.jpg를 .으로 스플릿 하여 zzz, jpg를 저장. output에서 file_name{1}을 사용하므로 file_out에 labels/zzz.txt 으로 저장되게 된다.
- fopen을 이용해 file_output을 쓰기모드로 호출. fprint를 통해 fid를 쓰기모드로 호출. Category, y, x, h, w, dist. 를 입력한다.
- 이 과정이 이미지가 전환될 때마다 수행되므로 각각의 이미지파일마다 txt 파일을 생성할 준비가 완료되었다.
- Rows에 LabelData로부터 row 번째 행을 저장한다.



```matlab
    for col = 1:numCols		//열마다 수행
            Data = Rows(:, col);	//Row의 열마다 확인하기 위한 Data
            LabelName = gTruth.LabelDefinitions.Description{col};	//Description으로부터 LabelName을 받음
            if((isempty(Data.(1){1})) || (iscell(Data.(1){1})))	//공란일때 처리
                continue
            end
            [numbox, non] = size(Data.(1){1});	//table 내부 요소에 접근하여 크기를 반환. 

            for count = 1:numbox	
                bbox = Data.(1){1, 1}(count, :);	//Data의 행 별로 bbox를 저장
                fprintf(fid, "%s, %d, %d, %d, %d, %1.3f\n", ...
                    LabelName, bbox(:, 2), bbox(:, 1), bbox(:, 4), bbox(:, 3), 0);	//y, x, h, w 입력
            end
        end
```

- 앞서 table에서 행별로 검사를 해서 이미지별로 검색을 하게 만들었으므로 이제 이미지에서 각각의 라벨 클래스들을 살펴보는 과정 - 라벨마다 수행
- LabelData에서 이미지의 열 별로 라벨 클래스가 변하므로 열마다 for를 수행한다.
- Lable-Name에 한글을 사용할 수가 없으나 Description 에는 한글 사용이 가능하다.
  - 라벨 명을 한글로 사용하기 위해 부득이하게 Description에 한글 라벨명을 입력한 후 이를 LabelName으로 취급하여 활용한다.
  - LabelName이라는 변수에 Description{col}을 통해 이미지마다 저장되어있는 Description 을 저장한다.
- size를 통해서 Data 내부의 크기를 구함
  - 사용할 rectangle은 double matrix {n x 4} 형태로 저장되어 있으며, 행 = 같은 라벨, 열 = x, y, w, h이다.
- bbox에 Data의 행 별로 값들을 저장, fid를 호출해서 LabelName, y, x, h, w, 0 순으로 입력하여 저장한다.
- 이 과정을 해당 이미지의 모든 라벨의 종류마다 수행한다.



```matlab
    fprintf(fid, "---\n");
```

- 위 과정을 통해 이미지 내에서 rectangle 라벨은 전부 수행하였으므루 --- 라는 구분 기호로 csv와 json을 구분하기 위한 장치



```matlab
    CheckLineStatus = 0;
    AnyLine = 0;
    for col = 1:numCols			//여기서부터 numLinecell, non 까지의 과정은 위의 box와 동일 --- (2) ---<1>
        Data = Rows(:, col);
        LabelName = gTruth.LabelDefinitions.Description{col};
        if((isempty(Data.(1){1})) || (~iscell(Data.(1){1})))
            continue
        end

        [numLinecell, non] = size(Data.(1){1});		//여기까지 동일 ---(2)
        if CheckLineStatus == 0		//json 구조의 시작일 때 수행
            fprintf(fid, '[');
        elseif CheckLineStatus == 1	//두 번째 구조부터 수행	--- (3)
            fprintf(fid, ',');
        end
        CheckLineStatus = 0;	//리셋용
        for countLine = 1:numLinecell		//행마다 수행	--- <2>
            temp_value1 = jsonencode(round(Data.(1){1}{countLine}, 2));  //json 구조로 데이터를 변환
            temp_value2 = string(temp_value1(2:end)); //2~마지막 까지 문자열을 temp_value2로 지정
            fprintf(fid, '["%s", %s', LabelName, temp_value2);	//[ LabelName temp_value2로 fid를 호출해서 입력

            if countLine ~= numLinecell	//하나의 구조가 반복될동안 , 를 입력
                fprintf(fid, ',');
            end
        end
        CheckLineStatus = CheckLineStatus + 1;	//(3)번 조건을 충족시키기 위함
        AnyLine = 1;	//마무리 조건
    end

    if AnyLine == 1		//위의 과정을 통해 json이 전부 입력되면 해당 조건을 통해서 json 구조가 닫힌다. --- 아마 삭제 가능
        fprintf(fid, ']');
    end
end			//--> 위에서 언급된 (1) for의 end에 해당. 여기서 하나의 이미지에 대해 수행하는 과정이 마무리됨
```

- Line 입력을 json 구조로 입력하기 위한 구간

- json의 구조를 [["라인", [x1, y1], [x2, y2]],["라인", [x1, y1], [x2, y2]]] 으로 생성할 것이므로 시작할 ' [ '을 생성한다.
  - 만약 이미 생성되어 있으며, 하나의 리스트가 마무리 되어서 두번째 리스트가 필요할 경우 CheckLineStatus가 1이 되므로 ' , ' 가 입력되어 리스트를 구분한다.
- cell 내부의 행마다 jsonencode를 통해 json 구조로 만들어 준다.
  - 이렇게 생성된 json 구조는 [[x1, y1], [x2, y2], [x3, y3], ..., [xn, yn]] 과 같은 구조인데여기서 앞의 괄호 ' [ '를 제거한 후 ' [ '와 LabelName을 집어넣어야하므로 temp_value1, 2 과정에서 [x1, y1], [x2, y2], ..., [xn, yn]] 구조로 바꾼 후 이를 fid 를 이용해 ' [ ', LabelName, temp_value2 구조를 완성한다.
- <1>번 for는 외부의 리스트에 대해 저장 - 이미지에서 모든 라인에 대해 적용
- <2>번 for는 내부의 리스트에 대해 저장 - 하나의 라인에서 모든 포인트를 저장함
- 모든 조건이 마무리 되었으면 ' ] '를 추가하여 리스트들을 하나의 json으로 묶음 --- 이 부분은 삭제해도 영향 없을 가능성이 클 것
- ' ] ' 까지 입력되었으면, 하나의 이미지에 대해서 모든 LabelData가 작성된 것이다.
