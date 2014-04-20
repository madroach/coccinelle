type regexp =
    Pcre of int (* Pcre.regexp *)
  | Str of Str.regexp

(* A table is used because PCRE regular expressions are not comparable.  They
sit in constraints of rule_elems that get bound to exists v variables in
the matching process.  It would be expensive to strip them at runtime, and
complex to strip them statically, because + and - annotations are added
by cocci_vs_c into the same rule_elems.  So instead we just replace them
by integers, which are comparable. *)
let pcre_table = Hashtbl.create 101
let pcre_ctr = ref 0 

let pcre_support = ref true

let regexp string =
  if !pcre_support
  then
    begin
      let c = !pcre_ctr in
      pcre_ctr := !pcre_ctr + 1;
      Hashtbl.add pcre_table c (Pcre.regexp string);
      Pcre c
    end
  else Str (Str.regexp string)

let string_match regexp string =
  match regexp with
      Pcre regexp ->
	let regexp = Hashtbl.find pcre_table regexp in
	Pcre.pmatch ~rex:regexp string
    | Str regexp ->
      try
	ignore(Str.search_forward regexp string 0);
	true
      with _ -> false
