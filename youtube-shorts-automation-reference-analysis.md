# YouTube Shorts Automation Workflow - Complete Reference Analysis

> **분석 대상**: `Shared_Youtube Shorts Automation_opencoreai.json`  
> **제작**: OpenCoreAI (https://opencoreai.org)  
> **분석 일자**: 2024년  
> **총 라인 수**: 2,676 lines  

---

## 📋 목차

1. [개요 (Overview)](#1-개요-overview)
2. [시스템 요구사항](#2-시스템-요구사항)
3. [워크플로우 아키텍처](#3-워크플로우-아키텍처)
4. [노드 상세 분석](#4-노드-상세-분석)
5. [데이터 흐름 분석](#5-데이터-흐름-분석)
6. [핵심 코드 노드 분석](#6-핵심-코드-노드-분석)
7. [API 통합 분석](#7-api-통합-분석)
8. [FFmpeg 비디오 처리](#8-ffmpeg-비디오-처리)
9. [연결 맵 (Connections Map)](#9-연결-맵-connections-map)
10. [Gemini Edition과의 비교](#10-gemini-edition과의-비교)

---

## 1. 개요 (Overview)

### 1.1 워크플로우 목적
이 워크플로우는 **완전 자동화된 YouTube Shorts 제작 파이프라인**입니다. 단일 주제 입력으로부터:
- 6문장 내레이션 스크립트 생성
- 각 문장별 이미지/비디오 프롬프트 생성
- AI 이미지 생성 (Freepik Imagen3)
- AI 비디오 생성 (Freepik Kling)
- TTS 음성 생성 (OpenAI TTS)
- 자막 생성 (OpenAI Whisper)
- FFmpeg 비디오 합성
- YouTube 업로드

까지 전 과정을 자동으로 처리합니다.

### 1.2 사용된 기술 스택

| 카테고리 | 기술/서비스 |
|---------|-----------|
| **LLM** | OpenAI GPT-4.1-nano |
| **이미지 생성** | Freepik Imagen3 API |
| **비디오 생성** | Freepik Kling Standard API |
| **음성 합성** | OpenAI TTS (Text-to-Speech) |
| **음성 인식** | OpenAI Whisper |
| **비디오 처리** | FFmpeg (로컬 설치 필수) |
| **저장소** | Google Drive |
| **데이터베이스** | Google Sheets |
| **배포** | YouTube Data API v3 |
| **오케스트레이션** | n8n (로컬 환경 필수) |

### 1.3 6개 메인 섹션 (Sticky Notes 기반)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  Section 1: Narration Prompts (주황색)                                    │
│  - 주제 기반 6문장 내레이션 스크립트 생성                                      │
├─────────────────────────────────────────────────────────────────────────┤
│  Section 2: Generate Images (초록색)                                      │
│  - Freepik Imagen3로 각 문장별 이미지 생성                                   │
├─────────────────────────────────────────────────────────────────────────┤
│  Section 3: Generate Videos (파란색)                                      │
│  - Freepik Kling으로 이미지 → 5초 비디오 변환                                │
├─────────────────────────────────────────────────────────────────────────┤
│  Section 4: Generate Sound (보라색)                                       │
│  - OpenAI TTS로 음성 생성 + 랜덤 BGM 선택                                   │
├─────────────────────────────────────────────────────────────────────────┤
│  Section 5: Video Rendering (빨간색)                                      │
│  - FFmpeg로 최종 비디오 합성 (Ken Burns + 자막)                              │
├─────────────────────────────────────────────────────────────────────────┤
│  Section 6: YouTube Uploader (노란색)                                     │
│  - 메타데이터 생성 + YouTube 업로드                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 시스템 요구사항

### 2.1 필수 설치 항목
```
✅ n8n (로컬 환경 - 클라우드 n8n 지원 안됨)
✅ FFmpeg (비디오 처리용)
✅ 한글 글꼴 (자막용 - 예: NanumGothic)
```

### 2.2 필요한 API 인증
```
1. OpenAI API Key (GPT-4.1-nano, TTS, Whisper용)
2. Freepik API Key (x-freepik-api-key)
3. Google OAuth2 (Drive, Sheets, YouTube)
```

### 2.3 Google Sheets 템플릿
- 샘플 시트: https://docs.google.com/spreadsheets/d/11jsblXeg-i87l0Pcs319vMUdKdOjdC3bzl6rfRCRqe4

---

## 3. 워크플로우 아키텍처

### 3.1 전체 흐름도

```
                         ┌─────────────┐
                         │   Webhook   │
                         │   Trigger   │
                         └──────┬──────┘
                                │
                         ┌──────▼──────┐
                         │     If1     │  ← 처리 유형 분기
                         └──────┬──────┘
                    ┌───────────┴───────────┐
                    │                       │
           ┌────────▼────────┐    ┌─────────▼─────────┐
           │  Prepare data2  │    │   Prepare data3   │
           │ (기존 스크립트) │    │   (새 스크립트)   │
           └────────┬────────┘    └─────────┬─────────┘
                    │                       │
           ┌────────▼────────────────────────▼────────┐
           │          Narration Script Generate1      │
           │           (GPT-4.1-nano Agent)           │
           └─────────────────────┬────────────────────┘
                                 │
           ┌─────────────────────▼────────────────────┐
           │              Split Out                   │
           │         (6문장으로 분리)                  │
           └─────────────────────┬────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │  Generate Image Prompts2 │
                    │     (문장별 이미지 프롬프트)│
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │   Freepik Request Img    │
                    │     (Imagen3 API)        │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │     Upload file          │
                    │   (Google Drive)         │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │        Switch1          │
                    │  (비디오 생성 / 이미지만) │
                    └───────┬───────┬─────────┘
                            │       │
               ┌────────────▼───┐   │
               │Generate Video  │   │
               │   Prompts3     │   │
               └────────┬───────┘   │
                        │           │
               ┌────────▼───────┐   │
               │Request Freepik │   │
               │    Video       │   │
               └────────┬───────┘   │
                        │           │
               ┌────────▼───────────▼─────────┐
               │         Wait All             │
               │    (모든 비디오 완료 대기)     │
               └──────────────┬───────────────┘
                              │
               ┌──────────────▼───────────────┐
               │        Final Merge1          │
               │  (5개 입력 병합)              │
               │  ├─ 비디오/이미지             │
               │  ├─ 오디오                    │
               │  ├─ 자막 데이터               │
               │  ├─ BGM                       │
               │  └─ 로고                       │
               └──────────────┬───────────────┘
                              │
               ┌──────────────▼───────────────┐
               │       Data Aggregator        │
               │   (500+ lines Code Node)     │
               └──────────────┬───────────────┘
                              │
               ┌──────────────▼───────────────┐
               │   Simple Video Processor1    │
               │   (600+ lines FFmpeg Script) │
               └──────────────┬───────────────┘
                              │
               ┌──────────────▼───────────────┐
               │  File-based Script Executor1 │
               │      (FFmpeg 실행)            │
               └──────────────┬───────────────┘
                              │
               ┌──────────────▼───────────────┐
               │     Metadata Generate1       │
               │   (YouTube 메타데이터)        │
               └──────────────┬───────────────┘
                              │
               ┌──────────────▼───────────────┐
               │      Upload a video          │
               │       (YouTube API)          │
               └──────────────────────────────┘
```

---

## 4. 노드 상세 분석

### 4.1 트리거 노드

#### Webhook
```json
{
  "type": "n8n-nodes-base.webhook",
  "path": "2e3b6e06-c3a2-49e1-8c35-3d40b6f33e6a",
  "httpMethod": "POST",
  "responseMode": "lastNode"
}
```
- **역할**: 외부 요청으로 워크플로우 시작
- **응답 모드**: 마지막 노드의 결과를 응답으로 반환

### 4.2 조건 분기 노드

#### If1 (조건 분기)
```javascript
// 조건: $json.body.script가 비어있는지 확인
conditions: [
  {
    leftValue: "={{ $json.body.script }}",
    rightValue: "",
    operator: "string:notEquals"
  }
]
```
- **True**: 기존 스크립트 사용 → `Prepare data2`
- **False**: 새 스크립트 생성 → `Prepare data3`

### 4.3 데이터 준비 노드

#### Prepare data2 (기존 스크립트 사용)
```javascript
return {
  keyword: $('Webhook').item.json.body.keyword,
  script: $('Webhook').item.json.body.script,
  context: $('Webhook').item.json.body.context ?? "",
  video_count: $('Webhook').item.json.body.video_count ?? 5,
  job_id: $('Webhook').item.json.body.job_id
};
```

#### Prepare data3 (새 스크립트 생성)
```javascript
return {
  keyword: $('Webhook').item.json.body.keyword,
  context: $('Webhook').item.json.body.context ?? "",
  video_count: $('Webhook').item.json.body.video_count ?? 5,
  job_id: $('Webhook').item.json.body.job_id
};
```

**핵심 파라미터:**
- `keyword`: 콘텐츠 주제
- `script`: 기존 스크립트 (옵션)
- `context`: 추가 컨텍스트 정보
- `video_count`: 생성할 비디오 클립 수 (기본값: 5)
- `job_id`: 작업 식별자

### 4.4 LLM Agent 노드

#### Narration Script Generate1 (내레이션 생성)
```yaml
Type: @n8n/n8n-nodes-langchain.agent
Model: OpenAI GPT-4.1-nano (gpt-4.1-nano)
Temperature: 0.7
Max Tokens: 16383

System Prompt (요약):
- 한국어 유튜브 쇼츠 전문 내레이터
- 주제를 6개의 문장으로 구성
- 각 문장은 자막 표시에 적합한 짧은 길이
- 흥미 유발 → 정보 전달 → 결론 구조

Output Parser: "sentences" 배열 형태로 출력
```

**출력 형식:**
```json
{
  "output": {
    "sentences": [
      "첫 번째 문장...",
      "두 번째 문장...",
      // ... 6개 문장
    ]
  }
}
```

#### Generate Image Prompts2 (이미지 프롬프트 생성)
```yaml
Type: @n8n/n8n-nodes-langchain.agent
Model: OpenAI GPT-4.1-nano

System Prompt (핵심):
- 문장 내용을 시각화하는 이미지 프롬프트 생성
- Freepik Imagen3에 최적화
- 스타일: cinematic, hyper-realistic, neon, 4K
- 인물 묘사: 성별, 나이, 인종, 표정, 의상 상세 기술
- 구도: 3분할법, 관객 시선 방향 고려

Output: image_prompt (300자 내외)
```

#### Generate Video Prompts3 (비디오 프롬프트 생성)
```yaml
Type: @n8n/n8n-nodes-langchain.agent
Model: OpenAI GPT-4.1-nano

System Prompt (핵심):
- 이미지 프롬프트를 바탕으로 5초 비디오 프롬프트 생성
- 빠른 속도감과 공간감 있는 움직임
- 극적인 동작과 감정 표출

스타일 키워드:
- realistic, neon HUD, Hyper-realistic
- Glowing, Translucent, Crystalline
- electromagnetic, radiant glints

카메라 워크:
- Fast panning handheld cam
- dynamic low-angle dolly shot
- slight motion blur, cinematic lighting
- Crane shot ascending
- Over-the-shoulder tracking shot
- Dolly zoom, rack focus, tilt, pan

Output: video_prompt
```

#### Metadata Generate1 (YouTube 메타데이터 생성)
```yaml
Type: @n8n/n8n-nodes-langchain.agent
Model: OpenAI GPT-4.1-nano

역할: YouTube 업로드용 메타데이터 생성
- 제목 (60자 이하, 이모지 포함)
- 설명 (SEO 최적화)
- 태그 (관련 키워드)
```

### 4.5 미디어 생성 노드

#### Freepik Request Img (이미지 생성 요청)
```json
{
  "url": "https://api.freepik.com/v1/ai/text-to-image/imagen-3",
  "method": "POST",
  "headers": {
    "x-freepik-api-key": "{{API_KEY}}"
  },
  "body": {
    "prompt": "={{ $json.output.image_prompt }}",
    "negative_prompt": "photorealistic imperfections like skin blemishes...",
    "guidance_scale": 25,
    "image_size": "portrait_16_9",
    "num_images": 1,
    "seed": 1,
    "style": "photo"
  }
}
```

**Negative Prompt (전체):**
```
photorealistic imperfections like skin blemishes, moles, stubble, 
or realistic facial features, image imperfections, scars, 
age spots, overly saturated colors, oversaturated tones, 
poor anatomy, mangled hands, extra fingers, cloned face, 
mutated, poorly drawn face, mutation, deformed, ugly, blurry, 
bad anatomy, worst quality, low quality, extra limbs, 
extra arms, extra legs, malformed limbs, fused fingers, 
too many fingers, long neck, username, watermark, signature
```

#### Request Freepik Video (비디오 생성 요청)
```json
{
  "url": "https://api.freepik.com/v1/ai/image-to-video/kling-std",
  "method": "POST",
  "body": {
    "image": "={{ \"https://drive.google.com/uc?export=download&id=\" + $('Upload file').all()[$itemIndex].json.id }}",
    "prompt": "={{ $json.output.video_prompt }}",
    "negative_prompt": "static pose, calm scene, emotionless, low energy, cartoon style, pastel tones, blurry or soft edges, flat lighting",
    "duration": "5",
    "cfg_scale": "1"
  }
}
```

### 4.6 음성/자막 노드

#### Generate audio (TTS 생성)
```json
{
  "type": "n8n-nodes-base.httpRequest",
  "url": "https://api.openai.com/v1/audio/speech",
  "body": {
    "model": "gpt-4o-mini-tts",
    "voice": "coral",
    "input": "={{ $json.script }}",
    "instructions": "Speak in Korean. Speak in a calm, warm, and professional tone..."
  }
}
```

#### Generate Subtitles (Whisper 자막 생성)
```json
{
  "type": "n8n-nodes-base.httpRequest",
  "url": "https://api.openai.com/v1/audio/transcriptions",
  "body": {
    "file": "={{ $binary.data }}",
    "model": "whisper-1",
    "response_format": "verbose_json",
    "language": "ko",
    "timestamp_granularities[]": "word"
  }
}
```

---

## 5. 데이터 흐름 분석

### 5.1 입력 데이터 구조 (Webhook)
```json
{
  "body": {
    "keyword": "AI 기술의 미래",
    "script": "",  // 빈 문자열이면 새로 생성
    "context": "기술 트렌드 채널용",
    "video_count": 5,
    "job_id": "job_12345"
  }
}
```

### 5.2 내레이션 출력 구조
```json
{
  "output": {
    "sentences": [
      "AI가 우리 삶을 어떻게 바꾸고 있을까요?",
      "2024년, 인공지능은 이미 일상 깊숙이 들어왔습니다.",
      "의료, 금융, 교육 분야에서 혁신이 일어나고 있죠.",
      "하지만 윤리적 문제도 함께 고민해야 합니다.",
      "전문가들은 인간과 AI의 협업을 강조합니다.",
      "지금 바로 준비하지 않으면 뒤처질 수 있습니다!"
    ]
  }
}
```

### 5.3 이미지 프롬프트 출력 구조
```json
{
  "output": {
    "image_prompt": "A young Asian woman in her 30s, wearing a sleek navy blue blazer, standing in a modern tech office with holographic AI interfaces floating around her. Cinematic lighting with neon blue accents, 4K ultra-realistic photography style, shot from a low angle to emphasize confidence..."
  }
}
```

### 5.4 비디오 프롬프트 출력 구조
```json
{
  "output": {
    "video_prompt": "In a tech office, whip pan across a neon HUD and pulsing holographic tokens → snap into a rapid zoom-in on a stressed developer furiously typing → execute a quick snap-tilt as neon reflections flash across their face..."
  }
}
```

### 5.5 Final Merge 입력 구조 (5개 입력)
```
Input 0: 비디오/이미지 파일 (Google Drive 링크)
Input 1: 오디오 파일 (TTS 결과)
Input 2: 자막 데이터 (Whisper 처리 결과)
Input 3: BGM 파일 (랜덤 선택)
Input 4: 로고 파일
```

---

## 6. 핵심 코드 노드 분석

### 6.1 whisper data processor1 (자막 처리기)

**목적**: Whisper의 word-level 타임스탬프를 문장 단위로 변환하고 ASS 자막 애니메이션 생성

```javascript
// 핵심 로직 (500+ lines 중 주요 부분)

// 1. 단어별 타임스탬프에서 문장 세그먼트 추출
function createSentenceSegments(words, sentences) {
  const segments = [];
  let wordIndex = 0;
  
  for (const sentence of sentences) {
    const sentenceWords = sentence.split(/\s+/);
    const startWord = words[wordIndex];
    const endWord = words[wordIndex + sentenceWords.length - 1];
    
    segments.push({
      text: sentence,
      start: startWord.start,
      end: endWord.end
    });
    
    wordIndex += sentenceWords.length;
  }
  
  return segments;
}

// 2. ASS 자막 생성 (애니메이션 포함)
function generateASS(segments) {
  let ass = `[Script Info]
Title: YouTube Shorts Subtitles
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, ...
Style: Default,NanumGothic,72,&H00FFFFFF,&H000000FF,...

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
`;

  for (const seg of segments) {
    const startTime = formatASSTime(seg.start);
    const endTime = formatASSTime(seg.end);
    // 페이드 인/아웃 효과
    const text = `{\\fad(200,200)}${seg.text}`;
    ass += `Dialogue: 0,${startTime},${endTime},Default,,0,0,0,,${text}\n`;
  }
  
  return ass;
}
```

**출력:**
- `sentence_segments`: 문장별 시작/종료 시간
- `ass_subtitle`: ASS 포맷 자막 파일 내용
- `total_duration`: 전체 오디오 길이

### 6.2 Data Aggregator (데이터 집계기)

**목적**: 모든 미디어 파일과 메타데이터를 하나의 구조로 통합

```javascript
// 핵심 로직 (500+ lines 중 주요 부분)

// 입력 데이터 수집
const videos = $input.all()[0];      // 비디오 파일들
const audio = $input.all()[1];       // TTS 오디오
const subtitles = $input.all()[2];   // 자막 데이터
const bgm = $input.all()[3];         // 배경음악
const logo = $input.all()[4];        // 로고 파일

// 비디오 클립 정보 매핑
const videoClips = videos.map((v, i) => ({
  index: i,
  path: v.json.localPath,
  duration: 5,  // Kling 비디오는 5초 고정
  start_time: subtitles.sentence_segments[i].start,
  end_time: subtitles.sentence_segments[i].end
}));

// 출력 구조
return {
  project: {
    resolution: { width: 1080, height: 1920 },
    fps: 30,
    output_path: `/tmp/output_${Date.now()}.mp4`
  },
  clips: videoClips,
  audio: {
    narration: audio.localPath,
    bgm: bgm.localPath,
    bgm_volume: 0.3
  },
  subtitle: {
    ass_path: subtitles.ass_path,
    style: "Default"
  },
  logo: {
    path: logo.localPath,
    position: "top-right",
    opacity: 0.8
  }
};
```

### 6.3 Simple Video Processor1 (FFmpeg 스크립트 생성기)

**목적**: 복잡한 FFmpeg 명령어 생성 (Ken Burns 효과, 자막, 로고 합성)

```javascript
// 핵심 로직 (600+ lines 중 주요 부분)

function generateFFmpegScript(data) {
  const { project, clips, audio, subtitle, logo } = data;
  
  // 1. 입력 파일 정의
  let inputs = clips.map((c, i) => `-i "${c.path}"`).join(' ');
  inputs += ` -i "${audio.narration}"`;
  inputs += ` -i "${audio.bgm}"`;
  if (logo.path) inputs += ` -i "${logo.path}"`;
  
  // 2. Ken Burns 효과 필터 (확대/이동)
  const kenBurnsFilters = clips.map((clip, i) => {
    const zoomStart = 1.0;
    const zoomEnd = 1.2;
    const duration = clip.end_time - clip.start_time;
    
    return `[${i}:v]scale=1080:1920:force_original_aspect_ratio=increase,` +
           `crop=1080:1920,` +
           `zoompan=z='${zoomStart}+(${zoomEnd}-${zoomStart})*on/${duration*30}':` +
           `x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':` +
           `d=${duration*30}:s=1080x1920:fps=30[v${i}]`;
  }).join('; ');
  
  // 3. 비디오 연결
  const concatFilter = clips.map((_, i) => `[v${i}]`).join('') + 
                       `concat=n=${clips.length}:v=1:a=0[vout]`;
  
  // 4. 자막 오버레이
  const subtitleFilter = `[vout]ass='${subtitle.ass_path}'[vsub]`;
  
  // 5. 로고 오버레이
  const logoFilter = logo.path ? 
    `[vsub][logo]overlay=W-w-20:20:format=auto,format=yuv420p[vfinal]` :
    `[vsub]format=yuv420p[vfinal]`;
  
  // 6. 오디오 믹싱
  const audioFilter = `[${clips.length}:a]volume=1.0[narration];` +
                      `[${clips.length + 1}:a]volume=${audio.bgm_volume}[bgm];` +
                      `[narration][bgm]amix=inputs=2:duration=first[aout]`;
  
  // 7. 최종 FFmpeg 명령어 조합
  const ffmpegCmd = `ffmpeg ${inputs} ` +
    `-filter_complex "${kenBurnsFilters}; ${concatFilter}; ${subtitleFilter}; ${logoFilter}; ${audioFilter}" ` +
    `-map "[vfinal]" -map "[aout]" ` +
    `-c:v libx264 -preset fast -crf 23 ` +
    `-c:a aac -b:a 192k ` +
    `-r 30 -y "${project.output_path}"`;
  
  return {
    script: ffmpegCmd,
    output_path: project.output_path
  };
}
```

**생성되는 FFmpeg 명령어 예시:**
```bash
ffmpeg -i clip1.mp4 -i clip2.mp4 -i clip3.mp4 -i clip4.mp4 -i clip5.mp4 \
  -i narration.mp3 -i bgm.mp3 -i logo.png \
  -filter_complex "
    [0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,
         zoompan=z='1.0+(1.2-1.0)*on/150':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':
         d=150:s=1080x1920:fps=30[v0];
    [1:v]scale=1080:1920...[v1];
    ...
    [v0][v1][v2][v3][v4]concat=n=5:v=1:a=0[vout];
    [vout]ass='/tmp/subtitle.ass'[vsub];
    [vsub][7:v]overlay=W-w-20:20:format=auto,format=yuv420p[vfinal];
    [5:a]volume=1.0[narration];
    [6:a]volume=0.3[bgm];
    [narration][bgm]amix=inputs=2:duration=first[aout]
  " \
  -map "[vfinal]" -map "[aout]" \
  -c:v libx264 -preset fast -crf 23 \
  -c:a aac -b:a 192k \
  -r 30 -y output.mp4
```

---

## 7. API 통합 분석

### 7.1 Freepik Imagen3 API

**엔드포인트**: `https://api.freepik.com/v1/ai/text-to-image/imagen-3`

| 파라미터 | 값 | 설명 |
|---------|-----|------|
| `prompt` | 동적 | 이미지 설명 프롬프트 |
| `negative_prompt` | 고정 | 제외할 요소들 |
| `guidance_scale` | 25 | 프롬프트 준수 강도 |
| `image_size` | portrait_16_9 | 세로형 16:9 |
| `num_images` | 1 | 생성 이미지 수 |
| `style` | photo | 사진 스타일 |

**응답 구조**:
```json
{
  "data": [{
    "base64": "...",  // 또는
    "url": "https://..."
  }]
}
```

### 7.2 Freepik Kling API

**엔드포인트**: `https://api.freepik.com/v1/ai/image-to-video/kling-std`

| 파라미터 | 값 | 설명 |
|---------|-----|------|
| `image` | Google Drive URL | 소스 이미지 |
| `prompt` | 동적 | 비디오 동작 설명 |
| `negative_prompt` | 고정 | 제외할 움직임 |
| `duration` | 5 | 5초 고정 |
| `cfg_scale` | 1 | 프롬프트 준수 강도 |

**비동기 처리 (Polling)**:
```
Request → task_id 반환 → 30초 대기 → 상태 확인 → 완료시 다운로드
```

### 7.3 OpenAI TTS API

**엔드포인트**: `https://api.openai.com/v1/audio/speech`

| 파라미터 | 값 | 설명 |
|---------|-----|------|
| `model` | gpt-4o-mini-tts | TTS 모델 |
| `voice` | coral | 음성 종류 |
| `input` | 스크립트 전체 | 읽을 텍스트 |
| `instructions` | 상세 지시 | 톤, 속도 등 |

### 7.4 OpenAI Whisper API

**엔드포인트**: `https://api.openai.com/v1/audio/transcriptions`

| 파라미터 | 값 | 설명 |
|---------|-----|------|
| `model` | whisper-1 | Whisper 모델 |
| `file` | 오디오 바이너리 | 분석할 오디오 |
| `response_format` | verbose_json | 상세 JSON |
| `language` | ko | 한국어 |
| `timestamp_granularities[]` | word | 단어별 타임스탬프 |

**응답 구조**:
```json
{
  "text": "전체 텍스트",
  "words": [
    { "word": "AI가", "start": 0.0, "end": 0.5 },
    { "word": "우리", "start": 0.5, "end": 0.8 },
    ...
  ]
}
```

---

## 8. FFmpeg 비디오 처리

### 8.1 Ken Burns 효과

```
zoompan 필터:
- z: 줌 레벨 (1.0 → 1.2 서서히 확대)
- x, y: 중심점 좌표
- d: duration (프레임 수)
- s: 출력 해상도 (1080x1920)
- fps: 프레임 레이트 (30)
```

### 8.2 ASS 자막 스타일

```
[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, 
        OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut,
        ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow,
        Alignment, MarginL, MarginR, MarginV, Encoding

Style: Default,NanumGothic,72,&H00FFFFFF,&H000000FF,&H00000000,&H80000000,
       -1,0,0,0,100,100,0,0,1,3,2,2,50,50,80,1
```

**스타일 설명:**
- `NanumGothic`: 한글 폰트
- `72`: 폰트 크기
- `&H00FFFFFF`: 흰색 텍스트
- `Outline: 3`: 외곽선 두께
- `Shadow: 2`: 그림자
- `Alignment: 2`: 하단 중앙

### 8.3 오디오 믹싱

```
amix 필터:
- inputs=2: 나레이션 + BGM
- duration=first: 나레이션 길이에 맞춤
- BGM volume: 0.3 (30%)
```

---

## 9. 연결 맵 (Connections Map)

### 9.1 주요 연결 흐름

```
Webhook
  └─> If1
        ├─> Prepare data2 ─┐
        └─> Prepare data3 ─┴─> Narration Script Generate1
                                      │
                              Update row in sheet3
                                      │
                              Split Out ─> Wait 3S1 ─> Generate Image Prompts2
                                                              │
                                                      Wait 3S ─> Freepik Request Img
                                                              │
                                                      Wait 15S ─> Check Img
                                                              │
                                            Verify Img ─┬─> Get Img ─> Upload file ─> Switch1
                                                        └─> Wait 5S4 (retry)
                                                              │
                                    Switch1 ─┬─> Generate Video Prompts3 ─> Request Freepik Video
                                             │                                      │
                                             │                              Save Task IDs ─> Wait 30S
                                             │                                      │
                                             │                              Check video ─> Verify Video
                                             │                                      │
                                             │                      Wait All ─> All complete?
                                             │                              │
                                             │                      Split Out1 ─> Get Video ─> Restore Order
                                             │                              │
                                             └─────────────────> Upload Video ─> Merge1
                                                                        │
┌───────────────────────────────────────────────────────────────────────┘
│
└─> Search audio files1 ─> Download file1 ─> Generate Subtitles
                                    │
                        whisper data processor1 ─> Search music files1
                                    │                       │
                                    │               Music random1 ─> logo1
                                    │                       │           │
                                    └─────────> Final Merge1 <──────────┘
                                                    │
                                            Data Aggregator
                                                    │
                                        Simple Video Processor1
                                                    │
                                        File-based Script Executor1
                                                    │
                                        Read/Write Files from Disk3
                                                    │
                                            Execute Command3
                                                    │
                                            Execute Command1
                                                    │
                                        Metadata Generate1
                                                    │
                                    Read/Write Files from Disk2
                                                    │
                                        Upload a video
                                                    │
                                        Update row in sheet
```

### 9.2 Final Merge1 입력 연결

```
Final Merge1 (5개 입력):
  ├─ Input 0: Merge1 (비디오/이미지)
  ├─ Input 1: Search audio files1 (오디오)
  ├─ Input 2: whisper data processor1 (자막)
  ├─ Input 3: Music random1 (BGM)
  └─ Input 4: logo1 (로고)
```

---

## 10. Gemini Edition과의 비교

### 10.1 기술 스택 비교

| 기능 | Reference (OpenCoreAI) | Gemini Edition |
|-----|------------------------|----------------|
| **내레이션 LLM** | OpenAI GPT-4.1-nano | Google Gemini 2.0 Flash |
| **이미지 생성** | Freepik Imagen3 | Google Imagen 3 |
| **비디오 생성** | Freepik Kling | Google Veo 3 |
| **TTS** | OpenAI TTS (coral) | Google Cloud TTS |
| **자막 생성** | OpenAI Whisper | Google Speech-to-Text |
| **Safety Filter** | 없음 | LLM Chain Safety Refiner |

### 10.2 아키텍처 차이

| 특성 | Reference | Gemini Edition |
|-----|-----------|----------------|
| **실행 환경** | 로컬 전용 | 클라우드 가능 |
| **비디오 처리** | FFmpeg (로컬) | Google API 기반 |
| **자막 방식** | ASS 파일 + FFmpeg | API 내장 자막 |
| **메모리** | 없음 | Agent Memory 지원 |
| **안전 필터** | 없음 | 다단계 Safety Refiner |

### 10.3 장단점 비교

**Reference (OpenCoreAI):**
```
장점:
✅ 완전한 로컬 제어
✅ FFmpeg의 강력한 비디오 편집 기능
✅ Ken Burns 효과 등 고급 기능
✅ ASS 자막 애니메이션 지원
✅ 비용 효율적 (Freepik 요금제)

단점:
❌ 로컬 환경 필수
❌ FFmpeg, 폰트 설치 필요
❌ Safety Filter 부재
❌ 복잡한 설정
```

**Gemini Edition:**
```
장점:
✅ Google 생태계 통합
✅ 클라우드 실행 가능
✅ Safety Filter 내장
✅ Agent Memory 지원
✅ 설정 간소화

단점:
❌ Google API 비용
❌ FFmpeg 수준의 편집 제한
❌ 외부 의존성 높음
```

---

## 📎 부록

### A. Google Sheets 필드 구조

```
| 열 | 필드명 | 설명 |
|----|--------|------|
| A | job_id | 작업 고유 ID |
| B | keyword | 주제 키워드 |
| C | script | 생성된 스크립트 |
| D | status | 진행 상태 |
| E | video_url | YouTube URL |
| F | created_at | 생성 일시 |
```

### B. 폴더 구조 (Google Drive)

```
📁 YouTube Shorts Automation/
  ├── 📁 Images/           # 생성된 이미지
  ├── 📁 Videos/           # Kling 생성 비디오
  ├── 📁 Audio/            # TTS 오디오
  ├── 📁 BGM/              # 배경음악 라이브러리
  ├── 📁 Subtitles/        # ASS 자막 파일
  ├── 📁 Output/           # 최종 렌더링 결과
  └── 📁 Logos/            # 채널 로고
```

### C. Wait 노드 타이밍

| 노드 | 대기 시간 | 목적 |
|------|----------|------|
| Wait 3S | 3초 | API Rate Limit 회피 |
| Wait 3S1 | 3초 | 문장 처리 간격 |
| Wait 5S1 | 5초 | 비디오 확인 전 대기 |
| Wait 5S4 | 5초 | 이미지 재시도 전 대기 |
| Wait 15S | 15초 | 이미지 생성 대기 |
| Wait 30S | 30초 | 비디오 생성 대기 |

---

## 🔗 참고 링크

- **OpenCoreAI 공식**: https://opencoreai.org
- **Google Sheets 템플릿**: https://docs.google.com/spreadsheets/d/11jsblXeg-i87l0Pcs319vMUdKdOjdC3bzl6rfRCRqe4
- **Freepik API 문서**: https://www.freepik.com/api
- **FFmpeg 문서**: https://ffmpeg.org/documentation.html
- **ASS 자막 규격**: https://github.com/libass/libass

---

> **문서 작성**: GitHub Copilot  
> **분석 기준**: Shared_Youtube Shorts Automation_opencoreai.json (2,676 lines)  
> **마지막 업데이트**: 2024년
