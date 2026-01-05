# Supabase 사용 예시

## 설정 완료

다음 파일들이 생성/수정되었습니다:
- ✅ `js/supabase-config.js` - Supabase 클라이언트 초기화
- ✅ `index.html` - Supabase CDN 추가
- ✅ `research-award-2023.html` - Supabase CDN 추가
- ✅ `research-award-2024.html` - Supabase CDN 추가
- ✅ `research-award-2025.html` - Supabase CDN 추가

## 다른 JS 파일에서 Supabase 사용하기

### 방법 1: window 객체 사용 (권장)

```javascript
// 다른 JS 파일에서 (예: upload.js)
// supabase-config.js가 먼저 로드되어야 함

// supabase 클라이언트 사용
const supabase = window.supabaseClient;

// 또는 직접 접근
const supabase = window.supabase.createClient(
    'https://jxeyvvstwoktkoaltmie.supabase.co',
    'sb_publishable_6OlVgtiomTJGkOyhBXTqEQ_nMr3WUGw'
);
```

### 방법 2: HTML에서 직접 사용

```html
<script>
    // supabase-config.js가 로드된 후
    const supabase = window.supabaseClient;
    
    // 파일 업로드 예시
    async function uploadFile(file) {
        const fileExt = file.name.split('.').pop();
        const fileName = `${Math.random()}.${fileExt}`;
        const filePath = `class-materials/${fileName}`;
        
        const { data, error } = await supabase.storage
            .from('class-materials')
            .upload(filePath, file);
        
        if (error) {
            console.error('업로드 오류:', error);
            return null;
        }
        
        return data;
    }
</script>
```

## 파일 업로드 예시

```javascript
async function uploadToSupabase(file, folder = 'class-materials') {
    try {
        // 파일 확장자 추출
        const fileExt = file.name.split('.').pop();
        // 고유한 파일명 생성
        const fileName = `${Date.now()}_${Math.random().toString(36).substr(2, 9)}.${fileExt}`;
        const filePath = `${folder}/${fileName}`;
        
        // Supabase Storage에 업로드
        const { data, error } = await window.supabaseClient.storage
            .from('class-materials')
            .upload(filePath, file, {
                cacheControl: '3600',
                upsert: false
            });
        
        if (error) {
            console.error('업로드 오류:', error);
            throw error;
        }
        
        console.log('업로드 성공:', data);
        return data;
    } catch (error) {
        console.error('파일 업로드 실패:', error);
        throw error;
    }
}
```

## 파일 다운로드 예시

```javascript
async function downloadFromSupabase(filePath) {
    try {
        // 파일 다운로드
        const { data, error } = await window.supabaseClient.storage
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
        a.download = filePath.split('/').pop();
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        
        return data;
    } catch (error) {
        console.error('파일 다운로드 실패:', error);
        throw error;
    }
}
```

## Public URL 가져오기 (다운로드 링크)

```javascript
async function getPublicUrl(filePath) {
    const { data } = window.supabaseClient.storage
        .from('class-materials')
        .getPublicUrl(filePath);
    
    return data.publicUrl;
}

// 사용 예시
const url = await getPublicUrl('class-materials/example.pdf');
console.log('Public URL:', url);
```

## 파일 목록 가져오기

```javascript
async function listFiles(folder = 'class-materials') {
    const { data, error } = await window.supabaseClient.storage
        .from('class-materials')
        .list(folder, {
            limit: 100,
            offset: 0,
            sortBy: { column: 'created_at', order: 'desc' }
        });
    
    if (error) {
        console.error('파일 목록 가져오기 오류:', error);
        throw error;
    }
    
    return data;
}
```

## 파일 삭제

```javascript
async function deleteFile(filePath) {
    const { data, error } = await window.supabaseClient.storage
        .from('class-materials')
        .remove([filePath]);
    
    if (error) {
        console.error('파일 삭제 오류:', error);
        throw error;
    }
    
    return data;
}
```

## 인증이 필요한 경우

```javascript
// 로그인
async function signIn(email, password) {
    const { data, error } = await window.supabaseClient.auth.signInWithPassword({
        email: email,
        password: password
    });
    
    if (error) {
        console.error('로그인 오류:', error);
        throw error;
    }
    
    return data;
}

// 현재 사용자 확인
async function getCurrentUser() {
    const { data: { user } } = await window.supabaseClient.auth.getUser();
    return user;
}

// 로그아웃
async function signOut() {
    const { error } = await window.supabaseClient.auth.signOut();
    if (error) {
        console.error('로그아웃 오류:', error);
        throw error;
    }
}
```

## 주의사항

1. **스크립트 로드 순서**: `supabase-config.js`는 Supabase CDN이 로드된 후에 실행되어야 합니다.
2. **에러 처리**: 모든 Supabase 작업에 에러 처리를 추가하세요.
3. **인증**: 업로드/삭제는 인증이 필요하므로, 사용자가 로그인되어 있는지 확인하세요.

## 다음 단계

이제 `research-award-*.html` 파일들의 파일 업로드/다운로드 기능을 localStorage에서 Supabase Storage로 전환할 수 있습니다.

