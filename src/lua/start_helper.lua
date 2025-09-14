-- start_helper.lua
-- 为企鹅WIFI助手主程序提供初始化与更新检测服务
--
-- 版权 (C) 2025-2026 企鹅君Punguin
--
-- 本程序是自由软件：你可以根据自由软件基金会发布的GNU Affero通用公共许可证的条款，即许可证的第3版或（您选择的）任何后来的版本重新发布它和/或修改它。。
-- 本程序的发布是希望它能起到作用。但没有任何保证；甚至没有隐含的保证。本程序的分发是希望它是有用的，但没有任何保证，甚至没有隐含的适销对路或适合某一特定目的的保证。 参见 GNU Affero通用公共许可证了解更多细节。
-- 您应该已经收到了一份GNU Affero通用公共许可证的副本。 如果没有，请参见<https://www.gnu.org/licenses/>。
--
-- 联系我们：3618679658@qq.com
-- ChatGPT协助制作编写

-- 设置标题终端与定义窗口大小
os.execute("title 企鹅WIFI助手 当前版本: 5.2 ,正在检测版本")
os.execute("mode con: cols=60 lines=15")

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
    
    -- 使用记事本打开配置文件
    print("检测到助手第一次运行")
    print("正在打开配置文件，请手动编辑...")
	delay.sleep(4)
    os.execute('start notepad.exe helper.ini')
    -- 删除标志文件，避免重复提示
    os.remove(flag_file)
	delay.sleep(2)
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
-- 新增：检测Build版本通道
local function get_version_path()
    local default_path = "helper"  -- 默认路径
    local file = io.open("helper.ini", "r")
    if not file then
        return default_path  -- 配置文件不存在，使用默认
    end
    for line in file:lines() do
        -- 检测未注释的[Build version channel]
        if line:match("^%s*%[Build version channel%]%s*$") then
            file:close()
            return "helper-build"  -- 使用Build通道路径
        -- 检测注释的#[Build version channel]
        elseif line:match("^%s*#%s*%[Build version channel%]%s*$") then
            file:close()
            return default_path  -- 使用默认路径
        end
    end
    file:close()
    return default_path  -- 未找到相关配置，使用默认
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

    -- 新增：通过get_version_path()获取实际拉取路径
    local version_path = get_version_path()
    local version_urls = {
        "https://punguin.pages.dev/" .. version_path,      -- 拼接路径
        --"http://47.239.84.169/" .. version_path,            -- 拼接路径
		"http://127.0.0.1:0721/" .. version_path                   -- 拼接路径
    } -- 服务器列表
    local local_version = "5.2" -- 替换为本地的版本号
    local temp_version_file = "version.ini" -- 临时版本文件
    local cloud_version = nil  -- 注意,在编译时需要将ip进行单独加密
    -- 从版本文件中提取云端版本号
    local function get_version_from_html(file_path)
        local file = io.open(file_path, "r")
        if not file then
            return nil
        end
        for line in file:lines() do
            local version = line:match("%d+%.%d+[%w%-]*") -- "%d.%d"为版本号格式,对应的版本为X.X(数字格式)
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