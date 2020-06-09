module Sentencize

export SentenceSplitter
export SUPPORTED_LANG

const SUPPORTED_LANG = ["ca", "cs", "da", "de", "el", "en", "es", "fi", "fr",
                        "hu", "is", "it", "lt", "lv", "nl", "no", "pl", "pt",
                        "ro", "ru", "sk", "sl", "sv", "tr"]

struct SentenceSplitter
    non_breaking_prefixes::Array{String}

    function SentenceSplitter(prefixes::Array{String}=String[]; prefix_file=missing, lang="en")
        function _load_prefix_file(pfile)
            nb_prefixes = String[]
            open(pfile) do file
                for line in eachline(file)
                    line = replace(line, r"#.*" => "")     # Remove comments
                    line = strip(line)
    
                    if isempty(line)
                        continue
                    end
    
                    push!(nb_prefixes, line)
                end
            end
            return nb_prefixes
        end
    
        if !ismissing(lang)
            if !(lang in SUPPORTED_LANG)
                throw(ArgumentError("Unsupported language. Use a supported language " \
                                    "($SUPPORTED_LANG). You can also provide your own " \
                                    "non_breaking_prefixes file with the keyword " \
                                    "argument `prefix_file`."))
            else
                append!(prefixes, _load_prefix_file(joinpath(@__DIR__, "non_breaking_prefixes/$lang.txt")))
            end
        end

        if !ismissing(prefix_file)
            append!(prefixes, _load_prefix_file(prefix_file))
        end

        new(prefixes)
    end
end

end
