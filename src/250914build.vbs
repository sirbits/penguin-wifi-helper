Set objShell = CreateObject("WScript.Shell")
objShell.Popup "当前版本是Build版本，不代表最终成品", 10, "提示", 64
objShell.Popup "1.修复格行降级因为删除Fota_upi循环重启问题" & vbCrLf & ""& vbCrLf & "2.在中兴微通杀完美去控新增设备类型" & vbCrLf & ""& vbCrLf & "3.添加atweb写入，在选项E中", 10, "5.1-build-250914更新内容：", 0