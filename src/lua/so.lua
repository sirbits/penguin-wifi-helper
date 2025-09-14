-- so.lua
-- 简单的MTD烧录工具(半成品)
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
os.execute("title 企鹅君PINGUIN_run块烧写工具     当前版本: 1.0测试版")
os.execute("mode con: cols=66 lines=35")

-- 引入外部库
local path = require("lua\\path") -- 工具路径变量库
local colors = require("lua\\colors") -- ANSI颜色码库
local delay = require("lua\\sleep") -- 倒计时操作

-- 输出提示信息
print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)
print(colors.red .. '警告!您输入的任何文件将会直接传入设备/tmp/中' .. colors.reset)
print(colors.red .. "请确保文件不大于3.19MB" .. colors.reset)
print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)

-- 获取脚本所在目录
local script_dir = debug.getinfo(1).source:match("@?(.*/)")   --设定一个名为"script_dir"参数
if not script_dir then                                        --循环获取"./"路径
    script_dir = "."
end

-- 提示用户输入文件路径或拖入文件
io.write("请输入文件路径或将文件拖入窗口: ")               --暂停程序的执行,让用户输入文本
local file_path = io.read()                                --将用户拖入的文件设定为"file_path"函数
file_path = file_path:gsub('^%"', ''):gsub('%"$', '')      --去掉文件路径的双引号（如果有）

-- 检查文件是否存在
local function file_exists(path)                           --获取已设置的文件函数
    local file = io.open(path, "rb")                       --获取用户刚刚输入的文件
    if file then                                           --剩下的代码是检测文件
        file:close()
        return true
    else
        return false
    end
end

if not file_exists(file_path) then                         --如果文件不存在，则提示用户
    print(colors.red .. "文件不存在: " .. file_path .. "脚本已退出" .. colors.reset)
    os.execute("pause")
	return
end

-- 复制并重命名文件
local destination_path = script_dir .. "/mtds.new"         --设置要重命名的文件名称"mtds.new"
local input_file = io.open(file_path, "rb")                --设置重命名参数"rb"
local output_file = io.open(destination_path, "wb")        --设置重命名参数"wb"

if input_file and output_file then                         --进行复制与重命名操作
    output_file:write(input_file:read("*all"))
    input_file:close()
    output_file:close()
    print("文件已复制并重命名为: " .. destination_path)    --输出结果
else
    print("文件复制失败。")                                --输出结果
    os.execute("pause")
	return                                                 --退出脚本
end

-- 检查busybox文件是否存在
local busybox_path = script_dir .. "\\file\\busybox"              --设置要检查的文件名称
if not file_exists(busybox_path) then                      --输出结果
    print("busybox文件不存在: " .. busybox_path)           --输出结果
    os.execute("pause")
	return                                                 --退出脚本
end

-- 使用adb push将文件传输到已连接设备的/tmp
os.execute('adb push "' .. destination_path .. '" /tmp/')  --通过adb上传文件
os.execute('adb push "' .. busybox_path .. '" /tmp/')      --通过adb上传文件
print(colors.green .. "文件和busybox已尝试传输到设备的/tmp目录。".. colors.reset)
print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)

-- 删除临时文件
os.execute("del mtds.new")                                 --删除"mtds.new"文件,这是用户刚刚拖入的临时文件              

-- 询问用户是否进行关键性操作
print(colors.red .. '警告!接下来的操作涉及关键MTD块更新' .. colors.reset)
print(colors.red .. colors.bright .. '若更新失败可能会导致您的设备无法正常启动!' .. colors.reset)
print(colors.green .. '请您确认是否要进行MTD块更新操作' .. colors.reset)
print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)
io.write("请输入'yes'以继续：")                            --暂停程序的执行,让用户输入文本
local input = io.read()                                    --将用户刚刚输的文本设置为"input"函数
if input ~= "yes" then                                     --比对用户的输入是否为"yes"
  print("您未同意，程序退出。")
  print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)
  os.execute("pause")
  os.exit() -- 退出程序
  else
  print(colors.green .. "您已同意，继续执行程序。" .. colors.reset)
  print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)
end

print(colors.red .. '!将在五秒后激活主线程,您有五秒的考虑时间!' .. colors.reset)
delay.sleep(5) -- 延迟5秒
print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)

-- 进行MTD块更新/刷写操作
print(colors.cyan .. colors.bright .. "正在尝试给予busybox关键权限" .. colors.reset)
os.execute("adb shell chmod +x /tmp/busybox")
print(colors.green .."busybox已被授予读写权限".. colors.reset)
print(" ")
print(colors.cyan .. colors.bright .. "正在尝试使用dd刷写MTD4" .. colors.reset)
os.execute("adb shell /tmp/busybox nohup dd if=/tmp/mtds.new of=/dev/mtd4 &")
print(colors.red .. "分区修改完毕后过几秒会自动重启设备" .. colors.reset)
print(colors.bright .. "(==0%)" .. colors.reset)
delay.sleep(10) -- 延迟10秒
print(colors.bright .. "(=======20%)" .. colors.reset)
print(colors.bright .. "(=============30%)" .. colors.reset)
print(colors.bright .. "(===================40%)" .. colors.reset)
print(colors.bright .. "(=========================50%)" .. colors.reset)
print(colors.bright .. "(===============================66%)" .. colors.reset)
delay.sleep(10) -- 延迟10秒
print(colors.bright .. "(======================================79%)" .. colors.reset)
delay.sleep(9) -- 延迟9秒
print(colors.bright .. "(===========================================83%)" .. colors.reset)
delay.sleep(12) -- 延迟12秒
print(colors.bright .. "(=================================================96%)" .. colors.reset)
delay.sleep(6) -- 延迟6秒
print(colors.bright .. "(=======================================================99%)" .. colors.reset)
delay.sleep(60) -- 延迟一分钟
print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)
print(colors.green .. "烧写已经完成了,按理来说设备可以正常开机" .. colors.reset)
print(colors.red .. "如果不开机，请等待两分钟后再拔出" .. colors.reset)
print(colors.red .. "有可能刷机时间与我们预计的时间不同" .. colors.reset)
os.execute("pause")