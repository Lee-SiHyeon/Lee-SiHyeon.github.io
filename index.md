# 👋 안녕하세요, 이시현입니다.

이곳은 제가 진행한 AI 자동화 프로젝트들을 정리하는 공간입니다.

---

## 🚀 Project: YouTube Shorts 완전 자동화 파이프라인

**n8n**과 **Google Gemini**를 활용하여 주제 선정부터 영상 제작, 업로드까지 사람의 개입 없이 수행하는 자동화 시스템을 구축했습니다.

### 🛠️ 기술 스택 (Tech Stack)
- **Workflow Engine:** [n8n](https://n8n.io/)
- **AI Core:** Google Gemini 2.5 Flash (Scripting & Logic)
- **Image Gen:** Google Vertex AI Imagen (Visuals)
- **Voice Gen:** Google Cloud TTS (Audio)
- **Video Rendering:** Creatomate API
- **Storage:** Google Drive API (중간 결과물 아카이빙)

### 📊 워크플로우 구조 (Workflow Architecture)

이 프로젝트는 다음과 같은 단계로 실행됩니다:

1.  **Source Fetching**: 커뮤니티(DogDrip)에서 인기 게시글 데이터를 수집합니다.
2.  **Topic Selection (AI Agent)**: Gemini가 수집된 데이터 중 가장 흥미로운 이야기를 선정합니다.
3.  **Parallel Processing (병렬 처리)**:
    *   **Script Branch**: 쇼츠용 대본 작성 -> 대사 추출 -> TTS 오디오 생성
    *   **Visual Branch**: 이미지 프롬프트 최적화(Safety Filter) -> 이미지 생성
4.  **Archiving**: 생성된 대본, 오디오, 이미지를 Google Drive에 자동 백업합니다.
5.  **Video Rendering**: Creatomate API를 통해 자막, 이미지, 오디오를 합성하여 영상을 렌더링합니다.
6.  **Upload**: 완성된 영상을 YouTube에 비공개로 업로드합니다.

### 💡 주요 해결 과제 (Key Challenges & Solutions)

*   **병렬 처리 동기화**: 오디오와 이미지 생성 시간이 다르기 때문에 `Merge Node (Wait for both)`를 사용하여 두 리소스가 모두 준비될 때까지 대기하도록 로직을 구현했습니다.
*   **AI 윤리 필터 우회**: 이미지 생성 시 "Safety Block"이 발생하는 문제를 해결하기 위해, 중간에 `Prompt Engineering Agent`를 두어 프롬프트를 추상적이고 안전한 예술적 묘사로 변환했습니다.
*   **데이터 아카이빙**: 디버깅과 품질 검수를 위해 각 단계의 결과물(txt, mp3, png)을 Google Drive에 타임스탬프와 함께 저장하는 시스템을 구축했습니다.

### 📝 개발 일지 & 문서 (Dev Log & Docs)
*   [🛡️ 주제 선정 고도화 (Safety Filtering)](./topic-selection-enhancement.md): YouTube 정책 준수를 위한 AI 프롬프트 엔지니어링 적용 사례

---

### 📂 Repository
이 프로젝트의 소스 코드는 아래 리포지토리에서 확인할 수 있습니다.
*   [GitHub Repository Link](https://github.com/Lee-SiHyeon/Lee-SiHyeon.github.io)

---
© 2025 Lee SiHyeon. Powered by Jekyll & GitHub Pages.
