module Sentencize

export SUPPORTED_LANG
export PrefixType
export Prefixes
export split_sentence

"""
    SUPPORTED_LANG

Supported languages.

Contains: 
- "ca"
- "cs"
- "da"
- "de"
- "el"
- "en"
- "es"
- "fi"
- "fr"
- "hu"
- "is"
- "it"
- "lt"
- "lv"
- "nl"
- "no"
- "pl"
- "pt"
- "ro"
- "ru"
- "sk"
- "sl"
- "sv"
- "tr"
"""
const SUPPORTED_LANG = ["ca", "cs", "da", "de", "el", "en", "es", "fi", "fr",
    "hu", "is", "it", "lt", "lv", "nl", "no", "pl", "pt",
    "ro", "ru", "sk", "sl", "sv", "tr"]

function _load_prefix_file(T::Type{<:AbstractString}, pfile)
    nb_prefixes = Dict{T, PrefixType}()
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

@enum PrefixType default numeric_only

"""
Prefixes(prefixes::Dict{T,PrefixType}=Dict{String,PrefixType}(); prefix_file::Union{String,Nothing}=nothing, lang::Union{String,Nothing}="en") where {T<:AbstractString}

Constructs `Prefixes`.

# Arguments
- `prefixes::Dict{<:AbstractString,PrefixType}=Dict{T,PrefixType}()`: Optional. A dictionary of non-breaking prefixes.
- `prefix_file::Union{String,Nothing}=nothing`: Optional. A path to a file containing non-breaking prefixes to add to provided `prefixes`.
- `lang::AbstractString="en"`: Optional. The language of the non-breaking prefixes (see `?SUPPORTED_LANG` for available languages) to be added to `prefixes`.
"""
struct Prefixes{T <: AbstractString}
    non_breaking_prefixes::Dict{T, PrefixType}

    function Prefixes(prefixes::Dict{T, PrefixType} = Dict{String, PrefixType}();
            prefix_file::Union{String, Nothing} = nothing,
            lang::Union{String, Nothing} = "en") where {T <: AbstractString}
        if !isnothing(lang)
            if !(lang in SUPPORTED_LANG)
                throw(ArgumentError("Unsupported language. Use a supported language ($SUPPORTED_LANG). " *
                                    "You can also provide your own non_breaking_prefixes file with the " *
                                    "keyword argument `prefix_file`."))
            else
                merge!(prefixes,
                    _load_prefix_file(
                        T, joinpath(@__DIR__, "non_breaking_prefixes/$lang.txt")))
            end
        end

        if !isnothing(prefix_file)
            if isfile(prefix_file)
                merge!(prefixes, _load_prefix_file(T, prefix_file))
            else
                throw(ArgumentError("File $prefix_file does not exist."))
            end
        end

        new{T}(prefixes)
    end
end

function _basic_sentence_breaks(text::AbstractString)
    # Non-period end of sentence markers (?!) followed by sentence starters
    text = replace(text, r"([?!]) +(['\"([\u00bf\u00A1\p{Pi}]*[\p{Lu}\p{Lo}])" => s"\1\n\2")

    # Multi-dots followed by sentence starters
    text = replace(
        text, r"(\.[\.]+) +(['\"([\u00bf\u00A1\p{Pi}]*[\p{Lu}\p{Lo}])" => s"\1\n\2")

    # Add breaks for sentences that end with some sort of punctuation inside a quote or parenthetical and are
    # followed by a possible sentence starter punctuation and upper case
    text = replace(text,
        r"([?!\.][\ ]*['\")\]\p{Pf}]+) +(['\"([\u00bf\u00A1\p{Pi}]*[\ ]*[\p{Lu}\p{Lo}])" => s"\1\n\2")

    # Add breaks for sentences that end with some sort of punctuation and are followed by a sentence starter punctuation
    # and upper case
    text = replace(
        text, r"([?!\.]) +(['\"[\u00bf\u00A1\p{Pi}]+[\ ]*[\p{Lu}\p{Lo}])" => s"\1\n\2")

    return text
end

function _is_prefix_honorific(prefix::AbstractString, starting_punct::AbstractString,
        non_breaking_prefixes::Dict{<:AbstractString, PrefixType})
    # Check if \\1 is a known honorific and \\2 is empty.
    if !isempty(prefix)
        if prefix in keys(non_breaking_prefixes)
            if non_breaking_prefixes[prefix] == default
                if isempty(starting_punct)
                    return true
                end
            end
        end
    end
    return false
end

function _is_numeric(
        prefix::AbstractString, starting_punct::AbstractString, next_word::AbstractString,
        non_breaking_prefixes::Dict{<:AbstractString, PrefixType})
    # The next word has a bunch of initial quotes, maybe a space, then either upper case or a number.
    if !isempty(prefix)
        if prefix in keys(non_breaking_prefixes)
            if non_breaking_prefixes[prefix] == numeric_only
                if isempty(starting_punct)
                    if !isnothing(match(r"^[0-9]+", next_word))
                        return true
                    end
                end
            end
        end
    end
    return false
end

"""
    split_sentence(text::AbstractString; prefixes::Dict{<:AbstractString,PrefixType}=Dict{String,PrefixType}(), prefix_file::Union{String,Nothing}=nothing, lang::Union{String,Nothing}="en")

Splits a `text` into sentences.

# Arguments
- `text::AbstractString`: The text to split into sentences.
- `prefixes::Dict{<:AbstractString,PrefixType}`: Optional. A dictionary of non-breaking prefixes.
- `prefix_file::Union{String,Nothing}`: Optional. A path to a file containing non-breaking prefixes to add to provided `prefixes`.
- `lang::Union{String,Nothing}`: Optional. The language of the non-breaking prefixes (see `?SUPPORTED_LANG` for available languages) to be added to `prefixes` Default is "en" (=English).

# Examples
```julia
split_sentence("This is a paragraph. It contains several sentences. \"But why,\" you ask?")
# Output: ["This is a paragraph.", "It contains several sentences.", "\"But why,\" you ask?"]
```
"""
function split_sentence(text::AbstractString;
        prefixes::Dict{<:AbstractString, PrefixType} = Dict{String, PrefixType}(),
        prefix_file::Union{String, Nothing} = nothing, lang::Union{String, Nothing} = "en")
    if text == ""
        return []
    end

    pf = Prefixes(prefixes, prefix_file = prefix_file, lang = lang)

    text = _basic_sentence_breaks(text)

    # Special punctuation cases : check all remaining periods
    words = split(text, r" +")
    text = ""
    for i in 1:(length(words) - 1)
        m = match(r"([\w\.\-]*)(['\"\)\]\%\p{Pf}]*)(\.+)$", words[i])

        if !isnothing(m)
            prefix = m.captures[1]
            starting_punct = m.captures[2]

            if _is_prefix_honorific(prefix, starting_punct, pf.non_breaking_prefixes)
                # Not breaking
            elseif !isnothing(match(r"(\.)[\p{Lu}\p{Lo}\-]+(\.+)$", words[i]))
                # Not breaking - upper case acronym
            elseif !isnothing(match(
                r"^([ ]*['\"([\u00bf\u00A1\p{Pi}]*[ ]*[\p{Lu}\p{Lo}0-9])", words[i + 1]))
                if !_is_numeric(
                    prefix, starting_punct, words[i + 1], pf.non_breaking_prefixes)
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
