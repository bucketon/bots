--- Parses binary data from memory.
-- @classmod BlobReader
local BlobReader = {
	_VERSION     = 'Blob 2.0.2',
	_LICENSE     = 'MIT, https://opensource.org/licenses/MIT',
	_URL         = 'https://github.com/megagrump/blob',
	_DESCRIPTION = 'Binary serialization and parsing library for LuaJIT',
}

local ffi = require('ffi')
local band = bit.band
local _native, _byteOrder, _parseByteOrder
local _tags, _getTag, _taggedReaders, _unpackMap

--- Creates a new BlobReader instance.
--
-- @tparam string|cdata data Data with which to populate the blob
-- @tparam[opt] string byteOrder The byte order of the data
--
-- Use `le` or `<` for little endian; `be` or `>` for big endian; `native`, `=` or `nil` to use the
-- host's native byte order (default)
-- @tparam[opt] number size When data is of type `cdata`, you need to pass the size manually
-- @treturn BlobReader A new BlobReader instance.
-- @usage local reader = BlobReader(data)
-- @usage local reader = BlobReader(data, '>')
-- @usage local reader = BlobReader(cdata, nil, 1000)
function BlobReader:new(data, byteOrder, size)
	local dtype = type(data)
	if dtype == 'string' then
		self:_allocate(#data)
		ffi.copy(self._data, data, #data)
	elseif dtype == 'cdata' then
		self._size = size or ffi.sizeof(data)
		self._data = data
	else
		error('Invalid data type <' .. dtype .. '>')
	end

	self._readPtr = 0
	self:setByteOrder(byteOrder)

	return self
end

--- Set source data byte order.
---
-- @tparam string byteOrder Byte order.
--
-- Can be either `le` or `<` for little endian, `be` or `>` for big endian, or `native` or `nil` for native host byte
-- order.
-- @treturn BlobReader self
function BlobReader:setByteOrder(byteOrder)
	self._orderBytes = _byteOrder[_parseByteOrder(byteOrder)]

	return self
end

--- Reads a `string`, a `number`, a `boolean` or a `table` from the input data.
--
-- The data must have been written by `BlobWriter:write`.
-- The type of the value is automatically detected from the input metadata.
-- @treturn string|number|bool|table The value read from the input data
-- @see BlobWriter:write
function BlobReader:read()
	local tag, value = self:_readTagged()
	return value
end

--- Reads a Lua number from the input data.
--
-- @treturn number The number read read from the input data
function BlobReader:number()
	_native.u32[0], _native.u32[1] = self:u32(), self:u32()
	return _native.n
end

--- Reads a string from the input data.
--
-- The string must have been written by `BlobWriter:write` or `BlobWriter:string`
-- @treturn string The string read from the input data
-- @see BlobWriter:write
-- @see BlobWriter:string
function BlobReader:string()
	local len, ptr = self:vu32(), self._readPtr
	assert(ptr + len - 1 < self._size, "Out of data")
	self._readPtr = ptr + len
	return ffi.string(ffi.cast('uint8_t*', self._data + ptr), len)
end

--- Reads a boolean value from the input data.
--
-- The data is expected to be 8 bits long, `0 == false`, any other value == `true`
-- @treturn bool The boolean value read from the input data
function BlobReader:bool()
	return self:u8() ~= 0
end

--- Reads a Lua table from the input data.
--
-- The table must have been written by BlobWriter:write or BlobWriter:table.
-- @treturn table The table read from the input data
-- @see BlobWriter:table
-- @see BlobWriter:write
function BlobReader:table()
	local result = {}
	local tag, key = self:_readTagged()
	while tag ~= _tags.stop do
		tag, result[key] = self:_readTagged()
		tag, key = self:_readTagged()
	end
	return result
end

--- Reads one unsigned 8-bit value from the input data.
--
-- @treturn number The unsigned 8-bit value read from the input data
function BlobReader:u8()
	assert(self._readPtr < self._size, "Out of data")
	local u8 = self._data[self._readPtr]
	self._readPtr = self._readPtr + 1
	return u8
end

--- Reads one signed 8-bit value from the input data.
--
-- @treturn number The signed 8-bit value read from the input data
function BlobReader:s8()
	_native.u8[0] = self:u8()
	return _native.s8[0]
end

--- Reads one unsigned 16-bit value from the input data.
--
-- @treturn number The unsigned 16-bit value read from the input data
function BlobReader:u16()
	local ptr = self._readPtr
	assert(ptr + 1 < self._size, "Out of data")
	self._readPtr = ptr + 2
	return self._orderBytes._16(self._data[ptr], self._data[ptr + 1])
end

--- Reads one signed 16 bit value from the input data.
--
-- @treturn number The signed 16-bit value read from the input data
function BlobReader:s16()
	_native.u16[0] = self:u16()
	return _native.s16[0]
end

--- Reads one unsigned 32 bit value from the input data.
--
-- @treturn number The unsigned 32-bit value read from the input data
function BlobReader:u32()
	local ptr = self._readPtr
	assert(ptr + 3 < self._size, "Out of data")
	self._readPtr = ptr + 4
	return self._orderBytes._32(self._data[ptr], self._data[ptr + 1], self._data[ptr + 2], self._data[ptr + 3])
end

--- Reads one signed 32 bit value from the input data.
--
-- @treturn number The signed 32-bit value read from the input data
function BlobReader:s32()
	_native.u32[0] = self:u32()
	return _native.s32[0]
end

--- Reads one unsigned 64 bit value from the input data.
--
-- @treturn number The unsigned 64-bit value read from the input data
function BlobReader:u64()
	local ptr = self._readPtr
	assert(ptr + 7 < self._size, "Out of data")
	self._readPtr = ptr + 8
	return self._orderBytes._64(self._data[ptr], self._data[ptr + 1], self._data[ptr + 2], self._data[ptr + 3],
		self._data[ptr + 4], self._data[ptr + 5], self._data[ptr + 6], self._data[ptr + 7])
end

--- Reads one signed 64 bit value from the input data.
--
-- @treturn number The signed 64-bit value read from the input data
function BlobReader:s64()
	_native.u64 = self:u64()
	return _native.s64
end

--- Reads one 32 bit floating point value from the input data.
--
-- @treturn number The 32-bit floating point value read from the input data
function BlobReader:f32()
	_native.u32[0] = self:u32()
	return _native.f[0]
end

--- Reads one 64 bit floating point value from the input data.
--
-- @treturn number The 64-bit floating point value read from the input data
function BlobReader:f64()
	return self:number()
end

--- Reads a variable length unsigned 32 bit integer value from the input data.
--
-- @treturn number The unsigned 32-bit integer value read from the input data
-- @see BlobWriter:vu32
function BlobReader:vu32()
	local result = self:u8()
	if band(result, 0x00000080) == 0 then return result end
	result = band(result, 0x0000007f) + self:u8() * 2 ^ 7
	if band(result, 0x00004000) == 0 then return result end
	result = band(result, 0x00003fff) + self:u8() * 2 ^ 14
	if band(result, 0x00200000) == 0 then return result end
	result = band(result, 0x001fffff) + self:u8() * 2 ^ 21
	if band(result, 0x10000000) == 0 then return result end
	return band(result, 0x0fffffff) + self:u8() * 2 ^ 28
end

--- Reads a variable length signed 32 bit integer value from the input data.
--
-- @treturn number The signed 32-bit integer value read from the input data
-- @see BlobWriter:vs32
function BlobReader:vs32()
	_native.u32[0] = self:vu32()
	return _native.s32[0]
end

--- Reads raw binary data from the input data.
--
-- @tparam number len The length of the data (in bytes) to read
-- @treturn string A string with raw data
function BlobReader:raw(len)
	local ptr = self._readPtr
	assert(ptr + len - 1 < self._size, "Out of data")
	self._readPtr = ptr + len
	return ffi.string(ffi.cast('uint8_t*', self._data + ptr), len)
end

--- Skips a number of bytes in the input data.
--
-- @tparam number len The number of bytes to skip
-- @treturn BlobReader self
function BlobReader:skip(len)
	assert(self._readPtr + len - 1 < self._size, "Out of data")
	self._readPtr = self._readPtr + len
	return self
end

--- Reads a zero-terminated string from the input data (up to 2 ^ 32 - 1 bytes).
--
-- Keeps reading bytes until a null byte is encountered.
-- @treturn string The string read from the input data
function BlobReader:cstring()
	local start = self._readPtr
	while self:u8() > 0 do end
	local len = self._readPtr - start
	assert(len < 2 ^ 32, "String too long")

	return ffi.string(ffi.cast('uint8_t*', self._data + start), len - 1)
end

--- Parses data into separate values according to a format string.
--
-- The format string syntax is based on the format that Lua 5.3's string.unpack accepts, but does not implement all
-- features and uses fixed instead of native data sizes.
-- See <a href='http://www.lua.org/manual/5.3/manual.html#6.4.2'>the Lua manual</a> for details.
--
-- @tparam string format Data format descriptor string.
--
-- Supported format specifiers:
--
-- * Byte order:
--     * `<` (little endian)
--     * `>` (big endian)
--     * `=` (host endian, default)
--
--     Byte order can be switched any number of times in a format string.
-- * Integer types:
--     * `b` / `B` (signed/unsigned 8 bits)
--     * `h` / `H` (signed/unsigned 16 bits)
--     * `l` / `L` (signed/unsigned 32 bits)
--     * `v` / `V` (signed/unsigned variable length 32 bits) - see `BlobReader:vs32` / `BlobReader:vu32`
--     * `q` / `Q` (signed/unsigned 64 bits)
-- * Floating point types:
--     * `f` (32 bits)
--     * `d`, `n` (64 bits)
-- * String types:
--     * `z` (zero terminated string)
--     * `s` (string with preceding length information)
-- * Raw data:
--     * `c[length]` (up to 2 ^ 32 - 1 bytes)
-- * Boolean:
--     * `y` (8 bits boolean value)
-- * Table:
--     * `t` (table written with `BlobWriter:table`
-- * "` `" (a single space character): skip one byte
-- @return All values parsed from the input data
-- @usage local byte, float, bool = reader:unpack('Bfy')
-- @see BlobWriter:pack
function BlobReader:unpack(format)
	assert(type(format) == 'string', "Invalid format specifier")
	local result, len = {}, nil

	local function _readRaw()
		local l = tonumber(table.concat(len))
		assert(l, l or "Invalid string length specification: " .. table.concat(len))
		assert(l < 2 ^ 32, "Maximum string length exceeded")
		table.insert(result, self:raw(l))
		len = nil
	end

	format:gsub('.', function(c)
		if len then
			if tonumber(c) then
				table.insert(len, c)
			else
				_readRaw()
			end
		end

		if not len then
			local parser = _unpackMap[c]
			assert(parser, parser or "Invalid data type specifier: " .. c)
			if c == 'c' then
				len = {}
			else
				local parsed = parser(self)
				if parsed ~= nil then
					table.insert(result, parsed)
				end
			end
		end
	end)

	if len then _readRaw() end -- final specifier in format was a length specifier

	return unpack(result)
end

--- Returns the size of the input data in bytes.
--
-- @treturn number Data size in bytes
function BlobReader:size()
	return self._size
end

--- Resets the read position to the beginning of the data.
--
-- @treturn BlobReader self
function BlobReader:rewind()
	self._readPtr = 0
	return self
end

--- Returns the current read position as an offset from the start of the input data in bytes.
--
-- @treturn number Current read position in bytes
function BlobReader:position()
	return self._readPtr
end

-----------------------------------------------------------------------------

function BlobReader:_allocate(size)
	local data
	if size > 0 then
		data = ffi.new('uint8_t[?]', size)
	end
	self._data, self._size = data, size
end

function BlobReader:_readTagged()
	local tag = self:u8()
	return tag, tag ~= _tags.stop and _taggedReaders[tag](self)
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
	le = {
		_16 = function(b1, b2)
			_native.u8[0], _native.u8[1] = b1, b2
			return _native.u16[0]
		end,
		_32 = function(b1, b2, b3, b4)
			_native.u8[0], _native.u8[1], _native.u8[2], _native.u8[3] = b1, b2, b3, b4
			return _native.u32[0]
		end,
		_64 = function(b1, b2, b3, b4, b5, b6, b7, b8)
			_native.u8[0], _native.u8[1], _native.u8[2], _native.u8[3],
			_native.u8[4], _native.u8[5], _native.u8[6], _native.u8[7] = b1, b2, b3, b4, b5, b6, b7, b8
			return _native.u64
		end,

	},

	be = {
		_16 = function(b1, b2)
			_native.u8[0], _native.u8[1] = b2, b1
			return _native.u16[0]
		end,
		_32 = function(b1, b2, b3, b4)
			_native.u8[0], _native.u8[1], _native.u8[2], _native.u8[3] = b4, b3, b2, b1
			return _native.u32[0]
		end,
		_64 = function(b1, b2, b3, b4, b5, b6, b7, b8)
			_native.u8[0], _native.u8[1], _native.u8[2], _native.u8[3],
			_native.u8[4], _native.u8[5], _native.u8[6], _native.u8[7] = b8, b7, b6, b5, b4, b3, b2, b1
			return _native.u64
		end,
	}
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

_taggedReaders = {
	BlobReader.number,
	BlobReader.string,
	BlobReader.bool,
	BlobReader.table,
	function() return true end,
	function() return false end,
}

_unpackMap = {
	b = BlobReader.s8,
	B = BlobReader.u8,
	h = BlobReader.s16,
	H = BlobReader.u16,
	l = BlobReader.s32,
	L = BlobReader.u32,
	v = BlobReader.vs32,
	V = BlobReader.vu32,
	q = BlobReader.s64,
	Q = BlobReader.u64,
	f = BlobReader.f32,
	d = BlobReader.number,
	n = BlobReader.number,
	c = BlobReader.raw,
	s = BlobReader.string,
	z = BlobReader.cstring,
	t = BlobReader.table,
	y = BlobReader.bool,
	['<'] = function(self) self:setByteOrder('<') end,
	['>'] = function(self) self:setByteOrder('>') end,
	['='] = function(self) self:setByteOrder('=') end,
	[' '] = function(self) self:skip(1) end,
}

return setmetatable({}, {
	__call = function(self, ...)
		return setmetatable({}, { __index = BlobReader }):new(...)
	end
})
