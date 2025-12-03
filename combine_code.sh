#!/bin/bash
# combine_code.sh - Combine all code files into one organized file

# Configuration
OUTPUT_FILE="combined_code_$(date +%Y%m%d_%H%M%S).txt"

# File extensions to include (case insensitive patterns)
FILE_PATTERNS=(
    "*.js"
    "*.yaml"
    "*.yml"
    "*.sh"
    "Dockerfile"
    "Dockerfile.*"
    "Jenkinsfile"
    "Jenkinsfile.*"
    "docker-compose*.yml"
    "docker-compose*.yaml"
)

# Directories to exclude
EXCLUDE_DIRS=(
    "node_modules"
    ".git"
    "dist"
    "build"
    ".next"
    "target"
    "vendor"
    "__pycache__"
    "venv"
    ".idea"
    ".vscode"
)

echo "=== Code Collection Started ==="
echo "Output file: $OUTPUT_FILE"

# Clear or create output file
> "$OUTPUT_FILE"

# Write header
{
    echo "# CODE REPOSITORY COLLECTION"
    echo "# Generated: $(date)"
    echo "# Project: $(basename "$PWD")"
    echo "=========================================="
    echo ""
} >> "$OUTPUT_FILE"

# Build find command
find_cmd="find . -type f "

# Add exclude patterns
for dir in "${EXCLUDE_DIRS[@]}"; do
    find_cmd+="-not -path \"./$dir/*\" -not -path \"./$dir\" "
done

# Add file patterns
find_cmd+="\( "
first=true
for pattern in "${FILE_PATTERNS[@]}"; do
    if [ "$first" = true ]; then
        find_cmd+="-name \"$pattern\""
        first=false
    else
        find_cmd+=" -o -name \"$pattern\""
    fi
done
find_cmd+=" \)"

# Execute find and process files
echo "Searching for files..."
file_count=0
total_size=0

eval "$find_cmd" | sort | while read -r file; do
    # Skip empty files
    if [ ! -s "$file" ]; then
        continue
    fi
    
    # Get file info
    file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    rel_path="${file#./}"
    
    echo "Processing: $rel_path (${file_size} bytes)"
    
    # Write file header
    {
        echo ""
        echo "################################################################"
        echo "# FILE: $rel_path"
        echo "# SIZE: ${file_size} bytes"
        echo "# TYPE: $(file -b --mime-type "$file" 2>/dev/null || echo "unknown")"
        echo "################################################################"
        echo ""
    } >> "$OUTPUT_FILE"
    
    # Add file content
    cat "$file" >> "$OUTPUT_FILE"
    
    # Ensure newline at end of file content
    echo "" >> "$OUTPUT_FILE"
    
    # Update counters
    ((file_count++))
    total_size=$((total_size + file_size))
done

# Write summary
{
    echo ""
    echo "=========================================="
    echo "# SUMMARY"
    echo "# Files processed: $file_count"
    echo "# Total size: $total_size bytes"
    echo "# Output file: $OUTPUT_FILE"
    echo "# Generation completed: $(date)"
} >> "$OUTPUT_FILE"

echo ""
echo "=== Code Collection Completed ==="
echo "Total files processed: $file_count"
echo "Output saved to: $OUTPUT_FILE"
echo "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"