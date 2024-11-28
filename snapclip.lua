--[[
 Copyright © 2024

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
--]]


clipboard_cmd = ""
tmp = ""
screenshot = "screenshot.png"


function descriptor()
    return {
		title = "Snapclip";
		version = "1.0";
		author = "Sergey Degtyar";
		url = "https://github.com/pwd491/snapclip";
		shortdesc = "Snapclip";
		description = "Take a screenshot to the clipboard easily";
	}
end

function activate()
    logging("Activated", "info")
    if define_environment() then 
        local dialog = vlc.dialog("Snapclip")
        local button = dialog:add_button("Screenshot to clipboard", take_screenshot)
        dialog:show()
    else
        deactivate()
    end
end

function deactivate()
    logging("Deactivated", "info")
end

function get_os_name()
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
    local osname = get_os_name()

    logging("OS: " .. osname, "info")
    if osname == "GNU/Linux" then
        tmp = "/tmp/"
        clipboard_cmd = string.format(
            "xclip -selection clipboard -t image/png -i %s", tmp .. screenshot
        )
        local fh,state,code = os.execute("xclip")
        if code == 127 then
            logging("Please, install xclip `sudo apt install xclip`", "error")
            return false
        end
    elseif osname == "Darwin" then
        tmp = os.getenv("TMPDIR")
        clipboard_cmd = string.format(
            "osascript -e 'set the clipboard to (read (POSIX file \"%s\") as {«class PNGf»})'",
            tmp .. screenshot
        )
    elseif osname == "Windows" then
        tmp = os.getenv("TEMP") .. "\\"
        clipboard_cmd = string.format(
            "powershell.exe -windowstyle hidden -command Set-Clipboard -Path %s",
            tmp .. screenshot
        )
    end
    
    logging("Clipboard command: " .. clipboard_cmd, "info")
    logging("Temporary directory: " .. tmp, "info")
    logging("Screenshot path: " .. tmp .. screenshot, "info")
    
    vlc.config.set("snapshot-format", "png")
    vlc.config.set("snapshot-prefix", "")
    vlc.config.set("snapshot-path", tmp .. screenshot)
    return true
end

function take_screenshot()
    local vout = vlc.object.vout()

    if vout then
        local snapshot = vlc.var.set(vout, "video-snapshot", nil)
        if snapshot then
            logging("Screenshot take success!", "info")
            set_clipboard()
        else
            logging(snapshot, "error")
        end
    else
        logging("No video track detected, have you opened the video?", "error")
    end
end

function set_clipboard()
    logging("Set screenshot to clipboard", "info")
    local clip, err = assert(os.execute(clipboard_cmd))
    if clip then
        logging("The screenshot was clipped to clipboard succusess.", "info")
    else
        logging(clip .. " " .. err, "debug")
    end
end


function logging(message, level)
    if level == "info" then
        vlc.msg.info("[Snapclip] " .. message)
    elseif level == "debug" then
        vlc.msg.dbg("[Snapclip] " .. message)
    elseif level == "warn" then
        vlc.msg.warn("[Snapclip] " .. message)
    elseif level == "error" then
        vlc.msg.err("[Snapclip] " .. message)
    end
end
