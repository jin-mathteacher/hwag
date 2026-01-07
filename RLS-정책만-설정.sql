ALTER TABLE public.practice_data ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Practice Data Public Read Access" ON public.practice_data;
DROP POLICY IF EXISTS "Practice Data Public Insert Access" ON public.practice_data;
DROP POLICY IF EXISTS "Practice Data Public Update Access" ON public.practice_data;
DROP POLICY IF EXISTS "Practice Data Public Delete Access" ON public.practice_data;

CREATE POLICY "Practice Data Public Read Access"
ON public.practice_data FOR SELECT USING (true);

CREATE POLICY "Practice Data Public Insert Access"
ON public.practice_data FOR INSERT WITH CHECK (true);

CREATE POLICY "Practice Data Public Update Access"
ON public.practice_data FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Practice Data Public Delete Access"
ON public.practice_data FOR DELETE USING (true);

