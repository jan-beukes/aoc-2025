#!/bin/sh

eval $(opam env)
ocamlfind ocamlopt -o main -package str -linkpkg main.ml
