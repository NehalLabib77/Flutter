import os
import re
from pathlib import Path

def remove_all_comments(content):
    """Remove ALL types of comments from Dart code including inline comments"""
    
    # Remove multi-line comments /* ... */
    content = re.sub(r'/\*[\s\S]*?\*/', '', content)
    
    # Process line by line for single-line comments
    lines = content.split('\n')
    cleaned_lines = []
    
    for line in lines:
        in_string = False
        in_single_quote = False
        in_double_quote = False
        escape_next = False
        result = []
        i = 0
        
        while i < len(line):
            char = line[i]
            
            # Handle escape sequences
            if escape_next:
                result.append(char)
                escape_next = False
                i += 1
                continue
            
            # Check for backslash
            if char == '\\':
                escape_next = True
                result.append(char)
                i += 1
                continue
            
            # Handle double quotes
            if char == '"' and not in_single_quote:
                in_double_quote = not in_double_quote
                result.append(char)
                i += 1
                continue
            
            # Handle single quotes
            if char == "'" and not in_double_quote:
                in_single_quote = not in_single_quote
                result.append(char)
                i += 1
                continue
            
            # Check for comment start - only if not in string
            if not in_double_quote and not in_single_quote and i < len(line) - 1 and line[i:i+2] == '//':
                break
            
            result.append(char)
            i += 1
        
        cleaned_line = ''.join(result).rstrip()
        if cleaned_line or not cleaned_lines or cleaned_lines[-1]:
            cleaned_lines.append(cleaned_line)
    
    content = '\n'.join(cleaned_lines)
    
    # Remove multiple consecutive empty lines (keep max 1)
    content = re.sub(r'\n\n\n+', '\n\n', content)
    
    return content

def process_dart_files(root_dir):
    """Find and process all .dart files"""
    dart_files = list(Path(root_dir).rglob('*.dart'))
    
    print(f"Found {len(dart_files)} Dart files")
    print("Removing ALL comments including inline comments...\n")
    
    for file_path in dart_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            cleaned_content = remove_all_comments(original_content)
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(cleaned_content)
            
            print(f"✓ {file_path.relative_to(root_dir)}")
        except Exception as e:
            print(f"✗ Error: {file_path.relative_to(root_dir)} - {e}")

if __name__ == '__main__':
    root = r'e:\Flutter\bijoy24_app'
    process_dart_files(root)
    print("\n✓✓✓ ALL comments removed including inline comments! ✓✓✓")
