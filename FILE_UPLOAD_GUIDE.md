# 파일 업로드 시스템 구현 가이드

## 현재 구현 상태

연구대회 수상작 페이지(2023, 2024, 2025)에 드래그 앤 드롭 파일 업로드 기능이 구현되었습니다.

## 구현된 기능

### ✅ 현재 작동하는 기능
1. **드래그 앤 드롭 업로드**: 파일을 드래그하여 업로드 영역에 놓으면 자동 업로드
2. **클릭 업로드**: 업로드 영역 클릭 또는 파일 선택 버튼으로 업로드
3. **다중 파일 업로드**: 여러 파일을 한 번에 업로드 가능
4. **파일 다운로드**: 수강생들이 업로드된 파일을 다운로드 가능
5. **권한 관리**: 강사/관리자만 업로드 및 삭제 가능
6. **파일 목록 표시**: 업로드된 파일 목록과 정보 표시

## ⚠️ 현재 제한사항 (프론트엔드만 사용 시)

### 1. **저장 용량 제한**
- **localStorage 용량 제한**: 브라우저별로 다르지만 보통 **5-10MB**
- **파일 크기 제한**: 현재 **10MB**로 설정됨
- **전체 저장 공간**: 모든 파일의 합이 localStorage 용량을 초과하면 오류 발생

### 2. **데이터 지속성**
- 브라우저 캐시 삭제 시 모든 파일 삭제
- 다른 브라우저/기기에서 접근 불가
- 사용자별로 다른 데이터 (공유 불가)

### 3. **성능 문제**
- 큰 파일 업로드 시 브라우저 메모리 부족 가능
- base64 인코딩으로 파일 크기가 약 33% 증가

## 🔧 실제 운영을 위해 필요한 것

### 옵션 1: 백엔드 서버 구축 (권장)

#### 필요한 기술
- **서버**: Node.js, Python (Flask/Django), PHP 등
- **데이터베이스**: MySQL, PostgreSQL, MongoDB 등
- **파일 저장소**: 서버 디스크 또는 클라우드 스토리지 (AWS S3, Google Cloud Storage 등)

#### 구현 방법
```javascript
// 예시: Node.js + Express
const express = require('express');
const multer = require('multer');
const app = express();

const upload = multer({ dest: 'uploads/' });

app.post('/api/upload', upload.single('file'), (req, res) => {
    // 파일 저장 및 메타데이터 DB에 저장
    res.json({ success: true, fileId: req.file.filename });
});

app.get('/api/download/:fileId', (req, res) => {
    // 파일 다운로드
    res.download(`uploads/${req.params.fileId}`);
});
```

### 옵션 2: 클라우드 스토리지 서비스 사용

#### 추천 서비스
1. **Firebase Storage** (Google)
   - 무료 용량: 5GB
   - 실시간 동기화
   - 인증 시스템 내장

2. **AWS S3** (Amazon)
   - 확장 가능
   - CDN 연동 가능
   - 비용: 사용량 기반

3. **Supabase Storage**
   - PostgreSQL 기반
   - 실시간 기능
   - 무료 티어 제공

### 옵션 3: IndexedDB 사용 (프론트엔드 개선)

현재 localStorage 대신 IndexedDB를 사용하면:
- **용량 제한**: 수백 MB ~ 수 GB (브라우저별 상이)
- **더 큰 파일 저장 가능**
- 여전히 브라우저별로 분리됨

## 📋 권장 구현 단계

### 단계 1: 현재 상태 (프론트엔드만)
- ✅ 작은 파일(10MB 이하) 업로드/다운로드
- ✅ 데모/테스트용으로 사용 가능
- ⚠️ 실제 운영에는 부적합

### 단계 2: IndexedDB로 개선
- 용량 제한 확대 (수백 MB)
- 여전히 브라우저별 분리

### 단계 3: 백엔드 서버 구축 (실제 운영)
- 무제한 파일 저장
- 모든 사용자 공유
- 보안 강화
- 백업 및 복구

## 🚀 빠른 해결책: Firebase Storage 사용

가장 빠르게 실제 운영 환경을 구축하려면 Firebase Storage를 사용하는 것을 권장합니다.

### Firebase Storage 설정 방법

1. **Firebase 프로젝트 생성**
   - https://console.firebase.google.com 접속
   - 새 프로젝트 생성

2. **Storage 활성화**
   - Firebase Console → Storage → 시작하기
   - 보안 규칙 설정

3. **코드 통합**
```html
<!-- Firebase SDK 추가 -->
<script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-storage.js"></script>

<script>
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    storageBucket: "YOUR_PROJECT.appspot.com"
  };
  firebase.initializeApp(firebaseConfig);
  const storage = firebase.storage();
</script>
```

## 현재 시스템 사용 방법

### 강사/관리자
1. 연구대회 수상작 페이지 접속
2. 파일을 드래그하여 업로드 영역에 놓기
3. 또는 "파일 선택" 버튼 클릭
4. 업로드 완료 후 파일 목록에 표시

### 수강생
1. 연구대회 수상작 페이지 접속
2. 업로드된 파일 목록 확인
3. "다운로드" 버튼 클릭하여 파일 다운로드

## 주의사항

⚠️ **현재는 프론트엔드만 사용하므로:**
- 브라우저 캐시 삭제 시 모든 파일 삭제
- 다른 사용자와 파일 공유 불가
- 용량 제한 있음 (약 5-10MB)
- 실제 운영 환경에서는 백엔드 서버 필수

## 문의

기술적 지원이 필요하시면 개발팀에 문의해주세요.




