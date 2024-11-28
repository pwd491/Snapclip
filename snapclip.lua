clipboard_command = ""
temporary_directory = ""
snapshot_name = "screenshot"
snapshot_format = "png"
snapshot = snapshot_name .. "." .. snapshot_format

function getOS()
    
	-- ask LuaJIT first
	if jit then
		return jit.os
	end

	-- Unix, Linux variants
	local fh,err = assert(io.popen("uname -o 2>/dev/null","r"))
	if fh then
		osname = fh:read()
	end

	return osname or "Windows"
end

function define_environment()
    local osname = getOS()

    -- Set defauts
    vlc.config.set("snapshot-format", snapshot_format)
    vlc.config.set("snapshot-prefix", "")

    if osname == "GNU/Linux" then
        clipboard_command = "xclip"
        temporary_directory = "/tmp/"
    elseif osname == "Darwin" then
        clipboard_command = "pbcopy"
        temporary_directory = "/tmp/"
    elseif osname == "Windows" then
        clipboard_command = "windows_clipboard"
        temporary_directory = os.getenv("Temp") .. "\\"
    end
    -- Set default path to temporary directory
    vlc.config.set("snapshot-path", temporary_directory .. snapshot)
end

function take_snapshot()
    local vout = vlc.object.vout()

    if vout then 
        vlc.var.get(vout, )
    end
end

function image_to_clipboard()
    
end