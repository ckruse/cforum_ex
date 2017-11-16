use ExGuard.Config

guard("unit-test")
|> command("mix test --color")
|> watch(
     {~r{lib/(?<lib_dir>.+_web)/(?<dir>.+)/(?<file>.+).ex$}i, fn m ->
       "test/#{m["lib_dir"]}/#{m["dir"]}/#{m["file"]}_test.exs"
     end}
   )
|> watch(~r{\.(erl|ex|exs|eex|xrl|yrl)\z}i)
|> ignore(~r{deps})
|> notification(:auto)
