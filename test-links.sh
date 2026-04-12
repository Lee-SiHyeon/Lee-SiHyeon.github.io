echo "📋 Checking all HTML files in repo..."
for file in *.html; do
  echo ""
  echo "File: $file"
  ls -lh "$file"
  echo "Lines: $(wc -l < "$file")"
done

echo ""
echo "📍 Checking deployed URLs..."
for file in mcp-corpus-report.html mcp-autorag-pipeline.html topic-selection-enhancement.html; do
  echo ""
  echo "Testing: $file"
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://lee-sihyeon.github.io/$file")
  size=$(curl -s "https://lee-sihyeon.github.io/$file" | wc -c)
  echo "  HTTP Status: $status"
  echo "  Content Size: $size bytes"
done
