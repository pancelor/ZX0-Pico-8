pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- zx0 decompresser

function zx0_decompress(
 get_input_byte,
 get_output_byte,
 set_output_byte
)
    local last_byte = 0
    local backtrack = false
    local bit_mask = 0
    local bit_value
    local last_offset = 1
    local input_count = 0
    local output_count = 0

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
            bit_mask = (bit_mask >> 1)\1
            if bit_mask == 0 then
                bit_value = read_byte()
                bit_mask = 128
            end
        end

        return min(1, bit_value & bit_mask)
    end

    local function read_var(mode)
        local v = 1
        while read_bit() == 0 do
            v = ((v << 1)|read_bit()) ^^ (mode or 0)
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

    local copy_literals, copy_from_last_offset, copy_from_new_offset

    copy_literals = function()
        local n = read_var(0)
        for _ = 1,n do
            write_byte(read_byte())
        end

        if read_bit() == 0 then
            return copy_from_last_offset()
        else
            return copy_from_new_offset()
        end
    end

    copy_from_last_offset = function()
        copy_bytes(read_var(0))

        if read_bit() == 0 then
            return copy_literals()
        else
            return copy_from_new_offset()
        end
    end

    copy_from_new_offset = function()
        local msb = read_var(1)
        if (msb == 256) return

        local lsb = (read_byte() >>> 1)\1
        last_offset = msb * 128 - lsb
        backtrack = true

        copy_bytes(read_var(0) + 1)

        if read_bit() == 0 then
            return copy_literals()
        else
            return copy_from_new_offset()
        end
    end

    copy_literals()
end
