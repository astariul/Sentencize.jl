<h1 align="center">Sentencize.jl</h1>
<p align="center"><a href="https://github.com/astariul/Sentencize.jl/actions"><img src="https://github.com/astariul/Sentencize.jl/workflows/tests/badge.svg" alt="test status" /></a></p>

**Text to sentence splitter using heuristic algorithm.**

This module is a port of the [python package `sentence-splitter`]().

The module allows splitting of text paragraphs into sentences. It is based on scripts developed by Philipp Koehn and Josh Schroeder for processing the [Europarl corpus](http://www.statmt.org/europarl/).

## Usage

The module uses punctuation and capitalization clues to split plain text into a list of sentences :

```julia
import Sentencize

sen = Sentencize.split_sentence("This is a paragraph. It contains several sentences. \"But why,\" you ask?")
println(sen)
# ["This is a paragraph.", "It contains several sentences.", "\"But why,\" you ask?"]
```

You can specify another language than english :

```julia
sen = Sentencize.split_sentence("Brookfield Office Properties Inc. (« BOPI »), dont les actifs liés aux immeubles directement...", lang="fr")
println(sen)
# ["Brookfield Office Properties Inc. (« BOPI »), dont les actifs liés aux immeubles directement..."]
```

You can specify your own non-breaking prefixes file:

```julia
sen = Sentencize.split_sentence("This is an example.", prefix_file="my_prefixes.txt", lang=missing)
```

Or even pass the prefixes as a dictionary :

```julia
sen = Sentencize.split_sentence("This is another example. Another sentence.", prefixes=Dict("example" => Sentencize.default))
# ["This is another example. Another sentence."]
```

## Languages

Currently supported languages are :

- Catalan (`ca`)
- Czech (`cs`)
- Danish (`da`)
- Dutch (`nl`)
- English (`en`)
- Finnish (`fi`)
- French (`fr`)
- German (`de`)
- Greek (`el`)
- Hungarian (`hu`)
- Icelandic (`is`)
- Italian (`it`)
- Latvian (`lv`)
- Lithuanian (`lt`)
- Norwegian (Bokmål) (`no`)
- Polish (`pl`)
- Portuguese (`pt`)
- Romanian (`ro`)
- Russian (`ru`)
- Slovak (`sk`)
- Slovene (`sl`)
- Spanish (`es`)
- Swedish (`sv`)
- Turkish (`tr`)
