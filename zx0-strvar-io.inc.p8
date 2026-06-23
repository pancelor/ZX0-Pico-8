pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

function strvar_get(t, var)
	return function(i)
	    local s = t[var]
	    assert(i < #s)
		return ord(s, i+1)
	end
end

function strvar_set(t, var)
	return function(i, v)
	    local s = t[var]
	    assert(i == #s)
	    t[var] = s .. chr(v)
	end
end
