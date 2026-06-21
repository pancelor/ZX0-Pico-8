pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

function mem_get(start_addr)
	return function(i)
		return peek(start_addr+i)
	end
end
