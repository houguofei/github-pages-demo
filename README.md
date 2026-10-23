# github-pages-demo · 静态展示仓库

线上门户：**https://houguofei.github.io/github-pages-demo/**

这是一个长期使用的 GitHub Pages 展示仓库：每个新的静态展示项目放入 `shows/` 下的独立子目录，推送到 `main` 分支后约 1 分钟自动上线，门户首页会**自动收录**新项目，无需手工改门户页。

## 仓库结构

```
/                        门户首页（自动发现 shows/ 下的项目）
├── 404.html             自定义 404（必须留在根目录）
├── .nojekyll            关闭 Jekyll（勿删）
├── publish.ps1          一键发布脚本
├── pages-tutorial/      Pages 使用教程（内置示例页）
└── shows/               ★ 所有展示项目都放这里
    └── <项目名>/         每个项目一个子目录
        ├── index.html   入口文件（必需，门户据此收录）
        └── meta.json    标题/描述/日期（可选，门户卡片用）
```

`meta.json` 格式（全部字段可选）：

```json
{
  "title": "项目标题",
  "desc": "一句话描述",
  "date": "2026-10-23"
}
```

## 发布方式

### 方式 1：一键脚本（推荐，本机执行）

```powershell
cd H:\AI\dsh\github-pages-demo
.\publish.ps1 -Source <要发布的文件或文件夹> -Name <英文目录名>
```

脚本自动完成：复制到 `shows/<Name>/` → commit → push，并输出最终访问地址。

### 方式 2：让 Agent 代劳

在会话里把文件给 Agent，说"发布到 github-pages-demo"即可。

### 方式 3：手动 git

```bash
# 把项目放进 shows/<项目名>/ 后：
git add shows/<项目名>
git commit -m "Add show: <项目名>"
git push          # 走 SSH，无需凭据
```

## 新项目注意事项

- 子目录名建议**纯英文小写**（URL 友好），中文标题写在 `meta.json` 的 `title` 里
- 页面内资源一律用**相对路径**（`./style.css`、`./data.json`），绝对路径 `/xxx` 会 404
- GitHub Pages 路径**区分大小写**
- 站点公开可访问：不放密钥、内网信息、个人隐私数据
- 纯静态展示，不能运行后端
- 需要构建的项目（Vite/React/VuePress 等）把构建产物放进子目录即可；想自动构建再加 GitHub Actions workflow

## 常见问题

| 现象 | 处理 |
|---|---|
| 推送后打不开 | 等 1–2 分钟；Ctrl+F5 强刷；确认 push 成功（`git log origin/main..main` 应为空） |
| 资源 404 | 检查相对路径与大小写 |
| 门户没显示新项目 | 门户经 GitHub API 自动发现（匿名限额 60 次/小时），刷新重试；确认子目录里有 `index.html` |
| 国内访问慢 | `*.github.io` 常被限速，可换 Cloudflare Pages / Vercel 或绑定自定义域名 |
