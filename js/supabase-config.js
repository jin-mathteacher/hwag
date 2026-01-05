// ============================================
// Supabase 클라이언트 초기화 설정
// ============================================

// Supabase 연결 정보
const SUPABASE_URL = 'https://jxeyvvstwoktkoaltmie.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_6OlVgtiomTJGkOyhBXTqEQ_nMr3WUGw';

// Supabase 클라이언트 초기화
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// 다른 파일에서 사용할 수 있도록 export
// 브라우저 환경에서는 window 객체에 할당
if (typeof window !== 'undefined') {
    window.supabaseClient = supabase;
}

// ES6 모듈 방식으로도 export (필요한 경우)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { supabase, SUPABASE_URL, SUPABASE_ANON_KEY };
}

// 디버깅용: 연결 확인
console.log('Supabase 클라이언트가 초기화되었습니다.');
console.log('URL:', SUPABASE_URL);

