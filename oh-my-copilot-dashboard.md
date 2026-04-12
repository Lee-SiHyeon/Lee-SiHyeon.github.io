---
layout: default
title: "oh-my-copilot Dashboard"
nav_order: 2
---

# 📊 oh-my-copilot v2.2.0 — Project Dashboard

> Multi-agent orchestration plugin for GitHub Copilot CLI  
> **Repo**: [Lee-SiHyeon/oh-my-copilot](https://github.com/Lee-SiHyeon/oh-my-copilot)

---

## 🔢 프로젝트 핵심 지표

| Metric | Value |
|--------|-------|
| **Version** | 2.2.0 |
| **Agents** | 15 |
| **Skills** | 23 |
| **Scripts** | 8 (bash) + 8 (powershell) |
| **Tests** | 12 files / 69 cases |
| **Script LOC** | ~1,965 (bash) |
| **Agent Prompt LOC** | ~2,093 |
| **Skill Definition LOC** | ~4,201 |
| **Total Files** | 251 |
| **CI Workflows** | 2 (TDD + Quality Gate) |
| **Documentation** | README (KR/EN), CONTRIBUTING, CHANGELOG, ARCHITECTURE, SECURITY |

---

## 🏗️ 아키텍처 개요

```
┌──────────────────────────────────────────────────┐
│                Copilot CLI v1.0.14               │
├──────────────────────────────────────────────────┤
│               hooks.json (3 hooks)               │
│  sessionStart │ preToolUse │ sessionEnd           │
├───────┬───────┴───────┬────┴─────────────────────┤
│       ▼               ▼              ▼           │
│  session-start.sh  pre-tool-use.sh  session-end.sh│
│  (DB bootstrap)    (permission      (proposals    │
│  (state recovery)   cache + guard)   migration    │
│  (experimental)    (danger detect)   Q-Learning)  │
├──────────────────────────────────────────────────┤
│            SQLite (semantic_memory.db)            │
│  ┌──────────┬──────────┬────────────┬──────────┐ │
│  │proposals │agent_q   │permission  │agent_    │ │
│  │          │_table    │_cache      │usage_log │ │
│  └──────────┴──────────┴────────────┴──────────┘ │
├──────────────────────────────────────────────────┤
│              15 Agents + 23 Skills               │
└──────────────────────────────────────────────────┘
```

---

## 🤖 에이전트 팀 구성

### Orchestrators (지휘자)

| Agent | Model | 역할 |
|-------|-------|------|
| 🧠 **meta-orchestrator** | opus-4.6-fast | 병렬 atlas 디스패치, 세션 메모리, 합성 |
| 🗺️ **atlas** | opus-4.6-fast | 마스터 오케스트레이터, 작업 위임 |
| 🪨 **sisyphus** | opus-4.6-fast | 지속적 /fleet 태스크 관리 |
| ⚡ **ultrawork** | opus-4.6-fast | 풀 자율 워크플로우 |

### Specialists (전문가)

| Agent | Model | 역할 |
|-------|-------|------|
| 🔨 **hephaestus** | opus-4.6 | 깊은 구현 전문가 |
| 🔍 **explore** | Haiku 4.5 | 코드베이스 검색 |
| 📚 **librarian** | Sonnet 4.6 | 외부 문서 연구 |
| 🔬 **nlm-researcher** | Sonnet 4.6 | NotebookLM 리서치 |

### Advisors (자문)

| Agent | Model | 역할 |
|-------|-------|------|
| 🔮 **oracle** | opus-4.6 | 읽기전용 디버깅 자문 |
| 🎯 **metis** | opus-4.6 | 사전분석 컨설턴트 |
| 📋 **momus** | opus-4.6 | 플랜 리뷰어 |
| 📐 **prometheus** | Sonnet 4.6 | 전략 플래닝 |

### Utilities (유틸리티)

| Agent | Model | 역할 |
|-------|-------|------|
| 👁️ **multimodal-looker** | Sonnet 4.6 | 이미지/문서 분석 |
| 🏃 **sisyphus-junior** | Haiku 4.5 | 경량 태스크 실행 |
| 💡 **personal-advisor** | Sonnet 4.6 | 개인 에이전트 추천 |

---

## ⚡ 실험적 기능 (v2.2.0)

### Phase 1 — Quick Wins ✅

| Feature | 설명 |
|---------|------|
| **Permission Cache** | MD5 해시 기반 도구 허가 캐시, 7일 TTL |
| **Session Cleanup** | proposals 30일, candidates 90일 GC |
| **Status Line** | 터미널 상태 표시줄 (18ms 실행) |
| **Install UX** | 설치 후 실험적 기능 배너 |

### Phase 2 — Strategic ✅

| Feature | 설명 |
|---------|------|
| **Q-Learning** | 에이전트 성능 학습 (α=0.1, reward -0.5~1.0) |
| **Structured Elicitation** | prometheus/metis 구조화된 인터뷰 |
| **3-Layer Compaction** | INVARIANTS / Core / LOW-PRIORITY 프롬프트 구조 |

### Phase 3 — Architecture ✅

| Feature | 설명 |
|---------|------|
| **Multi-Turn Agents** | write_agent, CONTEXT-CARRY 프로토콜 |
| **Extensions SDK** | @github/copilot-sdk 스캐폴드 |
| **Background Sessions** | ralph-loop/ultrawork 세션 지속성 |

---

## 📈 커밋 타임라인

```
2026-04-01  ████████████████████████████████████  12 commits

Commits (newest first):
────────────────────────────────────────────────
f1b938a  docs   README globalization + English
f638a7c  test   33 new tests (69 total)
800f6fb  fix    opus model restriction removed
d556c5d  feat   agent schema + quality CI
863fbef  docs   CONTRIBUTING, CHANGELOG, ARCHITECTURE, SECURITY
c1671a1  chore  7 orphan dirs removed
da1908e  fix    Background Session Persistence restore
5a46ccc  docs   v2.2.0 README + experimental features
0397fd8  feat   Extensions SDK + doctor/trace skills
a3025e7  feat   structured elicitation + background persistence
6b5093a  feat   3-layer compaction + multi-turn agents
1cb08b4  feat   permission cache, Q-Learning, session cleanup
```

---

## 🧪 테스트 커버리지

| Hook/Script | 테스트 파일 | 케이스 | 커버리지 |
|-------------|------------|--------|---------|
| **init-memory** | test_schema_creation | 6 | 🟢 HIGH |
| **pre-tool-use** | test_danger_patterns | 5 | 🟡 MEDIUM |
| **pre-tool-use** | test_permission_cache | 6 | 🟢 HIGH |
| **pre-tool-use** | test_readme_sync | 5 | 🟡 MEDIUM |
| **session-end** | test_is_shared_path | 5 | 🟡 MEDIUM |
| **session-end** | test_readme_sync | 5 | 🟡 MEDIUM |
| **session-end** | test_proposals_migration | 5 | 🟢 HIGH |
| **session-end** | test_agent_tracking | 5 | 🟢 HIGH |
| **session-end** | test_add_proposal | 5 | 🟡 MEDIUM |
| **session-start** | test_experimental_mode | 5 | 🟢 HIGH |
| **session-start** | test_db_bootstrap | 6 | 🟢 HIGH |
| **consolidate** | test_gc_cleanup | 6 | 🟢 HIGH |

**Total: 12 files, 69 test cases** | CI: Ubuntu + macOS

---

## 🔧 CI/CD 파이프라인

```
Push/PR to main
├── tdd.yml (기존)
│   └── bats-tests
│       ├── ubuntu-latest ✅
│       └── macos-latest  ✅
│
└── quality.yml (신규)
    ├── shellcheck     ── scripts/*.sh 정적 분석
    ├── markdownlint   ── *.md 마크다운 검증
    └── syntax-check   ── bash -n 구문 검사
```

---

## 📁 프로젝트 구조

```
oh-my-copilot/
├── agents/          15 에이전트 (.agent.md)
│   └── SCHEMA.md    frontmatter 스키마 정의
├── skills/          23 스킬 (SKILL.md)
├── scripts/         8 bash + 8 powershell hooks
├── tests/           12 BATS 테스트 파일
├── extensions/      SDK 스캐폴드 (@github/copilot-sdk)
├── docs/            English README
├── .github/         CI + issue/PR 템플릿
├── ARCHITECTURE.md  아키텍처 문서
├── CONTRIBUTING.md  기여 가이드
├── CHANGELOG.md     변경 이력
├── SECURITY.md      보안 정책
└── plugin.json      플러그인 매니페스트
```

---

*Last updated: 2026-04-01 | Generated by Meta-Orchestrator*
