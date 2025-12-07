# 🛡️ 주제 선정 고도화 (Topic Selection Enhancement)

## 🛑 문제 상황 (Problem)
자동화 파이프라인이 커뮤니티의 인기 게시글을 무작위로 가져오다 보니, YouTube의 콘텐츠 정책에 위배될 수 있는 **선정적(Sexually Explicit)**이거나 **폭력적(Violent)**인 주제가 선택될 위험이 있었습니다. 이는 채널의 안전성을 위협하고, 자동화 시스템의 신뢰도를 떨어뜨리는 요인이 되었습니다.

## ✅ 해결 방안 (Solution)
**Gemini Agent**의 `Select Topic` 노드에 적용되는 프롬프트를 고도화하여, 엄격한 필터링 기준을 적용했습니다. 단순한 "재미있는 이야기" 선정이 아닌, **"안전하고(Safe) 대중적인(Suitable)"** 이야기를 선정하도록 지시했습니다.

### 📝 적용된 프롬프트 (Refined Prompt)

```text
Analyze the HTML content and extract the most interesting/funny story suitable for a YouTube Short.

CRITICAL FILTERING CRITERIA:
1. STRICTLY EXCLUDE any content that is sexually explicit, lewd, or contains severe violence/gore.
2. EXCLUDE content that violates YouTube's Community Guidelines regarding safety and suitability for general audiences.
3. Prioritize funny, relatable, or surprising stories that are safe for work (SFW).

Content: {{ $json.data }}

Output the story summary.
```

### 🔑 핵심 변경 사항
1.  **CRITICAL FILTERING CRITERIA 추가**: AI에게 최우선으로 고려해야 할 필터링 기준을 명시했습니다.
2.  **STRICTLY EXCLUDE (엄격 제외)**: 성적, 폭력적 콘텐츠에 대해 타협 없는 제외 규칙을 적용했습니다.
3.  **YouTube 가이드라인 준수**: 플랫폼의 정책을 준수하도록 명시하여 계정 정지 위험을 최소화했습니다.
4.  **SFW (Safe For Work) 우선**: 누구나 볼 수 있는 안전한 콘텐츠를 우선순위로 두었습니다.

## 🚀 결과 (Result)
이 업데이트를 통해 자극적인 제목이나 내용이 포함된 게시글은 AI가 자동으로 걸러내게 되었으며, YouTube Shorts에 적합한 건전하고 재미있는 소재만이 파이프라인의 다음 단계로 넘어가게 되었습니다. 이를 통해 **완전 자동화 시스템의 안정성**을 크게 확보했습니다.

[← 메인으로 돌아가기](./index.md)
