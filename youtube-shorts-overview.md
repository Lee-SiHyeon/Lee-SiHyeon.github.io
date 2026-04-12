---
layout: default
title: "🎬 YouTube Shorts Automation"
nav_order: 2
has_children: true
---

# 🎬 YouTube Shorts 완전 자동화 파이프라인

**n8n**과 **Google Gemini**를 활용하여 주제 선정부터 영상 제작, 업로드까지 사람의 개입 없이 수행하는 자동화 시스템을 구축했습니다.

## 🛠️ 기술 스택 (Tech Stack)

| 분야 | 기술 |
|------|------|
| **Workflow Engine** | [n8n](https://n8n.io/) |
| **AI 추론** | Google Gemini 2.5 Flash (스크립팅 & 로직) |
| **이미지 생성** | Google Vertex AI Imagen (비주얼) |
| **음성 생성** | Google Cloud TTS (오디오) |
| **영상 렌더링** | Creatomate API (합성) |
| **데이터 저장** | Google Drive API (아카이빙) |

## 📊 워크플로우 구조 (Workflow Architecture)

이 프로젝트는 다음과 같은 단계로 실행됩니다:

```
1. Source Fetching
   └─ 커뮤니티(DogDrip)에서 인기 게시글 수집

2. Topic Selection (AI Agent)
   └─ Gemini가 수집 데이터 중 흥미로운 이야기 선정

3. Parallel Processing (병렬 처리)
   ├─ Script Branch: 대본 → 대사 추출 → TTS 오디오
   └─ Visual Branch: 이미지 프롬프트 최적화 → 이미지 생성

4. Archiving
   └─ 대본, 오디오, 이미지를 Google Drive에 백업

5. Video Rendering
   └─ Creatomate API로 자막+이미지+오디오 합성

6. Upload
   └─ YouTube에 비공개 업로드
```

## 💡 핵심 해결 과제 (Key Challenges & Solutions)

### 1️⃣ 병렬 처리 동기화
**문제**: 오디오와 이미지 생성 시간이 다름
**해결**: `Merge Node (Wait for both)` 사용하여 두 리소스가 모두 준비될 때까지 대기

### 2️⃣ AI 윤리 필터 우회
**문제**: 이미지 생성 시 "Safety Block" 발생
**해결**: `Prompt Engineering Agent` 도입하여 프롬프트를 추상적이고 안전한 예술적 묘사로 변환

### 3️⃣ 데이터 아카이빙
**문제**: 디버깅 및 품질 검수 필요
**해결**: 각 단계 결과물(txt, mp3, png)을 Google Drive에 타임스탐프와 함께 저장

## 📝 개발 일지 & 문서 (Dev Log & Docs)

이 프로젝트의 세부 내용을 다음 페이지에서 확인할 수 있습니다:

### 🛡️ [주제 선정 고도화](./topic-selection-enhancement.html)
YouTube 정책 준수를 위한 AI 프롬프트 엔지니어링 적용 사례

### 🔄 [워크플로우 개선 및 TTS 에이전트 도입 계획](./workflow-refactoring-plan.html)
현재 워크플로우의 컨텍스트 미스매치 문제 해결 및 구조 개선

### 🤖 [에이전트 시스템 고도화 제안](./agent-enhancement-proposal.html)
현재 LLM 추론 엔진 → 행동 가능한 AI 에이전트로의 진화 로드맵

### 📊 [OpenCoreAI 참고 분석](./youtube-shorts-automation-reference-analysis.html)
OpenCoreAI의 완전 자동화 YouTube Shorts 워크플로우 심층 분석 (2,676줄)

---

## 📚 관련 가이드

- [n8n GitHub Webhook to CSV 자동화](./n8n-github-webhook-setup.html) - n8n 워크플로우 기초 학습

---

**[← 홈으로 돌아가기](./)** | **[모든 프로젝트 보기](./#projects)**
