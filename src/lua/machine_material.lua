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
local intype = get_nv_value("Intype")
local fota_platform = get_nv_value("fota_platform")
local cr_version = get_nv_value("cr_version")
local hw_version = get_nv_value("hw_version")
local os_url = get_nv_value("os_url")
local Language = get_nv_value("Language")
local fota_oem = get_nv_value("fota_oem")
local apn_mode = get_nv_value("apn_mode")
local default_apn = get_nv_value("default_apn")
local SSID1 = get_nv_value("SSID1")
local DMZEnable = get_nv_value("DMZEnable")
local upnpEnabled = get_nv_value("upnpEnabled")
local sntp_timezone = get_nv_value("sntp_timezone")
local wifiEnabled = get_nv_value("wifiEnabled")
local max_station_num = get_nv_value("MAX_Station_num")
local sim_unlock_code = get_nv_value("sim_unlock_code")
local remo_sim_admin_password = get_nv_value("remo_sim_admin_password")
local admin_Password = get_nv_value("admin_Password")
local dhcpDns = get_nv_value("dhcpDns")
local dns_extern = get_nv_value("dns_extern")
local tr069_enable = get_nv_value("tr069_enable")
local tr069_acs_url = get_nv_value("tr069_acs_url")
local fota_updateMode = get_nv_value("fota_updateMode")
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
if cr_version ~= "" then
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
if max_station_num ~= "" then
	print(colors.cyan .. colors.bright .. "══════ WIFI信息══════════════════════════════════════════" .. colors.reset)
	print(colors.green .. colors.bright .. "WIFI开启: " .. wifiEnabled .. "              最大连接数: " .. max_station_num .. "个" .. colors.reset)
else
	print(colors.cyan .. colors.bright .. "══════ WIFI信息══════════════════════════════════════════" .. colors.reset)
	print(colors.red .. colors.bright .. "无法获取wifi信息" .. colors.reset)
end
if SSID1 ~= "" then
	print(colors.yellow .. colors.bright .. "当前WIFI名称: " .. SSID1 .. colors.reset)
else
	print(colors.red .. colors.bright .. "无法获取wifi信息" .. colors.reset)
end
if dns_extern ~= "" then
	print(colors.cyan .. colors.bright .. "══════ 网络信息══════════════════════════════════════════" .. colors.reset)
	print(colors.bright .. "DNS地址: " .. dns_extern .. colors.reset)
else
	print(colors.cyan .. colors.bright .. "══════ 网络信息══════════════════════════════════════════" .. colors.reset)
	print(colors.red .. colors.bright .. "无法获取DNS地址,设备应该不支持" .. colors.reset)
end
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
	print(colors.yellow .. colors.bright .. "SIM解锁码(SZXF): " .. sim_unlock_code .. colors.reset)
else
	print(colors.cyan .. colors.bright .. "══════ 密码相关══════════════════════════════════════════" .. colors.reset)
	print(colors.red .. colors.bright .. "SIM解锁码(SZXF):无法获取,设备不是SZXF或没有密码" .. colors.reset)
end
if remo_sim_admin_password ~= "" then
	print(colors.yellow .. colors.bright .. "SIM解锁码(REMO): " .. remo_sim_admin_password .. colors.reset)
else
	print(colors.red .. colors.bright .. "SIM解锁码(REMO):无法获取,设备不是REMO或没有密码" .. colors.reset)
end
print(colors.cyan .. colors.bright .. "══════ 远程相关══════════════════════════════════════════" .. colors.reset)
if tr069_enable ~= "" then
	print(colors.yellow .. colors.bright .. "tr069(acs)开关: " .. tr069_enable .. "            tr069地址：" .. tr069_acs_url .. colors.reset)
	print(" ")
else
	print(colors.red .. colors.bright .. "无法获取:tr069信息,设备不支持tr069" .. colors.reset)
	print(" ")
end
if fota_updateMode ~= "" then
	print(colors.yellow .. colors.bright .. "自动升级模式: " .. fota_updateMode .. "          升级地址:" .. fota_version_delta_url .. colors.reset)
	print(" ")
else
	print(colors.red .. colors.bright .. "无法获取自动升级,设备应该不支持自动升级" .. colors.reset)
end
if tc_enable ~= "" then
	print(colors.yellow .. colors.bright .. "tc状态: " .. tc_enable .. "       上传地址:" .. tc_uplink .. "       下载地址:" .. tc_downlink .. colors.reset)
	print(" ")
else
	print(colors.red .. colors.bright .. "无法获取TC，设备应该不支持" .. colors.reset)
end
print(colors.cyan .. colors.bright .. "═════════════════════════════════════════════════════════" .. colors.reset)
print()

-- 按下任意键退出程序
os.execute("pause")