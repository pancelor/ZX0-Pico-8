pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

function zx0_decompress(
	get_input_byte,
	get_output_byte,
	set_output_byte
)
	local last_offset, last_byte, bit_mask, input_count, output_count, backtrack, bit_value, msb = unpack(split"1,0,0,0,0")

	local function read_byte()
		last_byte = get_input_byte(input_count)
		input_count += 1
		return last_byte
	end

	local function read_bit()
		if backtrack then
			backtrack = false
			return last_byte & 1
		else
			bit_mask \= 2
			if bit_mask == 0 then
				bit_value, bit_mask = read_byte(), 128
			end
		end

		return min(1, bit_value & bit_mask)
	end

	local function read_var(invert)
		local v = 1
		while read_bit() == 0 do
			v <<= 1
			v |= read_bit()~invert
		end
		return v
	end

	local function write_byte(b)
		set_output_byte(output_count, b)
		output_count += 1
	end

	local function copy_bytes(n)
		for _ = 1,n do
			write_byte(
				get_output_byte(
					output_count-last_offset))
		end
	end

	::copy_literals::
		for _ = 1,read_var(0) do
			write_byte(read_byte())
		end

		if read_bit() == 1 then
			goto copy_from_new_offset
		end

	-- ::copy_from_last_offset::
		copy_bytes(read_var(0))

		goto loop

	::copy_from_new_offset::
		msb = read_var(1)
		if (msb == 256) return

		last_offset = (msb * 128) - read_byte()\2
		backtrack = true

		copy_bytes(read_var(0) + 1)

	::loop::
		if read_bit() == 0 then
			goto copy_literals
		else
			goto copy_from_new_offset
		end
end
