-- ============================================
-- Supabase Storage 버킷 생성 및 정책 설정
-- ============================================
-- 이 SQL 스크립트는 Supabase 대시보드의 SQL Editor에서 실행하세요.
-- 버킷 이름: class-materials
-- 정책: 다운로드(public), 업로드(authenticated만)
-- ============================================

-- 1. 버킷 생성 (이미 생성되어 있다면 이 단계는 건너뛰세요)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'class-materials',
    'class-materials',
    true,  -- public: true로 설정하면 다운로드 URL이 공개됩니다
    10485760,  -- 10MB 파일 크기 제한 (바이트 단위)
    NULL  -- NULL이면 모든 파일 타입 허용, 또는 배열로 지정: ARRAY['image/png', 'application/pdf']
)
ON CONFLICT (id) DO NOTHING;

-- 2. 기존 정책 삭제 (있는 경우)
DROP POLICY IF EXISTS "Public Download Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update Access" ON storage.objects;

-- 3. 다운로드 정책 (SELECT) - 누구나 다운로드 가능
CREATE POLICY "Public Download Access"
ON storage.objects
FOR SELECT
USING (
    bucket_id = 'class-materials'
);

-- 4. 업로드 정책 (INSERT) - 로그인한 사용자만 업로드 가능
CREATE POLICY "Authenticated Upload Access"
ON storage.objects
FOR INSERT
WITH CHECK (
    bucket_id = 'class-materials' AND
    auth.role() = 'authenticated'
);

-- 5. 파일 수정 정책 (UPDATE) - 로그인한 사용자만 수정 가능
CREATE POLICY "Authenticated Update Access"
ON storage.objects
FOR UPDATE
USING (
    bucket_id = 'class-materials' AND
    auth.role() = 'authenticated'
)
WITH CHECK (
    bucket_id = 'class-materials' AND
    auth.role() = 'authenticated'
);

-- 6. 파일 삭제 정책 (DELETE) - 로그인한 사용자만 삭제 가능
CREATE POLICY "Authenticated Delete Access"
ON storage.objects
FOR DELETE
USING (
    bucket_id = 'class-materials' AND
    auth.role() = 'authenticated'
);

-- ============================================
-- 정책 확인 쿼리
-- ============================================
-- 아래 쿼리로 생성된 정책을 확인할 수 있습니다:
-- SELECT * FROM storage.buckets WHERE id = 'class-materials';
-- SELECT * FROM pg_policies WHERE tablename = 'objects' AND schemaname = 'storage';

