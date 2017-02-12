







toString(x ::Real)                                                     = string(typeof(x), "(", isa(x, Bool) ? Int(x) : x, ")")
toString(x ::String)                                                   = string(typeof(x), "(\"", x, "\")")
toString(x ::Array)                                                    = isempty(x) ? string(x) : string(eltype(x), x)
toData(s   ::String)                                                   = eval(parse(s))
writeKV(io::IOStream, key::String, value::Union{Real, String, Array}) = write(io, key * "@" * toString(value) * "\n")
readKV(text::String) = begin
  key, value = split(text, '@')
  String(key), eval(parse(value[1:end-1]))
end
checkPath(path::String) = isabspath(path) || !('/' in path || '\\' in path) || error(path * "'s format is error")
