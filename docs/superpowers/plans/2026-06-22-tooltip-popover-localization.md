# Tooltip Popover Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Translate the screenshot's unassigned-drafts popover and improve the existing untranslated-English scan so current-page UI English can be collected and added to the dictionary.

**Architecture:** Keep the existing dictionary-first localization model. Add exact dictionary entries for confirmed UI strings, then add a tiny scan test and minimal scan changes only if current behavior misses popover/dialog/button text.

**Tech Stack:** JavaScript content scripts, PowerShell project tests, GitHub CLI for push.

---

## File Structure

- Modify: `scripts/test.ps1`
  - Add assertions that the new unassigned-drafts popover strings exist in the dictionary.
  - Add scan-related assertions only for existing scanner behavior that should be preserved or lightly enhanced.
- Modify: `payload/src/dictionary/zh-CN.js`
  - Add exact translations for confirmed Figma UI strings found in the screenshot and page scan.
- Modify if needed: `payload/src/content/localizer-core.js`
  - Keep scan categories and user-content protection intact.
  - Lightly improve current-page scan coverage for popover/dialog/button text if the scan result shows it is needed.
- Create if needed: `work/figma-untranslated-scan.json`
  - Store a local scratch copy of scan output for analysis. This is not a deliverable and should not be committed.

## Task 1: Add Failing Dictionary Coverage Test

**Files:**
- Modify: `scripts/test.ps1`

- [ ] **Step 1: Add dictionary assertions before implementation**

Add these checks near the existing dictionary assertions:

```powershell
Assert-TextContains $dictionary '"You can now access unassigned drafts": "你现在可以访问未分配的草稿"' "Unassigned drafts popover title must be translated."
Assert-TextContains $dictionary '"Unassigned drafts are the drafts of users who have left your team. You can move or delete them in your admin settings.": "未分配的草稿来自已离开团队的用户。你可以在管理设置中移动或删除这些草稿。"' "Unassigned drafts popover detail must be translated."
Assert-TextContains $dictionary '"Okay": "好的"' "Common popover confirmation button must be translated."
```

- [ ] **Step 2: Run the test and verify it fails**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

Expected: FAIL with `Unassigned drafts popover title must be translated.` or the detail assertion.

## Task 2: Add Exact Dictionary Entries

**Files:**
- Modify: `payload/src/dictionary/zh-CN.js`

- [ ] **Step 1: Add minimal exact translations**

Add entries to the `exact` object:

```javascript
"You can now access unassigned drafts": "你现在可以访问未分配的草稿",
"Unassigned drafts are the drafts of users who have left your team. You can move or delete them in your admin settings.": "未分配的草稿来自已离开团队的用户。你可以在管理设置中移动或删除这些草稿。",
```

- [ ] **Step 2: Run the test and verify it passes for these assertions**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

Expected: PASS or fail only on a later, unrelated new assertion added in a later task.

## Task 3: Scan The Current Figma Page For More UI English

**Files:**
- Create if useful: `work/figma-untranslated-scan.json`

- [ ] **Step 1: Try to collect scan output from the active real Figma page**

Use the existing runtime function when reachable:

```javascript
window.__figmaZhScanUntranslated && window.__figmaZhScanUntranslated({ limit: 300 })
```

Expected: JSON with `items`, `counts`, and UI strings if the real Figma page is reachable.

- [ ] **Step 2: If runtime JS is unreachable, collect visible English from screenshot/manual inspection**

Use only visible UI text from the provided screenshot and any accessible Figma window screenshot. Do not treat team names, file names, or user names as dictionary entries.

- [ ] **Step 3: Classify strings**

Only add dictionary entries for stable UI text such as buttons, labels, help text, popovers, tooltips, and banners. Skip user-specific content such as `霖's team`, project names, file names, email addresses, URLs, and generated timestamps.

## Task 4: Add Scan-Discovered Dictionary Entries

**Files:**
- Modify: `scripts/test.ps1`
- Modify: `payload/src/dictionary/zh-CN.js`

- [ ] **Step 1: Add failing assertions for confirmed scan-discovered UI strings**

For each confirmed UI string, add one `Assert-TextContains` check.

- [ ] **Step 2: Run the test and verify it fails**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

Expected: FAIL on the first newly asserted missing string.

- [ ] **Step 3: Add exact dictionary entries**

Add only the confirmed UI entries to `payload/src/dictionary/zh-CN.js`.

- [ ] **Step 4: Run the test and verify it passes**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

Expected: PASS.

## Task 5: Lightly Improve Scan Coverage If Needed

**Files:**
- Modify if needed: `payload/src/content/localizer-core.js`
- Modify: `scripts/test.ps1`

- [ ] **Step 1: Identify the smallest scanner gap**

If current-page scan misses text that is visibly in popovers/dialogs/buttons, identify whether the missing source is a text node, `aria-label`, `title`, or `placeholder`.

- [ ] **Step 2: Add a failing static assertion for the scanner capability**

Use `scripts/test.ps1` to assert the relevant selector or scan path exists, for example:

```powershell
if ($core -notmatch "role='dialog'" -or $core -notmatch "role='tooltip'" -or $core -notmatch "scanUntranslated") {
  throw "Untranslated scan must inspect dialog and tooltip UI text."
}
```

- [ ] **Step 3: Run the test and verify it fails if a scanner change is required**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

Expected: FAIL only if the scanner is missing the required coverage.

- [ ] **Step 4: Make the minimal scanner change**

Update the existing scan logic, keeping `userContent`, `protected`, and `canvas` categories intact.

- [ ] **Step 5: Run the test and verify it passes**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

Expected: PASS.

## Task 6: Build, Real Figma Verification, Commit, Push

**Files:**
- Modify generated if build succeeds: `FigBoost.exe`

- [ ] **Step 1: Run full automated test**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

Expected: `All tests passed.`

- [ ] **Step 2: Build updated executable if runtime payload changed**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\build.ps1
```

Expected: build completes and updates `FigBoost.exe`.

- [ ] **Step 3: Try real Figma Desktop verification**

Apply the updated patch using the normal project flow, open real Figma Desktop, scan or inspect the relevant team page, and capture a screenshot if the UI can be reached.

- [ ] **Step 4: Commit**

Run:

```powershell
git status --short
git add -- scripts/test.ps1 payload/src/dictionary/zh-CN.js payload/src/content/localizer-core.js FigBoost.exe docs/superpowers/plans/2026-06-22-tooltip-popover-localization.md
git commit -m "补齐小弹窗汉化词条"
```

- [ ] **Step 5: Push**

Run:

```powershell
git push origin main
```

Expected: push succeeds. If it fails, report the exact blocker and leave the local commit ready.
