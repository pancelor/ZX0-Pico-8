pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

function table_set(t)
	return function(i)
	    assert(i == #t)
		add(t,i)
	end
end