-- zmtd-brusque
-- 企鹅WiFi助手 刷写器V2.1
-- 
-- 版权 (C) 2025 企鹅君Punguin
--
-- 本程序是自由软件：你可以根据自由软件基金会发布的GNU Affero通用公共许可证的条款，即许可证的第3版或（您选择的）任何后来的版本重新发布它和/或修改它。。
-- 本程序的发布是希望它能起到作用。但没有任何保证；甚至没有隐含的保证。本程序的分发是希望它是有用的，但没有任何保证，甚至没有隐含的适销对路或适合某一特定目的的保证。 参见 GNU Affero通用公共许可证了解更多细节。
-- 您应该已经收到了一份GNU Affero通用公共许可证的副本。 如果没有，请参见<https://www.gnu.org/licenses/>。
--
-- 联系我们：3618679658@qq.com
-- ChatGPT协助制作编写

-- 设窗口变量
os.execute("title 企鹅WiFi助手  MTD刷写V2.1")
os.execute("mode con: cols=80 lines=32")

-- 引入外部库
local colors = require("lua\\colors") -- ANSI颜色码库
local delay = require("lua\\sleep") -- 倒计时操作

-- 终端与命令执行
local function exec(cmd)
    --print("[执行命令] " .. cmd)
    local f = io.popen(cmd .. " 2>&1")
    local res = f:read("*a")
    f:close()
    --print("[命令输出] " .. res)
    return res
	-- 如果需要调试程序，将以上print去除注释
end

-- 检查是否有 adb 设备连接
local function is_adb_device_connected()
	local check = io.popen("bin\\adb get-state")
	local state = check:read("*a")
	check:close()

	if not state:match("device") then -- 当没有设备时就输出
	    print()
		print(colors.red .."[错误] 未检测到ADB设备，请连接设备后重试。".. colors.reset)
		print(colors.green .."提示:如果设备处于连接但离线模式，设备adb也是不可用。".. colors.reset)
		print()
		print("按任意键退出...")
		io.read()  -- 获取用户输入
		os.exit(1)  -- 非0表示异常退出
	end
end

local function copy_to_workdir(src_path)
    local filename = src_path:match("([^\\/]+)$")
    exec(string.format('copy /Y "%s" "mtd.bin"', src_path))
    return "mtd.bin"
end

local function get_local_md5(file)
    local output = exec(string.format('bin\\md5sum.exe "%s"', file))
    local md5 = output:match("^(%x+)")
    if not md5 then
        error("[!] 无法解析本地MD5，输出为: " .. output)
    end
    return md5
end

local function adb_push(local_file, device_file)
    local cmd = string.format('bin\\adb push "%s" "%s"', local_file, device_file)
    exec(cmd)
end

local function get_device_md5(device_file)
    local output = exec(string.format('bin\\adb shell md5sum "%s"', device_file))
    local md5 = output:match("^(%x+)")
    if not md5 then
        error("[!] 无法解析设备端MD5，输出为: " .. output)
    end
    return md5
end

local function compare_md5(local_md5, device_md5)
    print("\n" .. colors.cyan .. colors.bright .."------------------ ".. colors.blue .. colors.bright .."文件传输校验".. colors.reset .. colors.cyan .. colors.bright .." ------------------")
    print(string.format(colors.cyan .. colors.bright .."[".. colors.blue .. colors.bright .."*".. colors.cyan .. colors.bright .."]".. colors.blue .." 本地文件 :    ".. colors.reset .. colors.green .."%s", local_md5))
    print(string.format(colors.cyan .. colors.bright .."[".. colors.blue .. colors.bright .."*".. colors.cyan .. colors.bright .."]".. colors.blue .." 设备文件 :    ".. colors.reset .. colors.green .."%s", device_md5))
    if local_md5:lower() == device_md5:lower() then
        print(colors.cyan .. colors.bright .."[".. colors.green .."√".. colors.cyan .. colors.bright .."]".. colors.green ..  colors.bright .." 校验一致，文件传输成功")
		print(colors.cyan .. colors.bright .."---------------------------------------------------".. colors.reset)
    else
        print(colors.cyan .. colors.bright .."[".. colors.red .."!".. colors.cyan .. colors.bright .."]".. colors.red .. colors.bright .."校验失败，文件可能损坏，已中止刷写，请重启设备后重新开始")
		print(colors.cyan .. colors.bright .."---------------------------------------------------".. colors.reset)
		os.execute("pause")
        os.exit(1)
    end
end

local function prepare_device_environment()
    exec('bin\\adb shell mount -t tmpfs rw,remount /tmp')
    adb_push('file\\busybox', '/tmp/')
    exec('bin\\adb shell ln -s /tmp/busybox /tmp/dd')
    exec('bin\\adb shell ln -s /tmp/busybox /tmp/sh')
    exec('bin\\adb shell ln -s /tmp/busybox /tmp/reboot')
    exec('bin\\adb shell chmod +x /tmp/busybox /tmp/dd /tmp/sh /tmp/reboot')
end

local function optional_backup()
    print(colors.blue .. colors.bright .."是否进行备份当前分区".. colors.cyan .. colors.bright .."(".. colors.red .."备份将耗费较长时间".. colors.cyan .. colors.bright ..")".. colors.yellow .. colors.bright .." [需要输yes，回车跳过]")
    local choice = io.read()
	print(colors.reset)
    if choice:lower() == "yes" then
        -- 获取当前时间并格式化为: 年月日小时分钟 (例如：202506151519)
        local timestamp = os.date("%Y%m%d%H%M")

        -- 获取用户桌面路径
        local userprofile = os.getenv("USERPROFILE")
        local backup_folder = userprofile .. "\\Desktop\\MTD分区备份"
        local filename = string.format("MTD4备份%s.bin", timestamp)
        local desktop_path = backup_folder .. "\\" .. filename

        -- 创建备份文件夹（确保存在）
        os.execute('mkdir "' .. backup_folder .. '" 2>nul')

        -- 生成readme文件
        local readme_path = backup_folder .. "\\readme.txt"
        local readme_file = io.open(readme_path, "w")
        if readme_file then
            readme_file:write("此文件夹由企鹅助手MTD刷写器生成，您已选择将MTD文件备份。\n本工具支持多次备份并不覆盖原文件，您无需删除原文件。\n\n您可以将备份的MTD文件重新写入设备。")
            readme_file:close()
        end

        -- 执行备份
        local command = string.format('bin\\adb pull /dev/mtd4 "%s" > NUL 2>&1', desktop_path)
        os.execute(command)

        print(colors.cyan .. colors.bright .."[".. colors.green .."√".. colors.cyan .. colors.bright .."]".. colors.blue .. colors.bright .." 备份完成，已保存至桌面:\n".. colors.yellow .. colors.bright .. desktop_path .. colors.reset)
		print(colors.cyan .. colors.bright .."---------------------------------------------------".. colors.reset)
		
    else
        print(colors.cyan .. colors.bright .."[".. colors.red .."!".. colors.cyan .. colors.bright .."]".. colors.red .." 已选择无需备份，跳过备份步骤".. colors.reset)
		print(colors.cyan .. colors.bright .."---------------------------------------------------".. colors.reset)
    end
end

local function upload_flash_files()
    exec('bin\\adb shell killall -9 zte_ufi')
    exec('bin\\adb shell killall -9 zte_mifi')
    exec('bin\\adb shell killall -9 zte_cpe')
    exec('bin\\adb shell killall -9 goahead')
    adb_push('mtd.bin', '/tmp/mtd4.bin')
    exec('bin\\adb shell mkdir -p /mnt/userdata/temp/')
end

local function write_flash_script()
    -- 传入设备
    adb_push("file\\flash.sh", "/mnt/userdata/temp/flash.sh")
    exec('bin\\adb shell chmod +x /mnt/userdata/temp/flash.sh')
end

local function final_confirmation()
    print()
    print(colors.yellow .. colors.bright .."全部文件已".. colors.green .."推送成功".. colors.yellow .. colors.bright .."，文件完整".. colors.green .."校验完成")
	print()
    print(colors.yellow .. colors.bright .."请二次确认您提供的".. colors.red .."文件是否正确".. colors.yellow .. colors.bright .."，这是您".. colors.red .."最后的机会。")
    print(colors.yellow .. colors.bright .."如果".. colors.green .."确认无误请连续按5次回车".. colors.yellow .. colors.bright .."。".. colors.red .."否则，立刻拔掉机器!".. colors.reset)
    for i = 1, 5 do io.read() end
end

local function execute_flash()
    print(colors.red .. colors.bright .."警告：".. colors.green .."即将开始刷写".. colors.yellow .. colors.bright .."，".. colors.red .. colors.bright .."本窗口会被adb占用。".. colors.reset)
    print(colors.red .. colors.bright .."此时不要操作键盘，以防错误指令输入！！！".. colors.reset)
	print(colors.green .. colors.bright .."读懂了请再按两次回车，感谢配合！".. colors.reset)
    for i = 1, 2 do io.read() end
    print(colors.cyan .. colors.bright .."[".. colors.green .."√".. colors.cyan .. colors.bright .."]".. colors.green ..  colors.bright .."刷写流程正在进行，不要关闭本窗口，请耐心等待设备重启....".. colors.reset)
    os.execute("bin\\adb shell ./mnt/userdata/temp/flash.sh &")
	print()
    print(colors.cyan .. colors.bright .."[".. colors.red .."!".. colors.cyan .. colors.bright .."]".. colors.green ..  colors.bright .."设备刷写完成，请等待设备开机，感谢使用。".. colors.reset)
	print(colors.green .. colors.bright .."机器插上闪一下灯关机就是砖了，请用编程器救回！".. colors.reset)
    os.execute("pause") -- 按下任意键
end

local function print_flash()
    print(colors.cyan .. colors.bright .."[".. colors.blue .. colors.bright .."$".. colors.cyan .. colors.bright .."]".. colors.blue .." 请等待文件与变量参数传入设备......".. colors.reset)
end

local function print_tip()
    print(colors.cyan .. colors.bright .."---------------------------------------------------".. colors.reset)
end

------------------ 主流程 ------------------
is_adb_device_connected()

print(colors.yellow .. colors.bright .."请将要写入的文件拖入此窗口后按回车：".. colors.red)
local user_path = io.read()
print(colors.reset)
copy_to_workdir(user_path)

local local_md5 = get_local_md5("mtd.bin")
adb_push("mtd.bin", "/tmp/mtd4.bin")
local device_md5 = get_device_md5("/tmp/mtd4.bin")
compare_md5(local_md5, device_md5)

prepare_device_environment()
optional_backup()
print_flash()
upload_flash_files()
print_tip()
write_flash_script()
final_confirmation()
execute_flash()