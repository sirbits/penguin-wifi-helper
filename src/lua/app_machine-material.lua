-- machine_material.lua
-- 通过adb获取设备nv参数并汉化后直观的展示给用户
-- 
-- 版权 (C) 2025 企鹅君Punguin
--
-- 本程序是自由软件：你可以根据自由软件基金会发布的GNU Affero通用公共许可证的条款，即许可证的第3版或（您选择的）任何后来的版本重新发布它和/或修改它。。
-- 本程序的发布是希望它能起到作用。但没有任何保证；甚至没有隐含的保证。本程序的分发是希望它是有用的，但没有任何保证，甚至没有隐含的适销对路或适合某一特定目的的保证。 参见 GNU Affero通用公共许可证了解更多细节。
-- 您应该已经收到了一份GNU Affero通用公共许可证的副本。 如果没有，请参见<https://www.gnu.org/licenses/>。
--
-- 联系我们：3618679658@qq.com
-- ChatGPT协助制作编写

-- 设置标题与窗口大小
os.execute("title 设备信息(By 企鹅君punguin)")
os.execute("mode con: cols=57 lines=35")

-- 引入外部库
local path = require("lua\\path") -- 工具路径变量库
local colors = require("lua\\colors") -- ANSI颜色码库
local delay = require("lua\\sleep") -- 倒计时操作

-- 让用户等待
print(colors.cyan .. colors.bright .. "正在获取..." .. colors.reset)
print() -- 给出一行空行可以让界面美观

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

-- 设置 nv 查询命令（带连接检测）
function get_nv_value(param)
	is_adb_device_connected()  -- 检查设备，若未连接会退出脚本

	local command = "bin\\adb shell nv get " .. param
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()

	local value = result:gsub("%s+", "")
	return value
end

-- 定义对应参数(太多不想写注释)
local intype = get_nv_value("zcgmi")
local fota_platform = get_nv_value("fota_platform")
local cr_version = get_nv_value("cr_version")
local remo_web_sw_version = get_nv_value("remo_web_sw_version")
local hw_version = get_nv_value("hw_version")
local os_url = get_nv_value("os_url")
local Language = get_nv_value("Language")
local fota_oem = get_nv_value("fota_oem")
local apn_mode = get_nv_value("apn_mode")
local default_apn = get_nv_value("default_apn")
local SSID1 = get_nv_value("SSID1")
local m_SSID = get_nv_value("m_SSID")
local DMZEnable = get_nv_value("DMZEnable")
local upnpEnabled = get_nv_value("upnpEnabled")
local sntp_timezone = get_nv_value("sntp_timezone")
local wifiEnabled = get_nv_value("wifiEnabled")
local max_station_num = get_nv_value("MAX_Station_num")
local sim_unlock_code = get_nv_value("sim_unlock_code")
local remo_sim_admin_password = get_nv_value("remo_sim_admin_password")
local admin_Password = get_nv_value("admin_Password")
local dhcpDns = get_nv_value("dhcpDns")
local tr069_enable = get_nv_value("tr069_enable")
local tr069_acs_url = get_nv_value("tr069_acs_url")
-- Remo专属内容 add Start 2025.06.25
local remo_sim_select = get_nv_value("remo_sim_select_display_type")
local remo_root_server_url = get_nv_value("fota_request_host")
local remo_root_server_url2 = get_nv_value("remo_fota_request_host")
local remo_root_server_url3 = get_nv_value("remo_dm_request_host")
local remo_root_server_port3 = get_nv_value("remo_dm_request_port")
local remo_root_server_path3 = get_nv_value("remo_dm_request_path")
local remo_config_server_url = get_nv_value("xinxun_iot_http_get_config_host")
local remo_config_server_path = get_nv_value("xinxun_iot_http_get_config_path")
local remo_led_server_url = get_nv_value("xinxun_iot_http_led_control_host")
local remo_led_server_path = get_nv_value("xinxun_iot_http_led_control_path")
local remo_flow_server_url = get_nv_value("xinxun_iot_http_flow_report_host")
local remo_flow_server_path = get_nv_value("xinxun_iot_http_flow_report_path")
local remo_info_server_url = get_nv_value("xinxun_iot_http_info_report_host")
local remo_info_server_path = get_nv_value("xinxun_iot_http_info_report_path")
-- Remo专属内容 add End
local fota_updateMode = get_nv_value("fota_updateMode")
local fota_updateIntervalDay = get_nv_value("fota_updateIntervalDay")
local fota_version_delta_url = get_nv_value("fota_version_delta_url")
local tc_enable = get_nv_value("tc_enable")
local tc_uplink = get_nv_value("tc_uplink")
local tc_downlink = get_nv_value("tc_downlink")

-- 清屏
os.execute("cls")

-- 显示结果
if intype ~= "" then
	print(colors.green .. colors.bright .. "设备类型: " .. intype .. "          搭载的平台:" .. fota_platform .. colors.reset)
else
	print(colors.cyan .. colors.bright .. "══════ 系统信息══════════════════════════════════════════" .. colors.reset)
	print(colors.red .. colors.bright .. "无法获取设备类型与搭载的平台" .. colors.reset)
end
if remo_web_sw_version ~= "" then
	print(colors.yellow .. colors.bright .. "软件版本: " .. remo_web_sw_version .. colors.reset)
elseif cr_version ~= "" then
	print(colors.yellow .. colors.bright .. "软件版本: " .. cr_version .. colors.reset)
else
	print(colors.red .. colors.bright .. "无法获取软件版本" .. colors.reset)
end
if hw_version ~= "" then
	print(colors.yellow .. colors.bright .. "硬件版本: " .. hw_version .. colors.reset)
else
	print(colors.red .. colors.bright .. "无法获取硬件版本" .. colors.reset)
end
if os_url ~= "" then
	print("厂家官网: " .. os_url)
else
	print(colors.red .. colors.bright .. "厂家官网:无法获取,可能为空!" .. colors.reset)
end
if Language ~= "" then
	print(colors.green .. colors.bright .. "设备语言: " .. Language .. "            生产厂家:" .. fota_oem .. colors.reset)
else
	print(colors.red .. colors.bright .. "无法获取设备语言与生产厂家" .. colors.reset)
end
if apn_mode ~= "" then
	print(colors.cyan .. colors.bright .. "══════ 联网信息══════════════════════════════════════════" .. colors.reset)
	print(colors.yellow .. colors.bright .. "APN模式: " .. apn_mode .. "            当前APN: " .. default_apn .. colors.reset)
else
	print(colors.cyan .. colors.bright .. "══════ 联网信息══════════════════════════════════════════" .. colors.reset)
	print(colors.red .. colors.bright .. "无法获取APN信息" .. colors.reset)
end
if DMZEnable ~= "" then
	print(colors.yellow .. colors.bright .. "dmz状态: " .. DMZEnable .. "               upnp状态: " .. upnpEnabled .. colors.reset)
else
	print(colors.red .. colors.bright .. "无法获取dmz与upnp信息" .. colors.reset)
end
print(colors.cyan .. colors.bright .. "══════ WIFI信息══════════════════════════════════════════" .. colors.reset)
if max_station_num ~= "" then
	print(colors.green .. colors.bright .. "WIFI开启: " .. wifiEnabled .. "              最大连接数: " .. max_station_num .. "个" .. colors.reset)
else
	print(colors.red .. colors.bright .. "无法获取wifi信息" .. colors.reset)
end
if SSID1 ~= "" then
	print(colors.yellow .. colors.bright .. "当前WIFI名称: " .. SSID1 .. "   多重WIFI名称: " .. m_SSID .. colors.reset)
else
	print(colors.red .. colors.bright .. "无法获取wifi信息" .. colors.reset)
end
print(colors.cyan .. colors.bright .. "══════ 网络信息══════════════════════════════════════════" .. colors.reset)
if dhcpDns ~= "" then
	print(colors.bright .. "后台地址: " .. dhcpDns .. colors.reset)
else
	print(colors.red .. colors.bright .. "无法获取后台信息" .. colors.reset)
end
if admin_Password ~= "" then
	print(colors.yellow .. colors.bright .. "后台密码: " .. admin_Password .. colors.reset)
else
	print(colors.red .. colors.bright .. "无法获取后台密码" .. colors.reset)
end
if sim_unlock_code ~= "" then
    print(colors.cyan .. colors.bright .. "══════ 密码相关══════════════════════════════════════════" .. colors.reset)
	print(colors.yellow .. colors.bright .. "SIM解锁码: " .. sim_unlock_code .. colors.reset)
else
end
if remo_sim_admin_password ~= "" then
    print(colors.cyan .. colors.bright .. "══════ 密码相关══════════════════════════════════════════" .. colors.reset)
	print(colors.yellow .. colors.bright .. "SIM模式: " .. remo_sim_select .. colors.reset)
	print(colors.yellow .. colors.bright .. "SIM解锁码: " .. remo_sim_admin_password .. colors.reset)
else
end
print(colors.cyan .. colors.bright .. "══════ 远程控制══════════════════════════════════════════" .. colors.reset)

-- tr069显示
if tr069_enable ~= "" then
	print(colors.yellow .. colors.bright .. "tr069(acs)开关: " .. tr069_enable .. "            tr069地址：" .. tr069_acs_url .. colors.reset)
	print(" ")
else
	print(" ")
end

-- 自动升级显示
if fota_updateMode ~= "" then
	if fota_updateMode == "0" then
		print(colors.yellow .. colors.bright .. "自动升级：关闭" .. colors.reset)
	else
		print(colors.yellow .. colors.bright .. "自动升级： 是" ..
		      "       检测时间: " .. fota_updateIntervalDay .. "天" .. colors.reset)
	end
	print(" ")
else
	print()
end

-- 限速显示
if tc_enable ~= "" then
	if tc_enable == "0" then
		print(colors.yellow .. colors.bright .. "限速开启: 否" .. colors.reset)
	else
		print(colors.yellow .. colors.bright .. "限速开启: 是" ..
		      "       上传速率: " .. tc_uplink ..
		      "       下载速率: " .. tc_downlink .. colors.reset)
	end
	print(" ")
else
	print(colors.red .. colors.bright .. "无法获取TC，设备应该不支持" .. colors.reset)
end

-- Remo专属远程服务器显示
local has_remo = false
if remo_root_server_url ~= "" then
	print(colors.yellow .. colors.bright .. "主服务器: " .. remo_root_server_url .. colors.reset)
	has_remo = true
end
if remo_root_server_url2 ~= "" then
	print(colors.yellow .. colors.bright .. "备用服务器: " .. remo_root_server_url2 .. colors.reset)
	has_remo = true
end
if remo_root_server_url3 ~= "" then
	local url3 = remo_root_server_url3
	if remo_root_server_port3 ~= "" then
		url3 = url3 .. ":" .. remo_root_server_port3
	end
	if remo_root_server_path3 ~= "" then
		url3 = url3 .. "/" .. remo_root_server_path3
	end
	print(colors.yellow .. colors.bright .. "备用服务器: " .. url3 .. colors.reset)
	has_remo = true
end
if remo_config_server_url ~= "" and remo_config_server_path ~= "" then
	print(colors.yellow .. colors.bright .. "配置服务器: " .. remo_config_server_url .. "/" .. remo_config_server_path .. colors.reset)
	has_remo = true
end
if remo_led_server_url ~= "" and remo_led_server_path ~= "" then
	print(colors.yellow .. colors.bright .. "LED控制服务器: " .. remo_led_server_url .. "/" .. remo_led_server_path .. colors.reset)
	has_remo = true
end
if remo_flow_server_url ~= "" and remo_flow_server_path ~= "" then
	print(colors.yellow .. colors.bright .. "流量上报服务器: " .. remo_flow_server_url .. "/" .. remo_flow_server_path .. colors.reset)
	has_remo = true
end
if remo_info_server_url ~= "" and remo_info_server_path ~= "" then
	print(colors.yellow .. colors.bright .. "信息上报服务器: " .. remo_info_server_url .. "/" .. remo_info_server_path .. colors.reset)
	has_remo = true
end
if has_remo then
	print(" ")
end

print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════════════════" .. colors.reset)
print()

-- 按下任意键退出程序
os.execute("pause")