---
layout: default
title: "🔬 MCP Server 3GPP"
nav_order: 3
has_children: true
---

# 🔬 MCP Server 3GPP — AutoRAG MCP 서버

**3GPP/RFC/ETSI 표준 규격 문서**를 LLM이 자율적으로 검색할 수 있도록 하는 **MCP(Model Context Protocol) 서버**입니다. SQLite + FTS5 + sqlite-vec 기반의 하이브리드 검색 엔진을 구축했습니다.

## 🛠️ 기술 스택

| 분야 | 기술 |
|------|------|
| **MCP Server** | Node.js (stdio transport, JSON-RPC 2.0) |
| **데이터베이스** | SQLite 3 + FTS5 + sqlite-vec (하이브리드 검색) |
| **문서 추출** | PyMuPDF · regex (PDF), IETF RFC parser (TXT) |
| **코퍼스** | **207 specs** · **66,109 sections** · **416MB** |

## 📊 핵심 지표

| 항목 | 수치 |
|------|------|
| **총 표준 문서** | 207개 (3GPP TS/TR/RFC/ETSI EN) |
| **섹션 개수** | 66,109개 |
| **전체 크기** | 416MB |
| **검색 타입** | FTS5 키워드 + sqlite-vec 벡터 |
| **배포 형태** | Git LFS (GitHub 공개) |

## 📁 프로젝트 구조

```
mcp-server-3gpp/
├─ server/
│  ├─ index.ts (MCP Server 진입점)
│  ├─ db.ts (SQLite + FTS5 + sqlite-vec 연결)
│  └─ handlers.ts (list_tools, call_tool)
├─ corpus/
│  ├─ 3gpp_specs.db (416MB LFS)
│  └─ extraction/ (PDF→JSONL 변환 스크립트)
├─ tests/
│  └─ integration.test.ts
└─ package.json
```

## 🔍 주요 기능

### 1️⃣ 하이브리드 검색
```
사용자 쿼리
  ├─ FTS5 키워드 검색 (전체 텍스트 검색)
  └─ sqlite-vec 벡터 검색 (의미론적 검색)
      → 두 결과 병합 & 재순위
```

### 2️⃣ AutoRAG 파이프라인
```
ETSI Portal 다운로드
  ↓
PDF/TXT 추출 (PyMuPDF, 정규표현식)
  ↓
섹션 분할 (헤더 기반)
  ↓
SQLite DB + FTS5 인덱싱
  ↓
Embedding 생성 (OpenAI, sqlite-vec)
  ↓
MCP 래핑 (JSON-RPC 2.0)
```

### 3️⃣ Claude/LLM 통합
LLM이 다음과 같이 자동으로 규격서를 검색:
```
Claude: "5G NR의 물리 채널 구조는?"
  ↓ (MCP 호출)
Server: 207개 스펙 중 관련 2-3개 추출
  ↓
Claude: (답변 생성)
```

## 📝 개발 일지 & 문서 (Dev Log & Docs)

### 🔗 [Integration Guide](./mcp-server-integration-guide.html)
AI 에이전트에 MCP 서버를 강제로 사용하도록 하는 아키텍처 및 구현 방법

### 📊 [Corpus Report](./mcp-corpus-report.html)
207개 스펙의 인제스트 현황, 시리즈별 분포, 커버리지를 시각화한 대시보드 (Chart.js)

### 🔧 [Pipeline Architecture](./mcp-autorag-pipeline.html)
데이터 다운로드 → 추출 → DB 빌드 → MCP 래핑까지 전체 파이프라인 시각화

---

## 🗄️ GitHub Repository

📦 **[mcp-server-3gpp](https://github.com/Lee-SiHyeon/mcp-server-3gpp)** — Git LFS로 corpus DB(416MB) 공개 배포

---

## 📚 관련 가이드

- [MCP 서버 통합 가이드](./mcp-server-integration-guide.html) - 아키텍처 깊이 있게 학습
- [YouTube Shorts 자동화](./youtube-shorts-overview.html) - n8n에서 MCP 통합 사례

---

**[← 홈으로 돌아가기](./)** | **[모든 프로젝트 보기](./#projects)**
