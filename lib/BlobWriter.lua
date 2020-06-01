--- Writes binary data to memory.
-- @classmod BlobWriter
local BlobWriter = {
	_VERSION     = 'Blob 2.0.2',
	_LICENSE     = 'MIT, https://opensource.org/licenses/MIT',
	_URL         = 'https://github.com/megagrump/blob',
	_DESCRIPTION = 'Binary serialization and parsing for LuaJIT',
}

local ffi = require('ffi')
local band, bnot, shr = bit.band, bit.bnot, bit.rshift
local _native, _byteOrder, _parseByteOrder
local _tags, _getTag, _taggedReaders, _taggedWriters, _packMap, _unpackMap

--- Creates a new BlobWriter instance.
--
-- @tparam[opt] string byteOrder Byte order
--
-- Use `le` or `<` for little endian; `be` or `>` for big endian; `native`, `=` or `nil` to use the
-- host's native byteOrder (default)
--
-- @tparam[opt] number size The initial size of the blob. Default size is 1024. Will grow automatically when needed.
-- @treturn BlobWriter A new BlobWriter instance.
-- @usage local writer = BlobWriter()
-- @usage local writer = BlobWriter('<', 1000)
function BlobWriter:new(byteOrder, size)
	self:setByteOrder(byteOrder)

	self._length = 0
	self:_allocate(size or 1024)

	return self
end

--- Sets the order in which multi-byte values will be written.
--
-- @tparam string byteOrder Byte order
--
-- Can be either `le` or `<` for little endian, `be` or `>` for big endian, or `native` or `nil` for native host byte
-- order.
--
-- @treturn BlobWriter self
function BlobWriter:setByteOrder(byteOrder)
	self._orderBytes = _byteOrder[_parseByteOrder(byteOrder)]

	return self
end

--- Writes a value to the output buffer. Determines the type of the value automatically.
--
-- Supported value types are `number`, `string`, `boolean` and `table`.
-- @param value the value to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:write(value)
	return self:_writeTagged(value)
end

--- Writes a Lua number to the output buffer.
--
-- @tparam number number The number to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:number(number)
	_native.n = number
	self:u32(_native.u32[0]):u32(_native.u32[1])

	return self
end

--- Writes a boolean value to the output buffer.
--
-- The value is written as an unsigned 8 bit value (`true = 1`, `false = 0`)
-- @tparam bool bool The boolean value to write to the output buffer
--
-- @treturn BlobWriter self
function BlobWriter:bool(bool)
	self:u8(bool and 1 or 0)

	return self
end

--- Writes a string to the output buffer.
--
-- Stores the length of the string as a `vu32` field before the actual string data.
-- @tparam string str The string to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:string(str)
	local length = #str
	local makeRoom = (self._size - self._length) - (length + self:vu32size(length))
	if makeRoom < 0 then
		self:_grow(math.abs(makeRoom))
	end

	self:vu32(length)
	ffi.copy(ffi.cast('char*', self._data + self._length), str, length)
	self._length = self._length + length

	return self
end

--- Writes an unsigned 8 bit value to the output buffer.
--
-- @tparam number u8 The value to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:u8(u8)
	if self._length + 1 > self._size then self:_grow(1) end
	self._data[self._length] = u8
	self._length = self._length + 1

	return self
end

--- Writes a signed 8 bit value to the output buffer.
--
-- @tparam number s8 The value to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:s8(s8)
	_native.s8[0] = s8

	return self:u8(_native.u8[0])
end

--- Writes an unsigned 16 bit value to the output buffer.
--
-- @tparam number u16 The value to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:u16(u16)
	local len = self._length
	if len + 2 > self._size then self:_grow(2) end
	local b1, b2 = self._orderBytes(band(u16, 2 ^ 8 - 1), shr(u16, 8))
	self._data[len], self._data[len + 1] = b1, b2
	self._length = len + 2

	return self
end

--- Writes a signed 16 bit value to the output buffer.
--
-- @tparam number s16 The value to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:s16(s16)
	_native.s16[0] = s16

	return self:u16(_native.u16[0])
end

--- Writes an unsigned 32 bit value to the output buffer.
--
-- @tparam number u32 The value to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:u32(u32)
	local len = self._length
	if len + 4 > self._size then self:_grow(4) end
	local w1, w2 = self._orderBytes(band(u32, 2 ^ 16 - 1), shr(u32, 16))
	local b1, b2 = self._orderBytes(band(w1, 2 ^ 8 - 1), shr(w1, 8))
	local b3, b4 = self._orderBytes(band(w2, 2 ^ 8 - 1), shr(w2, 8))
	self._data[len], self._data[len + 1], self._data[len + 2], self._data[len + 3] = b1, b2, b3, b4
	self._length = len + 4

	return self
end

--- Writes a signed 32 bit value to the output buffer.
--
-- @tparam number s32 The value to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:s32(s32)
	_native.s32[0] = s32

	return self:u32(_native.u32[0])
end

--- Writes an unsigned 64 bit value to the output buffer.
--
-- Lua numbers are only accurate up to 2 ^ 53. Use the LuaJIT `ULL` suffix to write large numbers.
-- @usage writer:u64(72057594037927936ULL)
-- @tparam number u64 The value to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:u64(u64)
	_native.u64 = u64
	local a, b = self._orderBytes(_native.u32[0], _native.u32[1])

	return self:u32(a):u32(b)
end

--- Writes a signed 64 bit value to the output buffer.
--
-- @see BlobWriter:u64
-- @tparam number s64 The value to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:s64(s64)
	_native.s64 = s64
	local a, b = self._orderBytes(_native.u32[0], _native.u32[1])

	return self:u32(a):u32(b)
end

--- Writes a 32 bit floating point value to the output buffer.
--
-- @tparam number f32 The value to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:f32(f32)
	_native.f[0] = f32

	return self:u32(_native.u32[0])
end

--- Writes a 64 bit floating point value to the output buffer.
---
-- @tparam number f64 The value to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:f64(f64)

	return self:number(f64)
end

--- Writes raw binary data to the output buffer.
--
-- @tparam string|cdata raw A `string` or `cdata` with the data to write to the output buffer
-- @tparam[opt] number length Length of data (not required when data is a string)
-- @treturn BlobWriter self
function BlobWriter:raw(raw, length)
	length = length or #raw
	local makeRoom = (self._size - self._length) - length
	if makeRoom < 0 then
		self:_grow(math.abs(makeRoom))
	end
	ffi.copy(ffi.cast('char*', self._data + self._length), raw, length)
	self._length = self._length + length

	return self
end

--- Writes a string to the output buffer, followed by a null byte.
--
-- @tparam string str The string to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:cstring(str)
	self:raw(str)
	self:u8(0)

	return self
end

--- Writes a table to the output buffer.
--
-- Supported field types are number, string, bool and table. Cyclic references throw an error.
-- @tparam table t The table to write to the output buffer
-- @treturn BlobWriter self
function BlobWriter:table(t)
	return self:_writeTable(t, {})
end


--- Writes an unsigned 32 bit integer value with varying length.
--
-- The value is written in an encoded format where the length depends on the value: larger values need more space.
-- The minimum length is 1 byte for values < 2^7, maximum length is 5 bytes for values >= 2^28.
-- @tparam number value The unsigned integer value to write to the output buffer
-- @see BlobWriter:vu32size
-- @treturn BlobWriter self
function BlobWriter:vu32(value)
	assert(value < 2 ^ 32, "Exceeded u32 value range")

	for i = 7, 28, 7 do
		local mask, shift = 2 ^ i - 1, i - 7
		if value < 2 ^ i then
			return self:u8(shr(band(value, mask), shift))
		else
			self:u8(shr(band(value, mask), shift) + 0x80)
		end
	end

	return self:u8(shr(band(value, 0xf0000000), 28))
end

--- Writes a signed 32 bit integer value with varying length.
--
-- @tparam number value The signed integer value to write to the output buffer
-- @see BlobWriter:vu32
-- @treturn BlobWriter self
function BlobWriter:vs32(value)
	assert(value < 2 ^ 31 and value >= -2^31, "Exceeded s32 value range")
	_native.s32[0] = value
	return self:vu32(_native.u32[0])
end

--- Writes data to the output buffer according to a format string.
--
-- See `BlobReader:unpack` for a list of supported format specifiers.
-- @tparam string format data format descriptor string
-- @param ... values to write
-- @treturn BlobWriter self
-- @usage writer:pack('Bfy', 255, 23.0, true)
-- @see BlobReader:unpack
function BlobWriter:pack(format, ...)
	assert(type(format) == 'string', "Invalid format specifier")
	local data, index, len = {...}, 1, nil
	local limit = select('#', ...)

	local function _writeRaw()
		local l = tonumber(table.concat(len))
		assert(l, l or "Invalid string length specification: " .. table.concat(len))
		assert(l < 2 ^ 32, "Maximum string length exceeded")
		self:raw(data[index], l)
		index, len = index + 1, nil
	end

	format:gsub('.', function(c)
		if len then
			if tonumber(c) then
				table.insert(len, c)
			else
				assert(index <= limit, "Number of arguments to pack() does not match format specifiers")
				_writeRaw()
			end
		end

		if not len then
			local writer = _packMap[c]
			assert(writer, writer or "Invalid data type specifier: " .. c)
			if c == 'c' then
				len = {}
			else
				assert(index <= limit, "Number of arguments to pack() does not match format specifiers")
				if writer(self, data[index]) then
					index = index + 1
				end
			end
		end
	end)

	if len then _writeRaw() end -- final specifier in format was a length specifier

	return self
end

-----------------------------------------------------------------------------

--- Returns the current buffer contents as a string.
--
-- @treturn string A string with the current buffer contents
function BlobWriter:tostring()
	return ffi.string(self._data, self._length)
end

--- Returns the number of bytes stored in the blob.
--
-- @treturn number The number of bytes stored in the blob
function BlobWriter:length()
	return self._length
end

--- Returns the size of the write buffer in bytes
--
-- @treturn number Write buffer size in bytes
function BlobWriter:size()
	return self._size
end

--- Returns the number of bytes required to store an unsigned 32 bit value when written by `BlobWriter:vu32`.
--
-- @tparam number value The unsigned 32 bit value to write
-- @treturn number The number of bytes required by `BlobWriter:vu32` to store `value`
function BlobWriter:vu32size(value)
	if value < 2 ^ 7 then return 1 end
	if value < 2 ^ 14 then return 2 end
	if value < 2 ^ 21 then return 3 end
	if value < 2 ^ 28 then return 4 end
	return 5
end

--- Returns the number of bytes required to store a signed 32 bit value when written by `BlobWriter:vs32`.
--
-- @tparam number value The signed 32 bit value to write
-- @treturn number The number of bytes required by `BlobWriter:vs32` to store `value`
function BlobWriter:vs32size(value)
	_native.s32[0] = value
	return self:vu32size(_native.u32[0])
end

-----------------------------------------------------------------------------

function BlobWriter:_allocate(size)
	local data
	if size > 0 then
		data = ffi.new('uint8_t[?]', size)
		if self._data then
			ffi.copy(data, self._data, self._length)
		end
	end
	self._data, self._size = data, size
	self._length = math.min(size, self._length)
end

function BlobWriter:_grow(minimum)
	minimum = minimum or 0
	local newSize = math.max(self._size + minimum, math.floor(math.max(1, self._size * 1.5) + .5))
	self:_allocate(newSize)
end


function BlobWriter:_writeTable(t, stack)
	stack = stack or {}
	local ttype = type(t)
	assert(ttype == 'table', ttype == 'table' or string.format("Invalid type '%s' for BlobWriter:table", ttype))
	assert(not stack[t], "Cycle detected; can't serialize table")

	stack[t] = true
	for key, value in pairs(t) do
		self:_writeTagged(key, stack)
		self:_writeTagged(value, stack)
	end
	stack[t] = nil

	self:u8(_tags.stop)

	return self
end

function BlobWriter:_writeTagged(value, stack)
	local tag = _getTag(value)
	assert(tag, tag or string.format("Can't write values of type '%s'", type(value)))
	self:u8(tag)

	return _taggedWriters[tag](self, value, stack)
end

function _parseByteOrder(endian)
	if not endian or endian == '=' or endian == 'native' then
		endian = ffi.abi('le') and 'le' or 'be'
	elseif endian == '<' then
		endian = 'le'
	elseif endian == '>' then
		endian = 'be'
	end
	local valid = endian == 'le' or endian == 'be'
	assert(valid, valid or "Invalid byteOrder identifier: " .. endian)

	return endian
end

function _getTag(value)
	if value == true or value == false then
		return _tags[value]
	end

	return _tags[type(value)]
end

_native = ffi.new[[
	union {
		  int8_t s8[8];
		 uint8_t u8[8];
		 int16_t s16[4];
		uint16_t u16[4];
		 int32_t s32[2];
		uint32_t u32[2];
		   float f[2];
		 int64_t s64;
		uint64_t u64;
		  double n;
	}
]]

_byteOrder = {
	le = function(v1, v2) return v1, v2 end,
	be = function(v1, v2) return v2, v1 end,
}

_tags = {
	stop = 0,
	number = 1,
	string = 2,
	boolean = 3, -- not used anymore in version 1.2+
	table = 4,
	[true] = 5,
	[false] = 6,
}

_taggedWriters = {
	BlobWriter.number,
	BlobWriter.string,
	function() error('booleans are stored in tags; this error should never occur') end,
	BlobWriter._writeTable,
	function(self) return self end, -- true is stored as tag, write nothing
	function(self) return self end, -- false is stored as tag, write nothing
}

_packMap = {
	b = BlobWriter.s8,
	B = BlobWriter.u8,
	h = BlobWriter.s16,
	H = BlobWriter.u16,
	l = BlobWriter.s32,
	L = BlobWriter.u32,
	v = BlobWriter.vs32,
	V = BlobWriter.vu32,
	q = BlobWriter.s64,
	Q = BlobWriter.u64,
	f = BlobWriter.f32,
	d = BlobWriter.number,
	n = BlobWriter.number,
	c = BlobWriter.raw,
	s = BlobWriter.string,
	z = BlobWriter.cString,
	t = BlobWriter.table,
	y = BlobWriter.bool,
	['<'] = function(self) self:setByteOrder('<') end,
	['>'] = function(self) self:setByteOrder('>') end,
	['='] = function(self) self:setByteOrder('=') end,
}

return setmetatable({}, {
	__call = function(self, ...)
		return setmetatable({}, { __index = BlobWriter }):new(...)
	end
})
