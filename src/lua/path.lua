-- path.lua
-- 提供常用工具路径的模块
-- 
-- 版权 (C) 2025-2026 企鹅君Punguin
--
-- 本程序是自由软件：你可以根据自由软件基金会发布的GNU Affero通用公共许可证的条款，即许可证的第3版或（您选择的）任何后来的版本重新发布它和/或修改它。。
-- 本程序的发布是希望它能起到作用。但没有任何保证；甚至没有隐含的保证。本程序的分发是希望它是有用的，但没有任何保证，甚至没有隐含的适销对路或适合某一特定目的的保证。 参见 GNU Affero通用公共许可证了解更多细节。
-- 您应该已经收到了一份GNU Affero通用公共许可证的副本。 如果没有，请参见<https://www.gnu.org/licenses/>。
--
-- 联系我们：3618679658@qq.com
-- ChatGPT协助制作编写

local path = {}

-- 统一管理 bin 目录
local base_bin = "bin"

-- 工具路径
path.lua = base_bin .. "\\lua54.exe"
path.curl = base_bin .. "\\curl.exe"
path.adb  = base_bin .. "\\adb.exe"

-- 如果需要绝对路径，可以这样获取：
-- local lfs = require("lfs")
-- LuaFileSystem 可选
-- path.abs_lua = lfs.currentdir() .. "/" .. path.lua


-- 提供函数调用方式
function path.get(tool)
    return path[tool]
	end
return path