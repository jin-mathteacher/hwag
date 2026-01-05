# Supabase Storage 설정 가이드

## 1. Supabase 프로젝트 생성

1. https://supabase.com 접속
2. 새 프로젝트 생성
3. 프로젝트 이름 및 데이터베이스 비밀번호 설정
4. 프로젝트 생성 완료 대기 (약 2분)

## 2. 버킷 생성 및 정책 설정

### 방법 1: SQL Editor 사용 (권장)

1. Supabase 대시보드 → **SQL Editor** 클릭
2. `supabase-storage-setup.sql` 파일의 내용을 복사하여 붙여넣기
3. **Run** 버튼 클릭하여 실행

### 방법 2: Storage UI 사용

1. Supabase 대시보드 → **Storage** 클릭
2. **New bucket** 버튼 클릭
3. 버킷 정보 입력:
   - **Name**: `class-materials`
   - **Public bucket**: ✅ 체크 (다운로드를 위해)
4. **Create bucket** 클릭
5. **Policies** 탭에서 정책 설정 (아래 참고)

## 3. 정책 설정 상세 설명

### 다운로드 정책 (Public)
```sql
CREATE POLICY "Public Download Access"
ON storage.objects
FOR SELECT
USING (bucket_id = 'class-materials');
```
- **목적**: 누구나 파일 다운로드 가능
- **권한**: SELECT (읽기)

### 업로드 정책 (Authenticated)
```sql
CREATE POLICY "Authenticated Upload Access"
ON storage.objects
FOR INSERT
WITH CHECK (
    bucket_id = 'class-materials' AND
    auth.role() = 'authenticated'
);
```
- **목적**: 로그인한 사용자만 파일 업로드 가능
- **권한**: INSERT (생성)

### 수정 정책 (Authenticated)
```sql
CREATE POLICY "Authenticated Update Access"
ON storage.objects
FOR UPDATE
USING (
    bucket_id = 'class-materials' AND
    auth.role() = 'authenticated'
);
```
- **목적**: 로그인한 사용자만 파일 수정 가능
- **권한**: UPDATE (수정)

### 삭제 정책 (Authenticated)
```sql
CREATE POLICY "Authenticated Delete Access"
ON storage.objects
FOR DELETE
USING (
    bucket_id = 'class-materials' AND
    auth.role() = 'authenticated'
);
```
- **목적**: 로그인한 사용자만 파일 삭제 가능
- **권한**: DELETE (삭제)

## 4. API 키 확인

Supabase 대시보드에서 다음 정보를 확인하세요:

1. **Settings** → **API**
2. 다음 정보 복사:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
   - **service_role key**: (관리자용, 비밀 유지)

## 5. 정책 확인 방법

SQL Editor에서 다음 쿼리 실행:

```sql
-- 버킷 확인
SELECT * FROM storage.buckets WHERE id = 'class-materials';

-- 정책 확인
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage'
AND policyname LIKE '%class-materials%' OR policyname LIKE '%Download%' OR policyname LIKE '%Upload%';
```

## 6. 테스트

### 업로드 테스트 (인증 필요)
```javascript
const { data, error } = await supabase.storage
  .from('class-materials')
  .upload('test-file.pdf', file);
```

### 다운로드 테스트 (인증 불필요)
```javascript
const { data, error } = await supabase.storage
  .from('class-materials')
  .download('test-file.pdf');
```

## 7. 보안 고려사항

### 현재 설정의 보안 수준
- ✅ **다운로드**: Public (누구나 가능)
- ✅ **업로드**: Authenticated (로그인한 사용자만)
- ⚠️ **주의**: Public 다운로드는 URL만 알면 누구나 접근 가능

### 더 강한 보안이 필요한 경우

#### 옵션 1: 서명된 URL 사용 (임시 접근)
```sql
-- 정책을 더 제한적으로 변경
CREATE POLICY "Signed URL Download"
ON storage.objects
FOR SELECT
USING (
    bucket_id = 'class-materials' AND
    auth.role() = 'authenticated'
);
```

#### 옵션 2: 특정 사용자만 접근
```sql
-- 특정 사용자 ID만 접근 가능하도록
CREATE POLICY "User Specific Access"
ON storage.objects
FOR SELECT
USING (
    bucket_id = 'class-materials' AND
    (storage.foldername(name))[1] = auth.uid()::text
);
```

## 8. 문제 해결

### 정책이 작동하지 않는 경우
1. 버킷이 public으로 설정되어 있는지 확인
2. 정책이 올바르게 생성되었는지 확인
3. 사용자가 올바르게 인증되었는지 확인

### 오류 메시지
- **"new row violates row-level security policy"**: 정책이 업로드를 차단하고 있음
- **"Bucket not found"**: 버킷 이름이 정확한지 확인
- **"Invalid API key"**: API 키가 올바른지 확인

## 9. 다음 단계

정책 설정이 완료되면:
1. 프론트엔드 코드에 Supabase SDK 통합
2. 파일 업로드/다운로드 함수 구현
3. 기존 localStorage 기반 코드를 Supabase로 교체

자세한 구현 방법은 `SUPABASE_INTEGRATION.md`를 참고하세요.

