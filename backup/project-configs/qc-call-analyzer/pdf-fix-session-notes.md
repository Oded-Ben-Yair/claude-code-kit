# PDF Font Fix Session Notes - Dec 23, 2025

## Problem Statement
Hebrew PDF export shows white boxes (□) instead of timestamps, numbers, and Latin characters.

## Root Cause Analysis
Hebrew font files (NotoSansHebrew) are only 15KB - they are **subsets** that lack Latin/number glyphs.
Arabic font files (NotoSansArabic) are 240KB - they include full Latin support.

## Attempts Made

### V3.4 (Failed)
- **What**: Removed Roboto fallback, used only Noto fonts
- **Result**: Hebrew PDF shows boxes for all Latin characters (timestamps, filenames, numbers)
- **Why failed**: Hebrew font subset doesn't include Latin glyphs

### V3.5 (Partially Failed)
- **What**: Added Roboto fonts for Latin/numbers, used inline font segmentation in text arrays
- **Files modified**:
  - `src/ui/src/lib/pdf-generator.ts`
  - Added `/public/fonts/Roboto-Regular.ttf` and `Roboto-Bold.ttf`
- **Approach**: Text arrays with inline fonts like:
  ```typescript
  text: [
    { text: 'קובץ: ', font: 'NotoSansHebrew' },
    { text: call.filename, font: 'Roboto' },
  ],
  style: 'metadata',  // metadata style has font: 'Roboto'
  ```
- **Result**:
  - Hebrew text renders ✅
  - Page footer (pure Roboto) renders ✅
  - BUT inline font segments in text arrays DON'T work - Latin shows as boxes ❌
- **Why failed**: pdfmake style's `font` property appears to override inline font specifications in text arrays

## Visual Validation Results (V3.5)

| Element | Status | Notes |
|---------|--------|-------|
| Title "דוח ניתוח שיחה" | ✅ Works | NotoSansHebrew via style |
| Hebrew transcript text | ✅ Works | NotoSansHebrew via style |
| Page footer "Page 1 of 14" | ✅ Works | Roboto via style |
| Metadata (filename, duration, date) | ❌ BOXES | Inline fonts not working |
| Speaker timestamps | ❌ BOXES | Inline fonts not working |
| Speaker labels (נציג, לקוח) | ✅ Works | NotoSansHebrew inline works |

## Key Insight
- When a **style** specifies a `font`, it may override inline font specifications in text arrays
- The Hebrew inline font (`{ text: 'קובץ:', font: 'NotoSansHebrew' }`) works
- BUT the Roboto inline font (`{ text: '27:04', font: 'Roboto' }`) shows boxes
- This suggests pdfmake has an issue with inline fonts when the style also specifies a font

## Next Steps for V3.6

### Option A: Remove font from styles (Recommended - try first)
Remove `font` property from styles that use text arrays with mixed fonts:
```typescript
metadata: {
  fontSize: 10,
  color: '#94a3b8',
  margin: [0, 0, 0, 15],
  alignment: 'center',
  // NO font here - let inline fonts take precedence
},
```

### Option B: Use columns for mixed content
Instead of text arrays, use columns layout:
```typescript
{
  columns: [
    { text: 'קובץ: ', font: 'NotoSansHebrew', width: 'auto' },
    { text: call.filename, font: 'Roboto', width: 'auto' },
  ],
}
```

### Option C: Use table for metadata row
```typescript
{
  table: {
    body: [[
      { text: 'קובץ:', font: 'NotoSansHebrew' },
      { text: call.filename, font: 'Roboto' },
    ]],
  },
  layout: 'noBorders',
}
```

### Option D: Build separate elements per font
```typescript
content.push({ text: 'קובץ: ', font: 'NotoSansHebrew', ... });
content.push({ text: call.filename, font: 'Roboto', ... });
```

## Files to Modify
- `/home/odedbe/projects/qc-call-analyzer/src/ui/src/lib/pdf-generator.ts`

## Styles that need fixing (have font + are used with text arrays)
1. `metadata` (line 222-227) - used for mixed Hebrew labels + Latin values
2. `speakerRep` (line 246-251) - used for Hebrew label + Latin timestamp
3. `speakerClient` (line 252-257) - used for Hebrew label + Latin timestamp

## Test Commands
```bash
cd ~/projects/qc-call-analyzer/src/ui
npm run build
swa deploy ./dist --deployment-token <token>

# Then test in browser and convert PDF to image:
pdftoppm -png -r 150 /path/to/pdf /tmp/output
```

## Deployment Info
- **UI**: https://icy-coast-0265d5310.3.azurestaticapps.net/
- **SWA Deploy Token**: Get via `az staticwebapp secrets list --name icy-coast-0265d5310 -g AZAI_group --query "properties.apiKey" -o tsv`
