-- sleep.lua
-- 简单的阻塞型倒计时函数（支持通过 ini 配置禁用）
-- 
-- 版权 (C) 2025-2026 企鹅君Punguin
--
-- 本程序是自由软件：你可以根据自由软件基金会发布的GNU Affero通用公共许可证的条款，即许可证的第3版或（您选择的）任何后来的版本重新发布它和/或修改它。。
-- 本程序的发布是希望它能起到作用。但没有任何保证；甚至没有隐含的保证。本程序的分发是希望它是有用的，但没有任何保证，甚至没有隐含的适销对路或适合某一特定目的的保证。 参见 GNU Affero通用公共许可证了解更多细节。
-- 您应该已经收到了一份GNU Affero通用公共许可证的副本。 如果没有，请参见<https://www.gnu.org/licenses/>。
--
-- 联系我们：3618679658@qq.com
-- ChatGPT协助制作编写

local delay = {}

-- 尝试读取 helper.ini 中的 off-all_sleep 参数
local skip_delay = false
local ini_file = io.open("helper.ini", "r")
if ini_file then
    for line in ini_file:lines() do
        local key, value = line:match("^%s*(.-)%s*=%s*(.-)%s*$")
        if key == "off-all_sleep" and value == "1" then
            skip_delay = true
            break
        end
    end
    ini_file:close()
end

--- 阻塞当前程序指定秒数（若 helper.ini 中禁用，则立即返回）
-- @param seconds number 延迟秒数
function delay.sleep(seconds)
    if skip_delay then
        return
    end

    local start = os.clock()
    while os.clock() - start < seconds do end
end

return delay