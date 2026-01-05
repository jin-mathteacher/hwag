# 파일 업로드 문제 해결 가이드

## 🔍 문제 원인

연구대회 수상작 페이지에서 파일 업로드가 되지 않았던 이유:
1. **localStorage 사용**: 파일이 브라우저의 localStorage에만 저장되어 다른 사용자나 다른 브라우저에서 접근 불가
2. **Supabase 미연결**: Supabase Storage를 사용하지 않아 실제 클라우드 저장소에 파일이 저장되지 않음

## ✅ 해결 방법

### 1. Supabase 설정 업데이트

**중요**: 먼저 Supabase 대시보드에서 다음 SQL 스크립트를 실행해야 합니다:

#### `supabase-update-20mb.sql` 실행
1. Supabase 대시보드 접속
2. SQL Editor 열기
3. `supabase-update-20mb.sql` 파일 내용 복사하여 실행

이 스크립트는:
- Storage 버킷의 파일 크기 제한을 **20MB**로 업데이트
- `files` 테이블에 `year` 컬럼 추가 (연도별 파일 분리)

### 2. 코드 변경 사항

#### 변경된 파일:
- ✅ `research-award-2023.html`
- ✅ `research-award-2024.html`
- ✅ `research-award-2025.html`

#### 주요 변경 내용:
1. **localStorage → Supabase Storage 전환**
   - 파일을 Supabase Storage에 업로드
   - 파일 메타데이터를 `files` 테이블에 저장

2. **연도별 파일 분리**
   - 각 연도별로 파일을 분리하여 저장
   - `year` 컬럼으로 필터링

3. **파일 크기 제한 20MB**
   - 클라이언트 측 검증: 20MB 초과 시 알림
   - Supabase Storage 버킷 설정: 20MB 제한

## 📋 사용 방법

### 파일 업로드
1. 강사 또는 관리자로 로그인
2. 연구대회 수상작 페이지 접속
3. 파일을 드래그 앤 드롭하거나 클릭하여 선택
4. 파일이 Supabase Storage에 업로드됨

### 파일 다운로드
1. 파일 목록에서 다운로드 버튼 클릭
2. Supabase Storage에서 직접 다운로드

### 파일 삭제
1. 강사 또는 관리자만 삭제 가능
2. 삭제 버튼 클릭
3. Storage와 DB에서 모두 삭제

## ⚠️ 주의사항

1. **Supabase 설정 필수**
   - `supabase-update-20mb.sql` 스크립트를 먼저 실행해야 함
   - `files` 테이블에 `year` 컬럼이 있어야 함
   - Storage 버킷의 파일 크기 제한이 20MB로 설정되어 있어야 함

2. **인증 문제**
   - 현재는 인증 없이 사용하도록 설정 (`uploader_id: null`)
   - 향후 Supabase Auth를 사용하려면 추가 설정 필요

3. **에러 확인**
   - 브라우저 콘솔(F12)에서 에러 메시지 확인
   - Supabase 대시보드에서 Storage 및 Database 상태 확인

## 🔧 문제 해결

### 파일 업로드가 안 될 때
1. 브라우저 콘솔 확인 (F12)
2. Supabase 클라이언트 초기화 확인
3. Storage 버킷 존재 확인
4. `files` 테이블 존재 확인
5. RLS 정책 확인

### 파일 크기 제한 오류
1. Supabase Storage 버킷의 `file_size_limit` 확인
2. `supabase-update-20mb.sql` 스크립트 실행 확인

### 파일 목록이 안 보일 때
1. `files` 테이블에 데이터가 있는지 확인
2. `year` 컬럼 값이 올바른지 확인
3. RLS 정책이 올바르게 설정되었는지 확인

