# 小弹窗和小提示汉化优化设计

## 背景

阿霖在 Figma Desktop 首页截图里发现还有英文小弹窗没有汉化。截图中的漏翻包括：

- `You can now access unassigned drafts`
- `Unassigned drafts are the drafts of users who have left your team. You can move or delete them in your admin settings.`
- `Okay`

项目当前已经有一套词库和页面替换逻辑：

- `payload/src/dictionary/zh-CN.js` 像一本英文到中文的字典。
- `payload/src/content/localizer-core.js` 负责在 Figma 页面里找到英文并替换。
- `payload/src/content/content.js` 已经暴露 `window.__figmaZhScanUntranslated`，可以扫描页面中还没翻译的英文。

这次目标不是大改架构，而是先修眼前的小弹窗，再让后续找同类漏翻更容易。

## 目标

1. 截图中的未分配草稿弹窗应显示中文。
2. 继续保护用户自己的文件名、项目名、团队名，不能乱翻用户内容。
3. 强化现有漏翻扫描能力，让它更适合发现弹窗、小提示、按钮和属性文字里的英文。
4. 保持改动小，优先复用现有词库、扫描器和测试脚本。

## 非目标

1. 不重做整个汉化系统。
2. 不引入联网翻译或 AI 自动翻译。
3. 不批量删除任何文件或目录。
4. 不改变 Figma 画布内容、用户文件名、用户项目名等用户自己输入的内容。

## 方案选择

### 方案 A：只补截图词条

优点是最快，风险最低。缺点是后续遇到新的小弹窗，仍然需要靠截图人工补词。

### 方案 B：主要增强漏翻扫描

优点是长期更省事。缺点是截图里的弹窗不一定马上变中文，还需要再补词。

### 方案 C：先补词，再轻量增强扫描

这是本次采用的方案。先把截图里的弹窗补成中文，再让现有扫描器更容易发现弹窗、小提示、按钮、`aria-label`、`title`、`placeholder` 等位置的英文。它兼顾立刻见效和后续维护。

## 设计

### 词库补齐

在 `payload/src/dictionary/zh-CN.js` 里补充精确词条：

- `You can now access unassigned drafts` -> `你现在可以访问未分配的草稿`
- `Unassigned drafts are the drafts of users who have left your team. You can move or delete them in your admin settings.` -> `未分配的草稿来自已离开团队的用户。你可以在管理设置中移动或删除这些草稿。`
- 保留已有的 `Okay` -> `好的`
- 如测试发现弹窗按钮或链接还有变体，再补最小必要词条，比如 `Admin settings`、`Move or delete` 这类真实出现的界面文案。

### 漏翻扫描增强

现有 `scanUntranslated` 已能扫描文本节点和部分属性。增强方向是轻量补强，不另起一套系统：

1. 扫描结果继续分为 `ui`、`protected`、`canvas`、`userContent`。
2. 对弹窗、菜单、提示类容器提高关注度，包括 `role="dialog"`、`role="tooltip"`、`role="menu"`、`data-testid` 中带 `popover` 或 `tooltip` 的元素。
3. 对按钮、小提示常见属性继续检查 `aria-label`、`title`、`placeholder`。
4. 扫描结果中保留元素路径和属性名，方便以后知道英文来自哪里。
5. 不把用户文件名、项目名、团队名当成必须翻译的界面英文。

### 测试与验证

自动验证：

1. 运行 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1`。
2. 必要时补充测试断言，确保新词条存在。
3. 运行 `node --check` 覆盖改到的 JavaScript 文件。

真实 Figma 验证：

1. 构建更新后的 `FigBoost.exe`，如果本次代码改动影响打包内容。
2. 用项目正常流程把补丁安装到真实 Figma Desktop。
3. 打开真实 Figma Desktop，尽量复现或接近截图里的团队首页弹窗。
4. 截图确认相关弹窗和按钮显示中文。
5. 如果无法复现该弹窗或无法启动真实客户端，要在交付时说明卡在哪一步，并提供已完成的自动验证结果。

## 成功标准

1. 截图里这个未分配草稿弹窗的标题、正文和按钮有对应中文词条。
2. 漏翻扫描器能继续返回还没翻译的 UI 英文，并且不会把用户命名内容当成必须翻译。
3. 项目测试通过。
4. 修改被提交到 Git，并按项目要求推送到 GitHub；如果推送失败，要保留本地提交并说明原因。
