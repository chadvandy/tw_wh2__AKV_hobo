local LicheLog = {
    filePath = "liche_log.txt",
    writeLog = true
} --# assume LicheLog: LICHE_LOG

--v function()
function LicheLog.init()
    do
        local file = io.open(LicheLog.filePath, "w+")
        file:write("NEW LOG INITIALIZED \n")
        local timeStamp = os.date("%d, %m %Y %X")
        --# assume timeStamp: string
        file:write("[" .. timeStamp .. "]\n")
        file:close()
    end
end

--v function(enabled: bool)
function LicheLog.setLog(enabled)
    LicheLog.writeLog = not not enabled
end

--v function(text: string)
function LicheLog.out(text)
    if LicheLog.writeLog then
        local file = io.open(LicheLog.filePath, "a")
        file:write(text .. "\n")
        file:close()
    end
end

--v function(text: string)
function LicheLog.error(text)
    if LicheLog.writeLog then
        local file = io.open(LicheLog.filePath, "a")
        file:write("ERROR: " .. text .. "\n")
        file:close()
    end
end

return {
    init = LicheLog.init,
    out = LicheLog.out,
    setLog = LicheLog.setLog,
    error = LicheLog.error
}