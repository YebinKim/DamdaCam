# DamdaCam
>### AR Drawing &amp; Selfie Camera "Damda"

Damda는 서울여자대학교 디지털미디어학과 레디파워팀에서 개발한 **AR Drawing & Selfie 카메라 어플리케이션**입니다.   
2018년 9월부터 2019년 5월까지 프로젝트를 진행했으며,  
2019년 6월 5일~6월 10일 진행된 서울여자대학교 디지털미디어학과 제1회 졸업전시에 작품으로써 전시했습니다.  

# 개발 환경
- IDE - Xcode 10.1  
- language - Swift 4  
- Platform - iOS 12.2  
- Test Device - iPhone8  

# 기능1 - AR Drawing
현실 공간에 가상의 3D 라인 또는 도형을 증강현실로 생성할 수 있는 기능입니다.  
Google LLC의 Just A Line을 참고하여 구현하였습니다.  

# 기능2 - AR Selfie
사용자의 얼굴에 실시간으로 3D 콘텐츠를 합성할 수 있는 기능입니다.  
적용할 수 있는 콘텐츠는 머리, 코, 입으로 나누어 .scn 확장자 파일로 편집하였으며,  
Vision 프레임워크를 사용해 실시간으로 얼굴 랜드마크의 2D 좌표를 반환받아 3D 콘텐츠의 위치와 크기를 정하고  
head-pose를 추정하여 얼굴의 방향과 3D 콘텐츠의 방향을 일치시켜 화면에 표시했습니다.  

head-pose를 추정할 수 있는 알고리즘은 자체 개발하여 적용시켰습니다.  
###### 본 프로젝트에 적용된 head-pose 추정 알고리즘은 2019 International Conference on Culture Technology에서 구두로 발표하고 Excellent Paper 상을 수상하였습니다.  

# 기능3 - AR Making
AR Selfie 기능에서 사용할 수 있는 콘텐츠를 직접 제작할 수 있는 기능입니다.  
imageView 위에 그림을 그리고 png로 저장하여 AR Selfie View에서 불러올 수 있도록 구현하였습니다.

# 향후 수정사항
- MVVM 모델로 재설계
- 일부 상황에서 촬영이 불가능한 오류 해결
