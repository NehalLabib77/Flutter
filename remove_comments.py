import os
import re
from pathlib import Path

def remove_comments(content):
    """Remove all types of comments from Dart code"""
    
    # Remove multi-line comments /* ... */
    content = re.sub(r'/\*[\s\S]*?\*/', '', content)
    
    # Remove single-line comments //
    lines = content.split('\n')
    cleaned_lines = []
    
    for line in lines:
        # Find // comment (but not in strings)
        in_string = False
        in_single_quote = False
        result = []
        i = 0
        
        while i < len(line):
            # Handle strings and quotes
            if line[i] == '"' and (i == 0 or line[i-1] != '\\'):
                in_string = not in_string
                result.append(line[i])
            elif line[i] == "'" and (i == 0 or line[i-1] != '\\'):
                in_single_quote = not in_single_quote
                result.append(line[i])
            # Check for comment marker
            elif not in_string and not in_single_quote and i < len(line) - 1 and line[i:i+2] == '//':
                break
            else:
                result.append(line[i])
            i += 1
        
        cleaned_line = ''.join(result).rstrip()
        if cleaned_line or not cleaned_lines or cleaned_lines[-1]:  # Keep empty lines for readability
            cleaned_lines.append(cleaned_line)
    
    content = '\n'.join(cleaned_lines)
    
    # Remove multiple consecutive empty lines (keep max 1)
    content = re.sub(r'\n\n+', '\n\n', content)
    
    return content

def process_dart_files(root_dir):
    """Find and process all .dart files"""
    dart_files = list(Path(root_dir).rglob('*.dart'))
    
    print(f"Found {len(dart_files)} Dart files")
    
    for file_path in dart_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            cleaned_content = remove_comments(original_content)
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(cleaned_content)
            
            print(f"✓ Processed: {file_path.relative_to(root_dir)}")
        except Exception as e:
            print(f"✗ Error processing {file_path}: {e}")

if __name__ == '__main__':
    root = r'e:\Flutter\bijoy24_app'
    process_dart_files(root)
    print("\n✓ All comments removed!")
