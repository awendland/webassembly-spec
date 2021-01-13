(*
 * Simple collection of functions useful for writing test cases.
 *)

open Types
open Values
open Instance


let global (GlobalType (t, _) as gt) =
  let v =
    match t with
    | NumType I32Type -> Num (I32 666l)
    | NumType I64Type -> Num (I64 666L)
    | NumType F32Type -> Num (F32 (F32.of_float 666.6))
    | NumType F64Type -> Num (F64 (F64.of_float 666.6))
    | RefType _ -> Ref NullRef
    (* Start: Abstract Types *)
    | SealedAbsType _ -> assert false
    (* Start: Abstract Types *)
    | BotType -> assert false
  in Global.alloc gt v

let table =
  Table.alloc (TableType ({min = 10l; max = Some 20l}, FuncRefType)) NullRef
let memory = Memory.alloc (MemoryType {min = 1l; max = Some 2l})
let func f t = Func.alloc_host t (f t)

let print_value v =
  Printf.printf "%s : %s\n"
    (Values.string_of_value v)
    (Types.string_of_value_type (Values.type_of_value v))

let print (FuncType (_, out)) vs =
  List.iter print_value vs;
  flush_all ();
  List.map (fun v -> default_value (unwrap v)) out

let lookup name t =
  let open Types_shorthand in
  match Utf8.encode name, t with
  | "print", _ -> ExternFunc (func print (FuncType ([], [])))
  | "print_i32", _ -> ExternFunc (func print (FuncType ([r (NumType I32Type)], [])))
  | "print_i32_f32", _ ->
    ExternFunc (func print (FuncType ([r (NumType I32Type); r (NumType F32Type)], [])))
  | "print_f64_f64", _ ->
    ExternFunc (func print (FuncType ([r (NumType F64Type); r (NumType F64Type)], [])))
  | "print_f32", _ -> ExternFunc (func print (FuncType ([r (NumType F32Type)], [])))
  | "print_f64", _ -> ExternFunc (func print (FuncType ([r (NumType F64Type)], [])))
  | "global_i32", _ -> ExternGlobal (global (GlobalType (NumType I32Type, Immutable)))
  | "global_f32", _ -> ExternGlobal (global (GlobalType (NumType F32Type, Immutable)))
  | "global_f64", _ -> ExternGlobal (global (GlobalType (NumType F64Type, Immutable)))
  | "table", _ -> ExternTable table
  | "memory", _ -> ExternMemory memory
  | _ -> raise Not_found
