DEBUG_LOGGING_ON = true

function shuffle(list)
	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end
end

function push(list, item)
	list[#list+1] = item
end

function append(list, item)--an immutable version of push
	local ret = deepCopy(list)
	push(ret, item)
	return ret
end

function pop(list)
	local item = list[#list]
	list[#list] = nil
	return item
end

function first(list, item)
	local n = 0
	if list.n ~= nil then 
		n = list.n 
	else
		n = #list
	end
	for i=1,n do
		if list[i] == item then
			return i
		end
	end
	return nil
end

function defrag(list, length)
	local ret = {}
	for i=1,length do
		if list[i] ~= nil then
			push(ret, list[i])
		end
	end
	return ret
end

function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function areEqual(left, right)
	for i,_ in ipairs(left) do
		if left[i] ~= right[i] then
			return false
		end
	end
	return true
end

function save(data)
	local dir = love.filesystem.getSaveDirectory()
	blob = blobWriter()
	blob:write(data)
	local file = io.open(dir..'/savedata', 'wb')
	file:write(blob:tostring())
	file:close()
end

function load()
	local dir = love.filesystem.getSaveDirectory()
	local file = io.open(dir..'/savedata', 'rb')
	if file ~= nil then
		local blob = blobReader(file:read("*all"))
		local data = blob:read()
		file:close()
		return data
	else
		return {}
	end
end

function backUp(data)
	local dir = love.filesystem.getSaveDirectory()
	blob = blobWriter()
	blob:write(data)
	local file = io.open(dir..'/savedata.prev', 'wb')
	file:write(blob:tostring())
	file:close()
end

function formatMenuString(string, selected, submenu)
	local ret = deepCopy(string)
	if selected == true then
		ret = "Z:["..ret.."]"
	end
	if submenu == true then
		ret = ret..">"
	end
	return ret
end


function log(message)
	if DEBUG_LOGGING_ON == true then
		local message = "["..os.date('%m/%d/%y %H:%M:%S').."]: "..message.."\n"
		love.filesystem.append("BotsLog.txt", message)
	end
end

function love.errhand(error_message)
  local app_name = "Bots"
  local version = "0.1"
  local email = "zac@bauermeister.com"
  local edition = love.system.getOS()

  local dialog_message = [[
%s crashed with the following error message:

%s

Would you like to report this crash so that it can be fixed?]]
  local titles = {"Oh no", "Oh boy", "Bad news"}
  local title = titles[love.math.random(#titles)]
  local full_error = debug.traceback(error_message or "")
  local message = string.format(dialog_message, app_name, full_error)
  local buttons = {"Yes", "No"}

  local pressedbutton = love.window.showMessageBox(title, message, buttons)

  local function url_encode(text)
    -- This is not complete. Depending on your issue text, you might need to
    -- expand it!
    text = string.gsub(text, "\n", "%%0A")
    text = string.gsub(text, " ", "%%20")
    text = string.gsub(text, "#", "%%23")
    return text
  end

  local issuebody = [[
%s crashed with the following error message:

%s

[If you can, describe what you've been doing when the error occurred]

---
Affects: %s
Edition: %s]]

	log("ERROR: "..full_error)

  if pressedbutton == 1 then
	issuebody = string.format(issuebody, app_name, full_error, version, edition)
    issuebody = url_encode(issuebody)

    local subject = string.format("Crash in %s %s", app_name, version)
    local url = string.format("mailto:%s?subject=%s&body=%s",
                              email, subject, issuebody)
    love.system.openURL(url)
  end
end
