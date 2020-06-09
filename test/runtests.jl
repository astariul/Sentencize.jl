using Sentencize
using Test

@testset "Sentencize.jl" begin

# COnstructor test

@test "Apr" in SentenceSplitter().non_breaking_prefixes     # Default : load the english prefixes

@test "C.Q.F.D" in SentenceSplitter(lang="fr").non_breaking_prefixes    # Load specific language

ss = SentenceSplitter(["test-prefix"])
@test "test-prefix" in ss.non_breaking_prefixes &&
      "Apr" in ss.non_breaking_prefixes        # English is also loaded

ss = SentenceSplitter(["test-prefix"], lang=missing)
@test "test-prefix" in ss.non_breaking_prefixes &&
      !("Apr" in ss.non_breaking_prefixes)

ss = SentenceSplitter(prefix_file="test.txt")
@test "another-test-prefix" in ss.non_breaking_prefixes &&
      "Apr" in ss.non_breaking_prefixes

ss = SentenceSplitter(prefix_file="test.txt", lang=missing)
@test "another-test-prefix" in ss.non_breaking_prefixes &&
      !("Apr" in ss.non_breaking_prefixes)

ss = SentenceSplitter(["test-prefix"], prefix_file="test.txt")
@test "another-test-prefix" in ss.non_breaking_prefixes &&
      "Apr" in ss.non_breaking_prefixes &&
      "test-prefix" in ss.non_breaking_prefixes

ss = SentenceSplitter(["test-prefix"], prefix_file="test.txt", lang=missing)
@test "another-test-prefix" in ss.non_breaking_prefixes &&
      !("Apr" in ss.non_breaking_prefixes) &&
      "test-prefix" in ss.non_breaking_prefixes

ss = SentenceSplitter(["test-prefix"], prefix_file="test.txt", lang="fr")
@test "another-test-prefix" in ss.non_breaking_prefixes &&
      "C.Q.F.D" in ss.non_breaking_prefixes &&
      "test-prefix" in ss.non_breaking_prefixes

end
