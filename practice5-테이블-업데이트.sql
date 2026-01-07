-- ============================================
-- practice_data 테이블에 practice5 지원 추가
-- ============================================
-- 이 SQL은 기존 practice_data 테이블이 있을 때 실행하세요.
-- practice5 타입을 지원하도록 CHECK 제약조건을 수정합니다.
-- ============================================

-- 기존 CHECK 제약조건 삭제
ALTER TABLE public.practice_data 
DROP CONSTRAINT IF EXISTS practice_data_practice_type_check;

-- 새로운 CHECK 제약조건 추가 (practice5 포함)
ALTER TABLE public.practice_data 
ADD CONSTRAINT practice_data_practice_type_check 
CHECK (practice_type IN ('practice1', 'practice2', 'practice5'));

-- 확인
SELECT 
    constraint_name,
    check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'practice_data_practice_type_check';

-- 완료 메시지
DO $$
BEGIN
    RAISE NOTICE '✅ practice_data 테이블이 practice5를 지원하도록 업데이트되었습니다!';
END $$;

