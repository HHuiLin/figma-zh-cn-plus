# Figma 简体中文增强版

这是基于 [Hoae2002/Figma-CN](https://github.com/Hoae2002/Figma-CN) 的增强版，目标是继续补齐官方原生 Figma Desktop 客户端里的简体中文界面。

它仍然是基于官方原生客户端的补丁程序，不是第三方重打包客户端，也不替换 Figma 安装包。

## 当前增强重点

优先补齐 Figma 首页、Recents 页面和 Make 区域的漏翻，并增加几个适合桌面客户端使用的辅助功能，例如：

- Make 顶部横幅
- Make 模式选择菜单
- 首页产品入口
- 最近文件筛选和排序
- 免费套餐提示卡片
- 顶部 FigBoost 菜单
- Figma 官方更新检查入口
- 检索画板与批量导出 `.fig` 文件

当前补丁程序版本：`0.3.5`

当前词库版本：`1.0.2`

## 普通用户使用

下载仓库或 Release 里的 `FigBoost.exe` 后，直接双击运行即可。这个程序不会替换 Figma 安装包，它只是给你电脑上已经安装好的官方 Figma Desktop 打补丁。

如果你更习惯命令行，也可以在仓库根目录运行：

```powershell
.\FigBoost.exe
```

不需要进入 `dist` 目录，也不要用旧的原版 `FigBoost.exe` 来判断增强词库是否生效。

最常用的操作顺序：

1. 打开 `FigBoost.exe`。
2. 点“检测当前版本”，确认它找到的是你正在使用的 Figma Desktop 目录。
3. 点“安装补丁”，等待提示安装成功。
4. 重新打开 Figma，看界面是否已经变成中文。
5. 如果需要更新检查或批量导出，再点“管理附加功能”安装对应功能。

界面里的主要操作：

- 自动检查路径和版本：自动查找最新完整 Figma 客户端目录，跳过更新残留目录，显示 Figma 版本和补丁状态。
- 安装补丁：强制关闭 Figma，备份 `resources\app.asar`，原地写入主进程注入 hook，并在界面选择的运行时目录生成汉化运行时。成功或失败都会弹窗提示。
- 管理附加功能：可以单独安装或卸载额外功能，不会卸载汉化补丁。
- 顶部 FigBoost 菜单：安装后，Figma 顶部会出现 FigBoost 入口；里面可以手动检查官方 Figma 最新版，也可以作为其他附加功能的入口。
- 检索画板与批量导出：在顶部 FigBoost 菜单里增加“批量导出画板文件”入口，可检索当前账号可见的团队项目文件，勾选后导出本地 `.fig` 副本。
- 重复安装：如果检测到补丁已安装，会提示“该补丁已安装，不需要重复安装”。
- 用户命名保护：文件名、项目名、团队名等用户自己命名的内容不会被词库自动汉化。
- 卸载补丁：强制关闭 Figma，从备份恢复原始 `app.asar`。成功或失败都会弹窗提示。
- FigBoost 自更新：点击“检测当前版本”后，如果 GitHub Release 里有新的 `FigBoost.exe`，程序会提示是否下载并替换当前版本。

安装或卸载时会自动强制关闭 Figma，请先保存未同步的工作。

## 说明

- 默认会自动选择 `%LOCALAPPDATA%\Figma` 下版本号最高的 `app-*` 目录。
- 备份文件名为 `resources\app.asar.figma-zh-official-preload-original`。
- Figma 更新后会创建新的 `app-*` 目录，需要对新版本重新安装补丁。
- 安装补丁后会禁用 Figma 客户端内置更新器，避免官方内置更新流程把客户端回退到旧版本；更新请通过顶部 FigBoost 菜单里的“检查更新”，或先卸载补丁后再使用官方更新方式。
- 批量导出功能依赖你当前登录的 Figma 账号权限，只能导出这个账号本来就能访问的设计文件。
- 这是对官方 Figma Desktop 的非官方修改，遇到客户端启动异常时请先卸载补丁恢复。

## 开发和测试

运行内置回归测试：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\src\FigBoost.ps1 -SelfTest
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

重新打包 exe：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\build.ps1
```
