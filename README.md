# 김학도
> 클래스를 카테고리 별로 조회하고, 클래스 정보를 제공하는 앱 

<br>

## 📌 프로젝트 소개
> 프로젝트 기간: 2025/09/02 ~ 2025/09/12   
> 개인 프로젝트

**김학도**는 클래스 조회 앱입니다.
- 클래스를 카테고리 별로 조회하고
- 클래스 수강료, 장소 등의 정보를 제공하며
- 댓글로 클래스 후기를 남길 수 있습니다.

<br>

## 📌 개발 환경

- **iOS Deployment Target** : 16.0+
- **Xcode** : 16.4
- **Swift** : 6.1.2
- **UI Framework** : UIKit

<br>
  
## 📌 기술스택  

**Architecture**
- MVVM과 RxSwift 구조체 기반 Input / Output 패턴으로 명확한 데이터 흐름과 반응형 프로그래밍 구현
- Base 구조를 활용해 코드 일관성을 유지하고 중복 로직을 최소화

**Network**
- Alamofire와 Router 패턴으로 API 통신 구조 표준화, Custom Query로 Parameter 타입 안정성 확보
- NWPathMonitor를 통한 네트워크 상태 감지와 서버 응답 값을 통한 에러 처리

**Data**
- NotificationCenter과 Delegate Pattern으로 화면 간 데이터 동기화 및 네트워크 비용 최소화
- Property Wrapper를 활용한 UserDefaults로 사용성 개선 및 중복 코드 제거

**etc.**
- RxSwift Extension으로 RxSwift와 DiffableDataSource를 결합하여 셀 갱신 성능 최적화  

**Frameworks**  
- UIKit, RxSwift, Alamofire, Kingfisher, Toast, SnapKit

<br>

## 📌 기능
<table align="center">
  <tr>
    <th><code>로그인</code></th>
    <th><code>메인 화면</code></th>
    <th><code>상세 화면</code></th>
    <th><code>댓글</code></th>
    <th><code>검색</code></th>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/a13ed080-ea89-4d3d-804d-e7a8b2f9cf04" alt="로그인"></td>
    <td><img src="https://github.com/user-attachments/assets/8fc21917-e51b-4c15-a2a6-52dc3d85f1f6" alt="클래스 조회"></td>
    <td><img src="https://github.com/user-attachments/assets/d6f7fc07-6410-47a1-9625-2c2fc5e82bf6" alt="상세 화면"></td>
    <td><img src="https://github.com/user-attachments/assets/e91cbde2-73a8-408a-b10d-7e0a5f82600a" alt="댓글"></td>
    <td><img src="https://github.com/user-attachments/assets/2f7c7fb3-8ee5-4c81-a471-6412314f909a" alt="검색"></td>
  </tr>
</table>

**로그인**
- 이메일, 비밀번호 유효성 검사
- 자동 로그인 기능


**클래스 조회**
- 카테고리 별 클래스 조회, 다중 카테고리 선택 가능
- 최신순/금액순 정렬
- 클래스 좋아요 기능
- 클래스 장소, 시간, 인원 등의 정보 제공


**댓글**
- 댓글 작성/수정/삭제 기능 제공
- 댓글 작성 시간 상대/절대 표기 지원 (예: 30분 전, 하루 전, 2025년 1월 1일)


**검색**
- 클래스 이름으로 검색
- 클래스 상세 화면으로 이동

<br>

## 📌 설치 및 실행

### 1. 프로젝트 클론
```bash
git clone https://github.com/kyhlsd/KimHakdo
cd KimHakdo
```

### 2. Xcode에서 프로젝트 열기
- Xcode에서 .xcodeproj (또는 .xcworkspace) 파일 열기

### 3. 빌드 및 실행
- Xcode에서 타겟 디바이스 선택 후 실행 (⌘ + R)

> **참고**: API 사용을 위해 `Secrets/` 파일이 필요합니다.

<br>

## 연락처

- **GitHub**: [@kyhlsd](https://github.com/kyhlsd)
- **Email**: kmyghn@gmail.com

