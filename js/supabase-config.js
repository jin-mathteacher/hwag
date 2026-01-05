// js/supabase-config.js

// 1. Supabase 라이브러리가 로드되었는지 확인
if (typeof window.supabase === 'undefined') {
    console.error('HTML 헤드에 Supabase CDN 스크립트가 없습니다!');
} else {
    // 2. 이미 연결된 클라이언트가 없을 때만 새로 생성 (중복 에러 방지!)
    if (!window.supabaseClient) {
        const SUPABASE_URL = 'https://jxeyvvstwoktkoaltmie.supabase.co';
        // 올바른 anon public key (JWT 형식)
        const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp4ZXl2dnN0d29rdGtvYWx0bWllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MDQ5MTAsImV4cCI6MjA4MzE4MDkxMH0.iQOBtE9XH7EhZt2vC1wM_CrgD06oxCgHpus0LO8bc-I'; 
        
        // window 객체에 저장해서 다른 파일에서(upload.js 등) 갖다 쓸 수 있게 함
        window.supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        console.log('✅ Supabase 연결 성공! (중복 방지 적용됨)');
    }
}
