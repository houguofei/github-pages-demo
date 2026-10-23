# GitHub Pages 静态站点部署说明

本文件夹是一份**最小可运行的 GitHub Pages 静态站点**，纯 HTML + CSS + JS，不需要任何构建工具，直接推送即可上线。

## 文件说明

| 文件 | 作用 |
|---|---|
| `index.html` | 站点首页（入口文件，必须是这个名字） |
| `styles.css` | 样式，含深色模式与响应式 |
| `app.js` | 交互脚本，加载后写入“运行时自检”区域 |
| `404.html` | 自定义 404 页面（GitHub Pages 会自动识别根目录下的 404.html） |
| `.nojekyll` | 空文件，关闭 Jekyll 构建，避免 `_` 开头目录被忽略 |

## 一、本地预览（上线前先验证）

在本文件夹内启动任意静态服务器：

```bash
# 方式 1：Node 自带（无需安装）
npx --yes serve . -l 4173

# 方式 2：Python
python -m http.server 4173

# 方式 3：VS Code 的 Live Server 插件，右键 index.html → Open with Live Server
```

浏览器打开 `http://localhost:4173/` 查看效果。

> 不要用 `file://` 直接打开来验证——那样测的是本地文件路径，不能暴露部署时的相对路径问题。

## 二、推到 GitHub

```bash
cd <本文件夹>
git init
git add -A
git commit -m "Add static site for GitHub Pages"
git branch -M main
git remote add origin https://github.com/<用户名>/<仓库名>.git
git push -u origin main
```

## 三、开启 Pages

1. 打开仓库页面 → **Settings** → 左侧 **Pages**
2. **Build and deployment → Source** 选 `Deploy from a branch`
3. 分支选 `main`，文件夹选 `/ (root)` → **Save**
4. 等 1–2 分钟刷新该页面，会显示站点地址

访问地址：

- 仓库名叫 `<用户名>.github.io` → `https://<用户名>.github.io/`
- 其他仓库名 → `https://<用户名>.github.io/<仓库名>/`

## 四、每次更新的流程

```bash
git add -A
git commit -m "Update site"
git push
```

推送后 Pages 会自动重新构建部署，通常 1 分钟内生效。看不到变化先按 `Ctrl+F5` 强制刷新排除浏览器缓存。

## 五、常见问题

| 现象 | 原因与处理 |
|---|---|
| 打开是 404 | Pages 未启用；分支/文件夹选错；仓库是私有而账号是免费版；刚保存需等 1–2 分钟 |
| CSS/JS 没生效 | 用了绝对路径 `/styles.css`。项目站点位于子路径，必须用相对路径 `./styles.css`，或在构建工具里把 base 设为 `/仓库名/` |
| 部分文件不生效 | 文件名以 `_` 开头被 Jekyll 忽略，本文件夹已放 `.nojekyll` 规避 |
| 链接 404 | GitHub Pages 路径**区分大小写**，`About.html` ≠ `about.html` |
| 改了不生效 | 浏览器缓存（Ctrl+F5）；或检查 Actions/部署记录是否成功 |
| 国内访问慢或打不开 | `*.github.io` 在国内常被限速或阻断，可考虑 Cloudflare Pages、Vercel、Netlify，或用自有服务器 + 域名 |

## 六、使用限制要点

- 每个账号只能有一个用户/组织站点（仓库名必须是 `<用户名>.github.io`）
- 发布源仓库建议 ≤ 1 GB，已发布站点 ≤ 1 GB
- 软性限制：每月 100 GB 带宽、每小时 10 次构建（走自定义 Actions 工作流时构建次数限制不适用）
- 部署超过 10 分钟会超时
- 免费账号仅**公开**仓库可发布；私有仓库发布需 GitHub Pro/Team/Enterprise
- 站点在互联网上**公开可访问**，不要放密钥、内网信息或个人隐私数据
- 仅适合静态内容，不能运行后端服务，不允许用作电商或商业 SaaS 站点

官方文档：[GitHub Pages 限制](https://docs.github.com/zh/pages/getting-started-with-github-pages/github-pages-limits)

## 七、进阶：从分支发布换成 Actions 发布

当站点需要构建（Vite/React/Vue、VuePress、Hugo、Jekyll 等）时，改用自定义工作流：

1. **Settings → Pages → Source** 改为 `GitHub Actions`
2. 在仓库新建 `.github/workflows/pages.yml`
3. 核心是三件事：用 `actions/upload-pages-artifact@v4` 上传构建产物目录，用 `actions/deploy-pages@v4` 部署，部署作业需要 `pages: write` 与 `id-token: write` 权限

无构建过程的极简示例：

```yaml
name: Deploy static site to Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v4
        with:
          path: .
      - id: deployment
        uses: actions/deploy-pages@v4
```

官方文档：[将自定义工作流与 GitHub Pages 配合使用](https://docs.github.com/zh/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)

## 八、进阶：绑定自定义域名

1. 域名 DNS 添加记录：
   - 子域名（`www.example.com`）：`CNAME` 记录指向 `<用户名>.github.io`
   - 顶级域名（`example.com`）：4 条 `A` 记录，指向 `185.199.108.153`、`185.199.109.153`、`185.199.110.153`、`185.199.111.153`
2. 仓库 **Settings → Pages → Custom domain** 填入域名并保存
3. DNS 检查通过后勾选 **Enforce HTTPS**，等证书签发完成
4. 注意：通过仓库文件里的 `CNAME` 文件不会自动设置域名，必须在仓库设置或 API 中配置
