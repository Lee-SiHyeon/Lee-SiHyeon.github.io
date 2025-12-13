---
layout: default
title: AI 에이전트에 MCP 서버 강제 사용 가이드
parent: Home
nav_order: 6
---

# AI 에이전트에 MCP 서버 강제 사용 가이드

## 1. 개요: MCP(Model Context Protocol)란?

MCP는 **AI 애플리케이션을 위한 USB-C 포트**와 같습니다. USB-C가 다양한 장치와 주변기기를 연결하는 표준화된 방법을 제공하듯, MCP는 **AI 모델과 다양한 데이터 소스 및 도구를 연결하는 표준화된 프로토콜**입니다.

```
┌─────────────────┐     ┌─────────────┐     ┌─────────────────┐
│   AI Agent      │────▶│  MCP Client │────▶│   MCP Server    │
│  (LLM + Memory) │     │  (n8n Tool) │     │ (Tools/Resources)│
└─────────────────┘     └─────────────┘     └─────────────────┘
                                                    │
                              ┌─────────────────────┼─────────────────────┐
                              ▼                     ▼                     ▼
                        ┌──────────┐         ┌──────────┐         ┌──────────┐
                        │ Database │         │   API    │         │   File   │
                        │  Query   │         │  Calls   │         │  System  │
                        └──────────┘         └──────────┘         └──────────┘
```

### 핵심 이점:
- **표준화**: 모든 도구가 동일한 인터페이스로 연결
- **분리**: AI 로직과 도구 구현을 분리하여 유지보수 용이
- **보안**: 도구 접근을 중앙에서 관리 가능
- **확장성**: 새 도구 추가 시 AI 에이전트 수정 불필요

---

## 2. 왜 MCP 서버를 "강제"해야 하는가?

### 2.1 일반적인 AI 에이전트 구조의 문제점

```
┌─────────────────────────────────────────────────────────────┐
│                     AI Agent Node                           │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│  │  Tool A │  │  Tool B │  │  Tool C │  │  Tool D │  ...   │
│  │ (직접)  │  │ (직접)  │  │ (직접)  │  │ (직접)  │        │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘        │
└─────────────────────────────────────────────────────────────┘
                         ↓ 문제점
- 도구가 추가될 때마다 에이전트 수정 필요
- 도구별 인증/권한 관리 복잡
- 도구 간 일관성 없음
- 테스트 및 디버깅 어려움
```

### 2.2 MCP 강제 적용 후 구조

```
┌─────────────────────────────────────────────────────────────┐
│                     AI Agent Node                           │
│                    ┌───────────────┐                        │
│                    │  MCP Client   │                        │
│                    │   (단일 Tool) │                        │
│                    └───────┬───────┘                        │
└────────────────────────────┼────────────────────────────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
       ┌───────────┐  ┌───────────┐  ┌───────────┐
       │MCP Server │  │MCP Server │  │MCP Server │
       │  (검색)   │  │ (DB 조회) │  │ (파일 IO) │
       └───────────┘  └───────────┘  └───────────┘
                         ↓ 장점
- 도구 추가 시 MCP 서버만 추가/설정
- 중앙 집중식 인증 관리
- 표준화된 인터페이스
- 독립적 테스트 가능
```

---

## 3. MCP 서버 강제 적용 아키텍처 패턴

### 3.1 Gateway 패턴 (권장)

모든 도구 호출이 MCP Gateway를 통해서만 가능하도록 강제합니다.

```
┌─────────────────────────────────────────────────────────────────┐
│                        AI Agent                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                   MCP Gateway Client                      │   │
│  │   (유일하게 허용된 Tool - 모든 요청은 여기로)             │   │
│  └─────────────────────────┬────────────────────────────────┘   │
└────────────────────────────┼────────────────────────────────────┘
                             │
                 ┌───────────┴───────────┐
                 ▼                       ▼
        ┌─────────────────┐    ┌─────────────────┐
        │  MCP Router     │    │  Auth Manager   │
        │  (요청 라우팅)   │    │  (인증/권한)    │
        └────────┬────────┘    └────────┬────────┘
                 │                      │
    ┌────────────┼──────────────────────┼────────────┐
    ▼            ▼                      ▼            ▼
┌───────┐   ┌───────┐             ┌───────┐   ┌───────┐
│Search │   │  DB   │             │ File  │   │ Custom│
│Server │   │Server │             │Server │   │Server │
└───────┘   └───────┘             └───────┘   └───────┘
```

### 3.2 n8n에서의 구현

```json
{
  "nodes": [
    {
      "name": "AI Agent",
      "type": "@n8n/n8n-nodes-langchain.agent",
      "parameters": {
        "agent": "toolsAgent"
      }
    },
    {
      "name": "MCP Gateway Tool",
      "type": "@n8n/n8n-nodes-langchain.toolMcp",
      "parameters": {
        "sseEndpoint": "http://your-mcp-gateway:3000/sse",
        "authentication": "bearerAuth",
        "toolsToInclude": "all"
      }
    }
  ],
  "connections": {
    "MCP Gateway Tool": {
      "ai_tool": [["AI Agent", 0, "ai_tool", 0]]
    }
  }
}
```

---

## 4. MCP 서버 강제 적용 구현 방법

### 4.1 방법 1: n8n AI Agent에서 MCP Tool만 허용

n8n의 AI Agent 노드에 **MCP Client Tool 노드만** 연결하여 다른 직접 도구 사용을 차단합니다.

```
┌─────────────────────────────────────────────────────────────┐
│                    n8n Workflow                             │
│                                                             │
│  ┌─────────────┐      ┌─────────────┐                      │
│  │  AI Agent   │◀────▶│ MCP Client  │                      │
│  │   Node      │      │   Tool      │                      │
│  └─────────────┘      └──────┬──────┘                      │
│         │                    │                              │
│         ▼                    ▼                              │
│  ┌─────────────┐      ┌─────────────┐                      │
│  │   Memory    │      │ MCP Server  │                      │
│  │   (선택)    │      │  (외부)     │                      │
│  └─────────────┘      └─────────────┘                      │
└─────────────────────────────────────────────────────────────┘
```

**n8n MCP Client Tool 설정:**

| 파라미터 | 설정값 | 설명 |
|---------|-------|------|
| SSE Endpoint | `http://mcp-server:3000/sse` | MCP 서버 SSE 엔드포인트 |
| Authentication | Bearer / Header / OAuth2 | 인증 방식 선택 |
| Tools to Include | All / Selected / All Except | 노출할 도구 선택 |

### 4.2 방법 2: Custom MCP Server 구축

모든 도구를 MCP 서버로 래핑하여 표준화합니다.

```python
# mcp_gateway_server.py
from mcp.server.fastmcp import FastMCP
from mcp.server import Server
import mcp.types as types

# MCP Gateway 서버 생성
mcp = FastMCP("Tool Gateway")

# 도구 1: 웹 검색
@mcp.tool()
async def web_search(query: str) -> str:
    """인터넷에서 정보를 검색합니다."""
    # 실제 검색 로직 구현
    result = await perform_search(query)
    return result

# 도구 2: 데이터베이스 조회
@mcp.tool()
async def query_database(sql: str) -> dict:
    """데이터베이스를 조회합니다."""
    # 실제 DB 조회 로직
    result = await execute_query(sql)
    return {"result": result}

# 도구 3: 파일 시스템 접근
@mcp.tool()
async def read_file(path: str) -> str:
    """파일 내용을 읽습니다."""
    with open(path, 'r') as f:
        return f.read()

# 도구 4: 외부 API 호출
@mcp.tool()
async def call_external_api(
    endpoint: str, 
    method: str = "GET",
    payload: dict = None
) -> dict:
    """외부 API를 호출합니다."""
    response = await make_api_call(endpoint, method, payload)
    return response

# 서버 실행
if __name__ == "__main__":
    mcp.run()
```

### 4.3 방법 3: MCP Server Trigger로 n8n 워크플로우 노출

n8n 워크플로우 자체를 MCP 서버로 노출하여 외부 AI 에이전트가 사용하게 합니다.

```json
{
  "nodes": [
    {
      "name": "MCP Server Trigger",
      "type": "@n8n/n8n-nodes-langchain.mcpTrigger",
      "parameters": {
        "path": "my-tools",
        "toolName": "process_data",
        "toolDescription": "데이터를 처리하고 결과를 반환합니다"
      }
    },
    {
      "name": "Processing Logic",
      "type": "n8n-nodes-base.code",
      "parameters": {
        "code": "// 실제 처리 로직"
      }
    }
  ]
}
```

---

## 5. MCP 서버 강제를 위한 시스템 아키텍처

### 5.1 전체 아키텍처

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           MCP-First Architecture                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                        AI Agent Layer                            │   │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │
│   │  │ Agent A  │  │ Agent B  │  │ Agent C  │  │ Agent D  │        │   │
│   │  │ (연구)   │  │ (작성)   │  │ (검수)   │  │ (실행)   │        │   │
│   │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘        │   │
│   │       │             │             │             │               │   │
│   │       └─────────────┴──────┬──────┴─────────────┘               │   │
│   │                            │                                     │   │
│   │                            ▼                                     │   │
│   │                 ┌────────────────────┐                          │   │
│   │                 │   MCP Client Hub   │◀─────── ONLY ALLOWED     │   │
│   │                 │   (Single Entry)   │         TOOL INTERFACE   │   │
│   │                 └─────────┬──────────┘                          │   │
│   └───────────────────────────┼─────────────────────────────────────┘   │
│                               │                                          │
│   ┌───────────────────────────┼─────────────────────────────────────┐   │
│   │                           ▼                                      │   │
│   │              ┌─────────────────────────────┐                    │   │
│   │              │      MCP Gateway Server      │                    │   │
│   │              │  ┌─────────┬─────────────┐  │                    │   │
│   │              │  │ Router  │ Auth/AuthZ  │  │                    │   │
│   │              │  └────┬────┴──────┬──────┘  │                    │   │
│   │              └───────┼───────────┼─────────┘                    │   │
│   │                      │           │                               │   │
│   │    ┌─────────────────┼───────────┼─────────────────┐            │   │
│   │    │                 │           │                 │            │   │
│   │    ▼                 ▼           ▼                 ▼            │   │
│   │ ┌──────────┐   ┌──────────┐ ┌──────────┐   ┌──────────┐        │   │
│   │ │ Search   │   │ Database │ │   File   │   │   API    │        │   │
│   │ │ MCP Srv  │   │ MCP Srv  │ │ MCP Srv  │   │ MCP Srv  │        │   │
│   │ └──────────┘   └──────────┘ └──────────┘   └──────────┘        │   │
│   │                      MCP Server Layer                           │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.2 MCP Gateway 서버 구현

```python
# mcp_gateway.py
from mcp.server import Server
from mcp.server.lowlevel import NotificationOptions
import mcp.types as types
from typing import Any
import asyncio

# Gateway 서버 생성
server = Server("mcp-gateway")

# 등록된 백엔드 MCP 서버들
BACKEND_SERVERS = {
    "search": "http://search-mcp:3001/sse",
    "database": "http://db-mcp:3002/sse",
    "filesystem": "http://fs-mcp:3003/sse",
    "api": "http://api-mcp:3004/sse"
}

# 도구 권한 매핑
TOOL_PERMISSIONS = {
    "web_search": ["search"],
    "query_db": ["database"],
    "read_file": ["filesystem"],
    "call_api": ["api"]
}

@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    """모든 백엔드 서버의 도구를 집계하여 반환"""
    all_tools = []
    
    for server_name, endpoint in BACKEND_SERVERS.items():
        tools = await fetch_tools_from_server(endpoint)
        for tool in tools:
            # 네임스페이스 추가
            tool.name = f"{server_name}.{tool.name}"
            all_tools.append(tool)
    
    return all_tools

@server.call_tool()
async def handle_tool_call(
    name: str, 
    arguments: dict[str, Any]
) -> list[types.TextContent]:
    """도구 호출을 적절한 백엔드 서버로 라우팅"""
    
    # 네임스페이스에서 서버 이름 추출
    server_name, tool_name = name.split(".", 1)
    
    # 권한 검증
    if not await verify_permission(server_name, tool_name):
        return [types.TextContent(
            type="text",
            text=f"Permission denied for tool: {name}"
        )]
    
    # 백엔드 서버로 요청 전달
    endpoint = BACKEND_SERVERS.get(server_name)
    if not endpoint:
        return [types.TextContent(
            type="text",
            text=f"Unknown server: {server_name}"
        )]
    
    result = await forward_to_backend(endpoint, tool_name, arguments)
    
    return [types.TextContent(type="text", text=str(result))]

async def verify_permission(server_name: str, tool_name: str) -> bool:
    """도구 사용 권한 검증"""
    # 실제 구현에서는 사용자/역할 기반 권한 검사
    return True

async def forward_to_backend(
    endpoint: str, 
    tool_name: str, 
    arguments: dict
) -> Any:
    """백엔드 MCP 서버로 요청 전달"""
    # MCP 클라이언트 연결 및 도구 호출
    async with connect_to_mcp_server(endpoint) as session:
        result = await session.call_tool(tool_name, arguments)
        return result.content[0].text if result.content else ""
```

---

## 6. n8n에서 MCP 강제 적용 설정

### 6.1 워크플로우 설계 원칙

```json
{
  "name": "MCP-Enforced AI Agent Workflow",
  "nodes": [
    {
      "name": "Chat Trigger",
      "type": "@n8n/n8n-nodes-langchain.chatTrigger",
      "position": [250, 300]
    },
    {
      "name": "AI Agent",
      "type": "@n8n/n8n-nodes-langchain.agent",
      "position": [450, 300],
      "parameters": {
        "agent": "toolsAgent",
        "systemMessage": "당신은 MCP 서버를 통해서만 외부 도구에 접근할 수 있습니다."
      }
    },
    {
      "name": "Gemini Chat Model",
      "type": "@n8n/n8n-nodes-langchain.lmChatGoogleGemini",
      "position": [450, 500],
      "parameters": {
        "model": "models/gemini-2.5-flash"
      }
    },
    {
      "name": "MCP Gateway Tool",
      "type": "@n8n/n8n-nodes-langchain.toolMcp",
      "position": [650, 300],
      "parameters": {
        "sseEndpoint": "={{ $env.MCP_GATEWAY_ENDPOINT }}",
        "authentication": "bearerAuth",
        "toolsToInclude": "all"
      }
    },
    {
      "name": "Memory",
      "type": "@n8n/n8n-nodes-langchain.memoryBufferWindow",
      "position": [650, 500],
      "parameters": {
        "windowSize": 10
      }
    }
  ],
  "connections": {
    "Chat Trigger": {
      "main": [[{"node": "AI Agent", "type": "main", "index": 0}]]
    },
    "Gemini Chat Model": {
      "ai_languageModel": [[{"node": "AI Agent", "type": "ai_languageModel", "index": 0}]]
    },
    "MCP Gateway Tool": {
      "ai_tool": [[{"node": "AI Agent", "type": "ai_tool", "index": 0}]]
    },
    "Memory": {
      "ai_memory": [[{"node": "AI Agent", "type": "ai_memory", "index": 0}]]
    }
  }
}
```

### 6.2 환경 변수 설정

```bash
# .env
MCP_GATEWAY_ENDPOINT=http://mcp-gateway:3000/sse
MCP_AUTH_TOKEN=your-secure-token
```

---

## 7. MCP 서버 유형별 구현 예시

### 7.1 검색 도구 MCP 서버

```python
# search_mcp_server.py
from mcp.server.fastmcp import FastMCP
import httpx

mcp = FastMCP("Search Server")

@mcp.tool()
async def google_search(query: str, num_results: int = 5) -> str:
    """구글 검색을 수행합니다."""
    async with httpx.AsyncClient() as client:
        response = await client.get(
            "https://api.serpapi.com/search",
            params={"q": query, "num": num_results}
        )
        return response.json()

@mcp.tool()
async def news_search(topic: str, language: str = "ko") -> str:
    """뉴스를 검색합니다."""
    # 뉴스 검색 로직
    pass

if __name__ == "__main__":
    mcp.run()
```

### 7.2 데이터베이스 MCP 서버

```python
# database_mcp_server.py
from mcp.server.fastmcp import FastMCP
import asyncpg

mcp = FastMCP("Database Server")

@mcp.tool()
async def query_postgres(
    sql: str,
    params: list = None
) -> dict:
    """PostgreSQL 데이터베이스를 조회합니다.
    
    Args:
        sql: 실행할 SQL 쿼리
        params: 쿼리 파라미터 (선택)
    
    Returns:
        조회 결과 딕셔너리
    """
    conn = await asyncpg.connect(DATABASE_URL)
    try:
        rows = await conn.fetch(sql, *(params or []))
        return {"rows": [dict(row) for row in rows]}
    finally:
        await conn.close()

@mcp.tool()
async def insert_data(
    table: str,
    data: dict
) -> dict:
    """데이터를 삽입합니다."""
    # INSERT 로직
    pass

if __name__ == "__main__":
    mcp.run()
```

### 7.3 n8n 워크플로우 MCP 서버

```python
# n8n_workflow_mcp_server.py
from mcp.server.fastmcp import FastMCP
import httpx

mcp = FastMCP("n8n Workflow Server")

N8N_API_URL = "http://n8n:5678/api/v1"
N8N_API_KEY = "your-api-key"

@mcp.tool()
async def execute_workflow(
    workflow_id: str,
    input_data: dict = None
) -> dict:
    """n8n 워크플로우를 실행합니다.
    
    Args:
        workflow_id: 실행할 워크플로우 ID
        input_data: 워크플로우에 전달할 입력 데이터
    """
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{N8N_API_URL}/workflows/{workflow_id}/execute",
            headers={"X-N8N-API-KEY": N8N_API_KEY},
            json={"data": input_data or {}}
        )
        return response.json()

@mcp.tool()
async def list_workflows() -> list:
    """사용 가능한 워크플로우 목록을 반환합니다."""
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{N8N_API_URL}/workflows",
            headers={"X-N8N-API-KEY": N8N_API_KEY}
        )
        return response.json()

if __name__ == "__main__":
    mcp.run()
```

---

## 8. 보안 및 인증 강화

### 8.1 MCP 서버 인증 구현

```python
# auth_middleware.py
from functools import wraps
import jwt

def require_auth(func):
    """MCP 도구 호출에 인증을 요구하는 데코레이터"""
    @wraps(func)
    async def wrapper(*args, **kwargs):
        context = get_request_context()
        token = context.headers.get("Authorization", "").replace("Bearer ", "")
        
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            context.user = payload
        except jwt.InvalidTokenError:
            raise PermissionError("Invalid authentication token")
        
        return await func(*args, **kwargs)
    return wrapper

# 사용 예
@mcp.tool()
@require_auth
async def sensitive_operation(data: str) -> str:
    """인증이 필요한 민감한 작업"""
    pass
```

### 8.2 역할 기반 접근 제어 (RBAC)

```python
# rbac.py
ROLE_PERMISSIONS = {
    "admin": ["*"],  # 모든 도구 접근 가능
    "researcher": ["search.*", "database.query"],
    "writer": ["search.*", "database.query", "file.read"],
    "executor": ["workflow.*", "api.*"]
}

def check_permission(user_role: str, tool_name: str) -> bool:
    """도구 접근 권한 검사"""
    allowed_patterns = ROLE_PERMISSIONS.get(user_role, [])
    
    for pattern in allowed_patterns:
        if pattern == "*":
            return True
        if pattern.endswith(".*"):
            prefix = pattern[:-2]
            if tool_name.startswith(prefix):
                return True
        if pattern == tool_name:
            return True
    
    return False
```

---

## 9. 모니터링 및 로깅

### 9.1 MCP 호출 로깅

```python
# logging_middleware.py
import logging
from datetime import datetime

logger = logging.getLogger("mcp_audit")

async def log_tool_call(
    tool_name: str,
    arguments: dict,
    result: Any,
    user: dict,
    duration_ms: float
):
    """도구 호출을 로깅합니다."""
    log_entry = {
        "timestamp": datetime.utcnow().isoformat(),
        "tool": tool_name,
        "user_id": user.get("id"),
        "user_role": user.get("role"),
        "arguments": arguments,
        "result_size": len(str(result)),
        "duration_ms": duration_ms,
        "success": True
    }
    logger.info(json.dumps(log_entry))
```

### 9.2 Prometheus 메트릭

```python
# metrics.py
from prometheus_client import Counter, Histogram

mcp_tool_calls = Counter(
    'mcp_tool_calls_total',
    'Total MCP tool calls',
    ['tool_name', 'status']
)

mcp_tool_duration = Histogram(
    'mcp_tool_duration_seconds',
    'MCP tool call duration',
    ['tool_name']
)
```

---

## 10. 결론: MCP 강제 적용 체크리스트

### ✅ 구현 체크리스트

| 항목 | 설명 | 상태 |
|-----|------|------|
| MCP Gateway 서버 구축 | 모든 도구 요청을 중앙 처리 | ☐ |
| 백엔드 MCP 서버 분리 | 기능별로 MCP 서버 분리 구현 | ☐ |
| n8n AI Agent 설정 | MCP Client Tool만 연결 | ☐ |
| 인증 미들웨어 | JWT/OAuth2 인증 구현 | ☐ |
| RBAC 설정 | 역할별 도구 접근 권한 설정 | ☐ |
| 로깅 및 모니터링 | 감사 로그 및 메트릭 수집 | ☐ |
| 문서화 | 도구 사용 가이드 작성 | ☐ |

### 📊 기대 효과

1. **일관성**: 모든 AI 에이전트가 동일한 인터페이스로 도구 사용
2. **보안**: 중앙 집중식 인증 및 권한 관리
3. **확장성**: 새 도구 추가 시 에이전트 수정 불필요
4. **추적성**: 모든 도구 호출 감사 로그
5. **유지보수**: 도구별 독립적 배포 및 테스트

---

## 참고 자료

- [Model Context Protocol 공식 문서](https://modelcontextprotocol.io/)
- [n8n MCP Client Tool 문서](https://docs.n8n.io/integrations/builtin/cluster-nodes/sub-nodes/n8n-nodes-langchain.toolmcp/)
- [n8n MCP Server Trigger 문서](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-langchain.mcptrigger/)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
