-- Extract_MTD4.lua
-- 提取设备mtd系统分区并重命名保存为文件
-- 
-- 版权 (C) 2025-2026 企鹅君Punguin
--
-- 本程序是自由软件：你可以根据自由软件基金会发布的GNU Affero通用公共许可证的条款，即许可证的第3版或（您选择的）任何后来的版本重新发布它和/或修改它。。
-- 本程序的发布是希望它能起到作用。但没有任何保证；甚至没有隐含的保证。本程序的分发是希望它是有用的，但没有任何保证，甚至没有隐含的适销对路或适合某一特定目的的保证。 参见 GNU Affero通用公共许可证了解更多细节。
-- 您应该已经收到了一份GNU Affero通用公共许可证的副本。 如果没有，请参见<https://www.gnu.org/licenses/>。
--
-- 联系我们：3618679658@qq.com
-- ChatGPT协助制作编写

-- 设置标题与窗口大小
os.execute("title 企鹅WIFI助手-MTD提取工具")
os.execute("mode con: cols=66 lines=35")

-- 引入外部库
local path = require("lua\\path") -- 工具路径变量库
local colors = require("lua\\colors") -- ANSI颜色码库
local delay = require("lua\\sleep") -- 倒计时操作

-- 获取脚本所在目录的绝对路径
local function get_script_dir()
    local path = io.popen("cd"):read("*l")
    return path .. "\\"
end
local script_dir = get_script_dir()

-- 定义目标文件夹路径
local qt_folder = script_dir .. "TQ\\"

-- 提取分区
print(colors.blue .. colors.bright .. "搜寻设备..." .. colors.reset)
delay.sleep (4) -- 等待设备
os.execute("bin\\adb pull /dev/mtd4 draw.tmp")   -- 固件MTD提取
print()
print()
print(colors.green .. "已尝试提取" .. colors.reset)

-- 获取用户输入的新文件名
print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)
io.write("请输入新的文件名（不含扩展名）：")               --暂停程序的执行,让用户输入文本
local new_file_name = io.read()                            --将用户拖入的文件设定为"new_file_name"函数
new_file_name = new_file_name:gsub('^%"', ''):gsub('%"$', '')      --去掉文件路径的双引号（如果有）
new_file_name = new_file_name .. ".bin" -- 将新文件名加上 .bin 后缀

-- 构造完整的路径
local old_file_path = script_dir .. "draw.tmp"
local new_file_path = script_dir .. new_file_name

-- 重命名文件
local success, err = os.rename(old_file_path, new_file_path)
if success then
    print(colors.green .."文件已成功重命名为: " .. new_file_name .. colors.reset)
else
    print(colors.red .."重命名失败: " .. err .. colors.reset)
end

-- 检查目标文件夹是否存在，如果不存在则创建
local function ensure_directory_exists(path)
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 2 then
            os.execute('mkdir "' .. path .. '"')
        else
            print(colors.red .."无法检查或创建目录: " .. err .. colors.reset)
        end
    end
end

ensure_directory_exists(qt_folder)

-- 构造新的目标路径
local target_file_path = qt_folder .. new_file_name

-- 移动文件
local success, err = os.rename(new_file_path, target_file_path)
if success then
    print(colors.green .."文件已成功移动至QT文件夹".. colors.reset)
	os.execute("explorer TQ")
	print(colors.green .. colors.bright .."脚本已正确执行,五秒后关闭窗口".. colors.reset)
	delay.sleep (5)
else
    print(colors.red .."移动文件失败: " .. err .. colors.reset)
	os.execute("pause")
end