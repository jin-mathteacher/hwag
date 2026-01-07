-- ============================================
-- Supabase 실습 데이터 저장 테이블 설정
-- ============================================
-- 이 SQL 스크립트는 Supabase 대시보드의 SQL Editor에서 실행하세요.
-- 
-- 포함 내용:
-- 1. practice_data 테이블 생성 (실습 1, 2 데이터 저장)
-- 2. RLS (Row Level Security) 설정
-- 3. Realtime 활성화
-- ============================================

-- ============================================
-- 1. practice_data 테이블 생성
-- ============================================

-- 기존 테이블이 있다면 삭제 (주의: 데이터도 함께 삭제됩니다)
DROP TABLE IF EXISTS public.practice_data CASCADE;

-- practice_data 테이블 생성
CREATE TABLE public.practice_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id TEXT NOT NULL,
    practice_type TEXT NOT NULL CHECK (practice_type IN ('practice1', 'practice2')),
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(class_id, practice_type) -- 각 클래스당 실습 타입별로 하나의 레코드만 유지
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_practice_data_class_id ON public.practice_data(class_id);
CREATE INDEX idx_practice_data_practice_type ON public.practice_data(practice_type);
CREATE INDEX idx_practice_data_updated_at ON public.practice_data(updated_at DESC);

-- 테이블 코멘트 추가
COMMENT ON TABLE public.practice_data IS '실습 데이터 저장 테이블 (실습 1: 워드크라우드, 실습 2: 담벼락)';
COMMENT ON COLUMN public.practice_data.id IS '데이터 고유 ID';
COMMENT ON COLUMN public.practice_data.class_id IS '클래스 ID (classes 테이블 참조)';
COMMENT ON COLUMN public.practice_data.practice_type IS '실습 타입 (practice1 또는 practice2)';
COMMENT ON COLUMN public.practice_data.data IS '실습 데이터 (JSON 형식)';
COMMENT ON COLUMN public.practice_data.created_at IS '데이터 생성 시간';
COMMENT ON COLUMN public.practice_data.updated_at IS '데이터 수정 시간';

-- ============================================
-- 2. RLS (Row Level Security) 설정
-- ============================================

-- RLS 활성화
ALTER TABLE public.practice_data ENABLE ROW LEVEL SECURITY;

-- 기존 정책 삭제 (있는 경우)
DROP POLICY IF EXISTS "Practice Data Public Read Access" ON public.practice_data;
DROP POLICY IF EXISTS "Practice Data Public Insert Access" ON public.practice_data;
DROP POLICY IF EXISTS "Practice Data Public Update Access" ON public.practice_data;
DROP POLICY IF EXISTS "Practice Data Public Delete Access" ON public.practice_data;

-- 정책 1: 조회(SELECT) - 누구나(anon) 가능
CREATE POLICY "Practice Data Public Read Access"
ON public.practice_data
FOR SELECT
USING (true);

-- 정책 2: 추가(INSERT) - 누구나(anon) 가능
CREATE POLICY "Practice Data Public Insert Access"
ON public.practice_data
FOR INSERT
WITH CHECK (true);

-- 정책 3: 수정(UPDATE) - 누구나(anon) 가능
CREATE POLICY "Practice Data Public Update Access"
ON public.practice_data
FOR UPDATE
USING (true)
WITH CHECK (true);

-- 정책 4: 삭제(DELETE) - 누구나(anon) 가능
CREATE POLICY "Practice Data Public Delete Access"
ON public.practice_data
FOR DELETE
USING (true);

-- ============================================
-- 3. Realtime 활성화
-- ============================================

-- Realtime을 활성화하려면 Supabase 대시보드에서:
-- 1. Database > Replication 메뉴로 이동
-- 2. practice_data 테이블을 찾아서 토글 활성화
-- 또는 아래 명령어 실행:

-- ALTER PUBLICATION supabase_realtime ADD TABLE public.practice_data;

-- ============================================
-- 4. updated_at 자동 업데이트 트리거
-- ============================================

-- updated_at 컬럼이 자동으로 업데이트되도록 트리거 함수 생성
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 생성
DROP TRIGGER IF EXISTS update_practice_data_updated_at ON public.practice_data;
CREATE TRIGGER update_practice_data_updated_at
    BEFORE UPDATE ON public.practice_data
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 5. 확인 쿼리
-- ============================================

-- practice_data 테이블 확인
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'practice_data'
ORDER BY ordinal_position;

-- practice_data 테이블 RLS 정책 확인
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'practice_data'
AND schemaname = 'public';

-- ============================================
-- 6. Realtime 활성화 (자동)
-- ============================================

-- Realtime 활성화 시도
DO $$
BEGIN
    -- Realtime publication에 테이블 추가
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.practice_data;
        RAISE NOTICE '✅ Realtime 활성화 완료';
    EXCEPTION
        WHEN OTHERS THEN
            -- 이미 추가되어 있거나 권한 문제인 경우
            RAISE NOTICE '⚠️ Realtime 활성화 실패 또는 이미 활성화됨: %', SQLERRM;
            RAISE NOTICE '   수동으로 활성화하려면: ALTER PUBLICATION supabase_realtime ADD TABLE public.practice_data;';
    END;
END $$;

-- ============================================
-- 설정 완료 메시지
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '✅ practice_data 테이블 생성 완료';
    RAISE NOTICE '✅ RLS 정책 설정 완료';
    RAISE NOTICE '✅ updated_at 자동 업데이트 트리거 설정 완료';
    RAISE NOTICE '✅ Realtime 활성화 시도 완료';
    RAISE NOTICE '✅ 모든 설정이 완료되었습니다!';
END $$;

