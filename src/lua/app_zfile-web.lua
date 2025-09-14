-- web.lua
-- 简单的jffs2可读写设备烧录web后台
-- 
-- 版权 (C) 2025-2026 企鹅君Punguin
--
-- 本程序是自由软件：你可以根据自由软件基金会发布的GNU Affero通用公共许可证的条款，即许可证的第3版或（您选择的）任何后来的版本重新发布它和/或修改它。。
-- 本程序的发布是希望它能起到作用。但没有任何保证；甚至没有隐含的保证。本程序的分发是希望它是有用的，但没有任何保证，甚至没有隐含的适销对路或适合某一特定目的的保证。 参见 GNU Affero通用公共许可证了解更多细节。
-- 您应该已经收到了一份GNU Affero通用公共许可证的副本。 如果没有，请参见<https://www.gnu.org/licenses/>。
--
-- 联系我们：3618679658@qq.com
-- ChatGPT协助制作编写

local colors = require("lua\\colors") -- ANSI颜色码库
local delay = require("lua\\sleep") -- 倒计时操作

-- 设置标题终端与定义窗口大小
os.execute("title 企鹅WIFI助手_WEB烧写工具")
os.execute("mode con: cols=66 lines=35")
print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)

-- 定义 executeADBCommand 函数,通过os.execute调用adb命令并捕获结果,用于判断机器是否为可读写并捕获输出
local function executeADBCommand(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result
end

-- 定义 check_file 函数
local function check_file()
    print(colors.blue .. colors.bright .. "搜寻设备..." .. colors.reset)
    delay.sleep(4)
    os.execute("cls")
    -- 运行 adb devices 命令并捕获返回结果
    local adbDevicesCommand = "bin\\adb devices"
    local devicesOutput = executeADBCommand(adbDevicesCommand)

    -- 检查是否有设备连接
    if not string.find(devicesOutput, "\tdevice") then
        print(colors.red .. "当前无设备连接" .. colors.reset)
		os.execute("pause")
        os.exit(1)
    end

    -- 运行 adb touch 命令并捕获返回结果
    local adbCommand = "bin\\adb shell touch /etc_ro/web/test_file"
    local output = executeADBCommand(adbCommand)

    -- 检查返回结果是否包含 "Read-only file system"
    if string.find(output, "Read") then
        print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)
        print(colors.red .. "该机器为只读文件系统 (squashfs)" .. colors.reset)
        print(colors.blue .. colors.bright .. "强行刷入会导致您的设备丢失后台" .. colors.reset)
        os.execute("pause")
        os.exit(1)
    else
        print(colors.green .. colors.bright .."该机器为可写文件系统,支持文件上传(可能是jffs2)".. colors.reset)
        print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)
    end
end

-- 修复 5.1-Build-250816
folderPath = nil -- 先声明全局nil变量
-- End

local function file()
-- 获取用户拖入的文件夹路径
print(colors.yellow .."请将文件夹拖入此窗口，然后按回车键:" ..colors.red)
  -- 修复 5.1-Build-250816
  -- 去除local,改为全局变量
  folderPath = io.read("*l") -- 读取用户输入的文件夹路径
  -- End

-- 去掉可能存在的引号
folderPath = folderPath:gsub("\"", "")

-- 检查文件夹路径是否有效
local checkCommand = string.format("if exist \"%s\" (echo ok) else (echo not found)", folderPath)
local handle = io.popen(checkCommand)
local result = handle:read("*a")
handle:close()

if not result:find("ok") then
    print(colors.red .. "无效的文件夹路径！")
	os.execute("pause")
    os.exit(1)
end
end

-- 获取当前 Lua 脚本所在目录
local function getScriptDirectory()
    local str = arg[0]
    return str:match("(.*/)") or str:match("(.*\\??") or ".\\"
end

-- 创建目录
local function createDirectory(path)
    os.execute("mkdir \"" .. path .. "\"")
end

-- 执行ADB命令并返回结果
local function executeADBCommand(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result
end

-- 备份 /etc_ro/web 文件夹到指定目录
local function backupWebFolder(tempBackupPath)
    print()
    print(colors.green .. "正在备份设备后台WEB文件夹..." .. colors.blue)
    local backupCommand = "bin\\adb pull /etc_ro/web \"" .. tempBackupPath .. "\""
    return executeADBCommand(backupCommand)
end

-- 移动并重命名备份文件夹
local function moveBackupFolder(tempBackupPath, backupDir)
    -- 询问用户输入文件夹名称
	print()
    print(colors.yellow .. "请输入备份文件夹的名称:" .. colors.red)
    local folderName = io.read()
	print(colors.blue)

    -- 移动并重命名文件夹
    local moveCommand = "move /Y \"" .. tempBackupPath .. "\" \"" .. backupDir .. folderName .. "\""
    local moveResult = os.execute(moveCommand)
    print(colors.reset)
	
    -- 检查移动结果
    if moveResult then
	    print()
        print(colors.green .. "备份完成，文件已保存到: " .. backupDir .. folderName .. colors.reset)
		os.execute("explorer TQ")
    else
	    print()
        print(colors.red .. "移动文件失败，请检查权限。" .. colors.reset)
    end
end

-- 封装整个备份流程的函数
local function Backup_web()
    local scriptDir = getScriptDirectory()

    -- 设置备份保存路径
    local tempBackupPath = scriptDir .. "web_backup" -- 直接备份到脚本所在目录
    local backupDir = scriptDir .. "TQ\\"

    -- 询问用户是否备份 /etc_ro/web 文件夹
	print()
    print(colors.yellow .. colors.bright .. "是否备份设备原后台? (y/n)" .. colors.reset)
    local userInput = io.read()

    if userInput == "y" or userInput == "Y" then
        -- 用户选择备份，执行备份操作
        local backupResult = backupWebFolder(tempBackupPath)
        
        -- 检查备份结果
        if backupResult and backupResult:find("error") then
		    print()
            print(colors.red .. "备份失败，请检查设备连接及权限。" .. colors.reset)
        else
            moveBackupFolder(tempBackupPath, backupDir)
        end
    else
        -- 用户选择不备份
		print()
        print(colors.blue .. "已跳过备份操作" .. colors.reset)
    end

    print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════" .. colors.reset)
end

local function up_web()
-- 删除设备上原有的 /etc_ro/web 文件夹
local deleteCommand = "bin\\adb shell rm -rf /etc_ro/web"
os.execute(deleteCommand)

-- 上传整个文件夹到设备
local uploadCommand = string.format("bin\\adb push \"%s\" /etc_ro/web", folderPath)
os.execute(uploadCommand)
print()
print(colors.green .. colors.bright .."上传完成,设备web已替换!"..colors.reset)
end

os.execute("bin\\adb shell mount -o remount,rw /")
check_file() -- 检查设备是否允许读写
file() -- 让用户托入文件
Backup_web() -- 进行后台的备份
up_web() -- 删除设备上原有的WEB并上传新的文件
os.execute("pause")