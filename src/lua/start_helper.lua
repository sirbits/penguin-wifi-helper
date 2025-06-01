-- start_helper.lua
-- 为企鹅WIFI助手主程序提供初始化与更新检测服务
-- 
-- 版权 (C) 2025 企鹅君Punguin
--
-- 本程序是自由软件：你可以根据自由软件基金会发布的GNU Affero通用公共许可证的条款，即许可证的第3版或（您选择的）任何后来的版本重新发布它和/或修改它。。
-- 本程序的发布是希望它能起到作用。但没有任何保证；甚至没有隐含的保证。本程序的分发是希望它是有用的，但没有任何保证，甚至没有隐含的适销对路或适合某一特定目的的保证。 参见 GNU Affero通用公共许可证了解更多细节。
-- 您应该已经收到了一份GNU Affero通用公共许可证的副本。 如果没有，请参见<https://www.gnu.org/licenses/>。
--
-- 联系我们：3618679658@qq.com
-- ChatGPT协助制作编写

-- 设置标题终端与定义窗口大小
os.execute("title 企鹅WIFI助手__当前版本: 4.9 ,正在检测版本")
os.execute("mode con: cols=53 lines=15")

-- 引入外部库
local path = require("lua\\path") -- 工具路径变量库
local colors = require("lua\\colors") -- ANSI颜色码库
local delay = require("lua\\sleep") -- 倒计时操作

-- 获取当前脚本所在目录
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*/)") or script_path:match("(.+\\)") or "./"

-- 定义标志文件路径
local flag_file = script_dir .. "dyc"

-- 判断是否为第一次运行
local file = io.open(flag_file, "r")
if file then
    file:close()
    
    -- 输出第一次运行提示
    print("助手正在初始化....")
    delay.sleep(6)
    print ()
    -- 获取 Windows 版本
    local handle = io.popen("wmic os get Caption")
    local result = handle:read("*a")
    handle:close()

   -- 判断 Windows 版本
   if result:find("Windows 10") then
       print(colors.cyan .. colors.bright .. "══════════════════════════" .. colors.reset)
       print(colors.cyan .. colors.bright .. "═══  " .. colors.green .."检测到 Windows 10".. colors.reset .. colors.cyan .. colors.bright .. "  ══" .. colors.reset)
       print(colors.cyan .. colors.bright .. "══════════════════════════" .. colors.reset)
   elseif result:find("Windows 11") then
       print(colors.cyan .. colors.bright .. "══════════════════════════" .. colors.reset)
       print(colors.cyan .. colors.bright .. "═══  " .. colors.green .."检测到 Windows 11".. colors.reset .. colors.cyan .. colors.bright .. "  ══" .. colors.reset)
       print(colors.cyan .. colors.bright .. "══════════════════════════" .. colors.reset)
       print()
       delay.sleep(1)
       print(colors.red .. colors.bright .."当前系统控制台可能会被终端替代".. colors.reset)
       print()
       print(colors.red .. colors.bright .."推荐前往设置→开发者选项修改为控制台".. colors.reset)
       delay.sleep(2)
   elseif result:find("Windows 7") then
       print("══════════════════════════")
       print("═══  ".."检测到 Windows 7".."  ══")
       print("══════════════════════════")
       print()
       print("当前助手不支持 Windows 7 系统。")
       print("请下载适用于 Windows 7 的专用工具箱。")
       print()
       print("按下任意键退出...")
       os.execute("pause >nul")  -- 等待用户按下任意键
       os.exit()  -- 退出脚本
   else
       print("无法确定 Windows 版本")
   end
    print()
    print()
    print("请稍后，助手正在优化运行环境")
    delay.sleep(6)
	print()
	--当前版本省略一些注册表参数
    print(colors.green .."注册表编辑器:参数已保存!".. colors.reset)
    delay.sleep(6)
    -- 删除 dyc 文件
    os.remove(flag_file)
    print ()
    print (colors.green .."完成".. colors.reset)
    delay.sleep(3)
    os.execute("cls")
end

local function print_tips()
   print(colors.green .."正在检测助手云端版本,请耐心等待数秒\n\n" .. colors.reset)
end

local function print_start()
   print()
   print()
   print(colors.green .."正在处理启动参数与拉起助手,请稍等几秒......\n" .. colors.reset)
end

-- 等待用户按下任意键
local function wait_for_user_input()
    print()
    print(colors.yellow .. "检测到新版本，按下任意键继续..." .. colors.reset)
    os.execute("pause >nul")  -- Windows下等待用户按下任意键
	print()
	delay.sleep(1)
	print()
	print(colors.red .. "每次更新都有新的好功能,还是建议您升级的呢" .. colors.reset)
	delay.sleep(5)
end

-- 获取云端版本信息
local function check_version()
-- 读取 helper.ini 中的刷新周期（天）
local function read_refresh_cycle(file_path)
    local file = io.open(file_path, "r")
    if not file then
        print("未找到 helper.ini，将立即进行版本检测。")
        return nil
    end
    for line in file:lines() do
        local cycle = line:match("refresh cycle%s*=%s*(%d+)")
        if cycle then
            file:close()
            return tonumber(cycle)
        end
    end
    file:close()
    print("未在 helper.ini 中找到 refresh cycle 参数，将立即进行版本检测。")
    return nil
end

-- 从 version.ini 中获取上次检测时间（格式：review time: YYYY-MM-DD）
local function read_last_check_time(file_path)
    local file = io.open(file_path, "r")
    if not file then
        print("未找到 version.ini，将立即进行版本检测。\n")
        return nil
    end
    for line in file:lines() do
        local y, m, d = line:match("review time:%s*(%d+)%-(%d+)%-(%d+)")
        if y then
            file:close()
            return os.time{year=tonumber(y), month=tonumber(m), day=tonumber(d), hour=0, min=0, sec=0}
        end
    end
    file:close()
    print("未在 version.ini 中找到 review time 记录，将立即进行版本检测。")
    return nil
end

-- 判断是否需要检测更新
local function should_check_update()
    local cycle = read_refresh_cycle("helper.ini") -- 天数
    local last_time = read_last_check_time("version.ini")
    if not cycle or not last_time then
        return true -- 缺文件/参数/时间信息，强制检测
    end

    local now = os.time()
    local diff_days = os.difftime(now, last_time) / (60 * 60 * 24) -- 秒转天
    if diff_days >= cycle then
    return true
else
    if diff_days < 1 then
        print("上次检测是今天，跳过版本检测。")
    else
        print(string.format("上次检测在 %.1f 天前，未达到 %d 天的更新周期", diff_days, cycle))
		print(string.format("跳过版本检测。", diff_days, cycle))
    end

    -- 计算下次检测时间
    local next_time = last_time + cycle * 24 * 60 * 60
    local next_date = os.date("%Y-%m-%d", next_time)
    print("预计将在 " .. next_date .. " 后再次检测。")

    return false
end
end

-- 若不需要检测，返回
if not should_check_update() then
    delay.sleep(2)
    return
end
    local version_urls = {
        "https://punguin.pages.dev/helper",      --来自Cloudflare提供的免费服务
        --"http://47.239.84.169/helper"            --企鹅官网
    } -- 服务器列表
    local local_version = "4.9" -- 替换为本地的版本号
    local temp_version_file = "version.ini" -- 临时版本文件
    local cloud_version = nil  -- 注意,在编译时需要将ip进行单独加密

    -- 从版本文件中提取云端版本号
    local function get_version_from_html(file_path)
        local file = io.open(file_path, "r")
        if not file then
            return nil
        end
        for line in file:lines() do
            local version = line:match("%d.%d") -- "%d.%d"为版本号格式,对应的版本为X.X(数字格式)
            if version then
                file:close()
                return version
            end
        end
        file:close()
        return nil
    end

    -- 检查文件是否有效
    local function is_file_valid(file_path)
        local file = io.open(file_path, "r")
        if not file then
            return false
        end
        local content = file:read("*a")
        file:close()
        return content and #content > 0 and not content:find("404") -- 检查内容是否包含404
    end

    -- 尝试从每个服务器下载版本文件
    for _, url in ipairs(version_urls) do
        -- 使用curl下载版本文件
        --os.execute(string.format('bin\\curl -l -o %s %s >nul 2>nul', temp_version_file, url))
		os.execute(string.format('"%s" -l -o %s %s >nul 2>nul', path.curl, temp_version_file, url))
        
        if is_file_valid(temp_version_file) then
            cloud_version = get_version_from_html(temp_version_file)
            if cloud_version then
                break -- 成功获取云端版本号，退出循环
            end
        end
    end

    --os.remove(temp_version_file) -- 删除临时版本文件

    -- 输出版本信息
    if cloud_version then
	-- 获取当前时间并写入版本文件
local function write_check_time(file_path)
    local time_str = os.date("\n\nreview time: %Y-%m-%d") -- 格式：检测时间：年-月-日
    local file = io.open(file_path, "a") -- 使用追加模式
    if file then
        file:write(time_str)
        file:close()
    end
end

write_check_time(temp_version_file)
        print(colors.bright .. "最新版本: " .. cloud_version .. "  当前版本: " .. local_version .. colors.reset .. "\n")
        print(colors.blue .. colors.bright .. "若云端有新版本,请进入助手后输入'new'下载\n" .. colors.reset)
        print()
        print("笑点解析:还有人现在在用企鹅助手1.2")
		print()

        -- 判断是否需要等待用户输入
        if cloud_version > local_version then
            wait_for_user_input()  -- 如果云端版本比本地版本高，等待用户输入
        else
        end
    else
        print(colors.bright .. "无法获取云端版本\n" .. colors.reset)
    end
end

print_tips()
check_version()
print_start()
delay.sleep(2)
os.execute("bin\\lua54 lua\\helper.lua")