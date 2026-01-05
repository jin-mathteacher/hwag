# Supabase 테이블 및 Storage 설정 가이드

## 실행 방법

1. Supabase 대시보드 접속
2. **SQL Editor** 클릭
3. `supabase-complete-setup.sql` 파일의 내용을 복사하여 붙여넣기
4. **Run** 버튼 클릭하여 실행

## 생성되는 내용

### 1. files 테이블

#### 테이블 구조
```sql
CREATE TABLE public.files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size NUMERIC NOT NULL,
    uploader_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 컬럼 설명
- **id**: 파일 고유 ID (UUID, 자동 생성)
- **file_name**: 파일명
- **file_url**: Supabase Storage 파일 경로
- **file_size**: 파일 크기 (바이트 단위)
- **uploader_id**: 업로드한 사용자 ID (auth.users 참조)
- **created_at**: 파일 업로드 시간 (자동 생성)

#### RLS 정책
- **SELECT (조회)**: 누구나(anon) 가능
- **INSERT (추가)**: 로그인한 사용자(authenticated)만 가능
- **UPDATE (수정)**: 자신이 업로드한 파일만 수정 가능
- **DELETE (삭제)**: 자신이 업로드한 파일만 삭제 가능

### 2. Storage 버킷 정책

#### 버킷: class-materials

#### RLS 정책
- **SELECT (다운로드)**: 누구나(Public) 가능
- **INSERT (업로드)**: 로그인한 사용자(authenticated)만 가능
- **UPDATE (수정)**: 로그인한 사용자만 가능
- **DELETE (삭제)**: 로그인한 사용자만 가능

## 사용 예시

### 파일 업로드 및 메타데이터 저장

```javascript
async function uploadFile(file) {
    const supabase = window.supabaseClient;
    
    // 1. Storage에 파일 업로드
    const fileExt = file.name.split('.').pop();
    const fileName = `${Date.now()}_${Math.random().toString(36).substr(2, 9)}.${fileExt}`;
    const filePath = `class-materials/${fileName}`;
    
    const { data: uploadData, error: uploadError } = await supabase.storage
        .from('class-materials')
        .upload(filePath, file);
    
    if (uploadError) {
        console.error('Storage 업로드 오류:', uploadError);
        throw uploadError;
    }
    
    // 2. Public URL 가져오기
    const { data: urlData } = supabase.storage
        .from('class-materials')
        .getPublicUrl(filePath);
    
    // 3. files 테이블에 메타데이터 저장
    const { data: metaData, error: metaError } = await supabase
        .from('files')
        .insert({
            file_name: file.name,
            file_url: filePath,
            file_size: file.size,
            uploader_id: (await supabase.auth.getUser()).data.user.id
        })
        .select()
        .single();
    
    if (metaError) {
        console.error('메타데이터 저장 오류:', metaError);
        // 업로드된 파일 삭제 (롤백)
        await supabase.storage
            .from('class-materials')
            .remove([filePath]);
        throw metaError;
    }
    
    return {
        storageData: uploadData,
        publicUrl: urlData.publicUrl,
        metadata: metaData
    };
}
```

### 파일 목록 조회

```javascript
async function getFileList() {
    const supabase = window.supabaseClient;
    
    const { data, error } = await supabase
        .from('files')
        .select('*')
        .order('created_at', { ascending: false });
    
    if (error) {
        console.error('파일 목록 조회 오류:', error);
        throw error;
    }
    
    return data;
}
```

### 파일 다운로드

```javascript
async function downloadFile(filePath, fileName) {
    const supabase = window.supabaseClient;
    
    // Public URL 사용 (인증 불필요)
    const { data: urlData } = supabase.storage
        .from('class-materials')
        .getPublicUrl(filePath);
    
    // 또는 직접 다운로드
    const { data, error } = await supabase.storage
        .from('class-materials')
        .download(filePath);
    
    if (error) {
        console.error('다운로드 오류:', error);
        throw error;
    }
    
    // Blob을 다운로드 링크로 변환
    const url = URL.createObjectURL(data);
    const a = document.createElement('a');
    a.href = url;
    a.download = fileName;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}
```

### 파일 삭제

```javascript
async function deleteFile(fileId, filePath) {
    const supabase = window.supabaseClient;
    
    // 1. Storage에서 파일 삭제
    const { error: storageError } = await supabase.storage
        .from('class-materials')
        .remove([filePath]);
    
    if (storageError) {
        console.error('Storage 삭제 오류:', storageError);
        throw storageError;
    }
    
    // 2. files 테이블에서 메타데이터 삭제
    const { error: metaError } = await supabase
        .from('files')
        .delete()
        .eq('id', fileId);
    
    if (metaError) {
        console.error('메타데이터 삭제 오류:', metaError);
        throw metaError;
    }
}
```

## 확인 쿼리

### 테이블 확인
```sql
SELECT * FROM public.files ORDER BY created_at DESC;
```

### RLS 정책 확인
```sql
-- files 테이블 정책
SELECT policyname, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'files' AND schemaname = 'public';

-- Storage 정책
SELECT policyname, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage';
```

## 주의사항

1. **인증 필요**: 파일 업로드/삭제는 로그인한 사용자만 가능합니다.
2. **Public 다운로드**: 파일 다운로드는 인증 없이 가능합니다.
3. **파일 경로**: Storage의 파일 경로와 files 테이블의 file_url은 일치해야 합니다.
4. **롤백 처리**: Storage 업로드는 성공했지만 메타데이터 저장이 실패한 경우, Storage 파일을 삭제해야 합니다.

## 문제 해결

### 오류: "new row violates row-level security policy"
- 사용자가 로그인되어 있는지 확인
- RLS 정책이 올바르게 설정되었는지 확인

### 오류: "Bucket not found"
- 버킷 이름이 정확한지 확인 ('class-materials')
- 버킷이 Public으로 설정되어 있는지 확인

### 오류: "permission denied for table files"
- RLS 정책이 올바르게 설정되었는지 확인
- 사용자 권한 확인

