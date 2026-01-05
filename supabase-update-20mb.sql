-- ============================================
-- Supabase Storage 버킷 파일 크기 제한을 20MB로 업데이트
-- ============================================
-- 이 SQL 스크립트는 Supabase 대시보드의 SQL Editor에서 실행하세요.

-- Storage 버킷의 file_size_limit을 20MB (20971520 바이트)로 업데이트
UPDATE storage.buckets
SET file_size_limit = 20971520  -- 20MB
WHERE id = 'class-materials';

-- files 테이블에 year 컬럼 추가 (없는 경우)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'files' 
        AND column_name = 'year'
    ) THEN
        ALTER TABLE public.files ADD COLUMN year INTEGER;
        COMMENT ON COLUMN public.files.year IS '연구대회 연도 (2023, 2024, 2025 등)';
    END IF;
END $$;

-- 업데이트 확인
SELECT 
    id,
    name,
    file_size_limit,
    file_size_limit / 1024 / 1024 as file_size_limit_mb
FROM storage.buckets 
WHERE id = 'class-materials';

-- files 테이블 구조 확인
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'files'
ORDER BY ordinal_position;

