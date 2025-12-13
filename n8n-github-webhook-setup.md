# n8n GitHub Webhook to CSV 자동화 설정 가이드

> GitHub 커밋을 자동으로 로컬 CSV 파일에 기록하는 n8n 워크플로우 구축 과정

## 📋 개요

이 가이드는 GitHub 레포지토리의 커밋을 실시간으로 모니터링하고, 로컬 CSV 파일에 자동으로 기록하는 n8n 워크플로우를 설정하는 방법을 다룹니다.

### 아키텍처

```
GitHub Push Event
       ↓
   Webhook POST
       ↓
  Cloudflare Tunnel (터널링)
       ↓
  localhost:5678 (n8n)
       ↓
  GitHub Commit Logger v4 Workflow
       ↓
  github_commits.csv (로컬 파일)
```

## 🛠 사전 요구사항

- Node.js 18+
- Windows 10/11
- GitHub 계정 및 레포지토리

## 📦 1. n8n 설치 및 실행

```powershell
# n8n 전역 설치
npm install -g n8n

# n8n 시작
n8n start
```

n8n UI: http://localhost:5678

## 📁 2. 프로젝트 구조

```
tcua/
├── .env                    # 환경변수
├── package.json            # 프로젝트 설정
├── github_commits.csv      # 커밋 로그 CSV
├── workflows/
│   └── GitHub_Commit_Logger_v4.json
└── README.md
```

## 🔧 3. 워크플로우 생성

### 워크플로우 노드 구성

| 순서 | 노드 | 역할 |
|------|------|------|
| 1 | **GitHub Webhook** | POST 요청 수신 (`/webhook/gh-commits`) |
| 2 | **Parse Commits** | GitHub payload에서 커밋 정보 추출 |
| 3 | **Filter Valid** | 유효한 커밋만 필터링 |
| 4 | **Format CSV** | CSV 행 포맷 생성 |
| 5 | **Append to CSV** | Execute Command로 파일에 추가 |
| 6 | **Respond** | Webhook 응답 반환 |

### 워크플로우 JSON

```json
{
  "name": "GitHub Commit Logger v4",
  "nodes": [
    {
      "name": "GitHub Webhook",
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "httpMethod": "POST",
        "path": "gh-commits",
        "responseMode": "responseNode"
      }
    },
    {
      "name": "Parse Commits",
      "type": "n8n-nodes-base.code",
      "parameters": {
        "jsCode": "const payload = $input.first().json.body || $input.first().json;\n\nif (!payload.commits || payload.commits.length === 0) {\n  return [{ json: { skip: true, message: 'No commits' } }];\n}\n\nconst commits = payload.commits.map(commit => {\n  return {\n    timestamp: new Date().toISOString(),\n    repo: payload.repository?.full_name || 'unknown',\n    branch: (payload.ref || '').replace('refs/heads/', ''),\n    commit_sha: (commit.id || '').substring(0, 7),\n    commit_message: (commit.message || '').replace(/[\\r\\n,\"]+/g, ' ').substring(0, 100),\n    author: commit.author?.name || 'unknown',\n    author_email: commit.author?.email || '',\n    files_added: (commit.added || []).length,\n    files_modified: (commit.modified || []).length,\n    files_removed: (commit.removed || []).length,\n    url: commit.url || ''\n  };\n});\n\nreturn commits.map(c => ({ json: c }));"
      }
    },
    {
      "name": "Append to CSV",
      "type": "n8n-nodes-base.executeCommand",
      "parameters": {
        "command": "=echo {{ $json.csvLine }} >> C:\\Users\\User\\Desktop\\tcua\\github_commits.csv"
      }
    }
  ]
}
```

### 워크플로우 Import

```powershell
npx n8n import:workflow --input="workflows/GitHub_Commit_Logger_v4.json"
```

## 🌐 4. Cloudflare Tunnel 설정

로컬 n8n 서버를 외부에서 접근 가능하게 터널링:

```powershell
# Cloudflare Tunnel 설치
winget install Cloudflare.cloudflared

# 터널 시작 (HTTP2 프로토콜 권장)
cloudflared tunnel --url http://localhost:5678 --protocol http2
```

생성된 URL 예시:
```
https://unfortunately-conviction-seeking-easier.trycloudflare.com
```

> ⚠️ Quick Tunnel URL은 매번 변경됩니다. 프로덕션에서는 Named Tunnel 사용을 권장합니다.

## 🔗 5. GitHub Webhook 설정

1. GitHub 레포 → **Settings** → **Webhooks** → **Add webhook**

2. 설정 값:

| 항목 | 값 |
|------|-----|
| Payload URL | `https://{터널URL}/webhook/gh-commits` |
| Content type | `application/json` |
| Secret | (비워두기) |
| Events | `Just the push event` |
| Active | ✅ |

## ✅ 6. 테스트

### 로컬 테스트 (Test URL)

n8n에서 워크플로우 Test 모드 활성화 후:

```powershell
curl.exe -X POST "http://localhost:5678/webhook-test/gh-commits" `
  -H "Content-Type: application/json" `
  -d '{"ref":"refs/heads/main","repository":{"full_name":"test/repo"},"commits":[{"id":"abc123","message":"test commit","author":{"name":"tester","email":"t@t.com"},"url":"http://github.com","added":["file.txt"],"modified":[],"removed":[]}]}'
```

### Production 테스트

1. n8n에서 워크플로우 **Active** 토글 켜기
2. 레포에 아무 파일이나 커밋 & push
3. CSV 파일 확인:

```powershell
Get-Content "C:\Users\User\Desktop\tcua\github_commits.csv"
```

## 📊 7. CSV 출력 예시

```csv
timestamp,repo,branch,commit_sha,commit_message,author,author_email,files_added,files_modified,files_removed,url
2025-12-13T04:18:23.058Z,Lee-SiHyeon/Lee-SiHyeon.github.io,main,abc1234,feat: Add new feature,Lee-SiHyeon,test@example.com,1,2,0,https://github.com/...
```

## 🔍 8. 트러블슈팅

### Webhook 404 에러
- 워크플로우가 **Active** 상태인지 확인
- Test URL (`/webhook-test/`) vs Production URL (`/webhook/`) 구분

### CSV에 데이터 안 들어감
- n8n Code 노드에서 `fs` 모듈은 기본적으로 비활성화
- `executeCommand` 노드로 `echo >> file` 방식 사용

### Cloudflare Tunnel 연결 끊김
- `--protocol http2` 옵션 추가
- 네트워크 상태 확인

## 📚 참고 자료

- [n8n 공식 문서](https://docs.n8n.io/)
- [Cloudflare Tunnel 문서](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [GitHub Webhooks 문서](https://docs.github.com/en/webhooks)

---

*작성일: 2025-12-13*
