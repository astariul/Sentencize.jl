using Sentencize
using Test

@testset "Sentencize.jl" begin

      # Prefixes Constructor tests

      @test "Apr" in keys(Prefixes().non_breaking_prefixes)     # Default : load the english prefixes

      @test "C.Q.F.D" in keys(Prefixes(lang="fr").non_breaking_prefixes)    # Load specific language

      ss = Prefixes(Dict("test-prefix" => Sentencize.default))
      @test "test-prefix" in keys(ss.non_breaking_prefixes) &&
            "Apr" in keys(ss.non_breaking_prefixes)        # English is also loaded

      ss = Prefixes(Dict("test-prefix" => Sentencize.default), lang=nothing)
      @test "test-prefix" in keys(ss.non_breaking_prefixes) &&
            !("Apr" in keys(ss.non_breaking_prefixes))

      ss = Prefixes(prefix_file="test.txt")
      @test "another-test-prefix" in keys(ss.non_breaking_prefixes) &&
            "Apr" in keys(ss.non_breaking_prefixes)

      ss = Prefixes(prefix_file="test.txt", lang=nothing)
      @test "another-test-prefix" in keys(ss.non_breaking_prefixes) &&
            !("Apr" in keys(ss.non_breaking_prefixes))

      ss = Prefixes(Dict("test-prefix" => Sentencize.default), prefix_file="test.txt")
      @test "another-test-prefix" in keys(ss.non_breaking_prefixes) &&
            "Apr" in keys(ss.non_breaking_prefixes) &&
            "test-prefix" in keys(ss.non_breaking_prefixes)

      ss = Prefixes(Dict("test-prefix" => Sentencize.default), prefix_file="test.txt", lang=nothing)
      @test "another-test-prefix" in keys(ss.non_breaking_prefixes) &&
            !("Apr" in keys(ss.non_breaking_prefixes)) &&
            "test-prefix" in keys(ss.non_breaking_prefixes)

      ss = Prefixes(Dict("test-prefix" => Sentencize.default), prefix_file="test.txt", lang="fr")
      @test "another-test-prefix" in keys(ss.non_breaking_prefixes) &&
            "C.Q.F.D" in keys(ss.non_breaking_prefixes) &&
            "test-prefix" in keys(ss.non_breaking_prefixes)

      @test_throws ArgumentError Prefixes(lang="some-weird-language")

      ## Test non-string prefix 
      ss = Prefixes(Dict(strip(" test-prefix") => Sentencize.default), lang=nothing)
      @test "test-prefix" in keys(ss.non_breaking_prefixes) &&
            !("Apr" in keys(ss.non_breaking_prefixes))


      # split sentences tests

      @test split_sentence("") == []


      # English

      @test split_sentence("This is a paragraph. It contains several sentences. \"But why,\" you ask?") == ["This is a paragraph.", "It contains several sentences.", "\"But why,\" you ask?"]

      @test split_sentence("Hey! Now.") == ["Hey!", "Now."]

      @test split_sentence("Hey... Now.") == ["Hey...", "Now."]

      @test split_sentence("Hey. Now.") == ["Hey.", "Now."]

      @test split_sentence("Hey.  Now.") == ["Hey.", "Now."]

      @test split_sentence("Hello. No. 1. No. 2. Prefix. 1. Prefix. 2. Good bye.") == ["Hello.", "No. 1.", "No. 2.", "Prefix.", "1.", "Prefix.", "2.", "Good bye."]      # Numeric only

      @test split_sentence("Hello. .NATO. Good bye.") == ["Hello. .NATO. Good bye."]      # Acronym

      @test split_sentence("Foo bar. (Baz foo.) Bar baz.") == ["Foo bar.", "(Baz foo.)", "Bar baz."]      # Sentence within bracket


      # Deutsch
      @test split_sentence("Nie hätte das passieren sollen. Dr. Soltan sagte: \"Der Fluxcompensator war doch kalibriert!\".", lang="de") == ["Nie hätte das passieren sollen.", "Dr. Soltan sagte: \"Der Fluxcompensator war doch kalibriert!\"."]


      # French
      @test split_sentence("Brookfield Office Properties Inc. (« BOPI »), dont les actifs liés aux immeubles directement...", lang="fr") == ["Brookfield Office Properties Inc. (« BOPI »), dont les actifs liés aux immeubles directement..."]

      # Greek
      @test split_sentence("Όλα τα συστήματα ανώτατης εκπαίδευσης σχεδιάζονται σε εθνικό επίπεδο. Η ΕΕ αναλαμβάνει κυρίως να συμβάλει στη βελτίωση της συγκρισιμότητας μεταξύ των διάφορων συστημάτων και να βοηθά φοιτητές και καθηγητές να μετακινούνται με ευκολία μεταξύ των συστημάτων των κρατών μελών.", lang="el") == ["Όλα τα συστήματα ανώτατης εκπαίδευσης σχεδιάζονται σε εθνικό επίπεδο.", "Η ΕΕ αναλαμβάνει κυρίως να συμβάλει στη βελτίωση της συγκρισιμότητας μεταξύ των διάφορων συστημάτων και να βοηθά φοιτητές και καθηγητές να μετακινούνται με ευκολία μεταξύ των συστημάτων των κρατών μελών."]

      # Portuguese
      @test split_sentence("Isto é um parágrafo. Contém várias frases. «Mas porquê,» perguntas tu?", lang="pt") == ["Isto é um parágrafo.", "Contém várias frases.", "«Mas porquê,» perguntas tu?"]

      # Espagnol
      @test split_sentence("La UE ofrece una gran variedad de empleos en un entorno multinacional y multilingüe. La Oficina Europea de Selección de Personal (EPSO) se ocupa de la contratación, sobre todo mediante oposiciones generales.", lang="es") == ["La UE ofrece una gran variedad de empleos en un entorno multinacional y multilingüe.", "La Oficina Europea de Selección de Personal (EPSO) se ocupa de la contratación, sobre todo mediante oposiciones generales."]

      # Custom prefixes
      @test split_sentence("Hello. Prefix1. Prefix2. Hello again. Good bye.", prefixes=Dict("Prefix1" => Sentencize.default, "#Hello" => Sentencize.default, "Prefix2" => Sentencize.default)) == ["Hello.", "Prefix1. Prefix2. Hello again.", "Good bye."]

      # Test with AbstractString
      sub_string = strip(" This is a paragraph. It contains several sentences. \"But why,\" you ask?  ")
      @test split_sentence(sub_string) == ["This is a paragraph.", "It contains several sentences.", "\"But why,\" you ask?"]

end
