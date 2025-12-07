# YouTube Shorts Automation with Gemini 2.5 & Veo 3

This project automates the creation of YouTube Shorts using n8n, Google Gemini 2.5 models, and Google Veo 3 for video generation.

## Features

- **Story Generation**: Uses `Gemini 2.5 Flash` to create engaging 5-scene scripts.
- **Visual Planning**: Uses `Gemini 2.5 Pro` to generate detailed image prompts for each of the 5 scenes.
- **Image Generation**: Generates 5 distinct images corresponding to the script scenes.
- **Video Creation**: Uses `Google Veo 3` (via Vertex AI) to animate the generated images into a cohesive video.
- **Memory Optimization**: Optimized n8n workflow to handle binary data efficiently and prevent memory errors.

## Workflow Structure

1.  **Script Agent**: Generates a structured script with exactly 5 scenes.
2.  **Image Prompt Agent**: Converts the script into 5 separate image prompts.
3.  **Split & Loop**: Iterates through each prompt to generate images.
4.  **Aggregate**: Collects all 5 images.
5.  **Video Generation**: Sends images to Veo 3 for video synthesis.

## Files

- `YouTube_Shorts_Automation_Gemini.json`: The complete n8n workflow file.
- `start_google_drive_mcp.ps1`: PowerShell script to start the Google Drive MCP server for file management.

## Usage

1.  Import `YouTube_Shorts_Automation_Gemini.json` into n8n.
2.  Configure your Google Cloud credentials (Vertex AI).
3.  Run the workflow.
