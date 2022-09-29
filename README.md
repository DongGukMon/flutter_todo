# flutter_todo

flutter를 입문 프로젝트로 만든 Todo list 앱입니다.

## 기술 스택
- flutter
- dart

## 구현 범위
-ListView로 ToTo List 구현
-ListView 정렬 규칙 선택: [최신순, 진행도순] (바텀시트 활용)
-list 추가 및 삭제 모달 구현(dialog 활용)
-텍스트 입력 필드 (글자수 제한 조건 추가)
-모달에서 입력받은 데이터를 기반으로 List item 추가
-List item 터치로 상세 보기 노출(touchable container-inkwell 활용)
-state 변경에 따라 각 list item 색상 및 일부 텍스트 변형(조건부 스타일)
-앱을 종료해도 입력한 todo list가 유지도되도록 local storage에 데이터 저장(shared_preferences 활용)
-앱 로드 시 local storage에서 데이터를 불러와 list 기본값 셋팅

## 결과물


