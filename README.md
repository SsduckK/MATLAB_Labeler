# MATLAb_Labeler

- matlab 의 Image Labeler를 이용한 gTruth를 기반으로 동작한다.
- 해당 Image Labeler에서 생성된 gTruth 는 다음과 같은 데이터 구조를 가지고 있다.
- gTruth 값들은 기본적으로 read-only 상태로 저장되어있다.



### gTruth(MATLAB)

1. DataSource
   - 원본 이미지들의 위치의 경로(Source)와 TimeStamps(TimeStamps)가 저장되어 있다.
   - Source는 {n x 1}크기의 cell 형으로 이루어져 있다.
     - 이 때 n = 이미지의 갯수
   - Image Labeler에서는 Timestamp를 사용 안하므로 Timestamp 는 empty 상태이다.
2. LabelDefinitions
   - 해당 gTruth 에서 사용하는 라벨의 위치를 제외한 정보들이 들어있다.
   - {n x 5} 크기의 table 형으로 이루어져 있다.
     - 이 때 n = 라벨 종류의 수
   - Definition 안의 각각의 열은 다음과 같은 정보를 가지고 있다.
     - 1열 : Name
       - 라벨의 이름
       - 한글 입력이 불가하다
     - 2열 : Type
       - 라벨링 타입
       - 0 = rectangle, 1 = line
       - Matlab Image Labler 자체적으로 cuboid, polyline, pixel 등의 부가적인 라벨링 타입이 있으므로 Type이 0, 1 뿐 아니라 더 있을것으로 추측되지만, 직접 확인한 것은 0과 1 두가지이다.
     - 3열 : LabelColor
       - 라벨의 색상 : {n x 3}의 크기를 가진 matrix
         - 이 때 n = 라벨 종류의 수
       - 각각 R, G, B에 해당하는 0 ~ 1 사이의 실수 값들이 저장된다.
     - 4열 : Group
       - 라벨의 그룹
     - 5열 : Description
       - 주석
       - Name에 한글 입력이 불가하지만, 여기에는 한글 입력이 가능하다.
       - 따라서 우리가 활용할 한글로 작성된 라벨명을 여기에 기입하였다.
3. LabelData
   - 라벨의 위치가 들어있다.
   - {m x n} 크기의 table 형으로 이루어져있다.
     - 이 때 m = 이미지의 수, n = 라벨 종류의 수
     - 행 = 이미지의 순서, 열 = 라벨 종류의 순서
   - 하나의 이미지에 있는 같은 종류의 라벨들은 하나의 matrix로 합쳐서 저장된다.
   - 현재 rectangle(Type = 0)과 line(Type = 1) 일때의 상태만 활용하였으므로 이들의 저장 방식을 설명한다.
   - Rectangle 의 저장 방식
     - {n x 4} 크기의 double matrix로 이루어져 있다.
       - 이 때 n = 이미지 안에서 해당 라벨의 수
     - 하나의 라벨에 대해 위치 정보를 표현하기 위해 [x, y, w, h] 의 4개의 값이 저장된다.
       - x, y = 좌측 상단의 x, y좌표
       - w = 라벨의 가로길이, h = 라벨의 세로 길이
   -  Line의 저장 방식
     - {n x 1} 크기의 cell 형으로 이루어져 있다.
       - 이 때 n = 이미지 안에서 해당 라벨의 수
     - 각 cell 에는 double matrix로 구성된 행렬이 들어가 있으며 이때 double matrix 의 수가 이미지 안에서의 라벨의 수. 즉 n 이다.
       - double matrix는 {n x 2}의 형태로 이루어져 있다.
         - 이때 n = point의 수.
       - 각 point에는 [x, y]의 값이 저장되며, 하나의 double matrix 안의 모든 point가 하나의 선으로 구성되어 있다.
       - point가 작성되는 순서대로 이미지에 point가 그려지게 된다.

