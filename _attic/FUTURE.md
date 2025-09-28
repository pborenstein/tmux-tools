# Future Improvements

## Minor Issues

1. **Client data error handling missing**: `tmux list-clients` could fail but has no error check (line 306)

2. **Window name uniqueness**: Animals can repeat across sessions (which is intended), but might confuse users initially

3. **Column width constraints**:
   - Session names >13 chars will break alignment
   - Window names >8 chars will break alignment
   - Commands >7 chars will break alignment

4. **Path truncation**: Very long paths aren't truncated and may wrap

## Enhancement Opportunities

1. **Performance**: Could cache client data instead of grep-searching repeatedly

2. **Robustness**: Could add tmux version compatibility checks

3. **Usability**: Could add `--version` flag

4. **Formatting**: Could add color support for better visual separation

