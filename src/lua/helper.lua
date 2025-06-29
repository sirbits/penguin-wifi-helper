-- helper.lua
-- 企鹅WIFI助手 一个整合工具箱,让用户便携管理设备
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
os.execute("title 企鹅WIFI助手(ChatGPT协助制作编写)                      当前版本: 5.0                     作者QQ:3618679758，官方QQ群:725700912 ")
os.execute("mode con: cols=113 lines=32")

-- 引入外部库
local path = require("lua\\path") -- 工具路径变量库
local colors = require("lua\\colors") -- ANSI颜色码库
local delay = require("lua\\sleep") -- 倒计时操作

-- 获取脚本当前目录
local script_dir = debug.getinfo(1, "S").source:match("@(.*[/\\])")

-- 设置ADB命令并返回结果
local function exec_command(cmd)       -- 定义cmommand类型标签,使用类似cmd来进行
    local file = io.popen(cmd)         -- 处理返回类型cmd
    local output = file:read("*all")   -- 类型All
    file:close()                       -- 返回重定义
    return output                      -- 输出
end

-- 检查ADB连接状态
local function check_adb_status()
    local adb_path = path.adb -- 调用adb.exe
    -- 运行 adb devices 命令来获取连接的设备列表
    local adb_output = exec_command(adb_path .. " devices 2>nul")

    -- 检查输出是否包含有效设备信息
    local has_device = false        -- 匹配内容device
    local is_offline = false        -- 匹配内容offline
    for line in adb_output:gmatch("[^\r\n]+") do   -- 设定输出类型匹配
        if line:match("device$") then      -- 匹配内容device
            has_device = true              -- 如果是,输出device对应内容
        elseif line:match("offline") then  -- 匹配内容offline
            is_offline = true              -- 如果是,输出device内容并包含offline参数
        end
    end

    -- 根据检测结果输出，并设定文本颜色
    if has_device and not is_offline then
        print(colors.yellow .. colors.bright .. "设备状态：" .. colors.reset .. colors.green .. colors.bright .."已连接" .. colors.reset)
    elseif is_offline then
        print(colors.yellow .. colors.bright .. "设备状态：" .. colors.reset .. colors.green ..  colors.bright .."已连接(".. colors.reset .. colors.red .."离线" .. colors.reset .. colors.green ..  colors.bright ..")".. colors.reset)
    else
        print(colors.yellow .. colors.bright .. "设备状态：" .. colors.reset .. colors.red .. "无设备" .. colors.reset)
    end
end

-- 封装检查串口连接的函数
function check_serial()
    -- 检测系统上是否有可用的串口
    local function is_serial_port_connected()
        for i = 1, 256 do
            local com_port = "\\\\.\\COM" .. i
            local file = io.open(com_port, "r")
            if file then
                file:close()
                return true -- 如果打开成功，说明有串口
            end
        end
        return false -- 如果没有打开成功，说明没有串口
    end

    -- 输出结果
    if is_serial_port_connected() then
	    print(colors.yellow .. colors.bright .. "串口状态(AT等)：" .. colors.reset .. colors.green .. colors.bright .."已连接" .. colors.reset)
    else
	    print(colors.yellow .. colors.bright .. "串口状态(AT等)：" .. colors.reset .. colors.red .. "无设备" .. colors.reset)
    end
end

-- 定义一个函数来获取云端版本信息
local function check_version()
    local local_version = "5.0"  -- 替换为本地的版本号
    local temp_version_file = "version.ini" -- 临时版本文件
    
    -- 从版本文件中提取云端版本号
    local function get_version_from_html(file_path)
        local file = io.open(file_path, "r")
        if not file then
            return nil
        end
        for line in file:lines() do
            local version = line:match("%d.%d") -- "%d.%d"为版本号格式
            if version then
                file:close()
                return version
            end
        end
        file:close()
        return nil
    end
    
    local cloud_version = get_version_from_html(temp_version_file)
    --os.remove(temp_version_file) -- 删除临时版本文件(从4.5版本开始,禁用该指令)

    -- 输出版本信息
    if cloud_version then
        print(colors.bright .."最新版本: " .. cloud_version .. "  当前版本: " .. local_version .. colors.reset)
    else
        print(colors.bright .."无法获取云端版本" .. colors.reset)
    end
end

local function mtd_check() --显示设备MTD状态
        print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════════════════════════════════════════════════════════════════════════" .. colors.reset)
        print("以下为您的设备MTD挂载状态")
        print()
        os.execute("bin\\adb shell cat /proc/mtd")
        print()
		print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════════════════════════════════════════════════════════════════════════" .. colors.reset)
        print("一般情况下,mtd4:'rootfs' ")
		print(" 小部分机器是mtd4:'imagefs'")
		print("  本工具箱目前仅支持mtd4:'rootfs'的机器")
		print("   后期可能考虑添加mtd5机器支持")
		print()
		os.execute("pause")
end

local function install_drive() --三合一驱动安装
  print(colors.cyan .. colors.bright .. "════════════════════════════════════════════════════════════════════════════════════════════════════════════════" .. colors.reset)
  print("请选择要安装的驱动(没安过建议全安)：")
  print()
  print(colors.cyan .. colors.bright .. "           1.通用安卓ADB驱动    2.中兴微专用lnterface驱动    3.移远的ASR专用驱动     4.紫光SPD通用驱动" .. colors.reset)
  print()
  print(colors.red .. colors.bright .."提示:中兴驱动为秒安驱动,安装过程只会弹出cmd。如果安装成功则会直接关闭。".. colors.reset)
  print()
  io.write(colors.green .. "请输入数字并按 Enter 键: " .. colors.reset)
  local drive_selection = io.read()
    if drive_selection == "1" then
     os.execute("start file\\drive\\vivo-drive.exe")
    elseif drive_selection == "2" then
     os.execute("start file\\drive\\zxicser.exe")
    elseif drive_selection == "3" then
     os.execute("start file\\drive\\Quectel_LTE_Windows_USB_Driver.exe")
    elseif drive_selection == "4" then
     os.execute("start file\\drive\\SPD_Driver\\DriverSetup.exe")
    end
end

local function set_adb()   -- 设置设备adb(3.21版本代码,4.0整合)
  print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════════════════════════════════════════════════════════════════════════" .. colors.reset)
  print()
  -- 让用户输入IP地址并保存为临时变量ipAddress
  print(colors.red .. colors.bright .. "警告!请先连接设备WIFI或网络,否则程序卡死[滑稽笑]" .. colors.reset)
  print()
  print()
  io.write(colors.green .. "设备WEB地址(例如 192.168.100.1): "  .. colors.red .. colors.bright)
  local ipAddress = io.read()
  print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════════════════════════════════════════════════════════════════════════" .. colors.reset)
  -- 打印操作选项菜单
  print()
  print(colors.cyan .. colors.bright .."使用小贴士:".. colors.reset .. colors.green .. "部分设备厂家删除adbd后端,导致开完adb后依然是无法使用状态(离线模式),详情请看助手主页设备状态")
  print()
  print(colors.cyan .. colors.bright .." =------".. colors.magenta .. colors.bright .."选择模式" .. colors.cyan .. colors.bright .."------------------------------------------------------------------------------------------------=")
  print(colors.cyan .. colors.bright .." =                                                                                                              =")
  print(colors.cyan .. colors.bright .." =    ".. colors.reset .. colors.yellow .."1. 调试模式(ADB+AT+网络)     2. 工厂端口模式(仅AT)       3. 仅系统模式(慎用)        4. 关闭所有模式       ".. colors.cyan ..colors.bright .."=")
  print(colors.cyan .. colors.bright .." =                                                                                                              =")
  print(colors.cyan .. colors.bright .." =    ".. colors.reset .. colors.yellow .."5. Remo专用调试模式(ADB+AT+网络)                                                                          ".. colors.cyan ..colors.bright .."=")
  print(colors.cyan .. colors.bright .." =                                                                                                              =")
  print(colors.cyan .. colors.bright .." =--------------------------------------------------------------------------------------------------------------=")
  print()
  -- 让用户选择相应的操作并保存临时变量
  io.write(colors.green .. "请输入数字并按 Enter 键: ".. colors.red .. colors.bright)
  local adb_selection = io.read()
  -- 筛选变量数据并执行对应操作
    if adb_selection == "1" then
      print(colors.blue .. colors.bright)
      os.execute('bin\\curl "http://'..ipAddress..'/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=2"')
      os.execute('bin\\curl "http://'..ipAddress..'/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=1"')
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=SET_DEVICE_MODE&debug_enable=1"')
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=SET_DEVICE_MODE&debug_enable=1&password=MM888@Qiruizhilian20241202"')
      print(colors.green .. colors.bright .."\n稍后重启设备(5秒)....." .. colors.blue .. colors.bright)
      delay.sleep(5)
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=REBOOT_DEVICE"')
      os.execute('bin\\curl "http://'..ipAddress..'/goform/goform_set_cmd_process?goformId=REBOOT_DEVICE"')
      print(colors.green .. colors.bright .."\n操作已完成，稍后返回" .. colors.reset)
      delay.sleep(3)
    elseif adb_selection == "2" then
      print(colors.blue .. colors.bright)
      os.execute('bin\\curl "http://'..ipAddress..'/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=2"')
      print(colors.green .. colors.bright .."\n稍后重启设备(5秒)....." .. colors.blue .. colors.bright)
      delay.sleep(5)
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=REBOOT_DEVICE"')
      os.execute('bin\\curl "http://'..ipAddress..'/goform/goform_set_cmd_process?goformId=REBOOT_DEVICE"')
      print(colors.green .. colors.bright .."\n操作已完成，稍后返回" .. colors.reset)
      delay.sleep(3)
    elseif adb_selection == "3" then
      print(colors.blue .. colors.bright) 
      os.execute('bin\\curl "http://'..ipAddress..'/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=3"')
      print(colors.green .. colors.bright .."\n稍后重启设备(5秒)....." .. colors.blue .. colors.bright)
      delay.sleep(5)
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=REBOOT_DEVICE"')
      os.execute('bin\\curl "http://'..ipAddress..'/goform/goform_set_cmd_process?goformId=REBOOT_DEVICE"')
      print(colors.green .. colors.bright .."\n操作已完成，稍后返回" .. colors.reset)
      delay.sleep(3)
    elseif adb_selection == "4" then
      print(colors.blue .. colors.bright)
      os.execute('bin\\curl "http://'..ipAddress..'/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=0"')
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=ID_SENDAT&at_str_data=AT%2BZMODE%3D0"')
	  print(colors.green .. colors.bright .."\n稍后重启设备(5秒)....." .. colors.blue .. colors.bright)
      delay.sleep(5)
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=REBOOT_DEVICE"')
      os.execute('bin\\curl "http://'..ipAddress..'/goform/goform_set_cmd_process?goformId=REBOOT_DEVICE"')
      print(colors.green .. colors.bright .."\n操作已完成，稍后返回" .. colors.reset)
      delay.sleep(3)
    elseif adb_selection == "5" then -- 这部分抄袭了ufitool
	  print(colors.red .. colors.bright .."\n\n警告:该方式来源于Remo内部人员" .. colors.blue .. colors.bright)
	  print(colors.red .. colors.bright .."仅适用于第四代机型以前的版本(即24年12月之前),其他版本估计会遇到错误" .. colors.blue .. colors.bright)
	  print("\n")
	  print(colors.green .. colors.bright .."\n正在向系统发送请求....." .. colors.blue .. colors.bright)
	  delay.sleep(2)
	  print(colors.blue .. colors.bright)
	  os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=LOGIN&password=cmVtb19zdXBlcl9hZG1pbl8yMjAx"')
	  os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=LOGIN&password=YWRtaW4%3D"')
	  print(colors.green .. colors.bright .."\n检测到阻止,正在绕过....." .. colors.blue .. colors.bright)
	  delay.sleep(3)
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=REMO_SIM_SELECT_R1865&isTest=false&sim_option_id=3&select_sim_mode=1"')
	  print(colors.green .. colors.bright .."\n已找到临时APi,正在反向劫持adbd....." .. colors.blue .. colors.bright)
	  delay.sleep(2)
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=SysCtlUtal&action=System_MODE&debug_enable=1"')
	  delay.sleep(2)
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=ID_SENDAT&at_str_data=AT%2BZMODE%3D1"')
	  delay.sleep(2)
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?goformId=SET_DEVICE_MODE&debug_enable=1"')
      print(colors.green .. colors.bright .."\n稍后重启设备(5秒)....." .. colors.blue .. colors.bright)
      delay.sleep(5)
      os.execute('bin\\curl "http://'..ipAddress..'/reqproc/proc_post?isTest=false&goformId=RESTORE_FACTORY_SETTINGS"')
      print(colors.green .. colors.bright .."\n操作已完成，稍后返回" .. colors.reset)
      delay.sleep(3)
	elseif About_stealing == "stealing" then
	  A = "俺承认Remo这段代码偷窃自Ufitool"
	  B = "我忍受不了每月那几次的使用机会了"
	  C = "希望苏哥能原谅我吧,望谅解"
	  D = "偷窃行为确实不文明,这样子做我心里也很不安"
	  E = "总之希望苏哥能原谅我,看到这段代码就联系我吧"
	  print ("Test,remo adbd By ufitool")
    end
 end
 
 local function ufi_nv_set() --通过设置标准NV参数来优化设备
 print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════════════════════════════════════════════════════════════════════════" .. colors.reset)
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
		os.execute("bin\\lua54 lua\\helper.lua")
	end
 -- 打印操作选项菜单
  print()
  print(colors.cyan .. colors.bright .."使用小贴士:".. colors.reset .. colors.green .. "在去控的时候如果设备是jffs2等系统，那么工具会尝试将远控程序铲除。")
  print()
  print(colors.cyan .. colors.bright .." =------".. colors.magenta .. colors.bright .."选择模式" .. colors.cyan .. colors.bright .."------------------------------------------------------------------------------------------------=")
  print(colors.cyan .. colors.bright .." =                                                                                                              =")
  print(colors.cyan .. colors.bright .." =    ".. colors.reset .. colors.yellow .."1. SZXF通用优化      2.ZTE本家优化(SZXK)                                                                  ".. colors.cyan ..colors.bright .."=")
  print(colors.cyan .. colors.bright .." =                                                                                                              =")
  print(colors.cyan .. colors.bright .." =    ".. colors.reset .. colors.yellow .."                                                                                                          ".. colors.cyan ..colors.bright .."=")
  print(colors.cyan .. colors.bright .." =                                                                      以后会陆续支持更多设备,请期待助手ota    =")
  print(colors.cyan .. colors.bright .." =--------------------------------------------------------------------------------------------------------------=")
  print()
  -- 让用户选择相应的操作并保存临时变量
  io.write(colors.green .. "请输入数字并按 Enter 键: ".. colors.red .. colors.bright)
  local selection = io.read()
  print(colors.reset)
  -- 筛选变量数据并执行对应操作
    if selection == "1" then
	print()
	print("挂载读写")
	os.execute("bin\\adb shell mount -o remount,rw /")
	print()
	print("关闭并篡改升级")
	os.execute("bin\\adb shell nv set fota_updateMode=0")
	os.execute("bin\\adb shell nv set fota_updateIntervalDay=365")
	os.execute("bin\\adb shell nv set fota_platform=Punguin")
	os.execute("bin\\adb shell nv set fota_token_rs=0")
	os.execute("bin\\adb shell nv set fota_version_delta_id=")
	os.execute("bin\\adb shell nv set fota_version_delta_url=")
	os.execute("bin\\adb shell nv set fota_version_name=")
	os.execute("bin\\adb shell nv set fota_upgrade_result_internal=")
	os.execute("bin\\adb shell nv set fota_oem=QEJ")
	print("篡改远控配置")
	os.execute("bin\\adb shell rm -rf /bin/terminal_mgmt")
	os.execute("bin\\adb shell rm -rf /sbin/ip_ratelimit.sh")
	os.execute("bin\\adb shell nv set traffic_mgmt_enable=0")
	os.execute("bin\\adb shell nv set terminal_mgmt_enable=0")
	os.execute("bin\\adb shell nv set tr069_enable=0")
	os.execute("bin\\adb shell nv set enable_lpa=0")
	os.execute("bin\\adb shell nv set lpa_trigger_host=info.punguin.cn")
	os.execute("bin\\adb shell nv set os_url=http://punguin.cn/")
	os.execute("bin\\adb shell nv set TM_SERVER_NAME=reportinfo.punguin.cn")
	os.execute("bin\\adb shell nv set HOST_FIELD=reportinfo.punguin.cn")
	print("增强功能")
	os.execute("bin\\adb shell nv set sim_auto_switch_enable=0")
	os.execute("bin\\adb shell nv set sim_switch=1")
	os.execute("bin\\adb shell nv set sim_unlock_code=az952#")
	os.execute("bin\\adb shell nv set sim_default_type=1")
	os.execute("bin\\adb shell nv set band_select_enable=1")
	os.execute("bin\\adb shell nv set dns_manual_func_enable=1")
	os.execute("bin\\adb shell nv set tr069_func_enable=1")
	os.execute("bin\\adb shell nv set ussd_enable=1")
	os.execute("bin\\adb shell nv set pdp_type=IPv4v6")
	os.execute("bin\\adb shell nv set zcgmi=SZXF-Punguin")
	print("保存NV设置")
	os.execute("bin\\adb shell nv save")
	print(colors.green .. colors.bright .."nv编辑器：参数已保存".. colors.reset)
	print()
	print(colors.blue .."正在给设备加水印".. colors.reset)
	os.execute([[bin\\adb shell "echo 'copyright = 此设备软件由 &copy; 企鹅君Punguin 修改' >> /etc_ro/web/i18n/Messages_zh-cn.properties"]])
	os.execute([[bin\\adb shell "echo 'copyright = Software by: &copy; Penguin Revise' >> /etc_ro/web/i18n/Messages_en.properties"]])
	os.execute([[bin\\adb shell "echo 'killall zte_de &' >> /etc/ro"]])
	os.execute([[bin\\adb shell "echo 'nv set cr_version=SZXF-Punguin_P001-20250601 &' >> /etc/ro"]])
	print(colors.green .. colors.bright .."出现Read-only file system是正常的".. colors.reset)
	print()
	print()
	print()
	print()
	print()
	print(colors.red .."修改完成，恢复出厂将会丢失更改，不要恢复出厂".. colors.reset)
	print()
	os.execute("pause")  -- 等待用户按任意键继续
	elseif selection == "2" then
            -- 修改设备
			print(colors.green .. colors.bright .."已挂载根目录为可读写，正在停止厂家服务...".. colors.reset)
			os.execute("bin\\adb shell killall fota_Update")
			os.execute("bin\\adb shell killall fota_upi")
			os.execute("bin\\adb shell killall zte_mqtt_sdk &")
			print()
			print(colors.green .. colors.bright .."已关闭多个进程".. colors.reset)
			print()
			print(colors.yellow .."正在优化设备nv配置...".. colors.reset)
			os.execute("bin\\adb shell nv set mqtt_syslog_level=0")
			os.execute("bin\\adb shell nv set dm_enable=0")
			os.execute("bin\\adb shell nv set mqtt_enable=0")
			os.execute("bin\\adb shell nv set tc_enable=0")
			os.execute("bin\\adb shell nv set tc_downlink=")
			os.execute("bin\\adb shell nv set tc_uplink=")
			os.execute("bin\\adb shell nv set tr069_enable=0")
			os.execute("bin\\adb shell nv set fota_updateMode=0")
			os.execute("bin\\adb shell nv set fota_version_delta_id=")
			os.execute("bin\\adb shell nv set fota_version_delta_url=")
			os.execute("bin\\adb shell nv set fota_version_name=")
			os.execute("bin\\adb shell nv set fota_upgrade_result_internal=")
			os.execute("bin\\adb shell nv save")
			print(colors.green .. colors.bright .."nv编辑器：参数已保存".. colors.reset)
			print()
	        print(colors.blue .."正在给设备加水印".. colors.reset)
			os.execute([[bin\\adb shell "echo 'copyright = 此设备软件由 &copy; 企鹅君Punguin 修改' >> /etc_ro/web/i18n/Messages_zh-cn.properties"]])
			os.execute([[bin\\adb shell "echo 'copyright = Software by: &copy; Penguin Revise' >> /etc_ro/web/i18n/Messages_en.properties"]])
			os.execute([[bin\\adb shell "echo 'killall zte_de &' >> /etc/ro"]])
			os.execute([[bin\\adb shell "echo 'nv set cr_version=SZXK-Punguin_P049U-20250601 &' >> /etc/ro"]])
			print(colors.green .. colors.bright .."出现Read-only file system是正常的".. colors.reset)
			print()
			print(colors.yellow .."正在修改设备文件".. colors.reset)
			os.execute("bin\\adb push file\\gsmtty /bin")
			os.execute('bin\\adb shell "chmod +x /bin/gsmtty"')
			os.execute("bin\\adb shell gsmtty AT+ZCARDSWITCH=0")
			os.execute("bin\\adb push file\\hosts /etc/hosts")
			os.execute("bin\\adb shell chmod +x /etc/hosts")
			os.execute("bin\\adb shell rm -r -rf /sbin/tc_tbf.sh")
			os.execute("bin\\adb push file\\tc_tbf.sh /sbin/tc_tbf.sh")
            os.execute("bin\\adb shell rm -rf /sbin/start_update_app.sh")
            os.execute("bin\\adb shell rm -rf /bin/fota_Update")
            os.execute("bin\\adb shell rm -rf /bin/fota_upi")
			os.execute([[bin\\adb shell "echo 'killall zte_de &' >> /etc/ro"]])
            os.execute([[bin\\adb shell "echo 'killall ztede_timer &' >> /etc/ro"]])
            os.execute([[bin\\adb shell "echo 'killall zte_mqtt_sdk &' >> /etc/ro"]])
			print()
			print(colors.yellow .."清理临时文件...".. colors.reset)
			os.execute("bin\\adb shell rm -r -rf /bin/miniupnp")
			os.execute("adb shell rm -r -rf /bin/gsmtty")
			os.execute("bin\\adb shell reboot")
			print()
			print(colors.green .. colors.bright .."完成,请等待设备开机".. colors.reset)
	        print()
	        print()
	        print()
	        print()
	        os.execute("pause")  -- 等待用户按任意键继续
	end
 end

-- 打印选项
local function uisoc()
    print(colors.cyan .. colors.bright .. "════════════════════════════════════════════════════════════════════════════════════════════════════════════════" .. colors.reset)
    print("\n")
	print()
    print(colors.yellow .. "       1.查询聚火SN" .. colors.reset) 
	print()
    print(colors.blue .. "          2.修改设备参数" .. colors.reset) 
	print()
    print(colors.cyan .. "             3.ResearchDownload" .. colors.reset) 
	print()
    print(colors.green .. "                4.spd_dump" .. colors.reset) 
	print()
    print(colors.white .. "                   5.切卡" .. colors.reset) 
	print()
	print("按下回车返回")
	print()
	print()
	print()
	print()
	io.write(colors.green .. "请输入并按Enter键: " .. colors.reset)
        local choice111 = io.read()
        if choice111 == "1" then
            os.execute("explorer file\\tool\\SN查询")
        elseif choice111 == "2" then
		    os.execute("explorer file\\tool\\Pandora_R22.20.1701")
        elseif choice111 == "3" then
		    os.execute("explorer file\\tool\\ResearchDownload")
        elseif choice111 == "4" then
		    os.execute("explorer file\\tool\\spd_dump")
        elseif choice111 == "5" then
		    print()
            print(colors.red .. colors.bright .. "警告!请先连接设备WIFI或网络,否则程序卡死[滑稽笑]" .. colors.reset)
            print()
            print()
		    io.write(colors.green .. "设备WEB地址(例如 192.168.100.1): "  .. colors.red .. colors.bright)
             local ipAddress = io.read()
			 os.execute('start "" "http://'..ipAddress..'//postesim?postesim=%7B%22esim%22:0%7D"')
		else
            os.execute("bin\\lua54 lua\\helper.lua")
        end
end

 local function mifi_Studio() --利用MifiStudio来提取设备文件
    print(colors.cyan .. colors.bright .. "════════════════════════════════════════════════════════════════════════════════════════════════════════════════" .. colors.reset)
	print()
	print()
	print(colors.green .. colors.bright .."使用小贴士:".. colors.reset .. colors.green .. " 1.本工具是直接运行MIFI之家的ZXIC-RomKit进行提取,该工具在助手3.0时就已经有了")
	print()
	print()
	print()
	print()
	print(colors.red .. '提取完成后,您提取的内容会在ZXIC-RomKit根目录以"Z."开头的文件夹内'.. colors.reset)
	print()
	print(colors.bright .."请选择要进行的操作：")
    print()
    print(colors.cyan .. colors.bright .. "                      1.打开工具           2.打开提取目录          3.返回" .. colors.reset)
	print()
	io.write(colors.green .. "请输入数字并按 Enter 键: " .. colors.reset)
    local user_Studio_selection = io.read()
        if user_Studio_selection == "1" then
        os.execute("start file\\ZXIC-RomKit\\_ADB一键提取固件.bat")
        elseif user_Studio_selection == "2" then
		os.execute("explorer file\\ZXIC-RomKit")
        end
 end

local function AD()  --为了维持生计所接的一个小广告。
os.execute('start "" "https://shimo.im/docs/RKAWMBJLgXu96aq8/"')
end

 local function set_wifi()  -- 设置zxic中文WIFI,4.1版本功能,24.11.14
    print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════════════════════════════════════════════════════════════════════════" .. colors.reset)
    print()
	print(colors.red .. "使用须知:".. colors.blue .. colors.bright .."目前版本暂不支持给您的路由器设置WiFi密码,只支持修改您的WiFi名称,支持中文")
    print()
	print("         " .. "支持小部分表情符号与大部分中文字符。如果遇到WiFi消失、WiFi无法连接等问题,请长按恢复出厂按钮。")
	print()
	print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════════════════════════════════════════════════════════════════════════" .. colors.reset)
	io.write(colors.green .. "设备WEB地址(例如 192.168.100.1): "  .. colors.red .. colors.bright)
    local YOUR_IP = io.read()
    print()
    print(colors.blue .. colors.bright .."请先在电脑上登录设备后台: http://".. YOUR_IP .."/".. colors.reset)
    print()
    io.write(colors.green .."请输入你的 SSID: ".. colors.red .. colors.bright)
    local YOUR_SSID = io.read()
    print(colors.reset)
    io.write(colors.green .."最大接入设备数: ".. colors.red .. colors.bright)
    local MAX_Access = io.read()
    print(colors.reset)
    -- Prepare the POST data
    local DATA = "goformId=SET_WIFI_SSID1_SETTINGS&ssid=" .. YOUR_SSID ..
                "&broadcastSsidEnabled=0&MAX_Access_num=" .. MAX_Access ..
                "&security_mode=OPEN&cipher=2&NoForwarding=0&show_qrcode_flag=0&security_shared_mode=NONE"

    local TYPES = {
        'goform/goform_set_cmd_process',
        'reqproc/proc_post'
    }

    -- Function to perform the POST request
    local function requ(type)
        local command = "bin\\curl -s -X POST -d \"" .. DATA .. "\" \"http://" .. YOUR_IP .. "/" .. type .. "\" 1>nul 2>nul"
        os.execute(command)
    end

    -- Loop through the request types and execute
    for _, TYPE in ipairs(TYPES) do
        requ(TYPE)
    end

    -- Output result
    print(colors.green .."如果此时WiFi断开代表设置成功")
    print("否则失败")
    io.read(1)
end

-- 打印标题
local function print_title1()
    os.execute("cls")  -- 清屏
	print("(C) 2020-2025 企鹅君punguin. All rights reserverd.".. colors.cyan .. colors.bright .. "                XZ.卸载        RE.刷新助手      EXIT.退出助手\n".. colors.reset)

end

-- 打印公告
local function print_announcement()
    print()
    print(colors.blue .. colors.bright .. "助手公告:".. colors.red .."本助手在4G圈子已经完美，即将面临停更！\n" .. colors.reset)
    check_adb_status()  -- ADB状态检测
    check_serial() -- 串口状态检测
	print(colors.green .. "\n" .. "Tips:助手官方QQ群聊已升级2000人大群,欢迎加入" .. colors.underline_blue .. colors.bright .. "725700912" .. colors.reset)
	print()
	check_version() -- 添加版本信息检测
	print(colors.blue .. colors.bright .. "若云端有新版本,请输入'new'下载" .. colors.reset)
end

-- 打印选项
local function print_menu()
	print()
	print()
    print(colors.yellow .. "            01.设备信息           02.设置设备adb       03.驱动安装       04.ADB终端      05.设备管理器    " .. colors.reset)
    print(colors.cyan .. colors.bright .. "          =------ 操作设备文件-------------------------------------------------------------------------=" .. colors.reset)
    print(colors.cyan .. colors.bright .."          =                                                                                            =".. colors.reset)
    print(colors.cyan .. colors.bright .."          =".. colors.reset .. colors.yellow .."    A.提取MTD4分区    B.调用dongle刷入MTD4     C.快速MTD刷写工具      D.查看机器mtd类型     ".. colors.reset .. colors.cyan ..colors.bright .."=" .. colors.reset)
    print(colors.cyan .. colors.bright .."          =                                                                                            =".. colors.reset)
	print(colors.cyan .. colors.bright .."          =".. colors.reset .. colors.yellow .."    E.写入WEB         F.中兴微通杀完美去控     G.固件提取与解打包                           ".. colors.reset .. colors.cyan ..colors.bright .."=" .. colors.reset)
	print(colors.cyan .. colors.bright .."          =                                                                                            =".. colors.reset)
    print(colors.cyan .. colors.bright .. "          =--------------------------------------------------------------------------------------------=" .. colors.reset)
	print("\n")
	print(colors.cyan .. colors.bright .. "     工具与导航栏:" .. colors.reset)
    print()
	print(colors.yellow .. "         1.串口工具         2.云小帆助手      3.1869工具      4.西瓜味asr工具(最终)   5.Orz0000工具(鸡蛋姐)" .. colors.reset)
	print()
	print(colors.yellow .. "         6.zxic设置WIFI     7.流量失踪器      ".. colors.underline_magenta .. "8.紫光专区入口" .. colors.reset .."  ".. colors.underline_green .. colors.bright .."9.要稳流量卡吗？" .. colors.reset)
	print()
	print()
end

-- 用户输入对应的选项
    while true do
    print_title1()            --标题
    print_announcement()      --公告
    print_menu()              --菜单
    io.write(colors.green .. "请输入并按Enter键: " .. colors.reset) --提示用户输入
    local choice = io.read() --捕获用户输入
    if choice == "A" then
        os.execute("start bin\\lua54 lua\\app_zmtd-extract.lua") --提取分区的脚本
    elseif choice == "B" then
		os.execute("cls")
		os.execute("start file\\dongle_fun\\dongle_fun.bat") --调用dongle_fun的Bat
    elseif choice == "C" then
        os.execute("start bin\\lua54 lua\\app_zmtd-brusque.lua")
    elseif choice == "D" then
        mtd_check()
		os.execute("pause")
    elseif choice == "E" then
        os.execute("start bin\\lua54 lua\\app_zfile-web.lua")
	elseif choice == "F" then
        ufi_nv_set()
	elseif choice == "G" then
        os.execute("explorer file\\OpenZxicEditor-For-Windows")
	elseif choice == "H" then
        mifi_Studio()
	elseif choice == "01" then
	    os.execute("start lua\\app_machine-material.lua")
	elseif choice == "02" then
        set_adb()
	elseif choice == "03" then
        install_drive()
	elseif choice == "04" then
        os.execute("start bin\\openadb.bat")
	elseif choice == "05" then
        os.execute("start devmgmt.msc")
	elseif choice == "1" then
        os.execute('start "" "https://atmaster.netlify.app/#/"')
	elseif choice == "2" then
        os.execute("start file\\tool\\YXF_TOOL.exe")
	elseif choice == "3" then
        os.execute("start file\\tool\\ZTE_PATCH_1.1.exe")
	elseif choice == "4" then
        os.execute("start file\\tool\\Watermelon-ASR_Tools.exe")
	elseif choice == "5" then
        os.execute("start file\\tool\\UFITOOL_MTD4.exe")
	elseif choice == "6" then
        set_wifi()
	elseif choice == "7" then
        os.execute('start "" "https://net.arsn.cn/"')
	elseif choice == "8" then
        uisoc()
	elseif choice == "9" then
	    AD()
	elseif choice == "new" then
        os.execute('start "" "http://punguin.cn/web-helper"')
    elseif choice == "C" then
         os.execute("start bin\\lua54 lua\\so.lua")
	elseif choice == "RE" then
        os.execute("bin\\lua54 lua\\helper.lua")
	elseif choice == "XZ" then
        os.execute("start unins000.exe")
		break
    elseif choice == "EXIT" then
        print(colors.red .. "退出工具箱" .. colors.reset)
        break
    else
        print(colors.red .. "无效的选项，请重试。" .. colors.reset)
		os.execute("pause")
    end
end