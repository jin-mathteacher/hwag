# GitHub 업로드 가이드

## 📋 현재 상황
Git이 사용자 홈 디렉토리에서 초기화되어 올바른 작업 폴더에서 다시 설정해야 합니다.

## 🔧 해결 방법

### 방법 1: 명령줄에서 직접 실행 (권장)

1. **작업 폴더로 이동**
   ```powershell
   cd "C:\Users\user\프로그램 실습"
   ```

2. **기존 .git 폴더 제거 (있다면)**
   ```powershell
   Remove-Item -Path ".git" -Recurse -Force -ErrorAction SilentlyContinue
   ```

3. **Git 저장소 초기화**
   ```powershell
   git init
   ```

4. **원격 저장소 연결**
   ```powershell
   git remote add origin https://github.com/jin-mathteacher/hwag.git
   ```

5. **원격 저장소 정보 가져오기**
   ```powershell
   git fetch origin
   ```

6. **기존 파일 확인 (선택사항)**
   ```powershell
   git pull origin main --allow-unrelated-histories
   ```

7. **모든 파일 추가**
   ```powershell
   git add .
   ```

8. **커밋**
   ```powershell
   git commit -m "프로젝트 파일 업로드"
   ```

9. **GitHub에 푸시**
   ```powershell
   git push -u origin main
   ```

### 방법 2: GitHub Desktop 사용 (더 쉬움)

1. **GitHub Desktop 다운로드**
   - https://desktop.github.com/ 에서 다운로드

2. **저장소 클론**
   - File > Clone Repository
   - URL: `https://github.com/jin-mathteacher/hwag.git`
   - Local Path: `C:\Users\user\프로그램 실습`

3. **파일 복사**
   - 현재 작업한 모든 파일을 클론된 폴더에 복사

4. **변경사항 커밋 및 푸시**
   - GitHub Desktop에서 변경사항 확인
   - Summary에 "프로젝트 파일 업로드" 입력
   - "Commit to main" 클릭
   - "Push origin" 클릭

## ⚠️ 주의사항

1. **인증 필요**: GitHub에 푸시하려면 인증이 필요합니다.
   - Personal Access Token (PAT) 사용 권장
   - 또는 GitHub Desktop 사용

2. **.gitignore 확인**: `.gitignore` 파일이 올바르게 설정되어 있는지 확인하세요.

3. **대용량 파일**: 비디오나 이미지 파일이 크면 GitHub에 업로드되지 않을 수 있습니다.
   - GitHub는 100MB 이상의 파일을 허용하지 않습니다.
   - 필요시 Git LFS 사용

## 🔐 GitHub 인증 설정

### Personal Access Token 생성

1. GitHub 웹사이트 로그인
2. Settings > Developer settings > Personal access tokens > Tokens (classic)
3. "Generate new token" 클릭
4. 권한 선택: `repo` (전체 저장소 권한)
5. 토큰 생성 후 복사 (한 번만 표시됨)

### 토큰으로 푸시

```powershell
git push -u origin main
# Username: jin-mathteacher
# Password: (생성한 토큰 붙여넣기)
```

## 📝 다음 단계

업로드가 완료되면:
1. GitHub 저장소 페이지에서 파일 확인
2. 필요시 추가 수정 후 커밋 및 푸시
3. 변경 이력은 GitHub에서 확인 가능

