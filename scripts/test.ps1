param()

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")

$jsFiles = @(
  "payload\src\dictionary\zh-CN.js",
  "payload\src\content\localizer-core.js",
  "payload\src\content\content.js",
  "payload\src\main\menu-localizer.js"
)

foreach ($relativePath in $jsFiles) {
  node --check (Join-Path $root $relativePath) | Out-Null
}

$figBoost = Get-Content -LiteralPath (Join-Path $root "src\FigBoost.ps1") -Raw
$version = (Get-Content -LiteralPath (Join-Path $root "VERSION") -Raw).Trim()
$build = Get-Content -LiteralPath (Join-Path $root "scripts\build.ps1") -Raw
if ($figBoost -notmatch "\`$PatcherVersion = `"$([regex]::Escape($version))`"" -or $build -notmatch "\[string\]\`$Version = `"$([regex]::Escape($version))`"") {
  throw "Patcher version must stay consistent across src, build script, and VERSION."
}
if (-not $build.Contains("-noConsole") -or -not $build.Contains("-noOutput")) {
  throw "FigBoost.exe must be built without a console window."
}
if (-not $figBoost.Contains('Join-Path $env:LOCALAPPDATA "FigBoost"') -or -not $figBoost.Contains('Add-Content -LiteralPath (Join-Path $logDir "FigBoost.log")')) {
  throw "GUI logs must go to a file instead of opening or writing to a console window."
}
if (-not $figBoost.Contains('$Host.Name -eq "ConsoleHost"') -or -not $figBoost.Contains('Write-Log "Self-test passed."')) {
  throw "Compiled command-mode logs must not be shown as no-console message boxes."
}
if (-not $figBoost.Contains("function Test-IsWindows11OrNewer") -or -not $figBoost.Contains("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion") -or -not $figBoost.Contains("CurrentBuildNumber") -or -not $figBoost.Contains("[Environment]::OSVersion.Version.Build -ge 22000") -or -not $figBoost.Contains('$isWindows11OrNewer') -or -not $figBoost.Contains('if ($isWindows11OrNewer)')) {
  throw "Main GUI must keep Windows 11 layout changes behind a Windows 11 build check."
}
if (-not $figBoost.Contains('$form.Width = 900') -or -not $figBoost.Contains('$form.Height = 650') -or -not $figBoost.Contains('$form.MinimumSize = New-Object System.Drawing.Size(860, 630)') -or -not $figBoost.Contains('$btnStatus.Top = 350')) {
  throw "Windows 10 default layout dimensions must remain unchanged."
}
if (-not $figBoost.Contains('$form.Width = 1000') -or -not $figBoost.Contains('$form.Height = 700') -or -not $figBoost.Contains('$currentGroup.Height = 104') -or -not $figBoost.Contains('$btnInstall.Width = 150') -or -not $figBoost.Contains('$btnFeatureManager.Width = 190') -or -not $figBoost.Contains('$form.StartPosition = "Manual"') -or -not $figBoost.Contains('[System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea')) {
  throw "Windows 11 layout must use roomier dimensions and button widths."
}
if (-not $figBoost.Contains("https://api.github.com/repos/HHuiLin/figma-zh-cn-plus/releases/latest") -or -not $figBoost.Contains('$PatcherReleaseAssetName = "FigBoost.exe"') -or -not $figBoost.Contains("function Get-LatestPatcherRelease") -or -not $figBoost.Contains("browser_download_url") -or -not $figBoost.Contains("function Check-PatcherUpdate") -or -not $figBoost.Contains('Compare-VersionString $release.Version $CurrentVersion') -or -not $figBoost.Contains("function Invoke-PatcherSelfUpdate") -or -not $figBoost.Contains('$currentExeLiteral = $currentExe.Replace') -or -not $figBoost.Contains('Copy-Item -LiteralPath ''$tempExeLiteral'' -Destination ''$currentExeLiteral'' -Force') -or -not $figBoost.Contains("Prompt-PatcherUpdateIfAvailable")) {
  throw "FigBoost self-update must use GitHub latest release, FigBoost.exe asset, version compare, and post-exit replacement."
}

function Assert-TextContains {
  param(
    [string]$Text,
    [string]$Needle,
    [string]$Message
  )
  if (-not $Text.Contains($Needle)) {
    throw $Message
  }
}

$dictionary = Get-Content -LiteralPath (Join-Path $root "payload\src\dictionary\zh-CN.js") -Raw
Assert-TextContains $dictionary '"Describe your idea and make it come to life": "描述你的想法，让它变成现实"' "Home Make hero title must use the improved Simplified Chinese translation."
Assert-TextContains $dictionary '"Design a color palette generator with harmony rules and export options.": "设计一个带有配色协调规则和导出选项的配色生成器。"' "Home Make prompt placeholder must be translated."
Assert-TextContains $dictionary '"Start making": "开始制作"' "Home Make primary CTA must be translated."
Assert-TextContains $dictionary '"Build": "构建"' "Make mode picker Build label must be translated."
Assert-TextContains $dictionary '"Create and iterate as you go": "边做边完善"' "Make mode picker Build description must be translated."
Assert-TextContains $dictionary '"Align on complex work for better results": "先梳理复杂需求，获得更好的结果"' "Make mode picker planning description must be translated."
Assert-TextContains $dictionary '"See what''s included": "查看包含内容"' "Plan upsell card title must be translated."
Assert-TextContains $dictionary '"Your plan and usage": "你的套餐和用量"' "Plan upsell card subtitle must be translated."
Assert-TextContains $dictionary '"All files": "所有文件"' "Recents file-type filter must be translated."
Assert-TextContains $dictionary '"All organizations": "所有组织"' "Recents organization filter must be translated."
Assert-TextContains $dictionary '"Recently viewed": "最近查看"' "Recents sort filter must be translated."
Assert-TextContains $dictionary '"Shared files": "共享文件"' "Recents shared files tab must be translated."
Assert-TextContains $dictionary '"Shared projects": "共享项目"' "Recents shared projects tab must be translated."
Assert-TextContains $dictionary '"Site": "站点"' "Top product switcher Site label must be translated."
Assert-TextContains $dictionary '"Beta, Learn more": "Beta，了解更多"' "Make beta link accessible label must be translated."
Assert-TextContains $dictionary '"New file": "新建文件"' "Make tab new file button must be translated."
Assert-TextContains $dictionary '"You can now access unassigned drafts": "你现在可以访问未分配的草稿"' "Unassigned drafts popover title must be translated."
Assert-TextContains $dictionary '"Unassigned drafts are the drafts of users who have left your team. You can move or delete them in your admin settings.": "未分配的草稿来自已离开团队的用户。你可以在管理设置中移动或删除这些草稿。"' "Unassigned drafts popover detail must be translated."
Assert-TextContains $dictionary '"Okay": "好的"' "Common popover confirmation button must be translated."
Assert-TextContains $dictionary '"Add images and files": "添加图片和文件"' "Make add context menu upload item must be translated."
Assert-TextContains $dictionary '"Skills": "技能"' "Make add context skills submenu must be translated."
Assert-TextContains $dictionary '"Enhance prompt": "优化提示词"' "Make enhance prompt button must be translated."
Assert-TextContains $dictionary '"Select a Make kit": "选择 Make 套件"' "Make kit picker button must be translated."
Assert-TextContains $dictionary '"Create with richer context": "用更丰富的上下文创建"' "Make kit tooltip title must be translated."
Assert-TextContains $dictionary '"Kits bring more of your design system into Make. Prototype with the actual code, library styles, and guidelines set by your team.": "套件可以把更多设计系统内容带入 Make。你可以使用团队设置的真实代码、组件库样式和指南来制作原型。"' "Make kit tooltip detail must be translated."
Assert-TextContains $dictionary '"Preview of a design system kit with buttons, labels, and other UI components": "包含按钮、标签和其他界面组件的设计系统套件预览"' "Make kit tooltip preview alt text must be translated."
Assert-TextContains $dictionary '"Design system kits": "设计系统套件"' "Make kit picker title must be translated."
Assert-TextContains $dictionary '"Search all Make kits": "搜索所有 Make 套件"' "Make kit picker search placeholder must be translated."
Assert-TextContains $dictionary '"Sample kit": "示例套件"' "Make kit picker sample kit label must be translated."
Assert-TextContains $dictionary '"Don''t see what you''re looking for?": "没找到你想要的内容？"' "Make kit picker empty hint title must be translated."
Assert-TextContains $dictionary '"Create a kit to use your design system in Make.": "创建一个套件，在 Make 中使用你的设计系统。"' "Make kit picker empty hint detail must be translated."
Assert-TextContains $dictionary '"Create a kit": "创建套件"' "Make kit picker create button must be translated."
Assert-TextContains $dictionary '"Add skill": "添加技能"' "Make skills add dialog title must be translated."
Assert-TextContains $dictionary '"Start making skills": "开始创建技能"' "Make skills add dialog empty title must be translated."
Assert-TextContains $dictionary '"Get started by uploading a SKILL.md file or creating from scratch.": "上传 SKILL.md 文件，或从零开始创建。"' "Make skills add dialog empty detail must be translated."
Assert-TextContains $dictionary '"Upload a file": "上传文件"' "Make skills upload button must be translated."
Assert-TextContains $dictionary '"From scratch": "从零开始"' "Make skills create-from-scratch button must be translated."
Assert-TextContains $dictionary '"Manage skills": "管理技能"' "Make skills manager title must be translated."
Assert-TextContains $dictionary '"Search skills": "搜索技能"' "Make skills manager search placeholder must be translated."
Assert-TextContains $dictionary '"Create a new skill": "创建新技能"' "Make skills manager create icon label must be translated."
Assert-TextContains $dictionary '"Bring custom skills into Figma": "将自定义技能带入 Figma"' "Make skills manager empty title must be translated."
Assert-TextContains $dictionary '"Upload existing SKILL.md files or create from scratch, then use them in chat with": "上传现有 SKILL.md 文件或从零开始创建，然后在对话中用"' "Make skills manager split empty detail must be translated."
Assert-TextContains $dictionary '"Upload existing SKILL.md files or create from scratch, then use them in chat with /skill-name.": "上传现有 SKILL.md 文件或从零开始创建，然后在对话中用 /skill-name 调用。"' "Make skills manager empty detail must be translated."
Assert-TextContains $dictionary '"Add skills": "添加技能"' "Make skills manager add button must be translated."
Assert-TextContains $dictionary '"Dictate": "语音输入"' "Make dictate button must be translated."
Assert-TextContains $dictionary '"Chat mode": "对话模式"' "Make chat mode button must be translated."
Assert-TextContains $dictionary '"Select model": "选择模型"' "Make model picker label must be translated."
Assert-TextContains $dictionary '"Select a model": "选择一个模型"' "Make model picker option label must be translated."
Assert-TextContains $dictionary '"Balanced, efficient": "均衡、高效"' "Make model option description must be translated."
Assert-TextContains $dictionary '"Thorough, uses more credits": "更全面，消耗更多额度"' "Make model option credit description must be translated."
Assert-TextContains $dictionary '"Fast, iterative": "快速、适合迭代"' "Make model option speed description must be translated."
Assert-TextContains $dictionary '"Deep, creative": "深入、富有创造力"' "Make model option creative description must be translated."
Assert-TextContains $dictionary '"Capable, quick": "能力强、响应快"' "Make model option quick description must be translated."
Assert-TextContains $dictionary '"Browser preview not available": "浏览器预览不可用"' "Make local browser preview warning must be translated."
Assert-TextContains $dictionary '"Browser preview not available for this tab": "此标签页无法使用浏览器预览"' "Make local browser preview tab warning must be translated."
Assert-TextContains $dictionary '"Trust this folder": "信任此文件夹"' "Make local trust folder button must be translated."
Assert-TextContains $dictionary '"Do you trust this repository?": "你信任这个仓库吗？"' "Make local trust repository dialog title must be translated."
Assert-TextContains $dictionary '"Trust cloned repository?": "信任克隆的仓库吗？"' "Make local cloned repository dialog title must be translated."
Assert-TextContains $dictionary '"Add to Tab Group": "添加到标签页组"' "Desktop tab group menu item must be translated."
Assert-TextContains $dictionary '"Remove from Tab Group": "从标签页组移除"' "Desktop tab group remove menu item must be translated."
Assert-TextContains $dictionary '"New Tab Group": "新建标签页组"' "Desktop new tab group menu item must be translated."
Assert-TextContains $dictionary '"Close Tab Group": "关闭标签页组"' "Desktop close tab group menu item must be translated."
Assert-TextContains $dictionary '"Move to Another Window": "移动到其他窗口"' "Desktop tab move menu item must be translated."
Assert-TextContains $dictionary '"Open in Browser": "在浏览器中打开"' "Desktop tab browser menu item must be translated."
Assert-TextContains $dictionary '"Separate Split Tabs": "拆分为独立标签页"' "Desktop split tab menu item must be translated."
Assert-TextContains $dictionary '"About this file": "关于这个文件"' "Community resource about-this-file heading must be translated."
Assert-TextContains $dictionary '"About this resource": "关于这个资源"' "Community resource about-this-resource heading must be translated."
Assert-TextContains $dictionary '"About this plugin": "关于这个插件"' "Community plugin about heading must be translated."
Assert-TextContains $dictionary '"About this widget": "关于这个小组件"' "Community widget about heading must be translated."
Assert-TextContains $dictionary '"About this template": "关于这个模板"' "Community template about heading must be translated."
Assert-TextContains $dictionary '"About the creator": "关于创作者"' "Community creator bio heading must be translated."
Assert-TextContains $dictionary '"View creator profile": "查看创作者主页"' "Community creator profile link must be translated."
Assert-TextContains $dictionary '"More from this creator": "这个创作者的更多内容"' "Community more-from-creator heading must be translated."
Assert-TextContains $dictionary '"Leave a comment": "发表评论"' "Community comment box prompt must be translated."
Assert-TextContains $dictionary '"Comment as": "评论身份"' "Community comment identity label must be translated."
Assert-TextContains $dictionary '"View all comments": "查看全部评论"' "Community all comments link must be translated."
Assert-TextContains $dictionary '"Load more comments": "加载更多评论"' "Community comments pagination button must be translated."
Assert-TextContains $dictionary '"Sort by newest": "按最新排序"' "Community comments newest sort must be translated."
Assert-TextContains $dictionary '"Sort by oldest": "按最早排序"' "Community comments oldest sort must be translated."
Assert-TextContains $dictionary '"No comments yet": "还没有评论"' "Community empty comments state must be translated."
Assert-TextContains $dictionary '"Be the first to comment": "抢先发表评论"' "Community first comment prompt must be translated."
Assert-TextContains $dictionary '"Resource actions": "资源操作"' "Community resource action menu label must be translated."
Assert-TextContains $dictionary '"Copy link to resource": "复制资源链接"' "Community copy resource link menu item must be translated."
Assert-TextContains $dictionary '"Copy link to file": "复制文件链接"' "Community copy file link menu item must be translated."
Assert-TextContains $dictionary '"Copy link to prototype": "复制原型链接"' "Community copy prototype link menu item must be translated."
Assert-TextContains $dictionary '"Duplicate in Figma": "在 Figma 中创建副本"' "Community duplicate in Figma button must be translated."
Assert-TextContains $dictionary '"Open page": "打开页面"' "Community preview page menu open item must be translated."
Assert-TextContains $dictionary '"Go to page": "跳转到页面"' "Community preview page navigation item must be translated."
Assert-TextContains $dictionary '"Show pages": "显示页面"' "Community preview page menu show item must be translated."
Assert-TextContains $dictionary '"Hide pages": "隐藏页面"' "Community preview page menu hide item must be translated."
Assert-TextContains $dictionary '"Page menu": "页面菜单"' "Community preview page menu label must be translated."
Assert-TextContains $dictionary '"Page selector": "页面选择器"' "Community preview page selector label must be translated."
Assert-TextContains $dictionary '"Page list": "页面列表"' "Community preview page list label must be translated."
Assert-TextContains $dictionary '["^Page: (.+)$","页面：$1","",true]' "Community preview current page label must translate the Page prefix while preserving the page name."
Assert-TextContains $dictionary '"Page: Cover": "页面：封面"' "Community preview Cover page label must be translated."
Assert-TextContains $dictionary '"Page: Components": "页面：组件"' "Community preview Components page label must be translated."
Assert-TextContains $dictionary '"Page: Mockups": "页面：样机"' "Community preview Mockups page label must be translated."
Assert-TextContains $dictionary '"Page: Wallpapers": "页面：壁纸"' "Community preview Wallpapers page label must be translated."
Assert-TextContains $dictionary '"Page: Artboard & Grids": "页面：画板与网格"' "Community preview Artboard and Grids page label must be translated."
Assert-TextContains $dictionary '"Page: Status & Home bar": "页面：状态栏与主页栏"' "Community preview Status and Home bar page label must be translated."
Assert-TextContains $dictionary '"Page: Camera Control": "页面：相机控制"' "Community preview Camera Control page label must be translated."
Assert-TextContains $dictionary '"Cover": "封面"' "Community preview Cover page menu item must be translated when Figma splits the page selector text."
Assert-TextContains $dictionary '"Camera Control": "相机控制"' "Community preview Camera Control page menu item must be translated when shown as a page name."
Assert-TextContains $dictionary '"Status & Home bar": "状态栏与主页栏"' "Community preview Status and Home bar page menu item must be translated when shown as a page name."
Assert-TextContains $dictionary '"Mockups": "样机"' "Community preview Mockups page menu item must be translated when shown as a page name."
Assert-TextContains $dictionary '"Wallpapers": "壁纸"' "Community preview Wallpapers page menu item must be translated when shown as a page name."
Assert-TextContains $dictionary '"Artboard & Grids": "画板与网格"' "Community preview Artboard and Grids page menu item must be translated when shown as a page name."
Assert-TextContains $dictionary '"Enter fullscreen": "进入全屏"' "Community preview fullscreen button must be translated."
Assert-TextContains $dictionary '"Exit fullscreen": "退出全屏"' "Community preview fullscreen exit button must be translated."
Assert-TextContains $dictionary '"Fit to screen": "适应屏幕"' "Community preview fit button must be translated."
Assert-TextContains $dictionary '"Actual size": "实际大小"' "Community preview actual size button must be translated."
Assert-TextContains $dictionary '"Open prototype": "打开原型"' "Community preview open prototype button must be translated."
Assert-TextContains $dictionary '"View prototype": "查看原型"' "Community preview view prototype button must be translated."
Assert-TextContains $dictionary '"View resource": "查看资源"' "Community view resource button must be translated."
Assert-TextContains $dictionary '"Use this template": "使用这个模板"' "Community use this template button must be translated."

$content = Get-Content -LiteralPath (Join-Path $root "payload\src\content\content.js") -Raw
if ($content -notmatch "if \(!isFigBoostUpdateButtonEnabled\(\)\) return;") {
  throw "Update button observer must not start when the feature is disabled."
}
if ($content -notmatch "observer\.disconnect\(\);") {
  throw "Update button observer must disconnect after the menu is installed."
}
$tabSelectorIndex = $content.IndexOf("[class*='tab_bar']")
if ($tabSelectorIndex -lt 0) {
  throw "Update button must look for the tab bar host."
}
$titlebarHostIndex = $content.IndexOf('if (IS_TITLEBAR_PAGE && document.body) return { element: document.body, placement: "titlebar" };')
if ($titlebarHostIndex -lt 0 -or $titlebarHostIndex -gt $tabSelectorIndex) {
  throw "Update button titlebar placement must take precedence over in-page tab hosts."
}
if ($content.Contains("[class*='top_bar']")) {
  throw "Update button must not fall back to the in-file top bar."
}
if ($content -notmatch "data-placement='tab'") {
  throw "Update button must include the tab bar placement style."
}
if ($content -notmatch "data-placement='titlebar'") {
  throw "Update button must include the titlebar fallback placement style."
}
if ($content -notmatch "right:250px;top:0;border-left:solid 1px var\(--color-bordertranslucent\);border-right:solid 1px var\(--color-bordertranslucent\)") {
  throw "Update button titlebar placement must sit on the native titlebar button grid."
}
if ($content -notmatch "data-overlapped='true'\]\{visibility:hidden;pointer-events:none;\}" -or $content -notmatch "function syncTitlebarButtonVisibility\(wrap\)" -or $content -notmatch "document\.elementsFromPoint" -or $content -notmatch "window\.addEventListener\(`"resize`", schedule\);") {
  throw "Update button titlebar placement must hide when it overlaps native controls."
}
if ($content -notmatch "SHOULD_INSTALL_UPDATE_BUTTON = IS_TEST_PAGE \|\| \(IS_TITLEBAR_PAGE && !IS_FIGMA_PAGE\)") {
  throw "Update button must not install inside figma.com content pages."
}
if ($content -notmatch "width:50px;height:38px") {
  throw "Update button visual hit area must match the native titlebar caption button."
}
if ($content -notmatch "min-width:0;min-height:0") {
  throw "Update button must neutralize inherited button minimum sizes."
}
if ($content -notmatch "\.figboost-menu-wrap\[data-placement='titlebar'\] \.figboost-menu-button\{background-color:unset;display:flex;align-items:center;justify-content:center;width:50px;height:38px;-webkit-app-region:no-drag;color:var\(--color-text-secondary\);fill:var\(--color-text-secondary\);--fpl-icon-color:var\(--color-text-secondary\);pointer-events:bounding-box;cursor:default;\}") {
  throw "Update button titlebar placement must reuse the native caption button style."
}
if ($content -notmatch "border-radius:0") {
  throw "Update button hover radius must match the native titlebar ghost style."
}
if ($content -notmatch "data-hover-suppressed='true'" -or $content -notmatch "background-color:var\(--color-bghovertransparent\)!important") {
  throw "Update button hover state must match the native titlebar caption button style."
}
if ($content -notmatch "\.figboost-menu-wrap\[data-placement='titlebar'\] \.figboost-menu-button:active,\.figboost-menu-wrap\[data-placement='titlebar'\] \.figboost-menu-button\[aria-expanded='true'\],\.figboost-menu-wrap\[data-placement='titlebar'\] \.figboost-menu-button\[aria-pressed='true'\]\{background-color:var\(--color-bgtransparent-secondary-hover\)!important;color:var\(--color-text\)!important;fill:var\(--color-text\)!important;--fpl-icon-color:var\(--color-text\)!important;\}") {
  throw "Update button titlebar states must override native/global button styles."
}
if ($content -notmatch "appearance:none;-webkit-appearance:none;outline:0;box-shadow:none;transform:none;-webkit-app-region:no-drag") {
  throw "Update button must use native titlebar button interaction behavior."
}
if ($content -notmatch "\.figboost-menu-button:active\{background:#424242;color:#d6d6d6;box-shadow:none;transform:none;\}") {
  throw "Update button active state must match the native titlebar hover state."
}
if ($content -notmatch "\.figboost-menu-button:focus-visible\{outline:1px solid #6a6a6a;outline-offset:-1px;\}") {
  throw "Update button focus-visible state must avoid the browser default blue outline."
}
if ($content -match 'button\.setAttribute\("aria-pressed", "true"\)') {
  throw "Update button titlebar click must not leave a persistent selected highlight."
}
if ($content -notmatch "resetFigBoostButtonState\(button\)" -or $content -notmatch 'button\.blur\(\)' -or $content -notmatch 'figboost:feature-menu-closed' -or $content -notmatch "suppressFigBoostButtonHover\(button\)" -or $content -notmatch "wrap\.dataset\.hoverSuppressed = `"true`"" -or $content -notmatch 'document\.addEventListener\("pointermove", release, true\)') {
  throw "Update button titlebar menu close must clear the button ghost state."
}
if ($content -notmatch "getFigBoostFeatureMenuBridge\(\)" -or $content -notmatch "getFigBoostMenuBounds\(button\)" -or $content -notmatch "bridge\(bounds\)" -or $content -notmatch "figboost://open-feature-menu") {
  throw "Update button titlebar placement must open the native feature menu bridge with button bounds."
}
if ($content -notmatch "getFigBoostBulkExportBridge\(\)" -or $content -notmatch "bulk-export-files" -or $content -notmatch "批量导出画板文件" -or $content -notmatch "visible: \(\) => Boolean\(getFigBoostBulkExportBridge\(\)") {
  throw "Update button fallback menu must expose batch file export."
}
if ($content -match "await bridge\(getFigBoostMenuBounds\(button\)\)") {
  throw "Update button titlebar click must not wait for the native menu to close."
}
if ($content -match "setTimeout\(\(\) => \{\s*resetFigBoostButtonState\(button\);") {
  throw "Update button titlebar click must keep the pressed state until the native menu closes."
}
if ($content -notmatch "toggleFigBoostMenu\(wrap\);") {
  throw "Update button click must fall back to the shared DOM feature menu."
}
if ($content -notmatch "result && result\.ok === false" -or $content -notmatch "\.then\(\(result\) =>" -or $content -notmatch "toggleFigBoostMenu\(wrap\);") {
  throw "Update button titlebar click must use the shared DOM menu when native menu opening fails."
}
if ($content -match "titlebarUpdateBusy" -or $content -match "await FIGBOOST_MENU_ITEMS\[0\]\.run\(\);" -or $content -match "button\.disabled = true") {
  throw "Update button titlebar click must not bypass the feature menu or trigger disabled browser styles."
}
if ($content -notmatch "\.figboost-menu-wrap\[data-placement='titlebar'\] \.figboost-menu-panel\{top:44px;right:0;min-width:168px;padding:6px 0;border:1px solid rgba\(255,255,255,\.08\);border-radius:10px;background:#252525;color:#f1f1f1;box-shadow:0 10px 28px rgba\(0,0,0,\.35\);\}") {
  throw "Update button titlebar menu must use a dark feature selection popup."
}
if ($content -notmatch "svg\{width:14px;height:14px" -or $content -notmatch 'stroke-width="0\.9"') {
  throw "Update button icon must be slightly larger with a lighter stroke."
}

$main = Get-Content -LiteralPath (Join-Path $root "payload\src\main\menu-localizer.js") -Raw
if ($main -notmatch 'ipcMain\.handle\("figboost:open-feature-menu"' -or $main -notmatch "Menu\.buildFromTemplate\(buildFigBoostFeatureMenuTemplate\(\)\)" -or $main -notmatch 'label: "检查更新"') {
  throw "Main process must expose a native FigBoost feature menu."
}
if ($figBoost -notmatch 'Id = "bulk-export-figma-files"' -or $figBoost -notmatch 'Install-Feature "bulk-export-figma-files"' -or $figBoost -notmatch 'Uninstall-Feature "bulk-export-figma-files"') {
  throw "Feature manager must expose install/uninstall for board scan and batch export."
}
if ($main -notmatch 'figboost:bulk-export-files' -or $main -notmatch '\\u6279\\u91cf\\u5bfc\\u51fa\\u753b\\u677f\\u6587\\u4ef6\.\.\.' -or $main -notmatch "function bulkExportFigmaFiles" -or $main -notmatch "createTimestampExportDir" -or $main -notmatch "showOpenDialog" -or $main -notmatch "failed\.push" -or $main -notmatch 'isFigBoostFeatureEnabled\("bulk-export-figma-files"\)') {
  throw "Native FigBoost feature menu must include batch .fig export with timestamp folder, path selection, and failure summary."
}
if ($main -notmatch "function showBulkExportSelectionWindow" -or $main -notmatch "selectAll" -or $main -notmatch "selectNone" -or $main -notmatch "keys: Array\.from\(selected\)" -or $main -notmatch "getFigmaPageCategory" -or $main -notmatch "projectPath" -or $main -notmatch "collapsed" -or $main -notmatch "\\\\u25b6") {
  throw "Batch .fig export must show a project-categorized selectable file list with select-all and collapse controls."
}
if ($main -notmatch "showInactive" -or $main -notmatch "createFigmaExportContext" -or $main -notmatch "moveExportWindowToBackground" -or $main -notmatch 'postMessageToActiveWebBinding\("' -or $main -notmatch "save-as" -or $main -notmatch "maxPages = 90" -or $main -notmatch "scanTargets") {
  throw "Batch .fig export must reduce foreground disruption, expand scanning, and reuse a background export context."
}
if ($main -notmatch "function suppressUtilityWindowMenuBar" -or $main -notmatch "setMenuBarVisibility\(false\)" -or $main -notmatch "progressWindow\.on\(`"show`"" -or $main -notmatch "selectionWindow\.on\(`"show`"") {
  throw "Batch .fig export utility windows must hide the native menu bar after showing."
}
if ($main -notmatch "function formatDuration" -or $main -notmatch "startedAt: exportStartedAt" -or -not $main.Contains('\\u5df2\\u7528\\u65f6') -or -not $main.Contains('\u5bfc\u51fa\u8017\u65f6') -or $main -notmatch "durationMs: exportDurationMs") {
  throw "Batch .fig export must show elapsed time and report final duration."
}
if ($main -match 'https://www\.figma\.com/files/drafts') {
  throw "Batch .fig export scan must not include Drafts pages."
}
if ($main -match 'https://www\.figma\.com/files/recent') {
  throw "Batch .fig export scan must not include Recent pages."
}
if ($main -notmatch "function getFigmaFileBrowserUrlsFromSettings" -or $main -notmatch "settings\.json" -or $main -notmatch "all-projects" -or $main -notmatch "function isFigmaProjectOverviewPage") {
  throw "Batch .fig export scan must use Figma's saved all-projects file browser path and ignore project overview cache links."
}
if ($main -notmatch "function getFigmaTeamIdsFromSettings" -or $main -notmatch "fetchFigmaTeamProjectsAndFilesViaRest" -or $main -notmatch "/v1/teams/" -or $main -notmatch "/v1/projects/" -or $main -notmatch "fetchFigmaTeamProjectsViaLiveGraph" -or $main -notmatch "FileBrowserTeamPageProjectsView" -or $main -notmatch "PaginatedFilesByProjectAndEditorTypeView") {
  throw "Batch .fig export scan must use fast team/project APIs first and fall back to LiveGraph project views."
}
if ($main -notmatch "recents-and-sharing\|deleted\|trash\|community" -or $main -match 'recents-and-sharing\?fuid') {
  throw "Batch .fig export scan must exclude recents-and-sharing and other non-project browser pages."
}
if ($main -notmatch 'editorType === "design" \|\| editorType === 0' -or $main -match 'editorType === undefined \|\| editorType === null \|\| editorType === "design"') {
  throw "Batch .fig export scan must not treat unknown editor types as Figma Design files."
}
if ($main -notmatch "path !== `"design`"" -or -not $main.Contains('/(?:file|design)\/([A-Za-z0-9]+)')) {
  throw "Batch .fig export must filter non-Design file types before exporting local .fig copies."
}
if ($main -notmatch "const isDesign = editorType === `"design`" \|\| editorType === 0;" -or $main -notmatch "projectPathFromPage" -or $main -notmatch "collectSnapshot" -or $main -notmatch "for \(let index = 0; index < 14") {
  throw "Batch .fig export fast page scan must accumulate scrolled project/file rows and keep only design files."
}
if ($main -notmatch "function createFigmaScanTarget" -or $main -notmatch "openInBackground: false" -or $main -notmatch "figboost-bulk-scan" -or $main -notmatch "activeJobs" -or $main -notmatch "getFigmaScanTargetWebContents" -or $main -notmatch "scanDeadline" -or $main -notmatch "function isExpectedFigmaScanUrl") {
  throw "Batch .fig export scan must use real Figma background windows and parallel queue workers."
}
if ($main -notmatch "function shouldReadVisibleFigmaPage" -or $main -notmatch "desktop_new_tab" -or $main -notmatch "team_id" -or $main -notmatch "project_id" -or $main -notmatch "webContents\.getAllWebContents\(\)" -or $main -notmatch "shouldReadVisibleFigmaPage\(currentUrl\)" -or $main -notmatch "readFigmaPageLinksFast" -or $main -notmatch "\\u6587\\u4ef6" -or $main -notmatch "elementFromPoint\(point\.x, point\.y\)") {
  throw "Batch .fig export scan must read visible All Projects pages while filtering drafts, recent, and new-tab cache pages."
}
if ($main -notmatch "function waitForDownloadToPath" -or $main -notmatch 'session\.once\("will-download"' -or $main -notmatch "item\.setSavePath\(targetPath\)" -or $main -notmatch "function openFigmaFileInDesktop" -or $main -notmatch "Open File URL From Clipboard" -or $main -notmatch "function withSaveDialogTarget" -or $main -notmatch "dialog\.showSaveDialog = async" -or $main -notmatch "function triggerFigmaSaveLocalCopy" -or $main -notmatch "Save Local Copy" -or $main -match "function findSaveLocalCopyMenuItem" -or $main -match "clickFigmaMainMenu") {
  throw "Batch .fig export must open real Figma tabs, invoke native Save Local Copy, and intercept the save/download path."
}
if ($main -notmatch "postMessageToActiveWebBinding\(`"handleAction`", `"save-as`", `"os-menu`"\)" -or $main -notmatch "let exportContext = createFigmaExportContext\(owner\)" -or $main -notmatch "exportContext = createFigmaExportContext\(owner\)" -or $main -notmatch "stage: `"file-failed`"") {
  throw "Batch .fig export must trigger background save directly and rebuild the export context after failures."
}
if ($main -notmatch "findOwnerWindowForWebContents" -or $main -notmatch "window\.getBrowserViews\(\)" -or $main -notmatch "BrowserWindow\.getFocusedWindow\(\)" -or $main -notmatch "normalizeFigBoostMenuBounds" -or $main -notmatch "popupOptions\.x = point\.x" -or $main -notmatch "__FIGBOOST_ACTIVE_FEATURE_MENUS__" -or $main -notmatch "__FIGBOOST_OPEN_FEATURE_MENU__ = openFigBoostFeatureMenu" -or $main -notmatch "menu\.popup\(popupOptions\)") {
  throw "Native FigBoost feature menu must bind to the owning BrowserWindow and button position."
}
if ($main -notmatch "getOwnerBrowserWindow" -or $main -notmatch "figBoostViewOwnsWebContents" -or $main -notmatch "window\.contentView" -or $main -notmatch "webContents\.getFocusedWebContents" -or $main -notmatch "function popupFigBoostFeatureMenu" -or $main -notmatch "menu\.popup\.length > 1" -or $main -notmatch "menu\.popup\(owner, point\.x, point\.y, undefined, onClosed\)") {
  throw "Native FigBoost feature menu must support old Electron popup signatures and newer contentView ownership."
}
if ($main -notmatch "parseFigBoostMenuBoundsFromUrl" -or $main -notmatch "openMenu\(contents, parseFigBoostMenuBoundsFromUrl\(url\)\)") {
  throw "Native FigBoost feature menu fallback URL must keep the button position."
}
if ($main -notmatch "dispatchFeatureMenuClosed" -or $main -notmatch "figboost:feature-menu-closed" -or $main -notmatch "if \(sender\) dispatchFeatureMenuClosed\(sender\)") {
  throw "Native FigBoost feature menu must notify the renderer when the popup closes."
}

if ($main -notmatch "function showOfficialUpdateCheckingWindow" -or $main -notmatch "\\u6b63\\u5728\\u68c0\\u67e5\\u66f4\\u65b0" -or $main -notmatch "const checkingWindow = showOfficialUpdateCheckingWindow\(\)" -or $main -notmatch "checkingWindow\.close\(\)") {
  throw "Manual update check must show and close a checking progress dialog."
}
if ($main -notmatch "const looksLikeOptions" -or $main -notmatch "const optionIndex = looksLikeOptions\(args\[1\]\) \? 1 : 0;") {
  throw "Dialog localization hook must not mistake BrowserWindow arguments for message box options."
}
if ($main -notmatch "useContentSize: true" -or $main -notmatch "autoHideMenuBar: true" -or $main -notmatch "removeMenu" -or $main -notmatch "overflow:hidden") {
  throw "Manual update checking dialog must hide menus and avoid clipped scrollable content."
}
if ($main -notmatch "__FIGBOOST_SKIP_RENDERER_INJECTION__" -or $main -notmatch "if \(contents\.__FIGBOOST_SKIP_RENDERER_INJECTION__\) return;" -or $main -match 'class="icon"' -or $main -match "\.icon\{") {
  throw "Manual update checking dialog must not receive injected buttons or extra body icons."
}

$core = Get-Content -LiteralPath (Join-Path $root "payload\src\content\localizer-core.js") -Raw
if ($core -notmatch "MAX_TRANSLATION_CACHE_SIZE") {
  throw "Translation cache must have a bounded size."
}
if ($core -notmatch "cache\.delete\(cache\.keys\(\)\.next\(\)\.value\)") {
  throw "Translation cache must evict the oldest entry at the size limit."
}
if ($core -notmatch 'const ICON_ONLY_TRANSLATABLE_ATTRS = new Set\(\["aria-label", "title"\]\)' -or $core -notmatch 'isIconOnlyControlElement\(element\) && !ICON_ONLY_TRANSLATABLE_ATTRS\.has\(name\)') {
  throw "Icon-only button aria labels and titles must be translated for tooltips and secondary controls."
}
if ($core -notmatch "function isCommunityPreviewPageControlElement" -or $core -notmatch "isCommunityPreviewPageControlElement\(parent, node\.nodeValue\)" -or $core -notmatch "PREVIEW_PAGE_MENU_TERMS") {
  throw "Community preview page controls inside Figma viewport/canvas wrappers must not be skipped as canvas content."
}
if ($core -notmatch "return Boolean\(element\.closest\(FIGMA_VIEWPORT_SKIP_SELECTOR\) && \/\^Page:\/\.test\(text\)\);") {
  throw "Community preview page control fallback must not translate ordinary canvas text just because a nearby page menu exists."
}

Write-Host "All tests passed."
