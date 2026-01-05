-- ============================================
-- Supabase 완전 설정 스크립트
-- ============================================
-- 이 SQL 스크립트는 Supabase 대시보드의 SQL Editor에서 실행하세요.
-- 
-- 포함 내용:
-- 1. files 테이블 생성 및 RLS 설정
-- 2. Storage 버킷(class-materials) RLS 정책 설정
-- ============================================

-- ============================================
-- 1. files 테이블 생성
-- ============================================

-- 기존 테이블이 있다면 삭제 (주의: 데이터도 함께 삭제됩니다)
DROP TABLE IF EXISTS public.files CASCADE;

-- files 테이블 생성
CREATE TABLE public.files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size NUMERIC NOT NULL,
    uploader_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_files_uploader_id ON public.files(uploader_id);
CREATE INDEX idx_files_created_at ON public.files(created_at DESC);

-- 테이블 코멘트 추가
COMMENT ON TABLE public.files IS '연구대회 수상작 파일 메타데이터 저장 테이블';
COMMENT ON COLUMN public.files.id IS '파일 고유 ID';
COMMENT ON COLUMN public.files.file_name IS '파일명';
COMMENT ON COLUMN public.files.file_url IS 'Supabase Storage 파일 경로';
COMMENT ON COLUMN public.files.file_size IS '파일 크기 (바이트)';
COMMENT ON COLUMN public.files.uploader_id IS '업로드한 사용자 ID (auth.users 참조)';
COMMENT ON COLUMN public.files.created_at IS '파일 업로드 시간';

-- ============================================
-- 2. files 테이블 RLS (Row Level Security) 설정
-- ============================================

-- RLS 활성화
ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;

-- 기존 정책 삭제 (있는 경우)
DROP POLICY IF EXISTS "Public Read Access" ON public.files;
DROP POLICY IF EXISTS "Authenticated Insert Access" ON public.files;
DROP POLICY IF EXISTS "Authenticated Update Access" ON public.files;
DROP POLICY IF EXISTS "Authenticated Delete Access" ON public.files;

-- 정책 1: 조회(SELECT) - 누구나(anon) 가능
CREATE POLICY "Public Read Access"
ON public.files
FOR SELECT
USING (true);

-- 정책 2: 추가(INSERT) - 로그인한 사용자(authenticated)만 가능
CREATE POLICY "Authenticated Insert Access"
ON public.files
FOR INSERT
WITH CHECK (
    auth.role() = 'authenticated'
);

-- 정책 3: 수정(UPDATE) - 로그인한 사용자만 자신이 업로드한 파일 수정 가능
CREATE POLICY "Authenticated Update Access"
ON public.files
FOR UPDATE
USING (
    auth.role() = 'authenticated' AND
    (uploader_id = auth.uid() OR auth.uid() IN (
        SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin'
    ))
)
WITH CHECK (
    auth.role() = 'authenticated' AND
    (uploader_id = auth.uid() OR auth.uid() IN (
        SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin'
    ))
);

-- 정책 4: 삭제(DELETE) - 로그인한 사용자만 자신이 업로드한 파일 삭제 가능
CREATE POLICY "Authenticated Delete Access"
ON public.files
FOR DELETE
USING (
    auth.role() = 'authenticated' AND
    (uploader_id = auth.uid() OR auth.uid() IN (
        SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin'
    ))
);

-- ============================================
-- 3. Storage 버킷(class-materials) RLS 정책 설정
-- ============================================

-- 기존 정책 삭제 (있는 경우)
DROP POLICY IF EXISTS "Public Download Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete Access" ON storage.objects;

-- 정책 1: 다운로드(SELECT) - 누구나 가능 (Public 버킷이지만 명시적으로 설정)
CREATE POLICY "Public Download Access"
ON storage.objects
FOR SELECT
USING (
    bucket_id = 'class-materials'
);

-- 정책 2: 업로드(INSERT) - 로그인한 사용자(authenticated)만 가능
CREATE POLICY "Authenticated Upload Access"
ON storage.objects
FOR INSERT
WITH CHECK (
    bucket_id = 'class-materials' AND
    auth.role() = 'authenticated'
);

-- 정책 3: 수정(UPDATE) - 로그인한 사용자만 자신이 업로드한 파일 수정 가능
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

-- 정책 4: 삭제(DELETE) - 로그인한 사용자만 자신이 업로드한 파일 삭제 가능
CREATE POLICY "Authenticated Delete Access"
ON storage.objects
FOR DELETE
USING (
    bucket_id = 'class-materials' AND
    auth.role() = 'authenticated'
);

-- ============================================
-- 4. 확인 쿼리
-- ============================================

-- files 테이블 확인
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'files'
ORDER BY ordinal_position;

-- files 테이블 RLS 정책 확인
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
WHERE tablename = 'files'
AND schemaname = 'public';

-- Storage 버킷 확인
SELECT * FROM storage.buckets WHERE id = 'class-materials';

-- Storage RLS 정책 확인
SELECT 
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'objects'
AND schemaname = 'storage'
AND (qual::text LIKE '%class-materials%' OR with_check::text LIKE '%class-materials%');

-- ============================================
-- 설정 완료 메시지
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '✅ files 테이블 생성 완료';
    RAISE NOTICE '✅ files 테이블 RLS 정책 설정 완료';
    RAISE NOTICE '✅ Storage 버킷(class-materials) RLS 정책 설정 완료';
    RAISE NOTICE '✅ 모든 설정이 완료되었습니다!';
END $$;

