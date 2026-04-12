# 📐 포트폴리오 구조 재설계 분석

## 현재 상태 진단

### ✅ 잘된 점
- 페이지 콘텐츠: 각 문서가 명확한 목적과 심화도 진행
- 프로젝트 중심: YouTube Shorts, mcp-server-3gpp 2개 핵심 프로젝트 명확
- 기술 깊이: 입문~고급 콘텐츠 균형

### ❌ 문제점
1. **계층 혼재**: 
   - index.md: 2개 핵심 프로젝트 소개 (허브 역할)
   - YouTube Shorts 관련 5개 문서: 개선안/분석/가이드가 분산
   - mcp-server-3gpp: 별도 가이드 1개만 (프로젝트 2 콘텐츠 부족)
   
2. **카테고리 불명확**:
   - "주제 선정 고도화" vs "워크플로우 개선" vs "에이전트 고도화" 관계 애매
   - n8n 가이드가 YouTube Shorts와의 연결고리 불명확

3. **내부 링크 거의 없음**:
   - 관련 문서 간 크로스 링크 미존재
   - 읽는 사람이 다음 읽을 문서를 못 찾음

4. **정보 아키텍처 미흡**:
   - 접근 경로: 모두 index.md → 각 페이지 (직렬)
   - 주제별/난이도별 탐색 불가능

## 제안 구조

### 방안 1: 프로젝트 중심 재구성 (권장)

```
📦 AI Automation Portfolio
│
├─ 🏠 Home (index.md - 간소화)
│   └─ "프로젝트" 버튼 → 프로젝트 목록
│
├─ 🎬 Project 1: YouTube Shorts 완전 자동화
│   ├─ 📝 Project Overview (youtube-shorts-overview.md - NEW)
│   ├─ 🛡️ 주제 선정 고도화 (topic-selection-enhancement.md)
│   ├─ 🔄 워크플로우 개선 (workflow-refactoring-plan.md)
│   ├─ 🤖 에이전트 시스템 고도화 (agent-enhancement-proposal.md)
│   └─ 📊 Reference: OpenCoreAI 분석 (youtube-shorts-automation-reference-analysis.md)
│
├─ 🔬 Project 2: MCP Server 3GPP
│   ├─ 📝 Project Overview (mcp-server-overview.md - NEW)
│   ├─ 🔗 Integration Guide (mcp-server-integration-guide.md)
│   ├─ 📊 Corpus Report (mcp-corpus-report.html)
│   └─ 🔧 Pipeline Architecture (mcp-autorag-pipeline.html)
│
├─ 🛠️ Tools & Guides
│   ├─ 📋 n8n GitHub Webhook 설정 (n8n-github-webhook-setup.md)
│   ├─ 📊 Copilot Agent vs Plan 분석 (copilot-mode-analysis.md)
│   └─ 📊 oh-my-copilot 대시보드 (oh-my-copilot-dashboard.md)
│
└─ 📚 Resources (NEW)
    ├─ 기술 스택
    ├─ About / Skills
    └─ 연락처
```

### 새로운 _config.yml nav 구조

```yaml
nav:
  - title: Home
    url: /
    
  - title: "🎬 YouTube Shorts Automation"
    children:
      - title: Project Overview
        url: /youtube-shorts-overview.html
      - title: "🛡️ 주제 선정 고도화"
        url: /topic-selection-enhancement.html
      - title: "🔄 워크플로우 개선"
        url: /workflow-refactoring-plan.html
      - title: "🤖 에이전트 고도화"
        url: /agent-enhancement-proposal.html
      - title: "📊 OpenCoreAI 참고 분석"
        url: /youtube-shorts-automation-reference-analysis.html
        
  - title: "🔬 MCP Server 3GPP"
    children:
      - title: Project Overview
        url: /mcp-server-overview.html
      - title: "🔗 Integration Guide"
        url: /mcp-server-integration-guide.html
      - title: "📊 Corpus Report"
        url: /mcp-corpus-report.html
      - title: "🔧 Pipeline Architecture"
        url: /mcp-autorag-pipeline.html
        
  - title: "🛠️ Tools & Guides"
    children:
      - title: "📋 n8n GitHub Webhook"
        url: /n8n-github-webhook-setup.html
      - title: "📊 Copilot 모드 분석"
        url: /copilot-mode-analysis.html
      - title: "📊 oh-my-copilot 대시보드"
        url: /oh-my-copilot-dashboard.html
        
  - title: "📚 About"
    url: /about.html
```

## 구현 계획

### Phase 1: 네비게이션 구조 재정의 (우선순위: 높음)
- [ ] _config.yml 수정 (새 nav 구조)
- [ ] index.md 간소화 (프로젝트 링크 강조)

### Phase 2: 프로젝트 개요 문서 분리 (우선순위: 중)
- [ ] youtube-shorts-overview.md 생성 (index.md Project 1 섹션 분리)
- [ ] mcp-server-overview.md 생성 (index.md Project 2 섹션 분리)
- [ ] about.md 생성 (기술 스택 / 연락처)

### Phase 3: 내부 링크 추가 (우선순위: 중)
- [ ] 각 페이지에 "다음 읽을 문서" 섹션 추가
- [ ] 프로젝트 페이지 간 탐색 링크 추가

## 개선 효과

✅ **사용자 여정 명확화**
- 프로젝트 진입 → 개요 → 세부 문서 진행
- 명확한 읽기 순서 제시

✅ **카테고리 기반 탐색**
- 좌측 네비게이션: 프로젝트 기반 그룹화
- 입문 사용자: 프로젝트 → 개요부터 시작
- 기술자: 특정 기술 문서 직접 접근

✅ **정보 계층 구조**
- 각 프로젝트 아래 5-6개 문서 체계화
- Tools & Guides: 독립형 콘텐츠

✅ **접근성 향상**
- 모바일 친화적 (계층 구조 네비)
- 데스크톱에서도 전체 맥락 파악 용이
