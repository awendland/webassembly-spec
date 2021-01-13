open Source
open Ast
open Extern_types

module Unknown = Error.Make ()
exception Unknown = Unknown.Error  (* indicates unknown import name *)

module Registry = Map.Make(struct type t = Ast.name let compare = compare end)
let registry = ref Registry.empty

let register name lookup = registry := Registry.add name lookup !registry

let lookup (m : module_) (im : import) : Instance.extern =
  let {module_name; item_name; idesc} = im.it in
  let t = unresolved_import_type m im in
  try Registry.find module_name !registry item_name t with Not_found ->
    Unknown.error im.at
      ("unknown import \"" ^ string_of_name module_name ^
        "\".\"" ^ string_of_name item_name ^ "\"")

let link m = List.map (lookup m) m.it.imports
