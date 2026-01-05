-- ============================================
-- Supabase 클래스 및 수강생 관리 테이블 설정
-- ============================================
-- 이 SQL 스크립트는 Supabase 대시보드의 SQL Editor에서 실행하세요.
-- 
-- 포함 내용:
-- 1. classes 테이블 생성 (클래스 정보)
-- 2. students 테이블 생성 (수강생 정보)
-- 3. RLS (Row Level Security) 설정
-- ============================================

-- ============================================
-- 1. classes 테이블 생성
-- ============================================

-- 기존 테이블이 있다면 삭제 (주의: 데이터도 함께 삭제됩니다)
DROP TABLE IF EXISTS public.students CASCADE;
DROP TABLE IF EXISTS public.classes CASCADE;

-- classes 테이블 생성
CREATE TABLE public.classes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    code TEXT NOT NULL UNIQUE,
    teacher_username TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_classes_code ON public.classes(code);
CREATE INDEX idx_classes_teacher_username ON public.classes(teacher_username);
CREATE INDEX idx_classes_created_at ON public.classes(created_at DESC);

-- 테이블 코멘트 추가
COMMENT ON TABLE public.classes IS '강사가 생성한 클래스 정보 저장 테이블';
COMMENT ON COLUMN public.classes.id IS '클래스 고유 ID';
COMMENT ON COLUMN public.classes.name IS '클래스 이름';
COMMENT ON COLUMN public.classes.description IS '클래스 설명';
COMMENT ON COLUMN public.classes.code IS '수강생 등록 코드 (고유)';
COMMENT ON COLUMN public.classes.teacher_username IS '강사 사용자명';
COMMENT ON COLUMN public.classes.created_at IS '클래스 생성 시간';
COMMENT ON COLUMN public.classes.updated_at IS '클래스 수정 시간';

-- ============================================
-- 2. students 테이블 생성
-- ============================================

-- students 테이블 생성
CREATE TABLE public.students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id TEXT NOT NULL REFERENCES public.classes(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(class_id, name) -- 같은 클래스에 같은 이름의 수강생은 중복 불가
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_students_class_id ON public.students(class_id);
CREATE INDEX idx_students_name ON public.students(name);
CREATE INDEX idx_students_registered_at ON public.students(registered_at DESC);

-- 테이블 코멘트 추가
COMMENT ON TABLE public.students IS '수강생 정보 저장 테이블';
COMMENT ON COLUMN public.students.id IS '수강생 고유 ID';
COMMENT ON COLUMN public.students.class_id IS '소속 클래스 ID (classes 테이블 참조)';
COMMENT ON COLUMN public.students.name IS '수강생 이름';
COMMENT ON COLUMN public.students.registered_at IS '수강생 등록 시간';

-- ============================================
-- 3. RLS (Row Level Security) 설정
-- ============================================

-- classes 테이블 RLS 활성화
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;

-- 기존 정책 삭제 (있는 경우)
DROP POLICY IF EXISTS "Public Read Access" ON public.classes;
DROP POLICY IF EXISTS "Public Insert Access" ON public.classes;
DROP POLICY IF EXISTS "Public Update Access" ON public.classes;
DROP POLICY IF EXISTS "Public Delete Access" ON public.classes;

-- 정책 1: 조회(SELECT) - 누구나(anon) 가능 (등록 코드로 클래스 찾기 위해)
CREATE POLICY "Public Read Access"
ON public.classes
FOR SELECT
USING (true);

-- 정책 2: 추가(INSERT) - 누구나(anon) 가능 (강사가 클래스 생성)
CREATE POLICY "Public Insert Access"
ON public.classes
FOR INSERT
WITH CHECK (true);

-- 정책 3: 수정(UPDATE) - 누구나(anon) 가능 (강사가 클래스 수정)
CREATE POLICY "Public Update Access"
ON public.classes
FOR UPDATE
USING (true)
WITH CHECK (true);

-- 정책 4: 삭제(DELETE) - 누구나(anon) 가능 (강사가 클래스 삭제)
CREATE POLICY "Public Delete Access"
ON public.classes
FOR DELETE
USING (true);

-- students 테이블 RLS 활성화
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

-- 기존 정책 삭제 (있는 경우)
DROP POLICY IF EXISTS "Public Read Access" ON public.students;
DROP POLICY IF EXISTS "Public Insert Access" ON public.students;
DROP POLICY IF EXISTS "Public Update Access" ON public.students;
DROP POLICY IF EXISTS "Public Delete Access" ON public.students;

-- 정책 1: 조회(SELECT) - 누구나(anon) 가능
CREATE POLICY "Public Read Access"
ON public.students
FOR SELECT
USING (true);

-- 정책 2: 추가(INSERT) - 누구나(anon) 가능 (수강생 등록)
CREATE POLICY "Public Insert Access"
ON public.students
FOR INSERT
WITH CHECK (true);

-- 정책 3: 수정(UPDATE) - 누구나(anon) 가능
CREATE POLICY "Public Update Access"
ON public.students
FOR UPDATE
USING (true)
WITH CHECK (true);

-- 정책 4: 삭제(DELETE) - 누구나(anon) 가능 (강사가 수강생 삭제)
CREATE POLICY "Public Delete Access"
ON public.students
FOR DELETE
USING (true);

-- ============================================
-- 4. 확인 쿼리
-- ============================================

-- classes 테이블 확인
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'classes'
ORDER BY ordinal_position;

-- students 테이블 확인
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'students'
ORDER BY ordinal_position;

-- classes 테이블 RLS 정책 확인
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'classes'
AND schemaname = 'public';

-- students 테이블 RLS 정책 확인
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'students'
AND schemaname = 'public';

-- ============================================
-- 설정 완료 메시지
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '✅ classes 테이블 생성 완료';
    RAISE NOTICE '✅ students 테이블 생성 완료';
    RAISE NOTICE '✅ RLS 정책 설정 완료';
    RAISE NOTICE '✅ 모든 설정이 완료되었습니다!';
END $$;

