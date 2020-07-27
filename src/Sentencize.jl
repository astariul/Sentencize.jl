module Sentencize

export SUPPORTED_LANG
export PrefixType
export Prefixes
export split_sentence

const SUPPORTED_LANG = ["ca", "cs", "da", "de", "el", "en", "es", "fi", "fr",
                        "hu", "is", "it", "lt", "lv", "nl", "no", "pl", "pt",
                        "ro", "ru", "sk", "sl", "sv", "tr"]

@enum PrefixType default numeric_only

struct Prefixes
    non_breaking_prefixes::Dict{String, PrefixType}

    function Prefixes(prefixes::Dict{String, PrefixType}=Dict{String, PrefixType}(); prefix_file=missing, lang="en")
        function _load_prefix_file(pfile)
            nb_prefixes = Dict{String, PrefixType}()
            open(pfile) do file
                for line in eachline(file)
                    if occursin("#NUMERIC_ONLY#", line)
                        prefix_type = numeric_only
                    else
                        prefix_type = default
                    end

                    line = replace(line, r"#.*" => "")     # Remove comments
                    line = strip(line)
    
                    if isempty(line)
                        continue
                    end
    
                    nb_prefixes[line] = prefix_type
                end
            end
            return nb_prefixes
        end
    
        if !ismissing(lang)
            if !(lang in SUPPORTED_LANG)
                throw(ArgumentError("Unsupported language. Use a supported language ($SUPPORTED_LANG). " * 
                                    "You can also provide your own non_breaking_prefixes file with the " *
                                    "keyword argument `prefix_file`."))
            else
                merge!(prefixes, _load_prefix_file(joinpath(@__DIR__, "non_breaking_prefixes/$lang.txt")))
            end
        end

        if !ismissing(prefix_file)
            merge!(prefixes, _load_prefix_file(prefix_file))
        end

        new(prefixes)
    end
end


function _basic_sentence_breaks(text::String)
    # Non-period end of sentence markers (?!) followed by sentence starters
    text = replace(text, r"([?!]) +(['\"([\u00bf\u00A1\p{Pi}]*[\p{Lu}\p{Lo}])" => s"\1\n\2")

    # Multi-dots followed by sentence starters
    text = replace(text, r"(\.[\.]+) +(['\"([\u00bf\u00A1\p{Pi}]*[\p{Lu}\p{Lo}])" => s"\1\n\2")

    # Add breaks for sentences that end with some sort of punctuation inside a quote or parenthetical and are
    # followed by a possible sentence starter punctuation and upper case
    text = replace(text, r"([?!\.][\ ]*['\")\]\p{Pf}]+) +(['\"([\u00bf\u00A1\p{Pi}]*[\ ]*[\p{Lu}\p{Lo}])" => s"\1\n\2")

    # Add breaks for sentences that end with some sort of punctuation and are followed by a sentence starter punctuation
    # and upper case
    text = replace(text, r"([?!\.]) +(['\"[\u00bf\u00A1\p{Pi}]+[\ ]*[\p{Lu}\p{Lo}])" => s"\1\n\2")

    return text
end


function _is_prefix_honorific(prefix::SubString{String}, starting_punct::SubString{String}, non_breaking_prefixes::Dict{String,PrefixType})
    # Check if \\1 is a known honorific and \\2 is empty.
    if prefix != ""
        if prefix in keys(non_breaking_prefixes)
            if non_breaking_prefixes[prefix] == default
                if starting_punct == ""
                    return true
                end
            end
        end
    end
    return false
end


function _is_numeric(prefix::SubString{String}, starting_punct::SubString{String}, next_word::SubString{String}, non_breaking_prefixes::Dict{String,PrefixType})
    # The next word has a bunch of initial quotes, maybe a space, then either upper case or a number.
    if prefix != ""
        if prefix in keys(non_breaking_prefixes)
            if non_breaking_prefixes[prefix] == numeric_only
                if starting_punct == ""
                    if match(r"^[0-9]+", next_word) != nothing
                        return true
                    end
                end
            end
        end
    end
    return false
end


function split_sentence(text::String; prefixes::Dict{String, PrefixType}=Dict{String, PrefixType}(), prefix_file=missing, lang="en")
    if text == ""
        return []
    end

    pf = Prefixes(prefixes, prefix_file=prefix_file, lang=lang)

    text = _basic_sentence_breaks(text)

    # Special punctuation cases : check all remaining periods
    words = split(text, r" +")
    text = ""
    for i in 1:length(words) - 1
        m = match(r"([\w\.\-]*)(['\"\)\]\%\p{Pf}]*)(\.+)$", words[i])

        if m != nothing
            prefix = m.captures[1]
            starting_punct = m.captures[2]

            if _is_prefix_honorific(prefix, starting_punct, pf.non_breaking_prefixes)
                # Not breaking
            elseif match(r"(\.)[\p{Lu}\p{Lo}\-]+(\.+)$", words[i]) != nothing
                # Not breaking - upper case acronym
            elseif match(r"^([ ]*['\"([\u00bf\u00A1\p{Pi}]*[ ]*[\p{Lu}\p{Lo}0-9])", words[i + 1]) != nothing
                if !_is_numeric(prefix, starting_punct, words[i + 1], pf.non_breaking_prefixes)
                    words[i] = words[i] * "\n"
                    # We always add a return for these unless we have a numeric non-breaker and a number start
                end
            end
        end
        text = text * words[i] * " "
    end

    # We stopped one token from the end to allow for easy look-ahead. Append it now.
    text = text * last(words)

    # Clean up spaces at head and tail of each line as well as any double-spacing
    text = replace(text, r" +" => s" ")
    text = replace(text, r"\n " => s"\n")
    text = replace(text, r" \n" => s"\n")
    text = strip(text)

    sentences = split(text, "\n")

    return sentences
end

end
