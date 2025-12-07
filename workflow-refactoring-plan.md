---
layout: default
title: 워크플로우 개선 및 TTS 에이전트 도입 계획
parent: Home
nav_order: 4
---

# 워크플로우 구조 개선 및 TTS 에이전트 신설 계획

## 1. 현황 및 문제점 (Current Issues)
현재 시스템은 각 에이전트가 독립적 혹은 병렬적으로 작동하여 다음과 같은 정합성 문제가 발생하고 있습니다.

### 1) 스크립트와 이미지의 불일치 (Context Mismatch)
*   **현상:** `Script Agent`(대본 작성)와 `Generate Image Agent`(이미지 생성)가 병렬로 처리되거나, 이미지 생성기가 대본 내용을 참고하지 않고 주제만으로 이미지를 생성함.
*   **결과:** 대본은 "화려한 도시의 밤"을 묘사하는데, 이미지는 단순히 주제와 관련된 엉뚱한 장면이 나올 수 있음.

### 2) TTS 및 자막 처리의 한계
*   **현상:** TTS 처리가 별도의 전문 에이전트 없이 단순 기능으로 수행되거나 스크립트 생성 단계에 묶여 있음.
*   **결과:** 자막(Subtitle) 싱크를 맞추거나, 다양한 보이스 스타일을 적용하는 등 세밀한 오디오 제어가 어려움.

---

## 2. 개선된 워크플로우 설계 (New Workflow Architecture)
**"직렬(Sequential)과 병렬(Parallel)의 조화"**

기존의 단순 병렬 구조를 **단계별 의존성(Dependency)**을 가진 구조로 변경합니다.

### [Step 1] 주제 선정 (Topic Selection)
*   **담당:** Topic Agent
*   **역할:** 트렌드 분석 및 주제 확정.

### [Step 2] 대본 작성 (Script Writing)
*   **담당:** Script Agent
*   **역할:** 주제를 바탕으로 **완성된 대본** 작성.
*   **중요:** 이 단계가 **완료되어야만** 다음 단계(이미지/TTS)가 시작됨.

### [Step 3] 병렬 처리 (Parallel Processing)
대본(Context)이 확보된 상태에서 시각(Visual)과 청각(Audio) 요소를 동시에 생성합니다.

#### **Track A: TTS & 자막 에이전트 (New!)**
*   **입력:** [Step 2]에서 완성된 대본.
*   **역할:**
    1.  **Audio Generation:** 대본을 음성으로 변환 (감정/톤 조절).
    2.  **Subtitle Generation:** 오디오 길이에 맞춘 자막(SRT/JSON) 데이터 생성.
*   **출력:** 오디오 파일(.mp3), 자막 파일.

#### **Track B: 이미지 생성 에이전트 (Image Gen Agent)**
*   **입력:** [Step 2]에서 완성된 대본.
*   **역할:**
    1.  **Prompt Engineering:** 대본의 문단/장면별로 적합한 이미지 프롬프트 추출.
    2.  **Generation:** 대본의 내용을 반영한 이미지 생성.
*   **출력:** 이미지 파일들(.png).

### [Step 4] 최종 렌더링 (Final Rendering)
*   **입력:** 오디오, 자막, 이미지.
*   **역할:** 생성된 자산들을 합쳐 최종 영상으로 변환.

---

## 3. 개발 로드맵 (Action Plan)

### Phase 1: 워크플로우 의존성 재설정
*   n8n 노드 연결 순서 변경: `Topic` -> `Script` -> `Merge Node` -> `Split to Image/TTS`.
*   이미지 생성 프롬프트가 스크립트 내용을 참조하도록 변수 매핑 수정.

### Phase 2: TTS 전용 에이전트(Node) 구축
*   단순 TTS 노드가 아닌, **Agent** 형태로 격상.
*   기능 추가: 긴 텍스트 처리, 자막 타임스탬프 계산 로직 추가.

### Phase 3: 자막(Subtitle) 파이프라인 구축
*   TTS 생성 시 글자 수/속도를 기반으로 자막 데이터를 구조화(JSON)하여 렌더링 엔진에 전달하는 로직 구현.
