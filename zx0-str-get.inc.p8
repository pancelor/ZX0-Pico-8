pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

function str_get(s)
	return function(i)
		return s[i+1]
	end
end
