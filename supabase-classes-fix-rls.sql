-- ============================================
-- classes 테이블 RLS 정책 확인 및 수정
-- ============================================
-- 이 스크립트는 classes 테이블의 RLS 정책이 없을 경우 생성합니다.
-- ============================================

-- 1. classes 테이블이 존재하는지 확인
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'classes') THEN
        RAISE EXCEPTION 'classes 테이블이 존재하지 않습니다. 먼저 supabase-classes-setup.sql을 실행하세요.';
    END IF;
END $$;

-- 2. RLS가 활성화되어 있는지 확인 및 활성화
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;

-- 3. 기존 정책 삭제 (있는 경우)
DROP POLICY IF EXISTS "Classes Public Read Access" ON public.classes;
DROP POLICY IF EXISTS "Classes Public Insert Access" ON public.classes;
DROP POLICY IF EXISTS "Classes Public Update Access" ON public.classes;
DROP POLICY IF EXISTS "Classes Public Delete Access" ON public.classes;
DROP POLICY IF EXISTS "Public Read Access" ON public.classes;
DROP POLICY IF EXISTS "Public Insert Access" ON public.classes;
DROP POLICY IF EXISTS "Public Update Access" ON public.classes;
DROP POLICY IF EXISTS "Public Delete Access" ON public.classes;

-- 4. classes 테이블 RLS 정책 생성
-- 정책 1: 조회(SELECT) - 누구나(anon) 가능 (등록 코드로 클래스 찾기 위해)
CREATE POLICY "Classes Public Read Access"
ON public.classes
FOR SELECT
USING (true);

-- 정책 2: 추가(INSERT) - 누구나(anon) 가능 (강사가 클래스 생성)
CREATE POLICY "Classes Public Insert Access"
ON public.classes
FOR INSERT
WITH CHECK (true);

-- 정책 3: 수정(UPDATE) - 누구나(anon) 가능 (강사가 클래스 수정)
CREATE POLICY "Classes Public Update Access"
ON public.classes
FOR UPDATE
USING (true)
WITH CHECK (true);

-- 정책 4: 삭제(DELETE) - 누구나(anon) 가능 (강사가 클래스 삭제)
CREATE POLICY "Classes Public Delete Access"
ON public.classes
FOR DELETE
USING (true);

-- 5. 정책 확인
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'classes'
AND schemaname = 'public'
ORDER BY policyname;

-- 완료 메시지
DO $$
BEGIN
    RAISE NOTICE '✅ classes 테이블 RLS 정책 설정 완료';
END $$;

