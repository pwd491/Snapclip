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


clipboard_tool = ""
clipboard_tool_args = ""
temporary_directory = ""
snapshot_name = "screenshot"
snapshot_format = "png"
snapshot = snapshot_name .. '.' .. snapshot_format


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
    define_environment()
    local dialog = vlc.dialog("Snapclip")
    local button = dialog:add_button("Screenshot to clipboard", take_snapshot)
    dialog:show()
end

function deactivate()
    logging("DEACTIVATE", "info")
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

    vlc.config.set("snapshot-format", snapshot_format)
    vlc.config.set("snapshot-prefix", "")

    logging("OS: " .. osname, "info")
    if osname == "GNU/Linux" then
        temporary_directory = "/tmp/"
        clipboard_tool = "xclip"
    elseif osname == "Darwin" then
        temporary_directory = "/tmp/"
        clipboard_tool = "pbcopy"
    elseif osname == "Windows" then
        clipboard_tool = "powershell"
        clipboard_tool_args = "-windowstyle hidden -command Set-Clipboard -Path"
        temporary_directory = os.getenv("temp") .. "\\"
    end

    logging("Clipboard command: " .. clipboard_tool, "info")
    logging("Clipboard args: " .. clipboard_tool_args, "info")
    logging("Temporary directory: " .. temporary_directory, "info")
    logging("Snapshot path: " .. temporary_directory .. snapshot, "info")

    vlc.config.set("snapshot-path", temporary_directory .. snapshot)
end

function take_snapshot()
    local vout = vlc.object.vout()

    if vout then
        local screenshot = vlc.var.set(vout, "video-snapshot", nil)
        if screenshot then
            logging("Snapshot taking success", "info")
            set_clipboard()
        else
            logging(screenshot, "error")
        end
    else
        logging("No video track detected, have you opened the video?", "error")
    end
end

function set_clipboard()
    logging("Set screenshot to clipboard", "info")
    local command = string.format(
        "%s %s %s%s", clipboard_tool, clipboard_tool_args, temporary_directory, snapshot
    )
    logging(command, "info")

    local clip, err = assert(os.execute(command))
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
