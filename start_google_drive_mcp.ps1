$env:GOOGLE_OAUTH_CLIENT_ID = "YOUR_CLIENT_ID_HERE"
$env:GOOGLE_OAUTH_CLIENT_SECRET = "YOUR_CLIENT_SECRET_HERE"

Write-Host "Starting Google Workspace MCP Server..."
Write-Host "Please authenticate in your browser if prompted."

# Use uvx to run the server
uvx workspace-mcp